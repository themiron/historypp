{-----------------------------------------------------------------------------
 HistoryGrid (historypp project)

 Version:   1.4
 Created:   xx.02.2003
 Author:    Oxygen

 [ Description ]

 THistoryGrid to display history items for History++ plugin

 [ History ]

 1.4
 - Fixed bug when Select All, Delete causes crash

 1.3 ()
 + Fixed scrollbar! Now scrolling is much better
 + Added XML export
 + URL & File Highlighting
 - Fixed bug with changing System font in options, and TextAuthRequest
   doesn't get changed
 1.2
 1.1
 1.0 (xx.02.03) First version.

 [ Modifications ]

 * (07.03.2006) Added OnFilterData event and UpdateFilter to manually
   filter messages. Now when filtering, current selection isn't lost
   (when possible)
   
 * (01.03.2006) Added OnNameData event. Now you can supply your own
   user name for each event separately.

 * (29.05.2003) Selecting all and then deleting now works without
   crashing, just added one check at THistoryGrid.DeleteSelected

 * (31.03.2003) Scrolling now works perfectly! (if you ever can
   do this with such way of doing scroll)

 [ Known Issues ]
 * Some visual bugs when track-scrolling. See WMVScroll for details.
 * Not very good support of EmailExpress events (togeter
   with HistoryForm.pas)

 Copyright (c) Art Fedorov, 2003
-----------------------------------------------------------------------------}


unit HistoryGrid;

interface

{$DEFINE CUST_SB}
{$DEFINE PAGE_SIZE}
{$DEFINE RENDER_RICH}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ComCtrls, CommCtrl,
  TntSysUtils, TntWindows, TntControls,TntGraphics, {TntComCtrls,} Menus, TntMenus, StdCtrls,
  Math, mmsystem,
  hpp_global, hpp_contacts, hpp_itemprocess, hpp_events, hpp_eventfilters,
  hpp_richedit, hpp_richedit_ole,
  Contnrs,
  VertSB,
  RichEdit, ShellAPI;

