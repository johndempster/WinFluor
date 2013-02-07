unit PowerCalibrationUnit;

// 16-Jan-2013. DE. Automation of procedure to perform power calibration,
// i.e., determine Pockel Cell driving voltage to apply in order to
// obtain a particular output power.
// Reuses much code from TimeCourseUnit.pas and IDRFile.pas (both by JD).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XMultiYPlot, Grids;

const
  MaxPlotPoints = 10000;
  MaxLinesPerPlot = 5;
  MaxReadoutLines = 20;
  MaxPlots = 10;
  NumScansPerBuf = 512;
  ProtocolSteps = 20;
  ProtocolStepSize = 3.0; // in seconds
  AverageStart = 1.0; // Within a given protocol step, average from time
  AverageEnd = 3.0;   //   AverageStart to AverageEnd (from beginning of step)

type
  TSmallIntArray = Array[0..99999999] of SmallInt;
  PSmallIntArray = ^TSmallIntArray;

  TFitParameters = record
    Vpi: Single;
    NetBias: Single;
    Pmin: Single;
    Pmax: Single;
  end;

  TPlotDescription = record
    InUse: Boolean;
    Source: Integer;
    Background: Integer;
  end;

  TPowerCalibrationFrm = class(TForm)
    plPlot: TXMultiYPlot;
    PowerTable: TStringGrid;
    plFittedPlot: TXMultiYPlot;
    ParameterBox: TGroupBox;
    VpiLabel: TLabel;
    NetBiasLabel: TLabel;
    PMaxLabel: TLabel;
    PMinLabel: TLabel;
    VpiValueLabel: TLabel;
    NetBiasValueLabel: TLabel;
    PMaxValueLabel: TLabel;
    PMinValueLabel: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);

  private
    { Private declarations }
    // Plots: Array[0..15] of TPlotDescription;  // Plot description records
    LineColors: Array[0..MaxLinesPerPlot-1] of TColor;       // Line colours
    ColorSequence: Array[0..9] of TColor;     // Standard line colour sequence
    ReadoutCursor: Integer;                   // Plot readout cursor number
    LineName: Array[0..MaxLinesPerPlot-1] of String;         // Names of lines in plot
    LineUnits: Array[0..MaxLinesPerPlot-1] of String;        // Units of data values in lines
    TScale: Single;                           // Time units scaling factor
    TUnits: String;                           // Time units
    dt : Single;                   // Inter-scan time interval
    TInterval: Single;                        // Inter-Frame /-Line time interval (s)
    // StopPlot: Boolean;
    DrivingChannel: Integer;  // Channel measuring driving voltage
    PowerChannel: Integer;    // Channel measuring output power
    Channel: Integer; // Channel to plot
    DrivingValues: Array[0..ProtocolSteps-1] of Single;
    PowerValues: Array[0..ProtocolSteps-1] of Single;
    FittedParameters: TFitParameters;
    HalfPi: Double;
    procedure PlotLine;
    procedure PlotADCChannel(StartAtFrame: Integer;
                             EndAtFrame: Integer;
                             PlotNum: Integer;
                             LineNum: Integer);
    procedure TabulateAverages;
    procedure GetAverageValues(Channel: Integer; var Values: Array of Single);
    procedure WriteTableToFile;
    procedure TestFit;
    procedure FitCalibrationData;
    procedure PlotFittedCurve;

  public
    { Public declarations }
    PlotAvailable: Boolean;
    // procedure UpdateSettings;
    // procedure CopyImageToClipboard;
    // procedure CopyDataToClipboard;
    // procedure Print;

  end;

var
  PowerCalibrationFrm: TPowerCalibrationFrm;

implementation

uses Main, Math, CurveFitter; //, NonLinearFit, OptimizedFuncs;

{$R *.dfm}

procedure TPowerCalibrationFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
// ---------------------------
// Tidy up when form is closed
// ---------------------------
begin
  Action := caFree;
end;

