unit hpp_externalgrid;

interface

uses
  Windows, Classes, Controls, Forms, Graphics, Messages,
  m_api, m_globaldefs,
  hpp_global, hpp_events, hpp_contacts, hpp_services, hpp_forms, hpp_bookmarks,
  hpp_richedit, hpp_messages, hpp_eventfilters,
  HistoryGrid,
  RichEdit, Menus, TntMenus;

type
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
    FSelection: AnsiString;
    SavedLinkUrl: AnsiString;
    pmGrid: TTntPopupMenu;
    pmLink: TTntPopupMenu;
    function GetGridHandle: HWND;
  protected
    procedure GridItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
    procedure GridTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
    procedure GridNameData(Sender: TObject; Index: Integer; var Name: WideString);
    procedure GridProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
    procedure GridUrlClick(Sender: TObject; Item: Integer; Url: String);
    procedure GridBookmarkClick(Sender: TObject; Item: Integer);
    procedure GridKillFocus(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridForbiddenChar(Sender: TObject; var Char: WideChar; Shift: TShiftState);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridPopup(Sender: TObject);
    procedure GridUrlPopup(Sender: TObject; Item: Integer; Url: String);
    procedure GridInlineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure OnCopyClick(Sender: TObject);
    procedure OnCopyTextClick(Sender: TObject);
    procedure OnSelectAllClick(Sender: TObject);
    procedure OnTextFormattingClick(Sender: TObject);
    procedure OnReplyQuotedClick(Sender: TObject);
    procedure OnBookmarkClick(Sender: TObject);
    procedure OnOpenLinkClick(Sender: TObject);
    procedure OnOpenLinkNWClick(Sender: TObject);
    procedure OnCopyLinkClick(Sender: TObject);

  public
    constructor Create(AParentWindow: HWND; ControlID: Cardinal = 0);
    destructor Destroy; override;

    procedure AddEvent(hContact, hDBEvent: THandle; Codepage: Integer; RTL: boolean);
    procedure SetPosition(x,y,cx,cy: Integer);
    procedure ScrollToBottom;
    function GetSelection(NoUnicode: Boolean): PChar;
    procedure Clear;
    property ParentWindow: HWND read FParentWindow;
    property GridHandle: HWND read GetGridHandle;
    function Perform(Msg: Cardinal; WParam, LParam: Longint): Longint;
    procedure HMBookmarkChanged(var M: TMessage); message HM_NOTF_BOOKMARKCHANGED;
    procedure HMIcons2Changed(var M: TMessage); message HM_NOTF_ICONS2CHANGED;
    procedure BeginUpdate;
    procedure EndUpdate;
  end;

var
  ExternalGrids: array of TExternalGrid;

function FindExtGridByHandle(var Handle: HWND): TExternalGrid;
function DeleteExtGridByHandle(var Handle: HWND): Boolean;

implementation

uses hpp_options;

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

procedure TExternalGrid.AddEvent(hContact, hDBEvent: THandle; Codepage: Integer; RTL: boolean);
var
  Flag: TBiDiMode;
begin
  SetLength(Items,Length(Items)+1);
  Items[High(Items)].hDBEvent := hDBEvent;
  Items[High(Items)].hContact := hContact;
  Items[High(Items)].Codepage := Codepage;
  if RTL then begin
    Items[High(Items)].RTLMode := hppRTLEnable;
    Flag := bdRightToLeft;
  end else begin
    Items[High(Items)].RTLMode := hppRTLDisable;
    Flag := bdLeftToRight;
  end;
  if Grid.BiDiMode <> Flag then Grid.BiDiMode := Flag;
  if Grid.Contact <> hContact then begin
    Grid.Contact := hContact;
    Grid.Protocol := GetContactProto(hContact);
  end;
  // comment or we'll get rerendering the whole grid
  //if Grid.Codepage <> Codepage then Grid.Codepage := Codepage;
  Grid.Allocate(Length(Items));
end;

constructor TExternalGrid.Create(AParentWindow: HWND; ControlID: Cardinal = 0);
begin
  FParentWindow := AParentWindow;
  Grid := THistoryGrid.CreateParented(ParentWindow);
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
  Grid.OnKillFocus := GridKillFocus;
  Grid.OnDblClick := GridDblClick;
  Grid.OnForbiddenChar := GridForbiddenChar;
  Grid.OnKeyDown := GridKeyDown;
  Grid.OnKeyUp := GridKeyUp;
  Grid.OnPopup := GridPopup;
  Grid.OnInlinePopup := GridPopup;
  Grid.OnUrlPopup := GridUrlPopup;
  Grid.OnInlineKeyDown := GridInlineKeyDown;
  Grid.Options := GridOptions;

  pmGrid := TTntPopupMenu.Create(Grid);
  pmGrid.ParentBiDiMode := False;
  pmGrid.Items.Add(WideNewItem('&Copy',TextToShortCut('Ctrl+C'),false,true,OnCopyClick,0,'pmCopy'));
  pmGrid.Items.Add(WideNewItem('Copy &Text',TextToShortCut('Ctrl+T'),false,true,OnCopyTextClick,0,'pmCopyText'));
  pmGrid.Items.Add(WideNewItem('Select &All',TextToShortCut('Ctrl+A'),false,true,OnSelectAllClick,0,'pmSelectAll'));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN1'));
  pmGrid.Items.Add(WideNewItem('Text Formatting',TextToShortCut('Ctrl+P'),false,true,OnTextFormattingClick,0,'pmTextFormatting'));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN2'));
  pmGrid.Items.Add(WideNewItem('&Reply Quoted',TextToShortCut('Ctrl+R'),false,true,OnReplyQuotedClick,0,'pmReplyQuoted'));
  pmGrid.Items.Add(WideNewItem('-',0,false,true,nil,0,'pmN3'));
  pmGrid.Items.Add(WideNewItem('Set &Bookmark',TextToShortCut('Ctrl+B'),false,true,OnBookmarkClick,0,'pmBookmark'));

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

procedure TExternalGrid.GridItemData(Sender: TObject; Index: Integer;
  var Item: THistoryItem);
begin
  Item := ReadEvent(Items[Index].hDBEvent,Items[Index].Codepage);
  Item.Proto := Grid.Protocol;
  Item.RTLMode := Items[Index].RTLMode;
  Item.Bookmarked := BookmarkServer[Items[Index].hContact].Bookmarked[Items[Index].hDBEvent];
  if (not Item.IsRead) and
     (MessageTypesToDWord(Item.MessageType) and
      MessageTypesToDWord([mtIncoming,mtMessage,mtUrl,mtStatus]) > 0) then begin
    PluginLink.CallService(MS_DB_EVENT_MARKREAD,Items[Index].hContact,Items[Index].hDBEvent);
    //PluginLink.CallService(MS_CLIST_REMOVEEVENT,Items[Index].hContact,Items[Index].hDBEvent);
  end;
end;

procedure TExternalGrid.GridTranslateTime(Sender: TObject; Time: Cardinal;
  var Text: WideString);
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
      Grid.ContactName := GetContactDisplayName(Items[Index].hContact, Grid.Protocol, true);
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
  Grid.ScrollToBottom;
  Grid.Repaint;
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
  Text: WideString;
  Source: PChar;
  Len: integer;
begin
  if Grid.Count = 0 then exit;
  if Grid.State = gsInline then
    Text := GetRichString(Grid.InlineRichEdit.Handle,True)
  else
  if Grid.Selected <> -1 then
    Text := Grid.FormatSelected(Grid.Options.ClipCopyFormat)
  else
    Text := Grid.FormatItem(Grid.BottomItem,Grid.Options.ClipCopyFormat);
  if NoUnicode then begin
    FSelection := WideToAnsiString(Text,CP_ACP)+#0;
  end else begin
    Text := Text+#0;
    SetLength(FSelection,Length(Text)*SizeOf(WideChar));
    Move(Pointer(@Text[1])^,Pointer(@FSelection[1])^,Length(FSelection));
  end;
  Result := @FSelection[1];
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

procedure TExternalGrid.GridKillFocus(Sender: TObject);
begin
  // deselect grid
  Grid.Selected := -1;
end;

procedure TExternalGrid.GridDblClick(Sender: TObject);
begin
  if Grid.Selected = -1 then exit;
  Grid.EditInline(Grid.Selected);
end;

procedure TExternalGrid.GridForbiddenChar(Sender: TObject; var Char: WideChar; Shift: TShiftState);
begin
  if Char = #27 then begin
    PostMessage(FParentWindow,WM_CLOSE,0,0);
    Char := #0;
  end;
end;

procedure TExternalGrid.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) then begin
    if key=Ord('C') then begin
      OnCopyClick(Sender);
      key:=0;
    end;
    if key=Ord('T') then begin
      OnCopyTextClick(Sender);
      key:=0;
    end;
    if key=Ord('R') then begin
      OnReplyQuotedClick(Sender);
      key:=0;
    end;
  end;
