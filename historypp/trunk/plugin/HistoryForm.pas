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
  ImgList, PasswordEditControl, TntStdCtrls, TntButtons, TntMenus;

const
  HM_EVENTADDED   = WM_APP + 100;
  HM_EVENTDELETED = WM_APP + 101;
  HM_PRESHUTDOWN  = WM_APP + 102;

type

  TLastSearch = (lsNone,lsHotSearch,lsSearch);

  THistoryFrm = class(TTntForm)
    FindDialog: TWFindDialog;
    SaveDialog: TSaveDialog;
    pmGrid: TTntPopupMenu;
    pmAdd: TTntPopupMenu;
    paClient: TPanel;
    paGrid: TPanel;
    hg: THistoryGrid;
    paTop: TPanel;
    laFilter: TTntLabel;
    cbFilter: TTntComboBox;
    paBottom: TPanel;
    paClose: TPanel;
    bnClose: TTntButton;
    bnSearch: TTntButton;
    bnDelete: TTntButton;
    bbAddit: TTntBitBtn;
    sb: TTntStatusBar;
    cbSort: TTntComboBox;
    pmLink: TTntPopupMenu;
    pmFile: TTntPopupMenu;
    paPassword: TPanel;
    paSess: TPanel;
    laPass: TTntLabel;
    Image1: TImage;
    laPass2: TTntLabel;
    edPass: TPasswordEdit;
    bnPass: TTntButton;
    pmOptions: TTntPopupMenu;
    RTLEnabled2: TMenuItem;
    RTLDisabled2: TMenuItem;
    RTLDefault2: TMenuItem;
    pmGridInline: TTntPopupMenu;
    SystemCodepage1: TMenuItem;
    tvSess: TTntTreeView;
    spSess: TTntSplitter;
    ilSessions: TImageList;
    Panel1: TPanel;
    laSess: TTntLabel;
    sbCloseSess: TTntSpeedButton;
    bnConversation: TTntButton;
    Setpassword1: TTntMenuItem;
    N6: TTntMenuItem;
    DeleteAll1: TTntMenuItem;
    N4: TTntMenuItem;
    SaveasText1: TTntMenuItem;
    SaveasXML1: TTntMenuItem;
    SaveasHTML1: TTntMenuItem;
    N7: TTntMenuItem;
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
    UnderlineURLs1: TTntMenuItem;
    FindURLs1: TTntMenuItem;
    N11: TTntMenuItem;
    RTLEnabled1: TTntMenuItem;
    N9: TTntMenuItem;
    MathModuleEnabled1: TTntMenuItem;
    BBCodesEnabled1: TTntMenuItem;
    SmileysEnabled1: TTntMenuItem;
    N3: TTntMenuItem;
    IconsEnabled1: TTntMenuItem;
    ContactRTLmode1: TTntMenuItem;
    ANSICodepage1: TTntMenuItem;
    Options1: TTntMenuItem;
    procedure tvSessMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tvSessClick(Sender: TObject);
    procedure sbCloseSessClick(Sender: TObject);
    procedure hgItemFilter(Sender: TObject; Index: Integer; var Show: Boolean);
    procedure tvSessChange(Sender: TObject; Node: TTreeNode);
    procedure bnConversationClick(Sender: TObject);

    procedure LoadHistory(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnCNChar(var Message: TWMChar); message WM_CHAR;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    //procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure hgItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
    procedure hgTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
    procedure hgPopup(Sender: TObject);
    procedure cbFilterChange(Sender: TObject);
    procedure hgSearchFinished(Sender: TObject; Text: WideString; Found: Boolean);
    procedure bnSearchClick(Sender: TObject);
    procedure hgDblClick(Sender: TObject);
    procedure SaveSelected1Click(Sender: TObject);
    procedure hgItemDelete(Sender: TObject; Index: Integer);
    procedure Delete1Click(Sender: TObject);
    procedure bnDeleteClick(Sender: TObject);
    procedure bbAdditClick(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Details1Click(Sender: TObject);
    procedure hgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure bnCloseClick(Sender: TObject);
    procedure hgState(Sender: TObject; State: TGridState);
    procedure DeleteAll1Click(Sender: TObject);
    procedure SaveasHTML1Click(Sender: TObject);
    procedure cbSortChange(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure hgSelect(Sender: TObject; Item, OldItem: Integer);
    procedure FindDialogClose(Sender: TObject);
    procedure SaveasXML1Click(Sender: TObject);
    procedure SaveasText1Click(Sender: TObject);
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
    procedure paGridResize(Sender: TObject);
    procedure edPassKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edPassKeyPress(Sender: TObject; var Key: Char);
    procedure Setpassword1Click(Sender: TObject);
    procedure CopyText1Click(Sender: TObject);
    procedure hgUrlClick(Sender: TObject; Item: Integer; Url: String);
    procedure hgUrlPopup(Sender: TObject; Item: Integer; Url: String);
    procedure hgProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
    procedure hgSearchItem(Sender: TObject; Item, ID: Integer; var Found: Boolean);
    procedure hgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    //procedure AddMenu(M: TMenuItem; FromM,ToM: TPopupMenu; Index: integer);
    procedure AddMenuArray(Menu: TPopupMenu; List: Array of TMenuItem; Index: integer);
    procedure pmPopup(Sender: TObject);
    procedure IconsEnabled1Click(Sender: TObject);
    procedure RTLEnabled1Click(Sender: TObject);
    procedure SmileysEnabled1Click(Sender: TObject);
    procedure MathModuleEnabled1Click(Sender: TObject);
    procedure UnderlineURLs1Click(Sender: TObject);
    procedure BBCodesEnabled1Click(Sender: TObject);
    procedure FindURLs1Click(Sender: TObject);
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
  private
    StartTimestamp: DWord;
    EndTimestamp: DWord;
    FhContact: THandle;
    hHookEventAdded,hHookEventDeleted,hHookEventPreShutdown: THandle;
    FPasswordMode: Boolean;
    SavedLinkUrl: String;
    ShowSessionsAfterPassword: Boolean;

    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);message WM_GetMinMaxInfo;
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

  public
    UserCodepage: Cardinal;
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
    procedure ApplyFilter(DoApply: boolean = true);
    procedure ReplyQuoted(Item: Integer);
    procedure OpenPassword;

    procedure SMItemsFound(var M: TMessage); message SM_ITEMSFOUND;
    procedure SMFinished(var M: TMessage); message SM_FINISHED;
    procedure ShowSessions(Show: Boolean);
  protected
    procedure LoadPendingHeaders(rowidx: integer; count: integer);
  published
    procedure AlignControls(Control: TControl; var ARect: TRect); override;
  public
    property PasswordMode: Boolean read FPasswordMode write SetPasswordMode;
    property hContact: THandle read FhContact write SethContact;
  end;

var
  HistoryFrm: THistoryFrm;

procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);
function ParseUrlItem(Item: THistoryItem; out Url,Mes: WideString): Boolean;
function ParseFileItem(Item: THistoryItem; out FileName,Mes: WideString): Boolean;
//function GetItemFile(Item: THistoryItem; hContact: THandle): string;
//function GetItemUrl(Item: THistoryItem): string;

implementation

uses EventDetailForm, PassForm, hpp_options, hpp_services;

{$R *.DFM}

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
Removes some glitches when copying non-latin
letters to clipboard on NT systems
*)
procedure CopyToClip(s: WideString; Handle: Hwnd; CodePage: Cardinal = CP_ACP);

