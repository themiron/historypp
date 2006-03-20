{-----------------------------------------------------------------------------
 hpp_searchthread (historypp project)

 Version:   1.0
 Created:   05.08.2004
 Author:    Oxygen

 [ Description ]

 Global searching in History++ is performed in background so
 we have separate thread for doing it. Here it is, all bright
 and shiny. In this module the thread is declared, also you
 can find all text searching routines used and all search
 logic. See TSearchThread and independent SearchText* funcs

 The results are sent in batches of 500, for every contact.
 First batch is no more than 50 for fast display.

 Yeah, all search is CASE-INSENSITIVE (at the time of writing :)

 [ History ]

 1.5 (05.08.2004)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) Art Fedorov, 2004
-----------------------------------------------------------------------------}

unit hpp_searchthread;

interface

uses
  Windows, SysUtils, Controls, Messages, HistoryGrid, Classes, m_GlobalDefs,
  hpp_global, hpp_events, TntSysUtils;


const
  ST_FIRST_BATCH = 50;
  ST_BATCH       = 500;

type
  PDBArray = ^TDBArray;
  TDBArray = array[0..ST_BATCH-1] of Integer;

  TSearchMethod = (smExact, smAnyWord, smAllWords);

  TSearchThread = class(TThread)
  private
    Buffer: TDBArray;
    BufCount: Integer;
    FirstBatch: Boolean;
    CurContact: THandle;
    CurContactCP: Cardinal;
    CurProgress: Integer;
    MaxProgress: Integer;
    FParentHandle: THandle;
    FSearchTime: Integer;
    SearchStart: Integer;
    SearchWords: array of WideString;
    FSearchText: WideString;
    FSearchMethod: TSearchMethod;
    FSearchProtected: Boolean;
    procedure GenerateSearchWords;
  protected
    function GetContactsCount: Integer;
    function GetItemsCount(hContact: THandle): Integer;
    procedure CalcMaxProgress;
    procedure IncProgress;
    procedure SetProgress(Progress: Integer);

    function SearchEvent(DBEvent: THandle): Boolean;
    procedure SearchContact(Contact: THandle);
    procedure SendItem(hDBEvent: Integer);
    procedure SendBatch;
    procedure Execute; override;

    procedure DoMessage(Message: DWord; wParam, lParam: DWord);

  public
    AllContacts, AllEvents: Integer;

    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    property SearchProtectedContacts: Boolean read FSearchProtected write FSearchProtected;
    property SearchText: WideString read FSearchText write FSearchText;
    property SearchMethod: TSearchMethod read FSearchMethod write FSearchMethod;
    property SearchTime: Integer read FSearchTime;
    property ParentHandle: THandle read FParentHandle write FParentHandle;

    property Terminated;
  end;

const
  SM_BASE = WM_APP + 421;
  SM_PREPARE = SM_BASE + 1; // the search is prepared (0,0)
  SM_PROGRESS = SM_BASE + 2; // report the progress (progress, max)
  SM_ITEMFOUND = SM_BASE + 3; // (OBSOLETE) item is found (hDBEvent,0)
  SM_NEXTCONTACT = SM_BASE + 4; // the next contact is searched (hContact, ContactCount)
  SM_FINISHED = SM_BASE + 5; // search finished (0,0)
  SM_ITEMSFOUND = SM_BASE + 6; // (NEW) items are found (array of hDBEvent, array size)

// helper functions
function SearchTextExact(MessageText: WideString; SearchText: WideString): Boolean;
function SearchTextAnyWord(MessageText: WideString; SearchWords: array of WideString): Boolean;
function SearchTextAllWords(MessageText: WideString; SearchWords: array of WideString): Boolean;

implementation

uses PassForm;

{$I m_database.inc}
{$I m_icq.inc}

function SearchTextExact(MessageText: WideString; SearchText: WideString): Boolean;
begin
  Result := Pos(SearchText, MessageText) <> 0;
end;

function SearchTextAnyWord(MessageText: WideString; SearchWords: array of WideString): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Length(SearchWords)-1 do begin
    Result := SearchTextExact(MessageText,SearchWords[i]);
    if Result then exit;
    end;
end;

function SearchTextAllWords(MessageText: WideString; SearchWords: array of WideString): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Length(SearchWords)-1 do begin
    Result := SearchTextExact(MessageText,SearchWords[i]);
    if not Result then exit;
    end;
end;

{ TSearchThread }

procedure TSearchThread.CalcMaxProgress;
var
  hCont: THandle;
begin
  MaxProgress := 0;
  hCont := PluginLink.CallService(MS_DB_CONTACT_FINDFIRST,0,0);
  while hCont <> 0 do begin
    // I hope I haven't messed this up by
    // if yes, also fix the same in Execute
    if SearchProtectedContacts or (not SearchProtectedContacts and (not IsUserProtected(hCont))) then
      MaxProgress := MaxProgress + GetItemsCount(hCont);
    hCont := PluginLink.CallService(MS_DB_CONTACT_FINDNEXT,hCont,0);
    end;
  // add sysem history
  MaxProgress := MaxProgress + GetItemsCount(hCont);
end;

