object EventDetailsFrm: TEventDetailsFrm
  Left = 375
  Top = 149
  Width = 466
  Height = 396
  BorderWidth = 4
  Caption = 'Event Details'
  Color = clBtnFace
  Constraints.MinHeight = 340
  Constraints.MinWidth = 466
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
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object paBottom: TTntPanel
    Left = 0
    Top = 329
    Width = 450
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 2
    object Panel3: TTntPanel
      Left = 250
      Top = 0
      Width = 200
      Height = 32
      Align = alRight
      BevelOuter = bvNone
      Caption = ' '
      TabOrder = 2
      object bnReply: TTntButton
        Left = 24
        Top = 4
        Width = 96
        Height = 25
        Caption = 'Reply &Quoted'
        TabOrder = 0
        OnClick = bnReplyClick
      end
      object CloseBtn: TTntButton
        Left = 126
        Top = 4
        Width = 75
        Height = 25
        Cancel = True
        Caption = '&Close'
        TabOrder = 1
        OnClick = CloseBtnClick
      end
    end
    object PrevBtn: TTntButton
      Left = 0
      Top = 4
      Width = 35
      Height = 25
      Caption = '<<'
      TabOrder = 0
      OnClick = PrevBtnClick
    end
    object NextBtn: TTntButton
      Left = 42
      Top = 4
      Width = 33
      Height = 25
      Caption = '>>'
      TabOrder = 1
      OnClick = NextBtnClick
    end
  end
  object paUser: TTntPanel
    Left = 0
    Top = 61
    Width = 450
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    object Panel7: TTntPanel
      Left = 0
      Top = 0
      Width = 222
      Height = 60
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object GroupBox2: TTntGroupBox
        Left = 0
        Top = 0
        Width = 222
        Height = 60
        Align = alClient
        Caption = 'From'
        TabOrder = 0
        DesignSize = (
          222
          60)
        object Label3: TTntLabel
          Left = 8
          Top = 16
          Width = 25
          Height = 13
          Caption = 'Nick:'
        end
        object Label4: TTntLabel
          Left = 8
          Top = 36
          Width = 14
          Height = 13
          Caption = 'ID:'
        end
        object EFromUIN: TTntEdit
          Left = 56
          Top = 36
          Width = 99
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object EFromNick: TTntEdit
          Left = 56
          Top = 16
          Width = 163
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 2
        end
        object EFromMore: TTntButton
          Left = 162
          Top = 32
          Width = 51
          Height = 17
          Anchors = [akTop, akRight]
          Caption = 'More...'
          TabOrder = 1
          OnClick = EFromMoreClick
        end
      end
    end
    object Panel8: TTntPanel
      Left = 222
      Top = 0
      Width = 228
      Height = 60
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object GroupBox3: TTntGroupBox
        Left = 0
        Top = 0
        Width = 228
        Height = 60
        Align = alClient
        Caption = 'To'
        TabOrder = 0
        DesignSize = (
          228
          60)
        object Label5: TTntLabel
          Left = 8
          Top = 16
          Width = 25
          Height = 13
          Caption = 'Nick:'
        end
        object Label6: TTntLabel
          Left = 8
          Top = 36
          Width = 14
          Height = 13
          Caption = 'ID:'
        end
        object EToNick: TTntEdit
          Left = 56
          Top = 16
          Width = 168
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object EToUIN: TTntEdit
          Left = 56
          Top = 36
          Width = 104
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object EToMore: TTntButton
          Left = 167
          Top = 32
          Width = 51
          Height = 17
          Anchors = [akTop, akRight]
          Caption = 'More...'
          TabOrder = 2
          OnClick = EToMoreClick
        end
      end
    end
  end
  object paInfo: TTntPanel
    Left = 0
    Top = 0
    Width = 450
    Height = 61
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 0
    object GroupBox1: TTntGroupBox
      Left = 0
      Top = 0
      Width = 450
      Height = 61
      Align = alClient
      Caption = 'Event Info'
      TabOrder = 0
      DesignSize = (
        450
        61)
      object Label1: TTntLabel
        Left = 8
        Top = 16
        Width = 27
        Height = 13
        Caption = 'Type:'
      end
      object Label2: TTntLabel
        Left = 8
        Top = 36
        Width = 54
        Height = 13
        Caption = 'Date/Time:'
      end
      object EMsgType: TTntEdit
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
      object EDateTime: TTntEdit
        Left = 80
        Top = 36
        Width = 361
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 1
      end
    end
  end
  object paText: TTntPanel
    Left = 0
    Top = 121
    Width = 450
    Height = 6
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
  end
  object EText: TTntRichEdit
    Left = 0
    Top = 127
    Width = 450
    Height = 202
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    PopupMenu = pmEText
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object pmEText: TTntPopupMenu
    OnPopup = pmETextPopup
    Left = 68
    Top = 173
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
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = SelectAllClick
    end
    object N1: TTntMenuItem
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