function StrAllocW(Size: Cardinal): PWideChar;
begin
  Size := SizeOf(WideChar) * Size + SizeOf(Cardinal);
  GetMem(Result, Size);
  FillChar(Result^, Size, 0);
  Cardinal(Pointer(Result)^) := Size;
  Inc(Result, SizeOf(Cardinal) div SizeOf(WideChar));
end;

procedure StrDisposeW(Str: PWideChar);
begin
  if Str <> nil then
  begin
    Dec(Str, SizeOf(Cardinal) div SizeOf(WideChar));
    FreeMem(Str, Cardinal(Pointer(Str)^));
  end;
end;

var
  WData, AData, LData: THandle;
  LDataPtr: PCardinal;
  WDataPtr: PWideChar;
  ADataPtr: PAnsiChar;
  ASize,WSize: Integer;
  a: AnsiString;
begin
  ASize := Length(s)+1;
  WSize := ASize*2;
  OpenClipboard(Handle);
  try
    EmptyClipboard;
    WData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, WSize);
    AData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, ASize);
    LData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, SizeOf(Cardinal));
    try
      WDataPtr := GlobalLock(WData);
      ADataPtr := GlobalLock(AData);
      LDataPtr := GlobalLock(LData);
      a := WideToAnsiString(S,CodePage);
      try
        Move(s[1],WDataPtr^,WSize);
        Move(a[1],ADataPtr^,ASize);
        LDataPtr^ := CodePage;
        SetClipboardData(CF_UNICODETEXT, WData);
        SetClipboardData(CF_TEXT, AData);
        SetClipboardData(CF_LOCALE, LData);
      finally
        GlobalUnlock(WData);
        GlobalUnlock(AData);
        GlobalUnlock(LData);
      end;
    except
      GlobalFree(WData);
      GlobalFree(AData);
      GlobalFree(LData);
    raise;
    end;
  finally
    CloseClipBoard;
  end;
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
    toRead := Max(0,HistoryLength-hppLoadBlock-1);
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

  UserCodepage := GetContactCodePage(hContact, Protocol);
  hg.RTLMode := GetContactRTLModeTRTL(hContact, Protocol);

  if hContact = 0 then Caption := AnsiToWideString(Translate('System History'),hppCodepage)
                  else Caption := WideFormat(Caption,[hg.ContactName]);
  hg.Allocate(Length(History));
  bnConversation.Visible := not (hContact = 0);
