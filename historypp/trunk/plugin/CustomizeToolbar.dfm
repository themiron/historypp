object fmCustomizeToolbar: TfmCustomizeToolbar
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Customize Toolbar'
  ClientHeight = 338
  ClientWidth = 466
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
    466
    338)
  PixelsPerInch = 96
  TextHeight = 13
  object TntLabel1: TTntLabel
    Left = 8
    Top = 5
    Width = 83
    Height = 13
    Caption = 'Available buttons'
  end
  object TntLabel2: TTntLabel
    Left = 283
    Top = 5
    Width = 89
    Height = 13
    Caption = 'Buttons on toolbar'
  end
  object TntBevel1: TTntBevel
    Left = 8
    Top = 298
    Width = 449
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    ExplicitWidth = 463
  end
  object bnAdd: TTntButton
    Left = 189
    Top = 24
    Width = 88
    Height = 25
    Caption = '&Add >>'
    TabOrder = 1
    OnClick = bnAddClick
  end
  object bnRemove: TTntButton
    Left = 189
    Top = 49
    Width = 88
    Height = 25
    Caption = '<< Remove'
    TabOrder = 2
  end
  object lbAdded: TTntListBox
    Left = 283
    Top = 24
    Width = 175
    Height = 268
    Style = lbOwnerDrawFixed
    DragMode = dmAutomatic
    IntegralHeight = True
    ItemHeight = 24
    TabOrder = 5
    OnDragDrop = lbAddedDragDrop
    OnDragOver = lbAddedDragOver
    OnDrawItem = lbAvailableDrawItem
  end
  object lbAvailable: TTntListBox
    Left = 8
    Top = 24
    Width = 175
    Height = 268
    Style = lbOwnerDrawFixed
    DragMode = dmAutomatic
    IntegralHeight = True
    ItemHeight = 24
    TabOrder = 0
    OnDragDrop = lbAvailableDragDrop
    OnDragOver = lbAvailableDragOver
    OnDrawItem = lbAvailableDrawItem
  end
  object bnUp: TTntButton
    Left = 189
    Top = 80
    Width = 88
    Height = 25
    Caption = 'Up'
    TabOrder = 3
  end
  object bnDown: TTntButton
    Left = 189
    Top = 105
    Width = 88
    Height = 25
    Caption = 'Down'
    TabOrder = 4
  end
  object TntButton1: TTntButton
    Left = 8
    Top = 306
    Width = 77
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 6
  end
  object TntButton2: TTntButton
    Left = 91
    Top = 306
    Width = 77
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 7
  end
  object TntButton3: TTntButton
    Left = 328
    Top = 306
    Width = 130
    Height = 25
    Caption = 'Reset to Default'
    TabOrder = 8
    OnClick = TntButton3Click
  end
end