end;

procedure TExternalGrid.GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then begin
    GridDblClick(Grid);
    Key := 0;
  end;
end;

procedure TExternalGrid.GridPopup(Sender: TObject);
begin
  pmGrid.Items[2].Visible := (Grid.State = gsInline);
  pmGrid.Items[4].Visible := (Grid.State = gsInline);
  pmGrid.Items[4].Checked := Grid.ProcessInline;
  if Grid.State = gsInline then
    pmGrid.Items[0].Enabled := Grid.InlineRichEdit.SelLength > 0
  else
    pmGrid.Items[0].Enabled := True;
  pmGrid.Items[6].Enabled := pmGrid.Items[0].Enabled;
  if Grid.Selected <> -1 then begin
    if Grid.Items[Grid.Selected].Bookmarked then
      pmGrid.Items[8].Caption := TranslateWideW('Remove &Bookmark')
    else
      pmGrid.Items[8].Caption := TranslateWideW('Set &Bookmark');
  end;
  pmGrid.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
end;

procedure TExternalGrid.OnCopyClick(Sender: TObject);
begin
  if Grid.Selected = -1 then exit;
  if Grid.State = gsInline then begin
    if Grid.InlineRichEdit.SelLength = 0 then exit;
    Grid.InlineRichEdit.CopyToClipboard;
  end else begin
    CopyToClip(Grid.FormatSelected(Grid.Options.ClipCopyFormat),Grid.Handle,Items[Grid.Selected].Codepage);
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
    CopyToClip(Grid.FormatSelected(Grid.Options.ClipCopyTextFormat),Grid.Handle,Items[Grid.Selected].Codepage);