end;

procedure THistoryFrm.FindDialogFind(Sender: TObject);
begin
  LastSearch := lsSearch;
  SearchNext((frDown in FindDialog.Options)=(hg.Reversed));
end;

procedure THistoryFrm.FormCreate(Sender: TObject);
var
  i: integer;
  mi: TMenuItem;
begin
  Icon.ReleaseHandle;
  Icon.Handle := CopyIcon(hppIcons[0].handle);
  DesktopFont := True;
  MakeFontsParent(Self);
  for i := 0 to High(cpTable) do begin
    mi := NewItem(cpTable[i].name,0,false,true,nil,0,'cp'+intToStr(i));
    mi.Tag := cpTable[i].cp;
    mi.OnClick := CodepageChangeClick;
    mi.AutoCheck := True;
    mi.RadioItem := True;
    ANSICodepage1.Add(mi);
  end;
  TranslateForm;
  cbFilter.ItemIndex := 0;
  RecentFormat := sfHtml;
  hg.InlineRichEdit.PopupMenu := pmGridInline;
  //for i := 0 to pmOptions.Items.Count-1 do
  //  pmOptions.Items.Remove(pmOptions.Items[0]);
  ShowSessions(False);
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
begin
  if Utils_RestoreWindowPosition(Self.Handle,0,0,hppDBName,'HistoryWindow.') <> 0 then begin
    Self.Left := (Screen.Width-Self.Width) div 2;
    Self.Top := (Screen.Height - Self.Height) div 2;
  end;
  if hContact = 0 then begin
    cbFilter.ItemIndex := 0;
    //paTop.Visible := False; // already set at Load proc
  end else begin
    filt := GetDBInt(hppDBName,'LastFilter',0);
  // if filter is System then set to all
    if filt >= cbFilter.Items.Count then filt := 0;
    cbFilter.ItemIndex := filt;
  end;
  cbSort.ItemIndex:=GetDBInt(hppDBName,'SortOrder',0);
  ShowSessionsAfterPassword := GetDBBool(hppDBName,'ShowSessions',False);
  paSess.Width := GetDBInt(hppDBName,'SessionsWidth',150);
end;

procedure THistoryFrm.SavePosition;
//save position and filter setting
begin
  Utils_SaveWindowPosition(Self.Handle,0,hppDBName,'HistoryWindow.');
  if hContact <> 0 then
    WriteDBInt(hppDBName,'LastFilter',cbFilter.ItemIndex);
  WriteDBInt(hppDBName,'SortOrder',cbSort.ItemIndex);
  if (hContact <> 0) and (not PasswordMode) then begin
     WriteDBBool(hppDBName,'ShowSessions',paSess.Visible);
     if paSess.Visible then
        WriteDBInt(hppDBName,'SessionsWidth',paSess.Width);
  end;
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
  //mcase,down: boolean;
  //t,stext: String;
  //res: Integer;
begin
  if (key = VK_F4) and (Shift=[]) then begin
    ShowSessions(not paSess.Visible);
    key := 0;
    end;

  if (key = VK_F3) and ((Shift=[]) or (Shift=[ssShift])) and (not PasswordMode) then begin
    SearchNext(ssShift in Shift,True);
    key := 0;
  end;

  if (ssAlt in Shift) then
    begin
    if key=Ord('C') then
      bnClose.Click;
    if (key=Ord('A')) and (not PasswordMode) then
      bbAddit.Click;
    if (key=Ord('D')) and (not PasswordMode) then
      bnDelete.Click;
    if (key=Ord('S')) and (not PasswordMode) then
      bnSearch.Click;
    key:=0;
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
    if (key=Ord('F')) and (not PasswordMode) then begin
      bnSearch.Click;
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
    FindDialog.CloseDialog;
    while SessThread <> nil do
      Application.ProcessMessages;
  except
  end;
end;

procedure THistoryFrm.Load;
begin
  if hContact = 0 then paTop.Visible := False;
  LoadHistory(Self);
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

procedure THistoryFrm.AddHistoryItem(hDBEvent:THandle);
//only add single lines, not whole histories, because this routine is pretty
//slow
begin
  Inc(HistoryLength);
  SetLength(History,HistoryLength);
  History[HistoryLength-1] := hDBEvent;
  hg.AddItem;
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

procedure THistoryFrm.FormShow(Sender: TObject);
begin
  LoadPosition;
  ProcessPassword;
  if not PasswordMode then ShowSessions(ShowSessionsAfterPassword);
  
  HookEvents;

  SessThread := TSessionsThread.Create(True);
  SessThread.ParentHandle := Self.Handle;
  SessThread.Contact := hContact;
  SessThread.Priority := tpLower;
  SessThread.Resume;
