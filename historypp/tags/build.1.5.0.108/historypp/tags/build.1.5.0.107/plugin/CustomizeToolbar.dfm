object fmCustomizeToolbar: TfmCustomizeToolbar
  Left = 264
  Top = 202
  BorderStyle = bsDialog
  Caption = 'Customize Toolbar'
  ClientHeight = 363
  ClientWidth = 518
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    518
    363)
  PixelsPerInch = 96
  TextHeight = 13
  object laAvailable: TTntLabel
    Left = 8
    Top = 5
    Width = 87
    Height = 13
    Caption = 'A&vailable buttons:'
    FocusControl = lbAvailable
  end
  object laAdded: TTntLabel
    Left = 310
    Top = 5
    Width = 93
    Height = 13
    Caption = 'Buttons on &toolbar:'
    FocusControl = lbAdded
  end
  object TntBevel1: TTntBevel
    Left = 8
    Top = 323
    Width = 501
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object bnAdd: TTntButton
    Left = 215
    Top = 24
    Width = 88
    Height = 25
    Caption = '&Add >>'
    TabOrder = 1
    OnClick = bnAddClick
  end
  object bnRemove: TTntButton
    Left = 215
    Top = 49
    Width = 88
    Height = 25
    Caption = '<< &Remove'
    TabOrder = 2
    OnClick = bnRemoveClick
  end
  object lbAdded: TTntListBox
    Left = 310
    Top = 24
    Width = 200
    Height = 292
    Style = lbOwnerDrawFixed
    DragMode = dmAutomatic
    IntegralHeight = True
    ItemHeight = 24
    TabOrder = 5
    OnClick = lbAvailableClick
    OnDragDrop = lbAddedDragDrop
    OnDragOver = lbAddedDragOver
    OnDrawItem = lbAvailableDrawItem
  end
  object lbAvailable: TTntListBox
    Left = 8
    Top = 24
    Width = 200
    Height = 292
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akBottom]
    DragMode = dmAutomatic
    IntegralHeight = True
    ItemHeight = 24
    TabOrder = 0
    OnClick = lbAvailableClick
    OnDragDrop = lbAvailableDragDrop
    OnDragOver = lbAvailableDragOver
    OnDrawItem = lbAvailableDrawItem
  end
  object bnUp: TTntButton
    Left = 215
    Top = 80
    Width = 88
    Height = 25
    Caption = '&Up'
    TabOrder = 3
    OnClick = bnUpClick
  end
  object bnDown: TTntButton
    Left = 215
    Top = 105
    Width = 88
    Height = 25
    Caption = '&Down'
    TabOrder = 4
    OnClick = bnDownClick
  end
  object bnOK: TTntButton
    Left = 8
    Top = 331
    Width = 77
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 6
    OnClick = bnOKClick
  end
  object bnCancel: TTntButton
    Left = 91
    Top = 330
    Width = 77
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = '&Cancel'
    TabOrder = 7
    OnClick = bnCancelClick
  end
  object bnReset: TTntButton
    Left = 380
    Top = 331
    Width = 130
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'R&eset to Default'
    TabOrder = 8
    OnClick = bnResetClick
  end
  object tiScroll: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tiScrollTimer
    Left = 376
    Top = 212
  end
end
