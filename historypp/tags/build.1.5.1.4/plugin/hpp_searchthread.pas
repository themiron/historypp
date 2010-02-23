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

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}

unit hpp_searchthread;

interface

uses
  Windows, SysUtils, TntSysUtils, Controls, Messages, HistoryGrid, Classes,
  m_GlobalDefs, m_api,
  hpp_global, hpp_events, hpp_forms, hpp_bookmarks, hpp_eventfilters;


const
  ST_FIRST_BATCH = 50;
  ST_BATCH       = 500;

type
  PDBArray = ^TDBArray;
  TDBArray = array[0..ST_BATCH-1] of Integer;

  TSearchMethod = set of (smExact, smAnyWord, smAllWords, smBookmarks, smRange, smEvents);

  TContactRec = record
    hContact: THandle;
    Timestamp: DWord;
  end;

  TSearchThread = class(TThread)
  private
    Buffer: TDBArray;
    BufCount: Integer;
    FirstBatch: Boolean;
    Contacts: array of TContactRec;
    CurContact: THandle;
    CurContactCP: Cardinal;
    CurProgress: Integer;
    MaxProgress: Integer;
    FParentHandle: Hwnd;
    FSearchStart: Cardinal;
    SearchWords: array of WideString;
    FSearchText: WideString;
    FSearchMethod: TSearchMethod;
    FSearchProtected: Boolean;
    FSearchRangeTo: TDateTime;
    FSearchRangeFrom: TDateTime;
    FSearchEvents: TMessageTypes;

    procedure GenerateSearchWords;
    procedure SetSearchRangeFrom(const Value: TDateTime);
    procedure SetSearchRangeTo(const Value: TDateTime);
    procedure SetSearchEvents(const Value: TMessageTypes);

    function SearchEvent(DBEvent: THandle): Boolean;
    procedure SearchContact(Contact: THandle);
    procedure SearchBookmarks(Contact: THandle);

    function DoMessage(Message: DWord; wParam: WPARAM; lParam: LPARAM): Boolean;
    function SendItem(hDBEvent: Integer): Boolean;
    function SendBatch: Boolean;

    function GetContactsCount: Integer;
    function GetItemsCount(hContact: THandle): Integer;
    procedure BuildContactsList;
    procedure CalcMaxProgress;
    procedure IncProgress;
    procedure SetProgress(Progress: Integer);

  protected
    procedure Execute; override;

  public
    AllContacts, AllEvents: Integer;

    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    property SearchProtectedContacts: Boolean read FSearchProtected write FSearchProtected;
    property SearchText: WideString read FSearchText write FSearchText;
    property SearchMethod: TSearchMethod read FSearchMethod write FSearchMethod;
    property SearchRangeFrom: TDateTime read FSearchRangeFrom write SetSearchRangeFrom;
    property SearchRangeTo: TDateTime read FSearchRangeTo write SetSearchRangeTo;
    property SearchEvents: TMessageTypes read FSearchEvents write SetSearchEvents;
    property SearchStart: Cardinal read FSearchStart;
    property ParentHandle: Hwnd read FParentHandle write FParentHandle;

    property Terminated;
    procedure Terminate(NewPriority: TThreadPriority = tpIdle); reintroduce;
  end;

const
  HM_STRD_PREPARE     = HM_STRD_BASE + 1; // the search is prepared (0,0)
  HM_STRD_PROGRESS    = HM_STRD_BASE + 2; // report the progress (progress, max)
  HM_STRD_ITEMFOUND   = HM_STRD_BASE + 3; // (OBSOLETE) item is found (hDBEvent,0)
  HM_STRD_NEXTCONTACT = HM_STRD_BASE + 4; // the next contact is searched (hContact, ContactCount)
  HM_STRD_FINISHED    = HM_STRD_BASE + 5; // search finished (0,0)
  HM_STRD_ITEMSFOUND  = HM_STRD_BASE + 6; // (NEW) items are found (array of hDBEvent, array size)

// helper functions
function SearchTextExact(MessageText: WideString; SearchText: WideString): Boolean;
function SearchTextAnyWord(MessageText: WideString; SearchWords: array of WideString): Boolean;
function SearchTextAllWords(MessageText: WideString; SearchWords: array of WideString): Boolean;

{$DEFINE SMARTSEARCH}

implementation

uses hpp_contacts, PassForm;

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

