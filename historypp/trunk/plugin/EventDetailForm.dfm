object EventDetailsFrm: TEventDetailsFrm
  Left = 275
  Top = 178
  Width = 466
  Height = 396
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
  object Panel2: TTntPanel
    Left = 0
    Top = 335
    Width = 458
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 3
    object Panel3: TTntPanel
      Left = 258
      Top = 0
      Width = 200
      Height = 34
      Align = alRight
      BevelOuter = bvNone
      Caption = ' '
      TabOrder = 2
      object bnReply: TTntButton
        Left = 16
        Top = 4
        Width = 96
        Height = 25
        Caption = 'Reply &Quoted'
        TabOrder = 0
        OnClick = bnReplyClick
      end
      object CloseBtn: TTntButton
        Left = 118
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
      Left = 8
      Top = 4
      Width = 35
      Height = 25
      Caption = '<<'
      TabOrder = 0
      OnClick = PrevBtnClick
    end
    object NextBtn: TTntButton
      Left = 50
      Top = 4
      Width = 33
      Height = 25
      Caption = '>>'
      TabOrder = 1
      OnClick = NextBtnClick
    end
  end
  object Panel4: TTntPanel
    Left = 0
    Top = 141
    Width = 458
    Height = 194
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    Caption = ' '
    TabOrder = 2
    object EText: TTntRichEdit
      Left = 4
      Top = 4
      Width = 450
      Height = 186
      Align = alClient
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object Panel5: TTntPanel
    Left = 0
    Top = 69
    Width = 458
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 2
    Caption = ' '
    TabOrder = 1
    object Panel7: TTntPanel
      Left = 2
      Top = 2
      Width = 227
      Height = 68
      Align = alLeft
      BevelOuter = bvNone
      BorderWidth = 2
      TabOrder = 0
      object GroupBox2: TTntGroupBox
        Left = 2
        Top = 2
        Width = 223
        Height = 64
        Align = alClient
        Caption = 'From'
        TabOrder = 0
        DesignSize = (
          223
          64)
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
      Left = 229
      Top = 2
      Width = 227
      Height = 68
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 2
      TabOrder = 1
      object GroupBox3: TTntGroupBox
        Left = 2
        Top = 2
        Width = 223
        Height = 64
        Align = alClient
        Caption = 'To'
        TabOrder = 0
        DesignSize = (
          223
          64)
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
          Width = 163
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
          Width = 99
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object EToMore: TTntButton
          Left = 162
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
  object Panel6: TTntPanel
    Left = 0
    Top = 0
    Width = 458
    Height = 69
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 4
    Caption = ' '
    TabOrder = 0
    object GroupBox1: TTntGroupBox
      Left = 4
      Top = 4
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
end
