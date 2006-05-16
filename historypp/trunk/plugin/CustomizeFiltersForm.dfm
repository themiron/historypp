object fmCustomizeFilters: TfmCustomizeFilters
  Left = 0
  Top = 0
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
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = TntFormClose
  OnCreate = FormCreate
  OnDestroy = TntFormDestroy
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
    ExplicitTop = 417
  end
  object bnCancel: TTntButton
    Left = 89
    Top = 444
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = bnCancelClick
    ExplicitTop = 417
  end
  object gbFilter: TTntGroupBox
    Left = 8
    Top = 167
    Width = 354
    Height = 265
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Filter Properties'
    TabOrder = 1
    ExplicitHeight = 260
    DesignSize = (
      354
      265)
    object laFilterName: TTntLabel
      Left = 12
      Top = 23
      Width = 31
      Height = 13
      Caption = 'Name:'
    end
    object edFilterName: TTntEdit
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
      Height = 164
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 3
      ExplicitHeight = 148
    end
    object rbExclude: TTntRadioButton
      Left = 12
      Top = 69
      Width = 332
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Show all except selected events'
      TabOrder = 2
    end
    object rbInclude: TTntRadioButton
      Left = 12
      Top = 50
      Width = 332
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Show only selected events'
      TabOrder = 1
    end
  end
  object bnReset: TTntButton
    Left = 231
    Top = 444
    Width = 131
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Reset to Default'
    Enabled = False
    TabOrder = 4
    ExplicitTop = 417
  end
  object gbFilters: TTntGroupBox
    Left = 8
    Top = 8
    Width = 354
    Height = 153
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Filters'
    TabOrder = 0
    DesignSize = (
      354
      153)
    object lbFilters: TTntListBox
      Left = 12
      Top = 18
      Width = 241
      Height = 123
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
      OnClick = lbFiltersClick
      ExplicitHeight = 107
    end
    object bnDown: TTntButton
      Left = 259
      Top = 41
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Down'
      TabOrder = 2
      OnClick = bnDownClick
    end
    object bnUp: TTntButton
      Left = 259
      Top = 18
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Up'
      TabOrder = 1
      OnClick = bnUpClick
    end
    object bnDelete: TTntButton
      Left = 259
      Top = 93
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Delete'
      TabOrder = 4
      OnClick = bnDeleteClick
    end
    object bnAdd: TTntButton
      Left = 259
      Top = 70
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Add'
      TabOrder = 3
      OnClick = bnAddClick
    end
  end
end
