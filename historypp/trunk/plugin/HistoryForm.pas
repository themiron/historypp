{-----------------------------------------------------------------------------
 HistoryForm (historypp project)

 Version:   1.4
 Created:   xx.03.2003
 Author:    Oxygen

 [ Description ]

  Main window with history listing

 [ History ]

 1.4
 - Fixed bug on closing history window with FindDialog opened

 1.3 ()
 + Added XML export
 + URL & File highlight handling
 * "Reply Quoted" now is "Forward Message", and it forwards now,
   instead of sending
 - Fixed possible bug when opening hist. window and deleting contact
   now hist. window closes on contact deletion.
 1.2
 1.1
 1.0 (xx.02.03) First version.

 [ Modifications ]
 * (29.05.2003) Added FindDialog.CloseDialog to Form.OnClose so now
   closing history window without closing find dialog don't throws
   exception

 [ Known Issues ]

 * Not very good support of EmailExpress events (togeter
   with HistoryGrid.pas)

 Copyright (c) Art Fedorov, 2003
-----------------------------------------------------------------------------}


unit HistoryForm;

interface

uses
  Windows, Messages, SysUtils, Classes, RichEdit,
  Graphics, Controls, Forms, Dialogs, Buttons, StdCtrls, Menus, ComCtrls, ExtCtrls,
  TntSysUtils, TntForms, TntDialogs, TntComCtrls, {WFindDialog,}
  m_globaldefs, m_api,
  hpp_global, hpp_database, hpp_messages, hpp_events, hpp_contacts, hpp_itemprocess,
  hpp_forms,
  clipbrd, {FileCtrl,} shellapi,
  HistoryGrid, Checksum, WFindReplaceDialog, TntExtCtrls, hpp_sessionsthread, DateUtils,
  ImgList, PasswordEditControl, TntStdCtrls, TntButtons, TntMenus,
  CommCtrl, ToolWin;

const
  HM_EVENTADDED   = WM_APP + 100;
  HM_EVENTDELETED = WM_APP + 101;
  HM_PRESHUTDOWN  = WM_APP + 102;