procedure TPowerCalibrationFrm.FormShow(Sender: TObject);
// --------------------------------------
// Initialisations when form is displayed
// --------------------------------------
begin
  HalfPi := Pi/2.0;
  DrivingChannel := 1;
  PowerChannel := 2;
  ColorSequence[0] := clBlue;
  ColorSequence[1] := clRed;
  ColorSequence[2] := clGreen;
  ColorSequence[3] := clYellow;
  ColorSequence[4] := clGray;
  ColorSequence[5] := clBlack;
  ColorSequence[6] := clOlive;
  ColorSequence[7] := clPurple;
  ColorSequence[8] := clAqua;
  ColorSequence[9] := clMaroon;
  // Inter-scan interval (s)
  dt :=  MainFrm.IDRFile.ADCScanInterval;
  TInterval := MainFrm.IDRFile.FrameInterval/MainFrm.IDRFile.ADCNumScansInFile;
  PowerTable.RowCount := ProtocolSteps + 1;
  PowerTable.Cells[0,0] := MainFrm.IDRFile.ADCChannel[DrivingChannel].ADCName +
               ' (' + MainFrm.IDRFile.ADCChannel[DrivingChannel].ADCUnits + ')';
  PowerTable.Cells[1,0] := MainFrm.IDRFile.ADCChannel[PowerChannel].ADCName +
               ' (' + MainFrm.IDRFile.ADCChannel[PowerChannel].ADCUnits + ')';

  // Add readout cursor to plot
  plPlot.ClearVerticalCursors;
  ReadoutCursor := plPlot.AddVerticalCursor(clGreen, '?ri');

  plPlot.ShowMarkers := False;
  plPlot.ShowLines := True;

  Resize;

  // No plots available for display
  // PlotAvailable := False;
  Channel := DrivingChannel;
  plPlot.CreatePlot;
  PlotLine;
  Channel := PowerChannel;
  plPlot.CreatePlot;
  PlotLine;
  TabulateAverages;
  WriteTableToFile;

  // TestFit;
  FitCalibrationData;
  plFittedPlot.CreatePlot;
  PlotFittedCurve;
end;

procedure TPowerCalibrationFrm.PlotLine;
// --------------------
// Add a line to a plot
// --------------------
var
  StartAtFrame, EndAtFrame: Integer;
  PlotNum: Integer;
  LineNum: Integer;
  Col: TColor;
  i: Integer;
begin
  // Prevent other plot operations while line is plotted
  // PlotGrp.Enabled := False ;

  // Re-size readout label and plot
  // plPlot.Height := ClientHeight - plPlot.Top - 5;
  plPlot.Height := (ClientHeight div 2) - plPlot.Top - 5;

  // Ensure there is enough space allocated for line
  plPlot.MaxPointsPerLine := MaxPlotPoints*2 ;

  {// Select range of frames to be plotted
  if rbAllFrames.Checked then begin
    StartAtFrame := Round(edRange.LoLimit) ;
    EndAtFrame := Round(edRange.HiLimit) ;
  end else
  begin
    StartAtFrame := Round(edRange.LoValue) ;
    EndAtFrame := Round(edRange.HiValue ) ;
  end;}

  StartAtFrame := 1;
  EndAtFrame := MainFrm.IDRFile.ADCNumScansInFile;

//  PlotStartFrame := StartAtFrame;

  {// Seconds or minutes time units
  if rbSeconds.Checked then begin}
  TScale := 1.0;
  TUnits := 's';
  {end
    else begin
        TScale := 1.0 / 60.0 ;
        TUnits := 'min' ;
        end ;}

  // Add`new line to plot
  Col := ColorSequence[plPlot.NumLinesInPlot[plPlot.PlotNum]];
  LineNum := plPlot.CreateLine(Col,
                               msOpenSquare,
                               psSolid);
  LineColors[LineNum] := Col;

  { Plot graph of currently selected variables }
  plPlot.xAxisAutoRange := False ;
  plPlot.XAxisMin := 0.0 ;
  plPlot.XAxisMax := (EndAtFrame-StartAtFrame)*TInterval*TScale ;
  plPlot.XAxisTick := (plPlot.XAxisMax - plPlot.XAxisMin) / 5.0 ;
  plPlot.yAxisAutoRange := True ;

  { Create X and Y axes labels }
  plPlot.xAxisLabel := '(' + TUnits + ')' ;

  // Plot analogue signal channel
  PlotADCChannel(StartAtFrame,
                 EndAtFrame,
                 PlotNum,
                 LineNum);

  // Add annotations to plot
  plPlot.ClearAnnotations ;
  for i := 0 to MainFrm.IDRFile.NumMarkers-1 do
    plPlot.AddAnnotation(MainFrm.IDRFile.MarkerTime[i],
                         MainFrm.IDRFile.MarkerText[i]);

  plPlot.VerticalCursors[ReadoutCursor] := (plPlot.XAxisMax +
                                            plPlot.XAxisMin) / 2.0;

  MainFrm.StatusBar.SimpleText := format(
                                  ' Power calibration: Frames %d-%d plotted',
                                         [StartAtFrame,EndAtFrame]);

end;

procedure TPowerCalibrationFrm.PlotADCChannel(
                                  StartAtFrame: Integer; // Start at frame #
                                  EndAtFrame: Integer;   // End at frame #
                                  PlotNum: Integer;      // Plot on plot #
                                  LineNum: Integer);     // Plot as line #
