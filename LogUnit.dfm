object LogFrm: TLogFrm
  Left = 367
  Top = 326
  Width = 696
  Height = 254
  Caption = 'Log'
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
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object meLog: TMemo
    Left = 8
    Top = 8
    Width = 673
    Height = 209
    ScrollBars = ssVertical
    TabOrder = 0
    OnKeyPress = meLogKeyPress
  end
end
