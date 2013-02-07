object PowerCalibrationFrm: TPowerCalibrationFrm
  Left = 574
  Top = 183
  Width = 666
  Height = 765
  Caption = 'Power Calibration'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object plPlot: TXMultiYPlot
    Left = 10
    Top = 10
    Width = 450
    Height = 340
    PlotNum = 0
    MaxPointsPerLine = 4096
    XAxisMax = 1.000000000000000000
    XAxisTick = 0.200000002980232200
    XAxisLaw = axLinear
    XAxisLabel = 'X Axis'
    XAxisAutoRange = False
    YAxisMax = 1.000000000000000000
    YAxisTick = 0.200000002980232200
    YAxisLaw = axLinear
    YAxisLabel = 'Y Axis'
    YAxisAutoRange = False
    YAxisLabelAtTop = False
    ScreenFontName = 'Arial'
    ScreenFontSize = 10
    LineWidth = 1
    MarkerSize = 10
    ShowLines = True
    ShowMarkers = True
    HistogramFullBorders = False
    HistogramFillColor = clWhite
    HistogramFillStyle = bsClear
    HistogramCumulative = False
    HistogramPercentage = False
    PrinterFontSize = 10
    PrinterFontName = 'Arial'
    PrinterLineWidth = 1
    PrinterMarkerSize = 5
    PrinterLeftMargin = 0
    PrinterRightMargin = 0
    PrinterTopMargin = 0
    PrinterBottomMargin = 0
    PrinterDisableColor = False
    MetafileWidth = 500
    MetafileHeight = 400
  end
  object plFittedPlot: TXMultiYPlot
    Left = 10
    Top = 370
    Width = 450
    Height = 340
    PlotNum = 0
    MaxPointsPerLine = 4096
    XAxisMax = 1.000000000000000000
    XAxisTick = 0.200000002980232200
    XAxisLaw = axLinear
    XAxisLabel = 'X Axis'
    XAxisAutoRange = False
    YAxisMax = 1.000000000000000000
    YAxisTick = 0.200000002980232200
    YAxisLaw = axLinear
    YAxisLabel = 'Y Axis'
    YAxisAutoRange = False
    YAxisLabelAtTop = False
    ScreenFontName = 'Arial'
    ScreenFontSize = 10
    LineWidth = 1
    MarkerSize = 10
    ShowLines = True
    ShowMarkers = True
    HistogramFullBorders = False
    HistogramFillColor = clWhite
    HistogramFillStyle = bsClear
    HistogramCumulative = False
    HistogramPercentage = False
    PrinterFontSize = 10
    PrinterFontName = 'Arial'
    PrinterLineWidth = 1
    PrinterMarkerSize = 5
    PrinterLeftMargin = 0
    PrinterRightMargin = 0
    PrinterTopMargin = 0
    PrinterBottomMargin = 0
    PrinterDisableColor = False
    MetafileWidth = 500
    MetafileHeight = 400
  end
  object PowerTable: TStringGrid
    Left = 472
    Top = 10
    Width = 145
    Height = 340
    ColCount = 2
    DefaultColWidth = 60
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 21
    TabOrder = 0
  end
  object ParameterBox: TGroupBox
    Left = 472
    Top = 368
    Width = 161
    Height = 110
    Caption = 'Fitted Parameters'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object VpiLabel: TLabel
      Left = 10
      Top = 25
      Width = 50
      Height = 13
      Caption = 'V_pi (V):'
    end
    object NetBiasLabel: TLabel
      Left = 10
      Top = 45
      Width = 72
      Height = 13
      Caption = 'Net bias (V):'
    end
    object PMaxLabel: TLabel
      Left = 10
      Top = 65
      Width = 75
      Height = 13
      Caption = 'P_max (mW):'
    end
    object PMinLabel: TLabel
      Left = 10
      Top = 85
      Width = 72
      Height = 13
      Caption = 'P_min (mW):'
    end
    object VpiValueLabel: TLabel
      Left = 125
      Top = 25
      Width = 5
      Height = 13
      Alignment = taRightJustify
    end
    object NetBiasValueLabel: TLabel
      Left = 125
      Top = 45
      Width = 5
      Height = 13
      Alignment = taRightJustify
    end
    object PMaxValueLabel: TLabel
      Left = 125
      Top = 65
      Width = 5
      Height = 13
      Alignment = taRightJustify
    end
    object PMinValueLabel: TLabel
      Left = 125
      Top = 85
      Width = 5
      Height = 13
      Alignment = taRightJustify
    end
  end
end
