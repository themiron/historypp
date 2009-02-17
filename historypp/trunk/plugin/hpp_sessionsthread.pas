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
 logic. See TTimeThread and independent SearchText* funcs

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

unit hpp_sessionsthread;

interface

uses
  Windows, SysUtils, Controls, Messages, HistoryGrid, Classes, m_GlobalDefs,
  hpp_global, m_api, hpp_events, TntSysUtils, hpp_forms;

type
  PSess = ^TSess;
  TSess = record
    hDBEventFirst: THandle;
    TimestampFirst: DWord;
    hDBEventLast: THandle;
    TimestampLast: DWord;
    ItemsCount: DWord;
  end;

  PSessArray = ^TSessArray;
  TSessArray = array of TSess;

  TSessionsThread = class(TThread)
  private
    Buffer: TSessArray;
    BufCount: Integer;
    FirstBatch: Boolean;
    FParentHandle: Hwnd;
    FSearchTime: Cardinal;
    SearchStart: Cardinal;
    FContact: THandle;
    function DoMessage(Message: DWord; wParam: WPARAM; lParam: LPARAM): Boolean;
    function SendItem(hDBEvent,Timestamp, LastEvent, LastTimestamp, Count: DWord): Boolean;
    function SendBatch: Boolean;

  protected
    procedure Execute; override;

  public
    AllContacts, AllEvents: Integer;

    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    property Contact: THandle read FContact write FContact;
    property SearchTime: Cardinal read FSearchTime;
    property ParentHandle: Hwnd read FParentHandle write FParentHandle;

    property Terminated;
    procedure Terminate(NewPriority: TThreadPriority = tpIdle); reintroduce;
  end;

const
  HM_SESS_PREPARE    = HM_SESS_BASE + 1; // the search is prepared (0,0)
  HM_SESS_FINISHED   = HM_SESS_BASE + 2; // search finished (0,0)
  HM_SESS_ITEMSFOUND = HM_SESS_BASE + 3; // (NEW) items are found (array of hDBEvent, array size)

const
  // 2 hours
  SESSION_TIMEDIFF = 2*(60*60);
  SessionEvents: array[0..4] of Word = (
    EVENTTYPE_MESSAGE,
    EVENTTYPE_FILE,
    EVENTTYPE_URL,
    EVENTTYPE_CONTACTS,
    EVENTTYPE_SMTPSIMPLE);

function IsEventInSession(EventType: Word): boolean;

implementation

uses PassForm;

function IsEventInSession(EventType: Word): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to High(SessionEvents) do
    if SessionEvents[i] = EventType then begin
      Result := True;
      exit;
    end;
end;

{ TSessionsThread }

constructor TSessionsThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  AllContacts := 0;
  AllEvents := 0;
end;

destructor TSessionsThread.Destroy;
begin
  inherited;
  SetLength(Buffer,0);
end;

function TSessionsThread.DoMessage(Message: DWord; wParam: WPARAM; lParam: LPARAM): Boolean;
begin
  Result := PassMessage(ParentHandle,Message,wParam,lParam,smSend);
end;

procedure TSessionsThread.Execute;
var
  Event: TDBEventInfo;
  Count, LastTimestamp, FirstTimestamp: DWord;
  FirstEvent, LastEvent, hDBEvent: THandle;
  PrevTime, CurTime: DWord;
begin
  PrevTime := 0;
  SearchStart := GetTickCount;
  BufCount := 0;
  Count := 0;
  FirstBatch := True;
  try
    DoMessage(HM_SESS_PREPARE,0,0);
    hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDFIRST,FContact,0);
    while (hDBEvent <> 0) and not Terminated do begin
      ZeroMemory(@Event,SizeOf(Event));
      Event.cbSize:=SizeOf(Event);
      Event.cbBlob := 0;
      PluginLink.CallService(MS_DB_EVENT_GET,hDBEvent,Integer(@Event));
      CurTime := Event.timestamp;
      if PrevTime = 0 then begin
        PrevTime := CurTime;
        FirstEvent := hDBEvent;
        FirstTimestamp := PrevTime;
        LastEvent := hDBEvent;
        LastTimestamp := PrevTime;
        Inc(Count);
        //SendItem(hDBEvent,PrevTime);
      end
      else begin
        if IsEventInSession(Event.eventType) then
          if (CurTime - PrevTime) > SESSION_TIMEDIFF then begin
            SendItem(FirstEvent,FirstTimestamp,LastEvent,LastTimestamp,Count);
            FirstEvent := hDBEvent;
            FirstTimestamp := CurTime;
            Count := 0;
          end;
        LastEvent := hDBEvent;
        LastTimestamp := CurTime;
        Inc(Count);
        PrevTime := CurTime;
      end;
      hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBEvent,0);
    end;
    SendItem(FirstEvent,FirstTimestamp,LastEvent,LastTimestamp,Count);
    SendBatch;
  finally
    FSearchTime := GetTickCount - SearchStart;
    DoMessage(HM_SESS_FINISHED,0,0);
  end;
end;

procedure TSessionsThread.Terminate(NewPriority: TThreadPriority = tpIdle);
begin
  if (NewPriority <> tpIdle) and (NewPriority <> Priority) then
    Priority := NewPriority;
  inherited Terminate;
end;

function TSessionsThread.SendItem(hDBEvent,Timestamp, LastEvent, LastTimestamp, Count: DWord): Boolean;
begin
  Result := True;
  if Terminated then exit;
  BufCount := Length(Buffer);
  SetLength(Buffer,BufCount+1);
  Buffer[BufCount].hDBEventFirst := hDBevent;
  Buffer[BufCount].TimestampFirst := Timestamp;
  Buffer[BufCount].hDBEventLast := LastEvent;
  Buffer[BufCount].TimestampLast := LastTimestamp;
  Buffer[BufCount].ItemsCount := Count;
  Inc(BufCount);
end;

function TSessionsThread.SendBatch: Boolean;
var
  Batch: PSessArray;
begin
  Result := True;
  if Terminated then exit;
  {$RANGECHECKS OFF}
  if Length(Buffer) > 0 then begin
    GetMem(Batch,SizeOf(Buffer));
    CopyMemory(Batch,@Buffer,SizeOf(Buffer));
    Result := DoMessage(HM_SESS_ITEMSFOUND,WPARAM(Batch),Length(Buffer));
    if not Result then begin
      FreeMem(Batch,SizeOf(Buffer));
      Terminate(tpHigher);
    end;
    SetLength(Buffer,0);
    BufCount := 0;
    FirstBatch := False;
  end;
  {$RANGECHECKS ON}
end;

end.
