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
    FContactCP: Cardinal;
    function GetBookmarked(Index: THandle): Boolean;
    procedure SetBookmarked(Index: THandle; const Value: Boolean);

    procedure DeleteBookmarks;
    procedure LoadBookmarks;
    procedure SaveBookmarks;
  public
    constructor Create(AContact: THandle);
    destructor Destroy; override;

    property Bookmarked[Index: THandle]: Boolean read GetBookmarked write SetBookmarked;
    property Contact: THandle read hContact;
    property ContactCP: Cardinal read FContactCP;
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
    function AddKey(Key, Value: Cardinal): Boolean;
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
    function FindEventByTimestampAndCrc(ped: PEventData): Boolean;
  public
    constructor Create(AContact: TContactBookmarks);
    destructor Destroy; override;

    function AddEventData(var EventData: TEventData): Boolean;
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

uses hpp_events, hpp_contacts, hpp_global, Checksum, hpp_database;

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
  Result := PInteger(@PPseudoHashEntry(Item1)^.Key)^ - PInteger(@PPseudoHashEntry(Item2)^.Key)^;
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
  FContactCP := GetContactCodepage(hContact);
  Bookmarks := TBookmarksHash.Create(Self);
  // read bookmarks from DB here
  LoadBookmarks;
end;

procedure TContactBookmarks.DeleteBookmarks;
begin
  DBDelete(hContact,hppDBName,'Bookmarks');
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

procedure TContactBookmarks.LoadBookmarks;
var
  i: Integer;
  mem: PEventData;
  mem_org: Pointer;
  mem_len: Integer;
  rec_size: Word;
  count: Integer;
  ed: PEventData;
  AllOk: Boolean;
begin
  if not GetDBBlob(hContact,hppDBName,'Bookmarks',mem_org,mem_len) then exit;
  try
    AllOk := True;
    if mem_len < SizeOf(Word) then raise EAbort.Create('Too small bookmarks rec');
    rec_size := PWord(mem_org)^;
    if rec_size < SizeOf(TEventData) then raise EAbort.Create('Bookmark size is too small');
    count := (mem_len - SizeOf(Word)) div rec_size;
    mem := Pointer(DWord(mem_org) + Sizeof(Word));
    for i := 0 to count - 1 do begin
      ed := PEventData(Integer(mem)+i*rec_size);
      if not Bookmarks.AddEventData(ed^) then AllOk := False;
    end;
    FreeMem(mem_org,mem_len);
    // if we found that some items are missing or different, save
    // correct copy:
    if not AllOk then SaveBookmarks;
  except
    DeleteBookmarks;
  end;
end;

procedure TContactBookmarks.SaveBookmarks;
var
  mem: Pointer;
  mem_len: Integer;
  i: Integer;
  src,dst: PEventData;
begin
  if Length(Bookmarks.Table) > 0 then begin
    mem_len := Length(Bookmarks.Table)*SizeOf(TEventData)+SizeOf(Word);
    GetMem(mem,mem_len);
    PWord(mem)^ := Word(SizeOf(TEventData));
    for i := 0 to High(Bookmarks.Table) do begin
      src := PEventData(Bookmarks.Table[i].Value);
      dst := PEventData(Integer(mem)+SizeOf(Word)+i*SizeOf(TEventData));
      Move(src^,dst^,SizeOf(src^));
    end;
    WriteDBBlob(hContact,hppDBName,'Bookmarks',mem,mem_len);
  end
  else begin
    DeleteBookmarks;
  end;
end;

procedure TContactBookmarks.SetBookmarked(Index: THandle; const Value: Boolean);
var
  res: Boolean;
begin
  if Value then
    res := Bookmarks.AddItem(Index)
  else
    res := Bookmarks.RemoveItem(Index);
  if res then SaveBookmarks;
end;


{ TPseudoHash }

function TPseudoHash.AddKey(Key, Value: Cardinal): Boolean;
var
  Nearest: Integer;
  ph: TPseudoHashEntry;
  i: Integer;