end;

procedure TExternalGrid.OnSelectAllClick(Sender: TObject);
begin
  if (Grid.Selected = -1) or (Grid.State <> gsInline) then exit;
  Grid.InlineRichEdit.SelectAll;
end;

procedure TExternalGrid.OnTextFormattingClick(Sender: TObject);
begin
  if Grid.Selected = -1 then exit;
  Grid.ProcessInline := not Grid.ProcessInline;
end;

procedure TExternalGrid.OnReplyQuotedClick(Sender: TObject);
begin
  if Grid.Selected = -1 then exit;
  if Grid.State = gsInline then begin
    if Grid.InlineRichEdit.SelLength = 0 then exit;
    SendMessageTo(Items[Grid.Selected].hContact,Grid.FormatSelected(DEFFORMAT_REPLYQUOTEDTEXT));
  end else begin
    //if (hContact = 0) or (hg.SelCount = 0) then exit;
    SendMessageTo(Items[Grid.Selected].hContact,Grid.FormatSelected(Grid.Options.ReplyQuotedFormat));
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

procedure TExternalGrid.GridInlineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) then begin
    if key=Ord('T') then begin
      OnCopyTextClick(Sender);
      key:=0;
    end;
    if key=Ord('P') then begin
      OnTextFormattingClick(Sender);
      key:=0;
    end;
    if key=Ord('R') then begin
      OnReplyQuotedClick(Sender);
      key:=0;
    end;
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

function FindExtGridByHandle(var Handle: HWND): TExternalGrid;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Length(ExternalGrids) - 1 do begin
    if ExternalGrids[i].Grid.Handle = Handle then begin
      Result := ExternalGrids[i];
      break;
    end;
  end;
end;

function DeleteExtGridByHandle(var Handle: HWND): Boolean;
var
  i,n: Integer;
begin
  Result := False;
  n := -1;
  for i := 0 to Length(ExternalGrids) - 1 do begin
    if ExternalGrids[i].Grid.Handle = Handle then begin
      n := i;
      break;
    end;
  end;
  if n = -1 then exit;
  ExternalGrids[n].Free;
  for i := n to Length(ExternalGrids) - 2 do begin
    ExternalGrids[i] := ExternalGrids[i+1];
  end;
  SetLength(ExternalGrids,Length(ExternalGrids)-1);
  Result := True;
end;

end.