// ----------------------------
// Plot analogue signal channel
// ----------------------------
var
  iChan: Integer;                // Channel # selected for plotting
  StartScan: Integer;            // Start plot scan #
  EndScan: Integer;              // End plot scan #
  NumScans: Integer;             // No. of channel scans in plot
  iScan: Integer;                // Scan index

  // Compression block variables
  BlockCount: Integer;           // No. of scans in block index
  NumScansPerBlock: Integer;     // No. scans in compression block
  NumPointsPerBlock: Integer;    // No. of displayed points per compression block
  y: Single;                    // Sample value
  yMin: Single;                 // Min. sample value within block
  yMax: Single;                 // Max. sample value within block
  yMaxAt: Integer;              // Blockcount index # of max sample
  yMinAt: Integer;              // Blockcount index of min sample

  NumPoints: Integer;           // No. of points in plot

  Done: Boolean;
  t : Single;                    // Current time (s)
  tStep : Single;                // Inter-point time interval on plot
  // File read buffer
  BufStartScan: Integer;
  NumScansRead: Integer;
  NumSamplesRead: Integer;
  iSample: Integer;              // Sample index
  ADCBuf: Array[0..NumScansPerBuf*(ADCChannelLimit+1)-1] of SmallInt;

begin
  // A/D channel to be plotted
  iChan := Channel;

  // Y axis label
  LineUnits[LineNum] := MainFrm.IDRFile.ADCChannel[iChan].ADCUnits ;
  LineName[LineNum] := MainFrm.IDRFile.ADCChannel[iChan].ADCName ;
  plPlot.yAxisLabel := MainFrm.IDRFile.ADCChannel[iChan].ADCName +
                 ' (' + MainFrm.IDRFile.ADCChannel[iChan].ADCUnits + ')';

  StartScan := Round( ((StartAtFrame-1)*TInterval)/dt) ;
  // EndScan := Round( (EndAtFrame*TInterval)/dt ) ;
  // Allow plotting of full ADC trace even if longer than line scan
  EndScan := Max(Round((EndAtFrame*TInterval)/dt),
                 MainFrm.IDRFile.ADCNumScansInFile);

  // No. of multi-channel scans to be displayed
  NumScans := EndScan - StartScan + 1;

  // Size of display compression block
  NumScansPerBlock := Max(NumScans div MaxPlotPoints, 1);
  // No. of display points per compression block
  NumPointsPerBlock := Min(NumScansPerBlock,2);

  // Initialise counters
  BlockCount := NumScansPerBlock;
  NumScansRead := NumScansPerBuf;
  iSample := NumScansRead * MainFrm.IDRFile.ADCNumChannels;
  BufStartScan := StartScan;
  iScan := StartScan;
  NumPoints := 0;
  Done := False;
  t := 0.0;
  tStep := (dt*NumScansPerBlock*TScale) / Max(NumPointsPerBlock,1) ;

  While not Done do
  begin
    // Load new buffer
    if iSample >= NumSamplesRead then
    begin
      NumScansRead := MainFrm.IDRFile.LoadADC(BufStartScan,
                                              NumScansPerBuf,
                                              ADCBuf);
      NumSamplesRead := NumScansRead * MainFrm.IDRFile.ADCNumChannels;
      BufStartScan := BufStartScan + NumScansPerBuf;
      iSample := MainFrm.IDRFile.ADCChannel[iChan].ChannelOffset;
      if NumScansRead <= 0 then
        Break;
    end;

    // Initialise compression block
    if BlockCount >= NumScansPerBlock then
    begin
      yMin := 1E30;
      yMax := -1E30;
      BlockCount := 0;
    end;

    // Get A/D sample and add to block
    y := (ADCBuf[iSample] - MainFrm.IDRFile.ADCChannel[iChan].ADCZero) *
         MainFrm.IDRFile.ADCChannel[iChan].ADCScale;
    if y < yMin then
    begin
      yMin := y;
      yMinAt := BlockCount;
    end;
    if y > yMax then
    begin
      yMax := y;
      yMaxAt := BlockCount;
    end;
    iSample := iSample + MainFrm.IDRFile.ADCNumChannels;
    Inc(BlockCount);

    // When block complete ... write min./max. to display buffer
    if BlockCount >= NumScansPerBlock then
    begin
      // First point
      if yMaxAt <= yMinAt then
        plPlot.AddPoint(LineNum, t, yMax)
      else plPlot.AddPoint(LineNum, t, yMin);
      t := t + tStep;
      Inc(NumPoints);

      // Second point
      if BlockCount > 1 then
      begin
        if yMaxAt >= yMinAt then
          plPlot.AddPoint(LineNum, t, yMax)
        else plPlot.AddPoint(LineNum, t, yMin);
        t := t + tStep;
        Inc(NumPoints);
      end;

    end ;

    Inc(iScan);
    if (iScan > EndScan) or
       (NumScansRead <= 0) or
       (NumPoints > (MaxPlotPoints*2)) then
      Done := True;

  end;
end;


