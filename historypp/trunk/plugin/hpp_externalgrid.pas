(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.
    History+ parts (C) 2001 Christian Kastner

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

unit hpp_externalgrid;

interface

uses
  Windows, Classes, Controls, Forms, Graphics, Messages, SysUtils, Dialogs,
  m_api, m_globaldefs,
  hpp_global, hpp_events, hpp_contacts, hpp_services, hpp_forms, hpp_bookmarks,
  hpp_richedit, hpp_messages, hpp_eventfilters, hpp_database, hpp_itemprocess,
  HistoryGrid,
  RichEdit, Menus, TntMenus, TntSysUtils, ShellAPI;

type
  TExGridMode = (gmNative, gmIEView);

  PExtCustomItem = ^TExtCustomItem;
  TExtCustomItem = record
    Nick: WideString;
    Text: WideString;
    Sent: Boolean;
    Time: DWord;
  end;

  TExtItem = record
    hDBEvent: THandle;
    hContact: THandle;
    Codepage: THandle;
    RTLMode: TRTLMode;
    Custom: Boolean;
    CustomEvent: TExtCustomItem;
  end;

  TOnDestroyWindow = procedure(Sender: TObject; Handle: HWND) of object;

  TExtHistoryGrid = class(THistoryGrid)
  private
    FCachedHandle: HWND;
    FControlID: Cardinal;
    FSavedKeyMessage: TWMKey;
    FOnDestroyWindow: TOnDestroyWindow;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMSysKeyUp(var Message: TWMSysKeyUp); message WM_SYSKEYUP;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMDestroy(var Message: TWMNCDestroy); message WM_DESTROY;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
  protected
    function GetCachedHandle: HWND;
    function SendMsgFilterMessage(var Message: TMessage): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    property CachedHandle: HWND read GetCachedHandle;
    property ControlID: Cardinal read FControlID write FControlID;
    property OnDestroyWindow: TOnDestroyWindow read FOnDestroyWindow write FOnDestroyWindow;
  end;

  TExternalGrid = class(TObject)
  private
    Items: array of TExtItem;
    Grid: TExtHistoryGrid;
    FParentWindow: HWND;
    FSelection: Pointer;
    SavedLinkUrl: WideString;
    SavedFileDir: String;
    pmGrid: TTntPopupMenu;
    pmLink: TTntPopupMenu;
    miEventsFilter: TTntMenuItem;
    WasKeyPressed: Boolean;
    FGridMode: TExGridMode;
    FUseHistoryRTLMode: Boolean;
    FExternalRTLMode: TRTLMode;
    FUseHistoryCodepage: Boolean;
    FExternalCodepage: Cardinal;
    FGridState: TGridState;
    SaveDialog: TSaveDialog;
    RecentFormat: TSaveFormat;
    FSubContact: THandle;
    FSubProtocol: String;

    function GetGridHandle: HWND;
    procedure SetUseHistoryRTLMode(const Value: Boolean);
    procedure SetUseHistoryCodepage(const Value: Boolean);
    procedure SetGroupLinked(const Value: Boolean);
    procedure SetShowHeaders(const Value: Boolean);
    procedure SetShowBookmarks(const Value: Boolean);
    procedure CreateEventsFilterMenu;
    procedure SetEventFilter(FilterIndex: Integer = -1);
    function IsFileEvent(Index: Integer): Boolean;
  protected
    procedure GridItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
    procedure GridTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
    procedure GridNameData(Sender: TObject; Index: Integer; var Name: WideString);
    procedure GridProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
    procedure GridUrlClick(Sender: TObject; Item: Integer; URLText: WideString; Button: TMouseButton);
    procedure GridBookmarkClick(Sender: TObject; Item: Integer);
    procedure GridSelectRequest(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridPopup(Sender: TObject);
    procedure GridInlineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridItemDelete(Sender: TObject; Index: Integer);
    procedure GridXMLData(Sender: TObject; Index: Integer; var Item: TXMLItem);
    procedure GridMCData(Sender: TObject; Index: Integer; var Item: TMCItem; Stage: TSaveStage);
    procedure OnCopyClick(Sender: TObject);
    procedure OnCopyTextClick(Sender: TObject);
    procedure OnSelectAllClick(Sender: TObject);
    procedure OnTextFormattingClick(Sender: TObject);
    procedure OnReplyQuotedClick(Sender: TObject);
    procedure OnBookmarkClick(Sender: TObject);
    procedure OnOpenClick(Sender: TObject);
    procedure OnOpenLinkClick(Sender: TObject);
    procedure OnOpenLinkNWClick(Sender: TObject);
    procedure OnCopyLinkClick(Sender: TObject);
    procedure OnDeleteClick(Sender: TObject);
    procedure OnBidiModeLogClick(Sender: TObject);
    procedure OnBidiModeHistoryClick(Sender: TObject);
    procedure OnCodepageLogClick(Sender: TObject);
    procedure OnCodepageHistoryClick(Sender: TObject);
    procedure OnSaveSelectedClick(Sender: TObject);
    procedure OnEventsFilterItemClick(Sender: TObject);
    procedure OnBrowseReceivedFilesClick(Sender: TObject);
    procedure OnOpenFileFolderClick(Sender: TObject);
    procedure OnSpeakMessage(Sender: TObject);
  public
    constructor Create(AParentWindow: HWND; ControlID: Cardinal = 0);
    destructor Destroy; override;
    procedure AddEvent(hContact, hDBEvent: Cardinal; Codepage: Integer; RTL: Boolean; DoScroll: Boolean);
    procedure AddCustomEvent(hContact: Cardinal; CustomItem: TExtCustomItem; Codepage: Integer; RTL: boolean; DoScroll: Boolean);
    procedure SetPosition(x, y, cx, cy: Integer);
    procedure ScrollToBottom;
    function GetSelection(NoUnicode: Boolean): PChar;
    procedure SaveSelected;
    procedure Clear;
    property ParentWindow: HWND read FParentWindow;
    property GridHandle: HWND read GetGridHandle;
    property GridMode: TExGridMode read FGridMode write FGridMode;
    property UseHistoryRTLMode: Boolean read FUseHistoryRTLMode write SetUseHistoryRTLMode;
    property UseHistoryCodepage: Boolean read FUseHistoryCodepage write SetUseHistoryCodepage;
    function Perform(Msg: Cardinal; WParam, LParam: Longint): Longint;
    procedure HMBookmarkChanged(var M: TMessage); message HM_NOTF_BOOKMARKCHANGED;
    //procedure HMIcons2Changed(var M: TMessage); message HM_NOTF_ICONS2CHANGED;
    procedure HMFiltersChanged(var M: TMessage); message HM_NOTF_FILTERSCHANGED;
    procedure HMNickChanged(var M: TMessage); message HM_NOTF_NICKCHANGED;
    procedure HMEventDeleted(var M: TMessage); message HM_MIEV_EVENTDELETED;
    procedure HMMetaDefaultChanged(var M: TMessage); message HM_MIEV_METADEFCHANGED;
    procedure BeginUpdate;
    procedure EndUpdate;
    property ShowHeaders: Boolean write SetShowHeaders;
    property GroupLinked: Boolean write SetGroupLinked;
    property ShowBookmarks: Boolean write SetShowBookmarks;
  end;

implementation

uses hpp_options,hpp_sessionsthread;

{ TExtHistoryGrid }

constructor TExtHistoryGrid.Create(AOwner: TComponent);
begin
  FCachedHandle := 0;
  FControlID := 0;
  inherited;
end;

function TExtHistoryGrid.GetCachedHandle: HWND;
begin
  if (FCachedHandle = 0) or HandleAllocated then
    Result := Handle else
    Result := FCachedHandle;
end;

function TExtHistoryGrid.SendMsgFilterMessage(var Message: TMessage): Integer;
var
  mf: TMsgFilter;
begin
  Result := 0;
  if FControlID <> 0 then begin
    mf.nmhdr.hwndFrom := WindowHandle;
    mf.nmhdr.idFrom := FControlID;
    mf.nmhdr.code := EN_MSGFILTER;
    mf.msg := Message.Msg;
    mf.wParam := Message.WParam;
    mf.lParam := Message.LParam;
    Result := SendMessage(ParentWindow,WM_NOTIFY,FControlID,LPARAM(@mf));
  end;
end;

procedure TExtHistoryGrid.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  FSavedKeyMessage := Message;
  if Message.CharCode <> 0 then SendMsgFilterMessage(TMessage(Message))
end;

procedure TExtHistoryGrid.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;
  if FSavedKeyMessage.CharCode = 0 then exit;
  if Message.CharCode <> 0 then SendMsgFilterMessage(TMessage(Message))
end;

procedure TExtHistoryGrid.WMSysKeyUp(var Message: TWMSysKeyUp);
begin
  inherited;
  if FSavedKeyMessage.CharCode = 0 then exit;
  if Message.CharCode <> 0 then SendMsgFilterMessage(TMessage(Message))
end;

procedure TExtHistoryGrid.WMChar(var Message: TWMChar);
begin
  inherited;
  if FSavedKeyMessage.CharCode = 0 then exit;
  if Message.CharCode <> 0 then SendMsgFilterMessage(TMessage(Message))
end;

procedure TExtHistoryGrid.WMDestroy(var Message: TWMDestroy);
begin
  if not (csDestroyingHandle in ControlState) then
    FCachedHandle := Handle;
  inherited;
end;

procedure TExtHistoryGrid.WMNCDestroy(var Message: TWMNCDestroy);
begin
  inherited;
  if not (csDestroyingHandle in ControlState) then
    if Assigned(FOnDestroyWindow) then
      FOnDestroyWindow(Self,FCachedHandle);
end;

{ TExternalGrid }

function TExternalGrid.Perform(Msg: Cardinal; WParam, LParam: Longint): Longint;
var
  M: TMessage;
begin
  M.Msg := Msg;
  M.WParam := WParam;
  M.LParam := LParam;
  Dispatch(M);
  Result := M.Result;
end;

procedure TExternalGrid.AddEvent(hContact, hDBEvent: Cardinal; Codepage: Integer; RTL: Boolean; DoScroll: Boolean);
var
  RTLMode: TRTLMode;
begin
  SetLength(Items,Length(Items)+1);
  Items[High(Items)].hDBEvent := hDBEvent;
  Items[High(Items)].hContact := hContact;
  Items[High(Items)].Codepage := Codepage;
  Items[High(Items)].Custom := False;
  if RTL then RTLMode := hppRTLEnable
         else RTLMode := hppRTLDefault;
  Items[High(Items)].RTLMode := RTLMode;
  if Cardinal(Grid.Contact) <> hContact then begin
    Grid.Contact := hContact;
    Grid.Protocol := GetContactProto(hContact,FSubContact,FSubProtocol);
    FExternalRTLMode := RTLMode;
    UseHistoryRTLMode := GetDBBool(Grid.Contact,Grid.Protocol,'UseHistoryRTLMode',FUseHistoryRTLMode);
    FExternalCodepage := Codepage;
    UseHistoryRTLMode := GetDBBool(Grid.Contact,Grid.Protocol,'UseHistoryCodepage',FUseHistoryCodepage);
  end;
  // comment or we'll get rerendering the whole grid
  //if Grid.Codepage <> Codepage then Grid.Codepage := Codepage;
  Grid.Allocate(Length(Items),DoScroll and (Grid.State <> gsInline));
end;

procedure TExternalGrid.AddCustomEvent(hContact: Cardinal; CustomItem: TExtCustomItem; Codepage: Integer; RTL: Boolean; DoScroll: Boolean);
var
  RTLMode: TRTLMode;
begin
  SetLength(Items,Length(Items)+1);
  Items[High(Items)].hDBEvent := 0;
  Items[High(Items)].hContact := hContact;
  Items[High(Items)].Codepage := Codepage;
  Items[High(Items)].Custom := True;
  Items[High(Items)].CustomEvent.Nick := CustomItem.Nick;
  Items[High(Items)].CustomEvent.Text := CustomItem.Text;
  Items[High(Items)].CustomEvent.Sent := CustomItem.Sent;
  Items[High(Items)].CustomEvent.Time := CustomItem.Time;
  if RTL then RTLMode := hppRTLEnable
         else RTLMode := hppRTLDefault;
  Items[High(Items)].RTLMode := RTLMode;
  if Cardinal(Grid.Contact) <> hContact then begin
    Grid.Contact := hContact;
    Grid.Protocol := GetContactProto(hContact,FSubContact,FSubProtocol);
    FExternalRTLMode := RTLMode;
    UseHistoryRTLMode := GetDBBool(Grid.Contact,Grid.Protocol,'UseHistoryRTLMode',FUseHistoryRTLMode);
    FExternalCodepage := Codepage;
    UseHistoryRTLMode := GetDBBool(Grid.Contact,Grid.Protocol,'UseHistoryCodepage',FUseHistoryCodepage);
  end;
  // comment or we'll get rerendering the whole grid
  //if Grid.Codepage <> Codepage then Grid.Codepage := Codepage;
  Grid.Allocate(Length(Items),DoScroll and (Grid.State <> gsInline));
end;

constructor TExternalGrid.Create(AParentWindow: HWND; ControlID: Cardinal = 0);

  function RadioItem(Value: Boolean; mi: TTntMenuItem): TTntMenuItem;
  begin
    Result := mi;
    Result.RadioItem := Value;
  end;

begin
  FParentWindow := AParentWindow;
  WasKeyPressed := False;
  FGridMode := gmNative;
  FUseHistoryRTLMode := False;
  FExternalRTLMode := hppRTLDefault;
  FUseHistoryCodepage := False;
  FExternalCodepage := CP_ACP;
  FSelection := nil;
  FGridState := gsIdle;
  RecentFormat := sfHtml;

  Grid := TExtHistoryGrid.CreateParented(ParentWindow);

  Grid.Reversed := False;
  Grid.ShowHeaders := True;
  Grid.ReversedHeader := True;
  Grid.ExpandHeaders := GetDBBool(hppDBName,'ExpandLogHeaders',False);
  Grid.HideSelection := True;
  Grid.ControlID := ControlID;

  Grid.ParentCtl3D := False;
  Grid.Ctl3D := True;
  Grid.ParentColor := False;
  Grid.Color := clBtnFace;

  Grid.BevelEdges := [beLeft, beTop, beRight, beBottom];
  Grid.BevelKind := bkNone;
  Grid.BevelInner := bvNone;
  Grid.BevelOuter := bvNone;
  Grid.BevelWidth := 1;

  if GetDBBool(hppDBName,'NoLogBorder',False) then
    Grid.BorderStyle := bsNone else
    Grid.BorderStyle := bsSingle;
  Grid.BorderWidth := 0;

  Grid.HideScrollBar := GetDBBool(hppDBName,'NoLogScrollBar',False);

  Grid.OnItemData := GridItemData;
  Grid.OnTranslateTime := GridTranslateTime;
  Grid.OnNameData := GridNameData;
  Grid.OnProcessRichText := GridProcessRichText;
  Grid.OnUrlClick := GridUrlClick;
  Grid.OnBookmarkClick := GridBookmarkClick;
  Grid.OnSelectRequest := GridSelectRequest;
  Grid.OnDblClick := GridDblClick;
  Grid.OnKeyDown := GridKeyDown;
  Grid.OnKeyUp := GridKeyUp;
  Grid.OnPopup := GridPopup;
  Grid.OnInlinePopup := GridPopup;
  Grid.OnInlineKeyDown := GridInlineKeyDown;
  Grid.OnItemDelete := GridItemDelete;
  Grid.OnXMLData := GridXMLData;
  Grid.OnMCData := GridMCData;

  Grid.TxtFullLog := TranslateWideW(Grid.TxtFullLog{TRANSLATE-IGNORE});
  Grid.TxtGenHist1 := TranslateWideW(Grid.TxtGenHist1{TRANSLATE-IGNORE});
  Grid.TxtGenHist2 := TranslateWideW(Grid.TxtGenHist2{TRANSLATE-IGNORE});
  Grid.TxtHistExport := TranslateWideW(Grid.TxtHistExport{TRANSLATE-IGNORE});
  Grid.TxtNoItems := '';
  Grid.TxtNoSuch := TranslateWideW(Grid.TxtNoSuch{TRANSLATE-IGNORE});
  Grid.TxtPartLog := TranslateWideW(Grid.TxtPartLog{TRANSLATE-IGNORE});
  Grid.TxtStartUp := TranslateWideW(Grid.TxtStartUp{TRANSLATE-IGNORE});
  Grid.TxtSessions := TranslateWideW(Grid.TxtSessions{TRANSLATE-IGNORE});

  Grid.Options := GridOptions;

  Grid.GroupLinked := GetDBBool(hppDBName,'GroupLogItems',False);

  pmGrid := TTntPopupMenu.Create(Grid);
  pmGrid.ParentBiDiMode := False;
  pmGrid.Items.Add(WideNewItem('Sh&ow in history',0,false,true,OnOpenClick,0,'pmOpen'));
  pmGrid.Items.Add(WideNewItem('Speak Message',0,false,true,OnSpeakMessage,0,'pmSpeakMessage'));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN1'));
  pmGrid.Items.Add(WideNewItem('&Copy',TextToShortCut('Ctrl+C'),false,true,OnCopyClick,0,'pmCopy'));
  pmGrid.Items.Add(WideNewItem('Copy &Text',TextToShortCut('Ctrl+T'),false,true,OnCopyTextClick,0,'pmCopyText'));
  pmGrid.Items.Add(WideNewItem('Select &All',TextToShortCut('Ctrl+A'),false,true,OnSelectAllClick,0,'pmSelectAll'));
  pmGrid.Items.Add(WideNewItem('&Delete',TextToShortCut('Del'),false,true,OnDeleteClick,0,'pmDelete'));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN2'));
  pmGrid.Items.Add(WideNewItem('Text Formatting',TextToShortCut('Ctrl+P'),false,true,OnTextFormattingClick,0,'pmTextFormatting'));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN3'));
  pmGrid.Items.Add(WideNewItem('&Reply Quoted',TextToShortCut('Ctrl+R'),false,true,OnReplyQuotedClick,0,'pmReplyQuoted'));
  pmGrid.Items.Add(WideNewItem('Set &Bookmark',TextToShortCut('Ctrl+B'),false,true,OnBookmarkClick,0,'pmBookmark'));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN4'));
  pmGrid.Items.Add(WideNewItem('&Save Selected...',TextToShortCut('Ctrl+S'),false,true,OnSaveSelectedClick,0,'pmSaveSelected'));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN5'));
  pmGrid.Items.Add(WideNewSubMenu('&File Actions',0,'pmFileActions',[
    WideNewItem('&Browse Received Files',0,false,true,OnBrowseReceivedFilesClick,0,'pmBrowseReceivedFiles',),
    WideNewItem('&Open file folder',0,false,true,OnOpenFileFolderClick,0,'pmOpenFileFolder',),
    WideNewItem('-',0,false,true,nil,0,'pmN7'),
    WideNewItem('&Copy Filename',0,false,true,OnCopyLinkClick,0,'pmCopyLink',)
  ],true));
  pmGrid.Items.Add(WideNewSubMenu('Text direction',0,'pmBidiMode',[
    RadioItem(true,WideNewItem('Log default',0,true,true,OnBidiModeLogClick,0,'pmBidiModeLog',)),
    RadioItem(true,WideNewItem('History default',0,false,true,OnBidiModeHistoryClick,0,'pmBidiModeHistory'))
  ],true));
  pmGrid.Items.Add(WideNewSubMenu('ANSI Encoding',0,'pmCodepage',[
    RadioItem(true,WideNewItem('Log default',0,true,true,OnCodepageLogClick,0,'pmCodepageLog',)),
    RadioItem(true,WideNewItem('History default',0,false,true,OnCodepageHistoryClick,0,'pmCodepageHistory'))
  ],true));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN6'));

  miEventsFilter := TTntMenuItem.Create(pmGrid);
  miEventsFilter.Caption := 'Events filter';
  pmGrid.Items.Add(miEventsFilter);

  pmLink := TTntPopupMenu.Create(Grid);
  pmLink.ParentBiDiMode := False;
  pmLink.Items.Add(WideNewItem('Open &Link',0,false,true,OnOpenLinkClick,0,'pmOpenLink'));
  pmLink.Items.Add(WideNewItem('Open Link in New &Window',0,false,true,OnOpenLinkNWClick,0,'pmOpenLinkNW'));
  pmLink.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN4'));
  pmLink.Items.Add(WideNewItem('&Copy Link',0,false,true,OnCopyLinkClick,0,'pmCopyLink'));

  TranslateMenu(pmGrid.Items);
  TranslateMenu(pmLink.Items);

  CreateEventsFilterMenu;
  //SetEventFilter(GetDBInt(hppDBName,'RecentLogFilter',GetShowAllEventsIndex));
  SetEventFilter(GetShowAllEventsIndex);
end;

destructor TExternalGrid.Destroy;
begin
  WriteDBBool(hppDBName,'ExpandLogHeaders',Grid.ExpandHeaders);
  if FSelection <> nil then FreeMem(FSelection);
  Grid.Free;
  Finalize(Items);
  inherited;
end;

function TExternalGrid.GetGridHandle: HWND;
begin
  Result := Grid.CachedHandle;
end;

procedure TExternalGrid.BeginUpdate;
begin
  Grid.BeginUpdate;
end;

procedure TExternalGrid.EndUpdate;
begin
  Grid.EndUpdate;
end;

procedure TExternalGrid.GridItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
const
  Direction: array[false..true] of TMessageTypes = ([mtIncoming],[mtOutgoing]);
var
  PrevTimestamp: DWord;
  Codepage: Cardinal;
begin
  if FUseHistoryCodepage then
    Codepage := Grid.Codepage
  else
    Codepage := Items[Index].Codepage;
  if Items[Index].Custom then begin
    Item.Height := -1;
    Item.Time := Items[Index].CustomEvent.Time;
    Item.MessageType := [mtOther] + Direction[Items[Index].CustomEvent.Sent];
    Item.Text := Items[Index].CustomEvent.Text;
    Item.IsRead := True;
  end else begin
    Item := ReadEvent(Items[Index].hDBEvent,Codepage);
    Item.Bookmarked := BookmarkServer[Items[Index].hContact].Bookmarked[Items[Index].hDBEvent];
  end;
  Item.Proto := Grid.Protocol;
  if Index = 0 then
    Item.HasHeader := IsEventInSession(Item.EventType)
  else begin
    if Items[Index].Custom then
      PrevTimestamp := Items[Index-1].CustomEvent.Time else
      PrevTimestamp := GetEventTimestamp(Items[Index-1].hDBEvent);
    if IsEventInSession(Item.EventType) then
      Item.HasHeader := ((DWord(Item.Time) - PrevTimestamp) > SESSION_TIMEDIFF);
    if (not Item.Bookmarked) and
       (Item.MessageType = Grid.Items[Index-1].MessageType) then
      Item.LinkedToPrev := ((DWord(Item.Time) - PrevTimestamp) < 60);
  end;
  if (not FUseHistoryRTLMode) and (Item.RTLMode <> hppRTLEnable) then
    Item.RTLMode := Items[Index].RTLMode;
  // tabSRMM still doesn't marks events read in case of hpp log is in use...
  //if (FGridMode = gmIEView) and
  if (mtIncoming in Item.MessageType) and
     (MessageTypesToDWord(Item.MessageType) and
      MessageTypesToDWord([mtMessage,mtUrl]) > 0) then begin
    if (not Item.IsRead) then
      PluginLink.CallService(MS_DB_EVENT_MARKREAD,Items[Index].hContact,Items[Index].hDBEvent);
    PluginLink.CallService(MS_CLIST_REMOVEEVENT,Items[Index].hContact,Items[Index].hDBEvent);
  end else
  if (not Item.IsRead) and
     (MessageTypesToDWord(Item.MessageType) and
      MessageTypesToDWord([mtStatus,mtNickChange,mtAvatarChange]) > 0) then begin
    PluginLink.CallService(MS_DB_EVENT_MARKREAD,Items[Index].hContact,Items[Index].hDBEvent);
  end;
end;

procedure TExternalGrid.GridTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
begin
  Text := TimestampToString(Time);
end;

procedure TExternalGrid.GridNameData(Sender: TObject; Index: Integer; var Name: WideString);
begin
  if Name = '' then begin
    if Grid.Protocol = '' then begin
      if Items[Index].hContact = 0 then begin
        Grid.Protocol := 'ICQ';
        FSubProtocol := Grid.Protocol;
      end else
        Grid.Protocol := GetContactProto(Items[Index].hContact,FSubContact,FSubProtocol);
    end;
    if Items[Index].Custom then
      Name := Items[Index].CustomEvent.Nick
    else
    if mtIncoming in Grid.Items[Index].MessageType then begin
      Grid.ContactName := GetContactDisplayName(Items[Index].hContact,Grid.Protocol,true);
      Name := Grid.ContactName;
    end else begin
      Grid.ProfileName := GetContactDisplayName(0, FSubProtocol);
      Name := Grid.ProfileName;
    end;
  end;
end;

procedure TExternalGrid.GridProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
var
  ItemRenderDetails: TItemRenderDetails;
begin
  ZeroMemory(@ItemRenderDetails,SizeOf(ItemRenderDetails));
  ItemRenderDetails.cbSize := SizeOf(ItemRenderDetails);
  // use meta's subcontact info, if available
  //ItemRenderDetails.hContact := Items[Item].hContact;
  ItemRenderDetails.hContact := FSubContact;
  ItemRenderDetails.hDBEvent := Items[Item].hDBEvent;
  // use meta's subcontact info, if available
  //ItemRenderDetails.pProto := PChar(Grid.Items[Item].Proto);
  ItemRenderDetails.pProto := PChar(FSubProtocol);
  ItemRenderDetails.pModule := PChar(Grid.Items[Item].Module);
  ItemRenderDetails.pText := nil;
  ItemRenderDetails.pExtended := PChar(Grid.Items[Item].Extended);
  ItemRenderDetails.dwEventTime := Grid.Items[Item].Time;
  ItemRenderDetails.wEventType := Grid.Items[Item].EventType;
  ItemRenderDetails.IsEventSent := (mtOutgoing in Grid.Items[Item].MessageType);
  if Handle = Grid.InlineRichEdit.Handle then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_INLINE;
  if Grid.IsSelected(Item) then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_SELECTED;
  ItemRenderDetails.bHistoryWindow := IRDHW_EXTERNALGRID;
  PluginLink.NotifyEventHooks(hHppRichEditItemProcess,WPARAM(Handle),LPARAM(@ItemRenderDetails));
end;

procedure TExternalGrid.ScrollToBottom;
begin
  if Grid.State <> gsInline then begin
    Grid.ScrollToBottom;
    Grid.Invalidate;
  end;
end;

procedure TExternalGrid.SetPosition(x, y, cx, cy: Integer);
begin
  Grid.Left := x;
  Grid.Top := y;
  Grid.Width := cx;
  Grid.Height := cy;
  if Grid.HandleAllocated then
    SetWindowPos(Grid.Handle,0,x,y,cx,cy,SWP_SHOWWINDOW);
end;

function TExternalGrid.GetSelection(NoUnicode: Boolean): PChar;
var
  TextW: WideString;
  TextA: AnsiString;
  Source: Pointer;
  Size: integer;
begin
  TextW := Grid.SelectionString;
  if Length(TextW) > 0 then begin
    TextW := TextW+#0;
    if NoUnicode then begin
      TextA := WideToAnsiString(TextW,CP_ACP);
      Source := @TextA[1];
      Size := Length(TextA);
    end else begin
      Source := @TextW[1];
      Size := Length(TextW)*SizeOf(WideChar);
    end;
    ReallocMem(FSelection,Size);
    Move(Source^,FSelection^,Size);
    Result := FSelection;
  end else
    Result := nil;
end;

procedure TExternalGrid.Clear;
begin
  Finalize(Items);
  Grid.Allocate(0);
  //Grid.Repaint;
end;

procedure TExternalGrid.GridUrlClick(Sender: TObject; Item: Integer; URLText: WideString; Button: TMouseButton);
begin
  if URLText= '' then exit;
  if (Button = mbLeft) or (Button = mbMiddle) then
    OpenUrl(URLText,True)
  else
  if Button = mbRight then begin
    SavedLinkUrl := URLText;
    pmLink.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
  end;
end;

procedure TExternalGrid.GridBookmarkClick(Sender: TObject; Item: Integer);
var
  val: boolean;
  hContact,hDBEvent: THandle;
begin
  if Items[Item].Custom then exit;
  hContact := Items[Item].hContact;
  hDBEvent := Items[Item].hDBEvent;
  val := not BookmarkServer[hContact].Bookmarked[hDBEvent];
  BookmarkServer[hContact].Bookmarked[hDBEvent] := val;
end;

procedure TExternalGrid.HMBookmarkChanged(var M: TMessage);
var
  i: integer;
begin
  if M.WParam <> Grid.Contact then exit;
  for i := 0 to Grid.Count-1 do
    if Items[i].hDBEvent = Cardinal(M.LParam) then begin
      Grid.Bookmarked[i] := BookmarkServer[M.WParam].Bookmarked[M.LParam];
      Grid.ResetItem(i);
      Grid.Invalidate;
      exit;
    end;
end;

//procedure TExternalGrid.HMIcons2Changed(var M: TMessage);
//begin
//  Grid.Repaint;
//end;

procedure TExternalGrid.GridSelectRequest(Sender: TObject);
begin
  if (Grid.Selected <> -1) and Grid.IsVisible(Grid.Selected) then
    exit;
  if Grid.Count > 0 then
    Grid.Selected := Grid.BottomItem;
end;

procedure TExternalGrid.GridDblClick(Sender: TObject);
begin
  if Grid.Selected = -1 then exit;
  Grid.EditInline(Grid.Selected);
end;

procedure TExternalGrid.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = VK_INSERT) then Key := Ord('C');
  if IsFormShortCut([pmGrid],Key,Shift) then begin
    Key := 0;
    exit;
  end;
  WasKeyPressed := (Key in [VK_RETURN,VK_ESCAPE]);
end;

procedure TExternalGrid.GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not WasKeyPressed then exit;
  WasKeyPressed := False;
  if (Key = VK_RETURN) and (Shift = []) then begin
    GridDblClick(Grid);
    Key := 0;
  end;
  if (Key = VK_RETURN) and (Shift = [ssCtrl]) then begin
    OnOpenClick(Grid);
    Key := 0;
  end;
  if (Key = VK_ESCAPE) and (Shift = []) then begin
    PostMessage(FParentWindow,WM_CLOSE,0,0);
    Key := 0;
  end;
end;

function TExternalGrid.IsFileEvent(Index: Integer): Boolean;
begin
  Result := (Index <> -1) and (mtFile in Grid.Items[Index].MessageType);
  if Result then begin
    // Auto CP_ACP usage
    SavedLinkUrl := ExtractFileName(Grid.Items[Index].Extended);
    SavedFileDir := ExtractFileDir(Grid.Items[Index].Extended);
  end;
end;

procedure TExternalGrid.GridPopup(Sender: TObject);
var
  GridSelected: Boolean;
begin
  GridSelected := (Grid.Selected <> -1);
  pmGrid.Items[0].Visible := GridSelected and (Grid.State = gsIdle) and not Items[Grid.Selected].Custom;
  pmGrid.Items[1].Visible := MeSpeakEnabled;
  pmGrid.Items[3].Visible := GridSelected;
  pmGrid.Items[4].Visible := GridSelected;
  pmGrid.Items[5].Visible := GridSelected and (Grid.State = gsInline); // works even if not in pseudo-edit
  pmGrid.Items[6].Visible := GridSelected;
  pmGrid.Items[8].Visible := GridSelected and (Grid.State = gsInline);
  pmGrid.Items[9].Visible := GridSelected;
  if GridSelected then begin
    pmGrid.Items[8].Checked := GridOptions.TextFormatting;
    if Grid.State = gsInline then
      pmGrid.Items[3].Enabled := Grid.InlineRichEdit.SelLength > 0 else
      pmGrid.Items[3].Enabled := True;
    pmGrid.Items[9].Enabled := pmGrid.Items[2].Enabled;
  end;
  pmGrid.Items[10].Visible := GridSelected and not Items[Grid.Selected].Custom;
  pmGrid.Items[11].Visible := GridSelected;
  if GridSelected then begin
    if Items[Grid.Selected].Custom then
      pmGrid.Items[11].Visible := False
    else
    if Grid.Items[Grid.Selected].Bookmarked then
      TTntMenuItem(pmGrid.Items[11]).Caption := TranslateWideW('Remove &Bookmark')
    else
      TTntMenuItem(pmGrid.Items[11]).Caption := TranslateWideW('Set &Bookmark');
  end;
  pmGrid.Items[13].Visible := (Grid.SelCount > 1);
  pmGrid.Items[15].Visible := GridSelected and IsFileEvent(Grid.Selected);
  if pmGrid.Items[15].Visible then
    pmGrid.Items[15].Items[1].Visible := (SavedFileDir <> '');
  pmGrid.Items[16].Visible := (Grid.State = gsIdle);
  pmGrid.Items[16].Items[0].Checked := not FUseHistoryRTLMode;
  pmGrid.Items[16].Items[1].Checked := FUseHistoryRTLMode;
  pmGrid.Items[17].Visible := (Grid.State = gsIdle);
  pmGrid.Items[17].Items[0].Checked := not FUseHistoryCodepage;
  pmGrid.Items[17].Items[1].Checked := FUseHistoryCodepage;
  pmGrid.Items[19].Visible := (Grid.State = gsIdle);
  pmGrid.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
end;

procedure TExternalGrid.OnCopyClick(Sender: TObject);
begin
  if Grid.Selected = -1 then exit;
  if Grid.State = gsInline then begin
    if Grid.InlineRichEdit.SelLength = 0 then exit;
    Grid.InlineRichEdit.CopyToClipboard;
  end else begin
    CopyToClip(Grid.FormatSelected(GridOptions.ClipCopyFormat),
      Grid.Handle,Items[Grid.Selected].Codepage);
  end;
end;

procedure TExternalGrid.OnCopyTextClick(Sender: TObject);
var
  cr: TCharRange;
begin
  if Grid.Selected = -1 then exit;
  if Grid.State = gsInline then begin
    Grid.InlineRichEdit.Lines.BeginUpdate;
    Grid.InlineRichEdit.Perform(EM_EXGETSEL,0,LPARAM(@cr));
    Grid.InlineRichEdit.SelectAll;
    Grid.InlineRichEdit.CopyToClipboard;
    Grid.InlineRichEdit.Perform(EM_EXSETSEL,0,LPARAM(@cr));
    Grid.InlineRichEdit.Lines.EndUpdate;
  end else
    CopyToClip(Grid.FormatSelected(GridOptions.ClipCopyTextFormat),
      Grid.Handle,Items[Grid.Selected].Codepage);
end;

procedure TExternalGrid.OnSelectAllClick(Sender: TObject);
begin
  if Grid.State = gsInline then begin
    if Grid.Selected = -1 then exit;
    Grid.InlineRichEdit.SelectAll;
  end else begin
    Grid.SelectAll;
  end;
end;

procedure TExternalGrid.OnDeleteClick(Sender: TObject);
begin
  if Grid.SelCount = 0 then exit;
  if Grid.SelCount > 1 then begin
    if HppMessageBox(FParentWindow,WideFormat(
      TranslateWideW('Do you really want to delete selected items (%.0f)?'),[Grid.SelCount/1]),
      TranslateWideW('Delete Selected'),
      MB_YESNOCANCEL or MB_DEFBUTTON1 or MB_ICONQUESTION) <> IDYES then exit;
  end else begin
    if HppMessageBox(FParentWindow,
      TranslateWideW('Do you really want to delete selected item?'),
      TranslateWideW('Delete'),
      MB_YESNOCANCEL or MB_DEFBUTTON1 or MB_ICONQUESTION) <> IDYES then exit;
  end;
  SetSafetyMode(False);
  try
    FGridState := gsDelete;
    Grid.DeleteSelected;
  finally
    FGridState := gsIdle;
    SetSafetyMode(True);
  end;
end;

procedure TExternalGrid.OnTextFormattingClick(Sender: TObject);
begin
  if (Grid.Selected = -1) or (Grid.State <> gsInline) then exit;
  GridOptions.TextFormatting := not GridOptions.TextFormatting;
end;

procedure TExternalGrid.OnReplyQuotedClick(Sender: TObject);
begin
  if Grid.Selected = -1 then exit;
  if Grid.State = gsInline then begin
    if Grid.InlineRichEdit.SelLength = 0 then exit;
    SendMessageTo(Items[Grid.Selected].hContact,
      Grid.FormatSelected(GridOptions.ReplyQuotedTextFormat));
  end else begin
    //if (hContact = 0) or (hg.SelCount = 0) then exit;
    SendMessageTo(Items[Grid.Selected].hContact,
      Grid.FormatSelected(GridOptions.ReplyQuotedFormat));
  end;
end;

procedure TExternalGrid.OnBookmarkClick(Sender: TObject);
var
  val: boolean;
  hContact,hDBEvent: THandle;
begin
  if Grid.Selected = -1 then exit;
  if Items[Grid.Selected].Custom then exit;
  hContact := Items[Grid.Selected].hContact;
  hDBEvent := Items[Grid.Selected].hDBEvent;
  val := not BookmarkServer[hContact].Bookmarked[hDBEvent];
  BookmarkServer[hContact].Bookmarked[hDBEvent] := val;
end;

procedure TExternalGrid.OnOpenClick(Sender: TObject);
var
  oep: TOpenEventParams;
begin
  if Grid.Selected = -1 then exit;
  if Items[Grid.Selected].Custom then exit;
  oep.cbSize := SizeOf(oep);
  oep.hContact := Items[Grid.Selected].hContact;
  oep.hDBEvent := Items[Grid.Selected].hDBEvent;
  oep.pPassword := nil;
  PluginLink.CallService(MS_HPP_OPENHISTORYEVENT,WPARAM(@oep),0);
end;

procedure TExternalGrid.GridInlineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if IsFormShortCut([pmGrid],Key,Shift) then begin
    Key := 0;
    exit;
  end;
end;

procedure TExternalGrid.OnOpenLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  OpenUrl(SavedLinkUrl,False);
  SavedLinkUrl := '';
end;

procedure TExternalGrid.GridItemDelete(Sender: TObject; Index: Integer);
begin
  if (FGridState = gsDelete) and
     (Items[Index].hDBEvent <> 0) and
     (not Items[Index].Custom) then
    PluginLink.CallService(MS_DB_EVENT_DELETE,Items[Index].hContact,Items[Index].hDBEvent);
  if Index <> High(Items) then begin
    Finalize(Items[Index]);
    Move(Items[Index+1],Items[Index],(Length(Items)-Index-1)*SizeOf(Items[0]));
    ZeroMemory(@Items[High(Items)],SizeOf(Items[0]));
    // reset has_header and linked_to_pervous_messages fields
    Grid.ResetItem(Index);
  end;
  SetLength(Items,Length(Items)-1);
  //Application.ProcessMessages;
end;

procedure TExternalGrid.OnOpenLinkNWClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  OpenUrl(SavedLinkUrl,True);
  SavedLinkUrl := '';
end;

procedure TExternalGrid.OnCopyLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  CopyToClip(SavedLinkUrl,Grid.Handle,CP_ACP);
  SavedLinkUrl := '';
end;

procedure TExternalGrid.OnBidiModeLogClick(Sender: TObject);
begin
  UseHistoryRTLMode := False;
  WriteDBBool(Grid.Contact,Grid.Protocol,'UseHistoryRTLMode',UseHistoryRTLMode);
end;

procedure TExternalGrid.OnBidiModeHistoryClick(Sender: TObject);
begin
  UseHistoryRTLMode := True;
  WriteDBBool(Grid.Contact,Grid.Protocol,'UseHistoryRTLMode',UseHistoryRTLMode);
end;

procedure TExternalGrid.SetUseHistoryRTLMode(const Value: Boolean);
begin
  if FUseHistoryRTLMode = Value then exit;
  FUseHistoryRTLMode := Value;
  if FUseHistoryRTLMode then
    Grid.RTLMode := GetContactRTLModeTRTL(Grid.Contact,Grid.Protocol)
  else
    Grid.RTLMode := FExternalRTLMode;
end;

procedure TExternalGrid.OnCodepageLogClick(Sender: TObject);
begin
  UseHistoryCodepage := False;
  WriteDBBool(Grid.Contact,Grid.Protocol,'UseHistoryCodepage',UseHistoryCodepage);
end;

procedure TExternalGrid.OnCodepageHistoryClick(Sender: TObject);
begin
  UseHistoryCodepage := True;
  WriteDBBool(Grid.Contact,Grid.Protocol,'UseHistoryCodepage',UseHistoryCodepage);
end;

procedure TExternalGrid.SetUseHistoryCodepage(const Value: Boolean);
begin
  if FUseHistoryCodepage = Value then exit;
  FUseHistoryCodepage := Value;
  if FUseHistoryCodepage then
    Grid.Codepage := GetContactCodePage(Grid.Contact,Grid.Protocol)
  else
    Grid.Codepage := FExternalCodepage;
end;

procedure TExternalGrid.SetGroupLinked(const Value: Boolean);
begin
  if Grid.GroupLinked = Value then exit;
  Grid.GroupLinked := Value;
end;

procedure TExternalGrid.SetShowHeaders(const Value: Boolean);
begin
  if Grid.ShowHeaders = Value then exit;
  Grid.ShowHeaders := Value;
end;

procedure TExternalGrid.SetShowBookmarks(const Value: Boolean);
begin
  if Grid.ShowBookmarks = Value then exit;
  Grid.ShowBookmarks := Value;
end;

procedure TExternalGrid.HMEventDeleted(var M: TMessage);
var
  i: integer;
begin
  if Grid.State = gsDelete then exit;
  if Grid.Contact <> M.WParam then exit;
  for i := 0 to Grid.Count - 1 do begin
    if (Items[i].hDBEvent = Cardinal(M.LParam)) then begin
      Grid.Delete(i);
      exit;
    end;
  end;
end;

procedure TExternalGrid.HMNickChanged(var M: TMessage);
begin
  if FSubProtocol = '' then exit;
  Grid.BeginUpdate;
  if M.WParam = 0 then
    Grid.ProfileName := GetContactDisplayName(0, FSubProtocol)
  else
  if Grid.Contact = M.WParam then begin
    Grid.ProfileName := GetContactDisplayName(0, FSubProtocol);
    Grid.ContactName := GetContactDisplayName(Grid.Contact,Grid.Protocol,True)
  end;
  Grid.EndUpdate;
  Grid.Invalidate;
end;

procedure TExternalGrid.HMMetaDefaultChanged(var M: TMessage);
var
  newSubContact: THandle;
  newSubProtocol: String;
begin
  if Grid.Contact <> M.WParam then exit;
  GetContactProto(Grid.Contact,newSubContact,newSubProtocol);
  if (FSubContact <> newSubContact) or (FSubProtocol <> newSubProtocol) then begin
    Grid.BeginUpdate;
    FSubContact := newSubContact;
    FSubProtocol := newSubProtocol;
    Grid.ProfileName := GetContactDisplayName(0, FSubProtocol);
    Grid.ContactName := GetContactDisplayName(Grid.Contact,Grid.Protocol,True);
    Grid.GridUpdate([guOptions]);
    Grid.EndUpdate;
    //Grid.Invalidate;
  end;
end;

procedure TExternalGrid.OnSaveSelectedClick(Sender: TObject);
var
  t: String;
  SaveFormat: TSaveFormat;
begin
  if Grid.Selected = -1 then exit;
  RecentFormat := TSaveFormat(GetDBInt(hppDBName,'ExportFormat',0));
  SaveFormat := RecentFormat;
  if not Assigned(SaveDialog) then begin
    SaveDialog := TSaveDialog.Create(Grid);
    SaveDialog.Title := Translate('Save History');
    SaveDialog.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofShareAware, ofEnableSizing];
  end;
  PrepareSaveDialog(SaveDialog,SaveFormat,True);
  t := Translate('Partial History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(Grid.ProfileName,CP_ACP),WideToAnsiString(Grid.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  for SaveFormat := High(SaveFormats) downto Low(SaveFormats) do
    if SaveDialog.FilterIndex = SaveFormats[SaveFormat].Index then
      break;
  if SaveFormat <> sfAll then RecentFormat := SaveFormat;
  Grid.SaveSelected(SaveDialog.Files[0],SaveFormat);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure TExternalGrid.SaveSelected;
begin
  OnSaveSelectedClick(Self);
end;

procedure TExternalGrid.GridXMLData(Sender: TObject; Index: Integer; var Item: TXMLItem);
var
  tmp: string;
  dt: TDateTime;
  mes: WideString;
begin
  dt := TimestampToDateTime(Grid.Items[Index].Time);
  Item.Time := MakeTextXMLedA(FormatDateTime('hh:mm:ss',dt));
  Item.Date := MakeTextXMLedA(FormatDateTime('yyyy-mm-dd',dt));

  Item.Contact := UTF8Encode(MakeTextXMLedW(Grid.ContactName));
  if mtIncoming in Grid.Items[Index].MessageType then
    Item.From := Item.Contact
  else
    Item.From := '&ME;';

  Item.EventType := '&'+GetEventRecord(Grid.Items[Index]).XML+';';

  mes := Grid.Items[Index].Text;
  if GridOptions.RawRTFEnabled and IsRTF(mes) then begin
    Grid.ApplyItemToRich(Index);
    mes := GetRichString(Grid.RichEdit.Handle,False);
  end;
  if GridOptions.BBCodesEnabled then
    mes := DoStripBBCodes(mes);
  Item.Mes := UTF8Encode(MakeTextXMLedW(mes));

  if mtFile in Grid.Items[Index].MessageType then begin
    tmp := Grid.Items[Index].Extended;
    if tmp = '' then Item.FileName := '&UNK;'
                else Item.FileName := UTF8Encode(MakeTextXMLedA(tmp));
  end else
  if mtUrl in Grid.Items[Index].MessageType then begin
    tmp := Grid.Items[Index].Extended;
    if tmp = '' then Item.Url := '&UNK;'
                else Item.Url := UTF8Encode(MakeTextXMLedA(tmp));
  end else
  if mtAvatarChange in Grid.Items[Index].MessageType then begin
    tmp := Grid.Items[Index].Extended;
    if tmp = '' then Item.FileName := '&UNK;'
                else Item.FileName := UTF8Encode(MakeTextXMLedA(tmp));
  end;

  {2.8.2004 OXY: Change protocol guessing order. Now
  first use protocol name, then, if missing, use module }

  Item.Protocol := Grid.Items[Index].Proto;
  if Item.Protocol = '' then
    Item.Protocol := MakeTextXMLedA(Grid.Items[Index].Module);
  if Item.Protocol = '' then Item.Protocol := '&UNK;';

  if mtIncoming in Grid.Items[Index].MessageType then
    Item.ID := GetContactID(Grid.Contact, Grid.Protocol, true)
  else
    Item.ID := GetContactID(0, Grid.Protocol);
  if Item.ID = '' then
    Item.ID := '&UNK;'
  else
    Item.ID := MakeTextXMLedA(Item.ID);
end;

procedure TExternalGrid.GridMCData(Sender: TObject; Index: Integer; var Item: TMCItem; Stage: TSaveStage);
var
  DBEventInfo: TDBEventInfo;
  hDBEvent:DWord;
  DataOffset: PChar;
  TextUTF: AnsiString;
begin
  if Stage = ssInit then begin
    Item.Size := 0;
    if Items[Index].Custom then begin
      ZeroMemory(@DBEventInfo,SizeOf(DBEventInfo));
      DBEventInfo.cbSize := SizeOf(DBEventInfo);
      DBEventInfo.timestamp := Items[Index].CustomEvent.Time;
      DBEventInfo.flags := DBEF_READ or DBEF_UTF;
      if Items[Index].CustomEvent.Sent then
        DBEventInfo.flags := DBEventInfo.flags or DBEF_SENT;
      DBEventInfo.eventType := EVENTTYPE_MESSAGE;
      TextUTF := UTF8Encode(Items[Index].CustomEvent.Text)+#0;
      DBEventInfo.cbBlob := Length(TextUTF)+1;
      DBEventInfo.pBlob := Pointer(PChar(TextUTF));
      Item.Size := DBEventInfo.cbSize + DBEventInfo.cbBlob;
    end else begin
      hDBEvent := Items[Index].hDBEvent;
      if hDBEvent <> 0 then begin
        DBEventInfo := GetEventInfo(hDBEvent);
        DBEventInfo.szModule := nil;
        DBEventInfo.flags := DBEventInfo.flags and not DBEF_FIRST;
        Item.Size := DBEventInfo.cbSize + DBEventInfo.cbBlob;
      end;
    end;
    if Item.Size > 0 then begin
      GetMem(Item.Buffer,Item.Size);
      DataOffset := PChar(Item.Buffer) + DBEventInfo.cbSize;
      Move(DBEventInfo,Item.Buffer^,DBEventInfo.cbSize);
      Move(DBEventInfo.pBlob^,DataOffset^,DBEventInfo.cbBlob);
    end;
  end else
  if Stage = ssDone then begin
    if Item.Size > 0 then
      FreeMem(Item.Buffer,Item.Size);
  end;
end;

procedure TExternalGrid.SetEventFilter(FilterIndex: Integer = -1);
var
  i,fi: Integer;
  ShowAllEventsIndex: Integer;
begin
  ShowAllEventsIndex := GetShowAllEventsIndex;
  if FilterIndex = -1 then begin
    fi := miEventsFilter.Tag+1;
    if fi > High(hppEventFilters) then fi := 0;
  end else begin
    fi := FilterIndex;
    if fi > High(hppEventFilters) then fi := ShowAllEventsIndex;
  end;
  miEventsFilter.Tag := fi;
  for i := 0 to miEventsFilter.Count-1 do
    miEventsFilter[i].Checked := (miEventsFilter[i].Tag = fi);
  if fi = ShowAllEventsIndex then
    Grid.TxtNoSuch := TranslateWideW('No such items') else
    Grid.TxtNoSuch := WideFormat(TranslateWideW('No "%s" items'),[hppEventFilters[fi].Name]);
  //Grid.ShowHeaders := mtMessage in hppEventFilters[fi].Events;
  Grid.Filter := hppEventFilters[fi].Events;
end;

procedure TExternalGrid.HMFiltersChanged(var M: TMessage);
begin
  CreateEventsFilterMenu;
  SetEventFilter(GetShowAllEventsIndex);
  //WriteDBInt(hppDBName,'RecentLogFilter',miEventsFilter.Tag);
end;

procedure TExternalGrid.OnEventsFilterItemClick(Sender: TObject);
begin
  SetEventFilter(TTntMenuItem(Sender).Tag);
  //WriteDBInt(hppDBName,'RecentLogFilter',miEventsFilter.Tag);
end;

procedure TExternalGrid.CreateEventsFilterMenu;
var
  i: Integer;
  mi: TTntMenuItem;
  ShowAllEventsIndex: Integer;
begin
  ShowAllEventsIndex := GetShowAllEventsIndex;
  miEventsFilter.Clear;
  for i := 0 to Length(hppEventFilters) - 1 do begin
    mi := TTntMenuItem.Create(pmGrid);
    mi.Caption := Tnt_WideStringReplace(hppEventFilters[i].Name,'&','&&',[rfReplaceAll]);
    mi.GroupIndex := 1;
    mi.RadioItem := True;
    mi.Tag := i;
    mi.OnClick := OnEventsFilterItemClick;
    if i = ShowAllEventsIndex then mi.Default := True;
    miEventsFilter.Insert(i,mi);
  end;
end;

procedure TExternalGrid.OnOpenFileFolderClick(Sender: TObject);
begin
  if SavedFileDir = '' then exit;
  ShellExecute(0,'open',PChar(SavedFileDir),nil,nil,SW_SHOW);
  SavedFileDir := '';
end;

procedure TExternalGrid.OnBrowseReceivedFilesClick(Sender: TObject);
var
  Path: Array[0..MAX_PATH] of Char;
begin
  if Grid.Selected = -1 then exit;
  PluginLink.CallService(MS_FILE_GETRECEIVEDFILESFOLDER,Items[Grid.Selected].hContact,LPARAM(@Path));
  ShellExecute(0,'open',Path,nil,nil,SW_SHOW);
end;

procedure TExternalGrid.OnSpeakMessage(Sender: TObject);
var
  mesW: WideString;
  mesA: AnsiString;
  hContact: THandle;
begin
  if not MeSpeakEnabled then exit;
  if Grid.Selected = -1 then exit;
  //if Items[Grid.Selected].Custom then exit;
  hContact := Items[Grid.Selected].hContact;
  mesW := Grid.Items[Grid.Selected].Text;
  if GridOptions.BBCodesEnabled then
      mesW := DoStripBBCodes(mesW);
  if Boolean(PluginLink.ServiceExists(MS_SPEAK_SAY_W)) then
    PluginLink.CallService(MS_SPEAK_SAY_W,hContact,LPARAM(PWideChar(mesW)))
  else begin
    mesA := WideToAnsiString(mesW,Items[Grid.Selected].Codepage);
    PluginLink.CallService(MS_SPEAK_SAY_A,hContact,LPARAM(PChar(mesA)));
  end;
end;

end.
