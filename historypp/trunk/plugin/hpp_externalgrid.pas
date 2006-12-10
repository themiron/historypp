unit hpp_externalgrid;

interface

uses
  Windows, Classes, Controls, Forms, Graphics, Messages, SysUtils,
  m_api, m_globaldefs,
  hpp_global, hpp_events, hpp_contacts, hpp_services, hpp_forms, hpp_bookmarks,
  hpp_richedit, hpp_messages, hpp_eventfilters, hpp_database,
  HistoryGrid,
  RichEdit, Menus, TntMenus;

type
  TExGridMode = (gmNative, gmIEView);

  TExtItem = record
    hDBEvent: THandle;
    hContact: THandle;
    Codepage: THandle;
    RTLMode: TRTLMode;
  end;

  TExternalGrid = class(TObject)
  private
    Items: array of TExtItem;
    Grid: THistoryGrid;
    FParentWindow: HWND;
    FSelection: Pointer;
    SavedLinkUrl: AnsiString;
    pmGrid: TTntPopupMenu;
    pmLink: TTntPopupMenu;
    WasKeyPressed: Boolean;
    FGridMode: TExGridMode;
    FUseHistoryRTLMode: Boolean;
    FExternalRTLMode: TRTLMode;
    FUseHistoryCodepage: Boolean;
    FExternalCodepage: Cardinal;
    FGridState: TGridState;

    function GetGridHandle: HWND;
    procedure SetUseHistoryRTLMode(const Value: Boolean);
    procedure SetUseHistoryCodepage(const Value: Boolean);
    procedure SetGroupLinked(const Value: Boolean);
  protected
    procedure GridItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
    procedure GridTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
    procedure GridNameData(Sender: TObject; Index: Integer; var Name: WideString);
    procedure GridProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
    procedure GridUrlClick(Sender: TObject; Item: Integer; Url: String);
    procedure GridBookmarkClick(Sender: TObject; Item: Integer);
    procedure GridSelectRequest(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridPopup(Sender: TObject);
    procedure GridUrlPopup(Sender: TObject; Item: Integer; Url: String);
    procedure GridInlineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridItemDelete(Sender: TObject; Index: Integer);
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
  public
    constructor Create(AParentWindow: HWND; ControlID: Cardinal = 0);
    destructor Destroy; override;
    procedure AddEvent(hContact, hDBEvent: Cardinal; Codepage: Integer; RTL: boolean);
    procedure SetPosition(x,y,cx,cy: Integer);
    procedure ScrollToBottom;
    function GetSelection(NoUnicode: Boolean): PChar;
    procedure Clear;
    property ParentWindow: HWND read FParentWindow;
    property GridHandle: HWND read GetGridHandle;
    property GridMode: TExGridMode read FGridMode write FGridMode;
    property UseHistoryRTLMode: Boolean read FUseHistoryRTLMode write SetUseHistoryRTLMode;
    property UseHistoryCodepage: Boolean read FUseHistoryCodepage write SetUseHistoryCodepage;
    function Perform(Msg: Cardinal; WParam, LParam: Longint): Longint;
    procedure HMBookmarkChanged(var M: TMessage); message HM_NOTF_BOOKMARKCHANGED;
    procedure HMIcons2Changed(var M: TMessage); message HM_NOTF_ICONS2CHANGED;
    procedure HMEventDeleted(var M: TMessage); message HM_MIEV_EVENTDELETED;
    procedure BeginUpdate;
    procedure EndUpdate;
    property GroupLinked: Boolean write SetGroupLinked;
  end;

implementation

uses hpp_options,hpp_sessionsthread;

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

procedure TExternalGrid.AddEvent(hContact, hDBEvent: Cardinal; Codepage: Integer; RTL: boolean);
var
  RTLMode: TRTLMode;
begin
  SetLength(Items,Length(Items)+1);
  Items[High(Items)].hDBEvent := hDBEvent;
  Items[High(Items)].hContact := hContact;
  Items[High(Items)].Codepage := Codepage;
  if RTL then RTLMode := hppRTLEnable
         else RTLMode := hppRTLDefault;
  Items[High(Items)].RTLMode := RTLMode;
  if Grid.Contact <> hContact then begin
    Grid.Contact := hContact;
    Grid.Protocol := GetContactProto(hContact);
    FExternalRTLMode := RTLMode;
    UseHistoryRTLMode := GetDBBool(Grid.Contact,Grid.Protocol,'UseHistoryRTLMode',FUseHistoryRTLMode);
    FExternalCodepage := Codepage;
    UseHistoryRTLMode := GetDBBool(Grid.Contact,Grid.Protocol,'UseHistoryCodepage',FUseHistoryCodepage);
  end;
  // comment or we'll get rerendering the whole grid
  //if Grid.Codepage <> Codepage then Grid.Codepage := Codepage;
  Grid.Allocate(Length(Items),False);
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

  Grid := THistoryGrid.CreateParented(ParentWindow);

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
  Grid.BorderStyle := bsSingle;
  Grid.BorderWidth := 0;
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
  Grid.OnUrlPopup := GridUrlPopup;
  Grid.OnInlineKeyDown := GridInlineKeyDown;
  Grid.OnItemDelete := GridItemDelete;

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

  Grid.GroupLinked := GetDBBool(hppDBName,'GroupLogItems',false);

  pmGrid := TTntPopupMenu.Create(Grid);
  pmGrid.ParentBiDiMode := False;
  pmGrid.Items.Add(WideNewItem('Sh&ow in history',0,false,true,OnOpenClick,0,'pmOpen'));
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
  pmGrid.Items.Add(WideNewSubMenu('Text direction',0,'pmBidiMode',[
    RadioItem(true,WideNewItem('Log default',0,true,true,OnBidiModeLogClick,0,'pmBidiModeLog',)),
    RadioItem(true,WideNewItem('History default',0,false,true,OnBidiModeHistoryClick,0,'pmBidiModeHistory'))
  ],true));
  pmGrid.Items.Add(WideNewSubMenu('ANSI Encoding',0,'pmCodepage',[
    RadioItem(true,WideNewItem('Log default',0,true,true,OnCodepageLogClick,0,'pmCodepageLog',)),
    RadioItem(true,WideNewItem('History default',0,false,true,OnCodepageHistoryClick,0,'pmCodepageHistory'))
  ],true));

  pmLink := TTntPopupMenu.Create(Grid);
  pmLink.ParentBiDiMode := False;
  pmLink.Items.Add(WideNewItem('Open &Link',0,false,true,OnOpenLinkClick,0,'pmOpenLink'));
  pmLink.Items.Add(WideNewItem('Open Link in New &Window',0,false,true,OnOpenLinkNWClick,0,'pmOpenLinkNW'));
  pmLink.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN4'));
  pmLink.Items.Add(WideNewItem('&Copy Link',0,false,true,OnCopyLinkClick,0,'pmCopyLink'));

  TranslateMenu(pmGrid.Items);
  TranslateMenu(pmLink.Items);
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
  Result := Grid.Handle;
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
var
  PrevTimestamp: DWord;
begin
  if FUseHistoryCodepage then
    Item := ReadEvent(Items[Index].hDBEvent,Grid.Codepage)
  else
    Item := ReadEvent(Items[Index].hDBEvent,Items[Index].Codepage);
  Item.Proto := Grid.Protocol;
  Item.Bookmarked := BookmarkServer[Items[Index].hContact].Bookmarked[Items[Index].hDBEvent];
  if Index = 0 then begin
    Item.HasHeader := True;
  end else begin
    PrevTimestamp := GetEventTimestamp(Items[Index-1].hDBEvent);
    if IsEventInSession(Item.EventType) then
      Item.HasHeader := ((DWord(Item.Time) - PrevTimestamp) > SESSION_TIMEDIFF);
    if (Item.MessageType = Grid.Items[Index-1].MessageType) then
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
      if Items[Index].hContact = 0 then Grid.Protocol := 'ICQ'
      else Grid.Protocol := GetContactProto(Items[Index].hContact);
    end;
    if mtIncoming in Grid.Items[Index].MessageType then begin
      Grid.ContactName := GetContactDisplayName(Items[Index].hContact,Grid.Protocol,true);
      Name := Grid.ContactName;
    end else begin
      Grid.ProfileName := GetContactDisplayName(0, Grid.Protocol);
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
  ItemRenderDetails.hContact := Items[Item].hContact;
  ItemRenderDetails.hDBEvent := Items[Item].hDBEvent;
  ItemRenderDetails.pProto := PChar(Grid.Items[Item].Proto);
  ItemRenderDetails.pModule := PChar(Grid.Items[Item].Module);
  ItemRenderDetails.pText := nil;
  ItemRenderDetails.pExtended := PChar(Grid.Items[Item].Extended);
  ItemRenderDetails.dwEventTime := Grid.Items[Item].Time;
  ItemRenderDetails.wEventType := Grid.Items[Item].EventType;
  ItemRenderDetails.IsEventSent := (mtOutgoing in Grid.Items[Item].MessageType);
  if Grid.IsSelected(Item) then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_SELECTED;
  ItemRenderDetails.bHistoryWindow := IRDHW_EXTERNALGRID;
  PluginLink.NotifyEventHooks(hHppRichEditItemProcess,WPARAM(Handle),LPARAM(@ItemRenderDetails));
end;

procedure TExternalGrid.ScrollToBottom;
begin
  if Grid.State <> gsInline then begin
    Grid.ScrollToBottom;
    Grid.Repaint;
  end;
end;

procedure TExternalGrid.SetPosition(x, y, cx, cy: Integer);
begin
  Grid.Left := x;
  Grid.Top := y;
  Grid.Width := cx;
  Grid.Height := cy;
  SetWindowPos(Grid.Handle,0,x,y,cx,cy,SWP_SHOWWINDOW);
end;

function TExternalGrid.GetSelection(NoUnicode: Boolean): PChar;
var
  TextW: WideString;
  TextA: AnsiString;
  Source: Pointer;
  Size: integer;
begin
  if Grid.Count = 0 then exit;
  if Grid.State = gsInline then
    TextW := GetRichString(Grid.InlineRichEdit.Handle,True)
  else
  if Grid.Focused and (Grid.Selected <> -1) then
    TextW := Grid.FormatSelected(Grid.Options.ClipCopyFormat)
  else
    TextW := '';
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

procedure TExternalGrid.GridUrlClick(Sender: TObject; Item: Integer; Url: String);
var
  bNewWindow: Integer;
begin
  if Url= '' then exit;
  bNewWindow := 0; // no, use existing window
  PluginLink.CallService(MS_UTILS_OPENURL,bNewWindow,Longint(Pointer(@Url[1])));
end;

procedure TExternalGrid.GridBookmarkClick(Sender: TObject; Item: Integer);
var
  val: boolean;
  hContact,hDBEvent: THandle;
begin
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
    if Items[i].hDBEvent = M.LParam then begin
      Grid.Bookmarked[i] := BookmarkServer[M.WParam].Bookmarked[M.LParam];
      exit;
    end;
end;

procedure TExternalGrid.HMIcons2Changed(var M: TMessage);
begin
  Grid.Repaint;
end;

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

procedure TExternalGrid.GridPopup(Sender: TObject);
begin
  pmGrid.Items[0].Visible := (Grid.State = gsIdle);
  pmGrid.Items[4].Visible := (Grid.State = gsInline);
  pmGrid.Items[7].Visible := (Grid.State = gsInline);
  pmGrid.Items[7].Checked := GridOptions.TextFormatting;
  if Grid.State = gsInline then
    pmGrid.Items[2].Enabled := Grid.InlineRichEdit.SelLength > 0
  else
    pmGrid.Items[2].Enabled := True;
  pmGrid.Items[8].Enabled := pmGrid.Items[2].Enabled;
  if Grid.Selected <> -1 then begin
    if Grid.Items[Grid.Selected].Bookmarked then
      pmGrid.Items[10].Caption := TranslateWideW('Remove &Bookmark')
    else
      pmGrid.Items[10].Caption := TranslateWideW('Set &Bookmark');
  end;
  pmGrid.Items[12].Visible := (Grid.State = gsIdle);
  pmGrid.Items[12].Items[0].Checked := not FUseHistoryRTLMode;
  pmGrid.Items[12].Items[1].Checked := FUseHistoryRTLMode;
  pmGrid.Items[13].Visible := (Grid.State = gsIdle);
  pmGrid.Items[13].Items[0].Checked := not FUseHistoryCodepage;
  pmGrid.Items[13].Items[1].Checked := FUseHistoryCodepage;
  pmGrid.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
end;

procedure TExternalGrid.OnCopyClick(Sender: TObject);
begin
  if Grid.Selected = -1 then exit;
  if Grid.State = gsInline then begin
    if Grid.InlineRichEdit.SelLength = 0 then exit;
    Grid.InlineRichEdit.CopyToClipboard;
  end else begin
    CopyToClip(Grid.FormatSelected(Grid.Options.ClipCopyFormat),
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
    CopyToClip(Grid.FormatSelected(Grid.Options.ClipCopyTextFormat),
      Grid.Handle,Items[Grid.Selected].Codepage);
end;

procedure TExternalGrid.OnSelectAllClick(Sender: TObject);
begin
  if (Grid.Selected = -1) or (Grid.State <> gsInline) then exit;
  Grid.InlineRichEdit.SelectAll;
end;

procedure TExternalGrid.OnDeleteClick(Sender: TObject);
var
  OldSelMode: Boolean;
begin
  if Grid.SelCount = 0 then exit;
  if Grid.SelCount > 1 then begin
    if HppMessageBox(FParentWindow,
      WideFormat(TranslateWideW('Do you really want to delete selected items (%.0f)?'),
      [Grid.SelCount/1]), TranslateWideW('Delete Selected'),
      MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = IDNO then exit;
  end else begin
    if HppMessageBox(FParentWindow, TranslateWideW('Do you really want to delete selected item?'),
    TranslateWideW('Delete'), MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = IDNO then exit;
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
      Grid.FormatSelected(DEFFORMAT_REPLYQUOTEDTEXT));
  end else begin
    //if (hContact = 0) or (hg.SelCount = 0) then exit;
    SendMessageTo(Items[Grid.Selected].hContact,
      Grid.FormatSelected(Grid.Options.ReplyQuotedFormat));
  end;
end;

procedure TExternalGrid.OnBookmarkClick(Sender: TObject);
var
  val: boolean;
  hContact,hDBEvent: THandle;
begin
  if Grid.Selected = -1 then exit;
  hContact := Items[Grid.Selected].hContact;
  hDBEvent := Items[Grid.Selected].hDBEvent;
  val := not BookmarkServer[hContact].Bookmarked[hDBEvent];
  BookmarkServer[hContact].Bookmarked[hDBEvent] := val;
end;

procedure TExternalGrid.OnOpenClick(Sender: TObject);
var
  hContact,hDBEvent: THandle;
  oep: TOpenEventParams;
begin
  if Grid.Selected = -1 then exit;
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

procedure TExternalGrid.GridUrlPopup(Sender: TObject; Item: Integer; Url: String);
begin
  SavedLinkUrl := Url;
  pmLink.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
end;

procedure TExternalGrid.OnOpenLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  PluginLink.CallService(MS_UTILS_OPENURL,0,Integer(Pointer(@SavedLinkUrl[1])));
  SavedLinkUrl := '';
end;

procedure TExternalGrid.GridItemDelete(Sender: TObject; Index: Integer);
var
  idx: Integer;
  hDBEvent: DWord;
begin
  if (FGridState = gsDelete) and (Items[Index].hDBEvent <> 0) then
    PluginLink.CallService(MS_DB_EVENT_DELETE,Items[Index].hContact,Items[Index].hDBEvent);
  if Index < Length(Items) then
    Move(Items[Index+1],Items[Index],(Length(Items)-Index-1)*SizeOf(Items[0]));
  SetLength(Items,Length(Items)-1);
  //Application.ProcessMessages;
end;

procedure TExternalGrid.OnOpenLinkNWClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  PluginLink.CallService(MS_UTILS_OPENURL,1,Integer(Pointer(@SavedLinkUrl[1])));
  SavedLinkUrl := '';
end;

procedure TExternalGrid.OnCopyLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  CopyToClip(AnsiToWideString(SavedLinkUrl,CP_ACP),Grid.Handle,CP_ACP);
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

procedure TExternalGrid.HMEventDeleted(var M: TMessage);
var
  i: integer;
begin
  if Grid.State = gsDelete then exit;
  if Grid.Contact <> Cardinal(M.WParam) then exit;
  for i := 0 to Grid.Count - 1 do begin
    if (Items[i].hDBEvent = M.LParam) then begin
      Grid.Delete(i);
      exit;
    end;
  end;
end;

end.
