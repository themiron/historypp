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

 Copyright (c) Art Fedorov, 2004
-----------------------------------------------------------------------------}

unit hpp_sessionsthread;

interface

uses
  Windows, SysUtils, Controls, Messages, HistoryGrid, Classes, m_GlobalDefs,
  hpp_global, m_api, hpp_events, TntSysUtils;

type
  PSessArray = ^TSessArray;
  TSessArray = array of array[0..1] of DWord;

  TSessionsThread = class(TThread)
  private
    Buffer: TSessArray;
    BufCount: Integer;
    FirstBatch: Boolean;
    FParentHandle: THandle;
    FSearchTime: Cardinal;
    SearchStart: Cardinal;
    FContact: THandle;
  protected
    procedure SendItem(hDBEvent,Timestamp: DWord);
    procedure SendBatch;
    procedure Execute; override;

    procedure DoMessage(Message: DWord; wParam, lParam: DWord);

  public
    AllContacts, AllEvents: Integer;

    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    property Contact: THandle read FContact write FContact;
    property SearchTime: Cardinal read FSearchTime;
    property ParentHandle: THandle read FParentHandle write FParentHandle;

    property Terminated;
  end;

const
  SM_BASE = WM_APP + 421;
  SM_PREPARE = SM_BASE + 1; // the search is prepared (0,0)
  SM_FINISHED = SM_BASE + 5; // search finished (0,0)
  SM_ITEMSFOUND = SM_BASE + 6; // (NEW) items are found (array of hDBEvent, array size)

const
  // 2 hours
  SESSION_TIMEDIFF = 2*(60*60);

implementation

uses PassForm;

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

procedure TSessionsThread.DoMessage(Message, wParam, lParam: DWord);
begin
  PostMessage(ParentHandle,Message,wParam,lParam);
end;

procedure TSessionsThread.Execute;
var
  Event: TDBEventInfo;
  hDBEvent: THandle;
  PrevTime, CurTime: DWord;
begin
  PrevTime := 0;
  SearchStart := GetTickCount;
  BufCount := 0;
  FirstBatch := True;
  try
    DoMessage(SM_PREPARE,0,0);
    hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDFIRST,FContact,0);
    while hDBEvent <> 0 do begin
      ZeroMemory(@Event,SizeOf(Event));
      Event.cbSize:=SizeOf(Event);
      Event.cbBlob := 0;
      PluginLink.CallService(MS_DB_EVENT_GET,hDBEvent,Integer(@Event));
      CurTime := Event.timestamp;
      if PrevTime = 0 then begin
        PrevTime := CurTime;
        SendItem(hDBEvent,PrevTime);
      end
      else begin
        if (CurTime - PrevTime) > SESSION_TIMEDIFF then begin
          SendItem(hDBEvent,CurTime);
        end;
        PrevTime := CurTime;
      end;
      hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBEvent,0);
    end;
    SendBatch;
  finally
    FSearchTime := GetTickCount - SearchStart;
    // only Post..., not Send... because we wait for this thread
    // to die in this message
    PostMessage(ParentHandle,SM_FINISHED,0,0);
  end;
 end;


procedure TSessionsThread.SendItem(hDBEvent,Timestamp: DWord);
//var
//  CurBuf: Integer;
begin
  if Terminated then
    raise EAbort.Create('Sessions thread terminated');
  //DoMessage(SM_ITEMFOUND,hDBEvent,0);
  //Inc(BufCount);
  //if FirstBatch then CurBuf := ST_FIRST_BATCH
  //else CurBuf := ST_BATCH;
  //Buffer[BufCount-1] := hDBEvent;
  SetLength(Buffer,Length(Buffer)+1);
//  Timestamp := PluginLink.CallService(MS_DB_TIME_TIMESTAMPTOLOCAL,Timestamp,0);
  Buffer[High(Buffer)][0] := hDBevent;
  Buffer[High(Buffer)][1] := Timestamp;
  BufCount := Length(Buffer);
  //if BufCount = CurBuf then begin
  //  SendBatch;
  //  end;
end;

procedure TSessionsThread.SendBatch;
var
  Batch: PSessArray;
begin
{$RANGECHECKS OFF}
  if Length(Buffer) > 0 then begin
    GetMem(Batch,SizeOf(Buffer));
    CopyMemory(Batch,@Buffer,SizeOf(Buffer));
    DoMessage(SM_ITEMSFOUND,DWord(Batch),Length(Buffer));
    BufCount := 0;
    FirstBatch := False;
  end;
{$RANGECHECKS ON}
end;

end.
