object fmCustomizeFilters: TfmCustomizeFilters
  Left = 227
  Top = 70
  BorderStyle = bsDialog
  Caption = 'Customize Filters'
  ClientHeight = 477
  ClientWidth = 370
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
  OnKeyDown = TntFormKeyDown
  DesignSize = (
    370
    477)
  PixelsPerInch = 96
  TextHeight = 13
  object bnOK: TTntButton
    Left = 8
    Top = 444
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = bnOKClick
  end
  object bnCancel: TTntButton
    Left = 89
    Top = 444
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = '&Cancel'
    TabOrder = 3
    OnClick = bnCancelClick
  end
  object gbFilter: TTntGroupBox
    Left = 8
    Top = 152
    Width = 354
    Height = 281
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Filter Properties'
    TabOrder = 1
    DesignSize = (
      354
      281)
    object laFilterName: TTntLabel
      Left = 12
      Top = 23
      Width = 31
      Height = 13
      Caption = '&Name:'
      FocusControl = edFilterName
    end
    object edFilterName: THppEdit
      Left = 60
      Top = 20
      Width = 284
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      MaxLength = 63
      TabOrder = 0
      OnChange = edFilterNameChange
    end
    object clEvents: TTntCheckListBox
      Left = 12
      Top = 92
      Width = 332
      Height = 153
      OnClickCheck = clEventsClickCheck
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      Style = lbOwnerDrawFixed
      TabOrder = 3
      OnDrawItem = clEventsDrawItem
    end
    object rbExclude: TTntRadioButton
      Left = 12
      Top = 69
      Width = 332
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Show all except selected events'
      TabOrder = 2
      OnClick = rbPropertyClick
    end
    object rbInclude: TTntRadioButton
      Left = 12
      Top = 50
      Width = 332
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Show only selected events'
      TabOrder = 1
      OnClick = rbPropertyClick
    end
    object edCustomEvent: THppEdit
      Left = 259
      Top = 250
      Width = 85
      Height = 21
      Anchors = [akRight, akBottom]
      MaxLength = 63
      TabOrder = 4
      OnChange = edCustomEventChange
    end
    object cbCustomEvent: TTntCheckBox
      Left = 12
      Top = 250
      Width = 241
      Height = 21
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Include custom event type (0-65535)'
      TabOrder = 5
      OnClick = cbCustomEventClick
    end
  end
  object bnReset: TTntButton
    Left = 231
    Top = 444
    Width = 131
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'R&eset to Default'
    TabOrder = 4
    OnClick = bnResetClick
  end
  object gbFilters: TTntGroupBox
    Left = 8
    Top = 8
    Width = 354
    Height = 137
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Filters'
    TabOrder = 0
    DesignSize = (
      354
      137)
    object lbFilters: TTntListBox
      Left = 12
      Top = 20
      Width = 241
      Height = 105
      Style = lbOwnerDrawFixed
      Anchors = [akLeft, akTop, akRight, akBottom]
      DragMode = dmAutomatic
      ItemHeight = 13
      TabOrder = 0
      OnClick = lbFiltersClick
      OnDragDrop = lbFiltersDragDrop
      OnDragOver = lbFiltersDragOver
      OnDrawItem = lbFiltersDrawItem
    end
    object bnDown: TTntButton
      Left = 259
      Top = 102
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = '&Down'
      TabOrder = 4
      OnClick = bnDownClick
    end
    object bnUp: TTntButton
      Left = 259
      Top = 74
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = '&Up'
      TabOrder = 3
      OnClick = bnUpClick
    end
    object bnDelete: TTntButton
      Left = 259
      Top = 47
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = '&Delete'
      TabOrder = 2
      OnClick = bnDeleteClick
    end
    object bnAdd: TTntButton
      Left = 259
      Top = 20
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = '&Add'
      TabOrder = 1
      OnClick = bnAddClick
    end
  end
end