type

  TMsgFilter = record
    nmhdr: NMHdr;
    msg: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
  end;

  TMouseMoveKey = (mmkControl,mmkLButton,mmkMButton,mmkRButton,mmkShift);
  TMouseMoveKeys = set of TMouseMoveKey;

  TSaveFormat = (sfHTML,sfXML,sfRTF,sfUnicode,sfText);
  TGridState = (gsIdle,gsDelete,gsSearch,gsSearchItem,gsLoad,gsSave,gsInline,gsClose);

  TXMLItem = record
    Protocol: string;
    Time: string;
    Date: string;
    Mes: string;
    Url: string;
    FileName: string;
    Contact: string;
    From: string;
    EventType: string;
    ID: string;
  end;

  TOnSelect = procedure(Sender: TObject; Item, OldItem: Integer) of object;
  TOnBookmarkClick = procedure(Sender: TObject; Item: Integer) of object;
  TGetItemData = procedure(Sender: TObject; Index: Integer; var Item: THistoryItem) of object;
  TGetNameData = procedure(Sender: TObject; Index: Integer; var Name: WideString) of object;
  TGetXMLData = procedure(Sender: TObject; Index: Integer; var Item: TXMLItem) of object;
  TOnPopup = TNotifyEvent;
  TOnTranslateTime = procedure(Sender: TObject; Time: DWord; var Text: WideString) of object;
  TOnProgress = procedure(Sender: TObject; Position, Max: Integer) of object;
  TOnSearchFinished = procedure(Sender: TObject; Text: WideString; Found: Boolean) of object;
  TOnSearched = TOnSearchFinished;
  TOnItemDelete = procedure(Sender: TObject; Index: Integer) of object;
  TOnState = procedure(Sender: TObject; State: TGridState) of object;
  TOnItemFilter = procedure(Sender: TObject; Index: Integer; var Show: Boolean) of object;
  TOnChar = procedure(Sender: TObject; var Char: WideChar; Shift: TShiftState) of object;
  TOnRTLChange = procedure(Sender: TObject; BiDiMode: TBiDiMode) of object;
  TOnProcessInlineChange = procedure(Sender: TObject; Enabled: boolean) of object;
  TOnProcessRichText = procedure(Sender: TObject; Handle: THandle; Item: Integer) of object;
  TOnSearchItem = procedure(Sender: TObject; Item: Integer; ID: Integer; var Found: Boolean) of object;
  TOnSelectRequest = TNotifyEvent;
  TOnFilterChange = TNotifyEvent;

  THPPRichEdit = class(TRichEdit)
  private
    FCodepage: Cardinal;
    procedure SetAutoKeyboard(Enabled: Boolean);
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMLangChange(var Message: TMessage); message WM_INPUTLANGCHANGE;
    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMKeyDown(var Message: TWMKey); message WM_KEYDOWN;
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    property Codepage: Cardinal read FCodepage write FCodepage default CP_ACP;
  end;

  THistoryGrid = class;

  {IFDEF RENDER_RICH}
  TUrlEvent = procedure(Sender: TObject; Item: Integer; Url: String) of object;
  {ENDIF}
  TOnShowIcons = procedure;
  TOnTextFormatting = procedure(Value: Boolean);

  TGridHitTest = (ghtItem, ghtHeader, ghtText, ghtLink, ghtButton, ghtSession, ghtSessHideButton, ghtSessShowButton, ghtBookmark);
  TGridHitTests = set of TGridHitTest;

  TItemOption = record
    MessageType: TMessageTypes;
    textFont: TFont;
    textColor: TColor;
  end;
  TItemOptions = array of TItemOption;

  TGridOptions = class(TPersistent)
  private
    FLocks: Integer;
    Changed: Integer;
    Grids: array of THistoryGrid;

    FColorDivider: TColor;
    FColorSelectedText: TColor;
    FColorSelected: TColor;
    FColorSessHeader: TColor;
    FColorBackground: TColor;

    FFontProfile: TFont;
    FFontContact: TFont;
    FFontIncomingTimestamp: TFont;
    FFontOutgoingTimestamp: TFont;
    FFontSessHeader: TFont;
    FFontMessage: TFont;

    FItemOptions: TItemOptions;

    //FIconMessage: TIcon;
    //FIconFile: TIcon;
    //FIconUrl: TIcon;
    //FIconOther: TIcon;

    FRTLEnabled: Boolean;
    //FShowAvatars: Boolean;
    FShowIcons: Boolean;
    FOnShowIcons: TOnShowIcons;

    FBBCodesEnabled: Boolean;
    FSmileysEnabled: Boolean;
    FMathModuleEnabled: Boolean;
    FRawRTFEnabled: Boolean;
    FAvatarsHistoryEnabled: Boolean;

    FTextFormatting: Boolean;
    FOnTextFormatting: TOnTextFormatting;

    FClipCopyTextFormat: WideString;
    FClipCopyFormat: WideString;
    FReplyQuotedFormat: WideString;
    FReplyQuotedTextFormat: WideString;
    FSelectionFormat: WideString;

    FOpenDetailsMode: Boolean;

    FForceProfileName: Boolean;
    FProfileName: WideString;
    FDateTimeFormat: String;

    procedure SetColorDivider(const Value: TColor);
    procedure SetColorSelectedText(const Value: TColor);
    procedure SetColorSelected(const Value: TColor);
    procedure SetColorSessHeader(const Value: TColor);
    procedure SetColorBackground(const Value: TColor);

    procedure SetFontContact(const Value: TFont);
    procedure SetFontProfile(const Value: TFont);
    procedure SetFontIncomingTimestamp(const Value: TFont);
    procedure SetFontOutgoingTimestamp(const Value: TFont);
    procedure SetFontSessHeader(const Value: TFont);
    procedure SetFontMessage(const Value: TFont);

    //procedure SetIconOther(const Value: TIcon);
    //procedure SetIconFile(const Value: TIcon);
    //procedure SetIconURL(const Value: TIcon);
    //procedure SetIconMessage(const Value: TIcon);

    procedure SetRTLEnabled(const Value: Boolean);
    procedure SetShowIcons(const Value: Boolean);
    //procedure SetShowAvatars(const Value: Boolean);

    procedure SetBBCodesEnabled(const Value: Boolean);
    procedure SetSmileysEnabled(const Value: Boolean);
    procedure SetMathModuleEnabled(const Value: Boolean);
    procedure SetRawRTFEnabled(const Value: Boolean);
    procedure SetAvatarsHistoryEnabled(const Value: Boolean);
    procedure SetProfileName(const Value: WideString);
    procedure SetTextFormatting(const Value: Boolean);

    function GetLocked: Boolean;
    procedure SetDateTimeFormat(const Value: String);
  protected
    procedure DoChange;
    procedure AddGrid(Grid: THistoryGrid);
    procedure DeleteGrid(Grid: THistoryGrid);
    procedure FontChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartChange;
    procedure EndChange(const Forced: Boolean = False);
    function AddItemOptions: integer;
    function GetItemOptions(Mes: TMessageTypes; out textFont: TFont; out textColor: TColor): integer;
    property OnShowIcons: TOnShowIcons read FOnShowIcons write FOnShowIcons;
    property OnTextFormatting: TOnTextFormatting read FOnTextFormatting write FOnTextFormatting;
  published
    property ClipCopyFormat: WideString read FClipCopyFormat write FClipCopyFormat;
    property ClipCopyTextFormat: WideString read FClipCopyTextFormat write FClipCopyTextFormat;
    property ReplyQuotedFormat: WideString read FReplyQuotedFormat write FReplyQuotedFormat;
    property ReplyQuotedTextFormat: WideString read FReplyQuotedTextFormat write FReplyQuotedTextFormat;
    property SelectionFormat: WideString read FSelectionFormat write FSelectionFormat; 

    property Locked: Boolean read GetLocked;

    //property IconOther: TIcon read FIconOther write SetIconOther;
    //property IconFile: TIcon read FIconFile write SetIconFile;
    //property IconUrl: TIcon read FIconUrl write SetIconUrl;
    //property IconMessage: TIcon read FIconMessage write SetIconMessage;

    //property IconHistory: hIcon read FIconHistory write FIconHistory;
    //property IconSearch: hIcon read FIconSearch write FIconSearch;

    property ColorDivider: TColor read FColorDivider write SetColorDivider;
    property ColorSelectedText: TColor read FColorSelectedText write SetColorSelectedText;
    property ColorSelected: TColor read FColorSelected write SetColorSelected;
    property ColorSessHeader: TColor read FColorSessHeader write SetColorSessHeader;
    property ColorBackground: TColor read FColorBackground write SetColorBackground;

    property FontProfile: TFont read FFontProfile write SetFontProfile;
    property FontContact: TFont read FFontContact write SetFontContact;
    property FontIncomingTimestamp: TFont read FFontIncomingTimestamp write SetFontIncomingTimestamp;
    property FontOutgoingTimestamp: TFont read FFontOutgoingTimestamp write SetFontOutgoingTimestamp;
    property FontSessHeader: TFont read FFontSessHeader write SetFontSessHeader;
    property FontMessage: TFont read FFontMessage write SetFontMessage;

    property ItemOptions: TItemOptions read FItemOptions write FItemOptions;

    property RTLEnabled: Boolean read FRTLEnabled write SetRTLEnabled;
    property ShowIcons: Boolean read FShowIcons write SetShowIcons;
    //property ShowAvatars: Boolean read FShowAvatars write SetShowAvatars;

    property BBCodesEnabled: Boolean read FBBCodesEnabled write SetBBCodesEnabled;
    property SmileysEnabled: Boolean read FSmileysEnabled write SetSmileysEnabled;
    property MathModuleEnabled: Boolean read FMathModuleEnabled write SetMathModuleEnabled;
    property RawRTFEnabled: Boolean read FRawRTFEnabled write SetRawRTFEnabled;
    property AvatarsHistoryEnabled: Boolean read FAvatarsHistoryEnabled write SetAvatarsHistoryEnabled;

    property OpenDetailsMode: Boolean read FOpenDetailsMode write FOpenDetailsMode;
    property ForceProfileName: Boolean read FForceProfileName;
    property ProfileName: WideString read FProfileName write SetProfileName;

    property DateTimeFormat: String read FDateTimeFormat write SetDateTimeFormat;
    property TextFormatting: Boolean read FTextFormatting write SetTextFormatting;
  end;


  TRichItem = record
    Rich: THPPRichEdit;
    Bitmap: TBitmap;
    BitmapDrawn: Boolean;
    Height: Integer;
    GridItem: Integer;
  end;
  PRichItem = ^TRichItem;

  TRichCache = class(TObject)
  private
    LogX,LogY: Integer;
    RichEventMasks: DWord;
    Grid: THistoryGrid;
    FRichWidth: Integer;
    FRichHeight: Integer;

    function FindGridItem(GridItem: Integer): Integer;
    procedure PaintRichToBitmap(Item: PRichItem);
    procedure ApplyItemToRich(Item: PRichItem);

    procedure OnRichResize(Sender: TObject; Rect: TRect);
  protected
    Items: array of PRichItem;
    procedure MoveToTop(Index: Integer);
    procedure SetWidth(const Value: Integer);
  public
    constructor Create(AGrid: THistoryGrid); overload;
    destructor Destroy; override;

    procedure ResetAllItems;
    procedure ResetItems(GridItems: array of Integer);
    procedure ResetItem(GridItem: Integer);
    property Width: Integer read FRichWidth write SetWidth;
    procedure SetHandles;

    procedure WorkOutItemAdded(GridItem: Integer);
    procedure WorkOutItemDeleted(GridItem: Integer);

    function RequestItem(GridItem: Integer): PRichItem;
    function CalcItemHeight(GridItem: Integer): Integer;
    function GetItemRich(GridItem: Integer): THPPRichEdit;
    function GetItemRichBitmap(GridItem: Integer): TBitmap;
  end;

  TGridUpdate = (guSize, guAllocate, guFilter);
  TGridUpdates = set of TGridUpdate;

  THistoryGrid = class(TScrollingWinControl)
  private
    SessHeaderHeight: Integer;
    CHeaderHeight, PHeaderheight: Integer;
    IsCanvasClean: Boolean;
    ProgressRect: TRect;
    BarAdjusted: Boolean;
    Allocated: Boolean;
    LockCount: Integer;
    ClipRect: TRect;
    ShowProgress: Boolean;
    ProgressPercent: Byte;
    SearchPattern: WideString;
    LastKeyDown: DWord;
    GridUpdates: TGridUpdates;
    VLineScrollSize: Integer;
    FSelItems, TempSelItems: array of Integer;
    FSelected: Integer;
    FGetItemData: TGetItemData;
    FGetNameData: TGetNameData;
    FPadding: Integer;
    FItems: array of THistoryItem;
    FClient: TBitmap;
    FCanvas: TCanvas;
    FContact: Integer;  // cose THandle defined as integer in m_globaldef
    FProtocol: String;
    FLoadedCount: Integer;
    FContactName: WideString;
    FProfileName: WideString;
    FOnPopup: TOnPopup;
    FTranslateTime: TOnTranslateTime;
    FFilter: TMessageTypes;
    FDblClick: TNotifyEvent;
    FSearchFinished: TOnSearchFinished;
    FOnProcessRichText: TOnProcessRichText;
    FItemDelete: TOnItemDelete;
    FState: TGridState;
    FControlID: Cardinal;
    FHideSelection: Boolean;
    FGridNotFocused: Boolean;

    FTxtNoItems: WideString;
    FTxtStartup: WideString;
    FTxtNoSuch: WideString;

    FTxtFullLog: WideString;
    FTxtPartLog: WideString;
    FTxtHistExport: WideString;
    FTxtGenHist1: WideString;
    FTxtGenHist2: WideString;
    FTxtSessions: WideString;

    FOnState: TOnState;
    FReversed: Boolean;
    FReversedHeader: Boolean;
    FOptions: TGridOptions;
    FMultiSelect: Boolean;
    FOnSelect: TOnSelect;
    FOnFilterChange: TOnFilterChange;
    FGetXMLData: TGetXMLData;
    FOnItemFilter: TOnItemFilter;
    {$IFDEF CUST_SB}
    FVertScrollBar: TVertScrollBar;
    {$ENDIF}
    {$IFDEF RENDER_RICH}
    FRichCache: TRichCache;
    FOnUrlClick: TUrlEvent;
    FOnUrlPopup: TUrlEvent;
    FRich: THPPRichEdit;
    FRichInline: THPPRichEdit;
    FRichSave: THPPRichEdit;
    FRichSaveItem: THPPRichEdit;
    FRichSaveOLECB: TRichEditOleCallback;

    FOnInlineKeyDown: TKeyEvent;
    FOnInlineKeyUp: TKeyEvent;
    FOnInlinePopup: TOnPopup;

    FRichHeight: Integer;
    FRichParamsSet: Boolean;
    FOnSearchItem: TOnSearchItem;

    FRTLMode: TRTLMode;
    FOnRTLChange: TOnRTLChange;

    TopItemOffset: Integer;
    MaxSBPos: Integer;
    FShowHeaders: Boolean;
    FCodepage: Cardinal;
    FOnChar: TOnChar;
    WindowPrePainting: Boolean;
    WindowPrePainted: Boolean;
    FExpandHeaders: Boolean;
    FOnProcessInlineChange: TOnProcessInlineChange;

    FOnBookmarkClick: TOnBookmarkClick;
    FShowBookmarks: Boolean;
    FGroupLinked: Boolean;
    FShowBottomAligned: Boolean;
    FOnSelectRequest: TOnSelectRequest;
    FSavedKeyMessage: TWMKey;
    FBorderStyle: TBorderStyle;

    FHintRect: TRect;
    function GetHint: WideString;
    procedure SetHint(const Value: WideString);
    function IsHintStored: Boolean;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;

    procedure SetBorderStyle(Value: TBorderStyle);

    procedure SetCodepage(const Value: Cardinal);
    procedure SetShowHeaders(const Value: Boolean);
    function GetIdx(Index: Integer): Integer;
    // Item offset support
    //procedure SetScrollBar
    procedure ScrollGridBy(Offset: Integer; Update: Boolean = True);
    procedure SetSBPos(Position: Integer);
    // FRich events
    //procedure OnRichResize(Sender: TObject; Rect: TRect);
    //procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    {$ENDIF}
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMRButtonUp(var Message: TWMRButtonDown); message WM_RBUTTONUP;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClick(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure CNVScroll(var Message: TWMVScroll); message CN_VSCROLL;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMSysKeyUp(var Message: TWMSysKeyUp); message WM_SYSKEYUP;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure EMSetSel(var Message: TMessage); message EM_SETSEL;
    procedure SetContolID(const Value: Cardinal);
    function SendMsgFilterMessage(var Message: TMessage): Longint;
    function GetCount: Integer;
    procedure SetContact(const Value: Integer);
    procedure SetPadding(Value: Integer);
    procedure SetSelected(const Value: Integer);
    procedure AddSelected(Item: Integer);
    procedure RemoveSelected(Item: Integer);
    procedure MakeSelectedTo(Item: Integer);
    function GetSelCount: Integer;
    procedure SetFilter(const Value: TMessageTypes);
    function GetTime(Time: DWord): WideString;
    function GetItems(Index: Integer): THistoryItem;
    function IsMatched(Index: Integer): Boolean;
    function IsUnknown(Index: Integer): Boolean;
    procedure WriteString(fs: TFileStream; Text: String);
    procedure WriteWideString(fs: TFileStream; Text: WideString);
    procedure CheckBusy;
    function GetSelItems(Index: Integer): Integer;
    procedure SetSelItems(Index: Integer; Item: integer);
    procedure SetState(const Value: TGridState);
    procedure SetReversed(const Value: Boolean);
    procedure SetReversedHeader(const Value: Boolean);
    procedure AdjustScrollBar;
    procedure SetOptions(const Value: TGridOptions);
    procedure SetMultiSelect(const Value: Boolean);
    {$IFDEF CUST_SB}
    procedure SetVertScrollBar(const Value: TVertScrollBar);
    {$ENDIF}
    function GetHitTests(X,Y: Integer): TGridHitTests;
    function GetLinkAtPoint(X,Y: Integer): WideString;
    {$IFDEF RENDER_RICH}
    function GetRichEditRect(Item: Integer; DontClipTop: Boolean = False): TRect;
    {$ENDIF}
    procedure SetRTLMode(const Value: TRTLMode);
    procedure SetExpandHeaders(const Value: Boolean);
    procedure SetProcessInline(const Value: Boolean);
    function GetBookmarked(Index: Integer): Boolean;
    procedure SetBookmarked(Index: Integer; const Value: Boolean);
    procedure SetGroupLinked(const Value: Boolean);
    procedure SetHideSelection(const Value: Boolean);

    // FRichInline events
    {procedure OnInlinePopup(Sender: TObject);
    procedure OnInlineCopyClick(Sender: TObject);
    procedure OnInlineCopyAllClick(Sender: TObject);
    procedure OnInlineSelectAllClick(Sender: TObject);
    procedure OnInlineToggleProcessingClick(Sender: TObject);
    procedure OnInlineCancelClick(Sender: TObject);}

    procedure OnInlineOnExit(Sender: TObject);
    procedure OnInlineOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnInlineOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnInlineOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnInlineOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    function GetProfileName: WideString;

  protected
    DownHitTests: TGridHitTests;
    HintHitTests: TGridHitTests;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateParams(var Params: TCreateParams); override;
    //procedure WndProc(var Message: TMessage); override;
    property Canvas: TCanvas read FCanvas;
    procedure Paint;
    procedure PaintHeader(Index: Integer; ItemRect: TRect);
    procedure PaintItem(Index: Integer; ItemRect: TRect);
    procedure DrawProgress;
    procedure DrawMessage(Text: WideString);
    procedure LoadItem(Item: Integer; LoadHeight: Boolean = True; Reload: Boolean = False);
    procedure DoOptionsChanged;
    procedure DoKeyDown(var Key: Word; ShiftState: TShiftState);
    procedure DoKeyUp(var Key: Word; ShiftState: TShiftState);
    procedure DoChar(var Ch: WideChar; ShiftState: TShiftState);
    procedure DoLButtonDblClick(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoLButtonDown(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoLButtonUp(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoMouseMove(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoRButtonDown(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoRButtonUp(X,Y: Integer; Keys: TMouseMoveKeys);
    //procedure DoUrlMouseMove(Url: WideString);
    procedure DoProgress(Position,Max: Integer);
    function CalcItemHeight(Item: Integer): Integer;
    procedure ScrollBy(DeltaX, DeltaY: Integer);
    procedure DeleteItem(Item: Integer);
    procedure SaveStart(Stream: TFileStream; SaveFormat: TSaveFormat; Caption: WideString);
    procedure SaveItem(Stream: TFileStream; Item: Integer; SaveFormat: TSaveFormat);
    procedure SaveEnd(Stream: TFileStream; SaveFormat: TSaveFormat);

    procedure GridUpdateSize;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property Contact: Integer read FContact write SetContact;
    property Protocol: String read FProtocol write FProtocol;
    property LoadedCount: Integer read FLoadedCount;
    procedure Allocate(ItemsCount: Integer; Scroll: Boolean = True);
    property Selected: Integer read FSelected write SetSelected;
    property SelCount: Integer read GetSelCount;
    function FindItemAt(x,y: Integer; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint): Integer; overload;
    function FindItemAt(x,y: Integer): Integer; overload;
    function GetItemRect(Item: Integer): TRect;
    function IsSelected(Item: Integer): Boolean;
    procedure MakeVisible(Item: Integer);
    procedure MakeSelected(Value: Integer);
    procedure BeginUpdate;
    procedure EndUpdate;
    function IsVisible(Item: Integer; Partially: Boolean = True): Boolean;
    procedure Delete(Item: Integer);
    procedure DeleteSelected;
    procedure DeleteAll;
    property Items[Index: Integer]: THistoryItem read GetItems;
    property Bookmarked[Index: Integer]: Boolean read GetBookmarked write SetBookmarked;
    property SelItems[Index: Integer]: Integer read GetSelItems write SetSelItems;
    function Search(Text: WideString; CaseSensitive: Boolean; FromStart: Boolean = False; SearchAll: Boolean = False; FromNext: Boolean = False; Down: Boolean = True): Integer;
    function SearchItem(ItemID: Integer): Integer;
    procedure AddItem;
    procedure SaveSelected(FileName: String; SaveFormat: TSaveFormat);
    procedure SaveAll(FileName: String; SaveFormat: TSaveFormat);
    function GetNext(Item: Integer; Force: Boolean = False): Integer;
    function GetDown(Item: Integer): Integer;
    function GetPrev(Item: Integer; Force: Boolean = False): Integer;
    function GetUp(Item: Integer): Integer;
    function GetTopItem: Integer;
    function GetBottomItem: Integer;
    property State: TGridState read FState write SetState;
    function GetFirstVisible: Integer;
    procedure UpdateFilter;

    procedure EditInline(Item: Integer);
    procedure CancelInline(DoSetFocus: boolean = true);
    property InlineRichEdit: THPPRichEdit read FRichInline write FRichInline;
    property RichEdit: THPPRichEdit read FRich write FRich;

    property Options: TGridOptions read FOptions write SetOptions;
    property HotString: WideString read SearchPattern;
    property RTLMode: TRTLMode read FRTLMode write SetRTLMode;

    procedure CalcAllHeight;
    procedure MakeTopmost(Item: Integer);
    procedure ScrollToBottom;
    procedure ResetItem(Item: Integer);

    procedure IntFormatItem(Item: Integer; var Tokens: TWideStrArray; var SpecialTokens: TIntArray);
    procedure PrePaintWindow;

    property Codepage: Cardinal read FCodepage write SetCodepage;
    property Filter: TMessageTypes read FFilter write SetFilter;

    property ControlID: Cardinal read FControlID write SetContolID;
  published
    procedure SetRichRTL(RTL: Boolean; RichEdit: THPPRichEdit; ProcessTag: Boolean = true);
    function GetItemRTL(Item: Integer): Boolean;

    //procedure CopyToClipSelected(const Format: WideString; ACodepage: Cardinal = CP_ACP);
    procedure ApplyItemToRich(Item: Integer; RichEdit: THPPRichEdit = nil; UseSelection: Boolean = True; ForceInline: Boolean = False);

    function FormatItem(Item: Integer; Format: WideString): WideString;
    function FormatItems(ItemList: array of Integer; Format: WideString): WideString;
    function FormatSelected(const Format: WideString): WideString;
    procedure MakeRangeSelected(FromItem,ToItem: Integer);

    property ShowBottomAligned: Boolean read FShowBottomAligned write FShowBottomAligned;
    property ShowBookmarks: Boolean read FShowBookmarks write FShowBookmarks;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
    property ShowHeaders: Boolean read FShowHeaders write SetShowHeaders;
    property ExpandHeaders: Boolean read FExpandHeaders write SetExpandHeaders default True;
    property GroupLinked: Boolean read FGroupLinked write SetGroupLinked default False;
    property ProcessInline: Boolean write SetProcessInline;
    property TxtStartup: WideString read FTxtStartup write FTxtStartup;
    property TxtNoItems: WideString read FTxtNoItems write FTxtNoItems;
    property TxtNoSuch: WideString read FTxtNoSuch write FTxtNoSuch;
    property TxtFullLog: WideString read FTxtFullLog write FTxtFullLog;
    property TxtPartLog: WideString read FTxtPartLog write FTxtPartLog;
    property TxtHistExport: WideString read FTxtHistExport write FTxtHistExport;
    property TxtGenHist1: WideString read FTxtGenHist1 write FTxtGenHist1;
    property TxtGenHist2: WideString read FTxtGenHist2 write FTxtGenHist2;
    property TxtSessions: WideString read FTxtSessions write FTxtSessions;
    //property Filter: TMessageTypes read FFilter write SetFilter;
    property ProfileName: WideString read GetProfileName write FProfileName;
    property ContactName: WideString read FContactName write FContactName;
    property OnDblClick: TNotifyEvent read FDblClick write FDblClick;
    property OnItemData: TGetItemData read FGetItemData write FGetItemData;
    property OnNameData: TGetNameData read FGetNameData write FGetNameData;
    property OnPopup: TOnPopup read FOnPopup write FOnPopup;
    property OnTranslateTime: TOnTranslateTime read FTranslateTime write FTranslateTime;
    property OnSearchFinished: TOnSearchFinished read FSearchFinished write FSearchFinished;
    property OnItemDelete: TOnItemDelete read FItemDelete write FItemDelete;
    property OnKeyDown;
    property OnKeyUp;
    property OnInlineKeyDown: TKeyEvent read FOnInlineKeyDown write FOnInlineKeyDown;
    property OnInlineKeyUp: TKeyEvent read FOnInlineKeyUp write FOnInlineKeyUp;
    property OnInlinePopup: TOnPopup read FOnInlinePopup write FOnInlinePopup;
    property OnProcessInlineChange: TOnProcessInlineChange read FOnProcessInlineChange write FOnProcessInlineChange;
    property OnChar: TOnChar read FOnChar write FOnChar;
    property OnState: TOnState read FOnState write FOnState;
    property OnSelect: TOnSelect read FOnSelect write FOnSelect;
    property OnXMLData: TGetXMLData read FGetXMLData write FGetXMLData;
    property OnRTLChange: TOnRTLChange read FOnRTLChange write FOnRTLChange;
    {IFDEF RENDER_RICH}
    property OnUrlClick: TUrlEvent read FOnUrlClick write FOnUrlClick;
    property OnUrlPopup: TUrlEvent read FOnUrlPopup write FOnUrlPopup;
    {ENDIF}
    property OnBookmarkClick: TOnBookmarkClick read FOnBookmarkClick write FOnBookmarkClick;
    property OnItemFilter: TOnItemFilter read FOnItemFilter write FOnItemFilter;
    property OnProcessRichText: TOnProcessRichText read FOnProcessRichText write FOnProcessRichText;
    property OnSearchItem: TOnSearchItem read FOnSearchItem write FOnSearchItem;
    property OnSelectRequest: TOnSelectRequest read FOnSelectRequest write FOnSelectRequest;
    property OnFilterChange: TOnFilterChange read FOnFilterChange write FOnFilterChange;

    property Reversed: Boolean read FReversed write SetReversed;
    property ReversedHeader: Boolean read FReversedHeader write SetReversedHeader;
    property TopItem: integer read GetTopItem;
    property BottomItem: integer read GetBottomItem;
    property HideSelection: Boolean read FHideSelection write SetHideSelection default False;
    property Align;
    property Anchors;
    property TabStop;
    property Font;
    property Color;
    property ParentColor;
    property BiDiMode;
    property ParentBiDiMode;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property BorderWidth;
    property Ctl3D;
    property ParentCtl3D;
    property Padding: Integer read FPadding write SetPadding;
    {$IFDEF CUST_SB}
    property VertScrollBar: TVertScrollBar read FVertScrollBar write SetVertScrollBar;
    {$ENDIF}
    property Hint: WideString read GetHint write SetHint stored IsHintStored;
    property ShowHint;
  end;

procedure Register;
function IsRichEdit20Available: Boolean;

implementation

{$I compilers.inc}

uses
  hpp_options, hpp_arrays, hpp_strparser;

const
  HtmlStop = [#0,#10,#13,'<','>',' '];
  EM_SETZOOM = WM_USER + 225;

var
  FRichEdit10Module: THandle = 0;
  FRichEdit20Module: THandle = 0;

function IsRichEdit20Available: Boolean;
const
  RICHED20_DLL = 'RICHED20.DLL';
begin
  if FRichEdit20Module = 0 then
    FRichEdit20Module := Tnt_LoadLibraryW(RICHED20_DLL);
  Result := FRichEdit20Module <> 0;
end;

function UrlHighlightHtml(Text: String): String;
var
  UrlStart, UrlCent, UrlEnd: Integer;
  UrlStr: String;
begin
  Result := Text;
  UrlCent := AnsiPos('://',Text);
  while UrlCent > 0 do begin
    Text[UrlCent] := '!';
    UrlStart := UrlCent;
    UrlEnd := UrlCent+2;
    while UrlStart > 0 do begin
      if (Text[UrlStart-1] in HtmlStop) then break;
      Dec(UrlStart);
    end;
    while UrlEnd < Length(Text) do begin
      if (Text[UrlEnd+1] in HtmlStop) then break;
      Inc(UrlEnd);
    end;
    if (UrlEnd-2-UrlCent > 0) and (UrlCent-UrlStart-1 > 0) then begin
      UrlStr := '<a id=url href="'+Copy(Result,UrlStart,UrlEnd-UrlStart+1)+'">';
      Insert(UrlStr,Result,UrlStart);
      Insert('</a>',Result,UrlEnd+Length(UrlStr)+1);
      UrlStr := StringReplace(UrlStr,'://','!//',[rfReplaceAll]);
      Insert(UrlStr,Text,UrlStart);
      Insert('</a>',Text,UrlEnd+Length(UrlStr)+1);
    end;
    UrlCent := AnsiPos('://',Text);
  end;
end;

function MakeTextHtmled(T: String): String;
begin
  Result := t;
  // change & to &amp;
  Result := StringReplace(Result,'&','&amp;',[rfReplaceAll]);
  // of course change tag brackets
  Result := StringReplace(Result,'>','&gt;',[rfReplaceAll]);
  Result := StringReplace(Result,'<','&lt;',[rfReplaceAll]);
  // replace tabs also
  Result := StringReplace(Result,#9,' ',[rfReplaceAll]);
  // make line feeds
  Result := StringReplace(Result,#13#10,'<br>',[rfReplaceAll]);
end;

function PointInRect(Pnt: TPoint; Rct: TRect): Boolean;
begin
Result := (Pnt.x >= Rct.Left) and (Pnt.x <= Rct.Right)
and (Pnt.y >= Rct.Top) and (Pnt.y <= Rct.Bottom);
end;

function DoRectsIntersect(R1,R2: TRect): Boolean;
begin
Result := ((Max(R1.Left,R2.Left) < Min(R1.Right,R2.Right)) and
(Max(R1.Top,R2.Top) < Min(R1.Bottom,R2.Bottom)));
end;

function TranslateKeys(const Keys: Integer): TMouseMoveKeys;
begin
Result := [];
if Keys and MK_CONTROL > 0 then Result := Result+[mmkControl];
if Keys and MK_LBUTTON > 0 then Result := Result+[mmkLButton];
if Keys and MK_MBUTTON > 0 then Result := Result+[mmkMButton];
if Keys and MK_RBUTTON > 0 then Result := Result+[mmkRButton];
if Keys and MK_SHIFT > 0 then Result := Result+[mmkShift];
end;

function NotZero(x:dword):dword;//used that array doesn't store 0 for already loaded data
begin
if x = 0 then
  Result:=1
else
  Result:=x;
end;

procedure Register;
begin
  RegisterComponents('History++', [THistoryGrid]);
  RegisterComponents('History++', [THPPRichedit]);
end;

{ THistoryGrid }

constructor THistoryGrid.Create(AOwner: TComponent);
const
  GridStyle = [csCaptureMouse, csClickEvents, csDoubleClicks, csReflector, csOpaque, csNeedsBorderPaint];
var
  dc: HDC;
  LogY: Integer;
begin
  inherited;
  ShowHint := True;
  HintHitTests := [];

  {$IFDEF RENDER_RICH}
  FRichCache := TRichCache.Create(Self);

  {tmp
  FRich := TRichEdit.Create(Self);
  FRich.Name := 'OrgFRich';
  FRich.Visible := False;
  // just a dirty hack to workaround problem with
  // SmileyAdd making richedit visible all the time
  FRich.Height := 1000;
  FRich.Top := -1001;
  // </hack>

  // Don't give him grid as parent, or we'll have
  // wierd problems with scroll bar
  FRich.Parent := nil;
  // on 9x wrong sizing
  //FRich.PlainText := True;
  FRich.WordWrap := True;
  FRich.BorderStyle := bsNone;
  FRich.OnResizeRequest := OnRichResize;
  FRich.OnMouseMove := OnMouseMove;
  // we cann't set specific params to FRich because
  // it's handle is unknown yet. We do it in WMSize, but
  // to prevent setting it multiple times
  // we have this variable
  }
  FRichParamsSet := False;

  // Ok, now inlined richedit
  FRichInline := THPPRichEdit.Create(Self);
  FRichInline.Top := -100;
  FRichInline.Name := 'FRichInline';
  FRichInline.Visible := False;
  //FRichInline.Parent := Self.Parent;
  //FRichInline.PlainText := True;
  FRichInline.WordWrap := True;
  FRichInline.BorderStyle := bsNone;
  FRichInline.ReadOnly := True;

  FRichInline.ScrollBars := ssVertical;
  FRichInline.HideScrollBars := True;

  FRichInline.OnExit := OnInlineOnExit;
  FRichInline.OnKeyDown := OnInlineOnKeyDown;
  FRichInline.OnKeyUp := OnInlineOnKeyUp;
  FRichInline.OnMouseDown := OnInlineOnMouseDown;
  FRichInline.OnMouseUp := OnInlineOnMouseUp;

  FRichInline.Brush.Style := bsClear;

  {$ENDIF}
  FCodepage := CP_ACP;
  //FRTLMode := hppRTLDefault;

  CHeaderHeight := -1;
  PHeaderHeight := -1;
  FExpandHeaders := False;

  TabStop := True;
  MultiSelect := True;

  TxtStartup := 'Starting up...';
  TxtNoItems := 'History is empty';
  TxtNoSuch  := 'No such items';
  TxtFullLog := 'Full History Log';
  TxtPartLog := 'Partial History Log';
  TxtHistExport := hppName+' export';
  TxtGenHist1 := '### (generated by '+hppName+' plugin)';
  TxtGenHist2 := '<h6>Generated by <b dir="ltr">'+hppName+'</b> Plugin</h6>';
  TxtSessions := 'Conversation started at %s';

  Reversed := False;
  ReversedHeader := False;

  FState := gsIdle;

  IsCanvasClean := False;

  BarAdjusted := False;
  Allocated := False;

  ShowBottomAligned := False;

  ProgressPercent := 255;
  ShowProgress := False;

  if NewStyleControls then
    ControlStyle := GridStyle
  else
    ControlStyle := GridStyle + [csFramed];

  LockCount := 0;

  // fill all events including AlwaysExclude
  FFilter := GenerateEvents(FM_EXCLUDE,[])+AlwaysExclude;

  FSelected := -1;
  FContact := 0;
  FProtocol := '';
  FPadding := 4;
  FShowBookmarks := True;

  FClient := TBitmap.Create;
  FClient.Width := 1;
  FClient.Height := 1;

  FCanvas := FClient.Canvas;
  FCanvas.Font.Name := 'MS Shell Dlg';

  {$IFDEF CUST_SB}
  FVertScrollBar := TVertScrollBar.Create(Self,sbVertical);
  {$ENDIF}

  // get line scroll size depending on current dpi
  // default is 5 lines (13px usually) for standard 96dpi
  dc := GetDC(0);
  LogY := GetDeviceCaps(dc, LOGPIXELSY);
  ReleaseDC(0,dc);
  VLineScrollSize := MulDiv(LogY,13*5,96);

  FBorderStyle := bsSingle;

  FHideSelection := False;
  FGridNotFocused := True;

  FControlID := 0;
end;

destructor THistoryGrid.Destroy;
begin
  FState := gsClose;
  {$IFDEF CUST_SB}
  VertScrollBar.Free;
  {$ENDIF}
  {$IFDEF RENDER_RICH}
  // it gets deleted autmagically because FRich.Owner = Self
  // FRich.Free;
  FRichCache.Free;
  {$ENDIF}
  if Assigned(Options) then
    Options.DeleteGrid(Self);
  FClient.Free;
  Finalize(FItems);
  inherited;
end;

function THistoryGrid.IsHintStored: Boolean;
begin
  Result := TntControl_IsHintStored(Self)
end;

function THistoryGrid.GetHint: WideString;
begin
  Result := TntControl_GetHint(Self)
end;

procedure THistoryGrid.SetHint(const Value: WideString);
begin
  TntControl_SetHint(Self, Value);
end;

procedure THistoryGrid.CMHintShow(var Message: TMessage);
var
  //ht: TGridHitTests;
  Item: Integer;
begin
  With TCMHintShow(Message).HintInfo^ do begin
    if ghtButton in HintHitTests then begin
      CursorRect := FHintRect;
      if ghtBookmark in HintHitTests then begin
        Item := FindItemAt(CursorPos);
        if FItems[Item].Bookmarked then
          Hint := TranslateWideW('Remove Bookmark')
        else
          Hint := TranslateWideW('Set Bookmark')
      end
      else if ghtSessHideButton in HintHitTests then
        Hint := TranslateWideW('Hide headers')
      else if ghtSessShowButton in HintHitTests then
        Hint := TranslateWideW('Show headers');
      Message.Result := 0
    end else
      Message.Result := 1;
  end;
  ProcessCMHintShowMsg(Message);
  inherited;
end;

function THistoryGrid.GetBookmarked(Index: Integer): Boolean;
begin
  Result := Items[Index].Bookmarked;
end;

function THistoryGrid.GetBottomItem: Integer;
begin
  if Reversed then
    Result := GetUp(-1)
  else
    Result := GetUp(Count);
end;

function THistoryGrid.GetCount: Integer;
begin
  Result := Length(FItems);
end;

procedure THistoryGrid.Allocate(ItemsCount: Integer; Scroll: Boolean = True);
var
  i: Integer;
  PrevCount: Integer;
begin
  PrevCount := Length(FItems);
  SetLength(FItems,ItemsCount);
  for i := PrevCount to ItemsCount-1 do begin
    FItems[i].Height := -1;
    FItems[i].MessageType := [mtUnknown];
    FRichCache.ResetItem(i);
    end;
  {$IFDEF CUST_SB}
    {$IFDEF PAGE_SIZE}
      //VertScrollBar.Visible := True;
      VertScrollBar.Range := ItemsCount + VertScrollBar.PageSize-1;
    {$ELSE}
      VertScrollBar.Range := ItemsCount+ClientHeight-1;
    {$ENDIF}
  {$ELSE}
    VertScrollBar.Range := ItemsCount+ClientHeight-1;
  {$ENDIF}
  BarAdjusted := False;
  Allocated := True;
  //if ItemsCount > 0 then SetSBPos(GetIdx(0));
  if Scroll then begin
    if Reversed xor ReversedHeader then
      SetSBPos(GetIdx(GetBottomItem))
    else
      SetSBPos(GetIdx(GetTopItem));
  end else
    AdjustScrollBar;
  Invalidate;
end;

procedure THistoryGrid.LoadItem(Item: Integer; LoadHeight: Boolean = True; Reload: Boolean = False);
begin
  if Reload or isUnknown(Item) then
    if Assigned(FGetItemData) then
      OnItemData(Self,Item,FItems[Item]);
  if LoadHeight then
    if FItems[Item].Height = -1 then
      FItems[Item].Height := CalcItemHeight(Item);
end;

procedure THistoryGrid.Paint;
var
  TextRect: TRect;
  ch,cw,idx,SumHeight: Integer;
begin
  if csDesigning in ComponentState then exit;

  if not Allocated then begin
    DrawMessage(TxtStartup);
    exit;
  end;
  if (Count = 0) then begin
    DrawMessage(TxtNoItems);
    exit;
  end;
  if ShowProgress then begin
    DrawProgress;
    exit;
  end;
  idx := GetFirstVisible;
  { REV
  idx := GetNext(VertScrollBar.Position-1);
  }
  if (idx = -1) then begin
    DrawMessage(TxtNoSuch);
    exit;
  end;

  if WindowPrePainted then begin
    WindowPrePainted := False;
    exit;
  end;

  SumHeight := -TopItemOffset;
  ch := ClientHeight;
  cw := ClientWidth;

  while (SumHeight < ch) and (idx >= 0) and (idx < Length(FItems)) do begin
    LoadItem(idx);
    TextRect := Rect(0,SumHeight,cw,SumHeight+FItems[idx].Height);
    if DoRectsIntersect(ClipRect,TextRect) then begin
      Canvas.Brush.Color := Options.ColorDivider;
      Canvas.FillRect(TextRect);
      if (FItems[idx].HasHeader) and (ShowHeaders) and (ExpandHeaders) then begin
        if Reversed xor ReversedHeader then begin
          TextRect := Rect(0,SumHeight,cw,SumHeight+SessHeaderHeight);
          PaintHeader(idx,TextRect);
          TextRect := Rect(0,SumHeight+SessHeaderHeight,cw,SumHeight+FItems[idx].Height);
        end
        else begin
          TextRect := Rect(0,SumHeight+FItems[idx].Height-SessHeaderHeight,cw,SumHeight+FItems[idx].Height);
          PaintHeader(idx,TextRect);
          TextRect := Rect(0,SumHeight,cw,SumHeight+FItems[idx].Height-SessHeaderHeight);
        end;
      end
      else
        TextRect := Rect(0,SumHeight,cw,SumHeight+FItems[idx].Height);
      PaintItem(idx,TextRect);
    end;
    Inc(SumHeight,FItems[idx].Height);
    {
    if Reversed then idx := GetPrev(idx)
    else idx := GetNext(idx);
    }
    idx := GetNext(idx);
    if idx = -1 then break;
    //Inc(idx);
  end;
  if SumHeight < ch then begin
    Canvas.Brush.Color := Options.ColorBackground;
    Canvas.FillRect(Rect(0,SumHeight,ClientWidth,ClientHeight));
  end;
end;

procedure THistoryGrid.PaintHeader(Index: Integer; ItemRect: TRect);
var
  text: WideString;
  RTL: Boolean;
  RIconOffset,IconOffset, IconTop: Integer;
  TextOffset: Integer;
  ArrIcon: Integer;
  //BackColor: TColor;
  //TextFont: TFont;
begin
  RTL := GetItemRTL(Index);
  //Options.GetItemOptions(FItems[Index].MessageType,textFont,BackColor);

  if not (RTL = ((Canvas.TextFlags and ETO_RTLREADING) > 0)) then begin
    if RTL then
      Canvas.TextFlags := Canvas.TextFlags or ETO_RTLREADING
    else
      Canvas.TextFlags := Canvas.TextFlags and not ETO_RTLREADING;
  end;

  // leave divider lines:
  //Inc(ItemRect.Top);
  Dec(ItemRect.Bottom,1);

  Canvas.Brush.Color := Options.ColorSessHeader;
  Canvas.FillRect(ItemRect);

  InflateRect(ItemRect,-3,-3);

  IconOffset := 0;
  RIconOffset := 0;
  IconTop := ((ItemRect.Bottom-ItemRect.Top-16) div 2);

  if (ShowHeaders) and (FItems[Index].HasHeader) and (ExpandHeaders)  then begin
    if RTL then
      DrawIconEx(Canvas.Handle,ItemRect.Left,ItemRect.Top + IconTop,
        hppIcons[HPP_ICON_SESS_HIDE].Handle,16,16,0,0,DI_NORMAL)
    else
      DrawIconEx(Canvas.Handle,ItemRect.Right-16,ItemRect.Top + IconTop,
        hppIcons[HPP_ICON_SESS_HIDE].Handle,16,16,0,0,DI_NORMAL);
    Inc(RIconOffset,16 + Padding);
  end;

  if hppIcons[HPP_ICON_SESS_DIVIDER].Handle <> 0 then begin
    if RTL then
      DrawIconEx(Canvas.Handle,ItemRect.Right-16-IconOffset,ItemRect.Top + IconTop,
        hppIcons[HPP_ICON_SESS_DIVIDER].Handle,16,16,0,0,DI_NORMAL)
    else
      DrawIconEx(Canvas.Handle,ItemRect.Left+IconOffset,ItemRect.Top + IconTop,
        hppIcons[HPP_ICON_SESS_DIVIDER].Handle,16,16,0,0,DI_NORMAL);
    Inc(IconOffset,16 + Padding);
  end;

  text := WideFormat(TxtSessions,[GetTime(Items[Index].Time)]);
  //Canvas.Font := Options.FontSessHeader;
  Canvas.Font.Assign(Options.FontSessHeader);
  Inc(ItemRect.Left,IconOffset);
  Dec(ItemRect.Right,RIconOffset);
  if RTL then begin
    TextOffset := WideCanvasTextWidth(Canvas,text);
    WideCanvasTextRect(Canvas,ItemRect,ItemRect.Right-TextOffset,ItemRect.Top,text);
  end
  else
    WideCanvasTextRect(Canvas,ItemRect,ItemRect.Left,ItemRect.Top,text);
end;

procedure THistoryGrid.SetBookmarked(Index: Integer; const Value: Boolean);
var
  r: TRect;
begin
  // don't set unknown items, we'll got correct bookmarks when we load them anyway
  if IsUnknown(Index) then exit;
  if Bookmarked[Index] = Value then exit;
  FItems[Index].Bookmarked := Value;
  if IsVisible(Index) then begin
    r := GetItemRect(Index);
    InvalidateRect(Handle,@r,False);
    Update;
  end;
end;

procedure THistoryGrid.SetCodepage(const Value: Cardinal);
var
  i: Integer;
  DoChanges: Boolean;
begin
  if FCodepage = Value then exit;
  FCodepage := Value;
  DoChanges := false;
  if Allocated then begin
    for i := 0 to Length(FItems) - 1 do
      if not IsUnknown(i) then begin
        DoChanges := true;
        // cose it's faster :)
        //LoadItem(i,false,true);
        FItems[i].MessageType := [mtUnknown];
      end;
    if DoChanges then DoOptionsChanged;
  end;
end;

procedure THistoryGrid.SetContact(const Value: Integer);
begin
  if FContact = Value then exit;
  FContact := Value;
end;

procedure THistoryGrid.SetExpandHeaders(const Value: Boolean);
var
  i: Integer;
begin
  if FExpandHeaders = Value then exit;
  FExpandHeaders := Value;
  for i := 0 to Length(FItems) - 1 do begin
    if FItems[i].HasHeader then begin
      FItems[i].Height := -1;
      FRichCache.ResetItem(i);
    end;
  end;
  BarAdjusted := False;
  AdjustScrollBar;
  Invalidate;
end;

procedure THistoryGrid.SetGroupLinked(const Value: Boolean);
var
  i: Integer;
begin
  if FGroupLinked = Value then exit;
  FGroupLinked := Value;
  for i := 0 to Length(FItems) - 1 do begin
    if FItems[i].LinkedToPrev then begin
      FItems[i].Height := -1;
      FRichCache.ResetItem(i);
    end;
  end;
  BarAdjusted := False;
  AdjustScrollBar;
  Invalidate;
end;

procedure THistoryGrid.SetProcessInline(const Value: Boolean);
//var
//  cr: CHARRANGE;
begin
  if State = gsInline then begin
    FRichInline.Lines.BeginUpdate;
    //FRichInline.Perform(EM_EXGETSEL,0,LPARAM(@cr));
    ApplyItemToRich(Selected, FRichInline);
    //FRichInline.Perform(EM_EXSETSEL,0,LPARAM(@cr));
    //FRichInline.Perform(EM_SCROLLCARET, 0, 0);
    FRichInline.SelStart := 0;
    FRichInline.Lines.EndUpdate;
  end;
  if Assigned(FOnProcessInlineChange) then
    FOnProcessInlineChange(Self,Value);
end;

procedure THistoryGrid.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  //Canvas.Brush.Color := Color;
  //Canvas.FillRect(Rect(0,0,ClientWidth,ClientHeight));//Canvas.ClipRect);
  Message.Result := 1;
  //inherited;
end;

procedure THistoryGrid.WMPaint(var Message: TWMPaint);
var
  ps: TagPaintStruct;
  dc: HDC;
begin
  if (LockCount > 0) or (csDestroying in ComponentState) then begin
    Message.Result := 1;
    exit;
  end;
  BeginPaint(Handle,ps);
  dc := ps.HDC;
  ClipRect := ps.rcPaint;
  try
    //Canvas.Handle := dc;
    //Canvas.Font.name := 'MS Shell Dlg';
    //Canvas.Brush.Color := Color;
    Paint;
    BitBlt(dc,ClipRect.Left,ClipRect.Top,
      ClipRect.Right-ClipRect.Left,ClipRect.Bottom-ClipRect.Top,
      Canvas.Handle,ClipRect.Left,ClipRect.Top,SRCCOPY);
  finally
    EndPaint(Handle,ps);
    Message.Result := 0;
    //FRich.Visible := False;
  end;
end;

procedure THistoryGrid.WMSize(var Message: TWMSize);
//var
//  re_mask: Longint;
begin
  if not FRichParamsSet then begin
    FRichCache.SetHandles;
    FRichParamsSet := true;
    FRichInline.ParentWindow := Handle;
    //re_mask := SendMessage(FRichInline.Handle,EM_GETEVENTMASK,0,0);
    //SendMessage(FRichInline.Handle,EM_SETEVENTMASK,0,re_mask or ENM_LINK);
    //SendMessage(FRichInline.Handle,EM_AUTOURLDETECT,1,0);
    //SendMessage(FRichInline.Handle,EM_SETMARGINS,EC_LEFTMARGIN or EC_RIGHTMARGIN,0);
  end;
  BeginUpdate;
  GridUpdates := GridUpdates + [guSize];
  EndUpdate;
  //Update;
end;

procedure THistoryGrid.SetPadding(Value: Integer);
begin
  if Value = FPadding then exit;
  FPadding := Value;
end;

procedure THistoryGrid.WMVScroll(var Message: TWMVScroll);
var
  r: TRect;
  Item1, Item2, SBPos: Integer;
  off,idx,first,ind: Integer;
begin
  CheckBusy;
  if Message.ScrollCode = SB_ENDSCROLL then begin
    Message.Result := 0;
    exit;
  end;

  BeginUpdate;
  try
  idx := VertScrollBar.Position;
  ind := idx;
  first := GetFirstVisible;

 {if FItems[first].Height > ClientRect.Bottom-ClientRect.Top then begin
    r := ClientRect;
    PaintItem(first,r);
    Message.Result := 0;
    exit;
  end;}

  // if visible > then scroll it

  // OXY: This code prevents thumb from staying "between" filtered items
  // but it leads to thumb "jumping" after user finishes thumbtracking
  // uncomment if this "stuck-in-between" seems to produce bug
  {if Message.ScrollCode = SB_THUMBPOSITION then begin
    Message.Pos := GetIdx(first);
    VertScrollBar.ScrollMessage(Message);
    exit;
    end;}

  if Message.ScrollCode in [SB_LINEUP,SB_LINEDOWN,SB_PAGEDOWN,SB_PAGEUP] then begin
    Message.Result := 0;
    case Message.ScrollCode of
      SB_LINEDOWN: ScrollGridBy(VLineScrollSize);
      SB_LINEUP: ScrollGridBy(-VLineScrollSize);
      SB_PAGEDOWN: ScrollGridBy(ClientHeight);
      SB_PAGEUP: ScrollGridBy(-ClientHeight);
    end;
    exit;
    end;

  {$IFDEF CUST_SB}
  if (Message.ScrollBar = 0) and VertScrollBar.Visible then
    VertScrollBar.ScrollMessage(Message)
  else
    inherited;
  {$ELSE}
  inherited;
  {$ENDIF}

  SBPos := VertScrollBar.Position;
  off := SBPos - idx;

  //if (VertScrollBar.Position > MaxSBPos) and (off=0) then begin
  //  SetSBPos(VertScrollBar.Position);
  //  exit;
  //  end;
  {if (off=0) and (VertScrollBar.Position > MaxSBPos) then begin
    SetSBPos(VertScrollBar.Position);
    Invalidate;
    exit;
  end;}

  if not (VertScrollBar.Position > MaxSBPos) then TopItemOffset := 0;
  if off = 0 then exit;
  if off > 0 then begin
    idx := GetNext(GetIdx(VertScrollBar.Position-1));
    if (idx = first) and (idx <> -1) then begin
      idx := GetNext(idx);
      if idx = -1 then idx := first;
    end;
    if idx = -1 then begin
      idx := GetPrev(GetIdx(VertScrollBar.Position+1));
      if idx = -1 then
        idx := ind;
    end;
  end;
  if off < 0 then begin
    idx := GetPrev(GetIdx(VertScrollBar.Position+1));
    if (idx = first) and (idx <> -1) then begin
      idx := GetPrev(idx);
      //if idx := -1 then idx := Count-1;
    end;
    if (idx <> first) and (idx <> -1) then begin
      first := idx;
      idx := GetPrev(idx);
      if idx <> -1 then idx := first
      else idx := GetIdx(0);
    end;
    if idx = -1 then begin
      idx := GetNext(GetIdx(VertScrollBar.Position-1));
      if idx = -1 then
        idx := ind;
    end;
  end;
  { BUG HERE (not actually here, but..)
  If you filter by (for example) files and you have several files
  and large history, then when tracking throu files, you'll see
  flicker, like constantly scrolling up & down by 1 event. That's
  because when you scroll down by 1, this proc finds next event and
  scrolls to it. But when you continue your move, your track
  position becomes higher then current pos, and we search backwards,
  and scroll to prev event. That's why flicker takes place. Need to
  redesign some things to fix it }
  // OXY 2006-03-05: THIS BUG FIXED!!!
  // Now while thumbtracking we look if we are closer to next item
  // than to original item. If we are closer, then scroll. If not, then
  // don't change position and wait while user scrolls futher.
  // With this we have ONE MORE bug: when user stops tracking,
  // we leave thumb were it left, while we need to put it on the item

  Item1 := GetIdx(first);
  Item2 := GetIdx(idx);
  if not (Message.ScrollCode in [SB_THUMBTRACK,SB_THUMBPOSITION]) then
    SetSBPos(Item2)
  else begin
    if (SBPos >= Item1) and (Item2 > MaxSBPos) then
      SetSBPos(Item2)
    else if Abs(Item1-SBPos) > Abs(Item2-SBPos) then
      SetSBPos(Item2);
  end;

  AdjustScrollBar;

  r := ClientRect;
  InvalidateRect(Handle,@r,False);
finally
  EndUpdate;
  Update;
  end;
end;

procedure THistoryGrid.PaintItem(Index: Integer; ItemRect: TRect);
var
  TimeStamp,HeaderName: WideString;
  OrgRect: TRect;
  TopIconOffset,IconOffset,NickOffset,TimeOffset: Integer;
  //icon: TIcon;
  BackColor: TColor;
  nameFont,timestampFont,textFont: TFont;
  Sel: Boolean;
  RTL: Boolean;
  FullHeader: Boolean;
  RichBMP: TBitmap;
  ic: HICON;
  HeadRect: TRect;
  offset,dtf: Integer;
  er: PEventRecord;
begin
  {$IFDEF DEBUG}
  OutputDebugString(PChar('Paint item '+intToStr(Index)+' to screen'));
  {$ENDIF}

  // leave divider line
  Dec(ItemRect.Bottom);

  OrgRect := ItemRect;

  FullHeader := not (FGroupLinked and FItems[Index].LinkedToPrev);
  Sel := IsSelected(Index);
  RTL := GetItemRTL(Index);
  Options.GetItemOptions(FItems[Index].MessageType,textFont,BackColor);

  if not (RTL = ((Canvas.TextFlags and ETO_RTLREADING) > 0)) then begin
    if RTL then
      Canvas.TextFlags := Canvas.TextFlags or ETO_RTLREADING
    else
      Canvas.TextFlags := Canvas.TextFlags and not ETO_RTLREADING;
  end;

  //BackColor := SendMessage(FRich.Handle,EM_SETBKGNDCOLOR,0,0);
  //SendMessage(FRich.Handle,EM_SETBKGNDCOLOR,0,ColorToRGB(BackColor));

  if FullHeader then begin
    HeadRect := ItemRect;
    InflateRect(HeadRect,-Padding,-Padding);
    Dec(HeadRect.Top,Padding);
    Inc(HeadRect.Top,Padding div 2);
    if mtIncoming in FItems[Index].MessageType then begin
      nameFont := Options.FontContact;
      timestampFont := Options.FontIncomingTimestamp;
      HeaderName := ContactName;
      HeadRect.Bottom := HeadRect.Top+CHeaderHeight;
    end else begin
      nameFont := Options.FontProfile;
      timestampFont := Options.FontOutgoingTimestamp;
      HeaderName := ProfileName;
      HeadRect.Bottom := HeadRect.Top+PHeaderHeight;
    end;
    if Assigned(FGetNameData) then
      FGetNameData(Self,Index,HeaderName);
    HeaderName := HeaderName + ':';
    TimeStamp := GetTime(FItems[Index].Time);
  end;

  if Sel then begin
    BackColor := Options.ColorSelected;
  end;

  //SendMessage(FRich.Handle,EM_SETBKGNDCOLOR,0,ColorToRGB(BackColor));

  Canvas.Brush.Color := BackColor;
  Canvas.FillRect(ItemRect);

  InflateRect(ItemRect,-Padding,-Padding);

  if FullHeader then begin

    Dec(ItemRect.Top,Padding);
    IconOffset := 0;
    TopIconOffset := ((HeadRect.Bottom-HeadRect.Top)-16) div 2;
    if (FItems[Index].HasHeader) and (ShowHeaders) and (not ExpandHeaders) then begin
      if RTL then begin
        DrawIconEx(Canvas.Handle,HeadRect.Right-16,HeadRect.Top+TopIconOffset,
          hppIcons[HPP_ICON_SESS_DIVIDER].Handle,16,16,0,0,DI_NORMAL);
        Dec(HeadRect.Right,16+Padding);
      end
      else begin
        DrawIconEx(Canvas.Handle,HeadRect.Left,HeadRect.Top+TopIconOffset,
          hppIcons[HPP_ICON_SESS_DIVIDER].Handle,16,16,0,0,DI_NORMAL);
        Inc(HeadRect.Left,16+Padding);
      end;
    end;

    if Options.ShowIcons then begin
      {if (mtFile in FItems[Index].MessageType) then
        ic := Options.IconFile.Handle
      else if (mtUrl in FItems[Index].MessageType) then
        ic := Options.IconUrl.Handle
      else if (mtMessage in FItems[Index].MessageType) then
        ic := Options.IconMessage.Handle
      else if (mtOther in FItems[Index].MessageType) then
        ic := Options.IconOther.Handle;}
      er := GetMessageRecord(FItems[Index].MessageType);
      if er.iSkin = -1 then
        ic := hppIcons[er.i].handle
      else
        ic := skinIcons[er.i].handle;
      if ic <> 0 then begin
        // canvas. draw here can sometimes draw 32x32 icon (sic!)
        if RTL then begin
          DrawIconEx(Canvas.Handle,HeadRect.Right-16,HeadRect.Top+TopIconOffset,ic,16,16,0,0,DI_NORMAL);
          Dec(HeadRect.Right,16+Padding);
        end
        else begin
          DrawIconEx(Canvas.Handle,HeadRect.Left,HeadRect.Top+TopIconOffset,ic,16,16,0,0,DI_NORMAL);
          Inc(HeadRect.Left,16+Padding);
        end;
      end;
    end;

    //Canvas.Font := nameFont;
    Canvas.Font.Assign(nameFont);
    if sel then Canvas.Font.Color := Options.ColorSelectedText;
    dtf := DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER;
    if RTL then
      dtf := dtf or DT_RTLREADING or DT_RIGHT
    else
      dtf := dtf or DT_LEFT;
    Tnt_DrawTextW(Canvas.Handle,PWideChar(HeaderName),Length(HeaderName),HeadRect,dtf);

    //Canvas.Font := timestampFont;
    Canvas.Font.Assign(timestampFont);
    if sel then Canvas.Font.Color := Options.ColorSelectedText;
    TimeOffset := WideCanvasTextWidth(Canvas,TimeStamp);
    dtf := DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER;
    if RTL then
      dtf := dtf or DT_RTLREADING or DT_LEFT
    else
      dtf := dtf or DT_RIGHT;
    Tnt_DrawTextW(Canvas.Handle,PWideChar(TimeStamp),Length(TimeStamp),HeadRect,dtf);

    if ShowBookmarks and (Sel or FItems[Index].Bookmarked) then begin
      IconOffset := TimeOffset + Padding;
      if FItems[Index].Bookmarked then
        ic := hppIcons[HPP_ICON_BOOKMARK_ON].handle
      else
        ic := hppIcons[HPP_ICON_BOOKMARK_OFF].handle;
      if RTL then
        DrawIconEx(Canvas.Handle,HeadRect.Left+IconOffset,HeadRect.Top+TopIconOffset,ic,16,16,0,0,DI_NORMAL)
      else
        DrawIconEx(Canvas.Handle,HeadRect.Right-IconOffset-16,HeadRect.Top+TopIconOffset,ic,16,16,0,0,DI_NORMAL);
    end;

    ItemRect.Top := HeadRect.Bottom + Padding - (Padding div 2);
  end;

  ApplyItemToRich(Index);
  RichBMP := FRichCache.GetItemRichBitmap(Index);
  BitBlt(Canvas.Handle,ItemRect.Left,ItemRect.Top,RichBMP.Width,RichBMP.Height,
    RichBMP.Canvas.Handle,0,0,SRCCOPY);

  //if (Focused or WindowPrePainting) and (Index = Selected) then begin
  if (not FGridNotFocused or WindowPrePainting) and (Index = Selected) then begin
    DrawFocusRect(Canvas.Handle,OrgRect);
  end;

end;

procedure THistoryGrid.PrePaintWindow;
begin
  ClipRect := Rect(0,0,ClientWidth,ClientHeight);
  WindowPrePainting := True;
  Paint;
  WindowPrePainting := False;
  WindowPrePainted := True;
end;

procedure THistoryGrid.MakeSelected(Value: Integer);
var
  OldSelected: Integer;
begin
  FRichCache.ResetItem(FSelected);
  OldSelected := FSelected;
  FSelected := Value;
  FRichCache.ResetItem(FSelected);
  if FSelected <> -1 then begin
    FRichCache.ResetItems(FSelItems);
    SetLength(FSelItems,1);
    FSelItems[0] := FSelected;
  end
  else begin
    FRichCache.ResetItems(FSelItems);
    SetLength(FSelItems,0);
  end;
  if FSelected <> -1 then begin
    MakeVisible(Selected);
  end;
  if Assigned(FOnSelect) then
    FOnSelect(Self,Selected,OldSelected);
  Invalidate;
  Update;
end;

procedure THistoryGrid.SetSelected(const Value: Integer);
begin
  MakeSelected(Value);
end;

procedure THistoryGrid.SetShowHeaders(const Value: Boolean);
var
  i: Integer;
begin
  if FShowHeaders = Value then exit;
  FShowHeaders := Value;
  for i := 0 to Length(FItems) - 1 do begin
    if FItems[i].HasHeader then begin
      FItems[i].Height := -1;
      FRichCache.ResetItem(i);
    end;
  end;
  BarAdjusted := False;
  AdjustScrollBar;
  Invalidate;
end;

procedure THistoryGrid.AddSelected(Item: Integer);
begin
  if IsSelected(Item) then exit;
  if IsUnknown(Item) then LoadItem(Item,False);
  if not IsMatched(Item) then exit;
  IntSortedArray_Add(TIntArray(FSelItems),Item);
  FRichCache.ResetItem(Item);
  //r := GetItemRect(Item);
  //InvalidateRect(Handle,@r,False);
end;

procedure THistoryGrid.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if FGridNotFocused then Windows.SetFocus(Handle);
  DoLButtonDown(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

function THistoryGrid.FindItemAt(x, y: Integer; out ItemRect: TRect): Integer;
var
  SumHeight: Integer;
  idx: Integer;
begin
  Result := -1;
  ItemRect := Rect(0,0,0,0);
  if Count = 0 then exit;

  SumHeight := TopItemOffset;
  if y < 0 then begin
    idx := GetFirstVisible;
    while idx >= 0 do begin
      if y > -SumHeight then begin
        Result := idx;
        break;
        end;
      idx := GetPrev(idx);
      if idx = -1 then break;
      LoadItem(idx,True);
      Inc(SumHeight,FItems[idx].Height);
      end;
    exit;
    end;

  idx := GetFirstVisible;

  SumHeight := - TopItemOffset;
  while (idx >= 0) and (idx < Length(FItems)) do begin
    LoadItem(idx,True);
    if y < SumHeight+FItems[idx].Height then begin
      Result := idx;
      break;
      end;
    Inc(SumHeight,FItems[idx].Height);
    idx := GetDown(idx);
    if idx = -1 then break;
    end;
  {FIX: 2004-08-20, can have AV here, how could I miss this line? }
  if Result = -1 then exit;
  ItemRect := Rect(0,SumHeight,ClientWidth,SumHeight+FItems[Result].Height);
end;

function THistoryGrid.FindItemAt(P: TPoint; out ItemRect: TRect): Integer;
begin
  Result := FindItemAt(P.x, P.y, ItemRect);
end;

function THistoryGrid.FindItemAt(P: TPoint): Integer;
var
  r: TRect;
begin
  Result := FindItemAt(P.x,P.y,r);
end;

function THistoryGrid.FindItemAt(x, y: Integer): Integer;
var
  r: TRect;
begin
  Result := FindItemAt(x,y,r);
end;

function THistoryGrid.FormatItem(Item: Integer; Format: WideString): WideString;
var
  tok: TWideStrArray;
  toksp: TIntArray;
  i: Integer;
begin
  TokenizeString(Format,tok,toksp);
  LoadItem(Item,False);
  IntFormatItem(Item,tok,toksp);
  Result := '';
  for i := 0 to Length(tok) - 1 do
    Result := Result + tok[i];
end;

function THistoryGrid.FormatItems(ItemList: array of Integer;
  Format: WideString): WideString;
var
  ifrom,ito,step,i,n: Integer;
  linebreak: WideString;
  tok2,tok: TWideStrArray;
  toksp,tok_smartdt: TIntArray;
  prevdt,dt: TDateTime;
begin
  // array of items MUST be a sorted list!

  Result := '';
  linebreak := #13#10;
  TokenizeString(Format,tok,toksp);

  // detect if we have smart_datetime in the tokens
  // and cache them if we do
  for n := 0 to Length(toksp) - 1 do
    if tok[toksp[n]] = '%smart_datetime%' then begin
      SetLength(tok_smartdt,Length(tok_smartdt)+1);
      tok_smartdt[High(tok_smartdt)] := toksp[n];
    end;
  dt := 0;
  prevdt := 0;

  // start processing all items

  //if Reversed then begin
  // from older to newer, excluding external grid
  if not ReversedHeader then begin
    ifrom := High(ItemList);
    ito := 0;
    step := -1;
  end else begin
    ifrom := 0;
    ito := High(ItemList);
    step := 1;
  end;
  i := ifrom;
  while (i >= 0) and (i <= High(ItemList)) do begin
    LoadItem(ItemList[i],False);
    if i = ito then linebreak := ''; // do not put linebr after last item
    tok2 := Copy(tok,0,Length(tok));

    // handle smart dates:
    if Length(tok_smartdt) > 0 then begin
      dt := TimestampToDateTime(FItems[ItemList[i]].Time);
      if prevdt <> 0 then
        if Trunc(dt) = Trunc(prevdt) then
          for n := 0 to Length(tok_smartdt) - 1 do
            tok2[tok_smartdt[n]] := '%time%';
    end; // end smart dates

    IntFormatItem(ItemList[i],tok2,toksp);
    for n := 0 to Length(tok2) - 1 do
      Result := Result + tok2[n];
    Result := Result + linebreak;
    prevdt := dt;
    Inc(i,step);
  end;
end;

function THistoryGrid.FormatSelected(const Format: WideString): WideString;
begin
  if SelCount = 0 then
    Result := ''
  else
    Result := FormatItems(FSelItems,Format);
end;

var
  // WasDownOnGrid hack was introduced
  // because I had the following problem: when I have
  // history of contact A opened and have search results
  // with messages from A, and if the history is behind the
  // search results window, when I double click A's message
  // I get hisory to the front with sometimes multiple messages
  // selected because it 1) selects right message;
  // 2) brings history window to front; 3) sends wm_mousemove message
  // to grid saying that left button is pressed (???) and because
  // of that shit grid thinks I'm selecting several items. So this
  // var is used to know whether mouse button was down down on grid
  // somewhere else
  WasDownOnGrid: Boolean = False;

procedure THistoryGrid.DoLButtonDown(X, Y: Integer; Keys: TMouseMoveKeys);
var
  Item: Integer;
begin
  WasDownOnGrid := True;
  SearchPattern := '';
  CheckBusy;
  if Count = 0 then exit;

  DownHitTests := GetHitTests(x,y);

  // we'll hide/show session headers on button up, don't select item
  if (ghtButton in DownHitTests) or
     (ghtLink in DownHitTests) then exit;

  Item := FindItemAt(x,y);

  if Item <> -1 then begin
    if (mmkControl in Keys) then begin
      if IsSelected(Item) then
        RemoveSelected(Item)
      else
        AddSelected(Item);
      FSelected := Item;
      MakeVisible(Item);
      Invalidate;
    end else
    if (Selected <> -1) and (mmkShift in Keys) then begin
      MakeSelectedTo(Item);
      FSelected := Item;
      MakeVisible(Item);
      Invalidate;
    end else
      Selected := Item;
  end;

end;

function THistoryGrid.GetItemRect(Item: Integer): TRect;
var
  tmp,idx,SumHeight: Integer;
  succ: Boolean;
begin
  Result := Rect(0,0,0,0);
  SumHeight := -TopItemOffset;
  if Item = -1 then exit;
  if not IsMatched(Item) then exit;
  if GetIdx(Item) < GetIdx(GetFirstVisible) then begin
    idx := GetFirstVisible;
    tmp := GetUp(idx);
    if tmp <> -1 then idx := tmp;
    {.TODO: fix here, don't go up, go down from 0}
    if Reversed then
      succ := (idx <= Item)
    else
      succ := (idx >= Item);
    while succ do begin
      LoadItem(idx);
      Inc(SumHeight,FItems[idx].Height);
      idx := GetPrev(idx);
      if idx = -1 then break;
      if Reversed then
        succ := (idx <= Item)
      else
        succ := (idx >= Item);
      end;
  {
  for i := VertScrollBar.Position-1 downto Item do begin
    LoadItem(i);
    Inc(SumHeight,FItems[i].Height);
    end;
  }
      Result := Rect(0,-SumHeight,ClientWidth,-SumHeight+FItems[Item].Height);
      exit;
    end;

  idx := GetFirstVisible;//GetIdx(VertScrollBar.Position);

  while GetIdx(idx) < GetIdx(Item) do begin
    LoadItem(idx);
    Inc(SumHeight,FItems[idx].Height);
    idx := GetNext(idx);
    if idx = -1 then break;
    end;

  Result := Rect(0,SumHeight,ClientWidth,SumHeight+FItems[Item].Height);
end;

function THistoryGrid.GetItemRTL(Item: Integer): Boolean;
begin
  if FItems[Item].RTLMode = hppRTLDefault then begin
    if RTLMode = hppRTLDefault then
      Result := Options.RTLEnabled
    else
      Result := (RTLMode = hppRTLEnable);
  end else
    Result := (FItems[Item].RTLMode = hppRTLEnable)
end;

function THistoryGrid.IsSelected(Item: Integer): Boolean;
begin
  Result := False;
  if FHideSelection and FGridNotFocused then exit;
  if Item = -1 then exit;
  Result := IntSortedArray_Find(TIntArray(FSelItems),Item) <> -1;
end;

function THistoryGrid.GetSelCount: Integer;
begin
  Result := Length(FSelItems);
end;

procedure THistoryGrid.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  DoLButtonUp(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

{$IFDEF RENDER_RICH}
procedure THistoryGrid.ApplyItemToRich(Item: Integer; RichEdit: THPPRichEdit = nil; UseSelection: Boolean = True; ForceInline: Boolean = False);
var
  textFont: TFont;
  textColor,backColor: TColor;
  //tsColor: TColor;
  RichItem: PRichItem;
  RTF,Text: String;
  UseTextFormatting,
  NoDefaultColors: Boolean;
  cf: CharFormat2;
begin
  if RichEdit = nil then begin
    RichItem := FRichCache.RequestItem(Item);
    FRich := RichItem^.Rich;
    FRichHeight := RichItem^.Height;
    exit;
  end else if not (RichEdit = FRichInline) then
    FRich := RichEdit;

  Options.GetItemOptions(FItems[Item].MessageType,textFont,backColor);

  if (IsSelected(Item)) and (not (RichEdit = FRichInline)) and UseSelection then begin
    //textColor := ColorToRGB(Options.ColorSelectedText);
    //backColor := ColorToRGB(Options.ColorSelected);
    textColor := Options.ColorSelectedText;
    backColor := Options.ColorSelected;
    NoDefaultColors := false;
  end else begin
    //textColor := ColorToRGB(textFont.Color);
    //backColor := ColorToRGB(backColor);
    textColor := textFont.Color;
    backColor := backColor;
    NoDefaultColors := true;
  end;

  UseTextFormatting := not (((State = gsInline) or ForceInline) and not Options.TextFormatting);

  //RichEdit.Clear;
  RichEdit.Perform(WM_SETTEXT,0,0);
  SetRichRTL(GetItemRTL(Item),RichEdit);
  // for use with WM_COPY
  RichEdit.Codepage := FItems[Item].Codepage;

  if Options.RawRTFEnabled and UseTextFormatting and isRTF(FItems[Item].Text) then begin
    // stored text seems to be RTF
    RTF := WideToAnsiString(FItems[Item].Text,FItems[Item].Codepage)+#0
  end else begin
    RTF := '{\rtf1\ansi\deff0{\fonttbl ';
    //RTF := Format('{\rtf1\ansi\ansicpg%u\deff0\deflang%u{\fonttbl ',[FItems[Item].Codepage,GetLCIDfromCodepage(CodePage)]);
    RTF := RTF + Format('{\f0\fnil\fcharset%u %s}',[textFont.CharSet,textFont.Name]);
    RTF := RTF + '}{\colortbl';
    RTF := RTF + Format('\red%u\green%u\blue%u;',[textColor and $FF,(textColor shr 8) and $FF,(textColor shr 16) and $FF]);
    RTF := RTF + Format('\red%u\green%u\blue%u;',[backColor and $FF,(backColor shr 8) and $FF,(backColor shr 16) and $FF]);
    // add color table for BBCodes
    if Options.BBCodesEnabled and NoDefaultColors then RTF := RTF + rtf_ctable_text;
    // hav probs with pasting in ms word with wring back color
    //RTF := RTF + '}\li30\ri30\fi0\highlight1\cf0';
    RTF := RTF + '}\li30\ri30\fi0\cf0';
    if GetItemRTL(Item) then RTF := RTF + '\rtlpar\ltrch\rtlch '
                        else RTF := RTF + '\ltrpar\rtlch\ltrch ';
    RTF := RTF + Format('\f0\b%d\i%d\ul%d\strike%d\fs%u',
      [integer(fsBold in textFont.Style),
       integer(fsItalic in textFont.Style),
       integer(fsUnderline in textFont.Style),
       integer(fsStrikeOut in textFont.Style),
       integer(textFont.Size shl 1)]);
    Text := FormatString2RTF(FItems[Item].Text);
    {if FGroupLinked and FItems[Item].LinkedToPrev then
      Text := FormatString2RTF(GetTime(FItems[Item].Time)+': '+FItems[Item].Text)
    else
      Text := FormatString2RTF(FItems[Item].Text);}
    if Options.BBCodesEnabled and UseTextFormatting then
      Text := DoSupportBBCodesRTF(Text,2,NoDefaultColors);
    RTF := RTF + Text + '\par }'+#0;
  end;

  SetRichRTF(RichEdit.Handle,RTF,False,False,True);

  (* smart date time in linked item
  if FGroupLinked and FItems[Item].LinkedToPrev then begin
    if mtIncoming in FItems[Item].MessageType then
      textFont := Options.FontIncomingTimestamp
    else
      textFont := Options.FontOutgoingTimestamp;
    if NoDefaultColors then
      tsColor := textFont.Color
    else
      tsColor := Options.ColorSelectedText;
    RTF := '{\rtf1\ansi\deff0{\fonttbl';
    RTF := RTF + Format('{\f0\fnil\fcharset%u %s}',[textFont.Charset,textFont.Name]);
    RTF := RTF + '}{\colortbl';
    RTF := RTF + Format('\red%u\green%u\blue%u;',[tsColor and $FF,(tsColor shr 8) and $FF,(tsColor shr 16) and $FF]);
    RTF := RTF + '}';
    RTF := RTF + Format('\f0\b%d\i%d\ul%d\strike%d\fs%u',
      [integer(fsBold in textFont.Style),
       integer(fsItalic in textFont.Style),
       integer(fsUnderline in textFont.Style),
       integer(fsStrikeOut in textFont.Style),
       integer(textFont.Size shl 1)]);
    Text := FormatString2RTF(GetTime(
    FItems[Item].Time));
    RTF := RTF + Text + '\par }'+#0;
    SetRichRTF(RichEdit.Handle,RTF,True,False,True);
  end;
  *)

  RichEdit.Perform(EM_SETBKGNDCOLOR,0,backColor);

  if UseTextFormatting and Assigned(FOnProcessRichText) then begin
    try
      FOnProcessRichText(Self,RichEdit.Handle,Item);
    except
    end;
    // do not allow changed back and color of selection
    //if isSelected(item) and (State <> gsInline) and UseSelection then begin
    if not NoDefaultColors then begin
      ZeroMemory(@cf,SizeOf(cf));
      cf.cbSize := SizeOf(cf);
      cf.dwMask := CFM_COLOR;
      cf.crTextColor := textColor;
      RichEdit.Perform(EM_SETBKGNDCOLOR, 0, backColor);
      RichEdit.Perform(EM_SETCHARFORMAT, SCF_ALL, integer(@cf));
    end;
  end;
  {$IFDEF DEBUG}
  OutputDebugString(PChar('Applying item '+intToStr(Item)+' to rich'));
  {$ENDIF}
end;
{$ENDIF}

procedure THistoryGrid.DoRButtonUp(X, Y: Integer; Keys: TMouseMoveKeys);
var
  Item: Integer;
  ht: TGridHitTests;
begin
  SearchPattern := '';
  CheckBusy;

  Item := FindItemAt(x,y);

  ht := GetHitTests(x,y);
  if (ghtLink in ht) then begin
    if Assigned(FOnUrlPopup) then begin
      Cursor := crDefault;
      FOnUrlPopup(Self,Item,GetLinkAtPoint(x,y));
    end;
    exit;
  end;

  if Selected <> Item then begin
    if IsSelected(Item) then begin
      FSelected := Item;
      MakeVisible(Item);
      Invalidate;
      end
    else begin
      Selected := item;
      end;
    end;

  if Assigned(FOnPopup) then
    OnPopup(Self);
end;

procedure THistoryGrid.DoLButtonUp(X, Y: Integer; Keys: TMouseMoveKeys);
var
  Item: Integer;
  ht: TGridHitTests;
begin
  ht := GetHitTests(x,y) * DownHitTests;
  DownHitTests := [];
  WasDownOnGrid := False;

  if ((ghtSessHideButton in ht) or (ghtSessShowButton in ht)) then begin
    ExpandHeaders := (ghtSessShowButton in ht);
    exit;
  end;

  if (ghtBookmark in ht) then begin
    if Assigned(FOnBookmarkClick) then begin
      Item := FindItemAt(x,y);
      FOnBookmarkClick(Self,Item);
    end;
    exit;
  end;

  if (ghtLink in ht) then begin
    if Assigned(FOnUrlClick) then begin
      Item := FindItemAt(x,y);
      FOnUrlClick(Self,Item,GetLinkAtPoint(x,y));
    end;
    exit;
  end;

end;

procedure THistoryGrid.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if Focused then
    DoMouseMove(Message.XPos,Message.YPos,TranslateKeys(Message.Keys))
end;

procedure THistoryGrid.DoMouseMove(X, Y: Integer; Keys: TMouseMoveKeys);
var
  Item: Integer;
  //ht: TGridHitTests;
  //NewCursor: TCursor;
  //NewHint: WideString;
  SelectMove: Boolean;
begin
  CheckBusy;
  if Count = 0 then exit;

  // do we need to process control here?
  SelectMove := ((mmkLButton in Keys) and not ((mmkControl in Keys) or (mmkShift in Keys))) and
                (MultiSelect) and (WasDownOnGrid);
  SelectMove := SelectMove and not (
                (ghtButton in DownHitTests) or
                (ghtLink in DownHitTests));

  if SelectMove then begin
    if SelCount = 0 then exit;
    Item := FindItemAt(x,y);
    if Item = -1 then exit;
    // do not do excessive relisting of items
    if (not ((FSelItems[0] = Item) or (FSelItems[High(FSelItems)] = Item)))
    or (FSelected <> Item) then begin
      MakeSelectedTo(Item);
      FSelected := Item;
      MakeVisible(Item);
      Invalidate;
    end;
  end;
end;

procedure THistoryGrid.WMLButtonDblClick(var Message: TWMLButtonDblClk);
begin
  DoLButtonDblClick(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

procedure THistoryGrid.CalcAllHeight;
var
  i: Integer;
  ts: DWord;
begin
  ts := GetTickCount;
  for i := 0 to Length(FItems) - 1 do
  begin
    LoadItem(i,True);
  end;
  ts := GetTickCount - ts;
  MessageBox(Handle,PChar('Calculated '+IntToStr(Length(FItems))+' items, time taken: '+IntToStr(ts)+' ms'),'Info',0)
end;

function THistoryGrid.CalcItemHeight(Item: Integer): Integer;
var
  hh,h: Integer;
begin
  Result := -1;
  if IsUnknown(Item) then exit;

  ApplyItemToRich(Item);
  Assert(FRichHeight > 0, 'CalcItemHeight: rich is still <= 0 height');
  // rude hack, but what the fuck??? First item with rtl chars is 1 line heighted always
  // probably fixed, see RichCache.ApplyItemToRich
  if FRichHeight <= 0 then exit
                      else h := FRichHeight;

  if FGroupLinked and FItems[Item].LinkedToPrev then
    hh := 0
  else
  if mtIncoming in FItems[Item].MessageType then
    hh := CHeaderHeight
  else
    hh := PHeaderHeight;

  { If you change this, be sure to check out DoMouseMove,
  DoLButtonDown, DoRButtonDown where I compute offset for
  clicking & moving over invisible off-screen rich edit
  control }
  // compute height =
  // 1 pix -- border
  // 2*padding
  // text height
  // + HEADER_HEIGHT header
  Result := 1 + 2*Padding + h + hh;
  if (FItems[Item].HasHeader) and (ShowHeaders) then begin
    if ExpandHeaders then
      Inc(Result,SessHeaderHeight)
    else
      Inc(Result,0);
  end;
end;

procedure THistoryGrid.SetFilter(const Value: TMessageTypes);
begin
  {$IFDEF DEBUG}
  OutPutDebugString('Filter');
  {$ENDIF}
  if (Filter = Value) or (Value = []) or (Value = [mtUnknown]) then exit;
  FFilter := Value;
  UpdateFilter;
  if Assigned(FOnFilterChange) then FOnFilterChange(Self);
  {CheckBusy;
  SetLength(FSelItems,0);
  FSelected := 0;
  FFilter := Value;
  ShowProgress := True;
  State := gsLoad;
  try
    VertScrollBar.Range := Count-1+ClientHeight;
    if Reversed then
      Selected := GetPrev(-1)
    else
      Selected := GetNext(-1);
    BarAdjusted := False;
    AdjustScrollBar;
  finally
    State := gsIdle;
  end;
  Repaint;}
end;

procedure THistoryGrid.DrawMessage(Text: WideString);
var
  cr,r: TRect;
begin
  //Canvas.Font := Screen.MenuFont;
  //Canvas.Brush.Color := clWindow;
  //Canvas.Font.Color := clWindowText;
  Canvas.Font := Options.FontMessage;
  Canvas.Brush.Color := Options.ColorBackground;
  r := ClientRect;
  cr := ClientRect;
  Canvas.FillRect(r);
  // make multiline support
  //DrawText(Canvas.Handle,PChar(Text),Length(Text),
  //r,DT_CENTER or DT_NOPREFIX	or DT_VCENTER or DT_SINGLELINE);
  Tnt_DrawTextW(Canvas.Handle,PWideChar(Text),Length(Text),r,DT_NOPREFIX or DT_CENTER or DT_CALCRECT);
  OffsetRect(r,
    ((cr.Right - cr.Left) - (r.right - r.left)) div 2,
    ((cr.Bottom - cr.Top) - (r.bottom - r.top)) div 2);
  Tnt_DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text),r, DT_NOPREFIX or DT_CENTER);
end;

procedure THistoryGrid.SetContolID(const Value: Cardinal);
begin
  FControlID := Value;
end;

function THistoryGrid.SendMsgFilterMessage(var Message: TMessage): Longint;
var
  mf: TMsgFilter;
  res: Longint;
begin
  Result := 0;
  if FControlID <> 0 then begin
    mf.nmhdr.hwndFrom := WindowHandle;
    mf.nmhdr.idFrom := FControlID;
    mf.nmhdr.code := EN_MSGFILTER;
    mf.msg := Message.Msg;
    mf.wParam := Message.WParam;
    mf.lParam := Message.LParam;
    SendMessage(ParentWindow,WM_NOTIFY,FControlID,LParam(@mf));
  end;
end;

procedure THistoryGrid.WMKeyDown(var Message: TWMKeyDown);
begin
  DoKeyDown(Message.CharCode,KeyDataToShiftState(Message.KeyData));
  inherited;
  FSavedKeyMessage := Message;
  if Message.CharCode <> 0 then SendMsgFilterMessage(TMessage(Message))
end;

procedure THistoryGrid.WMKeyUp(var Message: TWMKeyUp);
begin
  DoKeyUp(Message.CharCode,KeyDataToShiftState(Message.KeyData));
  inherited;
  if FSavedKeyMessage.CharCode = 0 then exit;
  if Message.CharCode <> 0 then SendMsgFilterMessage(TMessage(Message))
end;

procedure THistoryGrid.WMSysKeyUp(var Message: TWMSysKeyUp);
begin
  DoKeyUp(Message.CharCode,KeyDataToShiftState(Message.KeyData));
  inherited;
  if FSavedKeyMessage.CharCode = 0 then exit;
  if Message.CharCode <> 0 then SendMsgFilterMessage(TMessage(Message))
end;

procedure THistoryGrid.DoKeyDown(var Key: Word; ShiftState: TShiftState);
var
  NextItem,i,Item: Integer;
  r: TRect;
begin
  if Count = 0 then exit;
  if ssAlt in ShiftState then exit;
  CheckBusy;

  Item := Selected;
  if Item = -1 then begin
    if Reversed then Item := GetPrev(-1)
                else Item := GetNext(-1);
  end;

  if (Key = VK_HOME) or ((ssCtrl in ShiftState) and (Key = VK_PRIOR)) then begin
    SearchPattern := '';
    NextItem := GetNext(GetIdx(-1));
    if (not (ssShift in ShiftState)) or (not MultiSelect) then begin
      Selected := NextItem;
    end else begin
      MakeSelectedTo(NextItem);
      FSelected := NextItem;
      MakeVisible(NextItem);
      Invalidate;
    end;
    AdjustScrollBar;
    Key := 0;
  end else

  if (Key = VK_END) or ((ssCtrl in ShiftState) and (Key = VK_NEXT)) then begin
    SearchPattern := '';
    NextItem := GetPrev(GetIdx(Count));
    if (not (ssShift in ShiftState)) or (not MultiSelect) then begin
      Selected := NextItem;
    end else begin
      MakeSelectedTo(NextItem);
      FSelected := NextItem;
      MakeVisible(NextItem);
      Invalidate;
    end;
    AdjustScrollBar;
    Key := 0;
  end;

  if ssCtrl in ShiftState then exit;

  if Key = VK_NEXT then begin //PAGE DOWN
    SearchPattern := '';
    NextItem := Item;
    r := GetItemRect(NextItem);
    NextItem := FindItemAt(0,r.top+ClientHeight);
    if NextItem = Item then begin
      NextItem := GetNext(NextItem);
      if NextItem = -1 then NextItem := Item;
    end else
    if NextItem = -1 then begin
      NextItem := GetPrev(GetIdx(Count));
      if NextItem = -1 then NextItem := Item;
    end;
    if (not (ssShift in ShiftState)) or (not MultiSelect) then begin
      Selected := NextItem;
    end else begin
      MakeSelectedTo(NextItem);
      FSelected := NextItem;
      MakeVisible(NextItem);
      Invalidate;
    end;
    AdjustScrollBar;
    Key := 0;
  end else

  if Key = VK_PRIOR then begin //PAGE UP
    SearchPattern := '';
    NextItem := Item;
    r := GetItemRect(NextItem);
    NextItem := FindItemAt(0,r.top-ClientHeight);
    if NextItem <> -1 then begin
      if FItems[NextItem].Height < ClientHeight then
        NextItem := GetNext(NextItem);
    end else
      NextItem := GetNext(NextItem);
    if NextItem = -1 then begin
      if IsMatched(GetIdx(0)) then
        NextItem := GetIdx(0)
      else
        NextItem := GetNext(GetIdx(0));
    end;
    if (not (ssShift in ShiftState)) or (not MultiSelect) then begin
      Selected := NextItem;
    end else begin
      MakeSelectedTo(NextItem);
      FSelected := NextItem;
      MakeVisible(NextItem);
      Invalidate;
    end;
    AdjustScrollBar;
    Key := 0;
  end else

  if Key = VK_UP then begin
    SearchPattern := '';
    if GetIdx(Item) > 0 then Item := GetPrev(Item);
    if item = -1 then exit;
    if (ssShift in ShiftState) and (MultiSelect) then begin
      MakeSelectedTo(Item);
      FSelected := Item;
      MakeVisible(Selected);
      Invalidate;
    end else
      Selected := Item;
    AdjustScrollBar;
    Key := 0;
  end else

  if Key = VK_DOWN then begin
    SearchPattern := '';
    if GetIdx(Item) < Count-1 then Item := GetNext(Item);
    if Item = -1 then exit;
    if (ssShift in ShiftState) and (MultiSelect) then begin
      MakeSelectedTo(Item);
      FSelected := Item;
      MakeVisible(Item);
      Invalidate;
    end else
      Selected := Item;
    AdjustScrollBar;
    Key := 0;
  end;

end;

procedure THistoryGrid.DoKeyUp(var Key: Word; ShiftState: TShiftState);
var
  NextItem,i,Item: Integer;
  r: TRect;
begin
  if Count = 0 then exit;
  if (ssAlt in ShiftState) or (ssCtrl in ShiftState) then exit;
  if (Key = VK_APPS) or ((Key = VK_F10) and (ssShift in ShiftState)) then begin
    CheckBusy;
    if Selected = -1 then begin
      if Reversed then Selected := GetPrev(-1)
                  else Selected := GetNext(-1);
    end;
    if Assigned(FOnPopup) then OnPopup(Self);
    Key := 0;
  end;
end;

procedure THistoryGrid.WMNotify(var Message: TWMNotify);
var
  link: TENLink;
  AnsiUrl: String;
  p: TPoint;
  tr: TextRange;
  OverInline: Boolean;
  CurRich: THPPRichEdit;
  Item: Integer;
begin
  {$IFDEF RENDER_RICH}
  // ok, user either clicked or moved mouse over link
  // if we are over inline richedit?
  OverInline := (Message.NMHdr^.hwndFrom = FRichInline.Handle);

  if Message.NMHdr^.code = EN_LINK then begin
    link := TENLink(Pointer(Message.NMHdr)^);
    if OverInline then begin
      CurRich := FRichInline;
      SetLength(AnsiUrl,link.chrg.cpMax-link.chrg.cpMin);
      tr.chrg := link.chrg;
      tr.lpstrText := @AnsiUrl[1];
      CurRich.Perform(EM_GETTEXTRANGE,0,DWord(@tr));
      if link.msg = WM_LBUTTONUP then begin
        p := Mouse.CursorPos;
        p := ScreenToClient(p);
        if Assigned(FOnUrlClick) then begin
          Item := FindItemAt(p.x,p.y);
          FOnUrlClick(Self,Item, AnsiToWideString(AnsiUrl,Codepage));
        end;
      end;
    end;
  end;
{$ENDIF}
  inherited;
end;

procedure THistoryGrid.WMGetDlgCode(var Message: TWMGetDlgCode);
type
  PWMMsgKey = ^TWMMsgKey;
  TWMMsgKey = packed record
    hwnd: HWND;
    Msg: Cardinal;
    CharCode: Word;
    Unused: Word;
    KeyData: Longint;
    Result: Longint;
  end;
var
  msg: PWMMsgKey;
begin
  inherited;
  Message.Result := DLGC_WANTALLKEYS;
  if (TMessage(Message).LParam <> 0) then begin
    with PWMMsgKey(TMessage(Message).LParam)^ do begin
      if (Msg = WM_KEYDOWN) or (Msg = WM_CHAR) or (Msg = WM_SYSCHAR) then
        case CharCode of
          VK_TAB: Message.Result := DLGC_WANTARROWS;
        end;
    end;
  end;
  Message.Result := Message.Result or DLGC_HASSETSEL;
end;

procedure THistoryGrid.EMSetSel(var Message: TMessage);
begin
  if csDestroying in ComponentState then exit;
  if Assigned(FOnSelectRequest) then FOnSelectRequest(Self);
end;

procedure THistoryGrid.MakeRangeSelected(FromItem, ToItem: Integer);
var
  i: Integer;
  StartItem,EndItem: Integer;
  len: Integer;
  changed: TIntArray;
begin
  // detect start and end
  if FromItem <= ToItem then begin
    StartItem := FromItem;
    EndItem := ToItem;
  end
  else begin
    StartItem := ToItem;
    EndItem := FromItem;
  end;

  // fill selected items list
  len := 0;
  for i := StartItem to EndItem do begin
    if IsUnknown(i) then LoadItem(i,False);
    if not IsMatched(i) then continue;
    Inc(len);
    SetLength(TempSelItems,len);
    TempSelItems[len-1] := i;
  end;

  // determine and update changed items
  changed := IntSortedArray_NonIntersect(TIntArray(FSelItems),TIntArray(TempSelItems));
  FRichCache.ResetItems(changed);

  // set selection
  FSelItems := TempSelItems;
end;

procedure THistoryGrid.MakeSelectedTo(Item: Integer);
var
  first: Integer;
begin
  if FSelItems[0] = FSelected then
    first := FSelItems[High(FSelItems)]
  else if FSelItems[High(FSelItems)] = FSelected then
    first := FSelItems[0]
  else
    first := FSelected;
  MakeRangeSelected(first,Item);
end;

procedure THistoryGrid.MakeTopmost(Item: Integer);
begin
  if (Item < 0) or (Item >= Count) then exit;
  SetSBPos(GetIdx(Item));
end;

procedure THistoryGrid.MakeVisible(Item: Integer);
var
  First: Integer;
  SumHeight: Integer;
  BottomAlign: Boolean;
begin
  BottomAlign := ShowBottomAligned and Reversed;
  ShowBottomAligned := False;
  if Item = -1 then exit;
  // load it to make positioning correct
  LoadItem(Item,True);
  if not IsMatched(Item) then exit;
  if Item = GetFirstVisible then begin
    if FItems[Item].Height > ClientHeight then begin
      if BottomAlign or (TopItemOffset > FItems[Item].Height - ClientHeight) then begin
        TopItemOffset := FItems[Item].Height - ClientHeight;
      end;
      ScrollGridBy(0,False);
    end else
      ScrollGridBy(-TopItemOffset,False);
    exit;
  end;
  if GetIdx(Item) < GetIdx(GetFirstVisible) then
    SetSBPos(GetIdx(Item))
  else begin
    //if IsVisible(Item) then exit;
    if IsVisible(Item,False) then exit;
    SumHeight := 0;
    First := Item;
    while (Item >= 0) and (Item < Count) do begin
      LoadItem(Item,True);
      if (SumHeight + FItems[Item].Height) >= ClientHeight then break;
      Inc(SumHeight,FItems[Item].Height);
      Item := GetUp(Item);
    end;
    if GetIdx(Item) >= MaxSBPos then begin
      SetSBPos(GetIdx(Item)+1);
      // strange, but if last message is bigger then client,
      // it always scrolls to down, but grid thinks, that it's
      // aligned to top (when entering inline mode, for ex.)
      if Item = First then TopItemOffset := 0;
    end else begin
      SetSBPos(getIdx(Item));
      if Item <> First then
        TopItemOffset := (SumHeight + FItems[Item].Height) - ClientHeight;
    end;
  end;
end;

procedure THistoryGrid.DoRButtonDown(X, Y: Integer; Keys: TMouseMoveKeys);
begin
  ;
end;

procedure THistoryGrid.WMRButtonDown(var Message: TWMRButtonDown);
begin
  inherited;
  if FGridNotFocused then Windows.SetFocus(Handle);
  DoRButtonDown(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

procedure THistoryGrid.WMRButtonUp(var Message: TWMRButtonDown);
begin
  inherited;
  DoRButtonUp(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

procedure THistoryGrid.BeginUpdate;
begin
  Inc(LockCount);
end;

procedure THistoryGrid.EndUpdate;
begin
  if LockCount > 0 then begin
    Dec(LockCount);
  end;
  if LockCount > 0 then exit;
  try
    if guSize in GridUpdates then
      GridUpdateSize;
  finally
    GridUpdates := [];
  end;
end;

function THistoryGrid.GetTime(Time: DWord): WideString;
begin
if Assigned(FTranslateTime) then
  OnTranslateTime(Self,Time,Result)
else
  Result := '';
end;

function THistoryGrid.GetTopItem: Integer;
begin
  if Reversed then
    Result := GetDown(Count)
  else
    Result := GetDown(-1);
end;

function THistoryGrid.GetUp(Item: Integer): Integer;
begin
  Result := GetPrev(Item,False);
end;

procedure THistoryGrid.GridUpdateSize;
var
  w,h: Integer;
  NewClient: TBitmap;
  i: Integer;
  WidthWasUpdated: Boolean;
begin
  if State = gsInline then CancelInline;

  w := ClientWidth;
  h := ClientHeight;
  WidthWasUpdated := (FClient.Width <> w);

  // avatars!!!
  //FRichCache.Width := ClientWidth - 3*FPadding - 64;
  FRichCache.Width := ClientWidth - 2*FPadding;

  if (w <> 0) and (h <> 0) then begin
    NewClient := TBitmap.Create;
    NewClient.Width := w;
    NewClient.Height := h;
    NewClient.Canvas.Font.Assign(Canvas.Font);
    NewClient.Canvas.TextFlags := Canvas.TextFlags;

    FClient.Free;
    FClient := NewClient;
    FCanvas := FClient.Canvas;
  end;

  IsCanvasClean := False;

  if WidthWasUpdated then
    for i := 0 to Count-1 do
      FItems[i].Height := -1;

  BarAdjusted := False;
  if Allocated then AdjustScrollBar;
end;

function THistoryGrid.GetDown(Item: Integer): Integer;
begin
  Result := GetNext(Item,false);
end;

function THistoryGrid.GetItems(Index: Integer): THistoryItem;
begin
  if (Index < 0) or (Index > High(FItems)) then exit;
  if IsUnknown(Index) then LoadItem(Index,False);
  Result := FItems[Index];
end;

// Call this function to get the link url at given point in grid
// Call it when you are sure that the point has a link,
// if no link at a point, the result is ''
// To know if there's a link, use GetHitTests and look for ghtLink
function THistoryGrid.GetLinkAtPoint(X, Y: Integer): WideString;
var
  p: TPoint;
  cp: DWord;
  cr: CHARRANGE;
  cf: CHARFORMAT2;
  res: DWord;
  AnsiUrl: String;
  RichEditRect: TRect;
  Item: Integer;
begin
  Result := '';

  Item := FindItemAt(x,y);
  if Item = -1 then exit;
  RichEditRect := GetRichEditRect(Item,True);
  p := Point(x - RichEditRect.Left,y - RichEditRect.Top);

  ApplyItemToRich(Item);
  cp := FRich.Perform(EM_CHARFROMPOS,0,LPARAM(@p));
  cr.cpMin := cp;
  cr.cpMax := cp+1;
  FRich.Perform(EM_EXSETSEL,0,LPARAM(@cr));

  ZeroMemory(@cf,SizeOf(cf));
  cf.cbSize := SizeOf(cf);
  cf.dwMask := CFM_LINK;

  res := FRich.Perform(EM_GETCHARFORMAT,SCF_SELECTION,LPARAM(@cf));
  if res <> cf.dwMask then exit;

  // no link under point
  if (cf.dwEffects and CFE_LINK) = 0 then exit;

  while True do begin
    Inc(cr.cpMax);
    FRich.Perform(EM_EXSETSEL,0,LPARAM(@cr));
    cf.cbSize := SizeOf(cf);
    cf.dwMask := CFM_LINK;
    res := FRich.Perform(EM_GETCHARFORMAT,SCF_SELECTION,LPARAM(@cf));
    if (res <> cf.dwMask) or ((res and CFM_LINK) = 0) then begin
      Dec(cr.cpMax);
      break;
    end;
  end;

  while True do begin
    if cr.cpMin > 0 then
      Dec(cr.cpMin)
    else break;
    FRich.Perform(EM_EXSETSEL,0,LPARAM(@cr));
    cf.cbSize := SizeOf(cf);
    cf.dwMask := CFM_LINK;
    res := FRich.Perform(EM_GETCHARFORMAT,SCF_SELECTION,LPARAM(@cf));
    if (res <> cf.dwMask) or ((res and CFM_LINK) = 0) then begin
      Inc(cr.cpMin);
      break;
    end;
  end;

  SetLength(AnsiUrl,cr.cpMax-cr.cpMin);
  FRich.Perform(EM_EXSETSEL,0,LPARAM(@cr));
  res := FRich.Perform(EM_GETSELTEXT,0,LPARAM(@AnsiUrl[1]));
  SetLength(AnsiUrl,res);
  Result := AnsiToWideString(AnsiUrl,Codepage);
end;

const
  Substs: array[0..3] of array[0..1] of WideString = (
  ('\n',WideString(#13#10)),
  ('\t',WideString(#9)),
  ('\\','\'),
  ('\%','%')
  );

procedure THistoryGrid.IntFormatItem(Item: Integer; var Tokens: TWideStrArray;
  var SpecialTokens: TIntArray);
var
  i,n: Integer;
  tok: TWideStrArray;
  toksp: TIntArray;
  subst: WideString;
  from_nick,to_nick,nick: WideString;
  dt: TDateTime;
  mes,selmes: WideString;
begin
  // item MUST be loaded before calling IntFormatItem!

  tok := Tokens;
  toksp := SpecialTokens;

  for i := 0 to Length(toksp) - 1 do begin
    subst := '';
    if tok[toksp[i]][1] = WideChar('\') then begin
      for n := 0 to Length(Substs) - 1 do
        if tok[toksp[i]] = Substs[n][0] then begin
          subst := Substs[n][1];
          break;
        end;
    end
    else begin
      mes := FItems[Item].Text;
      if Options.RawRTFEnabled and IsRTF(mes) then begin
        ApplyItemToRich(Item);
        mes := GetRichString(FRich.Handle,False);
      end;
      if State = gsInline then
        selmes := GetRichString(FRichInline.Handle,True)
      else selmes := mes;
      if mtIncoming in FItems[Item].MessageType then begin
        from_nick := ContactName;
        to_nick := ProfileName;
      end else begin
        from_nick := ProfileName;
        to_nick := ContactName;
      end;
      nick := from_nick;
      if Assigned(FGetNameData) then
        FGetNameData(Self,Item,nick);
      dt := TimestampToDateTime(FItems[Item].Time);
      // we are doing many if's here, because I don't want to pre-compose all the
      // possible tokens into array. That's because some tokens take some time to
      // be generated, and if they're not used, this time would be wasted.
      if tok[toksp[i]] = '%mes%' then
        subst := mes
      else
      if tok[toksp[i]] = '%adj_mes%' then
        subst := WideWrapText(mes,#13#10,[' ',#9,'-'],72)
      else
      if tok[toksp[i]] = '%quot_mes%' then begin
        subst := Tnt_WideStringReplace('> '+mes,#13#10,#13#10+'> ',[rfReplaceAll]);
        subst := WideWrapText(subst,#13#10+'> ',[' ',#9,'-'],70)
      end else
      if tok[toksp[i]] = '%selmes%' then
        subst := selmes
      else
      if tok[toksp[i]] = '%adj_selmes%' then
        subst := WideWrapText(selmes,#13#10,[' ',#9,'-'],72)
      else
      if tok[toksp[i]] = '%quot_selmes%' then begin
        subst := Tnt_WideStringReplace('> '+selmes,#13#10,#13#10+'> ',[rfReplaceAll]);
        subst := WideWrapText(subst,#13#10+'> ',[' ',#9,'-'],70)
      end else
      if tok[toksp[i]] = '%nick%' then subst := nick
      else
      if tok[toksp[i]] = '%from_nick%' then subst := from_nick
      else
      if tok[toksp[i]] = '%to_nick%' then subst := to_nick
      else
      if tok[toksp[i]] = '%datetime%' then subst := DateTimeToStr(dt)
      else
      if tok[toksp[i]] = '%smart_datetime%' then subst := DateTimeToStr(dt)
      else
      if tok[toksp[i]] = '%date%' then subst := DateToStr(dt)
      else
      if tok[toksp[i]] = '%time%' then subst := TimeToStr(dt);
    end;
    tok[toksp[i]] := subst;
  end;
end;

function THistoryGrid.IsMatched(Index: Integer): Boolean;
var
  mts: TMessageTypes;
begin
  mts := FItems[Index].MessageType;
  Result := ((MessageTypesToDWord(FFilter) and MessageTypesToDWord(mts)) >= MessageTypesToDWord(mts));
  if Assigned(FOnItemFilter) then
    FOnItemFilter(Self,Index,Result);
end;

function THistoryGrid.IsUnknown(Index: Integer): Boolean;
begin
  Result := (mtUnknown in FItems[Index].MessageType);
end;

procedure THistoryGrid.AdjustScrollBar;
var
  maxidx,SumHeight,ind,idx: Integer;
  r1,r2: TRect;
begin
  if BarAdjusted then exit;
  MaxSBPos := -1;
  if Count = 0 then begin
    VertScrollBar.Range := 0;
    exit;
  end;
  SumHeight := 0;
  idx := GetFirstVisible;

  if idx >= 0 then
  repeat
    LoadItem(idx);
    if IsMatched(idx) then
      Inc(SumHeight,FItems[idx].Height);
    idx := GetDown(idx);
  until ((SumHeight > ClientHeight) or (idx < 0) or (idx >= Length(FItems)));

  maxidx := idx;
  // see if the idx is the last
  if maxidx <> -1 then
    if GetDown(maxidx) = -1 then maxidx := -1;

  // if we are at the end, look up to find first visible
  if (maxidx = -1) and (SumHeight > 0) then begin
    SumHeight := 0;
    maxidx := GetIdx(Length(FItems));
    idx := 0;
    repeat
      idx := GetUp(maxidx);
      if idx = -1 then break;
      maxidx := idx;
      LoadItem(maxidx,True);
      if IsMatched(maxidx) then
        Inc(SumHeight,FItems[maxidx].Height);
    until ((SumHeight >= ClientHeight) or (maxidx < 0) or (maxidx >= Length(FItems)));
    BarAdjusted := True;
    VertScrollBar.Visible := (idx <> -1);
    VertScrollBar.Range := GetIdx(maxidx) + VertScrollBar.PageSize-1+1;
    MaxSBPos := GetIdx(maxidx);
    //if VertScrollBar.Position > MaxSBPos then
    SetSBPos(VertScrollBar.Position);
    exit;
  end;

  if SumHeight = 0 then begin
    VertScrollBar.Range := 0;
    exit;
  end;

  VertScrollBar.Visible := True;
  VertScrollBar.Range := Count + VertScrollBar.PageSize-1;
  MaxSBPos := Count-1;
  exit;

  if SumHeight < ClientHeight then begin
    idx := GetPrev(GetIdx(Count));
    if idx = -1 then Assert(False);
    r1 := GetItemRect(idx);
    idx := FindItemAt(0,r1.bottom-ClientHeight);
    if idx = -1 then begin
      idx := Getidx(0);
    end else begin
      ind := idx;
      r2 := GetItemRect(idx);
      if r1.bottom-r2.top > ClientHeight then begin
        idx := GetNext(idx);
        if idx = -1 then idx := ind;
      end;
    end;
    BarAdjusted := True;
    {$IFDEF PAGE_SIZE}
    VertScrollBar.Range := GetIdx(idx) + VertScrollBar.PageSize-1;
    {$ELSE}
    VertScrollBar.Range := GetIdx(idx)+ClientHeight;
    {$ENDIF}
    MaxSBPos := GetIdx(idx)-1;
    SetSBPos(VertScrollBar.Range);
  end else begin
    {$IFDEF PAGE_SIZE}
    VertScrollBar.Range := Count + VertScrollBar.PageSize-1;
    {$ELSE}
    VertScrollBar.Range := Count+ClientHeight-1;
    {$ENDIF}
    MaxSBPos := Count-1;
  end;
end;

procedure THistoryGrid.CreateWindowHandle(const Params: TCreateParams);
begin
  if hppOSUnicode then
    CreateUnicodeHandle(Self, Params, '')
  else
    inherited;
end;

procedure THistoryGrid.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do begin
    Style := Style or BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    with WindowClass do
    //style := style or CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW;
    style := style or CS_HREDRAW or CS_VREDRAW;
  end;
end;

function THistoryGrid.GetNext(Item: Integer; Force: Boolean = False): Integer;
var
  max: Integer;
  WasLoaded: Boolean;
begin
  Result := -1;
  {REV}
  if not Force then
    if Reversed then begin
      Result := GetPrev(Item,true);
      exit;
    end;
  Inc(Item);
  max := Count-1;
  WasLoaded := False;
  {AF 31.03.03}
  if Item < 0 then
    Item := 0;
  while (Item >= 0) and (Item < Count) do begin
    if ShowProgress then WasLoaded := not IsUnknown(Item);
    LoadItem(Item, False);
    if (State = gsLoad) and ShowProgress and (not WasLoaded) then
      DoProgress(Item,Max);
    if IsMatched(Item) then begin
      Result := Item;
      break;
    end;
    Inc(Item);
  end;
  if (State = gsLoad) and ShowProgress then begin
    ShowProgress := False;
    DoProgress(0,0);
  end;
end;

function THistoryGrid.GetPrev(Item: Integer; Force: Boolean = False): Integer;
begin
  Result := -1;
  if not Force then
    if Reversed then begin
      Result := GetNext(Item, True);
      exit;
    end;
  Dec(Item);
  {AF 31.03.03}
  if Item >= Count then
    Item := Count-1;

  while (Item < Count) and (Item >= 0) do begin
    LoadItem(Item, False);
    if IsMatched(Item) then begin
      Result := Item;
      break;
    end;
    Dec(Item);
  end;
end;

procedure THistoryGrid.CNVScroll(var Message: TWMVScroll);
begin
;
end;

(*
Return is item is visible on client area
EVEN IF IT IS *PARTIALLY* VISIBLE
*)
function THistoryGrid.IsVisible(Item: Integer; Partially: Boolean = True): Boolean;
var
  idx,SumHeight: Integer;
begin
  Result := False;
  if GetIdx(Item) < GetIdx(GetFirstVisible) then exit;
  if not IsMatched(Item) then exit;
  SumHeight := -TopItemOffset;
  idx := GetFirstVisible;
  LoadItem(idx,True);
  while (SumHeight < ClientHeight) and (Item <> -1) and (Item < Count) do begin
    if Item = idx then begin
      if Partially then
        Result := True
      else
        Result := (SumHeight+FItems[idx].Height <= ClientHeight);
      break;
    end;
    Inc(SumHeight,FItems[idx].height);
    idx := GetNext(idx);
    if idx = -1 then break;
    LoadItem(idx,true);
  end;
end;

procedure THistoryGrid.DoLButtonDblClick(X, Y: Integer; Keys: TMouseMoveKeys);
var
  Item: Integer;
  ht: TGridHitTests;
begin
  SearchPattern := '';
  CheckBusy;
  ht := GetHitTests(x,y);
  if (ghtSessShowButton in ht) or (ghtSessHideButton in ht) or (ghtBookmark in ht) then exit;
  if ghtLink in ht then begin
    DownHitTests := ht;
    DoLButtonUp(X,Y,Keys);
    exit;
  end;
  Item := FindItemAt(x,y);
  if Item <> Selected then begin
    Selected := Item;
    exit;
  end;
  if Assigned(OnDblClick) then
    OnDblClick(Self);
end;

procedure THistoryGrid.WMSysCommand(var Message: TWMSysCommand);
begin
  inherited;
end;

procedure THistoryGrid.DrawProgress;
var
r: TRect;
begin
  r := ClientRect;
  //Canvas.Brush.Color := clWindow;
  //Canvas.Font.Color := clWindowText;
  Canvas.Font := Options.FontMessage;
  Canvas.Brush.Color := Options.ColorBackground;
  Canvas.Pen.Color := Options.FontMessage.Color;
  if not IsCanvasClean then begin
    Canvas.FillRect(r);
    ProgressRect := r;
    InflateRect(r,-30,-((ClientHeight - 17) div 2));
    IsCanvasClean := True;
  end else begin
    InflateRect(r,-30,-((ClientHeight - 17) div 2));
    ProgressRect := r;
  end;
  Canvas.FrameRect(r);
  //Canvas.FillRect(r);
  InflateRect(r,-1,-1);
  //InflateRect(r,-30,-((ClientHeight - 15) div 2));
  Canvas.Rectangle(r);
  InflateRect(r,-2,-2);
  //Canvas.Brush.Color := clHighlight;
  //Canvas.Brush.Color := Options.ColorSelected;
  Canvas.Brush.Color := Options.FontMessage.Color;
  if ProgressPercent < 100 then
    r.right := r.left + Round(((r.right-r.left) * ProgressPercent) / 100);
  Canvas.FillRect(r);
  //t := IntToStr(ProgressPercent)+'%';
  //DrawTExt(Canvas.Handle,PChar(t),Length(t),
  //r,DT_CENTER or DT_NOPREFIX	or DT_VCENTER or DT_SINGLELINE);
end;

procedure THistoryGrid.DoProgress(Position, Max: Integer);
var
  dc: HDC;
  newp: Byte;
begin
  if not ShowProgress then begin
    IsCanvasClean := False;
    Invalidate;
    //InvalidateRect(Handle,@ProgressRect,False);
    ProgressPercent := 255;
    exit;
  end;

  if Max = 0 then exit;
  newp := (Position*100 div Max);
  if newp = ProgressPercent then exit;
  ProgressPercent := newp;
  if Position = 0 then exit;

  Paint;

  dc := GetDC(Handle);

  try
    BitBlt(dc,ProgressRect.Left,ProgressRect.Top,
    ProgressRect.Right-ProgressRect.Left,ProgressRect.Bottom-
    Progressrect.Top,Canvas.Handle,ProgressRect.Left,
    ProgressRect.Top,SRCCOPY);
  finally
    ReleaseDC(Handle,dc);
  end;
  Application.ProcessMessages;
end;

procedure THistoryGrid.WMSetCursor(var Message: TWMSetCursor);
var
  p: TPoint;
  NewCursor: TCursor;
begin
  inherited;
  if State <> gsIdle then exit;
  if Message.HitTest = Word(HTERROR) then exit;
  NewCursor := crDefault;
  p := ScreenToClient(Mouse.CursorPos);
  HintHitTests := GetHitTests(p.X,p.Y);
  if HintHitTests * [ghtButton,ghtLink] <> [] then
    NewCursor := crHandPoint;
  if Windows.GetCursor <> Screen.Cursors[NewCursor] then begin
    Windows.SetCursor(Screen.Cursors[NewCursor]);
    Message.Result := 1;
  end else
    Message.Result := 0;
end;

procedure THistoryGrid.WMSetFocus(var Message: TWMSetFocus);
var
  r: TRect;
begin
  if not ((csDestroying in ComponentState) or
    IsChild(Handle,Message.FocusedWnd)) then begin
    CheckBusy;
    if FHideSelection and FGridNotFocused then begin
      if SelCount > 0 then begin
        FRichCache.ResetItems(FSelItems);
        Invalidate;
      end;
    end else
    if (FSelected <> -1) and IsVisible(FSelected) then begin
      r := GetItemRect(Selected);
      InvalidateRect(Handle,@r,False);
    end;
  end;
  FGridNotFocused := False;
  inherited;
end;

procedure THistoryGrid.WMKillFocus(var Message: TWMKillFocus);
var
  r: TRect;
begin
  if not ((csDestroying in ComponentState) or
    IsChild(Handle,Message.FocusedWnd)) then begin
    if FHideSelection and not FGridNotFocused then begin
      if SelCount > 0 then begin
        FRichCache.ResetItems(FSelItems);
        Invalidate;
      end;
    end else
    if (FSelected <> -1) and IsVisible(FSelected) then begin
      r := GetItemRect(Selected);
      InvalidateRect(Handle,@r,False);
    end;
    FGridNotFocused := True;
  end;
  inherited;
end;

procedure THistoryGrid.WMCommand(var Message: TWMCommand);
begin
  inherited;
  {$IFDEF RENDER_RICH}
  if not (csDestroying in ComponentState) and
    (Message.Ctl = FRichInline.Handle) then begin
    case Message.NotifyCode of
      EN_SETFOCUS: begin
        if State <> gsInline then begin
          FGridNotFocused := False;
          Windows.SetFocus(Handle);
          FGridNotFocused := True;
          PostMessage(Handle,WM_SETFOCUS,Handle,0);
        end;
      end;
      EN_KILLFOCUS: begin
        if State = gsInline then begin
          CancelInline(False);
          PostMessage(Handle,WM_KILLFOCUS,Handle,0);
        end;
        Message.Result := 0;
      end;
    end;
  end;
  {$ENDIF}
end;

procedure THistoryGrid.ScrollBy(DeltaX, DeltaY: Integer);
begin
  inherited;
end;

procedure THistoryGrid.ScrollGridBy(Offset: Integer; Update: Boolean = True);
var
  previdx,idx,first: Integer;
  pos,SumHeight: Integer;
begin
  first := GetFirstVisible;
  if first = -1 then exit;
  SumHeight := -TopItemOffset;
  idx := first;

  while (Offset > 0) do begin
    LoadItem(idx,True);
    if SumHeight+FItems[idx].Height > Offset+ClientHeight then
      break;
    Inc(SumHeight,FItems[idx].Height);
    idx := GetDown(idx);
    if idx = -1 then begin
      // we scroll to the last item, let's SetSBPos do the job
      SetSBPos(MaxSBPos+1);
      Repaint;
      exit;
    end;
  end;

  SumHeight := -TopItemOffset;
  idx := first;
  while (Offset > 0) and (idx <> -1) and (idx >=0) and (idx < Count) do begin
    LoadItem(idx,True);
    if SumHeight + FItems[idx].Height > Offset then begin
      pos := GetIdx(idx);
      VertScrollBar.Position := pos;
      TopItemOffset := Offset - SumHeight;
      if Update then begin
        ScrollWindow(Handle,0,-Offset,nil,nil);
        UpdateWindow(Handle);
      end;
      break;
    end;
    Inc(SumHeight,FItems[idx].Height);
    idx := GetDown(idx);
  end;

  SumHeight := -TopItemOffset;
  while (Offset < 0) and (idx <> -1) and (idx >=0) and (idx < Count) do begin
    if SumHeight <= Offset then begin
      VertScrollBar.Position := GetIdx(idx);
      if GetUp(idx) = -1 then
        VertScrollBar.Position := 0;
      TopItemOffset := Offset - SumHeight;
      if Update then begin
        ScrollWindow(Handle,0,-Offset,nil,nil);
        UpdateWindow(Handle);
      end;
      break;
    end;
  previdx := idx;
  idx := GetUp(idx);
  if idx = -1 then begin
    VertScrollBar.Position := GetIdx(previdx);
    TopItemOffset := 0;
    // to lazy to calculate proper offset
    if Update then
      Repaint;
    break;
  end;
  LoadItem(idx,True);
  Dec(SumHeight,FItems[idx].Height);
  end;
end;

procedure THistoryGrid.ScrollToBottom;
begin
  if not BarAdjusted then AdjustScrollBar;
  SetSBPos(Count);
end;

procedure THistoryGrid.Delete(Item: Integer);
var
  i, NextItem, Temp, PrevSelCount: Integer;
begin
  if Item = -1 then exit;
  State := gsDelete;
  try
    PrevSelCount := SelCount;
    if Selected = Item then begin
      NextItem := -1;
      if Reversed then NextItem := GetNext(Item)
                  else NextItem := GetPrev(Item);
    end;
    DeleteItem(Item);
    if Selected = Item then begin
      FSelected := -1;
      if Reversed then Temp := GetPrev(NextItem)
                  else Temp := GetNext(NextItem);
      if Temp <> -1 then NextItem := Temp;
      if PrevSelCount = 1 then
        // rebuild FSelItems
        Selected := NextItem
      else if PrevSelCount > 1 then begin
        // don't rebuild, just change focus
        FSelected := NextItem;
        // check if we're out of SelItems
        if FSelected > Math.Max(FSelItems[High(FSelItems)],FSelItems[Low(FSelItems)]) then
          FSelected := Math.Max(FSelItems[High(FSelItems)],FSelItems[Low(FSelItems)]);
        if FSelected < Math.Min(FSelItems[High(FSelItems)],FSelItems[Low(FSelItems)]) then
          FSelected := Math.Min(FSelItems[High(FSelItems)],FSelItems[Low(FSelItems)]);
      end;
    end
    else begin
      if SelCount > 0 then begin
        if Item <= FSelected then Dec(FSelected);
      end;
    end;
    BarAdjusted := False;
    AdjustScrollBar;
    Invalidate;
  finally
    State := gsIdle;
  end;
end;

procedure THistoryGrid.DeleteAll;
var
  cur,max: Integer;
begin
  State := gsDelete;
  try
    BarAdjusted := False;

    FRichCache.ResetAllItems;
    SetLength(FSelItems,0);
    FSelected := -1;

    max := length(FItems)-1;
    cur := 0;

    ShowProgress := True;

    for cur := 0 to max do begin
      if Assigned(FItemDelete) then
        FItemDelete(Self,-1);
      DoProgress(cur,max);
      if cur = 0 then Invalidate;
    end;
    SetLength(FItems,0);

    AdjustScrollBar;
    ShowProgress := False;
    DoProgress(0,0);
    Invalidate;
    Update;
  finally
    State := gsIdle;
  end;
end;

const
  MIN_ITEMS_TO_SHOW_PROGRESS = 10;

procedure THistoryGrid.DeleteSelected;
var
  nextitem: Integer;
  temp: Integer;
  s,e,max,cur: Integer;
begin
  if SelCount = 0 then exit;

  State := gsDelete;
  try

    max := Length(FSelItems)-1;
    cur := 0;

    s := Min(FSelItems[0],FSelItems[High(FSelItems)]);

    e := Math.Max(FSelItems[0],FSelItems[High(FSelItems)]);

    nextitem := -1;

    if Reversed then
      nextitem := GetNext(s)
    else
      nextitem := GetPrev(s);

    ShowProgress := (Length(FSelItems) >= MIN_ITEMS_TO_SHOW_PROGRESS);
    while Length(FSelItems) <> 0 do begin
      DeleteItem(FSelItems[0]);
      if ShowProgress then DoProgress(cur,max);
      if (ShowProgress) and (cur = 0) then Invalidate;
      Inc(cur);
    end;


    BarAdjusted := False;
    AdjustScrollBar;

    if nextitem < 0 then nextitem := -1;
    FSelected := -1;
    if Reversed then
      temp := GetPrev(nextitem)
    else
      temp := GetNext(nextitem);
    if temp = -1 then
      Selected := nextitem
    else
      Selected := temp;

    if ShowProgress then begin
      ShowProgress := False;
      DoProgress(0,0);
    end
    else Invalidate;
    Update;
  finally
    State := gsIdle;
  end;
end;

function THistoryGrid.Search(Text: WideString; CaseSensitive: Boolean; FromStart: Boolean = False;
  SearchAll: Boolean = False; FromNext: Boolean = False; Down: Boolean = True): Integer;
var
  StartItem: Integer;
  C,Item: Integer;
begin
  Result := -1;

  if not CaseSensitive then
    Text := Tnt_WideUpperCase(Text);

  if Selected = -1 then begin
    FromStart := True;
    FromNext := False;
  end;

  if FromStart then begin
    if Down then
      StartItem := GetTopItem
    else
      StartItem := GetBottomItem;
  end
  else if FromNext then begin
    if Down then
      StartItem := GetNext(Selected)
    else
      StartItem := GetPrev(Selected);

    if StartItem = -1 then begin
      StartItem := Selected;
    end;
  end
  else begin
    StartItem := Selected;
    if Selected = -1 then
      StartItem := GetNext(-1,True);
  end;

  Item := StartItem;

  C := Count;
  CheckBusy;
  State := gsSearch;
  try
    while (Item >= 0) and (Item < C) do begin
      if CaseSensitive then begin
        // need to strip bbcodes
        if Pos(Text,FItems[Item].Text) <> 0 then begin
          Result := Item;
          break;
        end;
      end
      else begin
        // need to strip bbcodes
        if Pos(Text,Tnt_WideUpperCase(FItems[Item].Text)) <> 0 then begin
          Result := Item;
          break;
        end;
      end;

      if SearchAll then Inc(Item)
      else
      if Down then Item := GetNext(Item)
              else Item := GetPrev(Item);

      if item <> -1 then begin
        // prevent GetNext from drawing progress
        IsCanvasClean := True;
        ShowProgress := True;
        DoProgress(Item,C-1);
        ShowProgress := False;
      end;
    end;

    ShowProgress := False;
    DoProgress(0,0);
  finally
    State := gsIdle;
  end;
end;

procedure THistoryGrid.WMChar(var Message: TWMChar);
var
  Key: WideChar;
begin
  Key := GetWideCharFromWMCharMsg(Message);
  DoChar(Key,KeyDataToShiftState(Message.KeyData));
  SetWideCharForWMCharMsg(Message,Key);
  inherited;
  if FSavedKeyMessage.CharCode = 0 then exit;
  if Message.CharCode <> 0 then SendMsgFilterMessage(TMessage(Message))
end;

const
  BT_BACKSPACE = #8;
  // #9 -- TAB
  // #13 -- ENTER
  // #27 -- ESC
  ForbiddenChars: array[0..2] of WideChar = (#9,#13,#27);

procedure THistoryGrid.DoChar(var Ch: WideChar; ShiftState: TShiftState);
var
  ForbiddenChar: Boolean;
  i: Integer;
begin
  CheckBusy;
  ForbiddenChar := ((ssAlt in ShiftState) or (ssCtrl in ShiftState));
  i := 0;
  While (not ForbiddenChar) and (i<=High(ForbiddenChars)) do begin
    ForbiddenChar := (Ch = ForbiddenChars[i]);
    Inc(i);
  end;
  if ForbiddenChar then exit;
  if Assigned(FOnChar) then FOnChar(Self,Ch,ShiftState);
end;

procedure THistoryGrid.AddItem;
var
  i: Integer;
begin
  SetLength(FItems,Count+1);

  FRichCache.WorkOutItemAdded(0);

  for i := Length(FItems)-1 downto 1 do begin
    FItems[i] := FItems[i-1];
  end;

  FItems[0].MessageType := [mtUnknown];
  FItems[0].Height := -1;
  FItems[0].Text := '';
  // change selected here
  if Selected <> -1 then Inc(FSelected);
  for i := 0 to SelCount-1 do begin
    Inc(FSelItems[i]);
  end;
  BarAdjusted := False;
  AdjustScrollBar;
  // or window in background isn't repainted. weired
  //if IsVisible(0) then begin
    Invalidate;
  //end;
end;

procedure THistoryGrid.WMMouseWheel(var Message: TWMMouseWheel);
var
  i,off: Integer;
  code: DWord;
begin
  off := -(Message.WheelDelta div WHEEL_DELTA);
  if off > 0 then code := SB_LINEDOWN
             else code := SB_LINEUP;
  if FState = gsInline then
    FRichInline.Perform(EM_SCROLL,code,0)
  else
    Perform(WM_VSCROLL,code,0);
end;

procedure THistoryGrid.DeleteItem(Item: Integer);
var
  i: Integer;
  SelIdx: Integer;
begin
  // find item pos in selected array if it is there
  // and fix other positions becouse we have
  // to decrease some after we delete the item
  // from main array
  SelIdx := -1;
  FRichCache.WorkOutItemDeleted(Item);
  //if IsSelected(Item) then begin
  for i := 0 to SelCount-1 do begin
    if FSelItems[i] = Item then
      SelIdx := i
    else
    if FSelItems[i] > Item then
      Dec(FSelItems[i]);
  end;
  //end;

  // delete item from main array
  //for i := Item to Length(FItems)-2 do
  //  FItems[i] := FItems[i+1];
  if Item <> High(FItems) then begin
    Finalize(FItems[Item]);
    Move(FItems[Item+1],FItems[Item],(High(FItems)-Item)*SizeOf(FItems[0]));
    FillChar(FItems[High(FItems)],SizeOf(FItems[0]),0);
  end;
  SetLength(FItems,High(FItems));

  // if it was in selected array delete there also
  if SelIdx <> -1 then begin
    //for i := SelIdx to SelCount-2 do
    //  FSelItems[i] := FSelItems[i+1];
    if SelIdx <> High(FSelItems) then
      Move(FSelItems[SelIdx+1],FSelItems[SelIdx],(High(FSelItems)-SelIdx)*SizeOf(FSelItems[0]));
    SetLength(FSelItems,High(FSelItems));
  end;

  // tell others they should clear up that item too
  if Assigned(FItemDelete) then
    FItemDelete(Self,Item);
end;

procedure THistoryGrid.SaveAll(FileName: String; SaveFormat: TSaveFormat);
var
  i: Integer;
  fs: TFileStream;
begin
  if Count = 0 then
    raise Exception.Create('History is empty, nothing to save');
  State := gsSave;
  try
    fs := TFileStream.Create(FileName,fmCreate or fmShareExclusive);
    SaveStart(fs,SaveFormat,TxtFullLog);
    ShowProgress := True;
    for i := Count-1 downto 0 do begin
      SaveItem(fs,i,SaveFormat);
      DoProgress(Count-1-i,Count-1);
    end;
    SaveEnd(fs,SaveFormat);
    fs.Free;
    ShowProgress := False;
    DoProgress(0,0);
  finally
    State := gsIdle;
  end;
end;

procedure THistoryGrid.SaveSelected(FileName: String; SaveFormat: TSaveFormat);
var
  fs: TFileStream;
  i: Integer;
begin
  Assert((SelCount > 1),'Save Selection is available when more than 1 item is selected');
  State := gsSave;
  try
    fs := TFileStream.Create(FileName,fmCreate or fmShareExclusive);
    SaveStart(fs,SaveFormat,TxtPartLog);
    ShowProgress := True;
    if FSelItems[0] > FSelItems[High(FSelItems)] then
      for i := 0 to SelCount-1 do begin
        DoProgress(i,SelCount);
        SaveItem(fs,FSelItems[i],SaveFormat);
      end
    else
      for i := SelCount-1 downto 0 do begin
        DoProgress(SelCount-1-i,SelCount);
        SaveItem(fs,FSelItems[i],SaveFormat);
      end;
    SaveEnd(fs,SaveFormat);
    fs.Free;
    ShowProgress := False;
    DoProgress(0,0);
  finally
    State := gsIdle;
  end;
end;

const
css =
'h3 { color: #666666; text-align: center; font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 16pt; }'+#13#10+
'h4 { text-align: center; font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 14pt; }'+#13#10+
'h6 { font-weight: normal; color: #000000; text-align: center; font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 8pt; }'+#13#10+
'.mes { border-top-width: 1px; border-right-width: 0px; border-bottom-width: 0px;'+
'border-left-width: 0px; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; '+
'border-left-style: solid; border-top-color: #666666; border-bottom-color: #666666; '+
'padding: 4px; }'+#13#10+
'.text { clear: both; }'+#13#10;

xml =
'<?xml version="1.0" encoding="%s"?>'+#13#10+
'<!DOCTYPE IMHISTORY ['+#13#10+
'<!ELEMENT IMHISTORY (EVENT*)>'+#13#10+
'<!ELEMENT EVENT (CONTACT, FROM, TIME, DATE, PROTOCOL, ID?, TYPE, FILE?, URL?, MESSAGE?)>'+#13#10+
'<!ELEMENT CONTACT (#PCDATA)>'+#13#10+
'<!ELEMENT FROM (#PCDATA)>'+#13#10+
'<!ELEMENT TIME (#PCDATA)>'+#13#10+
'<!ELEMENT DATE (#PCDATA)>'+#13#10+
'<!ELEMENT PROTOCOL (#PCDATA)>'+#13#10+
'<!ELEMENT ID (#PCDATA)>'+#13#10+
'<!ELEMENT TYPE (#PCDATA)>'+#13#10+
'<!ELEMENT FILE (#PCDATA)>'+#13#10+
'<!ELEMENT URL (#PCDATA)>'+#13#10+
'<!ELEMENT MESSAGE (#PCDATA)>'+#13#10+
'<!ENTITY ME "%s">'+#13#10+
'%s'+
'<!ENTITY UNK "UNKNOWN">'+#13#10+
']>'+#13#10+
'<IMHISTORY>'+#13#10;

function ColorToCss(Color: TColor): String;
var
  first2, mid2, last2: String;
begin
  //Result := IntToHex(ColorToRGB(Color),6);
  Result := IntToHex(Color,6);
  if Length(Result) > 6 then SetLength(Result,6);
  // rotate for HTML color format from AA AB AC to AC AB AA
  First2 := Copy(Result,1,2);
  Mid2 := Copy(Result,3,2);
  Last2 := Copy(Result,5,2);
  Result := '#'+last2+mid2+first2;
end;

function FontToCss(Font: TFont): String;
var
w: String;
begin
  Result := 'font-family: '+Font.Name+', Tahoma, Verdana, Arial, sans-serif;';
  Result := Result+' font-size: '+IntToStr(Font.Size)+'pt;';
  if fsBold in Font.Style then w := 'bold'
                          else w := 'normal';
  Result := Result+' font-weight: '+w+';';
  if fsItalic in Font.Style then w := 'italic'
                            else w := 'normal';
  Result := Result+' font-style: '+w+';';
  Result := Result+' color: '+ColorToCss(Font.Color)+';';
end;

procedure THistoryGrid.SaveStart(Stream: TFileStream; SaveFormat: TSaveFormat; Caption: WideString);
var
  ProfileID,ContactID,Proto: WideString;

  procedure SaveHTML;
  var
    title,head1,head2: String;
    i: integer;
  begin
  title := UTF8Encode(WideFormat('%s [%s] - [%s]',[Caption,ProfileName,ContactName]));
  head1 := UTF8Encode(WideFormat('%s',[Caption]));
  head2 := UTF8Encode(WideFormat('%s (%s: %s) - %s (%s: %s)',[ProfileName,Proto,ProfileID,ContactName,Proto,ContactID]));
  WriteString(Stream,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'+#13#10);
  //if Options.RTLEnabled then WriteString(Stream,'<html dir="rtl">')
  if (RTLMode = hppRTLEnable) or ((RTLMode = hppRTLDefault) and Options.RTLEnabled) then
    WriteString(Stream,'<html dir="rtl">')
  else
    WriteString(Stream,'<html dir="ltr">');
  WriteString(Stream,'<head>'+#13#10);
  WriteString(Stream,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'+#13#10);
  WriteString(Stream,'<title>'+MakeTextHtmled(title)+'</title>'+#13#10);
  WriteString(Stream,'<style type="text/css"><!--'+#13#10);
  WriteString(Stream,css);

  //if Options.RTLEnabled then begin
  if (RTLMode = hppRTLEnable) or ((RTLMode = hppRTLDefault) and Options.RTLEnabled) then begin
    WriteString(Stream,'.nick { float: right; }'+#13#10);
    WriteString(Stream,'.date { float: left; clear: left; }'+#13#10);
  end else begin
    WriteString(Stream,'.nick { float: left; }'+#13#10);
    WriteString(Stream,'.date { float: right; clear: right; }'+#13#10);
  end;
  WriteString(Stream,'.nick#inc { '+FontToCss(Options.FontContact)+' }'+#13#10);
  WriteString(Stream,'.nick#out { '+FontToCss(Options.FontProfile)+' }'+#13#10);
  WriteString(Stream,'.date#inc { '+FontToCss(Options.FontIncomingTimestamp)+' }'+#13#10);
  WriteString(Stream,'.date#out { '+FontToCss(Options.FontOutgoingTimestamp)+' }'+#13#10);
  for i := 0 to High(Options.ItemOptions) do
    WriteString(Stream,'.mes#event'+intToStr(i)+' { background-color: '+
      ColorToCss(Options.ItemOptions[i].textColor)+'; '+
      FontToCss(Options.ItemOptions[i].textFont)+' }'+#13#10);
  if ShowHeaders then
    WriteString(Stream,'.mes#session { background-color: '+
      ColorToCss(Options.ColorSessHeader)+'; '+
      FontToCss(Options.FontSessHeader)+' }'+#13#10);
  WriteString(Stream,'--></style>'+#13#10+'</head><body>'+#13#10);
  WriteString(Stream,'<h4>'+MakeTextHtmled(head1)+'</h4>'+#13#10);
  WriteString(Stream,'<h3>'+MakeTextHtmled(head2)+'</h3>'+#13#10);
  end;

  procedure SaveXML;
  var
    mt: TMessageType;
    messages,enc: string;
  begin
    //enc := 'windows-'+IntToStr(GetACP);
    enc := 'utf-8';
    messages := '';
    for mt := Low(EventRecords) to High(EventRecords) do begin
      if not (mt in [mtIncoming,mtOutgoing,mtUnknown]) then
        messages := messages + Format('<!ENTITY %s "%s">'+#13#10,
          [EventRecords[mt].XML,
          UTF8Encode(TranslateWideW(EventRecords[mt].Name))]{TRANSLATE-IGNORE});
    end;
    WriteString(Stream,Format(xml,[enc,UTF8Encode(ProfileName),messages]));
  end;

  procedure SaveUnicode;
  begin
    WriteString(Stream,#255#254);
    WriteWideString(Stream,'###'#13#10);
    if Caption = '' then Caption := TxtHistExport;
    WriteWideString(Stream,WideFormat('### %s'#13#10,[Caption]));
    WriteWideString(Stream,WideFormat('### %s (%s: %s) - %s (%s: %s)'#13#10,[ProfileName,Proto,ProfileID,ContactName,Proto,ContactID]));
    WriteWideString(Stream,TxtGenHist1+#13#10);
    WriteWideString(Stream,'###'#13#10#13#10);
  end;

  procedure SaveText;
  begin
    WriteString(Stream,'###'#13#10);
    if Caption = '' then
      Caption := TxtHistExport;
    WriteString(Stream,WideToAnsiString(WideFormat('### %s'#13#10,[Caption]),Codepage));
    WriteString(Stream,WideToAnsiString(WideFormat('### %s (%s: %s) - %s (%s: %s)'#13#10,[ProfileName,Proto,ProfileID,ContactName,Proto,ContactID]),Codepage));
    WriteString(Stream,WideToAnsiString(TxtGenHist1+#13#10,Codepage));
    WriteString(Stream,'###'#13#10#13#10);
  end;

  procedure SaveRTF;
  begin
    FRichSaveItem := THPPRichEdit.CreateParented(Handle);
    FRichSave := THPPRichEdit.CreateParented(Handle);
    FRichSaveOLECB := TRichEditOleCallback.Create;
    FRichSave.Perform(EM_SETOLECALLBACK, 0, DWord(TRichEditOleCallback(FRichSaveOLECB) as IRichEditOleCallback));
  end;

begin
  Proto :=  AnsiToWideString(Protocol,Codepage);
  ProfileId := AnsiToWideString(GetContactID(0,Protocol,false),Codepage);
  ContactID := AnsiToWideString(GetContactID(Contact,Protocol,true),Codepage);
  case SaveFormat of
    sfHTML: SaveHTML;
    sfXML: SaveXML;
    sfRTF: SaveRTF;
    sfUnicode: SaveUnicode;
    sfText: SaveText;
  end;
end;

procedure THistoryGrid.SaveEnd(Stream: TFileStream; SaveFormat: TSaveFormat);

  procedure SaveHTML;
  begin
    WriteString(Stream,'<div class=mes></div>'+#13#10);
    WriteString(Stream,UTF8Encode(TxtGenHist2)+#13#10);
    WriteString(Stream,'</body></html>');
  end;

  procedure SaveXML;
  begin
    WriteString(Stream,'</IMHISTORY>');
  end;

  procedure SaveUnicode;
  begin
  ;
  end;

  procedure SaveText;
  begin
  ;
  end;

  procedure SaveRTF;
  begin
    FRichSave.Lines.SaveToStream(Stream);
    FRichSave.Perform(EM_SETOLECALLBACK, 0, 0);
    FRichSave.Destroy;
    FRichSaveItem.Destroy;
    FRichSaveOLECB.Free;
  end;

begin
  case SaveFormat of
    sfHTML: SaveHTML;
    sfXML: SaveXML;
    sfRTF: SaveRTF;
    sfUnicode: SaveUnicode;
    sfText: SaveText;
  end;
end;

procedure THistoryGrid.SaveItem(Stream: TFileStream; Item: Integer; SaveFormat: TSaveFormat);

  procedure MesTypeToStyle(mt: TMessageTypes; out mes_id,type_id: String);
  var
    i: integer;
    found:boolean;
  begin
    mes_id := 'unknown';
    if mtIncoming in mt then type_id := 'inc'
                        else type_id := 'out';
    i := 0;
    found := false;
    while (not found) and (i <= High(Options.ItemOptions)) do
      if (MessageTypesToDWord(Options.ItemOptions[i].MessageType) and MessageTypesToDWord(mt)) >= MessageTypesToDWord(mt) then
        found := true
      else Inc(i);
    mes_id := 'event'+intToStr(i);
  end;

  procedure SaveHTML;
  var
    cnt: String;
    mes_id,type_id: String;
    mes,time: WideString;
    txt: String;
  begin
    if mtIncoming in FItems[Item].MessageType then cnt := UTF8Encode(ContactName)
                                              else cnt := UTF8Encode(ProfileName);
    cnt := MakeTextHtmled(cnt+':');
    mes := FItems[Item].Text;
    if Options.RawRTFEnabled and IsRTF(FItems[Item].Text) then begin
      ApplyItemToRich(Item);
      mes := GetRichString(FRich.Handle,False);
    end;
    txt := MakeTextHtmled(UTF8Encode(mes));
    try
      txt := UrlHighlightHtml(txt);
    except
    end;
    if Options.BBCodesEnabled then begin
      try
        txt := DoSupportBBCodesHTML(txt);
      except
      end;
    end;
    MesTypeToStyle(FItems[Item].MessageType,mes_id,type_id);
    time := GetTime(Items[Item].Time);
    if ShowHeaders and FItems[Item].HasHeader then begin
      WriteString(Stream,'<div class=mes id=session>'+#13#10);
      WriteString(Stream,#9+'<div class=text>'+MakeTextHtmled(UTF8Encode(WideFormat(TxtSessions,[time])))+'</div>'+#13#10);
      WriteString(Stream,'</div>'+#13#10);
    end;
    WriteString(Stream,'<div class=mes id='+mes_id+'>'+#13#10);
    WriteString(Stream,#9+'<div class=nick id='+type_id+'>'+cnt+'</div>'+#13#10);
    WriteString(Stream,#9+'<div class=date id='+type_id+'>'+MakeTextHtmled(UTF8Encode(time))+'</div>'+#13#10);
    WriteString(Stream,#9+'<div class=text>'+#13#10#9+txt+#13#10#9+'</div>'+#13#10);
    WriteString(Stream,'</div>'+#13#10);
  end;

  procedure SaveXML;
  var
    XmlItem: TXMLItem;
  begin
    if not Assigned(FGetXMLData) then exit;
    FGetXMLData(Self,Item,XMlItem);
    WriteString(Stream,'<EVENT>'+#13#10);
    WriteString(Stream,#9+'<CONTACT>'+XmlItem.Contact+'</CONTACT>'+#13#10);
    WriteString(Stream,#9+'<FROM>'+XmlItem.From+'</FROM>'+#13#10);
    WriteString(Stream,#9+'<TIME>'+XmlItem.Time+'</TIME>'+#13#10);
    WriteString(Stream,#9+'<DATE>'+XmlItem.Date+'</DATE>'+#13#10);
    WriteString(Stream,#9+'<PROTOCOL>'+XmlItem.Protocol+'</PROTOCOL>'+#13#10);
    WriteString(Stream,#9+'<ID>'+XmlItem.Id+'</ID>'+#13#10);
    WriteString(Stream,#9+'<TYPE>'+XmlItem.EventType+'</TYPE>'+#13#10);
    if XmlItem.Mes <> '' then
      WriteString(Stream,#9+'<MESSAGE>'+XmlItem.Mes+'</MESSAGE>'+#13#10);
    if XmlItem.FileName <> '' then
      WriteString(Stream,#9+'<FILE>'+XmlItem.FileName+'</FILE>'+#13#10);
    if XmlItem.Url <> '' then
      WriteString(Stream,#9+'<URL>'+XmlItem.Url+'</URL>'+#13#10);
    WriteString(Stream,'</EVENT>'+#13#10);
  end;

  procedure SaveUnicode;
  var
    mes,date,cnt: WideString;
  begin
    if mtIncoming in FItems[Item].MessageType then cnt := ContactName
                                              else cnt := ProfileName;
    mes := FItems[Item].Text;
    if Options.RawRTFEnabled and IsRTF(mes) then begin
      ApplyItemToRich(Item);
      mes := GetRichString(FRich.Handle,False);
    end;
    if Options.BBCodesEnabled then
      mes := DoStripBBCodes(mes);
    date := GetTime(FItems[Item].Time);
    WriteWideString(Stream,WideFormat('[%s] %s:'#13#10,[date,cnt]));
    WriteWideString(Stream,mes+#13#10+#13#10);
  end;

  procedure SaveText;
  var
    date,cnt: String;
    mes: WideString;
  begin
    if mtIncoming in FItems[Item].MessageType then cnt := WideToAnsiString(ContactName,Codepage)
                                              else cnt := WideToAnsiString(ProfileName,Codepage);
    mes := FItems[Item].Text;
    if Options.RawRTFEnabled and IsRTF(mes) then begin
      ApplyItemToRich(Item);
      mes := GetRichString(FRich.Handle,False);
    end;
    if Options.BBCodesEnabled then
      mes := DoStripBBCodes(mes);
    date := WideToAnsiString(GetTime(FItems[Item].Time),Codepage);
    WriteString(Stream,Format('[%s] %s:'#13#10,[date,cnt]));
    WriteString(Stream,WideToAnsiString(mes,Codepage)+#13#10+#13#10);
  end;

  procedure SaveRTF;
  var
    RTFStream: String;
    Text: WideString;
  begin
    if mtIncoming in FItems[Item].MessageType then Text := ContactName
                                              else Text := ProfileName;
    Text := Text + ' ['+GetTime(FItems[Item].Time)+']:';
    RTFStream := '{\rtf1\par\b1 '+FormatString2RTF(Text)+'\b0\par}';
    SetRichRTF(FRichSave.Handle,RTFStream,true,false,false);
    ApplyItemToRich(Item,FRichSaveItem,false,false);
    GetRichRTF(FRichSaveItem.Handle,RTFStream,false,false,false,false);
    SetRichRTF(FRichSave.Handle,RTFStream,true,false,false);
  end;

begin
  LoadItem(Item,False);
  case SaveFormat of
    sfHTML: SaveHTML;
    sfXML: SaveXML;
    sfRTF: SaveRTF;
    sfUnicode: SaveUnicode;
    sfText: SaveText;
  end;
end;

procedure THistoryGrid.WriteString(fs: TFileStream; Text: String);
begin
  fs.Write(Text[1],Length(Text));
end;

procedure THistoryGrid.WriteWideString(fs: TFileStream; Text: WideString);
begin
  fs.Write(Text[1],Length(Text)*2);
end;

procedure THistoryGrid.CheckBusy;
begin
  if FState = gsInline then CancelInline;
  if FState <> gsIdle then
    raise EAbort.Create('Grid is busy');
end;

function THistoryGrid.GetSelItems(Index: Integer): Integer;
begin
  Result := FSelItems[Index];
end;

procedure THistoryGrid.SetSelItems(Index: Integer; Item: Integer);
begin
  AddSelected(Item);
end;

procedure THistoryGrid.SetState(const Value: TGridState);
begin
  FState := Value;
  if Assigned(FOnState) then
    FOnState(Self,FState);
end;

procedure THistoryGrid.SetReversed(const Value: Boolean);
var
  vis_idx: Integer;
begin
  if FReversed = Value then exit;
  if not Allocated then begin
    FReversed := Value;
    exit;
  end;
  if Selected = -1 then begin
    vis_idx := GetFirstVisible;
  end else begin
    vis_idx := Selected;
  end;
  FReversed := Value;

  //VertScrollBar.Position := getIdx(0);
  BarAdjusted := False;
  SetSBPos(GetIdx(0));
  AdjustScrollBar;
  MakeVisible(vis_idx);
  Invalidate;
  Update;
end;

procedure THistoryGrid.SetReversedHeader(const Value: Boolean);
var
  vis_idx: Integer;
begin
  if FReversedHeader = Value then exit;
  FReversedHeader := Value;
  if not Allocated then exit;
  Invalidate;
  Update;
end;

procedure THistoryGrid.SetRichRTL(RTL: Boolean; RichEdit: THPPRichEdit; ProcessTag: Boolean = true);
var
  pf: PARAFORMAT2;
  ExStyle: DWord;
begin
  // we use RichEdit.Tag here to save previous RTL state to prevent from
  // reapplying same state, because SetRichRTL is called VERY OFTEN
  // (from ApplyItemToRich)
  if (RichEdit.Tag = Integer(RTL)) and ProcessTag then exit;
  ZeroMemory(@pf,SizeOf(pf));
  pf.cbSize := SizeOf(pf);
  pf.dwMask := PFM_RTLPARA;
  ExStyle := DWORD(GetWindowLong(Richedit.Handle, GWL_EXSTYLE)) and
      not (WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_RIGHT or WS_EX_LEFT);
  if RTL then begin
    ExStyle := ExStyle or (WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_LEFT);
    pf.wReserved := PFE_RTLPARA;
  end else begin
    ExStyle := ExStyle or WS_EX_RIGHT;
    pf.wReserved := 0;
  end;
  RichEdit.Perform(EM_SETPARAFORMAT,0,integer(@pf));
  SetWindowLong(Richedit.Handle, GWL_EXSTYLE, ExStyle);
  if ProcessTag then
    RichEdit.Tag := Integer(RTL);
end;

(* Index to Position *)
function THistoryGrid.GetIdx(Index: Integer): Integer;
begin
  if Reversed then
    Result := Count-1-Index
  else
    Result := Index;
end;

function THistoryGrid.GetFirstVisible: Integer;
var
  Pos: Integer;
begin
  Pos := VertScrollBar.Position;
  if MaxSBPos > -1 then
    Pos := Min(MaxSBPos,VertScrollBar.Position);
  Result := GetDown(GetIdx(Pos-1));
  if Result = -1 then
    Result := GetUp(GetIdx(Pos+1));
end;

procedure THistoryGrid.SetMultiSelect(const Value: Boolean);
begin
  FMultiSelect := Value;
end;

{ ThgVertScrollBar }

procedure THistoryGrid.DoOptionsChanged;
var
  i: integer;
  ch,ph,pth,cth,sh: Integer;
  //pf: PARAFORMAT2;
begin
  // recalc fonts
  for i := 0 to Length(FItems)-1 do begin
    FItems[i].Height := -1;
  end;
  FRichCache.ResetAllItems;

  //pf.cbSize := SizeOf(pf);
  //pf.dwMask := PFM_RTLPARA;

  //RTLEnabled := Options.RTLEnabled;

  //if Options.RTLEnabled then begin
  {if (RTLMode = hppRTLEnable) or ((RTLMode = hppRTLDefault) and Options.RTLEnabled) then begin
    // redundant, we do it in ApplyItemToRich
    //SetRichRTL(True);
    //pf.wReserved := PFE_RTLPARA;
    // redundant, we do it PaintItem
    // Canvas.TextFlags := Canvas.TextFlags or ETO_RTLREADING;
  end else begin
    // redundant, we do it in ApplyItemToRich
    // SetRichRTL(False);
    //pf.wReserved := 0;
    // redundant, we do it PaintItem
    // Canvas.TextFlags := Canvas.TextFlags and not ETO_RTLREADING;
  end;}
  //SendMessage(FRich.Handle,EM_SETPARAFORMAT,0,integer(@pf));
  //SendMessage(FRichInline.Handle,EM_SETPARAFORMAT,0,integer(@pf));
  //FRich.Perform(EM_SETPARAFORMAT,0,integer(@pf));
  //FRichInline.Perform(EM_SETPARAFORMAT,0,integer(@pf));

  Canvas.Font := Options.FontProfile;
  ph := WideCanvasTextHeight(Canvas,'Wy');
  Canvas.Font := Options.FontContact;
  ch := WideCanvasTextHeight(Canvas,'Wy');
  Canvas.Font := Options.FontOutgoingTimestamp;
  pth := WideCanvasTextHeight(Canvas,'Wy');
  Canvas.Font := Options.FontIncomingTimestamp;
  cth := WideCanvasTextHeight(Canvas,'Wy');
  Canvas.Font := Options.FontSessHeader;
  sh := WideCanvasTextHeight(Canvas,'Wy');
  // find heighest and don't forget about icons
  PHeaderHeight := Max(ph,pth);
  CHeaderHeight := Max(ch,cth);
  SessHeaderHeight := sh+1+3*2;
  if Options.ShowIcons then begin
    CHeaderHeight := Max(CHeaderHeight,16);
    PHeaderHeight := Max(PHeaderHeight,16);
  end;

  Inc(CHeaderHeight,Padding);
  Inc(PHeaderHeight,Padding);

  SetRTLMode(RTLMode);

  BarAdjusted := False;
  AdjustScrollBar;
  Invalidate;
  Update; // cos when you change from Options it updates with lag
end;

{ ThgVertScrollBar }
procedure THistoryGrid.SetOptions(const Value: TGridOptions);
begin
  { disconnect from options }
  if Assigned(Options) then
    Options.DeleteGrid(Self);
  FOptions := Value;
  { connect to options }
  if Assigned(Options) then
    Options.AddGrid(Self);
  DoOptionsChanged;
end;

procedure THistoryGrid.SetRTLMode(const Value: TRTLMode);
var
  NewBiDiMode: TBiDiMode;
begin
  if FRTLMode <> Value then begin
    FRTLMode := Value;
    FRichCache.ResetAllItems;
    Repaint;
  end;
  if (RTLMode = hppRTLEnable) or ((RTLMode = hppRTLDefault) and Options.RTLEnabled) then
    NewBiDiMode := bdRightToLeft
  else
    NewBiDiMode := bdLeftToRight;
  if NewBiDiMode <> BiDiMode then begin
    BiDiMode := NewBiDiMode;
    if Assigned(FOnRTLChange) then
      OnRTLChange(Self,NewBiDiMode);
  end;
  // no need in it?
  // cause we set rich's RTL in ApplyItemToRich and
  // canvas'es RTL in PaintItem
  // DoOptionsChanged;
end;

{$IFDEF CUST_SB}
procedure THistoryGrid.SetSBPos(Position: Integer);
var
  SumHeight: Integer;
  DoAdjust: Boolean;
  idx: Integer;
begin
  TopItemOffset := 0;
  VertScrollBar.Position := Position;
  AdjustScrollBar;
  if GetUp(GetIdx(VertScrollBar.Position)) = -1 then
    VertScrollBar.Position := 0;
  if MaxSBPos = -1 then exit;
  if VertScrollBar.Position > MaxSBPos then begin
    SumHeight := 0;
    idx := GetIdx(Length(FItems)-1);
    repeat
      LoadItem(idx,True);
      if IsMatched(idx) then
        Inc(SumHeight,FItems[idx].Height);
      idx := GetUp(idx);
      if idx = -1 then break;
    until ((SumHeight >= ClientHeight) or (idx < 0) or (idx >= Length(FItems)));
    if SumHeight > ClientHeight then begin
      TopItemOffset := SumHeight-ClientHeight;
      //Repaint;
    end;
  end;
  {
  if Allocated and VertScrollBar.Visible then begin
    idx := GetFirstVisible;
    SumHeight := -TopItemOffset;
    DoAdjust := False;
    while (idx <> -1) do begin
      DoAdjust := True;
      LoadItem(idx,True);
      if SumHeight + FItems[idx].Height >= ClientHeight then begin
        DoAdjust := False;
        break;
      end;
      Inc(Sumheight,FItems[idx].Height);
      idx := GetDown(idx);
    end;
    if DoAdjust then begin
      AdjustScrollBar;
      ScrollGridBy(-(ClientHeight-SumHeight),False);

    end;
      //TopItemOffset := TopItemOffset + (ClientHeight-SumHeight);
  end;}
end;

procedure THistoryGrid.SetVertScrollBar(const Value: TVertScrollBar);
begin
  FVertScrollBar.Assign(Value);
end;

{$ENDIF}

procedure THistoryGrid.UpdateFilter;
begin
  if not Allocated then exit;
  CheckBusy;
  FRichCache.ResetItems(FSelItems);
  SetLength(FSelItems,0);
  State := gsLoad;
  try
    VertScrollBar.Visible := True;
    VertScrollBar.Range := Count + ClientHeight -1;
    BarAdjusted := False;
    if (FSelected = -1) or (not IsMatched(FSelected)) then begin
      ShowProgress := True;
      try
        if FSelected <> -1 then begin
          FSelected := GetDown(FSelected);
          if FSelected = -1 then
            FSelected := GetUp(FSelected);
          // we have multiple selection sets
          //Selected := FSelected;
        end
        else begin
          FSelected := 0;
          SetSBPos(GetIdx(0));
          if Reversed then
            // we have multiple selection sets
            FSelected := GetPrev(-1)
          else
            // we have multiple selection sets
            FSelected := GetNext(-1);
        end;
      finally
        ShowProgress := False;
      end;
    end;
    AdjustScrollBar;
  finally
    State := gsIdle;
    Selected := FSelected;
  end;
  Repaint;
end;

function THistoryGrid.GetHitTests(X, Y: Integer): TGridHitTests;
var
  Item: Integer;
  ItemRect: TRect;
  HeaderHeight: Integer;
  HeaderRect,SessRect: TRect;
  ButtonRect: TRect;
  p: TPoint;
  RTL: Boolean;
  Sel: Boolean;
  FullHeader: Boolean;
  TimestampOffset: Integer;

  function IsLinkAtPoint(RichEditRect: TRect): Boolean;
  var
    p: TPoint;
    cr: CHARRANGE;
    cf: CHARFORMAT2;
    cp: DWord;
    res: DWord;
    AnsiUrl: String;
  begin
    p := Point(x - RichEditRect.Left,y - RichEditRect.Top);

    ApplyItemToRich(Item);
    cp := FRich.Perform(EM_CHARFROMPOS,0,LPARAM(@p));
    cr.cpMin := cp;
    cr.cpMax := cp+1;
    FRich.Perform(EM_EXSETSEL,0,LPARAM(@cr));

    ZeroMemory(@cf,SizeOf(cf));
    cf.cbSize := SizeOf(cf);
    cf.dwMask := CFM_LINK;

    res := FRich.Perform(EM_GETCHARFORMAT,SCF_SELECTION,LPARAM(@cf));
    if res <> cf.dwMask then exit;

    Result := (cf.dwEffects and CFE_LINK) > 0;
  end;

begin
  Result := [];
  FHintRect := Rect(0,0,0,0);
  Item := FindItemAt(X,Y);
  if Item <> -1 then
    Include(Result,ghtItem)
  else
    exit;

  FullHeader := not (FGroupLinked and FItems[Item].LinkedToPrev);
  ItemRect := GetItemRect(Item);
  RTL := GetItemRTL(Item);
  Sel := IsSelected(Item);
  p := Point(x,y);

  if FullHeader and (ShowHeaders) and (ExpandHeaders) and (FItems[Item].HasHeader) then begin
    if Reversed xor ReversedHeader then begin
      SessRect := Rect(ItemRect.Left,ItemRect.Top,ItemRect.Right,ItemRect.Top+SessHeaderHeight);
      Inc(ItemRect.Top,SessHeaderHeight);
    end
    else begin
      SessRect := Rect(ItemRect.Left,ItemRect.Bottom - SessHeaderHeight-1,ItemRect.Right,ItemRect.Bottom-1);
      Dec(ItemRect.Bottom,SessHeaderHeight);
    end;
    if PtInRect(SessRect,p) then begin
      Include(Result,ghtSession);
      InflateRect(SessRect,-3,-3);
      if RTL then
        ButtonRect := Rect(SessRect.Left,SessRect.Top,SessRect.Left+16,SessRect.Bottom)
      else
        ButtonRect := Rect(SessRect.Right-16,SessRect.Top,SessRect.Right,SessRect.Bottom);
      if PtInRect(ButtonRect,p) then begin
        Include(Result,ghtSessHideButton);
        Include(Result,ghtButton);
        FHintRect := ButtonRect;
      end;
    end;
  end;

  Dec(ItemRect.Bottom); // divider
  InflateRect(ItemRect,-Padding,-Padding); // paddings

  if FullHeader then begin
    Dec(ItemRect.Top,Padding);
    Inc(ItemRect.Top,Padding div 2);

    if mtIncoming in FItems[Item].MessageType then
      HeaderHeight := CHeaderHeight
    else
      HeaderHeight := PHeaderHeight;

    HeaderRect := Rect(ItemRect.Left,ItemRect.Top,ItemRect.Right,ItemRect.Top + HeaderHeight);
    Inc(ItemRect.Top,HeaderHeight+(Padding - (Padding div 2)));
    if PtInRect(HeaderRect,p) then begin
     Include(Result,ghtHeader);
     if (ShowHeaders) and (not ExpandHeaders) and (FItems[Item].HasHeader) then begin
       if RTL then
         ButtonRect := Rect(HeaderRect.Right-16,HeaderRect.Top,HeaderRect.Right,HeaderRect.Bottom)
       else
         ButtonRect := Rect(HeaderRect.Left,HeaderRect.Top,HeaderRect.Left+16,HeaderRect.Bottom);
       if PtInRect(ButtonRect,p) then begin
         Include(Result,ghtSessShowButton);
         Include(Result,ghtButton);
         FHintRect := ButtonRect;
       end;
     end;
     if ShowBookmarks and (Sel or FItems[Item].Bookmarked) then begin
       //TimeStamp := GetTime(FItems[Item].Time);
       //Canvas.Font.Assign(Options.FontTimeStamp);
       if mtIncoming in FItems[Item].MessageType then
         Canvas.Font.Assign(Options.FontIncomingTimestamp)
       else
         Canvas.Font.Assign(Options.FontOutgoingTimestamp);
       TimestampOffset := WideCanvasTextWidth(Canvas,GetTime(FItems[Item].Time)) + Padding;
        if RTL then
         ButtonRect := Rect(HeaderRect.Left+TimestampOffset,HeaderRect.Top,HeaderRect.Left+TimestampOffset+16,HeaderRect.Bottom)
       else
         ButtonRect := Rect(HeaderRect.Right-16-TimestampOffset,HeaderRect.Top,HeaderRect.Right-TimestampOffset,HeaderRect.Bottom);
       if PtInRect(ButtonRect,p) then begin
         Include(Result,ghtBookmark);
         Include(Result,ghtButton);
         FHintRect := ButtonRect;
       end;
      end;
    end;
   end;

  if PtInRect(ItemRect,p) then begin
    Include(Result,ghtText);
    if IsLinkAtPoint(ItemRect) then
      Include(Result,ghtLink);
      //FHintRect := Rect(0,0,0,0);
  end;
end;

procedure THistoryGrid.EditInline(Item: Integer);
var
  r: TRect;
  //cr: CHARRANGE;
begin
  if State = gsInline then CancelInline(False);
  MakeVisible(Item);
  r := GetRichEditRect(Item);
  if IsRectEmpty(r) then exit;

  // dunno why, but I have to fix it by 1 pixel
  // or positioning will be not perfectly correct
  // who knows why? i want to know! I already make corrections of margins!
  //Dec(r.left,1);
  Inc(r.right,1);

  FRichInline.Top := r.top;
  FRichInline.Left := r.left;
  FRichInline.Width := r.right - r.left;
  FRichInline.Height := r.Bottom - r.top;

  // below is not optimal way to show rich edit
  // (ie me better show it after applying item),
  // but it's done because now when we have OnProcessItem
  // event grid state is gsInline, which is how it should be
  // and you can't set it inline before setting focus
  // because of CheckBusy abort exception
  // themiron 03.10.2006. don't need to, 'cose there's check
  // if inline richedit got the focus

  //FRichInline.Show;
  //FRichInline.SetFocus;
  //State := gsInline;

  State := gsInline;
  ApplyItemToRich(Item, FRichInline);
  FRichInline.SelStart := 0;
  //cr.cpMin := 0;
  //cr.cpMax := 0;
  //FRichInline.Perform(EM_EXSETSEL,0,LPARAM(@cr));
  //FRichInline.Perform(EM_SCROLLCARET, 0, 0);
  FRichInline.Show;
  FRichInline.SetFocus;
end;

procedure THistoryGrid.CancelInline(DoSetFocus: boolean = true);
begin
  if State <> gsInline then exit;
  State := gsIdle;
  FRichInline.Hide;
  if DoSetFocus then Windows.SetFocus(Handle) ;
end;

procedure THistoryGrid.RemoveSelected(Item: Integer);
begin
  IntSortedArray_Remove(TIntArray(FSelItems),Item);
  FRichCache.ResetItem(Item);
end;

procedure THistoryGrid.ResetItem(Item: Integer);
begin
  // we need to adjust scrollbar after ResetItem if GetIdx(Item) >= MaxSBPos
  // as it's currently used to handle deletion with headers, adjust
  // is run after deletion ends, so no point in doing it here
  if IsUnknown(Item) then exit;
  FItems[Item].Height := -1;
  FItems[Item].MessageType := [mtUnknown];
  FRichCache.ResetItem(Item);
end;

procedure THistoryGrid.OnInlineOnExit(Sender: TObject);
begin
  CancelInline;
end;

procedure THistoryGrid.OnInlineOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ((Key = VK_ESCAPE) or (Key = VK_RETURN)) then begin
    CancelInline;
    Key := 0;
  end else
  if Assigned(FOnInlineKeyDown) then
    FOnInlineKeyDown(Sender,Key,Shift);
end;

procedure THistoryGrid.OnInlineOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not FRichInline.Visible then begin
    CancelInline;
    Key := 0;
  end else

  if (Key = VK_APPS) or ((Key= VK_F10) and (ssShift in Shift)) then begin
    if Assigned(FOnInlinePopup) then FOnInlinePopup(Sender);
    Key := 0;
  end else

  if Assigned(FOnInlineKeyUp) then
    FOnInlineKeyUp(Sender,Key,Shift);
end;

procedure THistoryGrid.OnInlineOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ;
end;

procedure THistoryGrid.OnInlineOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbRight) and Assigned(FOnInlinePopup) then
    FOnInlinePopup(Sender);
end;

function THistoryGrid.GetRichEditRect(Item: Integer; DontClipTop: Boolean): TRect;
var
  res: TRect;
  hh: Integer;
begin
  Result := Rect(0,0,0,0);
  if Item = -1 then exit;
  Result := GetItemRect(Item);
  Inc(Result.Left,Padding);
  Dec(Result.Right,Padding);
  /// avatars!!!
  //Dec(Result.Right,64+Padding);
  if FGroupLinked and FItems[Item].LinkedToPrev then
    hh := 0
  else
  if mtIncoming in FItems[Item].MessageType then
    hh := CHeaderHeight
  else
    hh := PHeaderHeight;
  Inc(Result.Top,hh+Padding);
  Dec(Result.Bottom,Padding+1);
  if (Items[Item].HasHeader) and (ShowHeaders) and (ExpandHeaders) then begin
    if Reversed xor ReversedHeader then
      Inc(Result.Top,SessHeaderHeight)
    else
      Dec(Result.Bottom,SessHeaderHeight);
  end;
  res := ClientRect;
  {$IFDEF DEBUG}
  OutputDebugString(PChar(Format('GetRichEditRect client: Top:%d Left:%d Bottom:%d Right:%d',[res.Top,res.Left,res.Bottom,res.Right])));
  OutputDebugString(PChar(Format('GetRichEditRect item_2: Top:%d Left:%d Bottom:%d Right:%d',[Result.Top,Result.Left,Result.Bottom,Result.Right])));
  {$ENDIF}
  if DontClipTop and (Result.Top < res.Top) then res.Top := Result.Top;
  IntersectRect(Result,res,Result);
end;

function THistoryGrid.SearchItem(ItemID: Integer): Integer;
var
  i,FirstItem: Integer;
  found: Boolean;
begin
  if not Assigned(OnSearchItem) then
    raise Exception.Create('You must handle OnSearchItem event to use SearchItem function');
  Result := -1;
  State := gsSearchItem;
  try
    FirstItem := GetNext(-1,True);
    State := gsSearchItem;
    ShowProgress := True;
    for i := 0 to Count-1 do begin
      if IsUnknown(i) then
        LoadItem(i,False);
      found := False;
      OnSearchItem(Self,i,ItemID,found);
      if found then begin
        Result := i;
        break;
      end;
      DoProgress(i+1,Count);
    end;
    ShowProgress := False;
  finally
    State := gsIdle;
  end;
end;

procedure THistoryGrid.SetBorderStyle(Value: TBorderStyle);
var
  Style, ExStyle: DWord;
begin
  if FBorderStyle = Value then exit;
  FBorderStyle := Value;
  if HandleAllocated then begin
    Style := DWORD(GetWindowLong(Handle, GWL_STYLE)) and WS_BORDER;
    ExStyle := DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) and not WS_EX_CLIENTEDGE;
    if Ctl3D and NewStyleControls and (FBorderStyle = bsSingle) then begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    SetWindowLong(Handle, GWL_STYLE, Style);
    SetWindowLong(Handle, GWL_EXSTYLE, ExStyle);
  end;
end;

procedure THistoryGrid.CMBiDiModeChanged(var Message: TMessage);
var
  ExStyle: DWORD;
begin
  //inherited;
  if HandleAllocated then begin
    ExStyle := DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) and
      not (WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_RIGHT or WS_EX_LEFT);
    AddBiDiModeExStyle(ExStyle);
    SetWindowLong(Handle, GWL_EXSTYLE, ExStyle);
  end;
end;

procedure THistoryGrid.CMCtl3DChanged(var Message: TMessage);
var
  Style, ExStyle: DWord;
begin
  if HandleAllocated then begin
    Style := DWORD(GetWindowLong(Handle, GWL_STYLE)) and WS_BORDER;
    ExStyle := DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) and not WS_EX_CLIENTEDGE;
    if Ctl3D and NewStyleControls and (FBorderStyle = bsSingle) then begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    SetWindowLong(Handle, GWL_STYLE, Style);
    SetWindowLong(Handle, GWL_EXSTYLE, ExStyle);
  end;
end;

procedure THistoryGrid.SetHideSelection(const Value: Boolean);
begin
  if FHideSelection = Value then exit;
  FHideSelection := Value;
  if FGridNotFocused and (SelCount > 0) then begin
    FRichCache.ResetItems(FSelItems);
    Invalidate;
  end;
end;

function THistoryGrid.GetProfileName: WideString;
begin
  if Assigned(Options) and Options.ForceProfileName then
    Result := Options.ProfileName
  else
    Result := FProfileName;
end;

{ TGridOptions }

procedure TGridOptions.AddGrid(Grid: THistoryGrid);
var
  i: Integer;
begin
  for i := 0 to Length(Grids)-1 do
    if Grids[i] = Grid then exit;
  SetLength(Grids,Length(Grids)+1);
  Grids[High(Grids)] := Grid;
end;

constructor TGridOptions.Create;
begin
  inherited;

  FRTLEnabled := False;
  FShowIcons := False;
  //FShowAvatars := False;

  FSmileysEnabled := False;
  FBBCodesEnabled := False;
  FMathModuleEnabled := False;
  FRawRTFEnabled := False;
  FAvatarsHistoryEnabled := False;

  FOpenDetailsMode := False;

  FProfileName := '';
  FForceProfileName := False;

  FTextFormatting := True;

  FLocks := 0;
  Changed := 0;

  //FIconOther := TIcon.Create;
  //FIconOther.OnChange := FontChanged;
  //FIconFile := TIcon.Create;
  //FIconFile.OnChange := FontChanged;
  //FIconUrl := TIcon.Create;
  //FIconUrl.OnChange := FontChanged;
  //FIconMessage := TIcon.Create;
  //FIconMessage.OnChange := FontChanged;

  FFontContact := TFont.Create;
  FFontContact.OnChange := FontChanged;
  FFontProfile := TFont.Create;
  FFontProfile.OnChange := FontChanged;
  FFontIncomingTimestamp := TFont.Create;
  FFontIncomingTimestamp.OnChange := FontChanged;
  FFontOutgoingTimestamp := TFont.Create;
  FFontOutgoingTimestamp.OnChange := FontChanged;
  FFontSessHeader := TFont.Create;
  FFontSessHeader.OnChange := FontChanged;
  FFontMessage := TFont.Create;
  FFontMessage.OnChange := FontChanged;

  //FItemFont := TFont.Create;

end;

procedure TGridOptions.DeleteGrid(Grid: THistoryGrid);
var
  i: Integer;
  idx: Integer;
begin
  idx := -1;
  for i := 0 to Length(Grids)-1 do
    if grids[i] = grid then begin
      idx := i;
      break;
      end;
  if idx = -1 then exit;
  for i := idx to Length(Grids)-2 do
    grids[i] := grids[i+1];
  SetLength(Grids,Length(Grids)-1);
end;

destructor TGridOptions.Destroy;
var
  i: Integer;
begin
  FFontContact.Free;
  FFontProfile.Free;
  FFontIncomingTimestamp.Free;
  FFontOutgoingTimestamp.Free;
  FFontSessHeader.Free;
  FFontMessage.Free;
  //FIconUrl.Free;
  //FIconMessage.Free;
  //FIconFile.Free;
  //FIconOther.Free;
  for i := 0 to Length(FItemOptions) - 1 do begin
    FItemOptions[i].textFont.Free;
  end;
  //SetLength(FItemOptions,0);
  Finalize(FItemOptions);
  //SetLength(Grids,0);
  Finalize(Grids);
  inherited;
end;

procedure TGridOptions.DoChange;
var
  i: Integer;
begin
  Inc(Changed);
  if FLocks > 0 then exit;
  for i := 0 to Length(Grids)-1 do
    Grids[i].DoOptionsChanged;
  Changed := 0;
end;

procedure TGridOptions.EndChange(const Forced: Boolean = False);
begin
  if FLocks = 0 then exit;
  Dec(FLocks);
  if Forced then Inc(Changed);
  if (FLocks = 0) and (Changed > 0) then DoChange;
end;

procedure TGridOptions.FontChanged(Sender: TObject);
begin
  DoChange;
end;

function TGridOptions.AddItemOptions: integer;
var
  i: integer;
begin
  i := Length(FItemOptions);
  SetLength(FItemOptions,i+1);
  FItemOptions[i].MessageType := [mtOther];
  FItemOptions[i].textFont := TFont.Create;
  //FItemOptions[i].textFont.Assign(FItemFont);
  //FItemOptions[i].textColor := clWhite;
  Result := i;
end;

function TGridOptions.GetItemOptions(Mes: TMessageTypes; out textFont: TFont; out textColor: TColor): integer;
var
  i: integer;
begin
  i := 0;
  while i <= High(FItemOptions) do
    if (MessageTypesToDWord(FItemOptions[i].MessageType) and MessageTypesToDWord(Mes)) >= MessageTypesToDWord(Mes) then begin
      textFont := FItemOptions[i].textFont;
      textColor := FItemOptions[i].textColor;
      Result := i;
      break;
    end else begin
      if mtOther in FItemOptions[i].MessageType then begin
        textFont := FItemOptions[i].textFont;
        textColor := FItemOptions[i].textColor;
        Result := i;
      end;
      Inc(i);
    end;
end;

function TGridOptions.GetLocked: Boolean;
begin
  Result := (FLocks > 0);
end;

procedure TGridOptions.SetColorDivider(const Value: TColor);
begin
  if FColorDivider = Value then exit;
  FColorDivider := Value;
  DoChange;
end;

procedure TGridOptions.SetColorSelectedText(const Value: TColor);
begin
  if FColorSelectedText = Value then exit;
  FColorSelectedText := Value;
  DoChange;
end;

procedure TGridOptions.SetColorSelected(const Value: TColor);
begin
  if FColorSelected = Value then exit;
  FColorSelected := Value;
  DoChange;
end;

procedure TGridOptions.SetColorSessHeader(const Value: TColor);
begin
  if FColorSessHeader = Value then exit;
  FColorSessHeader := Value;
  DoChange;
end;

procedure TGridOptions.SetDateTimeFormat(const Value: String);
var
  NewValue: String;
begin
  NewValue := Value;
  try
    FormatDateTime(NewValue,Now);
  except
    NewValue := DEFFORMAT_DATETIME;
  end;
  if FDateTimeFormat = NewValue then exit;
  FDateTimeFormat := NewValue;
  DoChange;
end;

procedure TGridOptions.SetTextFormatting(const Value: Boolean);
var
  i: integer;
begin
  if FTextFormatting = Value then exit;
  FTextFormatting := Value;
  if FLocks > 0 then exit;
  try
    for i := 0 to Length(Grids)-1 do
      Grids[i].ProcessInline := Value;
  finally
    if Assigned(FOnTextFormatting) then FOnTextFormatting(Value);
  end;
end;

procedure TGridOptions.SetColorBackground(const Value: TColor);
begin
  if FColorBackground = Value then exit;
  FColorBackground := Value;
  DoChange;
end;

//procedure TGridOptions.SetIconOther(const Value: TIcon);
//begin
//FIconOther.Assign(Value);
//FIconOther.OnChange := FontChanged;
//DoChange;
//end;

//procedure TGridOptions.SetIconFile(const Value: TIcon);
//begin
//FIconFile.Assign(Value);
//FIconFile.OnChange := FontChanged;
//DoChange;
//end;

//procedure TGridOptions.SetIconMessage(const Value: TIcon);
//begin
//FIconMessage.Assign(Value);
//FIconMessage.OnChange := FontChanged;
//DoChange;
//end;

//procedure TGridOptions.SetIconUrl(const Value: TIcon);
//begin
//FIconUrl.Assign(Value);
//FIconUrl.OnChange := FontChanged;
//DoChange;
//end;

procedure TGridOptions.SetShowIcons(const Value: Boolean);
begin
  if FShowIcons = Value then exit;
  FShowIcons := Value;
  Self.StartChange;
  try
    if Assigned(FOnShowIcons) then FOnShowIcons;
    DoChange;
  finally
    Self.EndChange;
  end;
end;

procedure TGridOptions.SetRTLEnabled(const Value: Boolean);
begin
  if FRTLEnabled = Value then exit;
  FRTLEnabled := Value;
  Self.StartChange;
  try
    DoChange;
  finally
    Self.EndChange;
  end;
end;

{procedure TGridOptions.SetShowAvatars(const Value: Boolean);
begin
  if FShowAvatars = Value then exit;
  FShowAvatars := Value;
  Self.StartChange;
  try
    DoChange;
  finally
    Self.EndChange;
  end;
end;}

procedure TGridOptions.SetBBCodesEnabled(const Value: Boolean);
begin
  if FBBCodesEnabled = Value then exit;
  FBBCodesEnabled := Value;
  Self.StartChange;
  try
    DoChange;
  finally
    Self.EndChange;
  end;
end;

procedure TGridOptions.SetSmileysEnabled(const Value: Boolean);
begin
  if FSmileysEnabled = Value then exit;
  FSmileysEnabled := Value;
  Self.StartChange;
  try
    DoChange;
  finally
    Self.EndChange;
  end;
end;

procedure TGridOptions.SetMathModuleEnabled(const Value: Boolean);
begin
  if FMathModuleEnabled = Value then exit;
  FMathModuleEnabled := Value;
  Self.StartChange;
  try
    DoChange;
  finally
    Self.EndChange;
  end;
end;

procedure TGridOptions.SetRawRTFEnabled(const Value: Boolean);
begin
  if FRawRTFEnabled = Value then exit;
  FRawRTFEnabled := Value;
  Self.StartChange;
  try
    DoChange;
  finally
    Self.EndChange;
  end;
end;

procedure TGridOptions.SetAvatarsHistoryEnabled(const Value: Boolean);
begin
  if FAvatarsHistoryEnabled = Value then exit;
  FAvatarsHistoryEnabled := Value;
  Self.StartChange;
  try
    DoChange;
  finally
    Self.EndChange;
  end;
end;

procedure TGridOptions.SetFontContact(const Value: TFont);
begin
  FFontContact.Assign(Value);
  FFontContact.OnChange := FontChanged;
  DoChange;
end;

procedure TGridOptions.SetFontProfile(const Value: TFont);
begin
  FFontProfile.Assign(Value);
  FFontProfile.OnChange := FontChanged;
  DoChange;
end;

procedure TGridOptions.SetFontIncomingTimestamp(const Value: TFont);
begin
  FFontIncomingTimestamp.Assign(Value);
  FFontIncomingTimestamp.OnChange := FontChanged;
  DoChange;
end;

procedure TGridOptions.SetFontOutgoingTimestamp(const Value: TFont);
begin
  FFontOutgoingTimestamp.Assign(Value);
  FFontOutgoingTimestamp.OnChange := FontChanged;
  DoChange;
end;

procedure TGridOptions.SetFontSessHeader(const Value: TFont);
begin
  FFontSessHeader.Assign(Value);
  FFontSessHeader.OnChange := FontChanged;
  DoChange;
end;

procedure TGridOptions.SetFontMessage(const Value: TFont);
begin
  FFontMessage.Assign(Value);
  FFontMessage.OnChange := FontChanged;
  DoChange;
end;

procedure TGridOptions.StartChange;
begin
  Inc(FLocks);
end;

procedure TGridOptions.SetProfileName(const Value: WideString);
begin
  if Value = FProfileName then exit;
  FProfileName := Value;
  FForceProfileName := (Value <> '');
  DoChange;
end;

{ TRichCache }

procedure TRichCache.ApplyItemToRich(Item: PRichItem);
var
  str: String;
begin
  //str := 'Apply item ['+IntToStr(Item.GridItem)+'] for "'+Copy(Item.Rich.Text,1,15)+'"';
  //OutputDebugString(PChar(str));
  // force to send the size:
  FRichHeight := -1;
  Grid.ApplyItemToRich(Item^.GridItem,Item^.Rich);
  SendMessage(Item^.Rich.Handle,EM_SETEVENTMASK,0,ENM_REQUESTRESIZE);
  SendMessage(Item^.Rich.Handle,EM_REQUESTRESIZE,0,0);
  //if FRichHeight <= 0 then begin
    //Grid.ApplyItemToRich(Item^.GridItem,Item^.Rich);
    //SendMessage(Item^.Rich.Handle,EM_REQUESTRESIZE,0,0);
  //end;
  SendMessage(Item^.Rich.Handle,EM_SETEVENTMASK,0,RichEventMasks);
  Assert(FRichHeight > 0, 'RichCache.ApplyItemToRich: rich is still <= 0 height');
end;

function TRichCache.CalcItemHeight(GridItem: Integer): Integer;
var
  Item: PRichItem;
begin
  Item := RequestItem(GridItem);
  Assert(Item <> nil);
  Result := Item^.Height;
end;

constructor TRichCache.Create(AGrid: THistoryGrid);
var
  i: Integer;
  RichItem: PRichItem;
  dc: HDC;
begin
  inherited Create;

  FRichWidth := -1;
  FRichHeight := -1;
  Grid := AGrid;
  // cache size:
  SetLength(Items,20);

  RichEventMasks := ENM_LINK;

  dc := GetDC(0);
  LogX := GetDeviceCaps(dc, LOGPIXELSX);
  LogY := GetDeviceCaps(dc, LOGPIXELSY);
  ReleaseDC(0,dc);

  for i := 0 to Length(Items) - 1 do begin
    New(RichItem);
    RichItem^.Bitmap := TBitmap.Create;
    RichItem^.Height := -1;
    RichItem^.GridItem := -1;
    RichItem^.Rich := THPPRichEdit.Create(nil);
    RichItem^.Rich.Name := 'CachedRichEdit'+IntToStr(i);
    RichItem^.Rich.Visible := False;
    // just a dirty hack to workaround problem with
    // SmileyAdd making richedit visible all the time
    RichItem^.Rich.Height := 1000;
    RichItem^.Rich.Top := -1001;
    // </hack>
    { Don't give him grid as parent, or we'll have
    wierd problems with scroll bar }
    RichItem^.Rich.Parent := nil;
    RichItem^.Rich.WordWrap := True;
    RichItem^.Rich.BorderStyle := bsNone;
    RichItem^.Rich.OnResizeRequest := OnRichResize;
    Items[i] := RichItem;
  end;
end;

destructor TRichCache.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(Items) - 1 do begin
    FreeAndNil(Items[i]^.Rich);
    FreeAndNil(Items[i]^.Bitmap);
    Dispose(Items[i]);
  end;
  //SetLength(Items,0);
  Finalize(Items);
  inherited;
end;

function TRichCache.FindGridItem(GridItem: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  if GridItem = -1 then exit;
  for i := 0 to Length(Items) - 1 do
    if Items[i].GridItem = GridItem then begin
       Result := i;
       break;
    end;
end;

function TRichCache.GetItemRich(GridItem: Integer): THPPRichEdit;
var
  Item: PRichItem;
begin
  Item := RequestItem(GridItem);
  Assert(Item <> nil);
  Result := Item^.Rich;
end;

function TRichCache.GetItemRichBitmap(GridItem: Integer): TBitmap;
var
  Item: PRichItem;
begin
  Item := RequestItem(GridItem);
  if not Item^.BitmapDrawn then
    PaintRichToBitmap(Item);
  Assert(Item <> nil);
  Result := Item^.Bitmap;
end;

procedure TRichCache.MoveToTop(Index: Integer);
var
  i: Integer;
  item: PRichItem;
begin
  Assert(Index < Length(Items));
  if Index = 0 then exit;
  item := Items[Index];
  for i := Index downto 1 do
    Items[i] := Items[i-1];
  Items[0] := item;
end;

procedure TRichCache.OnRichResize(Sender: TObject; Rect: TRect);
begin
  FRichHeight := Rect.Bottom - Rect.Top;
end;

procedure TRichCache.PaintRichToBitmap(Item: PRichItem);
var
  rc: TRect;
  BkColor: TCOLORREF;
  Range: TFormatRange;
  //str: String;
begin
  {$IFDEF DELPHI_9_UP}
  Item^.Bitmap.SetSize(Item^.Rich.Width,Item^.Height);
  {$ELSE}
  Item^.Bitmap.Width := Item^.Rich.Width;
  Item^.Bitmap.Height := Item^.Height;
  {$ENDIF}

  //str := 'Painted bitmap ['+IntToStr(item.GridItem)+'] for rich "'+Copy(Item.Rich.Text,1,15)+'"';
  //OutputDebugString(PChar(str));

  rc := Rect(0,0,Item^.Bitmap.Width,Item^.Bitmap.Height);

  // because RichEdit sometimes paints smaller image
  // than it said when calculating height, we need
  // to fill the background
  BkColor := SendMessage(Item^.Rich.Handle,EM_SETBKGNDCOLOR,0,0);
  SendMessage(Item^.Rich.Handle,EM_SETBKGNDCOLOR,0,BkColor);
  Item^.Bitmap.Canvas.Brush.Color := BkColor;
  Item^.Bitmap.Canvas.FillRect(rc);

  rc.Left := rc.left * 1440 div LogX;
  rc.Top := rc.Top * 1440 div LogY;
  rc.Right := rc.Right * 1440 div LogX;
  rc.Bottom := rc.Bottom * 1440 div LogY;

  Range.hdc := Item^.Bitmap.Canvas.Handle;
  Range.hdcTarget := Item^.Bitmap.Canvas.Handle;
  Range.rc := rc;
  Range.rcPage := rc;
  Range.chrg.cpMin := 0;
  Range.chrg.cpMax := -1;

  Item^.Rich.Perform(EM_FORMATRANGE, 1, Longint(@Range));
  Item^.BitmapDrawn := True;
end;

function TRichCache.RequestItem(GridItem: Integer): PRichItem;
var
  idx: Integer;
begin
  Result := nil;
  Assert(GridItem > -1);
  idx := FindGridItem(gridItem);
  if idx <> -1 then begin
    Result := Items[idx];
  end
  else begin
    idx := High(Items);
    Result := Items[idx];
    Result.GridItem := GridItem;
    Result.Height := -1;
  end;
  if Result.Height = -1 then begin
    ApplyItemToRich(Result);
    Result.Height := FRichHeight;
    Result.Rich.Height := FRichHeight;
    Result.BitmapDrawn := False;
  end;
  MoveToTop(idx);
end;

procedure TRichCache.ResetAllItems;
var
  i: Integer;
begin
  for i := 0 to Length(Items) - 1 do begin
    Items[i].Height := -1;
  end;
end;

procedure TRichCache.ResetItem(GridItem: Integer);
var
  idx: Integer;
begin
  if GridItem = -1 then exit;
  idx := FindGridItem(GridItem);
  if idx = -1 then exit;
  Items[idx].Height := -1;
end;

procedure TRichCache.ResetItems(GridItems: array of Integer);
var
  i: Integer;
  idx: Integer;
  ItemsReset: Integer;
begin
  ItemsReset := 0;
  for i := 0 to Length(GridItems) - 1 do begin
    idx := FindGridItem(GridItems[i]);
    if idx <> -1 then begin
      Items[idx].Height := -1;
      Inc(ItemsReset);
    end;
    // no point in searching, we've reset all items
    if ItemsReset >= Length(Items) then break;
  end;
end;

procedure TRichCache.SetHandles;
var
  i: Integer;
  exstyle: DWord;
begin
  for i := 0 to Length(Items) - 1 do begin
    Items[i].Rich.ParentWindow := Grid.Handle;
    //SendMessage(Items[i].Rich.Handle,EM_SETEVENTMASK,0,RichEventMasks);
    //SendMessage(Items[i].Rich.Handle,EM_AUTOURLDETECT,1,0);
    //SendMessage(Items[i].Rich.Handle,EM_SETMARGINS,EC_LEFTMARGIN or EC_RIGHTMARGIN,0);
    // make richedit transparent:
    exstyle := GetWindowLong(Items[i].Rich.Handle,GWL_EXSTYLE);
    exstyle := exstyle or WS_EX_TRANSPARENT;
    SetWindowLong(Items[i].Rich.Handle,GWL_EXSTYLE,exstyle);
    Items[i].Rich.Brush.Style := bsClear;
  end;
end;

procedure TRichCache.SetWidth(const Value: Integer);
var
  i: Integer;
begin
  if FRichWidth = Value then exit;
  FRichWidth := Value;
  for i := 0 to Length(Items) - 1 do begin
    Items[i].Rich.Width := Value;
    Items[i].Height := -1;
  end;
end;

procedure TRichCache.WorkOutItemAdded(GridItem: Integer);
var
  i: Integer;
begin
  for i := 0 to Length(Items) - 1 do
    if Items[i].Height <> -1 then begin
      if Items[i].GridItem >= GridItem then
        Inc(Items[i].GridItem);
    end;
end;

procedure TRichCache.WorkOutItemDeleted(GridItem: Integer);
var
  i: Integer;
begin
  for i := 0 to Length(Items) - 1 do
    if Items[i].Height <> -1 then begin
      if Items[i].GridItem = GridItem then
        Items[i].Height := -1
      else if Items[i].GridItem > GridItem then
        Dec(Items[i].GridItem);
    end;
end;

procedure THPPRichedit.SetAutoKeyboard(Enabled: Boolean);
var
  re_options,new_options: DWord;
begin
  re_options := SendMessage(Handle,EM_GETLANGOPTIONS,0,0);
  if Enabled then
    new_options := re_options or IMF_AUTOKEYBOARD else
    new_options := re_options and not IMF_AUTOKEYBOARD;
  if re_options <> new_options then
    SendMessage(Handle,EM_SETLANGOPTIONS,0,new_options);
end;

procedure THPPRichedit.WMSetFocus(var Message: TWMSetFocus);
begin
  SetAutoKeyboard(False);
  inherited;
end;

procedure THPPRichedit.WMLangChange(var Message: TMessage);
begin
  SetAutoKeyboard(False);
  Message.Result:=1;
end;

procedure THPPRichedit.CreateHandle;
var
  re_mask: cardinal;
begin
  inherited;
  re_mask := SendMessage(Handle,EM_GETEVENTMASK,0,0);
  SendMessage(Handle,EM_SETEVENTMASK,0,re_mask or ENM_LINK);
  SendMessage(Handle,EM_AUTOURLDETECT,1,0);
  SendMessage(Handle,EM_SETMARGINS,EC_LEFTMARGIN or EC_RIGHTMARGIN,0);
end;

// Fix for VCL TRichEdit uses RichEdit 1.0 class, incompatible
// with EM_REQUESTRESIZE message for some reasons
type
  TAccessCustomMemo = class(TCustomMemo);
  InheritedCreateParams = procedure(var Params: TCreateParams) of object;
procedure THPPRichedit.CreateParams(var Params: TCreateParams);
const
  RICHED10_DLL = 'RICHED32.DLL';
  aHideScrollBars: array[Boolean] of DWORD = (ES_DISABLENOSCROLL, 0);
  aHideSelections: array[Boolean] of DWORD = (ES_NOHIDESEL, 0);
var
  Method: TMethod;
begin
  if (not IsRichEdit20Available) and (FRichEdit10Module = 0) then begin
    FRichEdit10Module := LoadLibrary(RICHED10_DLL);
    if FRichEdit10Module <= HINSTANCE_ERROR then FRichEdit10Module := 0;
  end;
  Method.Code := @TAccessCustomMemo.CreateParams;
  Method.Data := Self;
  InheritedCreateParams(Method)(Params);
  if IsRichEdit20Available then
    CreateSubClass(Params, RICHEDIT_CLASSA)
  else
    CreateSubClass(Params, RICHEDIT_CLASS10A);
  with Params do begin
    Style := Style or
             aHideScrollBars[HideScrollBars] or
             aHideSelections[HideSelection];
    if WordWrap then
      Style := Params.Style and not WS_HSCROLL; // more compatible with RichEdit 1.0
    // Fix for updating rich in event details form
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure THPPRichedit.WMCopy(var Message: TWMCopy);
var
  Text: WideString;
begin
  inherited;
  // do not empty clip to not to loose rtf data
  //EmptyClipboard();
  Text := GetRichString(Handle,True);
  CopyToClip(Text,Handle,FCodepage,False);
end;

procedure THPPRichedit.WMKeyDown(var Message: TWMKey);
begin
  if (KeyDataToShiftState(Message.KeyData) = [ssCtrl]) then
    case Message.CharCode of
      Ord('E'),Ord('J'):
        Message.Result := 1;
      Ord('C'),VK_INSERT: begin
        PostMessage(Handle,WM_COPY,0,0);
        Message.Result := 1;
      end;
    end;
  if Message.Result = 1 then exit;
  inherited;
end;

initialization
  Screen.Cursors[crHandPoint] := LoadCursor(0,IDC_HAND);
  if Screen.Cursors[crHandPoint] = 0 then
    Screen.Cursors[crHandPoint] := LoadCursor(hInstance,'CR_HAND');

finalization
  if FRichEdit10Module <> 0 then
    FreeLibrary(FRichEdit10Module);
  if FRichEdit20Module <> 0 then
    FreeLibrary(FRichEdit20Module);

end.
