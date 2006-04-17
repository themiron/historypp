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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  TntSysUtils,TntWindows, TntControls,TntGraphics, TntComCtrls, Menus, StdCtrls,
  Math, mmsystem,
  hpp_global, hpp_contacts, hpp_itemprocess, hpp_events, m_api,
  Contnrs,
  VertSB,
  RichEdit, ShellAPI;

type
  TMouseMoveKey = (mmkControl,mmkLButton,mmkMButton,mmkRButton,mmkShift);
  TMouseMoveKeys = set of TMouseMoveKey;

  TSaveFormat = (sfHTML,sfXML,sfUnicode,sfText);
  TGridState = (gsIdle,gsDelete,gsSearch,gsSearchItem,gsLoad,gsSave,gsInline);

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

  THistoryGrid = class;

  {IFDEF RENDER_RICH}
  TUrlEvent = procedure(Sender: TObject; Item: Integer; Url: String) of object;
  {ENDIF}

  TOnProcessRichText = procedure(Sender: TObject; Handle: THandle; Item: Integer) of object;
  TOnSearchItem = procedure(Sender: TObject; Item: Integer; ID: Integer; var Found: Boolean) of object;

  TGridHitTest = (ghtItem, ghtHeader, ghtText, ghtLink);
  TGridHitTests = set of TGridHitTest;

  TOnEvent = procedure;
  TOnShowIcons = TOnEvent;

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

    FFontProfile: TFont;
    FFontContact: TFont;
    FFontTimestamp: TFont;

    FItemFont: TFont;
    FItemOptions: TItemOptions;

    FIconMessage: TIcon;
    FIconFile: TIcon;
    FIconUrl: TIcon;
    FIconOther: TIcon;

    FIconHistory: hIcon;
    FIconSearch: hIcon;

    FShowIcons: Boolean;
    FOnShowIcons: TOnShowIcons;

    FRTLEnabled: Boolean;
    FSmileysEnabled: Boolean;
    FBBCodesEnabled: Boolean;
    FMathModuleEnabled: Boolean;

    procedure SetColorDivider(const Value: TColor);
    procedure SetColorSelectedText(const Value: TColor);
    procedure SetColorSelected(const Value: TColor);

    procedure SetFontContact(const Value: TFont);
    procedure SetFontProfile(const Value: TFont);
    procedure SetFontTimestamp(const Value: TFont);

    procedure SetIconOther(const Value: TIcon);
    procedure SetIconFile(const Value: TIcon);
    procedure SetIconURL(const Value: TIcon);
    procedure SetIconMessage(const Value: TIcon);

    procedure SetShowIcons(const Value: Boolean);
    procedure SetOnShowIcons(const Value: TOnShowIcons);

    procedure SetRTLEnabled(const Value: Boolean);
    procedure SetSmileysEnabled(const Value: Boolean);
    procedure SetBBCodesEnabled(const Value: Boolean);
    procedure SetMathModuleEnabled(const Value: Boolean);

    function GetLocked: Boolean;
  protected
    procedure DoChange;
    procedure AddGrid(Grid: THistoryGrid);
    procedure DeleteGrid(Grid: THistoryGrid);
    procedure FontChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartChange;
    procedure EndChange;
    function AddItemOptions: integer;
    procedure GetItemOptions(Mes: TMessageTypes; out textFont: TFont; out textColor: TColor);
    property OnShowIcons: TOnShowIcons read FOnShowIcons write SetOnShowIcons;
  published
    property Locked: Boolean read GetLocked;

    property IconOther: TIcon read FIconOther write SetIconOther;
    property IconFile: TIcon read FIconFile write SetIconFile;
    property IconUrl: TIcon read FIconUrl write SetIconUrl;
    property IconMessage: TIcon read FIconMessage write SetIconMessage;

    property IconHistory: hIcon read FIconHistory write FIconHistory;
    property IconSearch: hIcon read FIconSearch write FIconSearch;

    property ColorDivider: TColor read FColorDivider write SetColorDivider;
    property ColorSelectedText: TColor read FColorSelectedText write SetColorSelectedText;
    property ColorSelected: TColor read FColorSelected write SetColorSelected;

    property FontProfile: TFont read FFontProfile write SetFontProfile;
    property FontContact: TFont read FFontContact write SetFontContact;
    property FontTimeStamp: TFont read FFontTimestamp write SetFontTimestamp;

    property ItemOptions: TItemOptions read FItemOptions write FItemOptions;

    property ShowIcons: Boolean read FShowIcons write SetShowIcons;
    property RTLEnabled: Boolean read FRTLEnabled write SetRTLEnabled;
    property SmileysEnabled: Boolean read FSmileysEnabled write SetSmileysEnabled;
    property BBCodesEnabled: Boolean read FBBCodesEnabled write SetBBCodesEnabled;
    property MathModuleEnabled: Boolean read FMathModuleEnabled write SetMathModuleEnabled;
  end;


  TRichItem = record
    Rich: TTntRichEdit;
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
    GridItems: array of Integer;
    Grid: THistoryGrid;
    FRichHeight: Integer;

    function FindGridItem(GridItem: Integer): Integer;
    procedure ApplyItemToRich(Item: PRichItem);
    procedure PaintRichToBitmap(Item: PRichItem);

    procedure OnRichResize(Sender: TObject; Rect: TRect);
  protected
    Items: array of PRichItem;
    procedure MoveToTop(Index: Integer);
  public
    constructor Create(AGrid: THistoryGrid); overload;
    destructor Destroy; override;

    procedure ResetAllItems;
    procedure ResetItems(GridItems: array of Integer);
    procedure ResetItem(GridItem: Integer);
    procedure SetWidth(NewWidth: Integer);
    procedure SetHandles;

    procedure WorkOutItemAdded(GridItem: Integer);
    procedure WorkOutItemDeleted(GridItem: Integer);

    function RequestItem(GridItem: Integer): PRichItem;
    function CalcItemHeight(GridItem: Integer): Integer;
    function GetItemRich(GridItem: Integer): TTntRichedit;
    function GetItemRichBitmap(GridItem: Integer): TBitmap;
  end;

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
    FSelItems: array of Integer;
    FSelected: Integer;
    FGetItemData: TGetItemData;
    FGetNameData: TGetNameData;
    FPadding: Integer;
    FItems: array of THistoryItem;
    FClient: TBitmap;
    FCanvas: TCanvas;
    FContact: THandle;
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

    FTxtNoItems: WideString;
    FTxtStartup: WideString;
    FTxtNoSuch: WideString;

    FTxtFullLog: WideString;
    FTxtPartLog: WideString;
    FTxtHistExport: WideString;    FTxtGenHist2: WideString;
    FTxtGenHist1: WideString;

    FOnState: TOnState;
    FReversed: Boolean;
    FOptions: TGridOptions;
    FMultiSelect: Boolean;
    FOnSelect: TOnSelect;
    FGetXMLData: TGetXMLData;
    FOnItemFilter: TOnItemFilter;
    {$IFDEF CUST_SB}
    FVertScrollBar: TVertScrollBar;
    {$ENDIF}
    {$IFDEF RENDER_RICH}
    FRichCache: TRichCache;
    FOnUrlClick: TUrlEvent;
    FOnUrlPopup: TUrlEvent;
    FRich: TTntRichEdit;
    //FRichItem: integer;
    //FRichSelected: TTntRichEdit;
    FRichInline: TTntRichEdit;
    FRichHeight: Integer;
    FRichParamsSet: Boolean;
    OverURL: Boolean;
    OverURLStr: WideString;
    FOnSearchItem: TOnSearchItem;

    FRTLMode: TRTLMode;

    TopItemOffset: Integer;
    MaxSBPos: Integer;
    FShowHeaders: Boolean;
    FCodepage: Cardinal;
    procedure SetCodepage(const Value: Cardinal);
    procedure SetShowHeaders(const Value: Boolean);
    function GetIdx(Index: Integer): Integer;
    // Item offset support
    //procedure SetScrollBar
    procedure ScrollGridBy(Offset: Integer; Update: Boolean = True);
    procedure SetSBPos(Position: Integer);
    // FRich events
    procedure OnRichResize(Sender: TObject; Rect: TRect);
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    // FRichInline events
    procedure RichInlineOnExit(Sender: TObject);
    procedure RichInlineOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RichInlineOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    function GetCount: Integer;
    procedure SetContact(const Value: THandle);
    procedure SetPadding(Value: Integer);
    procedure SetSelected(const Value: Integer);
    procedure AddSelected(Item: Integer);
    procedure RemoveSelected(Item: Integer);
    procedure MakeRangeSelected(FromItem,ToItem: Integer);
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
    procedure SetState(const Value: TGridState);
    procedure SetReversed(const Value: Boolean);
    procedure AdjustScrollBar;
    procedure SetOptions(const Value: TGridOptions);
    procedure SetMultiSelect(const Value: Boolean);
    {$IFDEF CUST_SB}
    procedure SetVertScrollBar(const Value: TVertScrollBar);
    {$ENDIF}
    function GetHitTests(X,Y: Integer): TGridHitTests;
    {$IFDEF RENDER_RICH}
    procedure ApplyItemToRich(Item: Integer; RichEdit: TTntRichEdit = nil);
    function GetRichEditRect(Item: Integer): TRect;
    procedure HandleRichEditMouse(Message: DWord; X,Y: Integer);
    {$ENDIF}
    procedure SetRTLMode(const Value: TRTLMode);
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateParams(var Params: TCreateParams); override;
    property Canvas: TCanvas read FCanvas;
    procedure Paint;
    procedure PaintHeader(Index: Integer; ItemRect: TRect);
    procedure PaintItem(Index: Integer; ItemRect: TRect);
    procedure DrawProgress;
    procedure DrawMessage(Text: WideString);
    procedure LoadItem(Item: Integer; LoadHeight: Boolean = True);
    procedure DoOptionsChanged;
    procedure DoKeyDown(Key: Word; ShiftState: TShiftState);
    procedure DoChar(Ch: WideChar; ShiftState: TShiftState);
    procedure DoLButtonDblClick(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoLButtonDown(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoLButtonUp(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoMouseMove(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoRButtonDown(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoRButtonUp(X,Y: Integer; Keys: TMouseMoveKeys);
    procedure DoUrlMouseMove(Url: WideString);
    procedure DoProgress(Position,Max: Integer);
    function CalcItemHeight(Item: Integer): Integer;
    procedure ScrollBy(DeltaX, DeltaY: Integer);
    procedure DeleteItem(Item: Integer);
    procedure SaveStart(Stream: TFileStream; SaveFormat: TSaveFormat; Caption: WideString);
    procedure SaveItem(Stream: TFileStream; Item: Integer; SaveFormat: TSaveFormat);
    procedure SaveEnd(Stream: TFileStream; SaveFormat: TSaveFormat);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property Contact: THandle read FContact write SetContact;
    property LoadedCount: Integer read FLoadedCount;
    procedure Allocate(ItemsCount: Integer);
    property Selected: Integer read FSelected write SetSelected;
    property SelCount: Integer read GetSelCount;
    function FindItemAt(x,y: Integer; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint): Integer; overload;
    function FindItemAt(x,y: Integer): Integer; overload;
    function GetItemRect(Item: Integer): TRect;
    function IsSelected(Item: Integer): Boolean;
    procedure MakeVisible(Item: Integer);
    procedure BeginUpdate;
    procedure EndUpdate;
    function IsVisible(Item: Integer): Boolean;
    procedure Delete(Item: Integer);
    procedure DeleteSelected;
    procedure DeleteAll;
    property Items[Index: Integer]: THistoryItem read GetItems;
    property SelItems[Index: Integer]: Integer read GetSelItems;
    function Search(Text: WideString; CaseSensitive: Boolean; FromStart: Boolean = False; SearchAll: Boolean = False; FromNext: Boolean = False; Down: Boolean = True): Integer;
    function SearchItem(ItemID: Integer): Integer;
    procedure AddItem;
    procedure SaveSelected(FileName: String; SaveFormat: TSaveFormat);
    procedure SaveAll(FileName: String; SaveFormat: TSaveFormat);
    function GetNext(Item: Integer; Force: Boolean = False): Integer;
    function GetDown(Item: Integer): Integer;
    function GetPrev(Item: Integer; Force: Boolean = False): Integer;
    function GetUp(Item: Integer): Integer;
    property State: TGridState read FState write SetState;
    function GetFirstVisible: Integer;
    procedure UpdateFilter;

    procedure EditInline(Item: Integer);
    procedure CancelInline;
    property InlineRichEdit: TTntRichEdit read FRichInline;

    property Options: TGridOptions read FOptions write SetOptions;
    property HotString: WideString read SearchPattern;
    property RTLMode: TRTLMode read FRTLMode write SetRTLMode;

    procedure CalcAllHeight;
    procedure MakeTopmost(Item: Integer);
    procedure ResetItem(Item: Integer);

    property Codepage: Cardinal read FCodepage write SetCodepage;
  published
    procedure SetRichRTL(RTL: Boolean; RichEdit: TTntRichEdit; ProcessTag: Boolean = true);
    function GetItemRTL(Item: Integer): Boolean;

    procedure CopyToClipSelected(const Format: WideString = ''; Codepage: Cardinal = CP_ACP);

  published
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
    property ShowHeaders: Boolean read FShowHeaders write SetShowHeaders;

    property TxtStartup: WideString read FTxtStartup write FTxtStartup;
    property TxtNoItems: WideString read FTxtNoItems write FTxtNoItems;
    property TxtNoSuch: WideString read FTxtNoSuch write FTxtNoSuch;
    property TxtFullLog: WideString read FTxtFullLog write FTxtFullLog;
    property TxtPartLog: WideString read FTxtPartLog write FTxtPartLog;
    property TxtHistExport: WideString read FTxtHistExport write FTxtHistExport;
    property TxtGenHist1: WideString read FTxtGenHist1 write FTxtGenHist1;
    property TxtGenHist2: WideString read FTxtGenHist2 write FTxtGenHist2;

    property Filter: TMessageTypes read FFilter write SetFilter;
    property ProfileName: WideString read FProfileName write FProfileName;
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
    property OnState: TOnState read FOnState write FOnState;
    property OnSelect: TOnSelect read FOnSelect write FOnSelect;
    property OnXMLData: TGetXMLData read FGetXMLData write FGetXMLData;
    {IFDEF RENDER_RICH}
    property OnUrlClick: TUrlEvent read FOnUrlClick write FOnUrlClick;
    property OnUrlPopup: TUrlEvent read FOnUrlPopup write FOnUrlPopup;
    {ENDIF}
    property OnItemFilter: TOnItemFilter read FOnItemFilter write FOnItemFilter;
    property OnProcessRichText: TOnProcessRichText read FOnProcessRichText write FOnProcessRichText;
    property OnSearchItem: TOnSearchItem read FOnSearchItem write FOnSearchItem;
    property Reversed: Boolean read FReversed write SetReversed;
    property Align;
    property Anchors;
    property TabStop;
    property Font;
    property Color;
    property Padding: Integer read FPadding write SetPadding;
    {$IFDEF CUST_SB}
    property VertScrollBar: TVertScrollBar read FVertScrollBar write SetVertScrollBar;
    {$ENDIF}
  end;

const
  filNone = [];
  filAll = [mtIncoming, mtOutgoing, mtMessage, mtUrl, mtFile, mtSystem, mtContacts, mtSMS, mtWebPager, mtEmailExpress, mtStatus, mtOther];
  filMessages = [mtMessage, mtIncoming, mtOutgoing];

procedure Register;

implementation

uses
  hpp_options, hpp_arrays;

const
  HtmlStop = [#0,#10,#13,'<','>',' '];

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
  RegisterComponents('Custom', [THistoryGrid]);
end;

{ THistoryGrid }

constructor THistoryGrid.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF RENDER_RICH}
  FRichCache := TRichCache.Create(Self);

  {tmp
  FRich := TTntRichEdit.Create(Self);
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

  // Ok, now selected richedit
  //FRichSelected := TTntRichEdit.Create(Self);
  //FRichSelected.Assign(FRich);

  // Ok, now inlined richedit
  FRichInline := TTntRichEdit.Create(Self);
  FRichInline.Name := 'FRichInline';
  FRichInline.Visible := False;
  //FRichInline.Parent := Self.Parent;
  //FRichInline.PlainText := True;
  FRichInline.WordWrap := True;
  FRichInline.BorderStyle := bsNone;
  FRichInline.ReadOnly := True;

  FRichInline.ScrollBars := ssVertical;

  FRichInline.OnExit := RichInlineOnExit;
  FRichInline.OnKeyDown := RichInlineOnKeyDown;
  FRichInline.OnKeyUp := RichInlineOnKeyUp;
  {$ENDIF}
  FCodepage := CP_ACP;

  CHeaderHeight := -1;
  PHeaderHeight := -1;

  TabStop := True;
  MultiSelect := True;

  TxtStartup := 'Starting up...';
  TxtNoItems := 'History is empty';
  TxtNoSuch  := 'No such items';
  TxtFullLog := 'Full History Log';
  TxtPartLog := 'Partial History Log';
  TxtHistExport := 'History++ export';
  TxtGenHist1 := '### (generated by history++ plugin)';
  TxtGenHist2 := '<h6>Generated by <b dir="ltr">History++</b> Plugin</h6>';

  Reversed := False;

  FState := gsIdle;

  IsCanvasClean := False;

  BarAdjusted := False;
  Allocated := False;

  ProgressPercent := 255;
  ShowProgress := False;

  ControlStyle := [csCaptureMouse,csClickEvents,csReflector,csDoubleClicks];
  ControlStyle := ControlStyle + [csOpaque];
  ControlStyle := ControlStyle + [csFramed];

  LockCount := 0;
  FFilter := filAll;
  FSelected := -1;
  FContact := 0;
  FPadding := 4;

  FClient := TBitmap.Create;
  FClient.Width := 1;
  FClient.Height := 1;

  FCanvas := FClient.Canvas;
  FCanvas.Font.Name := 'MS Shell Dlg';

  {$IFDEF CUST_SB}
  FVertScrollBar := TVertScrollBar.Create(Self,sbVertical);
  {$ENDIF}
end;

destructor THistoryGrid.Destroy;
begin
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

function THistoryGrid.GetCount: Integer;
begin
  Result := Length(FItems);
end;

procedure THistoryGrid.Allocate(ItemsCount: Integer);
var
  i: Integer;
  PrevCount: Integer;
begin
  PrevCount := Length(FItems);
  SetLength(FItems,ItemsCount);
  for i := PrevCount to ItemsCount-1 do begin
    FItems[i].Height := -1;
    FItems[i].MessageType := [mtUnknown];
    end;
  {$IFDEF CUST_SB}
    {$IFDEF PAGE_SIZE}
      VertScrollBar.Visible := True;
      VertScrollBar.Range := ItemsCount + VertScrollBar.PageSize-1;
    {$ELSE}
      VertScrollBar.Range := ItemsCount+ClientHeight-1;
    {$ENDIF}
  {$ELSE}
    VertScrollBar.Range := ItemsCount+ClientHeight-1;
  {$ENDIF}
  BarAdjusted := False;
  Allocated := True;
  if ItemsCount > 0 then
    SetSBPos(GetIdx(0));
  Invalidate;
end;

procedure THistoryGrid.LoadItem(Item: Integer; LoadHeight: Boolean = True);
begin
  if isUnknown(Item) then
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

  SumHeight := -TopItemOffset;
  ch := ClientHeight;
  cw := ClientWidth;

  while (SumHeight < ch) and (idx >= 0) and (idx < Length(FItems)) do begin
    LoadItem(idx);
    TextRect := Rect(0,SumHeight,cw,SumHeight+FItems[idx].Height);
    if DoRectsIntersect(ClipRect,TextRect) then begin
      Canvas.Brush.Color := Options.ColorDivider;
      Canvas.FillRect(TextRect);
      if (FItems[idx].HasHeader) and (ShowHeaders) then begin
        TextRect := Rect(0,SumHeight,cw,SumHeight+SessHeaderHeight-1);
        PaintHeader(idx,TextRect);
        TextRect := Rect(0,SumHeight+SessHeaderHeight,cw,SumHeight+FItems[idx].Height-1);
      end
      else
        TextRect := Rect(0,SumHeight,cw,SumHeight+FItems[idx].Height-1);
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
    Canvas.Brush.Color := clWindow;
    Canvas.FillRect(Rect(0,SumHeight,ClientWidth,ClientHeight));
  end;
end;

procedure THistoryGrid.PaintHeader(Index: Integer; ItemRect: TRect);
var
  text: WideString;
  RTL: Boolean;
  IconOffset, IconTop: Integer;
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

  Canvas.Brush.Color := clWindow;
  Canvas.FillRect(ItemRect);
  InflateRect(ItemRect,-3,-3);

  IconOffset := 0;
  if hppIcons[HPP_ICON_SESS_DIVIDER].Handle <> 0 then begin
    IconTop := ((ItemRect.Bottom-ItemRect.Top-16) div 2);
    IconOffset := 16 + 2;
    if RTL then
      DrawIconEx(Canvas.Handle,ItemRect.Right-16,ItemRect.Top + IconTop,
        hppIcons[HPP_ICON_SESS_DIVIDER].Handle,16,16,0,0,DI_NORMAL)
    else
      DrawIconEx(Canvas.Handle,ItemRect.Left,ItemRect.Top + IconTop,
        hppIcons[HPP_ICON_SESS_DIVIDER].Handle,16,16,0,0,DI_NORMAL);
  end;

  text := WideFormat(TranslateWideW('Conversation started at %s'),[GetTime(Items[Index].Time)]);
  Canvas.Font := Options.FontTimeStamp;
  Inc(ItemRect.Left,IconOffset);
  WideCanvasTextRect(Canvas,ItemRect,ItemRect.Left,ItemRect.Top,text);
end;

procedure THistoryGrid.SetCodepage(const Value: Cardinal);
begin
  if FCodepage = Value then exit;
  FCodepage := Value;
end;

procedure THistoryGrid.SetContact(const Value: THandle);
begin
  if FContact = Value then exit;
  FContact := Value;
end;

procedure THistoryGrid.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  //Canvas.Brush.Color := Color;
  //Canvas.FillRect(Rect(0,0,ClientWidth,ClientHeight));//Canvas.ClipRect);
  Message.Result := 1;
end;

procedure THistoryGrid.WMPaint(var Message: TWMPaint);
var
  ps: TagPaintStruct;
  dc: HDC;
begin
  if LockCount > 0 then begin
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
var
  i: Integer;
  NewClient: TBitmap;
  re_mask: Integer;

  procedure SetW;
  var
    w,h: Integer;
  begin
    w := Message.Width;
    h := Message.Height;
    if (w = 0) or (h=0) then exit;
    {
    FClient.Width := w;
    FClient.Height := h;
    }

    NewClient := TBitmap.Create;
    NewClient.Width := w;
    NewClient.Height := h;
    NewClient.Canvas.Font.Assign(Canvas.Font);
    NewClient.Canvas.TextFlags := Canvas.TextFlags;

    FClient.Free;
    FClient := NewClient;
    FCanvas := FClient.Canvas;
  end;
begin

  {$IFDEF RENDER_RICH}
  if State = gsInline then CancelInline;

  if not FRichParamsSet then begin
    FRichCache.SetHandles;
    FRichParamsSet := true;
    //re_mask := SendMessage(FRich.Handle, EM_GETEVENTMASK, 0, 0);
    //SendMessage(FRich.Handle, EM_SETEVENTMASK, 0, re_mask or ENM_LINK);
    //re_mask := FRich.Perform(EM_GETEVENTMASK, 0, 0);
    //FRich.Perform(EM_SETEVENTMASK, 0, re_mask or ENM_LINK);
    FRichInline.ParentWindow := Handle;
    re_mask := SendMessage(FRichInline.Handle, EM_GETEVENTMASK, 0, 0);
    SendMessage(FRichInline.Handle, EM_SETEVENTMASK, 0, re_mask or ENM_LINK);
    SendMessage(FRichInline.Handle,EM_AUTOURLDETECT,1,0);
    //re_mask := FRichInline.Perform(EM_GETEVENTMASK, 0, 0);
    //FRichInline.Perform(EM_SETEVENTMASK, 0, re_mask or ENM_LINK);
  end;
  FRichCache.SetWidth(ClientWidth - 2*FPadding);

  SetW;

  // tmp
  //FRich.Width := ClientWidth - 2*FPadding;

  {$ENDIF}

  IsCanvasClean := False;
  BarAdjusted := False;

  BeginUpdate;
  for i := 0 to Count-1 do
    FItems[i].Height := -1;
  if Allocated then AdjustScrollBar;
  EndUpdate;
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
      SB_LINEDOWN: ScrollGridBy(5*13);
      SB_LINEUP: ScrollGridBy(-5*13);
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
  hh,IconOffset,NickOffset,TimeOffset: Integer;
  icon: TIcon;
  BackColor: TColor;
  nameFont,timestampFont,textFont: TFont;
  Sel: Boolean;
  {IFDEF RENDER_RICH}
  LogX,LogY: Integer;
  rc: TRect;
  Range: TFormatRange;
  {ENDIF}
  RTL: Boolean;
  RichBMP: TBitmap;

begin
  {$IFDEF DEBUG}
  OutputDebugString(PChar('Paint item '+intToStr(Index)+' to screen'));
  {$ENDIF}

  OrgRect := ItemRect;

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

  if mtIncoming in FItems[Index].MessageType then begin
    nameFont := Options.FontContact;
    HeaderName := ContactName+':';
  end else begin
    nameFont := Options.FontProfile;
    HeaderName := ProfileName+':';
  end;
  if Assigned(FGetNameData) then
    FGetNameData(Self,Index,HeaderName);
  timestampFont := Options.FontTimeStamp;
  TimeStamp := GetTime(FItems[Index].Time);

  if Sel then begin
    BackColor := Options.ColorSelected;
  end;

  //SendMessage(FRich.Handle,EM_SETBKGNDCOLOR,0,ColorToRGB(BackColor));

  Canvas.Brush.Color := BackColor;
  Canvas.FillRect(ItemRect);

  InflateRect(ItemRect,-Padding,-Padding);

  IconOffset := 0;

  if Options.ShowIcons then begin
    if (mtFile in FItems[Index].MessageType) then
      Icon := Options.IconFile
    else if (mtUrl in FItems[Index].MessageType) then
      Icon := Options.IconUrl
    else if (mtMessage in FItems[Index].MessageType) then
      Icon := Options.IconMessage
    else
      Icon := Options.IconOther;
    if Icon <> nil then begin
      IconOffset := 16+Padding;
      // canvas. draw here can sometimes draw 32x32 icon (sic!)
      //if Options.RTLEnabled then
      if RTL then
        DrawIconEx(Canvas.Handle,ItemRect.Right-16,ItemRect.Top,Icon.Handle,16,16,0,0,DI_NORMAL)
      else
        DrawIconEx(Canvas.Handle,ItemRect.Left,ItemRect.Top,Icon.Handle,16,16,0,0,DI_NORMAL);
    end;
  end;

  Canvas.Font := nameFont;
  if sel then Canvas.Font.Color := Options.ColorSelectedText;

  if RTL then begin
    NickOffset := WideCanvasTextWidth(Canvas,HeaderName);
    WideCanvasTextOut(Canvas,ItemRect.Right-IconOffset-NickOffset,ItemRect.Top,HeaderName)
  end else
    WideCanvasTextOut(Canvas,ItemRect.Left+IconOffset,ItemRect.Top,HeaderName);

  Canvas.Font := timestampFont;
  if sel then Canvas.Font.Color := Options.ColorSelectedText;
  //if Options.RTLEnabled then
  if RTL then
    WideCanvasTextOut(Canvas,ItemRect.Left,ItemRect.Top,TimeStamp)
  else begin
    TimeOffset := WideCanvasTextWidth(Canvas,TimeStamp);
    WideCanvasTextOut(Canvas,ItemRect.Right-TimeOffset,ItemRect.Top,TimeStamp);
  end;

  if mtIncoming in FItems[Index].MessageType then
    hh := CHeaderHeight
  else
    hh := PHeaderHeight;

  Inc(ItemRect.Top,hh);

  ApplyItemToRich(Index);
  //if Sel then ApplyItemToRich(Index,FRichSelected);
  {
  LogX := GetDeviceCaps(Canvas.Handle, LOGPIXELSX);
  LogY := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);

  // fixed bug with scrolling by pixels
  // it's richedit who decides that it wants to draw anywhere he wants
  // and not where we told him
  RichBMP := TBitmap.Create;
  RichBMP.Width := ItemRect.Right - ItemRect.Left;
  RichBMP.Height := ItemRect.Bottom - ItemRect.Top;
  rc := RichBMP.Canvas.ClipRect;
  //rc := ItemRect;
  rc.Left := rc.left * 1440 div LogX;
  rc.Top := rc.Top * 1440 div LogY;
  rc.Right := rc.Right * 1440 div LogX;
  rc.Bottom := rc.Bottom * 1440 div LogY;

  Range.hdc := RichBMP.Canvas.Handle;
  Range.hdcTarget := RichBMP.Canvas.Handle;
  Range.rc := rc;
  Range.rcPage := rc;
  Range.chrg.cpMin := 0;
  Range.chrg.cpMax := -1;

  //FRich.SelectAll;
  //FRich.HideSelection := False;
  //SendMessage(FRich.Handle,WM_SETFOCUS,0,0);

  //SendMessage(FRich.Handle, EM_HIDESELECTION, 0, 0);
  //SendMessage(FRich.Handle, EM_EXSETSEL, 0, integer(@Range.chrg));

  //if Sel then SendMessage(FRichSelected.Handle, EM_FORMATRANGE, 1, Longint(@Range))
  //       else SendMessage(FRich.Handle, EM_FORMATRANGE, 1, Longint(@Range));

  //SendMessage(FRich.Handle, EM_FORMATRANGE, 1, Longint(@Range));
  FRich.Perform(EM_FORMATRANGE, 1, Longint(@Range));
  }
  RichBMP := FRichCache.GetItemRichBitmap(Index);
  BitBlt(Canvas.Handle,ItemRect.Left,ItemRect.Top,RichBMP.Width,RichBMP.Height,
    RichBMP.Canvas.Handle,0,0,SRCCOPY);
  //RichBMP.Free;

  // Free cached information
  //SendMessage(FRich.Handle, EM_FORMATRANGE, 0,0);

  if Focused and (Index = Selected) then begin
    //InflateRect(ItemRect,Padding,Padding);
    //Dec(ItemRect.Top,hh);
    DrawFocusRect(Canvas.Handle,OrgRect);
  end;
end;

procedure THistoryGrid.SetSelected(const Value: Integer);
var
  OldSelected: Integer;
  i: Integer;
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

procedure THistoryGrid.SetShowHeaders(const Value: Boolean);
begin
  FShowHeaders := Value;
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
  Windows.SetFocus(Handle);
  DoLButtonDown(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

function THistoryGrid.FindItemAt(x, y: Integer; out ItemRect: TRect): Integer;
var
  SumHeight: Integer;
  idx,tmp: Integer;
  succ: Boolean;
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
  //tmp := GetUp(idx);
  //if tmp <> -1 then idx := tmp;
 //else idx := GetIdx(GetIdx(idx)-1);
  //idx := GetIdx(VertScrollBar.Position-1);
  {if Reversed then
    succ := (idx >= 0)
  else
    succ := ;}

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
    //Inc(idx);
    {if Reversed then
      succ := (idx >= 0)
    else
      succ := (idx < Length(FItems));}
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
  i,s,e,Item: Integer;
begin
  WasDownOnGrid := True;
  SearchPattern := '';
  CheckBusy;
  if Count = 0 then exit;

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
var
  i: Integer;
begin
  Result := False;
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
procedure THistoryGrid.ApplyItemToRich(Item: Integer; RichEdit: TTntRichEdit = nil);
var
  textFont: TFont;
  FontColor,BackColor: TColor;
  cf: TCharFormat;
  RichItem: PRichItem;
begin
  if RichEdit = nil then begin
     RichItem := FRichCache.RequestItem(Item);
     FRich := RichItem.Rich;
     FRichHeight := RichItem.Height;
     exit;
  end
  else
    if not (RichEdit = FRichInline) then
      FRich := RichEdit;

  Options.GetItemOptions(FItems[Item].MessageType,textFont,BackColor);
  if (IsSelected(Item)) and (not (RichEdit = FRichInline)) then begin
    FontColor := Options.ColorSelectedText;
    BackColor := Options.ColorSelected;
  end else begin
    FontColor := textFont.Color;
  end;
  { 04.08.2004 OXY: Workaround fixed
    we do it this way because third-party plugins can change
    richedit properties via it's handle and we never
    know it because delphi properties doesn't change and
    delphi thinks it hasn't changed and not change it with
    simple .color := value if previous .color was the same
    (it may not be true, because plugins can change it with
    system messages)}
  //{DONE: Fix workaround (color = 0; color = ...)}
  //FRich.Color := 0;
  //FRich.Color := BackColor;

  RichEdit.Clear;

  //SendMessage(RichEdit.Handle,EM_SETBKGNDCOLOR,0,ColorToRGB(BackColor));
  RichEdit.Perform(EM_SETBKGNDCOLOR,0,ColorToRGB(BackColor));
  RichEdit.Font := textFont;
  RichEdit.DefAttributes.Color := FontColor;
  //RichEdit.Font.Color := FontColor;

  SetRichRTL(GetItemRTL(Item),RichEdit);

  RichEdit.Text := FItems[Item].Text;

  if Assigned(FOnProcessRichText) then begin
    try
      FOnProcessRichText(Self,RichEdit.Handle,Item);
    except
    end;
  end;

  // do not allow changed back and color of selection
  if isSelected(item) and (State <> gsInline) then begin
    ZeroMemory(@cf,SizeOf(cf));
    cf.cbSize := SizeOf(cf);
    cf.dwMask := CFM_COLOR;
    cf.crTextColor := FontColor;
    RichEdit.Perform(EM_SETBKGNDCOLOR, 0,ColorToRGB(BackColor));
    RichEdit.Perform(EM_SETCHARFORMAT, SCF_ALL, integer(@cf));
  end;

  {$IFDEF DEBUG}
  OutputDebugString(PChar('Applying item '+intToStr(Item)+' to rich'));
  {$ENDIF}
end;
{$ENDIF}

{$IFDEF RENDER_RICH}
procedure THistoryGrid.OnRichResize(Sender: TObject; Rect: TRect);
begin
  FRichHeight := Rect.Bottom - Rect.Top;
end;
{$ENDIF}

procedure THistoryGrid.DoRButtonUp(X, Y: Integer; Keys: TMouseMoveKeys);
var
  Item: Integer;
begin
  SearchPattern := '';
  CheckBusy;

  Item := FindItemAt(x,y);

  if OverURL then begin
    if Assigned(FOnUrlPopup) then begin
      FOnUrlPopup(Self,Item,OverUrlStr);
      OverURL := False;
      Cursor := crDefault;
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
begin
  WasDownOnGrid := False;
  if OverURL then begin
    if Assigned(FOnUrlClick) then begin
      Item := FindItemAt(x,y);
      FOnUrlClick(Self,item,OverUrlStr);
      OverURL := False;
      Cursor := crDefault;
      end;
    end;
end;

procedure THistoryGrid.WMMouseMove(var Message: TWMMouseMove);
begin
  //if GetCapture <> Handle then exit;
  if not Focused then exit;
  //if Self.State = gsIdle then
  DoMouseMove(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

procedure THistoryGrid.DoMouseMove(X, Y: Integer; Keys: TMouseMoveKeys);
var
Item: Integer;
{$IFDEF RENDER_RICH}
//ItemRect: TRect;
//RichX, RichY: Integer;
//hh: Integer;
{$ENDIF}
s,e,i: Integer;
begin
  CheckBusy;
  if Count = 0 then exit;
  // do we need to process control here?
  if ((mmkLButton in Keys) and not (mmkControl in Keys) and
  not (mmkShift in Keys)) and (MultiSelect) and (WasDownOnGrid) then begin
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
    exit;
  end;

  {$IFDEF RENDER_RICH}
  OverURL := False;
  HandleRichEditMouse(WM_MOUSEMOVE,X,Y);
  if OverURL then Cursor := crHandPoint
             else Cursor := crDefault;
  {$ENDIF}
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
  r: TRect;
  t: WideString;
  f: TFont;
  c: TColor;
begin
  Result := -1;
  if IsUnknown(Item) then exit;
  {$IFDEF RENDER_RICH}

  ApplyItemToRich(Item);
  // look like it solves the next hack
  // at least it helps if the first string we calculate is empty
  if FRichHeight = 0 then begin
    FRich.Text := FRich.Text + 'sasme/m,ds ad34!a9-1da'; // any junk here
    ApplyItemToRich(Item);
  end;
  Assert(FRichHeight <> 0, 'CalcItemHeight: rich is still 0 height');
  // rude hack, but what the fuck??? First item with rtl chars is 1 line heighted always
  if FRichHeight = 0 then exit
                     else h := FRichHeight;

  {$ENDIF}
  {begin
    r := Rect(padding,padding,ClientWidth-padding,padding+1);
    // 26.03.03 - OXY - no need, already done in GetItemData
    // t := TrimRight(FItems[Item].Text);
    t := FItems[Item].Text;
    Options.GetItemOptions(FItems[Item].MessageType,f,c);
    Canvas.Font := f;
    //h := DrawText(Canvas.Handle,PChar(t),Length(t),r,DT_CALCRECT or DT_NOCLIP or DT_NOPREFIX	or DT_WORDBREAK);
    h := Tnt_DrawTextW(Canvas.Handle,PWideChar(t),Length(t),r,DT_CALCRECT or DT_NOCLIP or DT_NOPREFIX	or DT_WORDBREAK);
  end;}

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
  if (FItems[Item].HasHeader) and (ShowHeaders) then
    Inc(Result,SessHeaderHeight);
end;

procedure THistoryGrid.SetFilter(const Value: TMessageTypes);
begin
  {$IFDEF DEBUG}
  OutPutDebugString('Filter');
  {$ENDIF}
  if (FFilter = Value) or (Value = []) then exit;
  FFilter := Value;
  UpdateFilter;
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
  Canvas.Font := Screen.MenuFont;
  Canvas.Brush.Color := clWindow;
  Canvas.Font.Color := clWindowText;
  r := ClientRect;
  cr := ClientRect;
  Canvas.FillRect(r);
  // make multiline support
  //DrawText(Canvas.Handle,PChar(Text),Length(Text),
  //r,DT_CENTER or DT_NOPREFIX	or DT_VCENTER or DT_SINGLELINE);
  Tnt_DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text),r, DT_NOPREFIX or DT_CENTER or DT_CALCRECT);
  OffsetRect(r,
    ((cr.Right - cr.Left) - (r.right - r.left)) div 2,
    ((cr.Bottom - cr.Top) - (r.bottom - r.top)) div 2);
  Tnt_DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text),r, DT_NOPREFIX or DT_CENTER);
end;

procedure THistoryGrid.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  DoKeyDown(Message.CharCode,KeyDataToShiftState(Message.KeyData));
end;

procedure THistoryGrid.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;
end;

const
  VK_PAGEDOWN = 34;

procedure THistoryGrid.DoKeyDown(Key: Word; ShiftState: TShiftState);
var
NextItem,i,Item: Integer;
r: TRect;
begin
CheckBusy;

if Count = 0 then exit;

Item := Selected;
if Item = -1 then begin
  if Count = 0 then exit;
  if Reversed then
    Item := GetPrev(-1)
  else
    Item := GetNext(-1);
  end;
{
if (Key = VK_RETURN) and (ShiftState = [ssCtrl]) then begin
  if SearchPattern = '' then exit;
  DoChar(#0,[]);
  end;
}
if Key = VK_HOME then begin
  if ShiftState <> [] then begin
    SearchPattern := '';
    end;
  SearchPattern := '';
  NextItem := GetNext(GetIdx(-1));
  if (not (ssShift in ShiftState)) or (not MultiSelect) then begin
    Selected := NextItem;
    end
  else begin
    MakeSelectedTo(NextItem);
    FSelected := NextItem;
    MakeVisible(NextItem);
    Invalidate;
    end;
  end;

if Key = VK_END then begin
  SearchPattern := '';
  NextItem := GetPrev(GetIdx(Count));
  if (not (ssShift in ShiftState)) or (not MultiSelect) then begin
    Selected := NextItem;
    end
  else begin
    MakeSelectedTo(NextItem);
    FSelected := NextItem;
    MakeVisible(NextItem);
    Invalidate;
    end;
  AdjustScrollBar;
  end;

if Key = VK_NEXT then begin //PAGE DOWN
  SearchPattern := '';
  NextItem := Item;
  r := GetItemRect(NextItem);
  NextItem := FindItemAt(0,r.top+ClientHeight);
  if NextItem = Item then begin
    NextItem := GetNext(NextItem);
    if NextItem = -1 then
      NextItem := Item;
    end
  else if NextItem = -1 then begin
    NextItem := GetPrev(GetIdx(Count));
    if NextItem = -1 then
      NextItem := Item;
    end;
  if (not (ssShift in ShiftState)) or (not MultiSelect) then begin
    Selected := NextItem;
    end
  else begin
    MakeSelectedTo(NextItem);
    FSelected := NextItem;
    MakeVisible(NextItem);
    Invalidate;
    end;
  AdjustScrollBar;
  end;

if Key = VK_PRIOR then begin //PAGE UP
  SearchPattern := '';
  NextItem := Item;
  r := GetItemRect(NextItem);
  NextItem := FindItemAt(0,r.top-ClientHeight);
  if NextItem <> -1 then begin
    if FItems[NextItem].Height < ClientHeight then
      NextItem := GetNext(NextItem);
    end
  else
    NextItem := GetNext(NextItem);
  if NextItem = -1 then begin
    if IsMatched(GetIdx(0)) then
      NextItem := GetIdx(0)
    else
      NextItem := GetNext(GetIdx(0));
  end;
  if (not (ssShift in ShiftState)) or (not MultiSelect) then begin
    Selected := NextItem;
    end
  else begin
    MakeSelectedTo(NextItem);
    FSelected := NextItem;
    MakeVisible(NextItem);
    Invalidate;
    end;
  AdjustScrollBar;
  end;

if Key = VK_UP then begin
  SearchPattern := '';
  if GetIdx(Item) > 0 then Item := GetPrev(Item);
  if item = -1 then exit;
  if (ssShift in ShiftState) and (MultiSelect) then begin
    MakeSelectedTo(Item);
    FSelected := Item;
    MakeVisible(Selected);
    Invalidate;
    end
  else
    Selected := Item;
  AdjustScrollBar;
  end;

if Key = VK_DOWN then begin
  SearchPattern := '';
  if GetIdx(Item) < Count-1 then Item := GetNext(Item);
  if Item = -1 then exit;
  if (ssShift in ShiftState) and (MultiSelect) then begin
    MakeSelectedTo(Item);
    FSelected := Item;
    MakeVisible(Item);
    Invalidate;
    end
  else
    Selected := Item;
  AdjustScrollBar;
  end;
end;

procedure THistoryGrid.WMNotify(var Message: TWMNotify);
var
  link: TENLink;
  AnsiUrl: String;
  url: WideString;
  p: TPoint;
  tr: TextRange;
  OverInline: Boolean;
  CurRich: TTntRichEdit;
begin
{$IFDEF RENDER_RICH}
// ok, user either clicked or moved mouse over link
if Message.NMHdr^.code = EN_LINK then begin
  link := TENLink(Pointer(Message.NMHdr)^);
  // if we are over inline richedit?
  OverInline := (Message.NMHdr^.hwndFrom = FRichInline.Handle);
  if OverInline then CurRich := FRichInline
  else CurRich := FRich;

  // get url. instead of using selections, use GetTextRange
  {FRich.Perform(EM_EXSETSEL, 0, LongInt(@(link.chrg)));
  url := FRich.SelText;}
  tr.chrg := link.chrg;
  if hppOSUnicode then begin
    SetLength(url,link.chrg.cpMax-link.chrg.cpMin);
    tr.lpstrText := @url[1];
  end
  else begin
    SetLength(AnsiUrl,link.chrg.cpMax-link.chrg.cpMin);
    tr.lpstrText := @AnsiUrl[1];
  end;
  CurRich.Perform(EM_GETTEXTRANGE,0,LongInt(@tr));
  if not hppOSUnicode then url := AnsiToWideString(AnsiUrl,Codepage);

  // process messages
  if link.msg = WM_MOUSEMOVE then
    if not OverInline then begin
      // no need for inline rich
      DoUrlMouseMove(url);
    end;

  // we recieve mouse buttons only for inline rich
  if link.msg = WM_LBUTTONUP then begin
    p := Mouse.CursorPos;
    p := ScreenToClient(p);
    OverUrlStr := url;
    OverUrl := True;
    DoLButtonUp(p.x,p.y,[]);
    OverUrl := False;
  end;
end;
{$ENDIF}
  inherited;
end;

procedure THistoryGrid.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := DLGC_WANTARROWS;
end;

procedure THistoryGrid.MakeRangeSelected(FromItem, ToItem: Integer);
var
  i: Integer;
  StartItem,EndItem: Integer;
  len: Integer;
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

  // clear current selected items
  FRichCache.ResetItems(FSelItems);
  SetLength(FSelItems,0);
  len := 0;

  // fill selected items list
  for i := StartItem to EndItem do begin
    if IsUnknown(i) then LoadItem(i,False);
    if not IsMatched(i) then continue;
    Inc(len);
    SetLength(FSelItems,len);
    FSelItems[len-1] := i;
  end;

  // redraw newly selected items
  FRichCache.ResetItems(FSelItems);
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
  OrgItem,First: Integer;
  SumHeight: Integer;
begin
  if Item = -1 then exit;
  OrgItem := Item;
  // load it to make positioning correct
  LoadItem(Item);
  if not IsMatched(Item) then exit;
  if Item = GetFirstVisible then begin
    ScrollGridBy(-TopItemOffset,False);
    exit;
  end;
  if GetIdx(Item) < GetIdx(GetFirstVisible) then
    SetSBPos(GetIdx(Item))
  else begin
    if IsVisible(Item) then exit;
    SumHeight := 0;
    First := Item;
    while (Item >= 0) and (Item < Count) do begin
      LoadItem(Item,True);
      if (SumHeight + FItems[Item].Height) >= ClientHeight then break;
      Inc(SumHeight,FItems[Item].Height);
      Item := GetUp(Item);
    end;
    if GetIdx(Item) >= MaxSBPos  then
      SetSBPos(GetIdx(Item)+1)
    else begin
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
  DoRButtonDown(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

procedure THistoryGrid.WMRButtonUp(var Message: TWMRButtonDown);
begin
  DoRButtonUp(Message.XPos,Message.YPos,TranslateKeys(Message.Keys));
end;

procedure THistoryGrid.BeginUpdate;
begin
//if LockCount = 0 then
//  if SendMessage(handle,WM_SETREDRAW,Integer(LongBool(False)),0) <> 0 then

  //not LockWindowUpdate(Handle) then
//    exit;

Inc(LockCount);
end;

procedure THistoryGrid.EndUpdate;
begin
if LockCount > 0 then begin
  Dec(LockCount);
//  if LockCount = 0 then begin
//    SendMessage(handle,WM_SETREDRAW,Integer(LongBool(False)),0);
//    LockWindowUpdate(0);
//  end;
  end;
end;

function THistoryGrid.GetTime(Time: DWord): WideString;
begin
if Assigned(FTranslateTime) then
  OnTranslateTime(Self,Time,Result)
else
  Result := '';
end;

function THistoryGrid.GetUp(Item: Integer): Integer;
begin
  Result := GetPrev(Item,False);
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

function THistoryGrid.IsMatched(Index: Integer): Boolean;
var
  mts: TMessageTypes;
begin
  mts := FItems[Index].MessageType;
  Result := ((Word(FFilter) and Word(mts)) >= Word(mts));
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
  CreateUnicodeHandle(Self, Params, '');
end;

procedure THistoryGrid.CreateParams(var Params: TCreateParams);
//var
//  h: HWND;
begin
  inherited CreateParams(Params);
  //Params.Style := Params.Style or WS_BORDER;
  with Params.WindowClass do
    //style := style or CS_HREDRAW or CS_VREDRAW or WS_EX_LEFTSCROLLBAR;
    style := style or CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW{ or CS_PARENTDC};
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
function THistoryGrid.IsVisible(Item: Integer): Boolean;
var
  idx,SumHeight: Integer;
begin
  Result := False;
  if GetIdx(Item) < GetIdx(GetFirstVisible) then exit;
  if not IsMatched(Item) then exit;
  SumHeight := -TopItemOffset;
  idx := GetFirstVisible;
  LoadItem(idx,True);
  while (SumHeight+FItems[idx].Height <= ClientHeight) and (Item <> -1) and (Item < Count) do begin
    if Item = idx then begin
      Result := True;
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
begin
  SearchPattern := '';
  CheckBusy;
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
  Canvas.Brush.Color := clWindow;
  Canvas.Font.Color := clWindowText;
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
  Canvas.Brush.Color := clHighlight;
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

procedure THistoryGrid.WMKillFocus(var Message: TWMKillFocus);
var
  r: TRect;
begin
  CheckBusy;
  if selected <> -1 then begin
  if IsVisible(Selected) then begin
    r := GetItemRect(Selected);
    InvalidateRect(Handle,@r,False);
    end;
  end;
  inherited;
end;

procedure THistoryGrid.WMSetCursor(var Message: TWMSetCursor);
{var
  p: TPoint;
  FocusWnd: THandle;}
begin
  // To *correctly* set cursor when we are not focused, we need RichEdit to
  // process WM_SETCURSOR and issue EN_LINK. Activating Richedit and then
  // killing focus in order for it to process WM_MOUSEMOVE causes bugs.
  // But there's a caveat with WM_SETCURSOR:
  // it wouldn't issue EN_LINK unless rich is visible, so we either should show
  // richedit under cursor or not process this at all. One more: when grid is
  // inactive and user clicks on this richedit under cursor, it would activate
  // richedit :) So we need to show "special" richedits, who know that when they
  // are clicked, they should hide themselves and transfer click to the grid
  inherited;
  {CheckBusy;
  if GetFocus = Handle then begin
    inherited;
    exit;
  end;
  if not IsChild(GetParentForm(Self).Handle,GetFocus) then begin
    inherited;
    exit;
  end;

  // button is pressed, exit
  if Message.HitTest = HTERROR then exit;
  p := ScreenToClient(Mouse.CursorPos);
  OverURL := False;
  HandleRichEditMouse(WM_MOUSEMOVE,p.X,p.Y);
  if OverURL then
    Windows.SetCursor(Screen.Cursors[crHandPoint])
  else
    Windows.SetCursor(Screen.Cursors[crDefault]);
  Message.Result := 1;}
end;

procedure THistoryGrid.WMSetFocus(var Message: TWMSetFocus);
var
  r: TRect;
begin
  CheckBusy;
  if selected <> -1 then begin
    if IsVisible(Selected) then begin
      r := GetItemRect(Selected);
      InvalidateRect(Handle,@r,False);
    end;
  end;
  inherited;
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
      if Reversed then
        NextItem := GetNext(Item)
      else
        NextItem := GetPrev(Item);
    end;

    DeleteItem(Item);

    if Selected = Item then begin
      FSelected := -1;
      if Reversed then
        Temp := GetPrev(NextItem)
      else
        Temp := GetNext(NextItem);
      if Temp <> -1 then
        NextItem := Temp;
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

  finally
    State := gsIdle;
    Invalidate;
  end;
end;

procedure THistoryGrid.DeleteAll;
var
cur,max: Integer;
begin
State := gsDelete;
try
BarAdjusted := False;

FRichCache.ResetItems(FSelItems);
SetLength(FSelItems,0);
FSelected := -1;

max := length(FItems)-1;
cur := 0;

ShowProgress := True;

while Length(FItems) <> 0 do begin
  LoadItem(0,False);
  DeleteItem(0);
  DoProgress(cur,max);
  if cur = 0 then Invalidate;
  Inc(cur);
  end;

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
  finally
    State := gsIdle;
    Update;
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

if FromStart then
  StartItem := GetNext(-1, True)
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
    if AnsiPos(Text,FItems[Item].Text) <> 0 then begin
      Result := Item;
      break;
      end;
    end
  else begin
    if Pos(Text,Tnt_WideUpperCase(FItems[Item].Text)) <> 0 then begin
      Result := Item;
      break;
      end;
    end;

  if SearchAll then
    Inc(Item)
  else begin
    if Down then
      Item := GetNext(Item)
    else
      Item := GetPrev(Item);
    end;

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
begin
  inherited;
  DoChar(GetWideCharFromWMCharMsg(Message),KeyDataToShiftState(Message.KeyData));
end;


const
  BT_BACKSPACE = #8;
  // #9 -- TAB
  // #13 -- ENTER
  // #27 -- ESC
  ForbiddenChars = [WideChar(#9),WideChar(#13),WideChar(#27)];

procedure THistoryGrid.DoChar(Ch: WideChar; ShiftState: TShiftState);
var
  OldPattern: WideString;
  Down: Boolean;
  Sr: Integer;
begin
CheckBusy;
if (ssAlt in ShiftState) or (ssCtrl in ShiftState) then exit;

//if (ch <> #0) and (ch <> BT_BACKSPACE) then
//  if (GetTickCount - LastKeyDown) > 5000 then SearchPattern := '';

  {if IsDBCSLeadByte(Byte(Ch)) then begin
    SearchPattern := SearchPattern+Ch;
    LastKeyDown := GetTickCount;
    exit;
  end;}

if (Ch in ForbiddenChars) then exit;

Down := not Reversed;

if Ch = BT_BACKSPACE then begin
  OldPattern := SearchPattern;
  if SearchPattern <> '' then
    SetLength(SearchPattern,Length(SearchPattern)-1)
  else
    exit;
  Down := not Down;
  end
else begin
  OldPattern := SearchPattern;
  if ch <> #0 then
    SearchPattern := SearchPattern+Ch;
  end;

sr := Search(SearchPattern, False,False,False,False{(ch = BT_BACKSPACE) or (ch=#0)},Down);
if sr = -1 then
  sr := Search(SearchPattern,False,True,False,False,Down);

if Assigned(FSearchFinished) then begin
    if (sr = -1) and (SearchPattern <>'')  then
      FSearchFinished(Self,OldPattern,(sr <> -1))
    else
      FSearchFinished(Self,SearchPattern,(sr <> -1));
  end;
if sr <> -1 then begin
  Selected := sr;
  end
else begin

  // beep here
  if SearchPattern <> '' then
    SearchPattern := OldPattern;
  //PlaySound('Stop',0,SND_ALIAS_ID or SND_ASYNC);
  end;


LastKeyDown := GetTickCount;
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
  //code := MakeLong(SB_THUMBPOSITION,VertScrollBar.Position + off);
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
    else if FSelItems[i] > Item then
      Dec(FSelItems[i]);
    end;
//  end;

// delete item from mail array
for i := Item to Length(FItems)-2 do begin
  FItems[i] := FItems[i+1];
  end;
SetLength(FItems,Count-1);

// if it was in selected array delete there also
if SelIdx <> -1 then begin
  for i := SelIdx to SelCount-2 do begin
    FSelItems[i] := FSelItems[i+1];
    end;
  SetLength(FSelItems,Length(FSelItems)-1);
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
  fs := TFileStream.Create(FileName,fmCreate or fmShareExclusive);
  State := gsSave;
  try
    SaveStart(fs,SaveFormat,TxtFullLog);
    ShowProgress := True;
    for i := Count-1 downto 0 do begin
      DoProgress(Count-1-i,Count-1);
      SaveItem(fs,i,SaveFormat);
    end;
    SaveEnd(fs,SaveFormat);
  finally
    fs.Free;
    ShowProgress := False;
    DoProgress(0,0);
    State := gsIdle;
  end;
end;

procedure THistoryGrid.SaveSelected(FileName: String; SaveFormat: TSaveFormat);
var
  fs: TFileStream;
  i: Integer;
begin
  Assert((SelCount > 1),'Save Selection is available when more than 1 item is selected');
  fs := TFileStream.Create(FileName,fmCreate or fmShareExclusive);
  State := gsSave;
  try
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
  finally
    fs.Free;
    ShowProgress := False;
    DoProgress(0,0);
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
'padding: 4px; }'+#13#10;

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
'<!ENTITY MSG "MESSAGE">'+#13#10+
'<!ENTITY FILE "FILETRANSFER">'+#13#10+
'<!ENTITY AUT "AUTHORIZATION REQUEST">'+#13#10+
'<!ENTITY ADD "ADDED">'+#13#10+
'<!ENTITY ICQEEX "ICQ EMAILEXPRESS">'+#13#10+
'<!ENTITY URL "URL">'+#13#10+
'<!ENTITY SMS "SMS">'+#13#10+
'<!ENTITY UNK "UNKNOWN">'+#13#10+
']>'+#13#10+
'<IMHISTORY>'+#13#10;

function ColorToCss(Color: TColor): String;
var
  first2, mid2, last2: String;
begin
  Result := IntToHex(ColorToRGB(Color),6);
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
  procedure SaveHTML;
  var
    title,head1,head2: String;
    i: integer;
  begin
  title := UTF8Encode(WideFormat('%s [%s] - [%s]',[Caption,ProfileName,ContactName]));
  head1 := UTF8Encode(WideFormat('%s',[Caption]));
  head2 := UTF8Encode(WideFormat('%s - %s',[ProfileName,ContactName]));
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
    WriteString(Stream,'.text { clear: left; }'+#13#10);
    WriteString(Stream,'.nick { float: right; }'+#13#10);
    WriteString(Stream,'.date { float: left; clear: left; }'+#13#10);
  end else begin
    WriteString(Stream,'.text { clear: right; }'+#13#10);
    WriteString(Stream,'.nick { float: left; }'+#13#10);
    WriteString(Stream,'.date { float: right; clear: right; }'+#13#10);
  end;
  WriteString(Stream,'.nick#inc { '+FontToCss(Options.FontContact)+' }'+#13#10);
  WriteString(Stream,'.nick#out { '+FontToCss(Options.FontProfile)+' }'+#13#10);
  WriteString(Stream,'.date { '+FontToCss(Options.FontTimestamp)+' }'+#13#10);
  for i := 0 to High(Options.ItemOptions) do
    WriteString(Stream,'.mes#event'+intToStr(i)+' { background-color: '+
      ColorToCss(Options.ItemOptions[i].textColor)+'; '+
      FontToCss(Options.ItemOptions[i].textFont)+' }'+#13#10);
  WriteString(Stream,'--></style>'+#13#10+'</head><body>'+#13#10);
  WriteString(Stream,'<h4>'+MakeTextHtmled(head1)+'</h4>'+#13#10);
  WriteString(Stream,'<h3>'+MakeTextHtmled(head2)+'</h3>'+#13#10);
  end;

  procedure SaveXML;
  var
    enc: string;
  begin
    //enc := 'windows-'+IntToStr(GetACP);
    enc := 'utf-8';
    WriteString(Stream,Format(xml,[enc,UTF8Encode(ProfileName)]));
  end;

  procedure SaveUnicode;
  begin
    WriteString(Stream,#255#254);
    WriteWideString(Stream,'###'#13#10);
    if Caption = '' then
      Caption := AnsiToWideString(TxtHistExport,hppCodepage);
    WriteWideString(Stream,WideFormat('### %s'#13#10,[Caption]));
    WriteWideString(Stream,WideFormat('### %s - %s'#13#10,[ProfileName,ContactName]));
    WriteWideString(Stream,AnsiToWideString(TxtGenHist1,hppCodepage)+#13#10);
    WriteWideString(Stream,'###'#13#10#13#10);
  end;

  procedure SaveText;
  begin
    WriteString(Stream,'###'#13#10);
    if Caption = '' then
      Caption := TxtHistExport;
    // bug there if cp_acp <> user_codepage !!!
    WriteString(Stream,WideToAnsiString(WideFormat('### %s'#13#10,[Caption]),CP_ACP));
    WriteString(Stream,WideToAnsiString(WideFormat('### %s - %s'#13#10,[ProfileName,ContactName]),CP_ACP));
    WriteString(Stream,TxtGenHist1+#13#10);
    WriteString(Stream,'###'#13#10#13#10);
  end;

begin
  case SaveFormat of
    sfHTML: SaveHTML;
    sfXML: SaveXML;
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

begin
  case SaveFormat of
    sfHTML: SaveHTML;
    sfXML: SaveXML;
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
      if (Word(Options.ItemOptions[i].MessageType) and Word(mt)) >= Word(mt) then
        found := true
      else Inc(i);
    mes_id := 'event'+intToStr(i);
  end;

  procedure SaveHTML;
  var
    cnt: String;
    mes_id,type_id: String;
    txt: String;
  begin
    if mtIncoming in FItems[Item].MessageType then cnt := UTF8Encode(ContactName)
                                              else cnt := UTF8Encode(ProfileName);
    cnt := MakeTextHtmled(cnt+':');
    txt := MakeTextHtmled(UTF8Encode(FItems[Item].Text));
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
    WriteString(Stream,'<div class=mes id='+mes_id+'>'+#13#10);
    WriteString(Stream,#9+'<div class=nick id='+type_id+'>'+cnt+'</div>'+#13#10);
    WriteString(Stream,#9+'<div class=date>'+GetTime(FItems[Item].Time)+'</div>'+#13#10);
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
    date,cnt: WideString;
  begin
    if mtIncoming in FItems[Item].MessageType then cnt := ContactName
    else cnt := ProfileName;
    date := GetTime(FItems[Item].Time);
    WriteWideString(Stream,WideFormat('[%s] %s:'#13#10,[date,cnt]));
    WriteWideString(Stream,FItems[Item].Text+#13#10+#13#10);
  end;

  procedure SaveText;
  var
    date,cnt: String;
  begin
    // bug there if cp_acp <> user codepage
    if mtIncoming in FItems[Item].MessageType then cnt := WideToAnsiString(ContactName,CP_ACP)
                                              else cnt := WideToAnsiString(ProfileName,CP_ACP);
    date := WideToAnsiString(GetTime(FItems[Item].Time),CP_ACP);
    WriteString(Stream,Format('[%s] %s:'#13#10,[date,cnt]));
    WriteString(Stream,WideToAnsiString(FItems[Item].Text,CP_ACP)+#13#10+#13#10);
  end;

begin
  LoadItem(Item,False);
  case SaveFormat of
    sfHTML: SaveHTML;
    sfXML: SaveXML;
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

procedure THistoryGrid.SetRichRTL(RTL: Boolean; RichEdit: TTntRichEdit; ProcessTag: Boolean = true);
var
  pf: PARAFORMAT2;
begin
  // we use RichEdit.Tag here to save previous RTL state to prevent from
  // reapplying same state, because SetRichRTL is called VERY OFTEN
  // (from ApplyItemToRich)
  // tmp
  if (RichEdit.Tag = Integer(RTL)) and ProcessTag then exit;
  pf.cbSize := SizeOf(pf);
  pf.dwMask := PFM_RTLPARA;
  if RTL then begin
    pf.wReserved := PFE_RTLPARA;
  end else begin
    pf.wReserved := 0;
  end;
  RichEdit.Perform(EM_SETPARAFORMAT,0,integer(@pf));
  //FRich.Perform(EM_SETPARAFORMAT,0,integer(@pf));
  //FRichInline.Perform(EM_SETPARAFORMAT,0,integer(@pf));
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
  ch,ph,th: Integer;
  pf: PARAFORMAT2;
begin
  // recalc fonts
  for i := 0 to Length(FItems)-1 do begin
    FItems[i].Height := -1;
  end;
  FRichCache.ResetAllItems;

  pf.cbSize := SizeOf(pf);
  pf.dwMask := PFM_RTLPARA;

  //RTLEnabled := Options.RTLEnabled;

  //if Options.RTLEnabled then begin
  if (RTLMode = hppRTLEnable) or ((RTLMode = hppRTLDefault) and Options.RTLEnabled) then begin
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
  end;
  //SendMessage(FRich.Handle,EM_SETPARAFORMAT,0,integer(@pf));
  //SendMessage(FRichInline.Handle,EM_SETPARAFORMAT,0,integer(@pf));
  //FRich.Perform(EM_SETPARAFORMAT,0,integer(@pf));
  //FRichInline.Perform(EM_SETPARAFORMAT,0,integer(@pf));

  Canvas.Font := Options.FontProfile;
  //ph := Canvas.TextHeight('Wy');
  ph := WideCanvasTextHeight(Canvas,'Wy');
  Canvas.Font := Options.FontContact;
  //ch := Canvas.TextHeight('Wy');
  ch := WideCanvasTextHeight(Canvas,'Wy');
  Canvas.Font := Options.FontTimestamp;
  //th := Canvas.Textheight('Wy');
  th := WideCanvasTextHeight(Canvas,'Wy');
  // find heighest and don't forget about icons
  PHeaderHeight := Max(ph,th);
  CHeaderHeight := Max(ch,th);
  SessHeaderHeight := th+1+3*2;
  if Options.ShowIcons then begin
    CHeaderHeight := Max(CHeaderHeight,16);
    PHeaderHeight := Max(PHeaderHeight,16);
  end;

  Inc(CHeaderHeight,Padding);
  Inc(PHeaderHeight,Padding);

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
begin
  if FRTLMode = Value then exit;
  FRTLMode := Value;
  FRichCache.ResetAllItems;
  Repaint;
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
      FSelected := 0;
      SetSBPos(GetIdx(0));
      if Reversed then
        Selected := GetPrev(-1)
      else
        Selected := GetNext(-1);
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
  ItemFont: TFont;
  ItemColor: TColor;
  //t: String;
begin
  Result := [];
  Item := FindItemAt(X,Y);
  if Item <> -1 then
    Include(Result,ghtItem)
  else
    exit;
  ItemRect := GetItemRect(Item);
  InflateRect(ItemRect,-Padding,-Padding); // paddings
  Dec(ItemRect.Bottom); // divider
  if mtIncoming in FItems[Item].MessageType then
    Inc(ItemRect.Top,CHeaderHeight)
  else
    Inc(ItemRect.Top,PHeaderHeight);
  if not PointInRect(Point(x,y),ItemRect) then
    Include(Result,ghtHeader)
  else
    Include(Result,ghtText);
end;

procedure THistoryGrid.OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  //x := 0;
end;

procedure THistoryGrid.DoUrlMouseMove(Url: WideString);
begin
  OverURL := True;
  OverURLStr := URL;
end;

procedure THistoryGrid.HandleRichEditMouse(Message: DWord; X, Y: Integer);
var
  Item: Integer;
  ItemRect: TRect;
  PrevHwnd: THandle;
  hh: Integer;
  RichX,RichY: word;
begin
  Item := FindItemAt(x,y);
  if Item <> -1 then begin
    ItemRect := GetRichEditRect(Item);
    if not PointInRect(Point(x,y),ItemRect) then exit;
    RichX := x - ItemRect.Left;
    RichY := y - ItemRect.Top;

    ApplyItemToRich(Item);
    // make it that height so we don't loose any clicks
    FRich.Height := FRichHeight;
    //res := SendMessage(FRich.Handle,WM_SETFOCUS,0,0);
    //res := SendMessage(FRich.Handle,Message,0,MakeLParam(RichX,RichY));
    PrevHwnd := Windows.SetFocus(FRich.Handle);
    //FRich.Perform(WM_SETFOCUS,0,0);
    FRich.Perform(Message,0,MakeLParam(RichX,RichY));
   // FRich.Perform(WM_KILLFOCUS,PrevHwnd,0);
    Windows.SetFocus(PrevHwnd);
  end;
end;

procedure THistoryGrid.EditInline(Item: Integer);
var
  margins: DWord;
  r: TRect;
begin
  if State = gsInline then
    CancelInline;
  MakeVisible(Item);
  r := GetRichEditRect(Item);
  if IsRectEmpty(r) then exit;
  //margins := SendMessage(FRichInline.Handle,EM_GETMARGINS,0,0);
  margins := FRichInline.Perform(EM_GETMARGINS,0,0);
  Dec(r.left,LoWord(margins));
  Inc(r.right,HiWord(margins));
  // dunno why, but I have to fix it by 1 pixel
  // or positioning will be not perfectly correct
  // who knows why? i want to know! I already make corrections of margins!
  Dec(r.left,1);
  Inc(r.right,1);

  FRichInline.Top := r.top;
  FRichInline.Left := r.left - LoWord(margins);
  FRichInline.Width := r.right - r.left;
  FRichInline.Height := r.Bottom - r.top;
  //FRichInline.Left := FRichInline.Left - LoWord(margins);
  //FRichInline.Width := FRichInline.Width + LoWord(margins) + HiWord(margins);

  // below is not optimal way to show rich edit
  // (ie me better show it after applying item),
  // but it's done because now when we have OnProcessItem
  // event grid state is gsInline, which is how it should be
  // and you can't set it inline before setting focus
  // because of CheckBusy abort exception

  //FRichInline.Show;
  //FRichInline.SetFocus;
  //State := gsInline;
  State := gsInline;
  ApplyItemToRich(Item, FRichInline);
  State := gsIdle;
  FRichInline.SelStart := 0;
  FRichInline.SelLength := 0;
  FRichInline.Show;
  FRichInline.SetFocus;
  State := gsInline;
  //FRichInline.SelectAll;
end;

procedure THistoryGrid.CancelInline;
begin
  if State <> gsInline then exit;
  State := gsIdle;
  Self.SetFocus;
  FRichInline.Hide;
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

procedure THistoryGrid.RichInlineOnExit(Sender: TObject);
begin
  CancelInline;
end;

procedure THistoryGrid.RichInlineOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
end;

procedure THistoryGrid.RichInlineOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_RETURN) then begin
    Key := 0;
    CancelInline;
    end;
  Key := 0;
end;

function THistoryGrid.GetRichEditRect(Item: Integer): TRect;
var
  r: TRect;
  hh: Integer;
begin
  Result := Rect(0,0,0,0);
  if Item = -1 then exit;
  Result := GetItemRect(Item);
  Inc(Result.Left,Padding);
  Dec(Result.Right,Padding);
  if mtIncoming in FItems[Item].MessageType then
    hh := CHeaderHeight
  else
    hh := PHeaderHeight;
  Inc(Result.Top,hh+Padding);
  Dec(Result.Bottom,Padding+1);
  if (Items[Item].HasHeader) and (ShowHeaders) then
    Inc(Result.Top,SessHeaderHeight);
  IntersectRect(r,ClientRect,Result);
  Result := r;
end;

function THistoryGrid.SearchItem(ItemID: Integer): Integer;
var
  i,FirstItem: Integer;
  found: Boolean;
begin
  if not Assigned(OnSearchItem) then
    raise Exception.Create('You must handle OnSearchItem event to use SearchItem function');

  Result := -1;
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
  State := gsIdle;
end;

procedure THistoryGrid.CopyToClipSelected(const Format: WideString = ''; Codepage: Cardinal = CP_ACP);

  function GetItemText(Item: Integer; const Format: WideString = ''): WideString;
  var
    name: WideString;
  begin
    Result := Format;
    Result := Tnt_WideStringReplace(Result,'\n',#13#10,[rfReplaceAll]);
    if Assigned(FGetNameData) then
      FGetNameData(Self,Item,name)
    else if mtIncoming in Items[Item].MessageType then
      name := ContactName
    else
      name := ProfileName;
    Result := Tnt_WideStringReplace(Result,'%n',name,[rfReplaceAll]);
    Result := Tnt_WideStringReplace(Result,'%t',TimestampToString(Items[Item].Time),[rfReplaceAll]);
    Result := Tnt_WideStringReplace(Result,'%m',Items[Item].Text,[rfReplaceAll]);
  end;

var
  t: WideString;
  i: Integer;
begin
  if Selected = -1 then exit;
  t := '';
  if SelCount = 1 then
    t := GetItemText(Selected, Format)
  else begin
    if SelItems[0] > SelItems[SelCount-1] then
      for i := 0 to SelCount-1 do t := t + GetItemText(SelItems[i],Format) + #13#10
    else
      for i := SelCount-1 downto 0 do t := t + GetItemText(SelItems[i],Format) + #13#10;
    t := TrimRight(t);
  end;
  CopyToClip(t,Handle,Codepage);
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
  ShowIcons := False;
  RTLEnabled := False;
  SmileysEnabled := False;
  BBCodesEnabled := False;
  MathModuleEnabled := False;

  FLocks := 0;
  Changed := 0;

  FIconOther := TIcon.Create;
  FIconOther.OnChange := FontChanged;
  FIconFile := TIcon.Create;
  FIconFile.OnChange := FontChanged;
  FIconUrl := TIcon.Create;
  FIconUrl.OnChange := FontChanged;
  FIconMessage := TIcon.Create;
  FIconMessage.OnChange := FontChanged;

  FFontContact := TFont.Create;
  FFontContact.OnChange := FontChanged;
  FFontProfile := TFont.Create;
  FFontProfile.OnChange := FontChanged;
  FFontTimestamp := TFont.Create;
  FFontTimestamp.OnChange := FontChanged;

  FItemFont := TFont.Create;

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
  FFontTimestamp.Free;
  FItemFont.Free;
  FIconUrl.Free;
  FIconMessage.Free;
  FIconFile.Free;
  FIconOther.Free;
  for i := 0 to Length(FItemOptions) - 1 do begin
    FItemOptions[i].textFont.Free;
  end;
  SetLength(FItemOptions,0);
  SetLength(Grids,0);
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

procedure TGridOptions.EndChange;
begin
  if FLocks = 0 then exit;
  Dec(FLocks);
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

procedure TGridOptions.GetItemOptions(Mes: TMessageTypes; out textFont: TFont; out textColor: TColor);
var
  i: integer;
  found: boolean;
begin
  i := 0;
  found := false;
  while (not found) and (i <= High(FItemOptions)) do
    if (Word(FItemOptions[i].MessageType) and Word(Mes)) >= Word(Mes) then begin
      textFont := FItemOptions[i].textFont;
      textColor := FItemOptions[i].textColor;
      found := true;
    end else Inc(i);
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

procedure TGridOptions.SetIconOther(const Value: TIcon);
begin
FIconOther.Assign(Value);
FIconOther.OnChange := FontChanged;
DoChange;
end;

procedure TGridOptions.SetIconFile(const Value: TIcon);
begin
FIconFile.Assign(Value);
FIconFile.OnChange := FontChanged;
DoChange;
end;

procedure TGridOptions.SetIconMessage(const Value: TIcon);
begin
FIconMessage.Assign(Value);
FIconMessage.OnChange := FontChanged;
DoChange;
end;

procedure TGridOptions.SetIconUrl(const Value: TIcon);
begin
FIconUrl.Assign(Value);
FIconUrl.OnChange := FontChanged;
DoChange;
end;

procedure TGridOptions.SetOnShowIcons(const Value: TOnShowIcons);
begin
  FOnShowIcons := Value;
end;

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

procedure TGridOptions.SetFontTimestamp(const Value: TFont);
begin
  FFontTimestamp := Value;
  FFontTimestamp.OnChange := FontChanged;
  DoChange;
end;

procedure TGridOptions.StartChange;
begin
  Inc(FLocks);
end;

{ TRichCache }

procedure TRichCache.ApplyItemToRich(Item: PRichItem);
begin
  Grid.ApplyItemToRich(Item.GridItem,Item.Rich);
  // force to send the size:
  SendMessage(Item.Rich.Handle,EM_SETEVENTMASK, 0, ENM_REQUESTRESIZE);
  SendMessage(Item.Rich.Handle,EM_REQUESTRESIZE,0, 0);
  SendMessage(Item.Rich.Handle,EM_SETEVENTMASK, 0, RichEventMasks);
  {if FRichHeight = 0 then begin
    Item.Rich.Text := Item.Rich.Text + 'sasme/m,ds ad34!a9-1da'; // any junk here
    Grid.ApplyItemToRich(Item.GridItem,Item.Rich);
  end;}
  Assert(FRichHeight <> 0, 'CalcItemHeight: rich is still 0 height');
end;

function TRichCache.CalcItemHeight(GridItem: Integer): Integer;
var
  Item: PRichItem;
begin
  Item := RequestItem(GridItem);
  Assert(Item <> nil);
  Result := Item.Height;
end;

constructor TRichCache.Create(AGrid: THistoryGrid);
var
  i: Integer;
  Rich: TtntRichEdit;
  RichItem: PRichItem;
begin
  inherited Create;

  FRichHeight := -1;
  Grid := AGrid;
  // cache size:
  SetLength(Items,20);

  RichEventMasks := EN_LINK;
  RichEventMasks := ENM_CHANGE or ENM_SELCHANGE or ENM_PROTECTED or ENM_LINK;

  for i := 0 to Length(Items) - 1 do begin
    New(RichItem);
    RichItem.Bitmap := TBitmap.Create;
    RichItem^.Height := -1;
    RichItem^.GridItem := -1;
    RichItem^.Rich := TTntRichEdit.Create(nil);
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
    FreeAndNil(Items[i].Rich);
    FreeAndNil(Items[i].Bitmap);
    Dispose(Items[i]);
  end;
  SetLength(Items,0);
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

function TRichCache.GetItemRich(GridItem: Integer): TTntRichEdit;
var
  Item: PRichItem;
begin
  Item := RequestItem(GridItem);
  Assert(Item <> nil);
  Result := Item.Rich;
end;

function TRichCache.GetItemRichBitmap(GridItem: Integer): TBitmap;
var
  Item: PRichItem;
begin
  Item := RequestItem(GridItem);
  if not Item.BitmapDrawn then
    PaintRichToBitmap(Item);
  Assert(Item <> nil);
  Result := Item.Bitmap;
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
  str: String;
begin
  {$IFDEF DELPHI_7}
  Item.Bitmap.SetSize(Item.Rich.Width,Item.Height);
  {$ELSE}
  Item.Bitmap.Width := Item.Rich.Width;
  Item.Bitmap.Height := Item.Height;
  {$ENDIF}

  //str := 'Painted bitmap ['+IntToStr(item.bitmap.Height)+'] for rich "'+Copy(Item.Rich.Text,1,15)+'"';
  //OutputDebugString(PChar(str));

  rc := Rect(0,0,Item.Bitmap.Width,Item.Bitmap.Height);

  // because RichEdit sometimes paints smaller image
  // than it said when calculating height, we need
  // to fill the background
  BkColor := Item.Rich.Perform(EM_SETBKGNDCOLOR, 0,0);
  Item.Rich.Perform(EM_SETBKGNDCOLOR, 0, BkColor);
  Item.Bitmap.Canvas.Brush.Color := BkColor;
  Item.Bitmap.Canvas.FillRect(rc);

  LogX := GetDeviceCaps(Item.Bitmap.Canvas.Handle, LOGPIXELSX);
  LogY := GetDeviceCaps(Item.Bitmap.Canvas.Handle, LOGPIXELSY);

  rc.Left := rc.left * 1440 div LogX;
  rc.Top := rc.Top * 1440 div LogY;
  rc.Right := rc.Right * 1440 div LogX;
  rc.Bottom := rc.Bottom * 1440 div LogY;

  Range.hdc := Item.Bitmap.Canvas.Handle;
  Range.hdcTarget := Item.Bitmap.Canvas.Handle;
  Range.rc := rc;
  Range.rcPage := rc;
  Range.chrg.cpMin := 0;
  Range.chrg.cpMax := -1;

  Item.Rich.Perform(EM_FORMATRANGE, 1, Longint(@Range));
  Item.BitmapDrawn := True;
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
    Result.BitmapDrawn := False;
   // PaintRichToBitmap(Result);
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
  re_mask: DWord;
begin
  for i := 0 to Length(Items) - 1 do begin
    Items[i].Rich.ParentWindow := Grid.Handle;
    //re_mask := Items[i].Rich.Perform(EM_GETEVENTMASK, 0, 0);
    SendMessage(Items[i].Rich.Handle,EM_SETEVENTMASK, 0, RichEventMasks);
    //re_mask or ENM_LINK);
    //re_mask := Items[i].Rich.Perform(EM_GETEVENTMASK, 0, 0);
    Items[i].Rich.Perform(EM_AUTOURLDETECT, DWord(True), 0);
    Items[i].Rich.Perform(EM_SETMARGINS,EC_LEFTMARGIN or EC_RIGHTMARGIN,0);
  end;
end;

procedure TRichCache.SetWidth(NewWidth: Integer);
var
  i: Integer;
begin
  for i := 0 to Length(Items) - 1 do begin
    Items[i].Rich.Width := NewWidth;
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

initialization
  Screen.Cursors[crHandPoint] := LoadCursor(0,IDC_HAND);
  if Screen.Cursors[crHandPoint] = 0 then
    Screen.Cursors[crHandPoint] := LoadCursor(hInstance,'CR_HAND');
end.
