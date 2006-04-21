object fmGlobalSearch: TfmGlobalSearch
  Left = 367
  Top = 158
  Caption = 'Global History Search'
  ClientHeight = 525
  ClientWidth = 551
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
  OnDestroy = TntFormDestroy
  OnKeyDown = FormKeyDown
  OnMouseWheel = TntFormMouseWheel
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TTntPanel
    Left = 0
    Top = 0
    Width = 551
    Height = 506
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object spContacts: TTntSplitter
      Left = 157
      Top = 113
      Height = 337
      Visible = False
    end
    object paSearch: TTntPanel
      Left = 2
      Top = 2
      Width = 547
      Height = 85
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        547
        85)
      object laSearch: TTntLabel
        Left = 4
        Top = 8
        Width = 49
        Height = 13
        Caption = 'Search for'
        FocusControl = edSearch
      end
      object edSearch: TTntEdit
        Left = 70
        Top = 4
        Width = 281
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = edSearchChange
        OnEnter = edSearchEnter
        OnKeyDown = edSearchKeyUp
        OnKeyPress = edSearchKeyPress
      end
      object bnSearch: TTntButton
        Left = 354
        Top = 3
        Width = 89
        Height = 23
        Anchors = [akTop, akRight]
        Caption = 'Search'
        Enabled = False
        TabOrder = 1
        OnClick = bnSearchClick
      end
      object bnAdvanced: TTntButton
        Left = 446
        Top = 3
        Width = 101
        Height = 23
        Anchors = [akTop, akRight]
        Caption = 'Advanced >>'
        TabOrder = 2
        OnClick = bnAdvancedClick
      end
      object gbAdvanced: TTntGroupBox
        Left = 2
        Top = 31
        Width = 543
        Height = 48
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Advanced Search Options'
        TabOrder = 3
        object rbAny: TTntRadioButton
          Left = 10
          Top = 21
          Width = 155
          Height = 17
          Caption = 'Search any word'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbAll: TTntRadioButton
          Left = 171
          Top = 21
          Width = 156
          Height = 17
          Caption = 'Search all words'
          TabOrder = 1
        end
        object rbExact: TTntRadioButton
          Left = 328
          Top = 21
          Width = 163
          Height = 17
          Caption = 'Search exact phrase'
          TabOrder = 2
        end
      end
    end
    object paProgress: TTntPanel
      Left = 2
      Top = 450
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
      Top = 87
      Width = 547
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object laPass: TTntLabel
        Left = 250
        Top = 5
        Width = 49
        Height = 13
        Caption = 'Password:'
        Enabled = False
      end
      object edPass: TPasswordEdit
        Left = 302
        Top = 1
        Width = 125
        Height = 21
        TabOrder = 1
        OnKeyDown = edSearchKeyUp
        OnKeyPress = edPassKeyPress
      end
      object cbPass: TTntCheckBox
        Left = 4
        Top = 4
        Width = 241
        Height = 17
        Caption = 'Include password-protected contacts'
        TabOrder = 0
        OnClick = cbPassClick
      end
    end
    object paContacts: TTntPanel
      Left = 2
      Top = 113
      Width = 155
      Height = 337
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 2
      Visible = False
      object lvContacts: TTntListView
        Left = 0
        Top = 0
        Width = 155
        Height = 337
        Align = alClient
        Columns = <
          item
            Width = -1
            WidthType = (
              -1)
          end>
        ColumnClick = False
        ReadOnly = True
        ShowColumnHeaders = False
        SmallImages = ilContacts
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = lvContactsSelectItem
      end
    end
    object paHistory: TTntPanel
      Left = 160
      Top = 113
      Width = 389
      Height = 337
      Align = alClient
      BevelOuter = bvNone
      BorderStyle = bsSingle
      TabOrder = 4
      object hg: THistoryGrid
        Left = 0
        Top = 0
        Width = 385
        Height = 305
        VertScrollBar.Increment = 1
        VertScrollBar.PageSize = 20
        MultiSelect = True
        TxtStartup = 'Starting up...'
        TxtNoItems = 'No items found'
        TxtNoSuch = 'No items for your current filter'
        TxtFullLog = 'Full History Log'
        TxtPartLog = 'Partial History Log'
        TxtHistExport = 'History++ export'
        TxtGenHist1 = '### (generated by history++ plugin)'
        TxtGenHist2 = '<h6>Generated by <b>History++</b> Plugin</h6>'
        Filter = [mtUnknown, mtIncoming, mtOutgoing, mtMessage, mtUrl, mtFile, mtSystem, mtContacts, mtSMS, mtWebPager, mtEmailExpress, mtStatus, mtOther]
        OnDblClick = hgDblClick
        OnItemData = hgItemData
        OnNameData = hgNameData
        OnPopup = hgPopup
        OnTranslateTime = hgTranslateTime
        OnSearchFinished = hgSearchFinished
        OnItemDelete = hgItemDelete
        OnKeyDown = hgKeyDown
        OnKeyUp = hgKeyUp
        OnState = hgState
        OnSelect = hgSelect
        OnUrlClick = hgUrlClick
        OnItemFilter = hgItemFilter
        OnProcessRichText = hgProcessRichText
        OnSearchItem = hgSearchItem
        Reversed = False
        Align = alClient
        TabStop = True
        Padding = 4
      end
      object paFilter: TTntPanel
        Left = 0
        Top = 305
        Width = 385
        Height = 28
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        DesignSize = (
          385
          28)
        object sbClearFilter: TTntSpeedButton
          Left = 27
          Top = 4
          Width = 23
          Height = 21
          Hint = 'Clear Search'
          Flat = True
          Glyph.Data = {
            7E030000424D7E030000000000003600000028000000120000000F0000000100
            1800000000004803000000000000000000000000000000000000FF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FF0000FF00FFD3CCC4FFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FF0000FF00FFBDB6AF00000000000000000000000000000000
            0000000000000000000000000000FFFFFFFF00FFFF00FFFF00FFFF00FFFF00FF
            0000FF00FFBEB7B1000000000000000000000000000000000000000000000000
            000000000000000000FFFFFFFF00FFFF00FFFF00FFFF00FF0000FF00FFBFB9B2
            000000000000FFFFFFFFFFFF000000000000000000FFFFFFFFFFFF0000000000
            00000000FFFFFFFF00FFFF00FFFF00FF0000FF00FFBFBAB4000000000000FFFF
            FFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF000000000000000000000000FF
            FFFFFF00FFFF00FF0000FF00FFC0BBB6000000000000000000FFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFF000000000000000000000000000000000000FFFFFFFF00FF
            0000FF00FFC1BCB7000000181818181818000000FFFFFFFFFFFFFFFFFF000000
            181818181818181818181818181818181818000000FF00FF0000FF00FFC2BEB8
            0000004040402D2D2DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2D2D2D4040404040
            40404040404040000000D9D5CFFF00FF0000FF00FFC3BFBA0000005A5A5AFFFF
            FFFFFFFFFFFFFF5A5A5AFFFFFFFFFFFFFFFFFF5A5A5A696969696969000000DA
            D6D0FF00FFFF00FF0000FF00FFC3C0BB000000888888FFFFFFFFFFFF88888893
            9393888888FFFFFFFFFFFF888888939393000000DBD8D2FF00FFFF00FFFF00FF
            0000FF00FFC4C1BD000000CFCFCFBDBDBDB7B7B7B7B7B7BDBDBDB7B7B7B7B7B7
            BDBDBDBDBDBD000000DCD8D4FF00FFFF00FFFF00FFFF00FF0000FF00FFC5C2BF
            000000000000000000000000000000000000000000000000000000000000DDD9
            D6FF00FFFF00FFFF00FFFF00FFFF00FF0000FF00FFB2B0ADC6C3C0C6C3C0C6C3
            C0C6C3C0C6C3C0C6C3C0C6C3C0C6C3C0C6C3C0C6C3C0FF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FF0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            0000}
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
          Width = 319
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = edFilterChange
          OnKeyDown = edFilterKeyDown
          OnKeyUp = edFilterKeyUp
        end
      end
    end
  end
  object sb: TTntStatusBar
    Left = 0
    Top = 506
    Width = 551
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object pmGrid: TTntPopupMenu
    Left = 206
    Top = 266
    object Open1: TTntMenuItem
      Caption = 'Sh&ow in context'
      ShortCut = 16397
      OnClick = hgDblClick
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
    Left = 52
    Top = 180
  end
  object SaveDialog: TSaveDialog
    FilterIndex = 0
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofShareAware, ofEnableSizing]
    Title = 'Save History'
    Left = 252
    Top = 176
  end
  object tiFilter: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tiFilterTimer
    Left = 352
    Top = 376
  end
end
