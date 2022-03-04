object SettingForm: TSettingForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 94
  ClientWidth = 223
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 5
    Width = 110
    Height = 16
    Caption = 'IP '#1072#1076#1088#1077#1089' '#1055#1088#1086#1082#1089#1080
  end
  object Label2: TLabel
    Left = 144
    Top = 5
    Width = 32
    Height = 16
    Caption = #1055#1086#1088#1090
  end
  object IPAdr: TIPAdress98
    Left = 8
    Top = 27
    Width = 121
    Height = 25
    ActiveField = 3
    MinIPAdress = '0.0.0.0'
    MaxIPAdress = '255.255.255.255'
    IPAdress = '127.0.0.1'
    ParentColor = False
    TabOrder = 0
    TabStop = True
  end
  object NumberBox1: TNumberBox
    Left = 144
    Top = 27
    Width = 73
    Height = 24
    MinValue = 80.000000000000000000
    MaxValue = 9999.000000000000000000
    MaxLength = 4
    TabOrder = 1
    Value = 80.000000000000000000
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 61
    Width = 97
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
  end
  object BitBtn2: TBitBtn
    Left = 120
    Top = 61
    Width = 97
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
  end
end
