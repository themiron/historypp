object fmPass: TfmPass
  Left = 359
  Top = 180
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'History++ Password Protection'
  ClientHeight = 329
  ClientWidth = 300
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TTntImage
    Left = 10
    Top = 10
    Width = 32
    Height = 29
    AutoSize = True
    Transparent = True
  end
  object laPassState: TTntLabel
    Left = 106
    Top = 254
    Width = 174
    Height = 25
    AutoSize = False
    Caption = '-'
    Layout = tlCenter
    WordWrap = True
  end
  object Bevel1: TTntBevel
    Left = 10
    Top = 291
    Width = 280
    Height = 2
  end
  object Label1: TTntLabel
    Left = 50
    Top = 10
    Width = 102
    Height = 13
    Caption = 'Password Options'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object rbProtAll: TTntRadioButton
    Left = 10
    Top = 53
    Width = 280
    Height = 17
    Caption = 'Protect all contacts'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbProtSelClick
  end
  object rbProtSel: TTntRadioButton
    Left = 10
    Top = 73
    Width = 280
    Height = 17
    Caption = 'Protect only selected contacts'
    TabOrder = 1
    TabStop = True
    OnClick = rbProtSelClick
  end
  object lvCList: TTntListView
    Left = 10
    Top = 93
    Width = 280
    Height = 150
    Checkboxes = True
    Columns = <
      item
        Width = 276
      end>
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    ShowColumnHeaders = False
    SortType = stText
    TabOrder = 2
    ViewStyle = vsReport
  end
  object bnPass: TTntButton
    Left = 10
    Top = 254
    Width = 89
    Height = 25
    Caption = 'Password...'
    TabOrder = 3
    OnClick = bnPassClick
  end
  object bnCancel: TTntButton
    Left = 215
    Top = 299
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = bnCancelClick
  end
  object bnOK: TTntButton
    Left = 135
    Top = 299
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 4
    OnClick = bnOKClick
  end
  object PopupMenu1: TTntPopupMenu
    Left = 186
    Top = 144
    object Refresh1: TMenuItem
      Caption = '&Refresh List'
      OnClick = Refresh1Click
    end
  end
end