procedure TSearchThread.BuildContactsList;
var
  hCont: THandle;

  procedure AddContact(Cont: THandle);
  var
    hDB: THandle;
  begin
    SetLength(Contacts,Length(Contacts)+1);
    Contacts[High(Contacts)].hContact := Cont;
    Contacts[High(Contacts)].Timestamp := 0;
    hDB := PluginLink.CallService(MS_DB_EVENT_FINDLAST,Cont,0);
    if hDB <> 0 then begin
      Contacts[High(Contacts)].Timestamp := GetEventTimestamp(hDB);
    end;
  end;

  // OXY:
  // Modified version, original taken from JclAlgorithms.pas (QuickSort routine)
  // See JclAlgorithms.pas for copyright and license information
  // JclAlgorithms.pas is part of Project JEDI Code Library (JCL)
  // [http://www.delphi-jedi.org], [http://jcl.sourceforge.net]
  procedure QuickSort(L, R: Integer);
  var
    I, J, P: Integer;
    Rec: TContactRec;
  begin
    repeat
      I := L;
      J := R;
      P := (L + R) shr 1;
      repeat
        while (Contacts[I].Timestamp - Contacts[P].Timestamp) < 0 do
          Inc(I);
        while (Contacts[J].Timestamp - Contacts[P].Timestamp) > 0 do
          Dec(J);
        if I <= J then
        begin
          Rec := Contacts[I];
          Contacts[I] := Contacts[J];
          Contacts[J] := Rec;
          if P = I then
            P := J
          else
          if P = J then
            P := I;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        QuickSort(L, J);
      L := I;
    until I >= R;
  end;

begin
    hCont := PluginLink.CallService(MS_DB_CONTACT_FINDFIRST,0,0);

    while hCont <> 0 do begin
      Inc(AllContacts);
      // I hope I haven't messed this up by
      // if yes, also fix the same in CalcMaxProgress
      if SearchProtectedContacts or (not SearchProtectedContacts and (not IsUserProtected(hCont))) then
        AddContact(hCont);
      hCont := PluginLink.CallService(MS_DB_CONTACT_FINDNEXT,hCont,0);
    end;

    AddContact(hCont);

    QuickSort(1,Length(Contacts)-1);
end;

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
  SearchMethod := [smExact];
  SearchProtectedContacts := True;
end;

destructor TSearchThread.Destroy;
begin
  SetLength(SearchWords,0);
  SetLength(Contacts,0);
  inherited;
end;

function TSearchThread.DoMessage(Message: DWord; wParam: WPARAM; lParam: LPARAM): Boolean;
begin
  Result := PassMessage(ParentHandle,Message,wParam,lParam,smSend);
end;

procedure TSearchThread.Execute;
var
  {$IFNDEF SMARTSEARCH}
  hCont: THandle;
  {$ELSE}
  i: Integer;
  {$ENDIF}
  BookmarksMode: Boolean;
begin
  BufCount := 0;
  FirstBatch := True;
  try
    FSearchStart := GetTickCount;
    DoMessage(HM_STRD_PREPARE,0,0);
    CalcMaxProgress;
    SetProgress(0);

    BookmarksMode := (smBookmarks in SearchMethod);

    // search within contacts
    if not BookmarksMode then begin
      // make it case-insensitive
      SearchText := Tnt_WideUpperCase(SearchText);
      if SearchMethod * [smAnyWord, smAllWords] <> [] then
        GenerateSearchWords;
    end;

    {$IFNDEF SMARTSEARCH}
    hCont := PluginLink.CallService(MS_DB_CONTACT_FINDFIRST,0,0);
    while (hCont <> 0) and not Terminated do begin
      Inc(AllContacts);
      // I hope I haven't messed this up by
      // if yes, also fix the same in CalcMaxProgress
      if SearchProtectedContacts or (not SearchProtectedContacts and (not IsUserProtected(hCont))) then begin
        if BookmarksMode then SearchBookmarks(hCont)
                         else SearchContact(hCont);
      end;
      hCont := PluginLink.CallService(MS_DB_CONTACT_FINDNEXT,hCont,0);
    end;
    if BookmarksMode then SearchBookmarks(hCont)
                     else SearchContact(hCont);
    {$ELSE}
    BuildContactsList;
    for i := Length(Contacts) - 1 downto 0 do begin
      if BookmarksMode then SearchBookmarks(Contacts[i].hContact)
                       else SearchContact(Contacts[i].hContact);
    end;
    {$ENDIF}

  finally
    // only Post..., not Send... because we wait for this thread
    // to die in this message
    DoMessage(HM_STRD_FINISHED,0,0);
  end;