procedure TPowerCalibrationFrm.FormResize(Sender: TObject);
// ----------------------------------------
// Adjusted controls when form is re-sized
// ----------------------------------------
begin
  // Plot display area
  plPlot.Height := Max((ClientHeight div 2) - plPlot.Top - 5, 2);
  plPlot.Width := Max(ClientWidth - plPlot.Left -
                           15 - PowerTable.Width, 2);
  PowerTable.Left := plPlot.Left + plPlot.Width + 5;
  ParameterBox.Left := PowerTable.Left;
  ParameterBox.Top := PowerTable.Top + PowerTable.Height + 10;
  ParameterBox.Width := PowerTable.Width;
  plFittedPlot.Top := plPlot.Top + plPlot.Height + 10;
  plFittedPlot.Width := plPlot.Width;
  plFittedPlot.Height := plPlot.Height;
end;


procedure TPowerCalibrationFrm.TabulateAverages;
var
  i: Integer;
begin
  GetAverageValues(DrivingChannel, DrivingValues);
  for i := 0 to ProtocolSteps-1 do
  begin
    PowerTable.Cells[0, i+1] := format('%0.2f', [DrivingValues[i]]);
  end;
  GetAverageValues(PowerChannel, PowerValues);
  for i := 0 to ProtocolSteps-1 do
  begin
    PowerTable.Cells[1, i+1] := format('%0.2f', [PowerValues[i]]);
  end;
end;

procedure TPowerCalibrationFrm.GetAverageValues(Channel: Integer;
                              var Values: Array of Single);
var
  Step: Integer;
  Sum: Integer;
  BlockSize: Integer;
  i: Integer;
  ChannelOffset: Integer;
  PADCBuf: PSmallIntArray;
  NumScansRead: Integer;
  BufStartScan: Integer;
  AvgStartScan: Integer;
  AvgEndScan: Integer;
  ThisEndScan: Integer;
begin
  ChannelOffset := MainFrm.IDRFile.ADCChannel[Channel].ChannelOffset;
  BlockSize := MainFrm.IDRFile.ADCNumScansInFile div ProtocolSteps;
  AvgStartScan := Max(Round(AverageStart / dt), 0);
  AvgEndScan := Min(Round(AverageEnd / dt), BlockSize);
  GetMem(PADCBuf, BlockSize*MainFrm.IDRFile.ADCNumChannels*2);
  for Step := 0 to ProtocolSteps-1 do
  begin
    Values[Step] := 0.0;
    Sum := 0;
    ThisEndScan := AvgEndScan;
    BufStartScan := Step*BlockSize;
    NumScansRead := MainFrm.IDRFile.LoadADC(BufStartScan,
                                            BlockSize,
                                            PADCBuf^);
    if (NumScansRead < AvgStartScan) then
      Continue;
    if (NumScansRead < AvgEndScan) then
      ThisEndScan := NumScansRead;
    for i := AvgStartScan to ThisEndScan-1 do
    begin
      Sum := Sum + (PADCBuf^[i*MainFrm.IDRFile.ADCNumChannels + ChannelOffset] -
                    MainFrm.IDRFile.ADCChannel[Channel].ADCZero);
    end;
    Values[Step] := MainFrm.IDRFile.ADCChannel[Channel].ADCSCale *
                      Sum / (ThisEndScan - AvgStartScan);
  end;
  FreeMem(PADCBuf);
end;

procedure TPowerCalibrationFrm.WriteTableToFile;
const
  TableSize = 4095;
var
  TableFileName: String;
  TableFileHandle: Integer;
  TableText: Array[0..TableSize] of Char;
  i,j,k: Integer;
  MyLine: String;
  TableFileSize: Integer;
begin
  // Create Calibration Table file
  TableFileName :=  ChangeFileExt(MainFrm.IDRFile.FileName, '_pwrcal.txt');
  TableFileHandle := FileCreate(TableFileName, fmOpenReadWrite);
  if TableFileHandle < 0 then
  begin
    ShowMessage('Unable to open file ' + TableFileName + 'for read/write.');
    Exit;
  end;
  // Initialise empty buffer with zero bytes
  for i := 0 to sizeof(TableText) do
    TableText[i] := chr(0);
  TableFileSize := 0;

  for i := 0 to PowerTable.RowCount-1 do
  begin
    MyLine := PowerTable.Cells[0, i] + chr(9) +
              PowerTable.Cells[1, i] + chr(13) + chr(10);
    j := TableFileSize;
    // while (TableText[j] <> chr(0)) and (j < High(TableText)) do
    //  j := j + 1;
    if (j + length(MyLine)) < High(TableText) then
    begin
      for k := 1 to length(MyLine) do
      begin
        TableText[j] := MyLine[k];
        j := j + 1;
      end;
      TableFileSize := TableFileSize + length(MyLine);
    end else
    begin
      ShowMessage('Ran out of room trying to write table to file.');
      Exit;
    end;
  end;

  FileWrite(TableFileHandle, PByteArray(@TableText)^, TableFileSize);

  FileClose(TableFileHandle);
end;

