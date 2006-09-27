unit hpp_externalgrid;

interface

uses
  Windows, Classes, Controls, Forms, Graphics, m_api,
  hpp_global, m_globaldefs, hpp_events, hpp_contacts, hpp_services,
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
  end;

var
  ExternalGrids: array of TExternalGrid;

function FindExtGridByHandle(var Handle: HWND): TExternalGrid;
function DeleteExtGridByHandle(var Handle: HWND): Boolean;

implementation

uses hpp_options;

{ TExternalGrid }

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
  Grid.Options := GridOptions;
  Grid.BeginUpdate;
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

procedure TExternalGrid.GridItemData(Sender: TObject; Index: Integer;
  var Item: THistoryItem);
begin
  Item := ReadEvent(Items[Index].hDBEvent,Items[Index].Codepage);
  Item.RTLMode := Items[Index].RTLMode;
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
  ItemRenderDetails.bHistoryWindow := IRDHW_EXTERNAL;
  PluginLink.NotifyEventHooks(hHppRichEditItemProcess,WPARAM(Handle),LPARAM(@ItemRenderDetails));
end;

procedure TExternalGrid.ScrollToBottom;
begin
  Grid.ScrollToBottom;
  //Grid.Repaint;
  Grid.EndUpdate;
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
begin
  Text := Grid.FormatSelected(Grid.Options.ClipCopyFormat);
  if NoUnicode then
    Result := PChar(WideToAnsiString(Text,CP_ACP))
  else
    Result := PChar(PWideChar(Text));
end;

procedure TExternalGrid.Clear;
begin
  Grid.Allocate(0);
  Finalize(Items);
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