type

  TLastSearch = (lsNone,lsHotSearch,lsSearch);

  THistoryFrm = class(TTntForm)
    SaveDialog: TSaveDialog;
    pmGrid: TTntPopupMenu;
    paClient: TPanel;
    paGrid: TPanel;
    hg: THistoryGrid;
    sb: TTntStatusBar;
    pmLink: TTntPopupMenu;
    pmFile: TTntPopupMenu;
    paSess: TPanel;
    pmGridInline: TTntPopupMenu;
    spSess: TTntSplitter;
    ilSessions: TImageList;
    Panel1: TPanel;
    laSess: TTntLabel;
    sbCloseSess: TTntSpeedButton;
    CopyFile1: TTntMenuItem;
    N5: TTntMenuItem;
    OpenFileFolder2: TTntMenuItem;
    OpenFile2: TTntMenuItem;
    N13: TTntMenuItem;
    SaveSelected1: TTntMenuItem;
    N2: TTntMenuItem;
    Delete1: TTntMenuItem;
    CopyText1: TTntMenuItem;
    Copy1: TTntMenuItem;
    N12: TTntMenuItem;
    UserDetails1: TTntMenuItem;
    ReplyQuoted1: TTntMenuItem;
    SendMessage1: TTntMenuItem;
    N8: TTntMenuItem;
    Details1: TTntMenuItem;
    CancelInline1: TTntMenuItem;
    N10: TTntMenuItem;
    SelectAllInline: TTntMenuItem;
    CopyAllInline: TTntMenuItem;
    CopyInline: TTntMenuItem;
    Copy2: TTntMenuItem;
    N1: TTntMenuItem;
    OpeninNewWindow1: TTntMenuItem;
    Open1: TTntMenuItem;
    ContactRTLmode1: TTntMenuItem;
    ANSICodepage1: TTntMenuItem;
    RTLDisabled2: TTntMenuItem;
    RTLEnabled2: TTntMenuItem;
    RTLDefault2: TTntMenuItem;
    SystemCodepage1: TTntMenuItem;
    sbClearFilter: TTntSpeedButton;
    pbFilter: TPaintBox;
    tiFilter: TTimer;
    ilToolbar: TImageList;
    Toolbar: TTntToolBar;
    tbHistory: TTntToolButton;
    paPassHolder: TTntPanel;
    paPassword: TPanel;
    laPass: TTntLabel;
    Image1: TImage;
    laPass2: TTntLabel;
    edPass: TPasswordEdit;
    bnPass: TTntButton;
    pmHistory: TTntPopupMenu;
    SaveasRTF2: TTntMenuItem;
    SaveasXML2: TTntMenuItem;
    SaveasHTML2: TTntMenuItem;
    SaveasText2: TTntMenuItem;
    tbSearch: TTntToolButton;
    TntToolButton2: TTntToolButton;
    TntToolButton3: TTntToolButton;
    paSearch: TTntPanel;
    tbFilter: TTntToolButton;
    tbDelete: TTntToolButton;
    tbSessions: TTntToolButton;
    TntToolButton7: TTntToolButton;
    paSearchStatus: TTntPanel;
    laSearchState: TTntLabel;
    paSearchPanel: TTntPanel;
    sbSearchNext: TTntSpeedButton;
    sbSearchPrev: TTntSpeedButton;
    edSearch: TTntEdit;
    pbSearch: TPaintBox;
    tvSess: TTntTreeView;
    tbSave: TTntToolButton;
    tbCopy: TTntToolButton;
    tbHistorySearch: TTntToolButton;
    imSearchEndOfPage: TTntImage;
    imSearchNotFound: TTntImage;
    tbEventsFilter: TTntToolButton;
    TntToolButton4: TTntToolButton;
    N4: TTntMenuItem;
    Emptyhistory1: TTntMenuItem;
    pmEventsFilter: TTntPopupMenu;
    Showall1: TTntMenuItem;
    Customize1: TTntMenuItem;
    N6: TTntMenuItem;
    Passwordprotection1: TTntMenuItem;
    TopPanel: TPanel;
    paSearchButtons: TTntPanel;
    pmSessions: TTntPopupMenu;
    SessCopy: TTntMenuItem;
    SessSelect: TTntMenuItem;
    SessDelete: TTntMenuItem;
    N7: TTntMenuItem;
    SessSave: TTntMenuItem;
    tbUserMenu: TTntToolButton;
    tbUserDetails: TTntToolButton;
    TntToolButton6: TTntToolButton;
    procedure tbHistoryClick(Sender: TObject);
    procedure SaveasText2Click(Sender: TObject);
    procedure SaveasRTF2Click(Sender: TObject);
    procedure SaveasXML2Click(Sender: TObject);
    procedure SaveasHTML2Click(Sender: TObject);
    procedure tbSessionsClick(Sender: TObject);
    procedure pbSearchStatePaint(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure sbSearchPrevClick(Sender: TObject);
    procedure sbSearchNextClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure hgChar(Sender: TObject; Char: WideChar; Shift: TShiftState);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edSearchKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tbFilterClick(Sender: TObject);
    procedure pbSearchPaint(Sender: TObject);
    procedure paPassHolderResize(Sender: TObject);
    procedure TntFormShow(Sender: TObject);
    procedure tvSessMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    //procedure tvSessClick(Sender: TObject);
    procedure sbCloseSessClick(Sender: TObject);
    procedure hgItemFilter(Sender: TObject; Index: Integer; var Show: Boolean);
    procedure tvSessChange(Sender: TObject; Node: TTreeNode);
    //procedure bnConversationClick(Sender: TObject);

    procedure LoadHistory(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnCNChar(var Message: TWMChar); message WM_CHAR;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    //procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure hgItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
    procedure hgTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
    procedure hgPopup(Sender: TObject);
    //procedure cbFilterChange(Sender: TObject);
    procedure hgSearchFinished(Sender: TObject; Text: WideString; Found: Boolean);
    procedure hgDblClick(Sender: TObject);
    procedure SaveSelected1Click(Sender: TObject);
    procedure hgItemDelete(Sender: TObject; Index: Integer);
    procedure Delete1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Details1Click(Sender: TObject);
    procedure hgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure hgState(Sender: TObject; State: TGridState);
    //procedure cbSortChange(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure hgSelect(Sender: TObject; Item, OldItem: Integer);
    procedure hgXMLData(Sender: TObject; Index: Integer; var Item: TXMLItem);
    procedure OpenFile1Click(Sender: TObject);
    procedure OpenFileFolder1Click(Sender: TObject);
    procedure OpenLink1Click(Sender: TObject);
    procedure OpenLinkInNewWindow1Click(Sender: TObject);
    procedure CopyLink1Click(Sender: TObject);
    //procedure OpenFile2Click(Sender: TObject);
    //procedure OpenFileFolder2Click(Sender: TObject);
    //procedure CopyFile1Click(Sender: TObject);
    procedure bnPassClick(Sender: TObject);
    procedure edPassKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edPassKeyPress(Sender: TObject; var Key: Char);
    procedure CopyText1Click(Sender: TObject);
    procedure hgUrlClick(Sender: TObject; Item: Integer; Url: String);
    procedure hgUrlPopup(Sender: TObject; Item: Integer; Url: String);
    procedure hgProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
    procedure hgSearchItem(Sender: TObject; Item, ID: Integer; var Found: Boolean);
    procedure hgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    //procedure AddMenu(M: TMenuItem; FromM,ToM: TPopupMenu; Index: integer);
    procedure AddMenuArray(Menu: TTntPopupMenu; List: Array of TTntMenuItem; Index: integer);
    procedure ContactRTLmode1Click(Sender: TObject);
    procedure SelectAllInlineClick(Sender: TObject);
    procedure CopyInlineClick(Sender: TObject);
    procedure pmGridInlinePopup(Sender: TObject);
    procedure CopyAllInlineClick(Sender: TObject);
    procedure CancelInline1Click(Sender: TObject);
    procedure SendMessage1Click(Sender: TObject);
    procedure ReplyQuoted1Click(Sender: TObject);
    procedure UserDetails1Click(Sender: TObject);
    procedure CodepageChangeClick(Sender: TObject);
    procedure sbClearFilterClick(Sender: TObject);
    procedure pbFilterPaint(Sender: TObject);
    procedure StartHotFilterTimer;
    procedure EndHotFilterTimer;
    procedure tiFilterTimer(Sender: TObject);
    procedure tbHistorySearchClick(Sender: TObject);
    procedure Emptyhistory1Click(Sender: TObject);
    procedure EventsFilterItemClick(Sender: TObject);
    procedure Passwordprotection1Click(Sender: TObject);
    procedure tbEventsFilterClick(Sender: TObject);
    procedure paSearchPanelResize(Sender: TObject);
    procedure SessSelectClick(Sender: TObject);
    procedure pmGridPopup(Sender: TObject);
    procedure pmHistoryPopup(Sender: TObject);
    procedure tbUserMenuClick(Sender: TObject);
    procedure tvSessGetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private
    StartTimestamp: DWord;
    EndTimestamp: DWord;
    FhContact: THandle;
    hHookEventAdded,hHookEventDeleted,hHookEventPreShutdown: THandle;
    FPasswordMode: Boolean;
    SavedLinkUrl: String;
    HotFilterString: WideString;
    FilterState: Boolean;

    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GetMinMaxInfo;
    procedure WndProc(var Message: TMessage); override;
    //procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure LoadPosition;
    procedure SavePosition;

    procedure HMEventAdded(var Message: TMessage); message HM_EVENTADDED;
    procedure HMEventDeleted(var Message: TMessage); message HM_EVENTDELETED;
    procedure HMPreShutdown(var Message: TMessage); message HM_PRESHUTDOWN;

    procedure HookEvents;
    procedure UnhookEvents;

    procedure OpenDetails(Item: Integer);
    procedure SetPasswordMode(const Value: Boolean);
    procedure ProcessPassword;
    procedure TranslateForm;

    procedure SethContact(const Value: THandle);
    procedure LoadInOptions();

    procedure PreLoadHistory;
    procedure PostLoadHistory;
  public
    UserCodepage: Cardinal;
    UseDefaultCP: boolean;
    LastSearch: TLastSearch;
    HotString: WideString;
    LastHotIdx: Integer;
    EventDetailFrom: TForm;
    WindowList:TList;
    History:array of THandle;
    HistoryLength:integer;
    Protocol: String;
    RecentFormat: TSaveFormat;
    SessThread: TSessionsThread;
    Sessions: TSessArray;

    procedure SearchNext(Rev: Boolean; Warp: Boolean = True);
    procedure DeleteHistoryItem(ItemIdx:Integer);
    procedure AddHistoryItem(hDBEvent: THandle);
    procedure Load;
    function GridIndexToHistory(Index: Integer): Integer;
    function HistoryIndexToGrid(Index: Integer): Integer;
    function GetItemData(Index: Integer): THistoryItem;
    //procedure ApplyFilter(DoApply: boolean = true);
    procedure ReplyQuoted(Item: Integer);
    procedure OpenPassword;

    procedure SMItemsFound(var M: TMessage); message SM_ITEMSFOUND;
    procedure SMFinished(var M: TMessage); message SM_FINISHED;
    procedure AddEventToSessions(hDBEvent: THandle);
    procedure DeleteEventFromSessions(ItemIdx: Integer);
    procedure ShowSessions(Show: Boolean);

    procedure LoadSessionIcons;
    procedure LoadToolbarIcons;
    procedure LoadButtonIcons;

    procedure SetRecentEventsPosition(OnTop: Boolean);
    procedure ChangeSearchMode(Filter: Boolean);
    procedure Search(Next: Boolean; FromNext: Boolean = False);

    procedure ShowAllEvents;
    procedure SetEventFilter(FilterIndex: Integer = -1);
    procedure CreateEventsFilterMenu;
  protected
    procedure LoadPendingHeaders(rowidx: integer; count: integer);
  published
    procedure AlignControls(Control: TControl; var ARect: TRect); override;
  public
    property PasswordMode: Boolean read FPasswordMode write SetPasswordMode;
    property hContact: THandle read FhContact write SethContact;
  end;

  ThppEventFilter = record
    Name: WideString;
    Events: TMessageTypes;
  end;

var
  HistoryFrm: THistoryFrm;

const
  hppEventFilters: array[0..6] of ThppEventFilter = (
    (Name: 'Show all events'; Events: filAll),
    (Name: 'Messages'; Events: [mtMessage,mtIncoming,mtOutgoing]),
    //(Name: 'Recieved links'; Events: [mtUrl,mtIncoming]),
    (Name: 'Link URLs'; Events: [mtUrl,mtIncoming,mtOutgoing]),
    (Name: 'Files'; Events: [mtFile,mtIncoming,mtOutgoing]),
    (Name: 'Status changes'; Events: [mtStatus,mtIncoming,mtOutgoing]),
    (Name: 'SMTP Simple'; Events: [mtSMTPSimple,mtIncoming,mtOutgoing]),
    (Name: 'All except status'; Events: filAll - [mtStatus])
    );

procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);
function ParseUrlItem(Item: THistoryItem; out Url,Mes: WideString): Boolean;
function ParseFileItem(Item: THistoryItem; out FileName,Mes: WideString): Boolean;
//function GetItemFile(Item: THistoryItem; hContact: THandle): string;
//function GetItemUrl(Item: THistoryItem): string;

implementation

uses EventDetailForm, PassForm, hpp_options, hpp_services;

{$R *.DFM}

const
  HPP_SESS_YEARFORMAT  = 'yyyy';
  HPP_SESS_MONTHFORMAT = 'mmmm';
  HPP_SESS_DAYFORMAT   = 'd (h:nn)';

function Max(a,b:integer):integer;
begin if b>a then Result:=b else Result:=a end;
function NotZero(x:dword):dword;//used that array doesn't store 0 for already loaded data
begin if x=0 then Result:=1 else Result:=x end;

{function GetItemFile(Item: THistoryItem; hContact: THandle): String;
var
  filename,mes: string;
  dir: array[0..MAX_PATH] of Char;
begin
  if not ParseFileItem(Item,Filename,mes) then exit;
  if mtOutgoing in Item.MessageType then begin
    Result := filename;
    exit;
  end;
  if hContact = 0 then exit;
  if PluginLink.CallService(MS_FILE_GETRECEIVEDFILESFOLDER,hContact,Integer(@dir)) <> 0 then exit;
  Result := string(dir) + FileName;
end;}

{function GetItemUrl(Item: THistoryItem): string;
var
url,mes: string;
begin
ParseUrlItem(Item,url,mes);
Result := url;
end;}

function ParseUrlItem(Item: THistoryItem; out Url,Mes: WideString): Boolean;
var
  tmp1,tmp2: WideString;
  n: Integer;
begin
  Url := '';
  Mes := '';
  Result := False;
  if not (mtUrl in Item.MessageType) then exit;
  tmp1 := Item.Text;
  if tmp1 = '' then exit;
  Result := True;

  n := Pos(#10,tmp1);
  if n <> 0 then begin
    tmp2 := Copy(tmp1,1,n-2);
    Delete(tmp1,1,n);
  end else begin
    tmp2 := tmp1;
    tmp1 := '';
  end;

  Mes := tmp1;

  n := Pos(':',tmp2);
  if n <> 0 then begin
    tmp2 := Copy(tmp2,n+2,Length(tmp2));
  end else begin
    Result := False;
    tmp2 := '';
  end;

  url := tmp2;
end;

function ParseFileItem(Item: THistoryItem; out FileName,Mes: WideString): Boolean;
var
  tmp1,tmp2: string;
  n: Integer;
begin
  Result := False;
  FileName := '';
  Mes := '';
  if not (mtFile in Item.MessageType) then exit;
  tmp1 := Item.Text;

  n := Pos(#10,tmp1);
  if n <> 0 then begin
    Delete(tmp1,1,n)
  end else
    exit;

  Result := True;

  n := Pos(#10,tmp1);
  if n <> 0 then begin
    tmp2 := tmp1;
    tmp1 := Copy(tmp2,1,n-2);
    Delete(tmp2,1,n);
  end;

  Mes := tmp2;
  FileName := tmp1;
end;

function GetEventInfo(hDBEvent: DWord): TDBEVENTINFO;
var
  BlobSize:Integer;
begin
  ZeroMemory(@Result,SizeOf(Result));
  Result.cbSize:=SizeOf(Result);
  Result.pBlob:=nil;
  BlobSize:=PluginLink.CallService(MS_DB_EVENT_GETBLOBSIZE,hDBEvent,0);

  GetMem(Result.pBlob,BlobSize);
  Result.cbBlob:=BlobSize;

  PluginLink.CallService(MS_DB_EVENT_GET,hDBEvent,Integer(@Result));
end;

(*
This function gets only name of the file
and tries to make it FAT-happy, so we trim out and
":"-s, "\"-s and so on...
*)
function MakeFileName(FileName: String): String;
begin
  Result := FileName;
  Result := StringReplace(Result,':','_',[rfReplaceAll]);
  Result := StringReplace(Result,'\','_',[rfReplaceAll]);
  Result := StringReplace(Result,'/','_',[rfReplaceAll]);
  Result := StringReplace(Result,'*','_',[rfReplaceAll]);
  Result := StringReplace(Result,'?','_',[rfReplaceAll]);
  Result := StringReplace(Result,'"','''',[rfReplaceAll]);
  Result := StringReplace(Result,'<',']',[rfReplaceAll]);
  Result := StringReplace(Result,'>','[',[rfReplaceAll]);
  Result := StringReplace(Result,'|','',[rfReplaceAll]);
end;

function MakeTextXMLed(Text: String): String;
begin;
  Result := Text;
  Result := StringReplace(Result,'&','&amp;',[rfReplaceAll]);
  Result := StringReplace(Result,'>','&gt;',[rfReplaceAll]);
  Result := StringReplace(Result,'<','&lt;',[rfReplaceAll]);
  Result := StringReplace(Result,'“','&quot;',[rfReplaceAll]);
  Result := StringReplace(Result,'‘','&apos;',[rfReplaceAll]);
end;

function MakeTextXMLedW(Text: WideString): WideString;
begin;
  Result := Text;
  Result := Tnt_WideStringReplace(Result,'&','&amp;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'>','&gt;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'<','&lt;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'“','&quot;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'‘','&apos;',[rfReplaceAll]);
end;

procedure THistoryFrm.LoadHistory(Sender: TObject);
//Load the History from the Database and Display it in the grid
  procedure FastLoadHandles;
  var
    hDbEvent: THandle;
    LineIdx: integer;
    ToRead: integer;
  begin
    HistoryLength:=PluginLink.CallService(MS_DB_EVENT_GETCOUNT,hContact,0);
    if HistoryLength = -1 then begin
      // contact is missing
      // or other error ?
      HistoryLength := 0;
    end;
    SetLength(History,HistoryLength);
    if HistoryLength=0 then Exit;
    hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDLAST,hContact,0);
    History[HistoryLength-1] := NotZero(hDbEvent);
    {if NeedhDBEvent = 0 then toRead := Max(0,HistoryLength-hppLoadBlock-1)
                        else toRead := 0;}
    toRead := Max(0,HistoryLength-hppFirstLoadBlock-1);
    LineIdx:=HistoryLength-2;
    repeat
      hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDbEvent,0);
      History[LineIdx] :=NotZero(hDbEvent);
      {if NeedhDBEvent = hDbEvent then begin
        Result := HistoryLength-LineIdx-1;
        toRead := Max(0,Result-hppLoadBlock shr 1);
      end;}
      dec(LineIdx);
    until LineIdx < toRead;
  end;
begin
  FastLoadHandles;
  if hContact = 0 then Protocol := 'ICQ'
                  else Protocol := GetContactProto(hContact);
  hg.ProfileName := GetContactDisplayName(0, Protocol);
  hg.ContactName := GetContactDisplayName(hContact, Protocol, true);
  UserCodepage := GetContactCodePage(hContact,Protocol,UseDefaultCP);
  hg.Codepage := UserCodepage;
  hg.RTLMode := GetContactRTLModeTRTL(hContact, Protocol);

  if hContact = 0 then Caption := TranslateW('System History')
                  else Caption := WideFormat(Caption,[hg.ContactName]);
  hg.Allocate(Length(History));
end;

procedure THistoryFrm.FormCreate(Sender: TObject);
var
  i: integer;
  mi: TTntMenuItem;
begin
  hg.BeginUpdate;

  Icon.ReleaseHandle;
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_CONTACTHISTORY].handle);
  LoadSessionIcons;
  LoadToolbarIcons;
  LoadButtonIcons;

  DesktopFont := True;
  MakeFontsParent(Self);

  hg.Filter := filAll;

  for i := 0 to High(cpTable) do begin
    mi := WideNewItem(cpTable[i].name,0,false,true,nil,0,'cp'+intToStr(i));
    mi.Tag := cpTable[i].cp;
    mi.OnClick := CodepageChangeClick;
    mi.AutoCheck := True;
    mi.RadioItem := True;
    ANSICodepage1.Add(mi);
  end;

  TranslateForm;

  //cbFilter.ItemIndex := 0;
  RecentFormat := sfHtml;
  hg.InlineRichEdit.PopupMenu := pmGridInline;
  //for i := 0 to pmOptions.Items.Count-1 do
  //  pmOptions.Items.Remove(pmOptions.Items[0]);
end;

procedure THistoryFrm.WMSysCommand(var Message: TWMSysCommand);
//show infodialog or font options
begin
  inherited;
  //if Message.CmdType and $FFF0 = $F200 then
  //  ;
  //if Message.CmdType and $FFF0 = $F220 then begin
  //  OpenOptions;
  //  end;
end;

procedure THistoryFrm.LoadPosition;
//load last position and filter setting
var
  filt: Integer;
  w,h,l,t: Integer;
begin
  // removed Utils_RestoreWindowPosition because it shows window sooner than we expect
  w := GetDBInt(hppDBName,'HistoryWindow.width',Self.Width);
  h := GetDBInt(hppDBName,'HistoryWindow.height',Self.Height);
  l := GetDBInt(hppDBName,'HistoryWindow.x',(Screen.Width-Self.Width) div 2);
  t := GetDBInt(hppDBName,'HistoryWindow.y',(Screen.Height - Self.Height) div 2);
  Self.SetBounds(l,t,w,h);
end;

procedure THistoryFrm.LoadSessionIcons;
var
  il: THandle;
begin
  tvSess.Items.BeginUpdate;
  try
    ImageList_Remove(ilSessions.Handle,-1); // clears image list
    il := ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,8,2);
    if il <> 0 then
      ilSessions.Handle := il
    else
      il := ilSessions.Handle;

    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESSION].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_SUMMER].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_AUTUMN].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_WINTER].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_SPRING].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_YEAR].handle);
  finally
    tvSess.Items.EndUpdate;
    //tvSess.Update;
  end;

  // simple hack to avoid dark icons
  ilSessions.BkColor := tvSess.Color;

end;

procedure THistoryFrm.LoadToolbarIcons;
var
  il: HIMAGELIST;
  ii: Integer;
  ic: HICON;
begin
  //tvSess.Items.BeginUpdate;
  try
    ImageList_Remove(ilToolbar.Handle,-1); // clears image list
    il := ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,10,2);
    if il <> 0 then
      ilToolbar.Handle := il
    else
      il := ilToolbar.Handle;
    Toolbar.Images := ilToolbar;

    // add other icons without processing
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_CONTACDETAILS].Handle);
    tbUserDetails.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_CONTACTMENU].Handle);
    tbUserMenu.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_CONTACTHISTORY].Handle);
    tbHistory.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_HOTFILTER].Handle);
    tbFilter.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_HOTSEARCH].Handle);
    tbSearch.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_DELETE].Handle);
    tbDelete.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_SESSIONS].Handle);
    tbSessions.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_SAVE].Handle);
    tbSave.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_COPY].Handle);
    tbCopy.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_GLOBALSEARCH].Handle);
    tbHistorySearch.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_EVENTSFILTER].Handle);
    tbEventsFilter.ImageIndex := ii;

  finally
    //Toolbar.Be
  end;
end;

procedure THistoryFrm.SavePosition;
//save position and filter setting
begin
  Utils_SaveWindowPosition(Self.Handle,0,hppDBName,'HistoryWindow.');
  if (hContact <> 0) and (not PasswordMode) and not ((HistoryLength = 0) and (not paSess.Visible)) then begin
     WriteDBBool(hppDBName,'ShowSessions',paSess.Visible);
     if paSess.Visible then
        WriteDBInt(hppDBName,'SessionsWidth',paSess.Width);
  end;
  if (hContact <> 0) then
    WriteDBBool(hppDBName,'ExpandHeaders',hg.ExpandHeaders);
end;

procedure THistoryFrm.HMEventAdded(var Message: TMessage);
//new message added to history (wparam=hcontact, lparam=hdbevent)
begin
  //if for this contact
  if dword(message.wParam)=hContact then begin
    //receive message from database
    AddHistoryItem(message.lParam);
    hgState(hg,hg.State);
  end;
end;

procedure THistoryFrm.HMEventDeleted(var Message: TMessage);
var
  i: Integer;
begin
  {wParam - hContact; lParam - hDBEvent}
  if (dword(message.wParam)=hContact) and (hg.State <> gsDelete) then
    for i := 0 to hg.Count - 1 do begin
      if (History[GridIndexToHistory(i)] = Message.lParam) then begin
        hg.Delete(i);
        DeleteHistoryItem(i);
        hgState(hg,hg.State);
        exit;
      end;
    end;
end;

procedure THistoryFrm.HMPreShutdown(var Message: TMessage);
begin
  Close;
end;

{Unfortunatly when you make a form from a dll this form won't become the
normal messages specified by the VCL but only the basic windows messages.
Therefore neither tabs nor button shortcuts work on this form. As a workaround
i've make some functions:}

procedure THistoryFrm.OnCNChar(var Message: TWMChar);
//make tabs work!
begin
  if not (csDesigning in ComponentState) then
    with Message do
    begin
      Result := 1;
      if (Perform(WM_GETDLGCODE, 0, 0) and DLGC_WANTCHARS = 0) and
        (GetParentForm(Self).Perform(CM_DIALOGCHAR,
        CharCode, KeyData) <> 0) then Exit;
      Result := 0;
    end;
end;

procedure THistoryFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Mask: Integer;
begin
  if (Key = VK_ESCAPE) or ((Key = VK_F4) and (ssAlt in Shift)) then begin
    Key := 0;
    close;
    exit;
  end;

  if (key = VK_F4) and (Shift=[]) and (not PasswordMode) then begin
    ShowSessions(not paSess.Visible);
    key := 0;
    end;

  if (key = VK_F3) and ((Shift=[]) or (Shift=[ssShift])) and (not PasswordMode) and (not FilterState) then begin
    if ssShift in Shift then
      sbSearchPrev.Click
    else
      sbSearchNext.Click;
    key := 0;
  end;

  if (ssAlt in Shift) then
    begin
    //if key=Ord('C') then
    //  bnClose.Click;
    //if (key=Ord('A')) and (not PasswordMode) then
    //  bbAddit.Click;
    //if (key=Ord('D')) and (not PasswordMode) then
    //  bnDelete.Click;
    //if (key=Ord('S')) and (not PasswordMode) then
    //  bnSearch.Click;
    //if (key=Ord('F')) and (not PasswordMode) then
    //  bnFilter.Click;
    //key:=0;
    end;

  // let only search keys be accepted if inline
  if hg.State = gsInline then begin
    exit;
    end;

  if (ssCtrl in Shift) then begin
    if (key=Ord('R')) and (not PasswordMode) then begin
      if hg.Selected <> -1 then ReplyQuoted(hg.Selected);
      key:=0;
      end;
    if (key=Ord('M')) and (not PasswordMode) then begin
      SendMessage1.Click;
      key:=0;
      end;
    if (key=Ord('I')) and (not PasswordMode) then begin
      UserDetails1.Click;
      key:=0;
      end;
    if (key=Ord('E')) and (not PasswordMode) then begin
      ChangeSearchMode(True);
      key:=0;
      end;
    if (key=Ord('F')) and (not PasswordMode) then begin
      ChangeSearchMode(False);
      key:=0;
      end;
    if ((key=Ord('C')) or (key = VK_INSERT)) and (not PasswordMode) then begin
      Copy1.Click;
      key:=0;
      end;
    if (key=Ord('T')) and (not PasswordMode) then begin
      CopyText1.Click;
      key:=0;
      end;
    end;

  with Sender as TWinControl do
    begin
      if Perform(CM_CHILDKEY, Key, Integer(Sender)) <> 0 then
        Exit;
      Mask := 0;
      case Key of
        VK_TAB:
          Mask := DLGC_WANTTAB;
        VK_RETURN, VK_EXECUTE, VK_ESCAPE, VK_CANCEL:
          Mask := DLGC_WANTALLKEYS;
      end;
      if (Mask <> 0)
        and (Perform(CM_WANTSPECIALKEY, Key, 0) = 0)
        and (Perform(WM_GETDLGCODE, 0, 0) and Mask = 0)
        and (Self.Perform(CM_DIALOGKEY, Key, 0) <> 0)
        then Exit;
    end;
end;

procedure THistoryFrm.FormClose(Sender: TObject; var Action: TCloseAction);
//var
  //h: hwnd;
begin
  try
    Action:=caFree;
    if Assigned(WindowList) then begin
      if WindowList.Count = 1 then begin
        // we are the last left
        if Assigned(PassCheckFm) then
          FreeAndNil(PassCheckFm);
        if Assigned(PassFm) then
          FreeAndNil(PassFm);
        end;
      WindowList.Delete(WindowList.IndexOf(Self));
      //Windows.ShowCaret(Handle);
      //Windows.ShowCursor(True);
    end;
    SavePosition;
    UnhookEvents;
    while SessThread <> nil do
      Application.ProcessMessages;
  except
  end;
end;

procedure THistoryFrm.Load;
begin
  PreLoadHistory;
  LoadHistory(Self);
  PostLoadHistory;
end;

var
  SearchUpHint: WideString = 'Search Up (Ctrl+Up)';
  SearchDownHint: WideString = 'Search Down (Ctrl+Down)';

procedure THistoryFrm.LoadButtonIcons;
var
  previc: HICON;
  nextic: HICON;
  prev_hint, next_hint: WideString;
begin
  if hg.Reversed then begin
    nextic := hppIcons[HPP_ICON_SEARCHUP].Handle;
    previc := hppIcons[HPP_ICON_SEARCHDOWN].Handle;
    sbSearchNext.Hint := SearchUpHint;
    sbSearchPrev.Hint := SearchDownHint;
  end
  else begin
    nextic := hppIcons[HPP_ICON_SEARCHDOWN].Handle;
    previc := hppIcons[HPP_ICON_SEARCHUP].Handle;
    sbSearchNext.Hint := SearchDownHint;
    sbSearchPrev.Hint := SearchUpHint;
  end;

  with sbSearchPrev.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := paSearch.Color;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      previc,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with sbSearchNext.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := paSearch.Color;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      nextic,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with sbClearFilter.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := paSearch.Color;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      hppIcons[HPP_ICON_HOTFILTERCLEAR].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;

  imSearchNotFound.Picture.Icon.Handle := CopyIcon(hppIcons[HPP_ICON_SEARCH_NOTFOUND].handle);
  imSearchEndOfPage.Picture.Icon.Handle := CopyIcon(hppIcons[HPP_ICON_SEARCH_ENDOFPAGE].handle);
end;

procedure THistoryFrm.LoadPendingHeaders(rowidx: integer; count: integer);
//reads hDBEvents from the database until this row (begin from end which was loaded at the startup)
// 2006.02.13 reads a windows with rowidx at center. Prefeching
var
  //startrowidx: integer;
  fromRow,tillRow: integer;
  fromRowIdx,tillRowIdx: integer;
  ridx: integer;
  hDBEvent: THandle;
begin
  if History[rowidx] <> 0 then Exit;
  {$IFDEF DEBUG}
  OutPutDebugString(PChar('Loading pending headers = '+intToStr(rowidx)));
  {$ENDIF}
  Screen.Cursor:=crHourGlass;
  try
    fromRow := rowidx + hppLoadBlock shr 1;
    if fromRow > HistoryLength-1 then fromRow := HistoryLength-1;
    fromRowIdx := rowidx;
    repeat
      Inc(fromRowIdx)
    until (fromRowIdx > HistoryLength-1) or (History[fromRowIdx] <> 0);

    tillRow := rowidx - hppLoadBlock shr 1;
    if tillRow < 0 then tillRow := 0;
    tillRowIdx := rowidx;
    repeat
      Dec(tillRowIdx)
    until (tillRowIdx < 0) or (History[tillRowIdx] <> 0);

    if fromRowIdx-rowidx < rowidx-tillRowIdx then begin
      if fromRowIdx > HistoryLength-1 then begin
        fromRowIdx := HistoryLength-1;
        hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDLAST,hContact,0);
        history[fromRowIdx] := hDBEvent;
      end else
        hDBEvent:=history[fromRowIdx];
      for ridx := fromRowIdx-1 downto tillRow do begin
        if history[ridx] <> 0 then break;
        hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDbEvent,0);
        history[ridx] := NotZero(hDbEvent);
      end;
    end else begin
      if tillRowIdx < 0 then begin
        tillRowIdx := 0;
        hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDFIRST,hContact,0);
        history[tillRowIdx] := hDBEvent;
      end else
        hDBEvent:=history[tillRowIdx];
      for ridx := tillRowIdx+1 to fromRow do begin
        if history[ridx] <> 0 then break;
        hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDbEvent,0);
        history[ridx] := NotZero(hDbEvent);
      end;
    end;
    {$IFDEF DEBUG}
    OutPutDebugString(PChar('... pending headers from '+intToStr(FromRow)+' to '+intToStr(tillRow)));
    {$ENDIF}
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure THistoryFrm.FormDestroy(Sender: TObject);
begin
  // this is the only event fired when history is open
  // and miranda is closed
  // (except now I added ME_SYSTEM_PRESHUTDOWN hook, which should work)
  if Assigned(EventDetailFrom) then
    EventDetailFrom.Release;
  Release;
end;

procedure THistoryFrm.DeleteHistoryItem(ItemIdx: Integer);
//history[itemidx] löschen (also row-1)
var
  p: integer;
begin
  for p:=ItemIdx to HistoryLength-2 do
    History[p]:=history[p+1];
  Dec(HistoryLength);
  SetLength(history,HistoryLength);
end;

procedure THistoryFrm.AddEventToSessions(hDBEvent: THandle);
var
  ts: DWord;
  dt: TDateTime;
  idx: Integer;
  year,month,day: TTntTreeNode;
  AddNewSession: Boolean;
begin
  ts := GetEventTimestamp(hDBEvent);
  AddNewSession := True;
  if Length(Sessions) > 0 then begin
    idx := High(Sessions);
    if (ts - Sessions[idx].TimestampLast) <= SESSION_TIMEDIFF then begin
      Sessions[idx].hDBEventLast := hDBEvent;
      Sessions[idx].TimestampLast := ts;
      Inc(Sessions[idx].ItemsCount);
      AddNewSession := False;
    end;
  end;
  if AddNewSession then begin
    idx := Length(Sessions);
    SetLength(Sessions,idx+1);
    Sessions[idx].hDBEventFirst := hDBEvent;
    Sessions[idx].TimestampFirst := ts;
    Sessions[idx].hDBEventLast := Sessions[idx].hDBEventFirst;
    Sessions[idx].TimestampLast := Sessions[idx].TimestampFirst;
    Sessions[idx].ItemsCount := 1;
    dt := TimestampToDateTime(ts);
    year := nil;
    if tvSess.Items.GetFirstNode <> nil then begin
      year := tvSess.Items.GetFirstNode;
      while year.getNextSibling <> nil do
        year := year.getNextSibling;
      if Integer(year.Data) <> YearOf(dt) then year := nil;
    end;
    if year = nil then begin
      year := tvSess.Items.AddChild(nil,FormatDateTime(HPP_SESS_YEARFORMAT,dt));
      year.Data := Pointer(YearOf(dt));
      year.ImageIndex := 5;
      //year.SelectedIndex := year.ImageIndex;
    end;
    month := nil;
    if year.GetLastChild <> nil then begin
      month := year.GetLastChild;
      if Integer(month.Data) <> MonthOf(dt) then month := nil;
    end;
    if month = nil then begin
      month := tvSess.Items.AddChild(year,FormatDateTime(HPP_SESS_MONTHFORMAT,dt));
      month.Data := Pointer(MonthOf(dt));
      case MonthOf(dt) of
        12,1..2: month.ImageIndex := 3;
        3..5: month.ImageIndex := 4;
        6..8: month.ImageIndex := 1;
        9..11: month.ImageIndex := 2;
      end;
      //month.SelectedIndex := month.ImageIndex;
    end;
    day := tvSess.Items.AddChild(month,FormatDateTime(HPP_SESS_DAYFORMAT,dt));
    day.Data := Pointer(idx);
    day.ImageIndex := 0;
    //day.SelectedIndex := day.ImageIndex;
  end;
end;

procedure THistoryFrm.AddHistoryItem(hDBEvent:THandle);
//only add single lines, not whole histories, because this routine is pretty
//slow
begin
  Inc(HistoryLength);
  SetLength(History,HistoryLength);
  History[HistoryLength-1] := hDBEvent;
  hg.AddItem;
  if HistoryLength = 1 then
    if GetDBBool(hppDBName,'ShowSessions',False) then
      ShowSessions(True);
end;

procedure THistoryFrm.HookEvents;
begin
  hHookEventAdded:=PluginLink.HookEventMessage(ME_DB_EVENT_ADDED,Self.Handle,HM_EVENTADDED);
  hHookEventDeleted := PluginLink.HookEventMessage(ME_DB_EVENT_DELETED,Self.Handle,HM_EVENTDELETED);
  hHookEventPreShutdown := PluginLink.HookEventMessage(ME_SYSTEM_PRESHUTDOWN,Self.Handle,HM_PRESHUTDOWN);
end;

procedure THistoryFrm.UnhookEvents;
begin
  PluginLink.UnhookEvent(hHookEventAdded);
  PluginLink.UnhookEvent(hHookEventDeleted);
  PluginLink.UnhookEvent(hHookEventPreShutdown);
end;

procedure THistoryFrm.hgItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
var
  PrevTimestamp: DWord;
begin
  Item := GetItemData(GridIndexToHistory(Index));
  Item.Proto := Protocol;
  if GridIndexToHistory(Index) = 0 then
    Item.HasHeader := True
  else begin
    if History[GridIndexToHistory(Index)-1] = 0 then
      LoadPendingHeaders(GridIndexToHistory(Index)-1,HistoryLength);
    PrevTimestamp := GetEventTimestamp(History[GridIndexToHistory(Index)-1]);
    Item.HasHeader := ((DWord(Item.Time) - PrevTimestamp) > SESSION_TIMEDIFF);
  end;
end;

procedure THistoryFrm.hgTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
begin
  Text := TimestampToString(Time);
end;

procedure THistoryFrm.hgPopup(Sender: TObject);
//var
//tmp1,tmp2: string;
begin
  //OpenURL1.Visible := False;
  //CopyLink1.Visible := False;
  //OpenURLNew1.Visible := False;
  //OpenFile1.Visible := False;
  //OpenFileFolder1.Visible := False;
  Delete1.Visible := False;
  SaveSelected1.Visible := False;
  if hContact = 0 then begin
    SendMessage1.Visible := False;
    ReplyQuoted1.Visible := False;
    UserDetails1.Visible := False;
  end;
  if hg.Selected <> -1 then begin
    //Details1.Default := True;
    Delete1.Visible := True;
    //if hContact <> 0 then
      //ReplyQuoted1.Visible := True;
    if hg.SelCount > 1 then
      SaveSelected1.Visible := True;
    {
    if mtURL in hg.Items[hg.Selected].MessageType then begin
      tmp1 := GetItemURL(hg.Items[hg.Selected]);
      if tmp1 <> '' then begin
        OpenURL1.Visible := True;
        //OpenURLNew1.Visible := True;
        CopyLink1.Visible := True;
        end;
      end;
    }
    {
    if mtFile in hg.Items[hg.Selected].MessageType then begin
      tmp1 := GetItemFile(hg.Items[hg.Selected],hContact);
      if tmp1 <> '' then begin
        if FileExists(tmp1) then
          OpenFile1.Visible := True;
        if DirectoryExists(ExtractFileDir(tmp1)) then
          OpenFileFolder1.Visible := True;
        end;
      end;
    }
    //AddMenuArray(pmGrid,[Options1,ANSICodepage1,ContactRTLmode1,N11,ConversationLog1],-1);
    pmGrid.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
  end;
end;

{procedure THistoryFrm.cbFilterChange(Sender: TObject);
var
  fil,filOthers: TMessageTypes;
begin
  LastSearch := lsNone;
  LastHotIdx := -1;
  HotString := '';
  filOthers := filAll;
  exclude(filOthers,mtMessage);
  exclude(filOthers,mtFile);
  exclude(filOthers,mtUrl);
  case cbFilter.ItemIndex of
    0: fil := filAll;
    1: fil := [mtMessage, mtIncoming];
    2: fil := [mtMessage, mtOutgoing];
    3: fil := [mtFile, mtIncoming, mtOutgoing];
    4: fil := [mtUrl, mtIncoming, mtOutgoing];
    5: fil := [mtStatus, mtIncoming, mtOutgoing];
    else
       fil := filOthers;
  end;
  hg.Filter := fil;
end;}

procedure THistoryFrm.hgSearchFinished(Sender: TObject; Text: WideString; Found: Boolean);
var
  t: WideString;
begin
  if LastSearch <> lsHotSearch then
    LastHotIdx := hg.Selected;
  LastSearch := lsHotSearch;
  if Text = '' then begin
    if (LastHotIdx <> -1) and (HotString <> '') then
      hg.Selected := LastHotIdx;
    LastSearch := lsNone;
    HotString := Text;
    hgState(Self,gsIdle);
    exit;
  end;
  HotString := Text;
  {
  if Found then t := 'Search: "'+Text+'" (Ctrl+Enter to search again)'
  else t := 'Search: "'+Text+'" (not found)';
  sb.SimpleText := t;
  }

  if not Found then t := HotString
               else t := Text;
  sb.SimpleText := WideFormat(TranslateWideW('HotSearch: %s (F3 to find next)'),[t]);
  //if Found then HotString := Text;
end;

procedure THistoryFrm.hgChar(Sender: TObject; Char: WideChar;
  Shift: TShiftState);
begin
  edSearch.Text := Char;
  if not paSearch.Visible then
    ChangeSearchMode(False);
  edSearch.SetFocus;
  edSearch.SelStart := Length(edSearch.Text);
  edSearch.SelLength := 0;
end;

procedure THistoryFrm.hgDblClick(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  hg.EditInline(hg.Selected);
end;

procedure THistoryFrm.SaveSelected1Click(Sender: TObject);
var
  t: String;
  SaveFormat: TSaveFormat;
begin
  RecentFormat := TSaveFormat(GetDBInt(hppDBName,'ExportFormat',0));
  SaveFormat := RecentFormat;
  PrepareSaveDialog(SaveDialog,SaveFormat,True);
  t := Translate('Partial History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  //t := t + SaveDialog.DefaultExt;
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
// why SaveDialog.FileName shows '' here???
// who knows? In debugger FFileName shows right file, but
// FileName property returns ''
  case SaveDialog.FilterIndex of
    1: SaveFormat := sfHtml;
    2: SaveFormat := sfXml;
    3: SaveFormat := sfRTF;
    4: SaveFormat := sfUnicode;
    5: SaveFormat := sfText;
  end;
  RecentFormat := SaveFormat;
  hg.SaveSelected(SaveDialog.Files[0],SaveFormat);
  //hg.SaveSelected(SaveDialog.FileName,SaveFormat);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.sbCloseSessClick(Sender: TObject);
begin
  ShowSessions(False);
end;

procedure THistoryFrm.sbSearchNextClick(Sender: TObject);
begin
  Search(True,True);
end;

procedure THistoryFrm.sbSearchPrevClick(Sender: TObject);
begin
  Search(False,True);
end;

procedure THistoryFrm.hgItemDelete(Sender: TObject; Index: Integer);
var
  idx: Integer;
begin
  idx := GridIndexToHistory(Index);
  DeleteEventFromSessions(idx);
  if History[idx] <> 0 then begin
    if Assigned(EventDetailFrom) then
      if TEventDetailsFrm(EventDetailFrom).Item=Index then
        EventDetailFrom.Release;
    PluginLink.CallService(MS_DB_EVENT_DELETE,hContact,History[idx]);
  end;
  DeleteHistoryItem(idx);
  Application.ProcessMessages;
end;

procedure THistoryFrm.hgItemFilter(Sender: TObject; Index: Integer;
  var Show: Boolean);
begin

  // if we have string filter
  if HotFilterString <> '' then begin
    if Pos(WideUpperCase(HotFilterString),WideUpperCase(hg.Items[Index].Text)) = 0 then
      Show := False;
    exit;
  end;

  // if filter by sessions disabled, then exit
  if StartTimestamp <> 0 then begin
    //Show := False;
    if hg.Items[Index].Time >= StartTimestamp then begin
      if EndTimestamp = 0 then exit
      else begin
        if hg.Items[Index].Time < EndTimestamp then exit
        else Show := False;
      end;
    end else Show := False;
  end;
end;

procedure THistoryFrm.Delete1Click(Sender: TObject);
begin
  if hg.SelCount = 0 then exit;
  if hg.SelCount > 1 then begin
    if HppMessageBox(Handle,
      WideFormat(TranslateWideW('Do you really want to delete selected items (%.0f)?'),
      [hg.SelCount/1]), TranslateWideW('Delete Selected'),
      MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = IDNO then exit;
  end else begin
    if HppMessageBox(Handle, TranslateWideW('Do you really want to delete selected item?'),
    TranslateWideW('Delete'), MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = IDNO then exit;
  end;
  SetSafetyMode(False);
  try
    hg.DeleteSelected;
  finally
    SetSafetyMode(True);
  end;
end;

function THistoryFrm.GridIndexToHistory(Index: Integer): Integer;
begin
  Result := Length(History)-1-Index;
end;

function THistoryFrm.HistoryIndexToGrid(Index: Integer): Integer;
begin
  Result := Length(History)-1-Index;
end;

procedure THistoryFrm.Copy1Click(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  CopyToClip(hg.FormatSelected(hg.Options.ClipCopyFormat),Handle,UserCodePage);
end;

procedure THistoryFrm.Details1Click(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  OpenDetails(hg.Selected);
end;

procedure THistoryFrm.OpenDetails(Item: Integer);
begin
  if not Assigned(EventDetailFrom) then begin
    EventDetailFrom:=TEventDetailsFrm.Create(Self);
    TEventDetailsFrm(EventDetailFrom).ParentForm := Self;
    TEventDetailsFrm(EventDetailFrom).Item := Item;
    TEventDetailsFrm(EventDetailFrom).Show;
  end else begin
    TEventDetailsFrm(EventDetailFrom).Item:=Item;
    TEventDetailsFrm(EventDetailFrom).Show;
  end;
end;

function THistoryFrm.GetItemData(Index: Integer): THistoryItem;
var
  hDBEvent:DWord;
begin
  hDBEvent := History[Index];
  if hDBEvent=0 then begin
    LoadPendingHeaders(Index,HistoryLength);
    hDBEvent:=history[Index];
    if hDBEvent=0 then
      raise EAbort.Create('can''t load event');
  end;
  Result := ReadEvent(hDBEvent,UserCodepage);
  {$IFDEF DEBUG}
  OutPutDebugString(PChar('Get item data from DB '+intToStr(Index)+' #'+intToStr(hDBEvent)));
  {$ENDIF}
end;

var
  WasReturnPressed: Boolean = False;

procedure THistoryFrm.hgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Shift=[]) then begin
    Delete1.Click;
    end;
  WasReturnPressed := (Key = VK_RETURN);
end;

procedure THistoryFrm.hgState(Sender: TObject; State: TGridState);
var
  Idle: Boolean;
  t: WideString;
begin
  if csDestroying in ComponentState then
    exit;
  Idle := (State <> gsDelete);
  case State of
    gsIdle:   t := WideFormat(TranslateWideW('%.0n items in history'),[HistoryLength/1]);
    gsLoad:   t := TranslateWideW('Loading...');
    gsSave:   t := TranslateWideW('Saving...');
    gsSearch: t := TranslateWideW('Searching...');
    gsDelete: t := TranslateWideW('Deleting...');
  end;
  if PasswordMode then
    t := '';

  sb.SimpleText := t;
end;

procedure THistoryFrm.DeleteEventFromSessions(ItemIdx: Integer);
var
  ts: DWord;
  dt: TDateTime;
  year,month,day: TTntTreeNode;
  i,idx: Integer;
  hDBEvent: THandle;
begin
  hDBEvent := History[ItemIdx];
  ts := GetEventTimestamp(hDBEvent);

  // find idx in sessions array
  idx := -1;
  for i := Length(Sessions) - 1 downto 0 do
    if (ts >= Sessions[i].TimestampFirst) and (ts <= Sessions[i].TimestampLast) then begin
      idx := i;
      break;
    end;
  if idx = -1 then exit;

  Dec(Sessions[idx].ItemsCount);

  // if the event is not first, we can do it faster
  if Sessions[idx].hDBEventFirst <> hDBEvent then begin
    if Sessions[idx].hDBEventLast = hDBEvent then begin
      hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDBEvent,0);
      if hDBEvent <> 0 then begin
        Sessions[idx].hDBEventLast := hDBEvent;
        Sessions[idx].TimestampLast := GetEventTimestamp(hDBEvent);
      end
      else begin //????
        Sessions[idx].hDBEventLast := Sessions[idx].hDBEventFirst;
        Sessions[idx].TimestampLast := Sessions[idx].TimestampFirst;
      end;
    end;
    exit;
  end;

  // now, the even is the first, probably the last in session
  dt := TimestampToDateTime(ts);
  year := tvSess.Items.GetFirstNode;
  while year <> nil do begin
    if Integer(year.data) = YearOf(dt) then
      break;
    year := year.getNextSibling;
  end;
  if year = nil then exit; // ???
  month := year.getFirstChild;
  while month <> nil do begin
    if Integer(month.data) = MonthOf(dt) then
      break;
    month := month.getNextSibling;
  end;
  if month = nil then exit; // ???
  day := month.getFirstChild;
  while day <> nil do begin
    if Integer(day.data) = idx then
      break;
    day := day.getNextSibling;
  end;
  if day = nil then exit; // ???
  if Sessions[idx].ItemsCount = 0 then begin
    day.Delete;
    if month.Count = 0 then
      month.Delete;
    if year.Count = 0 then
      year.Delete;
    // hmm... should we delete record in sessions array?
    // I'll not do it for the speed, I don't think there would be problems
    Sessions[idx].hDBEventFirst := 0;
    Sessions[idx].TimestampFirst := 0;
    Sessions[idx].hDBEventLast := 0;
    Sessions[idx].TimestampLast := 0;
    exit;
  end;
  hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBEvent,0);
  if hDBEvent <> 0 then begin
    Sessions[idx].hDBEventFirst := hDBEvent;
    Sessions[idx].TimestampFirst := GetEventTimestamp(hDBEvent);
  end
  else begin // ????
    Sessions[idx].hDBEventFirst := Sessions[idx].hDBEventLast;
    Sessions[idx].TimestampFirst := Sessions[idx].TimestampLast;
  end;
  ts := Sessions[idx].TimestampFirst;
  dt := TimestampToDateTime(ts);
  day.Text := FormatDateTime(HPP_SESS_DAYFORMAT,dt);
  // next item
  Inc(ItemIdx);
  if ItemIdx >= HistoryLength then exit;
  hg.ResetItem(HistoryIndexToGrid(ItemIdx));
end;

procedure THistoryFrm.SaveasHTML2Click(Sender: TObject);
var
  t: String;
begin
  PrepareSaveDialog(SaveDialog,sfHtml);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  RecentFormat := sfHTML;
  hg.SaveAll(SaveDialog.Files[0],sfHTML);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
  inherited;
  with Msg.MinMaxInfo^ do begin
    ptMinTrackSize.x:= 420;
    ptMinTrackSize.y:= 240;
    end
end;

{procedure THistoryFrm.WMSize(var Message: TWMSize);
begin
  inherited;
end;}

{procedure THistoryFrm.ApplyFilter(DoApply: boolean = true);
begin
  cbSortChange(cbSort);
  if not DoApply then cbFilter.ItemIndex := 0;
  cbFilterChange(cbFilter);
end;}

{procedure THistoryFrm.cbSortChange(Sender: TObject);
begin
  if hg.Reversed = (cbSort.ItemIndex = 0) then exit;
  hg.Reversed := (cbSort.ItemIndex = 0);
  LastSearch := lsNone;
  LastHotIdx := -1;
  HotString := '';
end;}

procedure THistoryFrm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
if PasswordMode then exit;
Handled := True;
(* we can get range check error (???) here
it looks that without range check it works ok
so turn it off *)
{$RANGECHECKS OFF}
hg.perform(WM_MOUSEWHEEL,MakeLong(MK_CONTROL,WheelDelta),0);
{$RANGECHECKS ON}
end;

procedure THistoryFrm.hgSelect(Sender: TObject; Item, OldItem: Integer);
begin
tbDelete.Enabled := (Item <> -1);
tbSave.Enabled := (hg.SelCount > 1);
tbCopy.Enabled := (Item <> -1);

if hg.HotString = '' then begin
  LastHotIdx := -1;
  // redraw status bar
  hgState(hg,gsIdle);
  end;
end;

procedure THistoryFrm.Search(Next, FromNext: Boolean);
var
  Down: Boolean;
  item: Integer;
  ShowEndOfPage: Boolean;
  ShowNotFound: Boolean;
  w: Integer;
begin
  if edSearch.Text = '' then begin
    paSearchStatus.Visible := False;
    edSearch.Color := clWindow;
    exit;
  end;
  if Next then Down := not hg.Reversed
          else Down := hg.Reversed;
  item := hg.Search(edSearch.Text,False,False,False,FromNext,Down);
  ShowEndOfPage := (item = -1);
  if item = -1 then
    item := hg.Search(edSearch.Text,False,True,False,FromNext,Down);
  if item <> -1 then begin
    hg.Selected := item;
    edSearch.Color := clWindow;
  end else begin
    edSearch.Color := $008080FF;
    ShowEndOfPage := False;
    ShowNotFound := True;
  end;
  if ShowNotFound or ShowEndOfPage then begin
    imSearchNotFound.Visible := ShowNotFound;
    imSearchEndOfPage.Visible := ShowEndOfPage;
    if ShowNotFound then
      laSearchState.Caption := TranslateWideW('Phrase not found')
    else if ShowEndOfPage then begin
      if Down then
        laSearchState.Caption := TranslateWideW('Continued from the top')
      else
        laSearchState.Caption := TranslateWideW('Continued from the bottom');
    end;
    paSearchStatus.Width := 22 + laSearchState.Width + 3;
    paSearchStatus.Left := paSearchButtons.Left - paSearchStatus.Width;
    paSearchStatus.Visible := True;
  end else begin
    paSearchStatus.Visible := False;
    //paSearchStatus.Width := 0;
  end;
  //paSearch2.Width := paSearchButtons.Left + paSearchButtons.Width;
end;

procedure THistoryFrm.SearchNext(Rev: Boolean; Warp: Boolean = True);
var
  stext,t,tCap: WideString;
  res: Integer;
  mcase,down: Boolean;
  WndHandle: HWND;
begin
  {if LastSearch = lsNone then exit;
  if LastSearch = lsHotSearch then begin
    stext := HotString;
    mcase := False;
  end else begin
    stext := FindDialog.FindText;
    mcase := (frMatchCase in FindDialog.Options);
  end;
  if stext = '' then exit;
  down := not hg.reversed;
  if Rev then Down := not Down;
  res := hg.Search(stext, mcase, not Warp, False, Warp, Down);
  if res <> -1 then begin
    // found
    hg.Selected := res;
    if LastSearch = lsSearch then
      t := TranslateWideW('Search: %s (F3 to find next)')
    else
      t := TranslateWideW('HotSearch: %s (F3 to find next)');
    sb.SimpleText := WideFormat(t,[stext]);
  end else begin
    if (LastSearch = lsSearch) and (FindDialog.Handle <> 0) then
      WndHandle := FindDialog.Handle
    else
      WndHandle := Handle;
    tCap := TranslateWideW('History++ Search');
    // not found
    if Warp and (down = not hg.Reversed) then begin
      // do warp?
      if HppMessageBox(WndHandle, TranslateWideW('You have reached the end of the history.')+
      #10#13+TranslateWideW('Do you want to continue searching at the beginning?'),
      tCap, MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = ID_YES then
        SearchNext(Rev,False);
    end else begin
      // not warped
      hgState(Self,gsIdle);
      // 25.03.03 OXY: FindDialog looses focus when
      // calling ShowMessage, using MessageBox instead
      t := TranslateWideW('"%s" not found');
      HppMessageBox(WndHandle, WideFormat(t,[stext]),tCap, MB_OK or MB_DEFBUTTON1 or 0);
    end;
  end;}
end;

procedure THistoryFrm.ReplyQuoted(Item: Integer);
var
  Txt: WideString;
begin
  if (hContact = 0) or (hg.SelCount = 0) then exit;
  Txt := QuoteText(hg.FormatSelected(hg.Options.ClipCopyFormat));
  SendMessageTo(hContact,Txt);
end;

var
  HtmlFilter: String = 'HTML file (*.html; *.htm)|*.html;*.htm';
  XmlFilter: String = 'XML file (*.xml)|*.xml';
  RtfFilter: String = 'RTF file (*.rtf)|*.rtf';
  UnicodeFilter: String = 'Unicode text file (*.txt)|*.txt';
  TextFilter: String = 'Text file (*.txt)|*.txt';
  AllFilter: String = 'All files (*.*)|*.*';
  HtmlDef: String = '.html';
  XmlDef: String = '.xml';
  RtfDef: String = '.rtf';
  TextDef: String = '.txt';

procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);
begin
  if AllFormats then begin
    SaveDialog.Filter := HtmlFilter+'|'+XmlFilter+'|'+RtfFilter+'|'+UnicodeFilter+'|'+TextFilter+'|'+AllFilter;
    case SaveFormat of
      sfHTML: SaveDialog.FilterIndex := 1;
      sfXML: SaveDialog.FilterIndex := 2;
      sfRTF: SaveDialog.FilterIndex := 3;
      sfUnicode: SaveDialog.FilterIndex := 4;
      sfText: SaveDialog.FilterIndex := 5;
    end;
  end else begin
    case SaveFormat of
      sfHTML: begin SaveDialog.Filter := HtmlFilter; SaveDialog.FilterIndex := 1; end;
      sfXML:  begin SaveDialog.Filter := XmlFilter; SaveDialog.FilterIndex := 1; end;
      sfRTF:  begin SaveDialog.Filter := RtfFilter; SaveDialog.FilterIndex := 1; end;
      sfUnicode: begin SaveDialog.Filter := UnicodeFilter+'|'+TextFilter; SaveDialog.FilterIndex := 1; end;
      sfText: begin SaveDialog.Filter := UnicodeFilter+'|'+TextFilter; SaveDialog.FilterIndex := 2; end;
    end;
    SaveDialog.Filter := SaveDialog.Filter + '|' + AllFilter;
  end;
  case SaveFormat of
    sfHTML: SaveDialog.DefaultExt := HtmlDef;
    sfXML: SaveDialog.DefaultExt := XmlDef;
    sfRTF: SaveDialog.DefaultExt := RtfDef;
    sfUnicode: SaveDialog.DefaultExt := TextDef;
    sfText: SaveDialog.DefaultExt := TextDef;
  end;
end;

procedure THistoryFrm.SaveasXML2Click(Sender: TObject);
var
  t: String;
begin
  PrepareSaveDialog(SaveDialog,sfXML);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  t := t + SaveDialog.DefaultExt;
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  hg.SaveAll(SaveDialog.Files[0],sfXML);
  RecentFormat := sfXML;
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.SaveasText2Click(Sender: TObject);
var
  t: String;
  SaveFormat: TSaveFormat;
begin
  if hppOSUnicode then SaveFormat := sfUnicode
                  else SaveFormat := sfText;
  PrepareSaveDialog(SaveDialog,SaveFormat);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  t := t + SaveDialog.DefaultExt;
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  case SaveDialog.FilterIndex of
    1: SaveFormat := sfUnicode;
    2: SaveFormat := sfText;
  end;
  RecentFormat := SaveFormat;
  hg.SaveAll(SaveDialog.Files[0],SaveFormat);
  //hg.SaveAll(SaveDialog.FileName,SaveFormat);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.hgXMLData(Sender: TObject; Index: Integer; var Item: TXMLItem);
var
//n: Integer;
  tmp1,tmp2: WideString;
  time,date: string;
  DTime,DDate: TDateTime;
  strdatetime:array [0..64] of Char;
  dbtts:TDBTimeToString;
begin
  dbtts.cbDest:=sizeof(strdatetime);
  dbtts.szDest:=@strdatetime;
  dbtts.szFormat:='s';
  PluginLink.CallService(MS_DB_TIME_TIMESTAMPTOSTRING,hg.Items[Index].Time,Integer(@dbtts));
  time := string(strdatetime);
  dbtts.szFormat:='d';
  PluginLink.CallService(MS_DB_TIME_TIMESTAMPTOSTRING,hg.Items[Index].Time,Integer(@dbtts));
  date := string(strdatetime);

  DTime := 0;
  DDate := 0;

  try
    DTime := StrToTime(time);
  except
    Item.Time := '&UNK;';
  end;

  try
    DDate := StrToDate(date);
  except
    Item.Date := '&UNK;';
  end;

  if Item.Time = '' then
    Item.Time := MakeTextXMLed(FormatDateTime('hh:mm:ss',DTime));
  if Item.Date = '' then
    Item.Date := MakeTextXMLed(FormatDateTime('yyyy-mm-dd',DDate));

  Item.Contact := UTF8Encode(MakeTextXMLedW(hg.ContactName));
  if mtIncoming in hg.Items[Index].MessageType then
    Item.From := Item.Contact
  else
    Item.From := '&ME;';

  if mtFile in hg.Items[Index].MessageType then
    Item.EventType := '&FILE;'
  else if mtUrl in hg.Items[Index].MessageType then
    Item.EventType := '&URL;'
{  else if mtAuthRequest in hg.Items[Index].MessageType then
    Item.EventType := '&AUT;'
  else if mtAdded in hg.Items[Index].MessageType then
    Item.EventType := '&ADD;'}
  else if mtSystem in hg.Items[Index].MessageType then
    Item.EventType := '&SYS;'
  else if mtSMS in hg.Items[Index].MessageType then
    Item.EventType := '&SMS;'
  else if mtWebPager in hg.Items[Index].MessageType then
    Item.EventType := '&EEX;'
  else
    Item.EventType := '&MSG;';

  if mtFile in hg.Items[Index].MessageType then begin
    ParseFileItem(hg.Items[Index],tmp1,tmp2);
    Item.Mes := UTF8Encode(tmp2);
    if tmp1 = '' then
      tmp1 := '&UNK;';
    Item.FileName := UTF8Encode(tmp1);
  end else if mtUrl in hg.Items[Index].MessageType then begin
    ParseUrlItem(hg.Items[Index],tmp1,tmp2);
    Item.Mes := UTF8Encode(tmp2);
    if tmp1 = '' then
      tmp1 := '&UNK;';
    Item.Url := UTF8Encode(tmp1);
  end else begin
    if hg.Options.BBCodesEnabled then
      Item.Mes := UTF8Encode(MakeTextXMLedW(DoStripBBCodes(hg.Items[Index].Text)))
    else
      Item.Mes := UTF8Encode(MakeTextXMLedW(hg.Items[Index].Text));
  end;

  {2.8.2004 OXY: Change protocol guessing order. Now
  first use protocol name, then, if missing, use module }

  Item.Protocol := hg.Items[Index].Proto;
  if Item.Protocol = '' then
    Item.Protocol := hg.Items[Index].Module;

  if mtIncoming in hg.Items[Index].MessageType then
    Item.ID := GetContactID(hContact, Protocol, true)
  else
    Item.ID := GetContactID(0, Protocol);

  if Item.Protocol = '' then
    Item.Protocol := '&UNK;'
  else
    Item.Protocol := MakeTextXMLed(Item.Protocol);

  if Item.ID = '' then
    Item.ID := '&UNK;'
  else
    Item.ID := MakeTextXMLed(Item.ID);
end;

procedure THistoryFrm.OpenFile1Click(Sender: TObject);
var
  FileName: string;
begin
  //FileName := GetItemFile(hg.Items[hg.Selected],hContact);
  //ShellExecute(0,nil,PChar(FileName),nil,PChar(ExtractFileDir(FileName)),SW_SHOWDEFAULT);
end;

procedure THistoryFrm.OpenFileFolder1Click(Sender: TObject);
var
  FileName: string;
begin
//  FileName := GetItemFile(hg.Items[hg.Selected],hContact);
//  FileName := ExtractFileDir(FileName);
//  ShellExecute(0,nil,PChar(FileName),nil,PChar(FileName),SW_SHOWDEFAULT);
end;

procedure THistoryFrm.OpenLink1Click(Sender: TObject);
var
  bNewWindow: Integer;
begin
  //if LinkUrl1.Caption = '' then exit;
  if SavedLinkUrl = '' then exit;
  bNewWindow := 0; // no, use existing window
  PluginLink.CallService(MS_UTILS_OPENURL,bNewWindow,Integer(Pointer(@SavedLinkUrl[1])));
end;

procedure THistoryFrm.OpenLinkInNewWindow1Click(Sender: TObject);
var
  bNewWindow: Integer;
begin
  //if LinkUrl1.Caption = '' then exit;
  if SavedLinkUrl = '' then exit;
  bNewWindow := 1; // use new window
  PluginLink.CallService(MS_UTILS_OPENURL,bNewWindow,Integer(Pointer(@SavedLinkUrl[1])));
end;

procedure THistoryFrm.CopyLink1Click(Sender: TObject);
begin
  //if LinkUrl1.Caption = '' then exit;
  if SavedLinkUrl = '' then exit;
  CopyToClip(AnsiToWideString(SavedLinkUrl,CP_ACP),Handle,CP_ACP);
end;

// no file operations
{procedure THistoryFrm.OpenFile2Click(Sender: TObject);
begin
ShellExecute(0,nil,PChar(FileLink1.Caption),nil,PChar(ExtractFileDir(FileLink1.Caption)),SW_SHOWDEFAULT);
end;}

// no file operations
{procedure THistoryFrm.OpenFileFolder2Click(Sender: TObject);
var
tmp1: String;
begin
tmp1 := ExtractFileDir(FileLink1.Caption);
ShellExecute(0,nil,PChar(tmp1),nil,PChar(tmp1),SW_SHOWDEFAULT);
end;}

{procedure THistoryFrm.CopyFile1Click(Sender: TObject);
begin
  if FileLink2.Caption = '' then exit;
  CopyToClip(FileLink2.Caption,Handle);
end;}

{procedure THistoryFrm.OpenOptions;
begin
  if not Assigned(OptionsFm) then begin
    OptionsFm := TfmOptions.Create(nil);
    TfmOptions(OptionsFm).DateGrid.ProfileName := hg.ProfileName;
    TfmOptions(OptionsFm).Load;
  end;
  OptionsFm.Show;
end;}

{procedure THistoryFrm.Options1Click(Sender: TObject);
begin
OpenOptions;
end;}

procedure THistoryFrm.SetPasswordMode(const Value: Boolean);
var
enb: Boolean;
begin
FPasswordMode := Value;
enb := not Value;
hgState(hg,hg.State);
hg.Enabled := enb;
hg.Visible := enb;
paClient.Enabled := enb;
paClient.Visible := enb;

if Value then paPassHolder.Align := alClient;
paPassHolder.Enabled := not enb;
paPassHolder.Visible := not enb;
if value = true then begin
  paPassword.Left := (paPassHolder.ClientWidth-paPassword.Width) div 2;
  paPassword.Top := (paPassHolder.ClientHeight - paPassword.Height) div 2;
  if Self.Visible then
    edPass.SetFocus
  else
    Self.ActiveControl := edPass;
  end
else begin
  hg.MakeVisible(hg.Selected);
  if Self.Visible then
    hg.SetFocus
  else
    Self.ActiveControl := hg;
  end;
end;

procedure THistoryFrm.SetRecentEventsPosition(OnTop: Boolean);
begin
  hg.Reversed := not OnTop;
  LoadButtonIcons;
end;

procedure THistoryFrm.EventsFilterItemClick(Sender: TObject);
begin
  //tbEventsFilter.Caption := TTntMenuItem(Sender).Caption;
  SetEventFilter(TTntMenuItem(Sender).Tag);
end;

procedure THistoryFrm.ShowAllEvents;
begin
  // TODO
  // we run UpdateFilter two times here, one when set
  // Filter property in SetEventFilter, one when reset hot filter
  // make Begin/EndUpdate support batch UpdateFilter requests
  // so we can make it run only one time on EndUpdate
  SetEventFilter(0);
  edSearch.Text := '';
  EndHotFilterTimer;
end;

procedure THistoryFrm.ShowSessions(Show: Boolean);
var
  Lock: Boolean;
begin
  if (hContact = 0) or (HistoryLength = 0) then Show := False;
  tbSessions.Down := Show;
  
  hg.BeginUpdate;
  if Visible then Lock := LockWindowUpdate(Handle);
  try
    paSess.Visible := Show;
    spSess.Visible := Show;
    spSess.Left := paSess.Left + paSess.Width + 1;
  finally
    if Visible and Lock then LockWindowUpdate(0);
    hg.EndUpdate;
  end;
end;

procedure THistoryFrm.SMFinished(var M: TMessage);
begin
  SessThread.Free;
  SessThread := nil;
end;

procedure THistoryFrm.bnPassClick(Sender: TObject);
begin
if DigToBase(HashString(edPass.Text)) = GetPassword then
  PasswordMode := False
else
  {DONE: sHure}
  hppMessageBox(Handle, TranslateWideW('You have entered the wrong password'),
  TranslateWideW('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
end;

procedure THistoryFrm.edPassKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
;
end;

procedure THistoryFrm.edSearchChange(Sender: TObject);
begin
  if FilterState then
    StartHotFilterTimer    
  else
    Search(True,False);
end;

procedure THistoryFrm.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FilterState then begin
    if Key in [VK_UP,VK_DOWN,VK_NEXT, VK_PRIOR] then begin
      SendMessage(hg.Handle,WM_KEYDOWN,Key,0);
      Key := 0;
    end;
  end else begin
    if (Shift = []) and (Key in [VK_UP,VK_DOWN,VK_NEXT, VK_PRIOR]) then begin
      SendMessage(hg.Handle,WM_KEYDOWN,Key,0);
      Key := 0;
      exit;
    end;
    if (Shift = [ssCtrl]) and (Key in [VK_UP,VK_DOWN]) then begin
      if hg.Reversed then begin
        if Key = VK_UP then
          sbSearchNext.Click
        else
          sbSearchPrev.Click;
      end else begin
        if Key = VK_UP then
          sbSearchPrev.Click
        else
          sbSearchNext.Click;
      end;
      Key := 0;
      exit;
    end;
  end;
end;

procedure THistoryFrm.edSearchKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    hg.SetFocus;
    key := 0;
  end;
end;

procedure THistoryFrm.edPassKeyPress(Sender: TObject; var Key: Char);
begin
// to prevent ** BLING ** when press Enter
if Key = Chr(VK_RETURN) then key := #0;
// to prevent ** BLING ** when press Tab
if Key = Chr(VK_TAB) then key := #0;
// to prevent ** BLING ** when press Esc
if Key = Chr(VK_ESCAPE) then key := #0;
end;

procedure THistoryFrm.PostLoadHistory;
begin
  ProcessPassword;
  //if hContact = 0 then paTop.Visible := False;
  // set reversed here, after Allocate, because of some scrollbar
  // "features", we'll load end of the list if put before Allocate
  SetRecentEventsPosition(GetDBInt(hppDBName,'SortOrder',0) <> 0);
  // set ShowSessions here because we check for empty history
  ShowSessions(GetDBBool(hppDBName,'ShowSessions',False));
  paSess.Width := GetDBInt(hppDBName,'SessionsWidth',150);
  
  HookEvents;
  ChangeSearchMode(False);
  CreateEventsFilterMenu;
  SetEventFilter(0);
end;

procedure THistoryFrm.PreLoadHistory;
begin
  LoadPosition;
  hg.ShowHeaders := (hContact <> 0);
  hg.ExpandHeaders := GetDBBool(hppDBName,'ExpandHeaders',True);
  if hContact = 0 then begin
    tbUserDetails.Enabled := False;
    tbUserMenu.Enabled := False;
    tbEventsFilter.Enabled := False;
    tbSessions.Enabled := False;
  end;

  SessThread := TSessionsThread.Create(True);
  SessThread.ParentHandle := Self.Handle;
  SessThread.Contact := hContact;
  SessThread.Priority := tpLower;
  SessThread.Resume;
end;

procedure THistoryFrm.ProcessPassword;
begin
  if IsPasswordBlank(GetPassword) then exit;
  if IsUserProtected(hContact) then
    PasswordMode := True;
end;

procedure THistoryFrm.OpenPassword;
begin
  RunPassForm;
end;

procedure THistoryFrm.TntFormShow(Sender: TObject);
begin
  // EndUpdate is better here, not in PostHistoryLoad, because it's faster
  // when called from OnShow. Don't know why.
  // Other form-modifying routines are better be kept at PostHistoryLoad for
  // speed too.
  hg.EndUpdate;
end;

procedure THistoryFrm.paPassHolderResize(Sender: TObject);
begin
  if PasswordMode = true then begin
    paPassword.Left := (ClientWidth-paPassword.Width) div 2;
    paPassword.Top := (ClientHeight - paPassword.Height) div 2;
  end;
end;

procedure THistoryFrm.Passwordprotection1Click(Sender: TObject);
begin
  OpenPassword;
end;

procedure THistoryFrm.TranslateForm;
var
  i: integer;

  procedure TranslateMenu(mi: TMenuItem);
  var
    i: integer;
  begin
    for i := 0 to mi.Count-1 do
      if mi.Items[i].Caption <> '-' then begin
        TTntMenuItem(mi.Items[i]).Caption := TranslateWideW(mi.Items[i].Caption{TRANSLATE-IGNORE});
          if mi.Items[i].Count > 0 then TranslateMenu(mi.Items[i]);
      end;
  end;

  procedure TranslateToolbar(const tb: TTntToolBar);
  var
    i: integer;
  begin
    for i := 0 to tb.ButtonCount-1 do
      if tb.Buttons[i].Style <> tbsSeparator then
        TTntToolBar(tb.Buttons[i]).Hint := TranslateWideW(tb.Buttons[i].Hint{TRANSLATE-IGNORE});
  end;

begin
  Caption := TranslateWideW(Caption);

  hg.TxtFullLog := TranslateWideW(hg.txtFullLog);
  hg.TxtGenHist1 := TranslateWideW(hg.txtGenHist1);
  hg.TxtGenHist2 := TranslateWideW(hg.txtGenHist2);
  hg.TxtHistExport := TranslateWideW(hg.TxtHistExport);
  hg.TxtNoItems := TranslateWideW(hg.TxtNoItems);
  hg.TxtNoSuch := TranslateWideW(hg.TxtNoSuch);
  hg.TxtPartLog := TranslateWideW(hg.TxtPartLog);
  hg.txtStartUp := TranslateWideW(hg.txtStartUp);

  SearchUpHint := TranslateWideW(SearchUpHint);
  SearchDownHint := TranslateWideW(SearchDownHint);

  sbClearFilter.Hint := TranslateWideW(sbClearFilter.Hint);

  bnPass.Caption := TranslateWideW(bnPass.Caption);
  laPass.Caption := TranslateWideW(laPass.Caption);
  laPass2.Caption := TranslateWideW(laPass2.Caption);
  laSess.Caption := TranslateWideW(laSess.Caption);

  SaveDialog.Title := Translate(PAnsiChar(SaveDialog.Title));

  TranslateToolbar(Toolbar);

  TranslateMenu(pmHistory.Items);
  TranslateMenu(pmGrid.Items);
  TranslateMenu(pmGridInline.Items);
  TranslateMenu(pmLink.Items);
  TranslateMenu(pmFile.Items);
  TranslateMenu(pmSessions.Items);

  HtmlFilter := Translate(PChar(HtmlFilter));
  XmlFilter := Translate(PChar(XmlFilter));
  RtfFilter := Translate(PChar(RtfFilter));
  UnicodeFilter := Translate(PChar(UnicodeFilter));
  TextFilter := Translate(PChar(TextFilter));
  AllFilter := Translate(PChar(AllFilter));
end;

procedure THistoryFrm.tvSessChange(Sender: TObject; Node: TTreeNode);
var
  Index,i: Integer;
  Event: THandle;
begin
  if SessThread <> nil then exit;
  if Node = nil then exit;
  if Node.Level <> 2 then begin
    Node := Node.getFirstChild;
    if (Node <> nil) and (Node.Level <> 2) then
      Node := Node.getFirstChild;
    if Node = nil then exit;
  end;

  Event := Sessions[DWord(Node.Data)].hDBEventFirst;
  Index := -1;
  // looks like history starts to load from end?
  // well, of course, we load from the last event!
  for i := Length(History) - 1 downto 0 do begin
    if History[i] = 0 then
      LoadPendingHeaders(i,HistoryLength);
    if History[i] = Event then begin
      Index := i;
      break;
    end;
  end;
  if Index = -1 then exit;
  if hg.State = gsInline then hg.CancelInline;
  Index := HistoryIndexToGrid(Index);
  hg.MakeTopmost(Index);
  hg.Selected := Index;
  //exit;
  // OXY: try to make selected item the topmost
  //while hg.GetFirstVisible <> Index do begin
  //  if hg.VertScrollBar.Position = hg.VertScrollBar.Range then break;
  //  hg.VertScrollBar.Position := hg.VertScrollBar.Position + 1;
  //end;

  {if Node = nil then begin
    StartTimestamp := 0;
    EndTimestamp := 0;
    hg.UpdateFilter;
    exit;
  end;

  if Node.Level <> 2 then exit;

  StartTimestamp := Sessions[DWord(Node.Data)][1];
  EndTimestamp := 0;
  if DWord(Node.Data) <= Length(Sessions)-2 then begin
    EndTimestamp := Sessions[DWord(Node.Data)+1][1];
  end;
  hg.UpdateFilter;}
end;

{procedure THistoryFrm.tvSessClick(Sender: TObject);
var
  Node: TTntTreeNode;
begin
  Node := tvSess.Selected;
  if Node = nil then exit;
  //tvSessChange(Self,Node);
end;}

procedure THistoryFrm.tvSessMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Node: TTntTreeNode;
  count,time: DWord;
  t: WideString;
  dt: TDateTime;
  timestr: WideString;
begin
  Node := tvSess.GetNodeAt(x,y);
  if (Node = nil) or (Node.Level <> 2) then begin
    Application.CancelHint;
    tvSess.ShowHint := False;
    exit;
  end;
  if tvSess.Tag <> Integer(Node.Data)+1 then begin
    Application.CancelHint;
    tvSess.ShowHint := False;
    tvSess.Tag := Integer(Node.Data)+1; // +1 because we have tag = 0 by default, and it will not catch first session then
    end;
  //else
  //  exit; // we are already showing the hint for this node

  time := Sessions[DWord(Node.Data)].TimestampLast - Sessions[DWord(Node.Data)].TimestampFirst;
  count := Sessions[DWord(Node.Data)].ItemsCount;

  dt := TimestampToDateTime(Sessions[DWord(Node.Data)].TimestampFirst);
  t := AnsiToWideString(FormatDateTime('[yyyy, mmmm, d]',dt),CP_ACP)+#13#10;
  if time/60 > 60 then
    timestr := WideFormat('%0.1n h',[time/(60*60)])
  else
    timestr := WideFormat('%d min',[time div 60]);

  if count = 1 then
    tvSess.Hint := t + WideFormat(
      ''+TranslateWideW('%d event'),[count])
  else
    tvSess.Hint := t + WideFormat(
      ''+TranslateWideW('%0.n events (%s)'),[count/1,timestr]);
  tvSess.ShowHint := True;
end;

procedure THistoryFrm.CopyText1Click(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  CopyToClip(hg.FormatSelected(hg.Options.ClipCopyTextFormat),Handle,UserCodePage);
  // rtf copy works only if not more then one selected
  //hg.ApplyItemToRich(hg.Selected,hg.RichEdit,False);
  //hg.RichEdit.SelectAll;
  //hg.RichEdit.CopyToClipboard;
end;

procedure THistoryFrm.CreateEventsFilterMenu;
var
  i: Integer;
  mi: TTntMenuItem;
begin
  for i := pmEventsFilter.Items.Count - 1 downto 0 do
    if pmEventsFilter.Items[i].RadioItem then
      pmEventsFilter.Items.Delete(i);

  for i := 0 to Length(hppEventFilters) - 1 do begin
    mi := TTntMenuItem.Create(pmEventsFilter);
    mi.Caption := Tnt_WideStringReplace(TranslateWideW(hppEventFilters[i].Name),'&','&&',[rfReplaceAll]{TRANSLATE-IGNORE});
    mi.GroupIndex := 1;
    mi.RadioItem := True;
    mi.Tag := i;
    mi.OnClick := EventsFilterItemClick;
    if i = 0 then mi.Default := True;
    pmEventsFilter.Items.Insert(i,mi);
  end;
end;

procedure THistoryFrm.hgUrlClick(Sender: TObject; Item: Integer; Url: String);
var
  bNewWindow: Integer;
begin
  // if LinkUrl1.Caption = '' then exit;
  bNewWindow := 0; // no, use existing window
  PluginLink.CallService(MS_UTILS_OPENURL,bNewWindow,Integer(Pointer(Url)));
end;

procedure THistoryFrm.hgUrlPopup(Sender: TObject; Item: Integer; Url: String);
begin
  //LinkUrl1.Caption := AnsiToWideString(Url,CP_ACP);
  SavedLinkUrl := Url;
  pmLink.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
end;

procedure THistoryFrm.hgProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
var
  ItemRenderDetails: TItemRenderDetails;
begin
  ZeroMemory(@ItemRenderDetails,SizeOf(ItemRenderDetails));
  ItemRenderDetails.cbSize := SizeOf(ItemRenderDetails);
  ItemRenderDetails.hContact := hContact;
  ItemRenderDetails.hDBEvent := History[GridIndexToHistory(Item)];
  //ItemRenderDetails.pProto := @hg.Items[Item].Proto[1];
  ItemRenderDetails.pProto := PChar(hg.Items[Item].Proto);
  //ItemRenderDetails.pModule := @hg.Items[Item].Module[1];
  ItemRenderDetails.pModule := PChar(hg.Items[Item].Module);
  ItemRenderDetails.dwEventTime := hg.Items[Item].Time;
  //ItemRenderDetails.wEventType := MessageTypeToEventType(hg.Items[Item].MessageType);
  ItemRenderDetails.wEventType := hg.Items[Item].EventType;
  ItemRenderDetails.IsEventSent := (mtOutgoing in hg.Items[Item].MessageType);
  if Handle = hg.InlineRichEdit.Handle then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_INLINE;
  if hg.IsSelected(Item) then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_SELECTED;
  if hContact = 0 then
    ItemRenderDetails.bHistoryWindow := IRDHW_GLOBALHISTORY
  else
    ItemRenderDetails.bHistoryWindow := IRDHW_CONTACTHISTORY;

  PluginLink.NotifyEventHooks(hHppRichEditItemProcess,Handle,Integer(@ItemRenderDetails));
end;

procedure THistoryFrm.hgSearchItem(Sender: TObject; Item, ID: Integer; var Found: Boolean);
begin
  Found := (ID = History[GridIndexToHistory(Item)]);
end;

procedure THistoryFrm.hgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // this workaround was done because when we have password and
  // press enter, if password is ok, we a brought to the
  // history grid, and have VK_RETURN onkeyup event. So we have
  // this var to help us. And no, if move this code to OnKeyDown,
  // we will have problems with inline richedit not appearing
  // on enter
  if not WasReturnPressed then exit;

  if (Key = VK_RETURN) and (Shift = []) then begin
    hgDblClick(hg);
    //Details1.Click;
    end;
  if (Key = VK_RETURN) and (Shift = [ssCtrl]) then begin
    Details1.Click;
    end;
end;

procedure THistoryFrm.LoadInOptions();
var
  i: integer;
begin
  if hContact = 0 then begin
    ContactRTLmode1.Visible := False;
    ANSICodepage1.Visible := False;
  end else begin
    case hg.RTLMode of
      hppRTLDefault: Self.RTLDefault2.Checked := true;
      hppRTLEnable: Self.RTLEnabled2.Checked := true;
      hppRTLDisable: Self.RTLDisabled2.Checked := true;
    end;
    if UseDefaultCP then
      SystemCodepage1.Checked := true
    else
      for i := 0 to ANSICodepage1.Count-1 do
        if ANSICodepage1.Items[i].Tag = Integer(UserCodepage) then begin
          ANSICodepage1.Items[i].Checked := true;
          break;
        end;
  end;
end;

procedure THistoryFrm.SetEventFilter(FilterIndex: Integer = -1);
var
  name: WideString;
  i,fi: Integer;
begin
  if FilterIndex = -1 then begin
    fi := tbEventsFilter.Tag+1;
    if fi > High(hppEventFilters) then fi := 0;
  end else
    fi := FilterIndex;
  name := TranslateWideW(hppEventFilters[fi].Name{TRANSLATE-IGNORE});
  name := Tnt_WideStringReplace(name,'&','&&',[rfReplaceAll]);
  tbEventsFilter.Caption := name;
  tbEventsFilter.Tag := fi;
  for i := 0 to pmEventsFilter.Items.Count-1 do
    if pmEventsFilter.Items[i].RadioItem then
      pmEventsFilter.Items[i].Checked := (pmEventsFilter.Items[i].Tag = fi);
  hg.Filter := hppEventFilters[fi].Events;
end;

procedure THistoryFrm.SethContact(const Value: THandle);
var
  i: integer;
begin
  FhContact := Value;
  {i := DBGetContactSettingByte(hContact,hppDBName,'RTL',255);
  case i of
    0: hg.RTLMode := hppRTLDisable;
    1: hg.RTLMode := hppRTLEnable;
    else
       hg.RTLMode := hppRTLDefault;
  end;
  if Value = 0 then
    UserCodepage := hppCodepage
  else
    UserCodepage := DBGetContactSettingWord(hContact,hppDBName,'CodePage',CP_ACP);}
end;

{procedure THistoryFrm.AddMenu(M: TMenuItem; FromM,ToM: TPopupMenu; Index: integer);
//var
//  i: integer;
//  mi: TMenuItem;
begin
  if ToM.FindItem(M.Handle,fkHandle) = nil then begin
    if FromM.FindItem(M.Handle,fkHandle) <> nil then
      FromM.Items.Remove(M);
    if Index = -1 then ToM.Items.Add(M)
                  else ToM.Items.Insert(Index,M);
  end;
end;}

procedure THistoryFrm.AddMenuArray(Menu: TTntPopupMenu; List: Array of TTntMenuItem; Index: integer);
var
  i: integer;
begin
  for i := 0 to High(List) do begin
    if List[i].Parent <> nil then begin
      if List[i].GetParentMenu = Menu then continue;
      List[i].Parent.Remove(List[i]);
    end;
    if Index = -1 then Menu.Items.Add(List[i])
                  else Menu.Items.Insert(Index+i,List[i]);
  end;
end;

// fix for infamous splitter bug!
// thanks to Greg Chapman
// http://groups.google.com/group/borland.public.delphi.objectpascal/browse_thread/thread/218a7511123851c3/5ada76e08038a75b%235ada76e08038a75b?sa=X&oi=groupsr&start=2&num=3
procedure THistoryFrm.AlignControls(Control: TControl; var ARect: TRect);
begin
  inherited;
  if paSess.Width = 0 then
    paSess.Left := spSess.Left;
end;

procedure THistoryFrm.ContactRTLmode1Click(Sender: TObject);
begin
  if RTLDefault2.Checked then
    hg.RTLMode := hppRTLDefault
  else begin
    if RTLEnabled2.Checked then hg.RTLMode := hppRTLEnable
                           else hg.RTLMode := hppRTLDisable;
  end;
  WriteContactRTLMode(hContact,hg.RTLMode,Protocol);
end;

procedure THistoryFrm.SMItemsFound(var M: TMessage);
var
  ti: TtntTreeNode;
  i: Integer;
  dt: TDateTime;
  ts: DWord;
  PrevYear,PrevMonth: Integer;
  PrevYearNode, PrevMonthNode: TtntTreeNode;
begin
{$RANGECHECKS OFF}
  // wParam - array of hDBEvent, lParam - array size
  PrevYearNode := nil;
  PrevMonthNode := nil;
  Sessions := PSessArray(m.WParam)^;
  FreeMem(PSessArray(m.WParam));
  tvSess.Items.BeginUpdate;
  try
    for i := 0 to Length(Sessions) - 1 do begin
      ts := Sessions[i].TimestampFirst;
      dt := TimestampToDateTime(ts);
      if (PrevYearNode = nil) or (DWord(PrevYearNode.Data) <> YearOf(dt)) then begin
        PrevYearNode := tvSess.Items.AddChild(nil,FormatDateTime(HPP_SESS_YEARFORMAT,dt));
        PrevYearNode.Data := Pointer(YearOf(dt));
        PrevYearNode.ImageIndex := 5;
        //PrevYearNode.SelectedIndex := PrevYearNode.ImageIndex;
        PrevMonthNode := nil;
      end;
      if (PrevMonthNode = nil) or (DWord(PrevMonthNode.Data) <> MonthOf(dt)) then begin
        PrevMonthNode := tvSess.Items.AddChild(PrevYearNode,FormatDateTime(HPP_SESS_MONTHFORMAT,dt));
        PrevMonthNode.Data := Pointer(MonthOf(dt));
        case MonthOf(dt) of
          12,1..2: PrevMonthNode.ImageIndex := 3;
          3..5: PrevMonthNode.ImageIndex := 4;
          6..8: PrevMonthNode.ImageIndex := 1;
          9..11: PrevMonthNode.ImageIndex := 2;
        end;
        //PrevMonthNode.SelectedIndex := PrevMonthNode.ImageIndex;
      end;
      ti := tvSess.Items.AddChild(PrevMonthNode,FormatDateTime(HPP_SESS_DAYFORMAT,dt));
      ti.Data := Pointer(i);
      ti.ImageIndex := 0;
      //ti.SelectedIndex := ti.ImageIndex;
    end;
    if PrevYearNode <> nil then begin
      PrevYearNode.Expand(False);
      PrevMonthNode.Expand(True);
    end;
    if ti <> nil then
      ti.Selected := True;
  finally
    tvSess.Items.EndUpdate;
  end;
{$RANGECHECKS ON}
end;

procedure THistoryFrm.pmGridInlinePopup(Sender: TObject);
begin
   CopyInline.Enabled := (hg.InlineRichEdit.SelLength > 0);
end;

procedure THistoryFrm.CopyInlineClick(Sender: TObject);
begin
  //CopyToClip(hg.InlineRichEdit.SelText,Handle,UserCodepage);
  hg.InlineRichEdit.CopyToClipboard;
end;


procedure THistoryFrm.CopyAllInlineClick(Sender: TObject);
var
  ss,sl: integer;
begin
  //CopyToClip(hg.InlineRichEdit.Text,Handle,UserCodepage);
  hg.InlineRichEdit.Lines.BeginUpdate;
  ss := hg.InlineRichEdit.SelStart;
  sl := hg.InlineRichEdit.SelLength;
  hg.InlineRichEdit.SelectAll;
  hg.InlineRichEdit.CopyToClipboard;
  hg.InlineRichEdit.SelStart := ss;
  hg.InlineRichEdit.SelLength := sl;
  hg.InlineRichEdit.Lines.EndUpdate;
end;

procedure THistoryFrm.SelectAllInlineClick(Sender: TObject);
begin
  hg.InlineRichEdit.SelectAll;
end;

procedure THistoryFrm.CancelInline1Click(Sender: TObject);
begin
  hg.CancelInline;
end;

procedure THistoryFrm.SendMessage1Click(Sender: TObject);
begin
  if hContact <> 0 then SendMessageTo(hContact);
end;

procedure THistoryFrm.ReplyQuoted1Click(Sender: TObject);
begin
  if hContact = 0 then exit;
  if hg.Selected <> -1 then
    ReplyQuoted(hg.Selected);
end;

procedure THistoryFrm.UserDetails1Click(Sender: TObject);
begin
  if hContact = 0 then exit;
  PluginLink.CallService(MS_USERINFO_SHOWDIALOG,hContact,0);
end;

procedure THistoryFrm.ChangeSearchMode(Filter: Boolean);
var
  SaveStr: WideString;
  NotFound,Lock: Boolean;
begin
  SaveStr := edSearch.Text;
  tbFilter.Down := Filter;
  tbSearch.Down := not Filter;
  hg.BeginUpdate;
  if Visible then Lock := LockWindowUpdate(Handle);
  try
    pbSearch.Visible := not Filter;
    pbFilter.Visible := Filter;
    if Filter then paSearchStatus.Visible := False;
    paSearchButtons.Visible := not Filter;
    NotFound := not (edSearch.Color = clWindow);
    edSearch.Text := '';
    if FilterState then EndHotFilterTimer;
  finally
    hg.EndUpdate;
    if Visible and Lock then LockWindowUpdate(0);
  end;
  FilterState := Filter;

  // don't search or filter if the string is not found
  if not NotFound then
    edSearch.Text := SaveStr;

  if Self.Visible then
    edSearch.SetFocus;
end;

procedure THistoryFrm.CodepageChangeClick(Sender: TObject);
var
  val: Cardinal;
begin
  val := (Sender as TTntMenuItem).Tag;
  WriteContactCodePage(hContact,val,Protocol);
  //UserCodepage := val;
  UserCodepage := GetContactCodePage(hContact,Protocol,UseDefaultCP);
  hg.Codepage := UserCodepage;
end;

procedure THistoryFrm.sbClearFilterClick(Sender: TObject);
begin
  if FilterState then EndHotFilterTimer;
  edSearch.Text := '';
  hg.SetFocus;
end;

procedure THistoryFrm.pbFilterPaint(Sender: TObject);
var
  ic: hIcon;
begin
  if tiFilter.Enabled then
    ic := hppIcons[HPP_ICON_HOTFILTERWAIT].Handle
  else
    ic := hppIcons[HPP_ICON_HOTFILTER].Handle;

  DrawIconEx(pbFilter.Canvas.Handle,0,0,ic,
    16,16,0,pbFilter.Canvas.Brush.Handle,DI_NORMAL);
end;

procedure THistoryFrm.pbSearchPaint(Sender: TObject);
begin
  DrawIconEx(pbSearch.Canvas.Handle,0,0,hppIcons[HPP_ICON_HOTSEARCH].Handle,
    16,16,0,pbSearch.Canvas.Brush.Handle,DI_NORMAL);
end;

procedure THistoryFrm.pbSearchStatePaint(Sender: TObject);
begin
  {case laSearchState.Tag of
    1: DrawIconEx(pbSearchState.Canvas.Handle,0,0,hppIcons[HPP_ICON_HOTSEARCH].Handle,
       16,16,0,pbSearchState.Canvas.Brush.Handle,DI_NORMAL);
    2: DrawIconEx(pbSearchState.Canvas.Handle,0,0,hppIcons[HPP_ICON_HOTSEARCH].Handle,
       16,16,0,pbSearchState.Canvas.Brush.Handle,DI_NORMAL)
  else
    pbSearchState.Canvas.FillRect(pbSearchState.Canvas.ClipRect);
  end;}
end;

procedure THistoryFrm.StartHotFilterTimer;
var
  RepaintIcon: Boolean;
begin
  if tiFilter.Interval = 0 then
    EndHotFilterTimer
  else begin
    tiFilter.Enabled := False;
    tiFilter.Enabled := True;
    if pbFilter.Tag <> 1 then begin // use Tag to not repaint every keystroke
      pbFilter.Tag := 1;
      pbFilter.Repaint;
    end;
  end;
end;

procedure THistoryFrm.Emptyhistory1Click(Sender: TObject);
begin
  if HppMessageBox(Handle,
    WideFormat(TranslateWideW('Do you really want to delete ALL items (%.0f) for this contact?')+
    #10#13+''+#10#13+TranslateWideW('Note: It can take several minutes for large history.'),
    [hg.Count/1]), TranslateWideW('Empty History'), MB_YESNO or MB_DEFBUTTON2 or MB_ICONEXCLAMATION) = IDNO then exit;

  SetSafetyMode(False);
  try
    hg.DeleteAll;
  finally
    SetSafetyMode(True);
    end;
end;

procedure THistoryFrm.EndHotFilterTimer;
begin
  tiFilter.Enabled := False;
  HotFilterString := edSearch.Text;
  hg.UpdateFilter;
  if pbFilter.Tag <> 0 then begin
    pbFilter.Tag := 0;
    pbFilter.Repaint;
  end;
  if hg.Selected = -1 then
    edSearch.Color := $008080FF
  else
    edSearch.Color := clWindow;
end;

procedure THistoryFrm.tbDeleteClick(Sender: TObject);
begin
  Delete1.Click;
end;

procedure THistoryFrm.tbFilterClick(Sender: TObject);
begin
  ChangeSearchMode(tbFilter.Down);
end;

procedure THistoryFrm.tbHistoryClick(Sender: TObject);
{var
  t: String;
  SaveFormat: TSaveFormat;}
begin
  if hg.SelCount > 1 then
    Self.SaveSelected1Click(Self)
  else
    tbHistory.CheckMenuDropdown;
  {RecentFormat := TSaveFormat(GetDBInt(hppDBName,'ExportFormat',0));
  SaveFormat := RecentFormat;
  PrepareSaveDialog(SaveDialog,SaveFormat,True);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  case SaveDialog.FilterIndex of
    1: SaveFormat := sfHtml;
    2: SaveFormat := sfXml;
    3: SaveFormat := sfRTF;
    4: SaveFormat := sfUnicode;
    5: SaveFormat := sfText;
  end;
  RecentFormat := SaveFormat;
  hg.SaveAll(SaveDialog.Files[0],sfXML);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));}
end;

procedure THistoryFrm.tbSessionsClick(Sender: TObject);
begin
  ShowSessions(tbSessions.Down);
end;

procedure THistoryFrm.tiFilterTimer(Sender: TObject);
begin
  EndHotFilterTimer;
end;

procedure THistoryFrm.SaveasRTF2Click(Sender: TObject);
var
  t: String;
begin
  PrepareSaveDialog(SaveDialog,sfRTF);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  t := t + SaveDialog.DefaultExt;
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  hg.SaveAll(SaveDialog.Files[0],sfRTF);
  RecentFormat := sfRTF;
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.tbHistorySearchClick(Sender: TObject);
begin
  PluginLink.CallService(MS_HPP_SHOWGLOBALSEARCH,0,0);
end;

procedure THistoryFrm.tbEventsFilterClick(Sender: TObject);
begin
  tbEventsFilter.CheckMenuDropdown;
end;

procedure THistoryFrm.paSearchPanelResize(Sender: TObject);
begin
  //paSearchButtons.Left := paSearch.ClientWidth-paSearchButtons.Width;
  //paSearchStatus.Left := paSearchButtons.Left - paSearchStatus.Width;
end;

procedure THistoryFrm.SessSelectClick(Sender: TObject);
var
  Items: Array of integer;
  i: integer;

function BuildIndexesFromSession(const Node: TtntTreeNode): boolean;
var
  First,Last: THandle;
  fFirst,fLast: integer;
  a,b,i,cnt: integer;
begin
  Result := false;
  if Node = nil then exit;
  if Node.Level = 2 then begin
    First := Sessions[DWord(Node.Data)].hDBEventFirst;
    Last:= Sessions[DWord(Node.Data)].hDBEventLast;
    fFirst := -1;
    fLast := -1;
    for i := Length(History) - 1 downto 0 do begin
      if History[i] = 0 then LoadPendingHeaders(i,HistoryLength);
      if History[i] = First then fFirst := i;
      if History[i] = Last then fLast := i;
      if (fLast>=0) and (fFirst>=0) then break;
    end;
    if (fLast>=0) and (fFirst>=0) then begin
      if fFirst > fLast then begin
        a:= fLast; b:= fFirst;
      end else begin
        a:= fFirst; b:= fLast;
      end;
      cnt := Length(Items);
      SetLength(Items,cnt+b-a+1);
      for i := b downto a do Items[cnt+b-i] := HistoryIndexToGrid(i);
      Result := True;
    end;
  end else
    for i := 0 to Node.Count-1 do
      Result := BuildIndexesFromSession(Node.Item[i]) or Result;
end;

begin
  if SessThread <> nil then exit;
  BuildIndexesFromSession(tvSess.Selected);
  //hg.MakeRangeSelected();
  for i := 0 to High(Items) do begin
    hg.SelItems[0] := Items[i];
    Application.ProcessMessages;
  end;
  hg.Invalidate;
  //w := w + hg.Items[i].Text+#13#10+'--------------'+#13#10;
  //CopyToClip(w,Handle,UserCodepage);
  SetLength(Items,0);
  //Index := HistoryIndexToGrid(Index);
  //hg.MakeTopmost(Index);
  //hg.Selected := Index;
  //exit;
  //Events := MakeSessionEvents();
end;

{procedure THistoryFrm.tvSessMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  exit;
  if (Button = mbRight) then begin
    Node := tvSess.GetNodeAt(X,Y);
    if Node <> nil then begin
      if not Node.Selected then
        tvSess.Select(Node);
      tvSessChange(tvSess,Node);
      if not Node.Focused then
        Node.Focused := True;
      tvSess.Invalidate;
    end;
  end;
end;}

procedure THistoryFrm.pmGridPopup(Sender: TObject);
begin
  Self.LoadInOptions();
  AddMenuArray(pmGrid,[ContactRTLmode1,ANSICodepage1],-1);
end;

procedure THistoryFrm.pmHistoryPopup(Sender: TObject);
begin
  Self.LoadInOptions();
  AddMenuArray(pmHistory,[ContactRTLmode1,ANSICodepage1],7);
end;

procedure THistoryFrm.WndProc(var Message: TMessage);
var
  res: integer;
begin
  inherited;
  case Message.Msg of
    WM_COMMAND: begin
      res := PluginLink.CallService(MS_CLIST_MENUPROCESSCOMMAND,MAKEWPARAM(Message.WParamLo,MPCF_CONTACTMENU),hContact);
      if  res <> 0 then Message.Result := res;
    end;
    WM_MEASUREITEM:
 	    Message.Result := PluginLink.CallService(MS_CLIST_MENUMEASUREITEM,Message.WParam,Message.LParam);
    WM_DRAWITEM:
   		Message.Result := PluginLink.CallService(MS_CLIST_MENUDRAWITEM,Message.WParam,Message.LParam);
  end;
end;

procedure THistoryFrm.tbUserMenuClick(Sender: TObject);
var
  p: TPoint;
  hm: hMenu;
begin
  hm := PluginLink.CallService(MS_CLIST_MENUBUILDCONTACT,hContact,0);
  if hm <> 0 then begin
    p.x := 0;
    p.y := tbUserMenu.Height;
    p := tbUserMenu.ClientToScreen(p);
    TrackPopupMenu(hm,TPM_LEFTALIGN + TPM_LEFTBUTTON,p.x,p.y,0,Handle,nil);
    DestroyMenu(hm);
  end;
end;

procedure THistoryFrm.tvSessGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  // and we don't need to set SelectedIndex manually anymore
  Node.SelectedIndex := Node.ImageIndex;
end;

end.
