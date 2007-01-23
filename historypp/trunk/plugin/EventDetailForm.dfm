object EventDetailsFrm: TEventDetailsFrm
  Left = 269
  Top = 168
  Width = 466
  Height = 389
  BorderWidth = 4
  Caption = 'Event Details'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object paBottom: THppPanel
    Left = 0
    Top = 322
    Width = 450
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    object PrevBtn: TTntSpeedButton
      Left = 0
      Top = 4
      Width = 77
      Height = 25
      Caption = 'Prev'
      OnClick = PrevBtnClick
    end
    object NextBtn: TTntSpeedButton
      Left = 82
      Top = 4
      Width = 77
      Height = 25
      Caption = 'Next'
      OnClick = NextBtnClick
    end
    object Panel3: THppPanel
      Left = 250
      Top = 0
      Width = 200
      Height = 32
      Align = alRight
      BevelOuter = bvNone
      Caption = ' '
      TabOrder = 0
      object bnReply: TTntButton
        Left = 4
        Top = 4
        Width = 116
        Height = 25
        Caption = 'Reply &Quoted'
        TabOrder = 0
        OnClick = bnReplyClick
      end
      object CloseBtn: TTntButton
        Left = 125
        Top = 4
        Width = 75
        Height = 25
        Cancel = True
        Caption = '&Close'
        Default = True
        TabOrder = 1
        OnClick = CloseBtnClick
      end
    end
  end
  object paInfo: THppPanel
    Left = 0
    Top = 0
    Width = 450
    Height = 101
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 2
    object GroupBox: TTntGroupBox
      Left = 0
      Top = 0
      Width = 450
      Height = 101
      Align = alClient
      Caption = 'Event Info'
      ParentBackground = False
      TabOrder = 0
      DesignSize = (
        450
        101)
      object laType: TTntLabel
        Left = 8
        Top = 16
        Width = 27
        Height = 13
        Caption = 'Type:'
        Transparent = True
      end
      object laDateTime: TTntLabel
        Left = 8
        Top = 36
        Width = 54
        Height = 13
        Caption = 'Date/Time:'
        Transparent = True
      end
      object laFrom: TTntLabel
        Left = 8
        Top = 56
        Width = 26
        Height = 13
        Caption = 'From:'
        Transparent = True
      end
      object laTo: TTntLabel
        Left = 8
        Top = 76
        Width = 16
        Height = 13
        Caption = 'To:'
        Transparent = True
      end
      object EFromMore: TTntSpeedButton
        Left = 424
        Top = 56
        Width = 20
        Height = 20
        Hint = 'Show sender information'
        Anchors = [akTop, akRight]
        Flat = True
        Layout = blGlyphTop
        ParentShowHint = False
        ShowHint = True
        OnClick = EFromMoreClick
      end
      object EToMore: TTntSpeedButton
        Left = 424
        Top = 76
        Width = 20
        Height = 20
        Hint = 'Show receiver information'
        Anchors = [akTop, akRight]
        Flat = True
        Layout = blGlyphTop
        ParentShowHint = False
        ShowHint = True
        OnClick = EToMoreClick
      end
      object EMsgType: THppEdit
        Left = 80
        Top = 16
        Width = 361
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 0
      end
      object EFrom: THppEdit
        Left = 80
        Top = 56
        Width = 341
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 1
      end
      object ETo: THppEdit
        Left = 80
        Top = 76
        Width = 341
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 2
      end
      object EDateTime: THppEdit
        Left = 80
        Top = 36
        Width = 341
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 3
      end
    end
  end
  object paText: THppPanel
    Left = 0
    Top = 101
    Width = 450
    Height = 6
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
  end
  object EText: THPPRichEdit
    Left = 0
    Top = 107
    Width = 450
    Height = 215
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    PopupMenu = pmEText
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    OnMouseMove = ETextMouseMove
    OnResizeRequest = ETextResizeRequest
  end
  object pmEText: TTntPopupMenu
    OnPopup = pmETextPopup
    Left = 68
    Top = 173
    object OpenLinkNW: TTntMenuItem
      Caption = 'Open in &new window'
      Default = True
      OnClick = OpenLinkNWClick
    end
    object OpenLink: TTntMenuItem
      Caption = '&Open in existing window'
      OnClick = OpenLinkClick
    end
    object CopyLink: TTntMenuItem
      Caption = '&Copy Link'
      OnClick = CopyLinkClick
    end
    object N4: TTntMenuItem
      Caption = '-'
    end
    object CopyText: TTntMenuItem
      Caption = '&Copy'
      ShortCut = 16451
      OnClick = CopyTextClick
    end
    object CopyAll: TTntMenuItem
      Caption = 'Copy All'
      OnClick = CopyAllClick
    end
    object SelectAll: TTntMenuItem
      Caption = 'Select &All'
      ShortCut = 16449
      OnClick = SelectAllClick
    end
    object N1: TTntMenuItem
      Caption = '-'
    end
    object ToogleItemProcessing: TTntMenuItem
      Caption = 'Text Formatting'
      ShortCut = 16464
      OnClick = ToogleItemProcessingClick
    end
    object N2: TTntMenuItem
      Caption = '-'
    end
    object SendMessage1: TTntMenuItem
      Caption = 'Send &Message'
      ShortCut = 16461
      OnClick = SendMessage1Click
    end
    object ReplyQuoted1: TTntMenuItem
      Caption = '&Reply Quoted'
      ShortCut = 16466
      OnClick = ReplyQuoted1Click
    end
  end
end
