object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Proxy Configuration'
  ClientHeight = 88
  ClientWidth = 515
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 69
    Width = 515
    Height = 19
    Panels = <>
    ExplicitLeft = 240
    ExplicitTop = 48
    ExplicitWidth = 0
  end
  object GetWind: TTimer
    Interval = 500
    OnTimer = GetWindTimer
    Left = 488
  end
end
