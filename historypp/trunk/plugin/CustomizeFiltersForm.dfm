object fmCustomizeFilters: TfmCustomizeFilters
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Customize Filters'
  ClientHeight = 450
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
    450)
  PixelsPerInch = 96
  TextHeight = 13
  object bnOK: TTntButton
    Left = 8
    Top = 417
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
    Top = 417
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object gbFilter: TTntGroupBox
    Left = 8
    Top = 156
    Width = 354
    Height = 249
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Filter Properties'
    TabOrder = 1
    DesignSize = (
      354
      249)
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
    end
    object clEvents: TTntCheckListBox
      Left = 12
      Top = 92
      Width = 332
      Height = 148
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 3
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
    Top = 417
    Width = 131
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Reset to Default'
    Enabled = False
    ModalResult = 8
    TabOrder = 4
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
      Top = 18
      Width = 241
      Height = 107
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
      OnClick = lbFiltersClick
    end
    object bnDown: TTntButton
      Left = 259
      Top = 41
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Down'
      TabOrder = 2
    end
    object bnUp: TTntButton
      Left = 259
      Top = 18
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Up'
      TabOrder = 1
    end
    object bnDelete: TTntButton
      Left = 259
      Top = 93
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Delete'
      TabOrder = 4
    end
    object bnAdd: TTntButton
      Left = 259
      Top = 70
      Width = 85
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Add'
      TabOrder = 3
    end
  end
end
