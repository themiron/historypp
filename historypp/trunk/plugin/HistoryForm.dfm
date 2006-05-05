object HistoryFrm: THistoryFrm
  Left = 256
  Top = 189
  Width = 586
  Height = 418
  VertScrollBar.Tracking = True
  VertScrollBar.Visible = False
  ActiveControl = hg
  BiDiMode = bdLeftToRight
  Caption = '%s - History++'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseWheel = FormMouseWheel
  OnShow = TntFormShow
  PixelsPerInch = 96
  TextHeight = 13
  object paClient: TPanel
    Left = 0
    Top = 0
    Width = 578
    Height = 372
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object spSess: TTntSplitter
      Left = 158
      Top = 33
      Height = 312
      AutoSnap = False
      MinSize = 100
      Visible = False
    end
    object paGrid: TPanel
      Left = 161
      Top = 33
      Width = 415
      Height = 312
      Align = alClient
      BevelOuter = bvNone
      BorderStyle = bsSingle
      TabOrder = 0
      object hg: THistoryGrid
        Left = 0
        Top = 0
        Width = 411
        Height = 308
        VertScrollBar.Increment = 1
        VertScrollBar.PageSize = 20
        MultiSelect = True
        ShowHeaders = False
        TxtStartup = 'Starting up...'
        TxtNoItems = 'History is empty'
        TxtNoSuch = 'No such items'
        TxtFullLog = 'Full History Log'
        TxtPartLog = 'Partial History Log'
        TxtHistExport = 'History++ export'
        TxtGenHist1 = '### (generated by history++ plugin)'
        TxtGenHist2 = '<h6>Generated by <b>History++</b> Plugin</h6>'
        Filter = [mtUnknown, mtIncoming, mtOutgoing, mtMessage, mtUrl, mtFile, mtSystem, mtContacts, mtSMS, mtWebPager, mtEmailExpress, mtStatus, mtOther]
        OnDblClick = hgDblClick
        OnItemData = hgItemData
        OnPopup = hgPopup
        OnTranslateTime = hgTranslateTime
        OnSearchFinished = hgSearchFinished
        OnItemDelete = hgItemDelete
        OnKeyDown = hgKeyDown
        OnKeyUp = hgKeyUp
        OnChar = hgChar
        OnState = hgState
        OnSelect = hgSelect
        OnXMLData = hgXMLData
        OnUrlClick = hgUrlClick
        OnUrlPopup = hgUrlPopup
        OnItemFilter = hgItemFilter
        OnProcessRichText = hgProcessRichText
        OnSearchItem = hgSearchItem
        Reversed = False
        Align = alClient
        TabStop = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Shell Dlg'
        Font.Style = []
        Padding = 4
      end
    end
    object paSess: TPanel
      Left = 2
      Top = 33
      Width = 156
      Height = 312
      Align = alLeft
      BevelOuter = bvLowered
      TabOrder = 1
      Visible = False
      object Panel1: TPanel
        Left = 1
        Top = 1
        Width = 154
        Height = 21
        Align = alTop
        TabOrder = 0
        DesignSize = (
          154
          21)
        object laSess: TTntLabel
          Left = 6
          Top = 2
          Width = 126
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Conversations'
          Layout = tlCenter
        end
        object sbCloseSess: TTntSpeedButton
          Left = 133
          Top = 2
          Width = 18
          Height = 17
          AllowAllUp = True
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            BE000000424DBE0000000000000076000000280000000A000000090000000100
            04000000000048000000C40E0000C40E00001000000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777700
            0000700777700700000077007700770000007770000777000000777700777700
            0000777000077700000077007700770000007007777007000000777777777700
            0000}
          OnClick = sbCloseSessClick
        end
      end
      object tvSess: TTntTreeView
        Left = 1
        Top = 22
        Width = 154
        Height = 289
        Align = alClient
        BevelInner = bvNone
        BorderStyle = bsNone
        Images = ilSessions
        Indent = 19
        ParentShowHint = False
        ReadOnly = True
        ShowHint = True
        TabOrder = 1
        ToolTips = False
        OnChange = tvSessChange
        OnClick = tvSessClick
        OnMouseMove = tvSessMouseMove
      end
    end
    object paSearch: TTntPanel
      Left = 2
      Top = 345
      Width = 574
      Height = 25
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object paSearchPanel: TTntPanel
        Left = 0
        Top = 0
        Width = 495
        Height = 25
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          495
          25)
        object pbSearch: TPaintBox
          Left = 2
          Top = 6
          Width = 16
          Height = 16
          OnPaint = pbSearchPaint
        end
        object sbClearFilter: TTntSpeedButton
          Left = 21
          Top = 4
          Width = 23
          Height = 21
          Hint = 'Clear Search'
          Flat = True
          ParentShowHint = False
          ShowHint = True
          OnClick = sbClearFilterClick
        end
        object pbFilter: TPaintBox
          Left = 2
          Top = 6
          Width = 16
          Height = 16
          OnPaint = pbFilterPaint
        end
        object edSearch: TTntEdit
          Left = 47
          Top = 4
          Width = 447
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = edSearchChange
          OnKeyDown = edSearchKeyDown
          OnKeyUp = edSearchKeyUp
        end
      end
      object paSearchButtons: TTntPanel
        Left = 532
        Top = 0
        Width = 42
        Height = 25
        Align = alRight
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          42
          25)
        object sbSearchNext: TTntSpeedButton
          Left = 0
          Top = 4
          Width = 21
          Height = 21
          AllowAllUp = True
          Anchors = [akTop, akRight]
          Flat = True
          Layout = blGlyphTop
          ParentShowHint = False
          ShowHint = True
          Spacing = 0
          OnClick = sbSearchNextClick
        end
        object sbSearchPrev: TTntSpeedButton
          Left = 21
          Top = 4
          Width = 21
          Height = 21
          Anchors = [akTop, akRight]
          Flat = True
          Layout = blGlyphTop
          ParentShowHint = False
          ShowHint = True
          Spacing = 0
          OnClick = sbSearchPrevClick
        end
      end
      object paSearchStatus: TTntPanel
        Left = 495
        Top = 0
        Width = 37
        Height = 25
        Align = alRight
        BevelOuter = bvNone
        BorderWidth = 3
        TabOrder = 2
        Visible = False
        object laSearchState: TTntLabel
          Left = 22
          Top = 3
          Width = 12
          Height = 19
          Align = alRight
          Caption = '>>'
          Layout = tlCenter
        end
        object imSearchEndOfPage: TTntImage
          Left = 3
          Top = 6
          Width = 16
          Height = 16
        end
        object imSearchNotFound: TTntImage
          Left = 3
          Top = 6
          Width = 16
          Height = 16
        end
      end
    end
    object TopPanel: TPanel
      Left = 2
      Top = 2
      Width = 574
      Height = 31
      Align = alTop
      AutoSize = True
      BevelOuter = bvNone
      TabOrder = 3
      object laFilterText: TTntLabel
        Left = 273
        Top = 0
        Width = 301
        Height = 31
        Align = alClient
        Alignment = taRightJustify
        Caption = '>>'
        Layout = tlCenter
        OnDblClick = tbEventsFilterClick
      end
      object Toolbar: TTntToolBar
        Left = 0
        Top = 0
        Width = 299
        Height = 31
        Align = alLeft
        AutoSize = True
        BorderWidth = 2
        EdgeInner = esNone
        EdgeOuter = esNone
        Flat = True
        Images = ilToolbar
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Transparent = True
        Wrapable = False
        object tbSessions: TTntToolButton
          Left = 0
          Top = 0
          Hint = 'Show conversations (F4)'
          Style = tbsCheck
          OnClick = tbSessionsClick
        end
        object TntToolButton7: TTntToolButton
          Left = 23
          Top = 0
          Width = 7
          Style = tbsSeparator
        end
        object tbSearch: TTntToolButton
          Left = 30
          Top = 0
          Hint = 'Find'
          Grouped = True
          Style = tbsCheck
          OnClick = tbFilterClick
        end
        object tbFilter: TTntToolButton
          Left = 53
          Top = 0
          Hint = 'Filter'
          Grouped = True
          Style = tbsCheck
          OnClick = tbFilterClick
        end
        object TntToolButton3: TTntToolButton
          Left = 76
          Top = 0
          Width = 7
          Style = tbsSeparator
        end
        object tbCopy: TTntToolButton
          Left = 83
          Top = 0
          Hint = 'Copy'
        end
        object tbDelete: TTntToolButton
          Left = 106
          Top = 0
          Hint = 'Delete'
          OnClick = tbDeleteClick
        end
        object tbSave: TTntToolButton
          Left = 129
          Top = 0
          Hint = 'Save'
          Visible = False
        end
        object TntToolButton2: TTntToolButton
          Left = 152
          Top = 0
          Width = 7
          Style = tbsSeparator
        end
        object tbEventsFilter: TTntToolButton
          Left = 159
          Top = 0
          Hint = 'Event Filter'
          DropdownMenu = pmEventsFilter
          Marked = True
          Style = tbsDropDown
          OnClick = tbEventsFilterClick
        end
        object TntToolButton4: TTntToolButton
          Left = 195
          Top = 0
          Width = 7
          Style = tbsSeparator
        end
        object tbHistory: TTntToolButton
          Left = 202
          Top = 0
          Hint = 'History'
          DropdownMenu = pmHistory
          Style = tbsDropDown
          OnClick = tbHistoryClick
        end
        object tbHistorySearch: TTntToolButton
          Left = 238
          Top = 0
          Hint = 'History Search'
          OnClick = tbHistorySearchClick
        end
        object TntToolButton5: TTntToolButton
          Left = 261
          Top = 0
          Width = 7
          Style = tbsSeparator
        end
        object tbOptions: TTntToolButton
          Left = 268
          Top = 0
          Hint = 'Options'
          DropdownMenu = pmOptions
        end
      end
    end
  end
  object sb: TTntStatusBar
    Left = 0
    Top = 372
    Width = 578
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object paPassHolder: TTntPanel
    Left = 179
    Top = 95
    Width = 325
    Height = 153
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Enabled = False
    TabOrder = 2
    Visible = False
    OnResize = paPassHolderResize
    object paPassword: TPanel
      Left = 8
      Top = 16
      Width = 301
      Height = 117
      BevelOuter = bvNone
      TabOrder = 0
      object laPass: TTntLabel
        Left = 54
        Top = 7
        Width = 236
        Height = 46
        AutoSize = False
        Caption = 'You need password to access this history'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
      object Image1: TImage
        Left = 10
        Top = 8
        Width = 32
        Height = 29
        AutoSize = True
        Picture.Data = {
          07544269746D6170160B0000424D160B00000000000036000000280000002000
          00001D0000000100180000000000E00A0000C40E0000C40E0000000000000000
          0000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000000000003333C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0000000000000009999006699000000003333C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C000000000CCCC00333399FFFF0066990000000033
          33C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0996600FF0000000000000000000000
          00000000000000000000000000000000FFFF00CCCC00333399FFFF0066990000
          00003333C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0FF0000000000000000000000000000000000000000FF0000
          996600996600996600FF000000000000000000FFFF00CCCC00333399FFFF0066
          99000000003333C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0FF0000000000000000000000000000FF0000996600FF0000FF0000FF0000
          FF0000FF0000FF000000000000000000000000333300000000CCCC00333399FF
          FF006699000000003333003333003366003333003366006666C0C0C0C0C0C0C0
          C0C0000000000000000000FF0000996600FF0000FF0000FF0000000000000000
          000000FF000000000000000000000000000000000000333300FFFF00CCCC0033
          3399FFFF006699000000000000000000000000000000000000006666C0C0C0C0
          C0C0000000FF0000996600FF0000FF0000FF000000000000000066CCFF808080
          00000000000000000000000000000000000000000000808000669900000000FF
          FF00333366FFFF00669900FFFF00669900FFFF00FFFF339999000000006666C0
          C0C0C0C0C0000000FF0000FF0000000000000000C0C0C066CCFF90A9AD3399CC
          8080800000000000800000800000800066FF0000800000000000000000000000
          0000FFFF00669999FFFF00333300FFFF33CCCC33CCCC66FFFF33999900000000
          6666C0C0C000000000000000000066CCFFC0C0C066CCFF90A9AD3399CC808080
          0000000000800000803399CC8080800000800066FF000000C0C0C0C0C0C00000
          0000669999FFFF00336600FFFF33CCCC00336633CCCC33CCCC66FFFF00000000
          6666C0C0C0C0C0C0000000000000C0C0C066CCFFC0C0C03399CC8080803399CC
          0000008080803399CC90A9AD3399CC808080000000C0C0C0C0C0C0C0C0C00000
          0000FFFF00333300FFFF33CCCC00333366FFFF66FFFF00FFFF00FFFF00000000
          6666C0C0C0C0C0C0C0C0C0000000000000C0C0C066CCFF90A9AD000000000000
          0000000000000000003399CC808080000000C0C0C0C0C0C0C0C0C0C0C0C00000
          0000669999FFFF33CCCC00333300669900000000000000669900FFFF00000000
          6666C0C0C0C0C0C0C0C0C00000000000003399CCC0C0C03399CC8080803399CC
          80808066CCFF8080800000003399CC000000C0C0C0C0C0C0C0C0C0C0C0C00033
          3366FFFF33CCCC00336666FFFF000000008080C0C0C000000066FFFF00000000
          6666C0C0C0C0C0C00000000000000000000000003399CCC0C0C066CCFFC0C0C0
          66CCFFC0C0C066CCFF000000000000000000000000000000C0C0C0C0C0C00033
          3399FFFF33CCCC00FFFF00FFFF00000000808000000033CCCC00FFFF00333300
          6699C0C0C000000000000000000000000000000000000066CCFFC0C0C066CCFF
          90A9AD3399CC90A9AD0000003399CC90A9AD3399CC90A9AD000000C0C0C00066
          9933999999FFFF66FFFF66FFFF00808000000033CCCC00FFFF003333006699C0
          C0C0C0C0C000000000000000000000000000000066CCFF90A9AD66CCFF90A9AD
          66CCFFC0C0C066CCFF0000000000003399CC90A9AD66CCFF000000C0C0C0C0C0
          C000669933999999FFFF99FFFF99FFFF99FFFF99FFFF003333006699C0C0C0C0
          C0C000000000000000000000000000000066CCFFC0C0C066CCFF90A9AD66CCFF
          EAEAEA66CCFFC0C0C066CCFFC0C0C00000003399CC90A9AD000000C0C0C0C0C0
          C0C0C0C0006699006666006699006666006699006666006699C0C0C0C0C0C0C0
          C0C0000000000000000000000000000000C0C0C066CCFFC0C0C066CCFFEAEAEA
          66CCFFEAEAEA66CCFFC0C0C00000003399CC90A9AD3399CC000000000000C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0000000000000000000000000000000000000C0C0C03399CC90A9AD66CCFF
          C0C0C000000090A9AD66CCFF00000090A9AD66CCFFC0C0C03399CC90A9AD0000
          00C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C00000000000000000000000000000000000000000000000003399CC90A9AD
          66CCFF00000000000000000000000066CCFFC0C0C03399CC90A9AD000000C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C00000000000000000000000000000000000000000000000000000003399CC
          C0C0C066CCFFC0C0C000333300000090A9AD000000C0C0C03399CC000000C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0000000000000000000000000000000000000000000000000000000000000
          3399CCC0C0C066CCFFC0C0C00000003399CC000000000000000000003366C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0000000000000000000000000000000000000000000000000000000000000
          0000003399CC90A9AD66CCFF00000090A9AD3399CC90A9AD003333003366C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000003399CC90A9AD66CCFF90A9AD000000C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0000000000000000000000000000000000000000000000000000000
          0000000000000000000000000033330000003399CC90A9AD3399CC0000000000
          00C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0000000000000000000000000000000000000000000000000
          0000000000000033330033330000000000000000000000000000000000000000
          00C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000000000000000000000003333
          0033330033330000000000000000000000000000000000000000000000000000
          00C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0003333003333000000
          000000000000000000000000000000000000000000000000000000000000C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000
          000000000000000000000000000000000000000000000000C0C0C0C0C0C0C0C0
          C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
          C0C0}
        Transparent = True
      end
      object laPass2: TTntLabel
        Left = 10
        Top = 60
        Width = 49
        Height = 13
        Caption = 'Password:'
      end
      object edPass: TPasswordEdit
        Left = 80
        Top = 56
        Width = 211
        Height = 21
        MaxLength = 100
        TabOrder = 0
        OnKeyPress = edPassKeyPress
        OnKeyUp = edPassKeyUp
      end
      object bnPass: TTntButton
        Left = 208
        Top = 82
        Width = 83
        Height = 25
        Caption = 'Enter'
        Default = True
        TabOrder = 1
        OnClick = bnPassClick
      end
    end
  end
  object SaveDialog: TSaveDialog
    FilterIndex = 0
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofShareAware, ofEnableSizing]
    Title = 'Save History'
    Left = 28
    Top = 108
  end
  object pmGrid: TTntPopupMenu
    OnPopup = pmPopup
    Left = 184
    Top = 257
    object Details1: TTntMenuItem
      Caption = '&Open'
      ShortCut = 16397
      OnClick = Details1Click
    end
    object N8: TTntMenuItem
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
    object UserDetails1: TTntMenuItem
      Caption = 'User &Details'
      ShortCut = 16457
      OnClick = UserDetails1Click
    end
    object N12: TTntMenuItem
      Caption = '-'
    end
    object Copy1: TTntMenuItem
      Caption = '&Copy'
      ShortCut = 16451
      OnClick = Copy1Click
    end
    object CopyText1: TTntMenuItem
      Caption = 'Copy &Text'
      ShortCut = 16468
      OnClick = CopyText1Click
    end
    object Delete1: TTntMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = Delete1Click
    end
    object N2: TTntMenuItem
      Caption = '-'
    end
    object SaveSelected1: TTntMenuItem
      Caption = '&Save Selected...'
      OnClick = SaveSelected1Click
    end
    object N13: TTntMenuItem
      Caption = '-'
    end
  end
  object pmLink: TTntPopupMenu
    Left = 288
    Top = 262
    object Open1: TTntMenuItem
      Caption = 'Open &Link'
      Default = True
      OnClick = OpenLink1Click
    end
    object OpeninNewWindow1: TTntMenuItem
      Caption = 'Open Link in New &Window'
      OnClick = OpenLinkInNewWindow1Click
    end
    object N1: TTntMenuItem
      Caption = '-'
    end
    object Copy2: TTntMenuItem
      Caption = '&Copy'
      OnClick = CopyLink1Click
    end
  end
  object pmFile: TTntPopupMenu
    Left = 318
    Top = 259
    object OpenFile2: TTntMenuItem
      Caption = 'Open &File'
      OnClick = OpenFile1Click
    end
    object OpenFileFolder2: TTntMenuItem
      Caption = 'Open File Fo&lder'
      OnClick = OpenFileFolder1Click
    end
    object N5: TTntMenuItem
      Caption = '-'
    end
    object CopyFile1: TTntMenuItem
      Caption = '&Copy'
    end
  end
  object pmOptions: TTntPopupMenu
    OnPopup = pmPopup
    Left = 260
    Top = 39
    object IconsEnabled1: TTntMenuItem
      Caption = 'Show event icons'
      Checked = True
      OnClick = IconsEnabled1Click
    end
    object N3: TTntMenuItem
      Caption = '-'
    end
    object SmileysEnabled1: TTntMenuItem
      Caption = 'Enable smiley support'
      Checked = True
      OnClick = SmileysEnabled1Click
    end
    object BBCodesEnabled1: TTntMenuItem
      Caption = 'Enable BBCodes support'
      Checked = True
      OnClick = BBCodesEnabled1Click
    end
    object MathModuleEnabled1: TTntMenuItem
      Caption = 'Enable MathModule support'
      Enabled = False
      OnClick = MathModuleEnabled1Click
    end
    object N16: TTntMenuItem
      Caption = '-'
    end
    object RTLEnabled1: TTntMenuItem
      Caption = 'Use RTL by default'
      OnClick = RTLEnabled1Click
    end
    object ContactRTLmode1: TTntMenuItem
      Caption = 'Text direction'
      object RTLDefault2: TTntMenuItem
        AutoCheck = True
        Caption = 'Default'
        Checked = True
        RadioItem = True
        OnClick = ContactRTLmode1Click
      end
      object RTLEnabled2: TTntMenuItem
        AutoCheck = True
        Caption = 'Always RTL'
        RadioItem = True
        OnClick = ContactRTLmode1Click
      end
      object RTLDisabled2: TTntMenuItem
        AutoCheck = True
        Caption = 'Always LTR'
        RadioItem = True
        OnClick = ContactRTLmode1Click
      end
    end
    object ANSICodepage1: TTntMenuItem
      Caption = 'ANSI Encoding'
      object SystemCodepage1: TTntMenuItem
        AutoCheck = True
        Caption = 'System default codepage'
        Checked = True
        RadioItem = True
        OnClick = CodepageChangeClick
      end
    end
    object N14: TTntMenuItem
      Caption = '-'
    end
    object RecentOnTop1: TTntMenuItem
      Caption = 'Recent events on top'
      OnClick = RecentOnTop1Click
    end
    object N15: TTntMenuItem
      Caption = '-'
    end
  end
  object pmGridInline: TTntPopupMenu
    OnPopup = pmGridInlinePopup
    Left = 184
    Top = 291
    object CopyInline: TTntMenuItem
      Caption = '&Copy'
      ShortCut = 16451
      OnClick = CopyInlineClick
    end
    object CopyAllInline: TTntMenuItem
      Caption = 'Copy All'
      OnClick = CopyAllInlineClick
    end
    object SelectAllInline: TTntMenuItem
      Caption = 'Select &All'
      ShortCut = 16449
      OnClick = SelectAllInlineClick
    end
    object N10: TTntMenuItem
      Caption = '-'
    end
    object CancelInline1: TTntMenuItem
      Caption = 'Cancel'
      OnClick = CancelInline1Click
    end
  end
  object ilSessions: TImageList
    ShareImages = True
    Left = 28
    Top = 68
  end
  object tiFilter: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tiFilterTimer
    Left = 468
    Top = 260
  end
  object ilToolbar: TImageList
    DrawingStyle = dsFocus
    ShareImages = True
    Left = 504
    Top = 4
  end
  object pmHistory: TTntPopupMenu
    Left = 216
    Top = 40
    object SaveasHTML2: TTntMenuItem
      Caption = 'Export as &HTML...'
      OnClick = SaveasHTML2Click
    end
    object SaveasXML2: TTntMenuItem
      Caption = 'Export as &XML...'
      OnClick = SaveasXML2Click
    end
    object SaveasRTF2: TTntMenuItem
      Caption = 'Export as &RTF...'
      Enabled = False
      OnClick = SaveasRTF2Click
    end
    object SaveasText2: TTntMenuItem
      Caption = 'Export as &Text...'
      OnClick = SaveasText2Click
    end
    object N4: TTntMenuItem
      Caption = '-'
    end
    object Emptyhistory1: TTntMenuItem
      Caption = 'Empty history...'
      OnClick = Emptyhistory1Click
    end
    object N6: TTntMenuItem
      Caption = '-'
    end
    object Passwordprotection1: TTntMenuItem
      Caption = 'Password protection...'
      OnClick = Passwordprotection1Click
    end
  end
  object pmEventsFilter: TTntPopupMenu
    Left = 172
    Top = 40
    object Showall1: TTntMenuItem
      Caption = '-'
    end
    object Customize1: TTntMenuItem
      Caption = 'Customize'
      Enabled = False
    end
  end
end