{procedure TPowerCalibrationFrm.TestFit;
// No inputs or outputs, I just want to test the lsfit routines to see if
// I can get them to work at all.  Code copied directly from example in
// ALGLIB documentation.
var
  M : AlglibInteger;  // dimensionality of input
  N : AlglibInteger;  // number of data points
  K : AlglibInteger;  // number of parameters to fit
  Y : TReal1DArray;   // data output
  X : TReal2DArray;   // data input
  C : TReal1DArray;   // parameters of function being fitted to
  Rep : LSFitReport;
  State : LSFitState;
  Info : AlglibInteger;
  EpsF : Double;
  EpsX : Double;
  MaxIts : AlglibInteger;
  I : AlglibInteger;
  J : AlglibInteger;
  A : Double;
  B : Double;
begin
  ShowMessage(Format(
    'Fitting 0.5(1+cos(x)) on [-pi,+pi] with exp(-alpha*x^2)',[]));

  //
  // Fitting 0.5(1+cos(x)) on [-pi,+pi] with Gaussian exp(-alpha*x^2):
  // * without Hessian (gradient only)
  // * using alpha=1 as initial value
  // * using 1000 uniformly distributed points to fit to
  //
  // Notes:
  // * N - number of points
  // * M - dimension of space where points reside
  // * K - number of parameters being fitted
  //
  N := 1000;
  M := 1;
  K := 1;
  A := -Pi;
  B := +Pi;

  //
  // Prepare task matrix
  //
  SetLength(Y, N);
  SetLength(X, N, M);
  SetLength(C, K);
  I:=0;
  while I<=N-1 do
  begin
    X[I,0] := A+(B-A)*I/(N-1);
    Y[I] := 0.5*(1+Cos(X[I,0]));
    Inc(I);
  end;
  C[0] := 1.0;
  EpsF := 0.0;
  EpsX := 0.0001;
  MaxIts := 0;

  //
  // Solve
  //
  LSFitNonlinearFG(X, Y, C, N, M, K, True, State);
  LSFitNonlinearSetCond(State, EpsF, EpsX, MaxIts);
  while LSFitNonlinearIteration(State) do
  begin
    if State.NeedF then
    begin

    //
    // F(x) = Exp(-alpha*x^2)
    //
    State.F := Exp(-State.C[0]*AP_Sqr(State.X[0]));
    end;
    if State.NeedFG then
    begin

    //
    // F(x)      = Exp(-alpha*x^2)
    // dF/dAlpha = (-x^2)*Exp(-alpha*x^2)
    //
    State.F := Exp(-State.C[0]*AP_Sqr(State.X[0]));
    State.G[0] := -AP_Sqr(State.X[0])*State.F;
    end;
  end;
  LSFitNonlinearResults(State, Info, C, Rep);
  ShowMessage(Format('alpha:   %0.3f',[C[0]]));
  ShowMessage(Format('rms.err: %0.3f',[Rep.RMSError]));
  ShowMessage(Format('max.err: %0.3f',[Rep.MaxError]));
  ShowMessage(Format('Termination type: %0d',[Info]));
end;}

procedure TPowerCalibrationFrm.TestFit;
// No inputs or outputs, I just want to test the CurveFitter routines to see if
// I can get them to work at all.  Code transmogrified pseudo-directly from
// example in ALGLIB documentation.
var
  TestFitter: TCurveFitter;
  M: Integer;  // dimensionality of input
  N: Integer;  // number of data points
  K: Integer;  // number of parameters to fit
  Y: Single;   // data output
  X: Single;   // data input
  // C: Single;   // parameters of function being fitted to
  // Rep : LSFitReport;
  // State : LSFitState;
  // Info : AlglibInteger;
  // EpsF : Double;
  // EpsX : Double;
  // MaxIts : AlglibInteger;
  I: Integer;
  // J: Integer;
  A: Double;
  B: Double;
