object fmGlobalSearch: TfmGlobalSearch
  Left = 271
  Top = 113
  Width = 559
  Height = 545
  Caption = 'Global History Search'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseWheel = TntFormMouseWheel
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TTntPanel
    Left = 0
    Top = 0
    Width = 551
    Height = 499
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object spContacts: TTntSplitter
      Left = 157
      Top = 202
      Height = 241
      Visible = False
    end
    object paSearch: TTntPanel
      Left = 2
      Top = 32
      Width = 547
      Height = 32
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        547
        32)
      object laSearch: TTntLabel
        Left = 4
        Top = 10
        Width = 49
        Height = 13
        Caption = 'Search for'
        FocusControl = edSearch
      end
      object edSearch: TTntEdit
        Left = 70
        Top = 6
        Width = 378
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = edSearchChange
        OnEnter = edSearchEnter
        OnKeyDown = edSearchKeyUp
        OnKeyPress = edSearchKeyPress
      end
      object bnSearch: TTntButton
        Left = 454
        Top = 5
        Width = 89
        Height = 23
        Anchors = [akTop, akRight]
        Caption = 'Search'
        Enabled = False
        TabOrder = 1
        OnClick = bnSearchClick
      end
    end
    object paProgress: TTntPanel
      Left = 2
      Top = 443
      Width = 547
      Height = 54
      Align = alBottom
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 3
      Visible = False
      DesignSize = (
        547
        54)
      object laProgress: TTntLabel
        Left = 12
        Top = 7
        Width = 523
        Height = 13
        Alignment = taCenter
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '-'
      end
      object pb: TProgressBar
        Left = 12
        Top = 29
        Width = 523
        Height = 16
        Anchors = [akLeft, akRight, akBottom]
        Position = 34
        TabOrder = 0
      end
    end
    object paPassword: TTntPanel
      Left = 2
      Top = 156
      Width = 547
      Height = 46
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      DesignSize = (
        547
        46)
      object bePassword: TTntBevel
        Left = 12
        Top = 10
        Width = 523
        Height = 5
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object laPass: TTntLabel
        Left = 8
        Top = 25
        Width = 49
        Height = 13
        Caption = 'Password:'
      end
      object laPasswordHead: TTntLabel
        Left = 4
        Top = 4
        Width = 154
        Height = 13
        Caption = 'Search Protected Contacts'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
      end
      object sbPasswordClose: TTntSpeedButton
        Left = 525
        Top = 2
        Width = 18
        Height = 17
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
        Transparent = False
        OnClick = sbPasswordCloseClick
      end
      object laPassNote: TTntLabel
        Left = 199
        Top = 25
        Width = 3
        Height = 13
      end
      object edPass: TPasswordEdit
        Left = 65
        Top = 21
        Width = 125
        Height = 21
        TabOrder = 0
        OnKeyDown = edSearchKeyUp
        OnKeyPress = edPassKeyPress
      end
    end
    object paContacts: TTntPanel
      Left = 2
      Top = 202
      Width = 155
      Height = 241
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 2
      Visible = False
      object lvContacts: TTntListView
        Left = 0
        Top = 0
        Width = 155
        Height = 241
        Align = alClient
        Columns = <
          item
            Width = -1
            WidthType = (
              -1)
          end>
        ColumnClick = False
        FlatScrollBars = True
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        SmallImages = ilContacts
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = lvContactsContextPopup
        OnSelectItem = lvContactsSelectItem
      end
    end
    object paHistory: TTntPanel
      Left = 160
      Top = 202
      Width = 389
      Height = 241
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 4
      object hg: THistoryGrid
        Left = 0
        Top = 0
        Width = 389
        Height = 213
        VertScrollBar.Increment = 1
        VertScrollBar.PageSize = 20
        ShowBottomAligned = False
        ShowBookmarks = True
        MultiSelect = True
        ShowHeaders = False
        ExpandHeaders = False
        TxtStartup = 'Starting up...'
        TxtNoItems = 'No items found'
        TxtNoSuch = 'No items for your current filter'
        TxtFullLog = 'Full History Log'
        TxtPartLog = 'Partial History Log'
        TxtHistExport = 'History++ export'
        TxtGenHist1 = '### (generated by history++ plugin)'
        TxtGenHist2 = '<h6>Generated by <b>History++</b> Plugin</h6>'
        OnDblClick = hgDblClick
        OnItemData = hgItemData
        OnNameData = hgNameData
        OnPopup = hgPopup
        OnTranslateTime = hgTranslateTime
        OnSearchFinished = hgSearchFinished
        OnItemDelete = hgItemDelete
        OnKeyDown = hgKeyDown
        OnKeyUp = hgKeyUp
        OnInlineKeyDown = hgInlineKeyDown
        OnInlinePopup = hgInlinePopup
        OnState = hgState
        OnSelect = hgSelect
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
        BevelInner = bvNone
        BevelOuter = bvNone
        Padding = 4
      end
      object paFilter: TTntPanel
        Left = 0
        Top = 213
        Width = 389
        Height = 28
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          389
          28)
        object sbClearFilter: TTntSpeedButton
          Left = 27
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
          Left = 6
          Top = 6
          Width = 16
          Height = 16
          OnPaint = pbFilterPaint
        end
        object edFilter: TTntEdit
          Left = 52
          Top = 4
          Width = 323
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = edFilterChange
          OnKeyDown = edFilterKeyDown
          OnKeyUp = edFilterKeyUp
        end
      end
    end
    object ToolBar: TTntToolBar
      Left = 2
      Top = 2
      Width = 547
      Height = 30
      AutoSize = True
      BorderWidth = 2
      EdgeInner = esNone
      EdgeOuter = esNone
      Flat = True
      Images = ilToolbar
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      Transparent = True
      object tbAdvanced: TTntToolButton
        Left = 0
        Top = 0
        Hint = 'Advanced search options'
        Style = tbsCheck
        OnClick = tbAdvancedClick
      end
      object tbRange: TTntToolButton
        Left = 23
        Top = 0
        Hint = 'Limit search range'
        Style = tbsCheck
        OnClick = tbRangeClick
      end
      object tbPassword: TTntToolButton
        Left = 46
        Top = 0
        Hint = 'Search protected contacts'
        ImageIndex = 0
        Style = tbsCheck
        OnClick = tbPasswordClick
      end
      object TntToolButton3: TTntToolButton
        Left = 69
        Top = 0
        Width = 8
        Enabled = False
        Style = tbsSeparator
      end
      object tbSearch: TTntToolButton
        Left = 77
        Top = 0
        Caption = 'tbSearch'
        Grouped = True
        Style = tbsCheck
        Visible = False
      end
      object tbFilter: TTntToolButton
        Left = 100
        Top = 0
        Caption = 'tbFilter'
        Grouped = True
        Style = tbsCheck
        Visible = False
      end
      object TntToolButton4: TTntToolButton
        Left = 123
        Top = 0
        Width = 8
        Style = tbsSeparator
        Visible = False
      end
      object tbEventsFilter: TTntSpeedButton
        Left = 131
        Top = 0
        Width = 110
        Height = 22
        Enabled = False
        Flat = True
        Layout = blGlyphTop
        ParentShowHint = False
        PopupMenu = pmEventsFilter
        ShowHint = True
        Spacing = -5
        Transparent = False
        OnClick = tbEventsFilterClick
      end
    end
    object paAdvanced: TTntPanel
      Left = 2
      Top = 64
      Width = 547
      Height = 46
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 6
      Visible = False
      DesignSize = (
        547
        46)
      object beAdvanced: TTntBevel
        Left = 16
        Top = 10
        Width = 519
        Height = 5
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object laAdvancedHead: TTntLabel
        Left = 4
        Top = 4
        Width = 149
        Height = 13
        Caption = 'Advanced Search Options'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
      end
      object sbAdvancedClose: TTntSpeedButton
        Left = 525
        Top = 2
        Width = 18
        Height = 17
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
        Transparent = False
        OnClick = sbAdvancedCloseClick
      end
      object rbAny: TTntRadioButton
        Left = 8
        Top = 24
        Width = 155
        Height = 17
        Caption = 'Search any word'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object rbAll: TTntRadioButton
        Left = 169
        Top = 24
        Width = 156
        Height = 17
        Caption = 'Search all words'
        TabOrder = 1
      end
      object rbExact: TTntRadioButton
        Left = 331
        Top = 24
        Width = 163
        Height = 17
        Caption = 'Search exact phrase'
        TabOrder = 2
      end
    end
    object paRange: TTntPanel
      Left = 2
      Top = 110
      Width = 547
      Height = 46
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 7
      Visible = False
      DesignSize = (
        547
        46)
      object laRange1: TTntLabel
        Left = 8
        Top = 25
        Width = 126
        Height = 13
        AutoSize = False
        Caption = 'Search messages from'
      end
      object laRange2: TTntLabel
        Left = 223
        Top = 25
        Width = 38
        Height = 13
        Alignment = taCenter
        AutoSize = False
        Caption = 'to'
      end
      object beRange: TTntBevel
        Left = 16
        Top = 10
        Width = 519
        Height = 5
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object laRangeHead: TTntLabel
        Left = 4
        Top = 4
        Width = 112
        Height = 13
        Caption = 'Limit Search Range'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
      end
      object sbRangeClose: TTntSpeedButton
        Left = 525
        Top = 2
        Width = 18
        Height = 17
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
        Transparent = False
        OnClick = sbRangeCloseClick
      end
      object dtRange1: TTntDateTimePicker
        Left = 135
        Top = 21
        Width = 87
        Height = 21
        BiDiMode = bdLeftToRight
        Date = 29221.000000000000000000
        Time = 29221.000000000000000000
        ParentBiDiMode = False
        TabOrder = 0
      end
      object dtRange2: TTntDateTimePicker
        Left = 262
        Top = 22
        Width = 87
        Height = 21
        BiDiMode = bdLeftToRight
        Date = 29221.999988425930000000
        Time = 29221.999988425930000000
        ParentBiDiMode = False
        TabOrder = 1
      end
    end
  end
  object sb: TTntStatusBar
    Left = 0
    Top = 499
    Width = 551
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object pmGrid: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    Left = 206
    Top = 266
    object Open1: TTntMenuItem
      Caption = 'Sh&ow in context'
      ShortCut = 16397
      OnClick = hgDblClick
    end
    object Bookmark1: TTntMenuItem
      Caption = 'Set &Bookmark'
      ShortCut = 16450
      OnClick = Bookmark1Click
    end
    object N3: TTntMenuItem
      Caption = '-'
    end
    object SendMessage1: TTntMenuItem
      Caption = 'Send &Message'
      ShortCut = 16461
      OnClick = SendMessage1Click
    end
    object ReplyQuoted1: TTntMenuItem
      Caption = 'Reply &Quoted'
      ShortCut = 16466
      OnClick = ReplyQuoted1Click
    end
    object N2: TTntMenuItem
      Caption = '-'
      Visible = False
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
    object N1: TTntMenuItem
      Caption = '-'
      Visible = False
    end
    object SaveSelected1: TTntMenuItem
      Caption = '&Save Selected...'
      ShortCut = 16467
      Visible = False
      OnClick = SaveSelected1Click
    end
  end
  object ilContacts: TImageList
    ShareImages = True
    Left = 174
    Top = 214
  end
  object SaveDialog: TSaveDialog
    FilterIndex = 0
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofShareAware, ofEnableSizing]
    Title = 'Save History'
    Left = 218
    Top = 204
  end
  object tiFilter: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tiFilterTimer
    Left = 352
    Top = 376
  end
  object ilToolbar: TImageList
    Left = 520
    Top = 2
  end
  object pmEventsFilter: TTntPopupMenu
    Left = 266
    Top = 2
    object N4: TTntMenuItem
      Caption = '-'
    end
    object Customize1: TTntMenuItem
      Caption = '&Customize...'
      OnClick = Customize1Click
    end
  end
  object pmInline: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    Left = 204
    Top = 301
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
  object pmLink: TTntPopupMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    Left = 244
    Top = 266
    object OpenLink: TTntMenuItem
      Caption = 'Open &Link'
      Default = True
      OnClick = OpenLinkClick
    end
    object OpenLinkNW: TTntMenuItem
      Caption = 'Open Link in New &Window'
      OnClick = OpenLinkNWClick
    end
    object TntMenuItem2: TTntMenuItem
      Caption = '-'
    end
    object CopyLink: TTntMenuItem
      Caption = '&Copy Link'
      OnClick = CopyLinkClick
    end
  end
end
