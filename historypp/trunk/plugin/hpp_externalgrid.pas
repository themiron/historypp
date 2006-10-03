unit hpp_externalgrid;

interface

uses
  Windows, Classes, Controls, Forms, Graphics, Messages,
  m_api, m_globaldefs,
  hpp_global, hpp_events, hpp_contacts, hpp_services, hpp_forms, hpp_bookmarks,
  hpp_richedit,
  HistoryGrid;

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
  public
    constructor Create(AParentWindow: HWND);
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
  if Grid.Contact <> hContact then Grid.Contact := hContact;
  // comment or we'll get rerendering the whole grid
  //if Grid.Codepage <> Codepage then Grid.Codepage := Codepage;
  Grid.Allocate(Length(Items));
end;

constructor TExternalGrid.Create(AParentWindow: HWND);
begin
  FParentWindow := AParentWindow;
  Grid := THistoryGrid.CreateParented(ParentWindow);
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
  Grid.Options := GridOptions;
  TranslateMenu(Grid.InlineRichEdit.PopupMenu.Items);
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
  Item.RTLMode := Items[Index].RTLMode;
  Item.Bookmarked := BookmarkServer[Items[Index].hContact].Bookmarked[Items[Index].hDBEvent];
  if not Item.IsRead then begin
    PluginLink.CallService(MS_DB_EVENT_MARKREAD,Items[Index].hContact,Items[Index].hDBEvent);
    PluginLink.CallService(MS_CLIST_REMOVEEVENT,Items[Index].hContact,Items[Index].hDBEvent);
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
  TextW: WideString;
  TextA: AnsiString;
begin
  if Grid.Count = 0 then exit;
  if Grid.State = gsInline then begin
    if NoUnicode then begin
      GetRichRTF(Grid.InlineRichEdit.Handle,TextA,True,True,True,False);
      Result := PChar(TextA);
    end else begin
      GetRichRTF(Grid.InlineRichEdit.Handle,TextA,True,True,True,False,CP_UTF8);
      Result := PChar(PWideChar(AnsiToWideString(TextA,CP_UTF8)));
    end;
  end else begin
    if Grid.Selected <> -1 then
      TextW := Grid.FormatSelected(Grid.Options.ClipCopyFormat)
    else
      TextW := Grid.FormatItem(Grid.BottomItem,Grid.Options.ClipCopyFormat);
    if NoUnicode then
      Result := PChar(WideToAnsiString(TextW,CP_ACP))
    else
      Result := PChar(PWideChar(TextW));
  end;
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
  PluginLink.CallService(MS_UTILS_OPENURL,bNewWindow,Integer(Pointer(@Url[1])));
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