constructor TSearchThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  AllContacts := 0;
  AllEvents := 0;
  SearchMethod := smExact;
  SearchProtectedContacts := True;
end;

destructor TSearchThread.Destroy;
begin
  SetLength(SearchWords,0);
  inherited;
end;

procedure TSearchThread.DoMessage(Message, wParam, lParam: DWord);
begin
  PostMessage(ParentHandle,Message,wParam,lParam);
end;

procedure TSearchThread.Execute;
var
  hCont: THandle;
begin
  BufCount := 0;
  FirstBatch := True;
  try
    SearchStart := GetTickCount;
    DoMessage(SM_PREPARE,0,0);
    CalcMaxProgress;
    SetProgress(0);

    // make it case-insensitive
    SearchText := Tnt_WideUpperCase(SearchText);
    if SearchMethod in [smAnyWord, smAllWords] then
      GenerateSearchWords;

    hCont := PluginLink.CallService(MS_DB_CONTACT_FINDFIRST,0,0);
    while hCont <> 0 do begin
      Inc(AllContacts);
      // I hope I haven't messed this up by
      // if yes, also fix the same in CalcMaxProgress
      if SearchProtectedContacts or (not SearchProtectedContacts and (not IsUserProtected(hCont))) then
        SearchContact(hCont);
      hCont := PluginLink.CallService(MS_DB_CONTACT_FINDNEXT,hCont,0);
      end;
    SearchContact(hCont);
  finally
    FSearchTime := GetTickCount - SearchStart;
    // only Post..., not Send... because we wait for this thread
    // to die in this message
    PostMessage(ParentHandle,SM_FINISHED,0,0);
    end;
end;

procedure TSearchThread.GenerateSearchWords;
var
  n: Integer;
  st: WideString;
begin
  SetLength(SearchWords,0);
  st := SearchText;
  n := Pos(' ',st);
  while n > 0 do begin
    if n > 1 then begin
      SetLength(SearchWords,Length(SearchWords)+1);
      SearchWords[High(SearchWords)] := Copy(st,1,n-1);
      end;
    Delete(st,1,n);
    n := Pos(' ',st);
    end;

  if st <> '' then begin
    SetLength(SearchWords,Length(SearchWords)+1);
    SearchWords[High(SearchWords)] := st;
    end;
end;

function TSearchThread.GetContactsCount: Integer;
begin
  Result := PluginLink.CallService(MS_DB_CONTACT_GETCOUNT,0,0);
end;

function TSearchThread.GetItemsCount(hContact: THandle): Integer;
begin
  Result := PluginLink.CallService(MS_DB_EVENT_GETCOUNT,hContact,0);
end;

procedure TSearchThread.IncProgress;
begin
  SetProgress(CurProgress+1);
end;

procedure TSearchThread.SearchContact(Contact: THandle);
var
  hDBEvent: THandle;
begin
  CurContactCP := CP_ACP;
  CurContact := Contact;
  DoMessage(SM_NEXTCONTACT, Contact, GetContactsCount);
  hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDLAST,Contact,0);
  while hDBEvent <> 0 do begin
    if SearchEvent(hDBEvent) then begin
      SendItem(hDBEvent);
      end;
    hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDBEvent,0);
    end;
  SendBatch;
end;

function TSearchThread.SearchEvent(DBEvent: THandle): Boolean;
var
  hi: THistoryItem;
begin
  //Sleep(50);
  Inc(AllEvents);
  if Terminated then
    raise EAbort.Create('Thread terminated');
  hi := ReadEvent(DBEvent, CurContactCP);
  case SearchMethod of
    smAnyWord: Result := SearchTextAnyWord(Tnt_WideUpperCase(hi.Text),SearchWords);
    smAllWords: Result := SearchTextAllWords(Tnt_WideUpperCase(hi.Text),SearchWords)
  else // smExact
    Result := SearchTextExact(Tnt_WideUpperCase(hi.Text),SearchText);
    end;
  IncProgress;
end;


procedure TSearchThread.SendItem(hDBEvent: Integer);
var
  CurBuf: Integer;
begin
  //DoMessage(SM_ITEMFOUND,hDBEvent,0);
  Inc(BufCount);
  if FirstBatch then CurBuf := ST_FIRST_BATCH
  else CurBuf := ST_BATCH;
  Buffer[BufCount-1] := hDBEvent;
  if BufCount = CurBuf then begin
    SendBatch;
    end;
end;

procedure TSearchThread.SendBatch;
var
  Batch: PDBArray;
begin
  if BufCount > 0 then begin
    GetMem(Batch,SizeOf(Batch^));
    CopyMemory(Batch,@Buffer,SizeOf(Buffer));
    DoMessage(SM_ITEMSFOUND,DWord(Batch),DWord(BufCount));
    BufCount := 0;
    FirstBatch := False;
  end;
end;

procedure TSearchThread.SetProgress(Progress: Integer);
begin
  CurProgress := Progress;
  if CurProgress > MaxProgress then
    MaxProgress := CurProgress;
  if (CurProgress mod 1000 = 0) or (CurProgress = MaxProgress) then
    DoMessage(SM_PROGRESS,CurProgress,MaxProgress);
end;


end.