begin
  ShowMessage('About to create...');
  TestFitter := TCurveFitter.Create(Self);
  ShowMessage('Created...');

  ShowMessage(Format(
    'Fitting 0.5(1+cos(x)) on [-pi,+pi] with exp(-alpha*x^2)',[]));

  //
  // Fitting 0.5(1+cos(x)) on [-pi,+pi] with Gaussian exp(-alpha*x^2):
  // * without Hessian (gradient only)
  // * using alpha=1 as initial value
  // * using 1000 uniformly distributed points to fit to
  //
  // Notes:
  // * N - number of points
  // * M - dimension of space where points reside
  // * K - number of parameters being fitted
  //
  N := 1000;
  M := 1;
  K := 3;
  A := -Pi;
  B := +Pi;

  TestFitter.Equation := Gaussian;
  ShowMessage('Equation set to Gaussian...');
  TestFitter.FixedParameters[0] := True;
  TestFitter.Parameters[0] := 0.0;
  TestFitter.FixedParameters[2] := True;
  TestFitter.Parameters[2] := 1.0;

  TestFitter.FixedParameters[1] := False;

  ShowMessage('Initialized TestFitter Parameters...');
  //
  // Prepare task matrix
  //
  I:=0;
  while I<=N-1 do
  begin
    X := A+(B-A)*I/(N-1);
    Y := 0.5*(1+Cos(X));
    TestFitter.AddPoint(X,Y);
    Inc(I);
  end;
  TestFitter.Parameters[1] := 0.707;
  // EpsF := 0.0;
  // EpsX := 0.0001;
  // MaxIts := 0;
  ShowMessage('Loaded data points, going to fit...');

  //
  // Solve
  //
  TestFitter.FitCurve; // Okay that part is easier, I admit. :/
  ShowMessage('After FitCurve.');
  {LSFitNonlinearFG(X, Y, C, N, M, K, True, State);
  LSFitNonlinearSetCond(State, EpsF, EpsX, MaxIts);
  while LSFitNonlinearIteration(State) do
  begin
    if State.NeedF then
    begin

    //
    // F(x) = Exp(-alpha*x^2)
    //
    State.F := Exp(-State.C[0]*AP_Sqr(State.X[0]));
    end;
    if State.NeedFG then
    begin

    //
    // F(x)      = Exp(-alpha*x^2)
    // dF/dAlpha = (-x^2)*Exp(-alpha*x^2)
    //
    State.F := Exp(-State.C[0]*AP_Sqr(State.X[0]));
    State.G[0] := -AP_Sqr(State.X[0])*State.F;
    end;
  end;
  LSFitNonlinearResults(State, Info, C, Rep);}
  ShowMessage(Format('alpha:   %0.3f',
                     [1/(2*TestFitter.Parameters[1]*TestFitter.Parameters[1])]));
  ShowMessage(TestFitter.FitResults);
  // ShowMessage(Format('rms.err: %0.3f',[Rep.RMSError]));
  // ShowMessage(Format('max.err: %0.3f',[Rep.MaxError]));
  // ShowMessage(Format('Termination type: %0d',[Info]));}
end;


{procedure TPowerCalibrationFrm.FitCalibrationData;
var
  M: AlglibInteger;  // dimensionality of input
  N: AlglibInteger;  // number of data points
  K: AlglibInteger;  // number of parameters to fit
  Y: TReal1DArray;   // data output
  X: TReal2DArray;   // data input
  C: TReal1DArray;   // parameters of function being fitted to
  Rep: LSFitReport;
  State: LSFitState;
  Info: AlglibInteger;
  EpsF: Double;
  EpsX: Double;
  MaxIts: AlglibInteger;
  I: AlglibInteger;
  // J: AlglibInteger;
  // A: Double;
  // B: Double;
  PowerMax: Single;
  PowerMaxIndex: Integer;
  PowerMin: Single;
  PowerMinIndex: Integer;
begin
  // Fitting Amp * sin^2[(x-v_b)/v_pi] + P_min
  // * without Hessian (gradient only)
  //
  // Notes:
  // * N - number of points (here ProtocolSteps)
  // * M - dimension of space where points reside (here 1)
  // * K - number of parameters being fitted (here 4)
  //
  N := ProtocolSteps;
  M := 1;
  K := 4;

  PowerMax := PowerValues[0];
  PowerMaxIndex := 0;
  PowerMin := PowerValues[0];
  PowerMinIndex := 0;

  //
  // Prepare task matrix
  //
  SetLength(Y, N);
  SetLength(X, N, M);
  SetLength(C, K);
  I:=0;
  while I<=N-1 do
  begin
    X[I,0] := DrivingValues[I];
    Y[I] := PowerValues[I];
    if (PowerValues[I] > PowerMax) then
    begin
      PowerMax := PowerValues[I];
      PowerMaxIndex := I;
    end;
    if (PowerValues[I] < PowerMin) then
    begin
      PowerMin := PowerValues[I];
      PowerMinIndex := I;
    end;
    Inc(I);
  end;
  C[0] := DrivingValues[PowerMaxIndex]; // V_pi
  C[1] := DrivingValues[PowerMinIndex]; // V_b
  C[2] := PowerMax - PowerMin;
  C[3] := PowerMin;
  EpsF := 0.0;
  EpsX := 0.0001;
  MaxIts := 0;

  //
  // Solve
  //
  LSFitNonlinearFG(X, Y, C, N, M, K, True, State);
  LSFitNonlinearSetCond(State, EpsF, EpsX, MaxIts);
  while LSFitNonlinearIteration(State) do
  begin
    if State.NeedF then
    begin
      State.F := State.C[2] * AP_Sqr(Sin(HalfPi *
         (State.X[0]-State.C[1])/State.C[0])) + State.C[3];
    end;
    if State.NeedFG then
    begin
      State.F := State.C[2] * AP_Sqr(Sin(HalfPi *
         (State.X[0]-State.C[1])/State.C[0])) + State.C[3];
      State.G[0] := -Pi * (State.C[2] *
                    (State.X[0]-State.C[1])/AP_Sqr(State.C[0])) *
                     Sin(HalfPi * (State.X[0]-State.C[1])/State.C[0]) *
                     Cos(HalfPi * (State.X[0]-State.C[1])/State.C[0]);
      State.G[1] := -Pi * (State.C[2] / State.C[0]) *
                     Sin(HalfPi * (State.X[0]-State.C[1])/State.C[0]) *
                     Cos(HalfPi * (State.X[0]-State.C[1])/State.C[0]);
      State.G[2] := AP_Sqr(Sin(HalfPi * (State.X[0]-State.C[1])/State.C[0]));
      State.G[3] := 1;
    end;
  end;
  LSFitNonlinearResults(State, Info, C, Rep);
  FittedParameters.Vpi := C[0];
  FittedParameters.NetBias := 375*C[1]/C[0];
  FittedParameters.Pmax := C[2]+C[3];
  FittedParameters.Pmin := C[3];
  VpiValueLabel.Caption := Format('%0.2f', [FittedParameters.Vpi]);
  NetBiasValueLabel.Caption := Format('%0.2f', [FittedParameters.NetBias]);
  PMaxValueLabel.Caption := Format('%0.2f', [FittedParameters.Pmax]);
  PMinValueLabel.Caption := Format('%0.2f', [FittedParameters.Pmin]);
end;}

