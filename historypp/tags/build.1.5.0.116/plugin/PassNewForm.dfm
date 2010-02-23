object fmPassNew: TfmPassNew
  Left = 460
  Top = 222
  ActiveControl = edPass
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'New Password'
  ClientHeight = 203
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TTntLabel
    Left = 52
    Top = 10
    Width = 243
    Height = 31
    AutoSize = False
    Caption = 'Enter new password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TTntLabel
    Left = 10
    Top = 88
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  object Label3: TTntLabel
    Left = 10
    Top = 113
    Width = 38
    Height = 13
    Caption = 'Confirm:'
  end
  object Label4: TTntLabel
    Left = 10
    Top = 139
    Width = 297
    Height = 18
    AutoSize = False
    Caption = 'Leave this fields blank to disable password'
    WordWrap = True
  end
  object Image1: TTntImage
    Left = 10
    Top = 10
    Width = 32
    Height = 29
    AutoSize = True
    Transparent = True
  end
  object Label5: TTntLabel
    Left = 10
    Top = 50
    Width = 295
    Height = 27
    AutoSize = False
    Caption = 'Pay attention to CAPS LOCK button state'
    WordWrap = True
  end
  object Bevel1: TTntBevel
    Left = 10
    Top = 162
    Width = 300
    Height = 2
  end
  object edPass: TPasswordEdit
    Left = 72
    Top = 84
    Width = 234
    Height = 21
    MaxLength = 100
    TabOrder = 0
  end
  object edConf: TPasswordEdit
    Left = 72
    Top = 109
    Width = 234
    Height = 21
    MaxLength = 100
    TabOrder = 1
  end
  object bnCancel: TTntButton
    Left = 235
    Top = 171
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = bnCancelClick
  end
  object bnOK: TTntButton
    Left = 156
    Top = 171
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = bnOKClick
  end
end
