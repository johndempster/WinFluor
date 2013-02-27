object PowerCalibrationFrm: TPowerCalibrationFrm
  Left = 528
  Top = 148
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
    Left = 180
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
    Left = 180
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
  object lbDriveChannel: TLabel
    Left = 90
    Top = 12
    Width = 81
    Height = 13
    Caption = 'Drive Channel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbPowerChannel: TLabel
    Left = 90
    Top = 42
    Width = 86
    Height = 13
    Caption = 'Power Channel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbAttenuator: TLabel
    Left = 10
    Top = 90
    Width = 92
    Height = 13
    Caption = 'Attenuator Type'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object PowerTable: TStringGrid
    Left = 10
    Top = 240
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
    Left = 10
    Top = 600
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
  object cbDriveChannel: TComboBox
    Left = 8
    Top = 10
    Width = 75
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    Text = 'cbDriveChannel'
    OnChange = cbDriveChannelChange
  end
  object cbPowerChannel: TComboBox
    Left = 8
    Top = 40
    Width = 75
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    Text = 'cbPowerChannel'
    OnChange = cbPowerChannelChange
  end
  object rbSinSqrd: TRadioButton
    Left = 10
    Top = 110
    Width = 113
    Height = 17
    Caption = 'Crossed (sin^2)'
    TabOrder = 4
  end
  object rbCosSqrd: TRadioButton
    Left = 10
    Top = 130
    Width = 113
    Height = 17
    Caption = 'Parallel (cos^2)'
    TabOrder = 5
  end
  object bFitData: TButton
    Left = 8
    Top = 180
    Width = 121
    Height = 25
    Caption = 'Fit Calibration Data'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = bFitDataClick
  end
end
