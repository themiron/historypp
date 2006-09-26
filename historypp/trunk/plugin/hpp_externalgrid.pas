unit hpp_externalgrid;

interface

uses
  Windows, hpp_global, m_globaldefs, m_api, hpp_events, HistoryGrid;

type
  TExtItem = record
    hDBEvent: THandle;
    hContact: THandle;
    Codepage: THandle;
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
  public
    constructor Create(AParentWindow: HWND);
    destructor Destroy; override;

    procedure AddEvent(hContact, hDBEvent: THandle; Codepage: Integer);
    procedure SetPosition(x,y,cx,cy: Integer);
    procedure ScrollToBottom;
    property ParentWindow: HWND read FParentWindow;
    property GridHandle: HWND read GetGridHandle;
  end;

var
  ExternalGrids: array of TExternalGrid;

implementation

uses hpp_options;

{ TExternalGrid }

procedure TExternalGrid.AddEvent(hContact, hDBEvent: THandle; Codepage: Integer);
begin
  SetLength(Items,Length(Items)+1);
  Items[High(Items)].hDBEvent := hDBEvent;
  Items[High(Items)].hContact := hContact;
  Items[High(Items)].Codepage := Codepage;
  Grid.Allocate(Length(Items));
end;

constructor TExternalGrid.Create(AParentWindow: HWND);
begin
  FParentWindow := AParentWindow;
  Grid := THistoryGrid.CreateParented(ParentWindow);
  Grid.OnItemData := GridItemData;
  Grid.OnTranslateTime := GridTranslateTime;
  Grid.Options := GridOptions;
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
end;

procedure TExternalGrid.GridTranslateTime(Sender: TObject; Time: Cardinal;
  var Text: WideString);
begin
  Text := TimestampToString(Time);
end;

procedure TExternalGrid.ScrollToBottom;
begin
  Grid.MakeVisible(Length(Items)-1);
  Grid.Invalidate;
  Grid.Update;
end;

procedure TExternalGrid.SetPosition(x, y, cx, cy: Integer);
begin
  Grid.Left := x;
  Grid.Top := y;
  Grid.Width := cx;
  Grid.Height := cy;
  SetWindowPos(Grid.Handle,0,x,y,cx,cy,SWP_SHOWWINDOW);
end;

initialization
  SetLength(ExternalGrids,1);
finalization
  Finalize(ExternalGrids);
end.
