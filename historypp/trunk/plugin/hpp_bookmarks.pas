{-----------------------------------------------------------------------------
 hpp_bookmarks.pas (historypp project)

 Version:   1.5
 Created:   02.04.2006
 Author:    Oxygen

 [ Description ]

 Hello, this is dummy text


 [ History ]

 1.5 (02.04.2006)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) Art Fedorov, 2006
-----------------------------------------------------------------------------}

unit hpp_bookmarks;

interface

uses m_globaldefs, m_api, hpp_jclSysUtils, SysUtils;

type
  TEventData = packed record
    hDBEvent: DWord;
    CRC32: DWord;
    Timestamp: DWord;
    Position: DWord;
  end;

  TContactBookmarks = class(TObject)
  private
    Bookmarks: array of TEventData;
    hContact: THandle;
  public
    constructor Create(AContact: THandle);
    destructor Destroy; override;

    property Contact: THandle read hContact;
  end;
  PContactBookmarks = ^TContactBookmarks;

  TPseudoHashEntry = record
    Key: Cardinal;
    Value: Cardinal;
  end;
  PPseudoHashEntry = ^TPseudoHashEntry;

  TPseudoHash = class(TObject)
  private
    Table: array of TPseudoHashEntry;
    procedure AddKey(Key, Value: Cardinal);
    function GetKey(Key: Cardinal; var Value: Cardinal): Boolean;
  end;

  TContactsHash = class(TPseudoHash)
  private
    function GetContactBookmarks(Index: Integer): TContactBookmarks;
  public
    property Items[Index: THandle]: TContactBookmarks read GetContactBookmarks;
  end;

  TBookmarkServer = class(TObject)
  private
    hookEventDeleted,hookEventAdded: THandle;
    Contacts: TContactsHash;
  protected
    procedure EventDeleted(hContact,hDBEvent: THandle);
    procedure EventAdded(hContact,hDBEvent: THandle);
  public
    constructor Create;
    destructor Destroy; override;

    function AddBookmark(hContact, hDBEvent: THandle): Integer;
    function GetBookmark(hContact, hDBEvent: THandle): Integer;
    function DeleteBookmark(Bookmark: Integer): Integer; overload;
    function DeleteBookmark(hContact, hDBEvent: THandle): Integer; overload;
  end;

var
  BookmarkServer: TBookmarkServer;

procedure hppInitBookmarkServer;
procedure hppDeinitBookmarkServer;

implementation

procedure hppInitBookmarkServer;
begin
  BookmarkServer := TBookmarkServer.Create;
end;

procedure hppDeinitBookmarkServer;
begin
  BookmarkServer.Free;
end;

function EventDeletedHelper(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
// wParam: hContact, lParam: hDBEvent
begin
  if Assigned(BookmarkServer) then
    BookmarkServer.EventDeleted(wParam,lParam);
  Result := 0;
end;

function EventAddedHelper(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
// wParam: hContact, lParam: hDBEvent
begin
  if Assigned(BookmarkServer) then
    BookmarkServer.EventAdded(wParam,lParam);
  Result := 0;
end;

{ TBookmarkServer }

function TBookmarkServer.AddBookmark(hContact, hDBEvent: THandle): Integer;
begin
  Result := 0;
end;

function TBookmarkServer.GetBookmark(hContact, hDBEvent: THandle): Integer;
begin
  Result := -1;
end;

function TBookmarkServer.DeleteBookmark(Bookmark: Integer): Integer;
begin
  Result := 0;
end;

function TBookmarkServer.DeleteBookmark(hContact, hDBEvent: THandle): Integer;
var
  bm: integer;
begin
  bm := GetBookmark(hContact, hDBEvent);
  if bm <> -1 then
    Result := Self.DeleteBookmark(bm)
  else
    Result := bm;
end;

constructor TBookmarkServer.Create;
begin
  inherited;
  hookEventDeleted := PluginLink.HookEvent(ME_DB_EVENT_DELETED,EventDeletedHelper);
  hookEventAdded := PluginLink.HookEvent(ME_DB_EVENT_ADDED,EventAddedHelper);
end;

destructor TBookmarkServer.Destroy;
begin
  PluginLink.UnhookEvent(hookEventDeleted);
  PluginLink.UnhookEvent(hookEventAdded);
  BookmarkServer := nil;
  inherited;
end;

procedure TBookmarkServer.EventAdded(hContact, hDBEvent: THandle);
begin
  ;
end;

procedure TBookmarkServer.EventDeleted(hContact, hDBEvent: THandle);
begin
  DeleteBookmark(hContact, hDBEvent);
end;

{ TContactBookmarks }

constructor TContactBookmarks.Create(AContact: THandle);
begin
  hContact := AContact;
  // read bookmarks from DB here
end;

destructor TContactBookmarks.Destroy;
begin
  SetLength(Bookmarks,0);
  inherited;
end;

{ TContactsHash }


{ TPseudoHash }

function DynArrayComparePseudoHash(Item1, Item2: Pointer): Integer;
begin
  Result := PPseudoHashEntry(Item1)^.Key - PPseudoHashEntry(Item2)^.Key;
end;

procedure TPseudoHash.AddKey(Key, Value: Cardinal);
var
  Nearest: Integer;
  ph: TPseudoHashEntry;
  i: Integer;
begin
  ph.Key := Key;
  Nearest := SearchDynArray(Table,SizeOf(TPseudoHashEntry),DynArrayComparePseudoHash,
    @ph,True);
  if Nearest <> -1 then begin // we have nearest or match
    if Table[Nearest].Key = Key then
      raise Exception.Create('TPseudoHash: Key already exists');
    if Table[Nearest].Key < Key then
      Inc(Nearest);
  end
  else
    Nearest := 0; // table is empty

  SetLength(Table,Length(Table)+1);
  for i := Length(Table)-1 downto Nearest do
    Table[i] := Table[i-1];

  Table[Nearest].Key := Key;
  Table[Nearest].Value := Value;
end;

function TPseudoHash.GetKey(Key: Cardinal; var Value: Cardinal): Boolean;
var
  ph: TPseudoHashEntry;
  res: Integer;
begin
  Result := False;
  ph.Key := Key;
  res := SearchDynArray(Table,SizeOf(TPseudoHashEntry),DynArrayComparePseudoHash,
    @ph,False);
  if res <> -1 then begin
    Result := True;
    Value := Table[res].Value;
  end;
end;

{ TContactsHash }

function TContactsHash.GetContactBookmarks(Index: Integer): TContactBookmarks;
var
  val: Pointer;
begin
  Result := nil;
  if GetKey(Cardinal(Index),Cardinal(val)) then
    Result := PContactBookmarks(val)^
  else begin
    Result := TContactBookmarks.Create(Index);
    AddKey(Cardinal(Index),Cardinal(PContactBookmarks(Result)));
  end;
end;

end.
