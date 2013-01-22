object SetLasersFrm: TSetLasersFrm
  Left = 590
  Top = 268
  Width = 262
  Height = 169
  Caption = 'Set Laser Intensity'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object LasersGrp: TGroupBox
    Left = 8
    Top = 8
    Width = 241
    Height = 97
    TabOrder = 0
    object Label31: TLabel
      Left = 9
      Top = 18
      Width = 43
      Height = 15
      Caption = 'Laser 1'
    end
    object Label1: TLabel
      Left = 9
      Top = 40
      Width = 43
      Height = 15
      Caption = 'Laser 2'
    end
    object Label2: TLabel
      Left = 9
      Top = 64
      Width = 43
      Height = 15
      Caption = 'Laser 3'
    end
    object edLaser1Intensity: TValidatedEdit
      Left = 184
      Top = 18
      Width = 49
      Height = 20
      Hint = 'Laser #1 emission wavelength (nm)'
      OnKeyPress = edLaser1IntensityKeyPress
      AutoSize = False
      ShowHint = True
      Text = ' 0 %'
      Scale = 1.000000000000000000
      Units = '%'
      NumberFormat = '%.4g'
      LoLimit = -1.000000015047466E30
      HiLimit = 100.000000000000000000
    end
    object edLaser2Intensity: TValidatedEdit
      Left = 184
      Top = 40
      Width = 49
      Height = 20
      Hint = 'Laser #1 emission wavelength (nm)'
      OnKeyPress = edLaser2IntensityKeyPress
      AutoSize = False
      ShowHint = True
      Text = ' 0 %'
      Scale = 1.000000000000000000
      Units = '%'
      NumberFormat = '%.4g'
      LoLimit = -1.000000015047466E30
      HiLimit = 100.000000000000000000
    end
    object edLaser3Intensity: TValidatedEdit
      Left = 184
      Top = 64
      Width = 49
      Height = 20
      Hint = 'Laser #1 emission wavelength (nm)'
      OnKeyPress = edLaser3IntensityKeyPress
      AutoSize = False
      ShowHint = True
      Text = ' 0 %'
      Scale = 1.000000000000000000
      Units = '%'
      NumberFormat = '%.4g'
      LoLimit = -1.000000015047466E30
      HiLimit = 100.000000000000000000
    end
    object sbLaser1: TScrollBar
      Left = 64
      Top = 18
      Width = 113
      Height = 17
      PageSize = 0
      TabOrder = 3
      OnChange = sbLaser1Change
    end
    object sbLaser2: TScrollBar
      Left = 64
      Top = 40
      Width = 113
      Height = 17
      PageSize = 0
      TabOrder = 4
      OnChange = sbLaser2Change
    end
    object sbLaser3: TScrollBar
      Left = 64
      Top = 64
      Width = 113
      Height = 17
      PageSize = 0
      TabOrder = 5
      OnChange = sbLaser3Change
    end
  end
  object bOK: TButton
    Left = 8
    Top = 112
    Width = 49
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 66
    Top = 112
    Width = 48
    Height = 17
    Caption = 'Cancel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = bCancelClick
  end
end