end;

procedure THistoryFrm.hgItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
//var
  //hi: THistoryItem;
begin
  Item := GetItemData(GridIndexToHistory(Index));
  Item.Proto := Protocol;
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
    //AddMenu(Options1,pmAdd,pmGrid,-1);
    //AddMenu(ANSICodepage1,pmAdd,pmGrid,-1);
    //AddMenu(ContactRTLmode1,pmAdd,pmGrid,-1);
    AddMenuArray(pmGrid,[Options1,ANSICodepage1,ContactRTLmode1],-1);
    pmGrid.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
  end;
end;

procedure THistoryFrm.cbFilterChange(Sender: TObject);
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
end;

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

procedure THistoryFrm.bnSearchClick(Sender: TObject);
begin
  //hgState(Self,gsSearch);
  FindDialog.Execute;
end;

const
  // 4 hours
  TIME_DIFF = 4*(60*60);

procedure THistoryFrm.bnConversationClick(Sender: TObject);
begin
  ShowSessions(not paSess.Visible);
end;

procedure THistoryFrm.hgDblClick(Sender: TObject);
begin
  if hg.Selected = -1 then
    exit;
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
    3: SaveFormat := sfUnicode;
    4: SaveFormat := sfText;
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

procedure THistoryFrm.hgItemDelete(Sender: TObject; Index: Integer);
var
  idx: Integer;
begin
  idx := GridIndexToHistory(Index);
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
  // if filter by sessions disabled, then exit
  if StartTimestamp = 0 then exit;
  //Show := False;
  if hg.Items[Index].Time >= StartTimestamp then begin
    if EndTimestamp = 0 then exit
    else begin
      if hg.Items[Index].Time < EndTimestamp then exit
      else Show := False;
    end;
  end else Show := False;
end;