procedure TPowerCalibrationFrm.FitCalibrationData;
var
  SinSqrdFitter: TCurveFitter;
  // M: AlglibInteger;  // dimensionality of input
  N: Integer;  // number of data points
  // K: AlglibInteger;  // number of parameters to fit
  Y: Single;   // data output
  X: Single;   // data input
  // C: TReal1DArray;   // parameters of function being fitted to
  // Rep: LSFitReport;
  // State: LSFitState;
  // Info: AlglibInteger;
  // EpsF: Double;
  // EpsX: Double;
  // MaxIts: AlglibInteger;
  I: Integer;
  // J: AlglibInteger;
  // A: Double;
  // B: Double;
  // PowerMax: Single;
  // PowerMaxIndex: Integer;
  // PowerMin: Single;
  // PowerMinIndex: Integer;
begin
  // Fitting Amp * sin^2[(x-v_b)/v_pi] + P_min
  // * without Hessian (gradient only)
  //
  // Notes:
  // * N - number of points (here ProtocolSteps)
  // * M - dimension of space where points reside (here 1)
  // * K - number of parameters being fitted (here 4)
  //
  SinSqrdFitter := TCurveFitter.Create(Self);
  SinSqrdFitter.Equation := SinSqrd;

  N := ProtocolSteps;
  // M := 1;
  // K := 4;

  // These are done automatically in TCurveFitter.InitialGuess.
  // PowerMax := PowerValues[0];
  // PowerMaxIndex := 0;
  // PowerMin := PowerValues[0];
  // PowerMinIndex := 0;

  //
  // Prepare task matrix
  //
  // SetLength(Y, N);
  // SetLength(X, N, M);
  // SetLength(C, K);
  I:=0;
  while I<=N-1 do
  begin
    X := DrivingValues[I];
    Y := PowerValues[I];
    SinSqrdFitter.AddPoint(X, Y);
    Inc(I);
  end;

  // C[0] := DrivingValues[PowerMaxIndex]; // V_pi
  // C[1] := DrivingValues[PowerMinIndex]; // V_b
  // C[2] := PowerMax - PowerMin;
  // C[3] := PowerMin;
  // EpsF := 0.0;
  // EpsX := 0.0001;
  // MaxIts := 0;

  //
  // Solve
  //
  SinSqrdFitter.FitCurve;
  {LSFitNonlinearFG(X, Y, C, N, M, K, True, State);
  LSFitNonlinearSetCond(State, EpsF, EpsX, MaxIts);
  while LSFitNonlinearIteration(State) do
  begin
    if State.NeedF then
    begin
      State.F := State.C[2] * AP_Sqr(Sin(HalfPi *
         (State.X[0]-State.C[1])/State.C[0])) + State.C[3];
    end;
    if State.NeedFG then
    begin
      State.F := State.C[2] * AP_Sqr(Sin(HalfPi *
         (State.X[0]-State.C[1])/State.C[0])) + State.C[3];
      State.G[0] := -Pi * (State.C[2] *
                    (State.X[0]-State.C[1])/AP_Sqr(State.C[0])) *
                     Sin(HalfPi * (State.X[0]-State.C[1])/State.C[0]) *
                     Cos(HalfPi * (State.X[0]-State.C[1])/State.C[0]);
      State.G[1] := -Pi * (State.C[2] / State.C[0]) *
                     Sin(HalfPi * (State.X[0]-State.C[1])/State.C[0]) *
                     Cos(HalfPi * (State.X[0]-State.C[1])/State.C[0]);
      State.G[2] := AP_Sqr(Sin(HalfPi * (State.X[0]-State.C[1])/State.C[0]));
      State.G[3] := 1;
    end;
  end;
  LSFitNonlinearResults(State, Info, C, Rep);}
  FittedParameters.Vpi := SinSqrdFitter.Parameters[0] / 1000.0;
  FittedParameters.NetBias := 375*SinSqrdFitter.Parameters[1] /
                                  SinSqrdFitter.Parameters[0];
  FittedParameters.Pmax := SinSqrdFitter.Parameters[2] +
                           SinSqrdFitter.Parameters[3];
  FittedParameters.Pmin := SinSqrdFitter.Parameters[3];
  VpiValueLabel.Caption := Format('%0.2f', [FittedParameters.Vpi]);
  NetBiasValueLabel.Caption := Format('%0.2f', [FittedParameters.NetBias]);
  PMaxValueLabel.Caption := Format('%0.2f', [FittedParameters.Pmax]);
  PMinValueLabel.Caption := Format('%0.2f', [FittedParameters.Pmin]);
