program WinFluor;

uses
  Forms,
  Main in 'MAIN.PAS' {MainFrm},
  About in 'about.pas' {AboutBox},
  RecUnit in 'RecUnit.pas' {RecordFrm},
  ViewUnit in 'ViewUnit.pas' {ViewFrm},
  SetupUnit in 'SetupUnit.pas' {SetupFrm},
  LabIOUnit in 'LabIOUnit.pas' {LabIO: TDataModule},
  HistogramUnit in 'HistogramUnit.pas' {HistogramFrm},
  FileIOUnit in 'FileIOUnit.pas' {FileIO: TDataModule},
  StimSetupUnit in 'StimSetupUnit.pas' {StimSetupFrm},
  ExcSetupUnit in 'ExcSetupUnit.pas' {ExcSetupFrm},
  TimeCourseUnit in 'TimeCourseUnit.pas' {TimeCourseFrm},
  Printgra in 'Printgra.pas' {PrintGraphFrm},
  Setaxes in 'SETAXES.PAS' {SetAxesFrm},
  AmpModule in 'AmpModule.pas' {Amplifier: TDataModule},
  NIDAQCNS in 'nidaqcns.pas',
  Sealtest in 'SEALTEST.PAS' {SealTestFrm},
  AverageUnit in 'AverageUnit.pas' {AverageFrm},
  LineProfileUnit in 'LineProfileUnit.pas' {LineProfileFrm},
  RatioUnit in 'RatioUnit.pas' {RatioFrm},
  SetupADCUnit in 'SetupADCUnit.pas' {SetupADCFrm},
  SetupIonUnit in 'SetupIonUnit.pas' {SetupIonFrm},
  PrintRec in 'PRINTREC.PAS' {PrintRecFrm},
  RecADCOnlyUnit in 'RecADCOnlyUnit.pas' {RecADCOnlyFrm},
  AVIUnit in 'AVIUnit.pas' {AVIFrm},
  exportAnalogueUnit in 'exportAnalogueUnit.pas' {ExportAnalogueFrm},
  ViewLineUnit in 'ViewLineUnit.pas' {ViewLineFrm},
  WinFluor_TLB in 'WinFluor_TLB.pas',
  AutoUnit in 'AutoUnit.pas' {AUTO: CoClass},
  LogUnit in 'LogUnit.pas' {LogFrm},
  LightSourceUnit in 'LightSourceUnit.pas' {LightSource: TDataModule},
  ExportImagesUnit in 'ExportImagesUnit.pas' {ExportImagesFrm},
  Wavgen in 'WAVGEN.PAS' {WavGenFrm},
  StimModule in 'StimModule.pas' {Stimulator: TDataModule},
  EventAnalysisUnit in 'EventAnalysisUnit.pas' {EventAnalysisFrm},
  ExportADCEventsUnit in 'ExportADCEventsUnit.pas' {ExportEventsFrm},
  FilePropsUnit in 'FilePropsUnit.pas' {FilePropsFrm},
  PlotSETAXES in 'PlotSETAXES.PAS' {PlotSetAxesFrm},
  SaveAsFileUnit in 'SaveAsFileUnit.pas' {SaveAsFileFrm},
  nidaqlib in 'nidaqlib.pas',
  UltimaUnit in 'UltimaUnit.pas' {Ultima: TDataModule},
  ViewPlotUnit in 'ViewPlotUnit.pas' {ViewPlotFrm},
  RecPlotUnit in 'RecPlotUnit.pas' {RecPlotFrm},
  StimulusDefaultsUnit in 'StimulusDefaultsUnit.pas' {StimulusDefaultsFrm},
  SetCCDReadoutUnit in 'SetCCDReadoutUnit.pas' {SetCCDReadoutFrm},
  AVITypes in 'AVITypes.pas',
  SpectrumUnit in 'SpectrumUnit.pas' {SpectrumFrm},
  SetLasersUnit in 'SetLasersUnit.pas' {SetLasersFrm},
  EditROIUnit in 'EditROIUnit.pas' {EditROIFrm},
  Graphics in '..\Source\Vcl\Graphics.pas',
  SnapUnit in 'SnapUnit.pas' {SnapFrm},
  PhotoStimUnit in 'PhotoStimUnit.pas' {PhotoStimFrm},
  MATFileWriterUnit in 'MATFileWriterUnit.pas',
  SmoothDifferentiateUnit in 'SmoothDifferentiateUnit.pas' {SmoothDifferentiateFrm},
  CameraSettingsUnit in 'CameraSettingsUnit.pas' {CameraSettingsFrm},
  PhotoStimSetupUnit in 'PhotoStimSetupUnit.pas' {PhotoStimSetupFrm},
  DynamicProtocolSetupUnit in 'DynamicProtocolSetupUnit.pas' {DynamicProtocolSetupFrm},
  PhotoStimModule in 'PhotoStimModule.pas' {PhotoStimulator: TDataModule},
  ExportROITImeCourseUnit in 'ExportROITImeCourseUnit.pas' {ExportROITimeCourseFrm},
  PlaybackStimModule in 'PlaybackStimModule.pas' {PlaybackStimulator: TDataModule},
  PlaybackSetupUnit in 'PlaybackSetupUnit.pas' {PlaybackSetupFrm},
  DigitalFilterUnit in 'DigitalFilterUnit.pas' {DigitalFilterFrm},
  DirectControlUnit in 'DirectControlUnit.pas' {DirectControlFrm},
  HTMLHelpViewer in '..\SESComponents\HTMLHelpViewer.pas',
  Maths in '..\SESComponents\Maths.pas',
  ZStageUnit in 'ZStageUnit.pas' {ZStage: TDataModule};

{$R *.TLB}

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'WinFluor V3.4.6';
  Application.HelpFile := 'C:\Program Files\Borland\Delphi7\WinFluor\WINFLUOR.chm';
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TLabIO, LabIO);
  Application.CreateForm(TFileIO, FileIO);
  Application.CreateForm(TPrintGraphFrm, PrintGraphFrm);
  Application.CreateForm(TSetAxesFrm, SetAxesFrm);
  Application.CreateForm(TAmplifier, Amplifier);
  Application.CreateForm(TPrintRecFrm, PrintRecFrm);
  Application.CreateForm(TExportAnalogueFrm, ExportAnalogueFrm);
  Application.CreateForm(TLogFrm, LogFrm);
  Application.CreateForm(TLightSource, LightSource);
  Application.CreateForm(TExportImagesFrm, ExportImagesFrm);
  Application.CreateForm(TStimulator, Stimulator);
  Application.CreateForm(TExportEventsFrm, ExportEventsFrm);
  Application.CreateForm(TPlotSetAxesFrm, PlotSetAxesFrm);
  Application.CreateForm(TSaveAsFileFrm, SaveAsFileFrm);
  Application.CreateForm(TUltima, Ultima);
  Application.CreateForm(TSetLasersFrm, SetLasersFrm);
  Application.CreateForm(TEditROIFrm, EditROIFrm);
  Application.CreateForm(TPhotoStimulator, PhotoStimulator);
  Application.CreateForm(TExportROITimeCourseFrm, ExportROITimeCourseFrm);
  Application.CreateForm(TPlaybackStimulator, PlaybackStimulator);
  Application.CreateForm(TZStage, ZStage);
  Application.Run;
end.
