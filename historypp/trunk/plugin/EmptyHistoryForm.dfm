object EmptyHistoryFrm: TEmptyHistoryFrm
  Left = 346
  Top = 283
  BorderStyle = bsDialog
  BorderWidth = 8
  Caption = 'Empty History'
  ClientHeight = 79
  ClientWidth = 274
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    274
    79)
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Left = 0
    Top = 0
    Width = 32
    Height = 32
  end
  object Text: TTntLabel
    Left = 42
    Top = 0
    Width = 232
    Height = 32
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Layout = tlCenter
    WordWrap = True
  end
  object paButtons: THppPanel
    Left = 0
    Top = 54
    Width = 274
    Height = 25
    Align = alBottom
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 0
    object btYes: THppButton
      Left = 0
      Top = 0
      Width = 75
      Height = 25
      Caption = 'Yes'
      ModalResult = 6
      TabOrder = 0
      OnClick = btYesClick
    end
    object btNo: THppButton
      Left = 85
      Top = 0
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'No'
      ModalResult = 7
      TabOrder = 1
    end
    object btCancel: THppButton
      Left = 168
      Top = 0
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      Default = True
      ModalResult = 2
      TabOrder = 2
    end
  end
  object paContacts: THppPanel
    Left = 0
    Top = 31
    Width = 274
    Height = 23
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    object cbInclude: THppCheckBox
      Left = 0
      Top = 0
      Width = 274
      Height = 23
      Caption = 'Empty history of subcontacts also'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
  end
end