end;

procedure TSearchThread.Terminate(NewPriority: TThreadPriority = tpIdle);
begin
  if (NewPriority <> tpIdle) and (NewPriority <> Priority) then
    Priority := NewPriority;
    inherited Terminate;
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
  if Terminated then exit;
  CurContactCP := GetContactCodePage(Contact);
  CurContact := Contact;
  DoMessage(HM_STRD_NEXTCONTACT,WPARAM(Contact),LPARAM(GetContactsCount));
  hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDLAST,Contact,0);
  while (hDBEvent <> 0) and (not Terminated) do begin
    if SearchEvent(hDBEvent) then SendItem(hDBEvent);
    hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDBEvent,0);
  end;
  SendBatch;
end;

procedure TSearchThread.SearchBookmarks(Contact: THandle);
var
  i: Integer;
begin
  if Terminated then exit;
  DoMessage(HM_STRD_NEXTCONTACT,WPARAM(Contact),LPARAM(GetContactsCount));
  for i := 0 to BookmarkServer[Contact].Count-1 do begin
    if Terminated then exit;
    Inc(AllEvents);
    SendItem(BookmarkServer[Contact].Items[i]);
    IncProgress;
  end;
  SendBatch;
end;

function TSearchThread.SearchEvent(DBEvent: THandle): Boolean;
var
  hi: THistoryItem;
  Passed: Boolean;
  EventDate: TDateTime;
begin
  Result := False;
  if Terminated then exit;
  Passed := True;
  if smRange in SearchMethod then begin
    EventDate := Trunc(GetEventDateTime(DBEvent));
    Passed := ((SearchRangeFrom <= EventDate) and (SearchRangeTo >= EventDate));
  end;
  if Passed then begin
    if SearchMethod * [smExact,smAnyWord,smAllWords,smEvents] <> [] then begin
      hi := ReadEvent(DBEvent, CurContactCP);
      if smEvents in SearchMethod then
        Passed := ((MessageTypesToDWord(FSearchEvents) and MessageTypesToDWord(hi.MessageType)) >= MessageTypesToDWord(hi.MessageType));
      if Passed then begin
        if smExact in SearchMethod then
          Passed := SearchTextExact(Tnt_WideUpperCase(hi.Text),SearchText) else
        if smAnyWord in SearchMethod then
          Passed := SearchTextAnyWord(Tnt_WideUpperCase(hi.Text),SearchWords) else
        if smAllWords in SearchMethod then
          Passed := SearchTextAllWords(Tnt_WideUpperCase(hi.Text),SearchWords);
      end;
    end;
  end;
  Inc(AllEvents);
  IncProgress;
  Result := Passed;
end;

function TSearchThread.SendItem(hDBEvent: Integer): Boolean;
var
  CurBuf: Integer;
begin
  Result := True;
  if Terminated then exit;
  Inc(BufCount);
  if FirstBatch then
    CurBuf := ST_FIRST_BATCH else
    CurBuf := ST_BATCH;
  Buffer[BufCount-1] := hDBEvent;
  if BufCount = CurBuf then Result := SendBatch;
end;

function TSearchThread.SendBatch;
var
  Batch: PDBArray;
begin
  Result := True;
  if Terminated then exit;
  if BufCount > 0 then begin
    GetMem(Batch,SizeOf(Batch^));
    CopyMemory(Batch,@Buffer,SizeOf(Buffer));
    Result := DoMessage(HM_STRD_ITEMSFOUND,WPARAM(Batch),LPARAM(BufCount));
    if not Result then begin
      FreeMem(Batch,SizeOf(Batch^));
      Terminate(tpHigher);
    end;
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
    DoMessage(HM_STRD_PROGRESS,WPARAM(CurProgress),LPARAM(MaxProgress));
end;

procedure TSearchThread.SetSearchRangeFrom(const Value: TDateTime);
begin
  FSearchRangeFrom := Trunc(Value);
end;

procedure TSearchThread.SetSearchRangeTo(const Value: TDateTime);
begin
  FSearchRangeTo := Trunc(Value);
end;

procedure TSearchThread.SetSearchEvents(const Value: TMessageTypes);
begin
  FSearchEvents := Value;
end;

end.