begin
  Result := False;
  ph.Key := Key;
  Nearest := SearchDynArray(Table,SizeOf(TPseudoHashEntry),DynArrayComparePseudoHash,@ph,True);
  if Nearest <> -1 then begin // we have nearest or match
    if Table[Nearest].Key = Key then
      exit;
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

  Result := True;
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

function TBookmarksHash.AddEventData(var EventData: TEventData): Boolean;
var
  ped: PEventData;
  hi: THistoryItem;
  ts: Cardinal;
  ItemExists, ItemCorrect, NewItemFound: Boolean;
begin
  GetMem(ped,SizeOf(TEventData));
  ped^.hDBEvent := EventData.hDBEvent;
  ped^.CRC32 := EventData.CRC32;
  ped^.Timestamp := EventData.Timestamp;
  ItemExists := (PluginLink.CallService(MS_DB_EVENT_GETBLOBSIZE,EventData.hDBEvent,0) >= 0);
  if ItemExists then begin
    ts := GetEventTimestamp(EventData.hDBEvent);
    ItemCorrect := (ts = ped^.Timestamp);
    // we might check for CRC32 here also?
  end;
  if (not ItemExists) or (not ItemCorrect) then begin
    Result := False;
    NewItemFound := FindEventByTimestampAndCrc(ped); // try to find the item
    if not NewItemFound then begin // can not find
      FreeMem(ped,SizeOf(TEventData));
      exit;
    end
    else
      AddKey(ped^.hDBEvent,Cardinal(ped)); // exit, but leave Result = False as we want to resave after this load
  end
  else
    Result := AddKey(ped^.hDBEvent,Cardinal(ped)); // item exists, add as normal
end;

function TBookmarksHash.AddItem(hDBEvent: THandle): Boolean;
var
  ped: PEventData;
  hi: THistoryItem;
begin
  GetMem(ped,SizeOf(TEventData));
  ped^.hDBEvent := hDBEvent;
  hi := ReadEvent(hDBEvent,Contact.ContactCP);
  ped^.Timestamp := hi.Time;
  CalcCRC32(PWideChar(hi.Text),Length(hi.Text)*SizeOf(WideChar),Cardinal(ped^.CRC32));
  AddKey(hDBEvent,Cardinal(ped));
  Result := True;
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

// currently finds events with similar timestamp ONLY
function TBookmarksHash.FindEventByTimestampAndCrc(ped: PEventData): Boolean;
var
  hDBEvent: THandle;
  first_ts,last_ts,ts,cur_ts: Integer;
  StartFromFirst: Boolean;
begin
  Result := False;

  hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDFIRST,Contact.hContact,0);
  if hDBEvent = 0 then exit;
  first_ts := GetEventTimestamp(hDBEvent);
  hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDLAST,Contact.hContact,0);
  if hDBEvent = 0 then exit;
  last_ts := GetEventTimestamp(hDBEvent);
  ts := ped^.Timestamp;
  if (ts < first_ts) or (ts > last_ts) then exit;
  StartFromFirst := ((ts - first_ts) < (last_ts - ts));

  if StartFromFirst then begin
    hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDFIRST,Contact.hContact,0);
    while hDBEvent <> 0 do begin
      cur_ts := GetEventTimestamp(hDBEvent);
      if cur_ts > ts then break;
      if cur_ts = ts then begin
        ped^.hDBEvent := hDBEvent;
        Result := True;
        break;
      end;
      hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBEvent,0);
    end;
  end
  else begin
    hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDLAST,Contact.hContact,0);
    while hDBEvent <> 0 do begin
      cur_ts := GetEventTimestamp(hDBEvent);
      if ts > cur_ts then break;
      if cur_ts = ts then begin
        ped^.hDBEvent := hDBEvent;
        Result := True;
        break;
      end;
      hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDBEvent,0);
    end;
  end;
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