end;


procedure TPowerCalibrationFrm.PlotFittedCurve;
var
  Col: TColor;
  LineNum: Integer;
  i,j: Integer;
  x, y, DelX, DelY, Arg: Single;
begin
  // Add readout cursor to plot
  plFittedPlot.ClearVerticalCursors;
  ReadoutCursor := plFittedPlot.AddVerticalCursor(clGreen, '?ri');

  plFittedPlot.ShowMarkers := False;
  plFittedPlot.ShowLines := True;

  plFittedPlot.MaxPointsPerLine := MaxPlotPoints*2 ;

  Col := ColorSequence[0];
  LineNum := plFittedPlot.CreateLine(Col,
                                     msOpenSquare,
                                     psSolid);

  { Plot graph of currently selected variables }
  plFittedPlot.XAxisAutoRange := False;
  plFittedPlot.XAxisMin := 0.0;
  plFittedPlot.XAxisMax := 2000.0;
  plFittedPlot.XAxisTick := (plFittedPlot.XAxisMax - plFittedPlot.XAxisMin) /
                             5.0;
  plFittedPlot.YAxisAutoRange := False;
  plFittedPlot.YAxisTick := 50.0;
  plFittedPlot.YAxisMin := -plFittedPlot.YAxisTick;
  plFittedPlot.YAxisMax := plFittedPlot.YAxisTick *
                        Ceil(FittedParameters.Pmax / plFittedPlot.YAxisTick);

  { Create X and Y axes labels }
  plFittedPlot.xAxisLabel :=
                        MainFrm.IDRFile.ADCChannel[DrivingChannel].ADCName +
                 ' (' + MainFrm.IDRFile.ADCChannel[DrivingChannel].ADCUnits +
                 ')';
  plFittedPlot.yAxisLabel := MainFrm.IDRFile.ADCChannel[PowerChannel].ADCName +
                              ' (mW)';

  for i := 0 to MaxPlotPoints do
  begin
    x := i * (plFittedPlot.XAxisMax - plFittedPlot.XAxisMin) /
              MaxPlotPoints;
    Arg := HalfPi * (x/(FittedParameters.Vpi * 1000.0) -
                     FittedParameters.NetBias / 375.0);
    y := (FittedParameters.Pmax - FittedParameters.Pmin) *
         Sin(Arg) * Sin(Arg) + FittedParameters.Pmin;
    plFittedPlot.AddPoint(LineNum, x, y);
  end;
  DelX := 0.01 * (plFittedPlot.XAxisMax - plFittedPlot.XAxisMin);
  DelY := DelX * ((plFittedPlot.YAxisMax - plFittedPlot.YAxisMin) /
                  (plFittedPlot.XAxisMax - plFittedPlot.XAxisMin)) *
                 (plFittedPlot.Width / plFittedPlot.Height);
  Col := ColorSequence[1];

  for i := 0 to ProtocolSteps-1 do
  begin
    LineNum := plFittedPlot.CreateLine(Col,
                                       msOpenSquare,
                                       psSolid);
    plFittedPlot.AddPoint(LineNum, Max(DrivingValues[i] - DelX,
                                       plFittedPlot.XAxisMin), PowerValues[i]);
    plFittedPlot.AddPoint(LineNum, Min(DrivingValues[i] + DelX,
                                       plFittedPlot.XAxisMax), PowerValues[i]);

    LineNum := plFittedPlot.CreateLine(Col,
                                       msOpenSquare,
                                       psSolid);
    plFittedPlot.AddPoint(LineNum, DrivingValues[i], Max(PowerValues[i] - DelY,
                                       plFittedPlot.YAxisMin));
    plFittedPlot.AddPoint(LineNum, DrivingValues[i], Min(PowerValues[i] + DelY,
                                       plFittedPlot.YAxisMax));
  end;
end;

end.
