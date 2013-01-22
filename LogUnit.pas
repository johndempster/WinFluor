unit LogUnit;
// --------------
// Experiment log
// --------------
// 08.07.04
// 21.06.05 ... Log file updated every time a line is added

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, maths ;

type
  TLogFrm = class(TForm)
    meLog: TMemo;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure meLogKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    LogFileName : String ;
    procedure AddLine( LineText : String ) ;
    procedure AddLineNoTime( LineText : String ) ;
    procedure SaveLogToFile ;
  end;

var
  LogFrm: TLogFrm;

implementation

{$R *.dfm}

procedure TLogFrm.AddLine( LineText : String );
// ---------------
// Add line to log
// ---------------
begin
    meLog.Lines.Add(TimeToStr(Time) + ' ' + LineText ) ;
    SaveLogToFile ;
    end;


procedure TLogFrm.AddLineNoTime( LineText : String );
// -------------------------------
// Add line to log (no time stamp)
// -------------------------------
begin
    meLog.Lines.Add( LineText ) ;
    SaveLogToFile ;
    end;



procedure TLogFrm.FormResize(Sender: TObject);
// ----------------------------------
// Update controls when form re-sized
// ----------------------------------
begin
     meLog.Width :=  MaxInt( [ClientWidth - meLog.Left - 10,2]) ;
     meLog.Height := MaxInt( [ClientHeight - 2*meLog.Top, 2]) ;
     end;


procedure TLogFrm.FormCreate(Sender: TObject);
// ------------------------------------
// Load from log file when form created
// ------------------------------------
var
    FileHandle : Integer ;
    NumBytes : Integer ;
    Buf : PChar ;
begin

    // Re-size form to set up control sizes
    Resize ;

    DateSeparator := '-' ;
    LogFileName := ExtractFilePath(ParamStr(0)) +
                   'WinFluor Log ' +
                   DateToStr(Date) +
                   '.log' ;
    Caption := 'Log: ' + LogFileName ;

    if not FileExists(LogFileName) then Exit ;

    // If file already exists load log text
    FileHandle := FileOpen(LogFileName, fmOpenRead);
    if FileHandle < 0 then begin
       ShowMessage( 'Unable to open ' + LogFileName ) ;
       Exit ;
       end ;

    // Load text into memo control
    NumBytes := FileSeek( FileHandle, 0, 2 ) ;
    if NumBytes > 0 then begin
       GetMem( Buf, NumBytes+1 ) ;
       FileSeek( FileHandle, 0, 0 ) ;
       FileRead( FileHandle, Buf^, NumBytes ) ;
       meLog.SetSelTextBuf( Buf );
       FreeMem( Buf ) ;
       end ;

    FileClose( FileHandle ) ;

    end;


procedure TLogFrm.FormDestroy(Sender: TObject);
// -----------------------------------
// Actions take when form is destroyed
// -----------------------------------
begin
    // Save log to file
    SaveLogToFile ;
    end ;


procedure TLogFrm.SaveLogToFile ;
// ---------------------
// Save data to log file
// ---------------------
var
    FileHandle : Integer ;
    NumBytes : Integer ;
    Buf : PChar ;
    ZeroByte : Byte ;
begin

    // Create new log file
    if FileExists(LogFileName) then DeleteFile(PChar(LogFileName)) ;
    FileHandle := FileCreate(LogFileName);
    if FileHandle < 0 then begin
       MessageDlg( 'Unable to create ' + LogFileName,mtError, [mbOK], 0 ) ;
       Exit ;
       end ;

    // Save memo control text to file
    meLog.SelectAll ;
    NumBytes := meLog.SelLength ;
    ZeroByte := 0 ;
    if NumBytes > 0 then begin
       GetMem( Buf, NumBytes+1 ) ;
       meLog.GetSelTextBuf(Buf, NumBytes+1) ;
       FileSeek(  FileHandle, 0, 0 ) ;
       FileWrite( FileHandle, Buf^, NumBytes ) ;
       FileWrite( FileHandle, ZeroByte, 1 ) ;
       FreeMem( Buf ) ;
       end ;

    FileClose( FileHandle ) ;

    // Set selected region to zero
    meLog.SelLength := 0 ;
    meLog.SelStart := NumBytes ;

    end;


procedure TLogFrm.meLogKeyPress(Sender: TObject; var Key: Char);
// ----------------------------------
// When CR is pressed update log file
// ----------------------------------
begin
     if Key = #13 then SaveLogToFile ;
     end;

procedure TLogFrm.FormActivate(Sender: TObject);
begin
     meLog.SelStart := melog.GetTextLen-1 ;

     end;

procedure TLogFrm.FormShow(Sender: TObject);
begin
meLog.SelStart := melog.GetTextLen-1 ;
end;

end.