procedure THistoryFrm.Delete1Click(Sender: TObject);
begin
  if hg.SelCount = 0 then exit;
  if hg.SelCount > 1 then begin
    if Windows.MessageBox(Handle,
      PChar(Format(Translate('Do you really want to delete selected items (%.0f)?'),
      [hg.SelCount/1])), Translate('Delete Selected'),
      MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = IDNO then exit;
  end else begin
    if Windows.MessageBox(Handle, Translate('Do you really want to delete selected item?'),
    Translate('Delete'), MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = IDNO then exit;
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

procedure THistoryFrm.bnDeleteClick(Sender: TObject);
begin
  Delete1.Click
end;

procedure THistoryFrm.bbAdditClick(Sender: TObject);
var
  p: TPoint;
begin
  if hg.state <> gsIdle then exit;
  p := Point(0,bbAddit.Height);
  p := bbAddit.ClientToScreen(p);
  //AddMenu(Options1,pmGrid,pmAdd,0);
  //AddMenu(ANSICodepage1,pmGrid,pmAdd,1);
  //AddMenu(ContactRTLmode1,pmGrid,pmAdd,2);
  AddMenuArray(pmAdd,[Options1,ANSICodepage1,ContactRTLmode1],0);
  pmAdd.Popup(p.x,p.y);
end;

procedure THistoryFrm.Copy1Click(Sender: TObject);
  function GetItemText(Item: Integer): WideString;
  begin
    if mtIncoming in hg.Items[Item].MessageType then
      Result := hg.ContactName
    else
      Result := hg.ProfileName;
    Result := Result+', '+TimestampToString(hg.Items[Item].Time)+' :';
    Result := Result+#13#10+hg.Items[Item].Text;
  end;
var
  t: WideString;
  i: Integer;
begin
  if hg.Selected = -1 then exit;
  t := '';
  if hg.SelCount = 1 then
    t := GetItemText(hg.Selected)
  else begin
    if hg.SelItems[0] > hg.SelItems[hg.SelCount-1] then
      for i := 0 to hg.SelCount-1 do t := t+GetItemText(hg.SelItems[i]) + #13#10
    else
      for i := hg.SelCount-1 downto 0 do t := t+GetItemText(hg.SelItems[i]) + #13#10;
    t := TrimRight(t);
  end;
  CopyToClip(t,Handle,UserCodepage);
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

procedure THistoryFrm.bnCloseClick(Sender: TObject);
begin
  close;
end;

procedure THistoryFrm.hgState(Sender: TObject; State: TGridState);
var
  Idle: Boolean;
  t: WideString;
begin
  if csDestroying in ComponentState then
    exit;
  Idle := (State <> gsDelete);
  cbFilter.Enabled := Idle and not PasswordMode;
  bnSearch.Enabled := Idle and not PasswordMode;
  bnDelete.Enabled := Idle and not PasswordMode;
  bbAddit.Enabled := Idle; // bnAddit don't gets disabled on PassMode
  case State of
    gsIdle:   t := WideFormat(TranslateWideW('%.0n items in history'),[HistoryLength/1]);
    gsLoad:   t := TranslateWideW('Loading...');
    gsSave:   t := TranslateWideW('Saving...');
    gsSearch: t := TranslateWideW('Searching...');
    gsDelete: t := TranslateWideW('Deleting...');
  end;
  if PasswordMode then
    t := TranslateWideW('Enter password');
  //sb.SimpleText := AnsiToWideString(t,hppCodepage);
  sb.SimpleText := t;
end;

procedure THistoryFrm.DeleteAll1Click(Sender: TObject);
begin
  if Windows.MessageBox(Handle,
    PChar(Format(Translate('Do you really want to delete ALL items (%.0f) for this contact?')+
    #10#13+''+#10#13+Translate('Note: It can take several minutes for large history.'),
    [hg.Count/1])), Translate('Delete All'), MB_YESNO or MB_DEFBUTTON2 or MB_ICONEXCLAMATION) = IDNO then exit;

  SetSafetyMode(False);
  try
    hg.DeleteAll;
  finally
    SetSafetyMode(True);
    end;
end;

procedure THistoryFrm.SaveasHTML1Click(Sender: TObject);
var
  t: String;
begin
  PrepareSaveDialog(SaveDialog,sfHtml);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  // why SaveDialog.FileName shows '' here???
  // who knows? In debugger FFileName shows right file, but
  // FileName property returns ''
  RecentFormat := sfHTML;
  hg.SaveAll(SaveDialog.Files[0],sfHTML);
  //hg.SaveAll(SaveDialog.FileName,sfHTML);
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

procedure THistoryFrm.ApplyFilter(DoApply: boolean = true);
begin
  cbSortChange(cbSort);
  if not DoApply then cbFilter.ItemIndex := 0;
  cbFilterChange(cbFilter);
end;

procedure THistoryFrm.cbSortChange(Sender: TObject);
begin
  if hg.Reversed = (cbSort.ItemIndex = 0) then exit;
  hg.Reversed := (cbSort.ItemIndex = 0);
  LastSearch := lsNone;
  LastHotIdx := -1;
  HotString := '';
  if (frDown in FindDIalog.Options) then
    FindDialog.Options := FindDialog.Options - [frDown]
  else
    FindDialog.Options := FindDialog.Options + [frDown];
end;

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
if hg.HotString = '' then begin
  LastHotIdx := -1;
  // redraw status bar
  hgState(hg,gsIdle);
  end;
end;

procedure THistoryFrm.FindDialogClose(Sender: TObject);
begin
  hg.SetFocus;
end;

procedure THistoryFrm.SearchNext(Rev: Boolean; Warp: Boolean = True);
var
  stext: WideString;
  t,tCap: string;
  res: Integer;
  mcase,down: Boolean;
  WndHandle: HWND;
begin
  if LastSearch = lsNone then exit;
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
      t := Translate('Search: %s (F3 to find next)')
    else
      t := Translate('HotSearch: %s (F3 to find next)');
    sb.SimpleText := WideFormat(AnsiToWideString(t,hppCodepage),[stext]);
  end else begin
    if (LastSearch = lsSearch) and (FindDialog.Handle <> 0) then
      WndHandle := FindDialog.Handle
    else
      WndHandle := Handle;
    tCap := Translate('History++ Search');
    // not found
    if Warp and (down = not hg.Reversed) then begin
      // do warp?
      if MessageBox(WndHandle, PChar(String(Translate('You have reached the end of the history.'))+
      #10#13+String(Translate('Do you want to continue searching at the beginning?'))),
      PChar(tCap), MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = ID_YES then
        SearchNext(Rev,False);
    end else begin
      // not warped
      hgState(Self,gsIdle);
      { 25.03.03 OXY: FindDialog looses focus when
      calling ShowMessage, using MessageBox instead }
      t := Translate('"%s" not found');
      if hppOSUnicode then
        MessageBoxW(WndHandle, PWideChar(WideFormat(AnsiToWideString(t,hppCodepage),[stext])),
        PWideChar(AnsiToWideString(tCap,hppCodepage)), MB_OK or MB_DEFBUTTON1 or 0)
      else
        MessageBox(WndHandle, PChar(Format(t,[stext])),
        PChar(tCap), MB_OK or MB_DEFBUTTON1 or 0);
    end;
  end;
end;

procedure THistoryFrm.ReplyQuoted(Item: Integer);
var
  Txt: WideString;
begin
  if hContact = 0 then exit;
  if (item < 0) or (item > hg.Count-1) then exit;
  if mtIncoming in hg.Items[Item].MessageType then
    Txt := hg.ContactName
  else
    Txt := hg.ProfileName;
  Txt := Txt+', '+TimestampToString(hg.Items[item].Time)+' :';
  Txt := Txt+#13#10+QuoteText(hg.Items[item].Text);
  SendMessageTo(hContact,Txt);
end;

var
  HtmlFilter: String = 'HTML file (*.html; *.htm)|*.html;*.htm';
  XmlFilter: String = 'XML file (*.xml)|*.xml';
  UnicodeFilter: String = 'Unicode text file (*.txt)|*.txt';
  TextFilter: String = 'Text file (*.txt)|*.txt';
  AllFilter: String = 'All files (*.*)|*.*';
  HtmlDef: String = '.html';
  XmlDef: String = '.xml';
  TextDef: String = '.txt';

procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);
begin
  if AllFormats then begin
    SaveDialog.Filter := HtmlFilter+'|'+XmlFilter+'|'+UnicodeFilter+'|'+TextFilter+'|'+AllFilter;
    case SaveFormat of
      sfHTML: SaveDialog.FilterIndex := 1;
      sfXML: SaveDialog.FilterIndex := 2;
      sfUnicode: SaveDialog.FilterIndex := 3;
      sfText: SaveDialog.FilterIndex := 4;
    end;
  end else begin
    case SaveFormat of
      sfHTML: begin SaveDialog.Filter := HtmlFilter; SaveDialog.FilterIndex := 1; end;
      sfXML:  begin SaveDialog.Filter := XmlFilter; SaveDialog.FilterIndex := 1; end;
      sfUnicode: begin SaveDialog.Filter := UnicodeFilter+'|'+TextFilter; SaveDialog.FilterIndex := 1; end;
      sfText: begin SaveDialog.Filter := UnicodeFilter+'|'+TextFilter; SaveDialog.FilterIndex := 2; end;
    end;
    SaveDialog.Filter := SaveDialog.Filter + '|' + AllFilter;
  end;
  case SaveFormat of
    sfHTML: SaveDialog.DefaultExt := HtmlDef;
    sfXML: SaveDialog.DefaultExt := XmlDef;
    sfUnicode: SaveDialog.DefaultExt := TextDef;
    sfText: SaveDialog.DefaultExt := TextDef;
  end;
end;

procedure THistoryFrm.SaveasXML1Click(Sender: TObject);
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
  //hg.SaveAll(SaveDialog.FileName,sfXML);
  RecentFormat := sfXML;
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.SaveasText1Click(Sender: TObject);
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
laFilter.Enabled := enb;
cbFilter.Enabled := enb;
//label2.Enabled := enb;
cbSort.Enabled := enb;
bnSearch.Enabled := enb;
bnDelete.Enabled := enb;
SaveAsHTML1.Enabled := enb;
SaveAsXML1.Enabled := enb;
SaveAsText1.Enabled := enb;
DeleteAll1.Enabled := enb;
hgState(hg,hg.State);
hg.Enabled := enb;
hg.Visible := enb;
paPassword.Enabled := not enb;
paPassword.Visible := not enb;
if value = true then begin
  ShowSessions(False);
  paPassword.Left := (paGrid.ClientWidth-paPassword.Width) div 2;
  paPassword.Top := (paGrid.ClientHeight - paPassword.Height) div 2;
  //laPass.Caption := Format('You need password to access history for %s
  edPass.SetFocus;
  end
else begin
  ShowSessions(ShowSessionsAfterPassword);
  hg.SetFocus;
  end;
end;

procedure THistoryFrm.ShowSessions(Show: Boolean);
begin
  if hContact = 0 then Show := False;

  paSess.Visible := Show;
  spSess.Visible := Show;
  spSess.Left := paSess.Left + paSess.Width + 1;

  if Show = False then begin
     StartTimestamp := 0;
     EndTimestamp := 0;
     hg.UpdateFilter;
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
  MessageBox(Handle, PChar(String(Translate('You have entered the wrong password.'))+
  #10#13+String(Translate('Make sure you have CAPS LOCK turned off.'))),
  Translate('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
end;

procedure THistoryFrm.paGridResize(Sender: TObject);
begin
if PasswordMode = true then begin
  paPassword.Left := (paGrid.ClientWidth-paPassword.Width) div 2;
  paPassword.Top := (paGrid.ClientHeight - paPassword.Height) div 2;
  end;
  inherited;
end;

procedure THistoryFrm.edPassKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
;
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

procedure THistoryFrm.ProcessPassword;
begin
  if IsPasswordBlank(GetPassword) then exit;
  if IsUserProtected(hContact) then
    PasswordMode := True;
end;

procedure THistoryFrm.Setpassword1Click(Sender: TObject);
begin
  OpenPassword;
end;

procedure THistoryFrm.OpenPassword;
begin
  RunPassForm;
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
        mi.Items[i].Caption := TranslateWideW(mi.Items[i].Caption{TRANSLATE-IGNORE});
        if mi.Items[i].Count > 0 then TranslateMenu(mi.Items[i]);
      end;
  end;

begin
  Caption := TranslateWideW(Caption);

  hg.TxtFullLog := Translate(PChar(hg.txtFullLog));
  hg.TxtGenHist1 := Translate(PChar(hg.txtGenHist1));
  hg.TxtGenHist2 := Translate(PChar(hg.txtGenHist2));
  hg.TxtHistExport := Translate(PChar(hg.TxtHistExport));
  hg.TxtNoItems := Translate(PChar(hg.TxtNoItems));
  hg.TxtNoSuch := Translate(PChar(hg.TxtNoSuch));
  hg.TxtPartLog := Translate(PChar(hg.TxtPartLog));
  hg.txtStartUp := Translate(PChar(hg.txtStartUp));

  laFilter.Caption := TranslateWideW(laFilter.Caption);

  for i := 0 to cbFilter.Items.Count-1 do
    cbFilter.Items[i] := TranslateWideW(cbFilter.Items[i]);

  for i := 0 to cbSort.Items.Count-1 do
    cbSort.Items[i] := TranslateWideW(cbSort.Items[i]);

  bnSearch.Caption := TranslateWideW(bnSearch.Caption);
  bnDelete.Caption := TranslateWideW(bnDelete.Caption);
  bbAddit.Caption := TranslateWideW(bbAddit.Caption);
  bnClose.Caption := TranslateWideW(bnClose.Caption);
  bnConversation.Caption := TranslateWideW(bnConversation.Caption);

  bnPass.Caption := TranslateWideW(bnPass.Caption);
  laPass.Caption := TranslateWideW(laPass.Caption);
  laPass2.Caption := TranslateWideW(laPass2.Caption);
  laSess.Caption := TranslateWideW(laSess.Caption);

  SaveDialog.Title := Translate(PAnsiChar(SaveDialog.Title));

  TranslateMenu(pmOptions.Items);
  TranslateMenu(pmAdd.Items);
  TranslateMenu(pmGrid.Items);
  TranslateMenu(pmGridInline.Items);
  TranslateMenu(pmLink.Items);
  TranslateMenu(pmFile.Items);

  HtmlFilter := Translate(PChar(HtmlFilter));
  XmlFilter := Translate(PChar(XmlFilter));
  UnicodeFilter := Translate(PChar(UnicodeFilter));
  TextFilter := Translate(PChar(TextFilter));
  AllFilter := Translate(PChar(AllFilter));

  cbFilter.Left := laFilter.Left + laFilter.Width + 5;
  cbSort.Left := paTop.Width - cbSort.Width - 2;
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
  Index := HistoryIndexToGrid(Index);
  hg.MakeTopmost(Index);
  hg.Selected := Index;
  exit;
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

procedure THistoryFrm.tvSessClick(Sender: TObject);
var
  Node: TTntTreeNode;
begin
  Node := tvSess.Selected;
  if Node = nil then exit;
  //tvSessChange(Self,Node);
end;

procedure THistoryFrm.tvSessMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Node: TTntTreeNode;
  count,time: DWord;
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
  if count = 1 then
    tvSess.Hint := WideFormat('%d message',[count, time/60])
  else
    tvSess.Hint := WideFormat(
      'Conversation:'+#13#10+
      '   '+'%d messages'+#13#10+
      '   '+'%0.f minutes',[count,time/60]);
  tvSess.ShowHint := True;
end;

procedure THistoryFrm.CopyText1Click(Sender: TObject);
  function GetItemText(Item: Integer): WideString;
  begin
    Result := hg.Items[Item].Text;
  end;
var
  t: WideString;
  i: Integer;
begin
  if hg.Selected = -1 then exit;
  t := '';
  if hg.SelCount = 1 then
    t := GetItemText(hg.Selected)
  else begin
    if hg.SelItems[0] > hg.SelItems[hg.SelCount-1] then
      for i := 0 to hg.SelCount-1 do t := t+GetItemText(hg.SelItems[i]) + #13#10 + #13#10
    else
      for i := hg.SelCount-1 downto 0 do t := t+GetItemText(hg.SelItems[i]) + #13#10 + #13#10;
    t := TrimRight(t);
  end;
  CopyToClip(t,Handle,UserCodepage);
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
  IconsEnabled1.Checked := hg.Options.ShowIcons;
  RTLEnabled1.Checked := hg.Options.RTLEnabled;
  if hContact = 0 then begin
    ContactRTLmode1.Visible := False;
    ANSICodepage1.Visible := False;
  end else begin
    case hg.RTLMode of
      hppRTLDefault: Self.RTLDefault2.Checked := true;
      hppRTLEnable: Self.RTLEnabled2.Checked := true;
      hppRTLDisable: Self.RTLDisabled2.Checked := true;
    end;
    for i := 0 to ANSICodepage1.Count-1 do
      if ANSICodepage1.Items[i].Tag = Integer(UserCodepage) then begin
        ANSICodepage1.Items[i].Checked := true;
        break;
      end;
  end;
  SmileysEnabled1.Enabled := SmileyAddEnabled;
  SmileysEnabled1.Checked := hg.Options.SmileysEnabled;
  BBCodesEnabled1.Checked := hg.Options.BBCodesEnabled;
  //MathModuleEnabled1.Enabled := MathModuleEnabled;
  //MathModuleEnabled1.Checked  := hg.Options.MathModuleEnabled;
  UnderlineURLs1.Checked := hg.Options.UnderlineURLEnabled;
  FindURLs1.Checked := hg.Options.FindURLEnabled;
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

procedure THistoryFrm.AddMenuArray(Menu: TPopupMenu; List: Array of TMenuItem; Index: integer);
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

procedure THistoryFrm.pmPopup(Sender: TObject);
begin
  LoadInOptions();
end;

procedure THistoryFrm.IconsEnabled1Click(Sender: TObject);
var
  val: boolean;
begin
  val := not hg.Options.ShowIcons;
  hg.Options.ShowIcons := val;
  SaveGridOptions;
  //(Sender as TMenuItem).Checked := val;
end;

procedure THistoryFrm.RTLEnabled1Click(Sender: TObject);
var
  val: boolean;
begin
  val := not hg.Options.RTLEnabled;
  hg.Options.RTLEnabled := val;
  SaveGridOptions;
  //(Sender as TMenuItem).Checked := val;
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

procedure THistoryFrm.SmileysEnabled1Click(Sender: TObject);
var
  val: boolean;
begin
  val := not hg.Options.SmileysEnabled;
  hg.Options.SmileysEnabled := val;
  SaveGridOptions;
  //(Sender as TMenuItem).Checked := val;
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
        PrevYearNode := tvSess.Items.AddChild(nil,FormatDateTime('yyyy',dt));
        PrevYearNode.Data := Pointer(YearOf(dt));
        PrevYearNode.ImageIndex := -1;
        PrevYearNode.SelectedIndex := PrevYearNode.ImageIndex;
      end;
      if (PrevMonthNode = nil) or (DWord(PrevMonthNode.Data) <> MonthOf(dt)) then begin
        PrevMonthNode := tvSess.Items.AddChild(PrevYearNode,FormatDateTime('mmmm',dt));
        PrevMonthNode.Data := Pointer(MonthOf(dt));
        case MonthOf(dt) of
          12,1..2: PrevMonthNode.ImageIndex := 3;
          3..5: PrevMonthNode.ImageIndex := 4;
          6..8: PrevMonthNode.ImageIndex := 1;
          9..11: PrevMonthNode.ImageIndex := 2;
        end;
        PrevMonthNode.SelectedIndex := PrevMonthNode.ImageIndex;
      end;
      ti := tvSess.Items.AddChild(PrevMonthNode,FormatDateTime('d (h:nn)',dt));
      ti.Data := Pointer(i);
      ti.ImageIndex := 0;
      ti.SelectedIndex := ti.ImageIndex;
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

procedure THistoryFrm.BBCodesEnabled1Click(Sender: TObject);
var
  val: boolean;
begin
  val := not hg.Options.BBCodesEnabled;
  hg.Options.BBCodesEnabled := val;
  SaveGridOptions;
  //(Sender as TMenuItem).Checked := val;
end;

procedure THistoryFrm.MathModuleEnabled1Click(Sender: TObject);
var
  val: boolean;
begin
  val := not hg.Options.MathModuleEnabled;
  hg.Options.MathModuleEnabled := val;
  SaveGridOptions;
  //(Sender as TMenuItem).Checked := val;
end;

procedure THistoryFrm.UnderlineURLs1Click(Sender: TObject);
var
  val: boolean;
begin
  val := not hg.Options.UnderlineURLEnabled;
  hg.Options.UnderlineURLEnabled := val;
  SaveGridOptions;
  //(Sender as TMenuItem).Checked := val;
end;

procedure THistoryFrm.FindURLs1Click(Sender: TObject);
var
  val: boolean;
begin
  val := not hg.Options.FindURLEnabled;
  hg.Options.FindURLEnabled := val;
  SaveGridOptions;
  //(Sender as TMenuItem).Checked := val;
end;

procedure THistoryFrm.pmGridInlinePopup(Sender: TObject);
begin
   CopyInline.Enabled := (hg.InlineRichEdit.SelLength > 0);
end;

procedure THistoryFrm.CopyInlineClick(Sender: TObject);
begin
  CopyToClip(hg.InlineRichEdit.SelText,Handle,UserCodepage);
end;


procedure THistoryFrm.CopyAllInlineClick(Sender: TObject);
begin
  CopyToClip(hg.InlineRichEdit.Text,Handle,UserCodepage);
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

procedure THistoryFrm.CodepageChangeClick(Sender: TObject);
var
  val: Cardinal;
begin
  val := (Sender as TMenuItem).Tag;
  WriteContactCodePage(hContact,val,Protocol);
  UserCodepage := val;
end;

end.
