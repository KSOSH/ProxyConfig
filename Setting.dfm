object SettingForm: TSettingForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1045#1057#1055#1044
  ClientHeight = 265
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Microsoft Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 5
    Width = 84
    Height = 13
    Caption = 'IP '#1072#1076#1088#1077#1089' '#1055#1088#1086#1082#1089#1080
  end
  object Label2: TLabel
    Left = 144
    Top = 8
    Width = 25
    Height = 13
    Caption = #1055#1086#1088#1090
  end
  object Label3: TLabel
    Left = 8
    Top = 58
    Width = 191
    Height = 26
    Caption = #1053#1077' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1088#1086#1082#1089#1080' '#1076#1083#1103' '#1076#1072#1085#1085#1099#1093' '#1072#1076#1088#1077#1089#1086#1074'. '#1056#1072#1079#1076#1077#1083#1080#1090#1077#1083#1100'  (;)'
    WordWrap = True
  end
  object IpAdress: TIPAdress98
    Left = 8
    Top = 27
    Width = 121
    Height = 25
    ActiveField = 3
    MinIPAdress = '0.0.0.0'
    MaxIPAdress = '255.255.255.255'
    IPAdress = '0.0.0.0'
    ParentColor = False
    TabOrder = 0
    TabStop = True
  end
  object Port: TNumberBox
    Left = 144
    Top = 27
    Width = 73
    Height = 21
    MinValue = 1.000000000000000000
    MaxValue = 9999.000000000000000000
    MaxLength = 4
    TabOrder = 1
    Value = 80.000000000000000000
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 233
    Width = 97
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
    OnClick = BitBtn1Click
  end
  object BitBtn2: TBitBtn
    Left = 120
    Top = 233
    Width = 97
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
  end
  object ProxyDisAddr: TMemo
    Left = 8
    Top = 90
    Width = 209
    Height = 97
    Lines.Strings = (
      'ProxyDisAddr')
    TabOrder = 4
  end
  object Ch1: TCheckBox
    Left = 8
    Top = 193
    Width = 209
    Height = 34
    Cursor = crHandPoint
    Caption = #1053#1077' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1076#1083#1103' '#1083#1086#1082#1072#1083#1100#1085#1099#1093' '#1072#1076#1088#1077#1089#1086#1074
    DragCursor = crDefault
    TabOrder = 5
    WordWrap = True
  end
  object XPManifest1: TXPManifest
    Left = 176
    Top = 8
  end
end
