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
  TEventData = record
    hDBEvent: DWord;
    CRC32: DWord;
    Timestamp: DWord;
  end;
  PEventData = ^TEventData;

  TBookmarksHash = class;

  TContactBookmarks = class(TObject)
  private
    Bookmarks: TBookmarksHash;
    hContact: THandle;
    function GetBookmarked(Index: THandle): Boolean;
    procedure SetBookmarked(Index: THandle; const Value: Boolean);
  public
    constructor Create(AContact: THandle);
    destructor Destroy; override;

    property Bookmarked[Index: THandle]: Boolean read GetBookmarked write SetBookmarked;
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
    procedure RemoveByIndex(Index: Integer);
    procedure InsertByIndex(Index: Integer; Key,Value: Cardinal);
  protected
    procedure AddKey(Key, Value: Cardinal);
    function GetKey(Key: Cardinal; var Value: Cardinal): Boolean;
    function RemoveKey(Key: Cardinal): Boolean;
  public
    destructor Destroy; override;
  end;

  TContactsHash = class(TPseudoHash)
  private
    function GetContactBookmarks(Index: Integer): TContactBookmarks;
  public
    property Items[Index: THandle]: TContactBookmarks read GetContactBookmarks; default;

    destructor Destroy; override;
  end;

  TBookmarksHash = class(TPseudoHash)
  private
    Contact: TContactBookmarks;
    function GetHasItem(Index: THandle): Boolean;
    function GetBookmark(hDBEvent: THandle; var EventData: TEventData): Boolean;
    function AddItem(hDBEvent: THandle): Boolean;
    function RemoveItem(hDBEvent: THandle): Boolean;
  public
    constructor Create(AContact: TContactBookmarks);
    destructor Destroy; override;

    property HasItem[Index: THandle]: Boolean read GetHasItem; default;
  end;

  TBookmarkServer = class(TObject)
  private
    hookEventDeleted,hookEventAdded: THandle;
    CachedContacts: TContactsHash;
    function GetContacts(Index: THandle): TContactBookmarks;
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

    property Contacts[Index: THandle]: TContactBookmarks read GetContacts; default;
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

function DynArrayComparePseudoHash(Item1, Item2: Pointer): Integer;
begin
  if PPseudoHashEntry(Item1)^.Key > PPseudoHashEntry(Item2)^.Key then
    Result := 1
  else if PPseudoHashEntry(Item1)^.Key < PPseudoHashEntry(Item2)^.Key then
    Result := -1
  else
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

function TBookmarkServer.GetContacts(Index: THandle): TContactBookmarks;
begin
  Result := CachedContacts[Index];
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
  CachedContacts := TContactsHash.Create;
  hookEventDeleted := PluginLink.HookEvent(ME_DB_EVENT_DELETED,EventDeletedHelper);
  hookEventAdded := PluginLink.HookEvent(ME_DB_EVENT_ADDED,EventAddedHelper);
end;

destructor TBookmarkServer.Destroy;
begin
  PluginLink.UnhookEvent(hookEventDeleted);
  PluginLink.UnhookEvent(hookEventAdded);
  CachedContacts.Free;
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
  Bookmarks := TBookmarksHash.Create(Self);
  // read bookmarks from DB here
end;

destructor TContactBookmarks.Destroy;
begin
  Bookmarks.Free;
  inherited;
end;

function TContactBookmarks.GetBookmarked(Index: THandle): Boolean;
begin
  Result := Bookmarks[Index];
end;

procedure TContactBookmarks.SetBookmarked(Index: THandle; const Value: Boolean);
begin
  if Value <> Bookmarks[Index] then begin
    if Value then
      Bookmarks.AddItem(Index)
    else
      Bookmarks.RemoveItem(Index);
  end;
end;


{ TPseudoHash }

procedure TPseudoHash.AddKey(Key, Value: Cardinal);
var
  Nearest: Integer;
  ph: TPseudoHashEntry;
  i: Integer;
begin
  ph.Key := Key;
  Nearest := SearchDynArray(Table,SizeOf(TPseudoHashEntry),DynArrayComparePseudoHash,@ph,True);
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

destructor TPseudoHash.Destroy;
begin
  SetLength(Table,0);
  inherited;
end;

function TPseudoHash.GetKey(Key: Cardinal; var Value: Cardinal): Boolean;
var
  ph: TPseudoHashEntry;
  res: Integer;
begin
  Result := False;
  ph.Key := Key;
  res := SearchDynArray(Table,SizeOf(TPseudoHashEntry),DynArrayComparePseudoHash,@ph,False);
  if res <> -1 then begin
    Result := True;
    Value := Table[res].Value;
  end;
end;

procedure TPseudoHash.InsertByIndex(Index: Integer; Key, Value: Cardinal);
begin

end;

procedure TPseudoHash.RemoveByIndex(Index: Integer);
var
  i: Integer;
begin
  for i := Index to Length(Table) - 2 do
    Table[i] := Table[i+1];
  SetLength(Table,Length(Table)-1);
end;

function TPseudoHash.RemoveKey(Key: Cardinal): Boolean;
var
  idx: Integer;
  ph: TPseudoHashEntry;
begin
  Result := False;
  idx := SearchDynArray(Table,SizeOf(TPseudoHashEntry),DynArrayComparePseudoHash,@ph,False);
  if idx = -1 then exit;
  RemoveByIndex(idx);
end;

{ TContactsHash }

destructor TContactsHash.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(Table) - 1 do
    TContactBookmarks(Pointer(Table[i].Value)).Free;
  inherited;
end;

function TContactsHash.GetContactBookmarks(Index: Integer): TContactBookmarks;
var
  val: Pointer;
begin
  Result := nil;
  if GetKey(Cardinal(Index),Cardinal(val)) then
    Result := TContactBookmarks(val)
  else begin
    Result := TContactBookmarks.Create(Index);
    AddKey(Cardinal(Index),Cardinal(Pointer(Result)));
  end;
end;

{ TBookmarksHash }

function TBookmarksHash.AddItem(hDBEvent: THandle): Boolean;
var
  ped: PEventData;
begin
  GetMem(ped,SizeOf(TEventData));
  ped^.hDBEvent := hDBEvent;
  AddKey(hDBEvent,Cardinal(ped));
end;

constructor TBookmarksHash.Create(AContact: TContactBookmarks);
begin
  Contact := AContact;
end;

destructor TBookmarksHash.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(Table) - 1 do
    FreeMem(PEventData(Table[i].Value),SizeOf(TEventData));
  inherited;
end;

function TBookmarksHash.GetBookmark(hDBEvent: THandle;
  var EventData: TEventData): Boolean;
var
  val: Pointer;
begin
  Result := False;
  if GetKey(Cardinal(hDBEvent),Cardinal(val)) then begin
    EventData := PEventData(val)^;
    Result := True;
  end;
end;

function TBookmarksHash.GetHasItem(Index: THandle): Boolean;
var
  val: Pointer;
begin
  Result := False;
  if GetKey(Cardinal(Index),Cardinal(val)) then
    Result := True;
end;

function TBookmarksHash.RemoveItem(hDBEvent: THandle): Boolean;
var
  ped: PEventData;
begin
  Result := False;
  if GetKey(Cardinal(hDBEvent),Cardinal(ped)) then begin
    RemoveKey(Cardinal(hDBEvent));
    FreeMem(ped,SizeOf(ped^));
    Result := True;
  end;
end;

end.
