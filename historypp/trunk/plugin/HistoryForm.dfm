object HistoryFrm: THistoryFrm
  Left = 245
  Top = 167
  Width = 586
  Height = 424
  VertScrollBar.Tracking = True
  VertScrollBar.Visible = False
  ActiveControl = hg
  Caption = '%s - History++'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseWheel = FormMouseWheel
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object paClient: TTntPanel
    Left = 0
    Top = 0
    Width = 578
    Height = 378
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object spSess: TTntSplitter
      Left = 314
      Top = 32
      Height = 319
      AutoSnap = False
      MinSize = 100
      Visible = False
    end
    object paGrid: TTntPanel
      Left = 317
      Top = 32
      Width = 259
      Height = 319
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object hg: THistoryGrid
        Left = 0
        Top = 0
        Width = 259
        Height = 319
        VertScrollBar.Increment = 1
        VertScrollBar.PageSize = 20
        ShowBottomAligned = False
        ShowBookmarks = True
        MultiSelect = True
        ShowHeaders = False
        ExpandHeaders = False
        TxtStartup = 'Starting up...'
        TxtNoItems = 'History is empty'
        TxtNoSuch = 'No such items'
        TxtFullLog = 'Full History Log'
        TxtPartLog = 'Partial History Log'
        TxtHistExport = 'History++ export'
        TxtGenHist1 = '### (generated by history++ plugin)'
        TxtGenHist2 = '<h6>Generated by <b>History++</b> Plugin</h6>'
        OnDblClick = hgDblClick
        OnItemData = hgItemData
        OnPopup = hgPopup
        OnTranslateTime = hgTranslateTime
        OnSearchFinished = hgSearchFinished
        OnItemDelete = hgItemDelete
        OnKeyDown = hgKeyDown
        OnKeyUp = hgKeyUp
        OnInlineKeyDown = hgInlineKeyDown
        OnInlinePopup = hgInlinePopup
        OnProcessInlineChange = hgProcessInlineChange
        OnChar = hgChar
        OnState = hgState
        OnSelect = hgSelect
        OnXMLData = hgXMLData
        OnRTLChange = hgRTLEnabled
        OnUrlClick = hgUrlClick
        OnUrlPopup = hgUrlPopup
        OnBookmarkClick = hgBookmarkClick
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
        BevelInner = bvNone
        BevelOuter = bvNone
        Padding = 4
      end
    end
    object paSess: TTntPanel
      Left = 158
      Top = 32
      Width = 156
      Height = 319
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      object paSessInt: TTntPanel
        Left = 0
        Top = 0
        Width = 156
        Height = 21
        Align = alTop
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        DesignSize = (
          156
          21)
        object laSess: TTntLabel
          Left = 6
          Top = 2
          Width = 128
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Conversations'
          Layout = tlCenter
        end
        object sbCloseSess: TTntSpeedButton
          Left = 135
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
        Left = 0
        Top = 21
        Width = 156
        Height = 298
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Images = ilSessions
        Indent = 19
        MultiSelect = True
        ParentShowHint = False
        PopupMenu = pmSessions
        ReadOnly = True
        RightClickSelect = True
        RowSelect = True
        ShowHint = True
        TabOrder = 1
        ToolTips = False
        OnChange = tvSessChange
        OnGetSelectedIndex = tvSessGetSelectedIndex
        OnKeyDown = tvSessKeyDown
        OnKeyPress = edPassKeyPress
        OnMouseMove = tvSessMouseMove
      end
    end
    object paSearch: TTntPanel
      Left = 2
      Top = 351
      Width = 574
      Height = 25
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      Visible = False
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
        object edSearch: THppEdit
          Left = 47
          Top = 4
          Width = 447
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = edSearchChange
          OnKeyDown = edSearchKeyDown
          OnKeyPress = edPassKeyPress
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
    object TopPanel: TTntPanel
      Left = 2
      Top = 2
      Width = 574
      Height = 30
      Align = alTop
      AutoSize = True
      BevelOuter = bvNone
      TabOrder = 3
      object Toolbar: TTntToolBar
        Left = 0
        Top = 0
        Width = 574
        Height = 30
        AutoSize = True
        BorderWidth = 2
        EdgeBorders = []
        Flat = True
        Images = ilToolbar
        ParentShowHint = False
        PopupMenu = pmToolbar
        ShowHint = True
        TabOrder = 0
        Transparent = True
        Wrapable = False
        OnDblClick = ToolbarDblClick
        object tbUserDetails: TTntToolButton
          Left = 0
          Top = 0
          Hint = 'User Details'
          HelpKeyword = 'Ctrl+I'
          Caption = 'User Details'
          OnClick = tbUserDetailsClick
        end
        object tbUserMenu: TTntToolButton
          Left = 23
          Top = 0
          Hint = 'User Menu'
          Caption = 'User Menu'
          OnClick = tbUserMenuClick
        end
        object TntToolButton1: TTntToolButton
          Left = 46
          Top = 0
          Width = 8
          Style = tbsSeparator
        end
        object tbSessions: TTntToolButton
          Left = 54
          Top = 0
          Hint = 'Conversations'
          HelpKeyword = 'F4'
          AllowAllUp = True
          Caption = 'Conversations'
          Style = tbsCheck
          OnClick = tbSessionsClick
        end
        object tbBookmarks: TTntToolButton
          Left = 77
          Top = 0
          Hint = 'Bookmarks'
          HelpKeyword = 'F5'
          AllowAllUp = True
          Caption = 'Bookmarks'
          Style = tbsCheck
          OnClick = tbBookmarksClick
        end
        object TntToolButton2: TTntToolButton
          Left = 100
          Top = 0
          Width = 7
          Style = tbsSeparator
        end
        object tbSearch: TTntToolButton
          Left = 107
          Top = 0
          Hint = 'Find'
          HelpKeyword = 'Ctrl+F'
          AllowAllUp = True
          Caption = 'Find'
          Grouped = True
          Style = tbsCheck
          OnClick = tbSearchClick
        end
        object tbFilter: TTntToolButton
          Left = 130
          Top = 0
          Hint = 'Filter'
          HelpKeyword = 'Ctrl+E'
          AllowAllUp = True
          Caption = 'Filter'
          Grouped = True
          Style = tbsCheck
          OnClick = tbFilterClick
        end
        object TntToolButton3: TTntToolButton
          Left = 153
          Top = 0
          Width = 7
          Style = tbsSeparator
        end
        object tbEventsFilter: TTntSpeedButton
          Left = 160
          Top = 0
          Width = 110
          Height = 22
          Flat = True
          Layout = blGlyphTop
          PopupMenu = pmEventsFilter
          Spacing = -5
          Transparent = False
          OnClick = tbEventsFilterClick
        end
        object TntToolButton4: TTntToolButton
          Left = 270
          Top = 0
          Width = 7
          Style = tbsSeparator
        end
        object tbCopy: TTntToolButton
          Left = 277
          Top = 0
          Hint = 'Copy'
          Caption = 'Copy'
          OnClick = Copy1Click
        end
        object tbDelete: TTntToolButton
          Left = 300
          Top = 0
          Hint = 'Delete'
          Caption = 'Delete'
          OnClick = tbDeleteClick
        end
        object tbSave: TTntToolButton
          Left = 323
          Top = 0
          Hint = 'Save'
          Caption = 'Save'
          Visible = False
        end
        object TntToolButton5: TTntToolButton
          Left = 346
          Top = 0
          Width = 8
          Style = tbsSeparator
        end
        object tbHistory: TTntToolButton
          Left = 354
          Top = 0
          Hint = 'History Actions'
          Caption = 'History Actions'
          DropdownMenu = pmHistoryDD
          PopupMenu = pmHistory
          Style = tbsDropDown
          OnClick = tbHistoryClick
        end
        object tbHistorySearch: TTntToolButton
          Left = 390
          Top = 0
          Hint = 'History Search'
          Caption = 'History Search'
          OnClick = tbHistorySearchClick
        end
      end
    end
    object paBook: TTntPanel
      Left = 2
      Top = 32
      Width = 156
      Height = 319
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 4
      Visible = False
      object paBookInt: TTntPanel
        Left = 0
        Top = 0
        Width = 156
        Height = 21
        Align = alTop
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        DesignSize = (
          156
          21)
        object laBook: TTntLabel
          Left = 6
          Top = 2
          Width = 128
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Bookmarks'
          Layout = tlCenter
        end
        object sbCloseBook: TTntSpeedButton
          Left = 135
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
          OnClick = sbCloseBookClick
        end
      end
      object lvBook: TTntListView
        Left = 0
        Top = 21
        Width = 156
        Height = 298
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Columns = <
          item
            AutoSize = True
          end>
        FlatScrollBars = True
        RowSelect = True
        ShowColumnHeaders = False
        SmallImages = ilBook
        TabOrder = 1
        ViewStyle = vsReport
        OnContextPopup = lvBookContextPopup
        OnEdited = lvBookEdited
        OnKeyDown = lvBookKeyDown
        OnSelectItem = lvBookSelectItem
      end
    end
  end
  object sb: TTntStatusBar
    Left = 0
    Top = 378
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
    object paPassword: TTntPanel
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
    Left = 540
    Top = 40
  end
  object pmGrid: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    OnPopup = pmGridPopup
    Left = 324
    Top = 257
    object Details1: TTntMenuItem
      Caption = '&Open'
      OnClick = Details1Click
    end
    object Bookmark1: TTntMenuItem
      Caption = 'Set &Bookmark'
      ShortCut = 16450
      OnClick = Bookmark1Click
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
      ShortCut = 16467
      OnClick = SaveSelected1Click
    end
    object N13: TTntMenuItem
      Caption = '-'
    end
    object SelectAll1: TTntMenuItem
      Caption = 'Select &All'
      ShortCut = 16449
      Visible = False
      OnClick = SelectAll1Click
    end
  end
  object pmLink: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    Left = 368
    Top = 258
    object OpenLink: TTntMenuItem
      Caption = 'Open &Link'
      Default = True
      OnClick = OpenLinkClick
    end
    object OpenLinkNW: TTntMenuItem
      Caption = 'Open Link in New &Window'
      OnClick = OpenLinkNWClick
    end
    object N1: TTntMenuItem
      Caption = '-'
    end
    object CopyLink: TTntMenuItem
      Caption = '&Copy Link'
      OnClick = CopyLinkClick
    end
  end
  object ilSessions: TImageList
    BkColor = clWhite
    Left = 164
    Top = 60
  end
  object tiFilter: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tiFilterTimer
    Left = 540
    Top = 72
  end
  object ilToolbar: TImageList
    Left = 540
    Top = 4
  end
  object pmHistory: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    OnPopup = pmHistoryPopup
    Left = 444
    Top = 20
    object SaveSelected2: TTntMenuItem
      Caption = '&Save Selected...'
      OnClick = SaveSelected1Click
    end
    object N4: TTntMenuItem
      Caption = '-'
    end
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
      OnClick = SaveasRTF2Click
    end
    object SaveasText2: TTntMenuItem
      Caption = 'Export as &Text...'
      OnClick = SaveasText2Click
    end
    object N3: TTntMenuItem
      Caption = '-'
    end
    object Emptyhistory1: TTntMenuItem
      Caption = 'Empty history...'
      OnClick = Emptyhistory1Click
    end
    object N6: TTntMenuItem
      Caption = '-'
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
    object N7: TTntMenuItem
      Caption = '-'
    end
    object Passwordprotection1: TTntMenuItem
      Caption = 'Password protection...'
      OnClick = Passwordprotection1Click
    end
  end
  object pmEventsFilter: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    OnPopup = pmEventsFilterPopup
    Left = 412
    Top = 20
    object Showall1: TTntMenuItem
      Caption = '-'
    end
    object Customize1: TTntMenuItem
      Caption = '&Customize...'
      OnClick = Customize1Click
    end
  end
  object pmSessions: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    Left = 198
    Top = 61
    object SessCopy: TTntMenuItem
      Caption = '&Copy'
      Enabled = False
    end
    object SessSelect: TTntMenuItem
      Caption = 'Select'
      OnClick = SessSelectClick
    end
    object SessDelete: TTntMenuItem
      Caption = 'Delete'
      Enabled = False
    end
    object SessSave: TTntMenuItem
      Caption = 'Save...'
      Enabled = False
    end
  end
  object pmToolbar: TTntPopupMenu
    Images = ilToolbar
    Left = 476
    Top = 20
    object N5: TTntMenuItem
      Caption = '-'
    end
    object Customize2: TTntMenuItem
      Caption = '&Customize...'
      OnClick = Customize2Click
    end
  end
  object ilBook: TImageList
    BkColor = clWhite
    Left = 8
    Top = 60
  end
  object pmBook: TTntPopupMenu
    Left = 42
    Top = 61
    object RenameBookmark1: TTntMenuItem
      Caption = 'Rename &Bookmark'
      OnClick = RenameBookmark1Click
    end
    object N11: TTntMenuItem
      Caption = '-'
    end
    object DeleteBookmark1: TTntMenuItem
      Caption = 'Remove &Bookmark'
      ShortCut = 16450
      OnClick = Bookmark1Click
    end
  end
  object pmInline: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    Left = 324
    Top = 293
    object InlineCopy: TTntMenuItem
      Caption = '&Copy'
      ShortCut = 16451
      OnClick = InlineCopyClick
    end
    object InlineCopyAll: TTntMenuItem
      Caption = 'Copy &Text'
      ShortCut = 16468
      OnClick = InlineCopyAllClick
    end
    object InlineSelectAll: TTntMenuItem
      Caption = 'Select &All'
      ShortCut = 16449
      OnClick = InlineSelectAllClick
    end
    object TntMenuItem10: TTntMenuItem
      Caption = '-'
    end
    object InlineTextFormatting: TTntMenuItem
      Caption = 'Text Formatting'
      ShortCut = 16464
      OnClick = InlineTextFormattingClick
    end
    object TntMenuItem6: TTntMenuItem
      Caption = '-'
    end
    object InlineSendMessage: TTntMenuItem
      Caption = 'Send &Message'
      ShortCut = 16461
      OnClick = SendMessage1Click
    end
    object InlineReplyQuoted: TTntMenuItem
      Caption = '&Reply Quoted'
      ShortCut = 16466
      OnClick = InlineReplyQuotedClick
    end
  end
  object mmAcc: TTntMainMenu
    Left = 10
    Top = 98
    object mmToolbar: TTntMenuItem
      Caption = 'Toolbar'
      OnClick = mmToolbarClick
    end
    object mmService: TTntMenuItem
      Caption = 'Service'
      object mmHideMenu: TTntMenuItem
        Caption = 'Hide Menu'
        ShortCut = 16505
        OnClick = mmHideMenuClick
      end
    end
    object mmShortcuts: TTntMenuItem
      Caption = '--'
      Visible = False
      object mmBookmark: TTntMenuItem
        Caption = '--'
        ShortCut = 16450
        OnClick = Bookmark1Click
      end
    end
  end
  object pmHistoryDD: TPopupMenu
    OnPopup = pmHistoryDDPopup
    Left = 365
    Top = 36
  end
end
