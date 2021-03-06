object fmGlobalSearch: TfmGlobalSearch
  Left = 220
  Top = 99
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
        Text = 'http:'
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
      DesignSize = (
        547
        26)
      object laPass: TTntLabel
        Left = 369
        Top = 5
        Width = 49
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Password:'
        Enabled = False
      end
      object edPass: TPasswordEdit
        Left = 421
        Top = 1
        Width = 125
        Height = 21
        Anchors = [akTop, akRight]
        TabOrder = 1
        OnKeyDown = edSearchKeyUp
        OnKeyPress = edPassKeyPress
      end
      object cbPass: TTntCheckBox
        Left = 4
        Top = 4
        Width = 273
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
        object imFilter: TImage
          Left = 6
          Top = 6
          Width = 16
          Height = 16
          Picture.Data = {
            055449636F6E0000010002001010000000000000680500002600000010100000
            00000000680400008E0500002800000010000000200000000100080000000000
            400100000000000000000000000000000000000000000000FFFFFF00A38A8000
            B08A7900B9907E00B6938200A8928B00B78E7C00F2D5C000FEF4E700FFFBEC00
            FFF8E600FAE9D200BFA19000FBEAD900FFFCEF00FFECD200FFE3C700FFE1C500
            FFE3C800FEE9CF00BE9F8F00FFE5C900FFE5C800FFECCF00FFEFD100FFEBCD00
            F8D0B600B0897800FFF3D400FFFCDE00FFFEE300FFFCDF00FFF1D200FEDCC000
            B3968900B9907D00FFFFED00FFFFF700FFFFF300FFFCE000FFE6C900B7958800
            B6918200FEF8E600FFFFFE00FFFEE800FEE8CA00B1958A00A7918900F9E8D100
            FFE4C800FFFFF200FFFFFD00FFFFFA00FFFBE100EECEB300BE9F8E00FFE1C400
            FFF0D200FFFBDF00FFFEE700FFFBE000FCE8CA00AA958F0099AEC600BD9D8D00
            FEDBBF00FEE6C900EDCCB200957F7F007599C400A5C9E60099AFC700B2958A00
            B6958700B0968A004D597E005777AC00759ECE009AB0C8004D588000A5C8E600
            9AB1C9004D587F00759ECD0096AAC2004E597F00749ECD00829DBF0057608200
            5569940000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000005A5B000000000000000000000000004D
            4E585900000000000000000000004D4E58485600000000000000000000514E58
            48530000000000004A054A004D4E5848530000000000421B4344444546474841
            0000000000421A3A1D1E1F1F1A404100000000000610441A1E2735351F450000
            00000000051F3A101F2735350A1A4A0000000000240A3A1A1E0A27271F444A00
            00000000070910441D1E1F1E1D224A000000000002080A44441A101A3A1B0000
            0000000000070E0A103A3A441A4200000000000000000708090A1F100D000000
            0000000000000002072405400000000000000000FFFF0000FFF30000FFE10000
            FFC10000FF830000F1070000C00F0000801F0000003F0000001F0000001F0000
            001F0000003F0000803F0000C07F0000E0FF0000280000001000000020000000
            0100200000000000400400000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000170000004A0000002E0000000200000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000001B1B312E374269D94A618CF9283145C90000002E00000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000001B1B312E3A4670E45777ACFF749ECDFF7895B7F90000004A00000000
            0000000000000000000000000000000000000000000000000000000000000000
            1B1B312E3A4670E45777ACFF749ECDFFA5C8E5FF8098B3D80000001600000000
            0000000000000000000000030000001500000029000000250000000F1A1A2F30
            3A4670E45777ACFF749ECDFFA5C8E5FF8EA7C2E33844602D0000000000000000
            000000001810101F5A403793876658D793705FE8795A4EDE3A2A26BA3A456FE8
            5777ACFF749ECDFFA5C8E5FF8EA7C2E33844602D000000000000000000000000
            51393035B18E7DE2F6CFB5FFFEDABEFFFFE5C8FFFEE7C9FFEECEB3FF97807FFF
            7598C3FFA5C8E5FF8EA7C2E33844602D00000000000000000000000050353513
            B59381E3FEEACFFFFFE0C4FFFFEFD1FFFFFBDFFFFFFEE7FFFFFBE1FFFDE9CBFF
            AB958EFF8BA2BDE837425E2E0000000000000000000000000000000089645682
            F7E4CDFFFFE5C9FFFFEACCFFFFFBDEFFFFFFF2FFFFFFFDFFFFFFFAFFFFFCE1FF
            EFD0B5FF3F2F2CBC0000001000000000000000000000000000000000AE8473D1
            FEF7E5FFFFE2C6FFFFEED0FFFFFDE2FFFFFFF6FFFFFFFFFFFFFFFEFFFFFEE8FF
            FEE9CBFF7E5F51E10000002800000000000000000000000000000000B68B79EE
            FFFAEBFFFFE4C8FFFFECCEFFFFFCDEFFFFFFEDFFFFFFF7FFFFFFF3FFFFFCE0FF
            FFE7CAFF987464EA0000002C00000000000000000000000000000000AB816EDB
            FEF2E4FFFFEED4FFFFE5C8FFFFF2D4FFFFFCDEFFFFFEE3FFFFFCDFFFFFF1D3FF
            FEDCC0FF8D6A5CDC00000019000000000000000000000000000000008E665896
            EFD1BBFFFFFCF0FFFFE5CAFFFFE5C8FFFFECCFFFFFEFD1FFFFEBCEFFFFE1C5FF
            F9D2B8FF60463C9C0000000300000000000000000000000000000000774F4720
            B28874F3FAE7D6FFFFFCF0FFFFEDD3FFFFE3C7FFFFE1C5FFFFE3C7FFFFE9CFFF
            B69583E922141425000000000000000000000000000000000000000000000000
            7D574C49B38976F4F1D3BEFFFEF4E6FFFFFBECFFFFF8E7FFFAEAD3FFBE9C89EA
            593C343F00000000000000000000000000000000000000000000000000000000
            00000000745048239168599CAD8370E4B98F7CF8B48A78DD91695B8E583A311A
            00000000000000000000000000000000000000000000000000000000FFF00000
            FFE00000FFC00000FF800000E0010000C003000080070000000F0000000F0000
            000F0000000F0000000F0000000F0000001F0000803F0000C07F0000}
          Transparent = True
        end
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
        object imFilterWait: TImage
          Left = 6
          Top = 6
          Width = 16
          Height = 16
          Picture.Data = {
            055449636F6E0000010002001010000000000000680500002600000010100000
            00000000680400008E0500002800000010000000200000000100080000000000
            000100000000000000000000000000000000000000000000F4F4F400CCCCCC00
            C4C4C400D4CCBC00CCC4BC00BCBCBC00B4B4B400BCB4AC00B4ACA400ACACAC00
            ACA4A400A4A4A400BCBC94009C9C9C009494940094948C008C8C8C009C9C4400
            A4A404009C9C04008C8C0400848404007C7C74007C7474007474740064646400
            54544C004C4C4C004C4C44007C7C04006C6C04005C5C04005454040044440400
            34343400242424003C3C04002C2C0400141414001C1C04000404040000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000FCFCFC00000000262520202226262626
            1D0000000000000D151414151616162800000000000000000F01FF0303030329
            00000000000000000F01FF030303032900000000000000000F01FF0303030329
            0000000000000000080B010206071C00000000000000000000080E0A061C0000
            00000000000000000000000C2700000000000000000000000000181A1C100000
            0000000000000000001B111A2319100000000000000000001711241A07231C00
            00000000000000000F11010F030A0E2900000000000000000F01FF0303030329
            0000000000000000190F0F0F0F0F0F2900000000000000121F13131E21212121
            170000000000001616161616161616161D000000E0070000E00F0000F00F0000
            F00F0000F00F0000F01F0000F83F0000FE7F0000FC3F0000F81F0000F01F0000
            F00F0000F00F0000F00F0000E0070000E0070000280000001000000020000000
            0100200000000000000400000000000000000000000000000000000000000000
            00000000000000002F2F00FF3F3F00FF5D5D00FF5D5D00FF464600FF2F2F00FF
            2F2F00FF2F2F00FF2F2F00FF000000A200000000000000000000000000000000
            00000000000000008080003B8B8B00FF9D9D00FF9D9D00FF8F8F00FF808000FF
            808000FF808000FF1D1D00FF0000002500000000000000000000000000000000
            000000000000000000000000979797FFF1F1F1FFF9F9F9FFC0C0C0FFC0C0C0FF
            C0C0C0FFC0C0C0FF000000FF0000000000000000000000000000000000000000
            000000000000000000000000979797FFF1F1F1FFF9F9F9FFC0C0C0FFC0C0C0FF
            C0C0C0FFC0C0C0FF000000FF0000000000000000000000000000000000000000
            000000000000000000000000979797FFF1F1F1FFF9F9F9FFC0C0C0FFC0C0C0FF
            C0C0C0FFC0C0C0FF000000FF0000000000000000000000000000000000000000
            00000000000000000000000080808048A6A6A6F1F2F2F2FFCACACAFFBCBCBCFF
            B6B6B6FF363636DA000000000000000000000000000000000000000000000000
            00000000000000000000000000000000808080489D9D9DFFA9A9A9FFB9B9B9FF
            363636DA00000022000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000080808018A0A0A0FF121212FF
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000707076C606060FF4B4B4BFF
            0000004800000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000978A8A8AFF606060FF363636FF
            727272F100000048000000000000000000000000000000000000000000000000
            0000000000000000000000000E0E0E6C8A8A8AFF262626FF606060FFB0B0B0FF
            363636FF4B4B4BFF000000180000000000000000000000000000000000000000
            000000000000000000000000979797FF8F8F8FFFF0F0F0FF909090FFC0C0C0FF
            AAAAAAFF9D9D9DFF000000FF0000000000000000000000000000000000000000
            000000000000000000000000979797FFF1F1F1FFF9F9F9FFC0C0C0FFC0C0C0FF
            C0C0C0FFC0C0C0FF000000FF0000000000000000000000000000000000000000
            000000000000000000000000747474FF949494FF949494FF949494FF949494FF
            949494FF949494FF000000FF0000000000000000000000000000000000000000
            0000000000000000808000A26F6F00FFA2A200FFA2A200FF7A7A00FF515100FF
            515100FF515100FF515100FF0000006700000000000000000000000000000000
            0000000000000000808000FF808000FF808000FF808000FF808000FF808000FF
            808000FF808000FF808000FF000000A2000000000000000000000000E0070000
            E0070000F00F0000F00F0000F00F0000F01F0000F81F0000FC7F0000FC3F0000
            F81F0000F00F0000F00F0000F00F0000F00F0000E0070000E0070000}
          Transparent = True
          Visible = False
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
      Visible = False
    end
    object CopyText1: TTntMenuItem
      Caption = 'Copy &Text'
      ShortCut = 16468
      Visible = False
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
