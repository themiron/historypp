{-----------------------------------------------------------------------------
 hpp_events (historypp project)

 Version:   1.0
 Created:   05.08.2004
 Author:    Oxygen

 [ Description ]

 Some refactoring we have here, so now all event reading
 routines are here. By event reading I mean getting usefull
 info out of DB and translating it into human words,
 like reading different types of messages and such.

 [ History ]

 1.5 (05.08.2004)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) Art Fedorov, 2004
-----------------------------------------------------------------------------}

unit hpp_events;

interface

uses
  Windows, TntSystem, SysUtils, TntSysUtils, TntWideStrUtils,
  m_globaldefs, m_api,
  hpp_global, hpp_contacts;

// Miranda timestamp to TDateTime
function TimestampToDateTime(Timestamp: DWord): TDateTime;
function TimestampToString(Timestamp: DWord): WideString;
function ReadEvent(hDBEvent: THandle; UseCP: Cardinal = CP_ACP): THistoryItem;
function GetEventTimestamp(hDBEvent: THandle): DWord;
//function MessageTypeToEventType(mt: TMessageTypes): Word;

// general routine
function GetEventText(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
// specific routines
function GetEventTextForMessage(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForFile(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForUrl(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForAuthRequest(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForYouWereAdded(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForSms(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForContacts(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForWebPager(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForEmailExpress(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForStatusChange(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
function GetEventTextForOther(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;


implementation

// OXY:
// This routine UnixTimeToDate is taken from JclDateTime.pas
// See JclDateTime.pas for copyright and license information
// JclDateTime.pas is part of Project JEDI Code Library (JCL)
// [http://www.delphi-jedi.org], [http://jcl.sourceforge.net]
const
  // 1970-01-01T00:00:00 in TDateTime
  UnixTimeStart = 25569;
  SecondsPerDay = 60* 24 * 60;
function UnixTimeToDateTime(const UnixTime: DWord): TDateTime;
begin
  Result:= UnixTimeStart + (UnixTime / SecondsPerDay);
end;

// Miranda timestamp to TDateTime
function TimestampToDateTime(Timestamp: DWord): TDateTime;
begin
  Timestamp := PluginLink.CallService(MS_DB_TIME_TIMESTAMPTOLOCAL,Timestamp,0);
  Result := UnixTimeToDateTime(Timestamp);
end;

function GetEventTimestamp(hDBEvent: THandle): DWord;
var
  Event: TDBEventInfo;
begin
  ZeroMemory(@Event,SizeOf(Event));
  Event.cbSize:=SizeOf(Event);
  Event.cbBlob := 0;
  PluginLink.CallService(MS_DB_EVENT_GET,hDBEvent,Integer(@Event));
  Result := Event.timestamp;
end;

function TimestampToString(Timestamp: DWord): WideString;
var
  strdatetime: array [0..64] of Char;
  dbtts: TDBTimeToString;
begin
  dbtts.cbDest := sizeof(strdatetime);
  dbtts.szDest := @strdatetime;
  dbtts.szFormat := 'd s';
  PluginLink.CallService(MS_DB_TIME_TIMESTAMPTOSTRING,timestamp,Integer(@dbtts));
  Result := strdatetime;
end;

procedure ReadStringTillZero(Text: PChar; TextLength: LongWord; var Result: String; var Pos: LongWord);
begin
  while ((Text+Pos)^ <> #0) and (Pos < TextLength) do begin
    Result := Result + (Text+Pos)^;
    Inc(Pos);
  end;
  Inc(Pos);
end;

function GetEventTextForMessage(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
var
  //PEnd: PWideChar;
  lenW,lenA : Cardinal;
  //buf: String;
  PBlobEnd: Pointer;
  PWideStart,
  PWideEnd: PWideChar;
  FoundWideEnd: Boolean;
begin
  PBlobEnd := PChar(EventInfo.pBlob) + EventInfo.cbBlob;
  PWideStart := Pointer(StrEnd(PChar(EventInfo.pBlob))+1);
  lenA := PChar(PWideStart) - PChar(EventInfo.pBlob)-1;
  PWideEnd := PWideStart;
  FoundWideEnd := false;
  While PWideEnd < PBlobEnd do begin
    if PWideEnd^ = #0 then begin
      FoundWideEnd := true;
      break;
    end;
    Inc(PWideEnd);
  end;
  if FoundWideEnd then begin
    lenW := PWideEnd - PWideStart;
    if lenA = lenW then
      SetString(Result,PWideStart,lenW)
    else
      Result := AnsiToWideString(PChar(EventInfo.pBlob),UseCP);
  end else
    Result := AnsiToWideString(PChar(EventInfo.pBlob),UseCP);
end;

function GetEventTextForUrl(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
var
  BytePos:LongWord;
  Url,Desc: String;
begin
  BytePos:=0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Url,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Desc,BytePos);
  Result := WideFormat(TranslateWideW('URL: %s'),[AnsiToWideString(url+#13#10+desc,UseCP)]);
end;

function GetEventTextForFile(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
var
  BytePos: LongWord;
  FileName,Desc: String;
begin
  //blob is: sequenceid(DWORD),filename(ASCIIZ),description(ASCIIZ)
  BytePos:=4;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Filename,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Desc,BytePos);
  if (EventInfo.Flags and DBEF_SENT)>0 then
    Result := TranslateWideW('Outgoing file transfer: %s')
  else
    Result := TranslateWideW('Incoming file transfer: %s');
  Result := WideFormat(Result,[AnsiToWideString(FileName+#13#10+Desc,UseCP)]);
end;

function GetEventTextForAuthRequest(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
var
  BytePos: LongWord;
  uin,hContact: integer;
  Nick,Name,Email,Reason: String;
  NickW,ReasonW,ReasonUTF,ReasonACP: WideString;
begin
  //blob is: uin(DWORD), hContact(DWORD), nick(ASCIIZ), first(ASCIIZ), last(ASCIIZ), email(ASCIIZ)
  uin := PDWord(EventInfo.pBlob)^;
  hContact := PInteger(Integer(Pointer(EventInfo.pBlob))+SizeOf(Integer))^;
  BytePos:=8;
  // read nick
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Nick,BytePos);
  if Nick='' then
    NickW := GetContactDisplayName(hContact)
  else
    NickW := AnsiToWideString(Nick,CP_ACP);
  // read first name
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  Name := Name+' ';
  // read last name
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  Name := Trim(Name);
  if Name <> '' then Name:=Name + ', ';
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  if Email <> '' then Email := Email + ', ';

  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Reason,BytePos);
  ReasonUTF := AnsiToWideString(Reason,CP_UTF8);
  ReasonACP := AnsiToWideString(Reason,hppCodepage);
  if (Length(ReasonUTF) > 0) and (Length(ReasonUTF) < Length(ReasonACP)) then
    ReasonW := ReasonUTF
  else
    ReasonW := ReasonACP;
  Result := WideFormat(TranslateWideW('Authorisation request by %s (%s%d): %s'),
            [NickW,AnsiToWideString(Name+Email,hppCodepage),uin,ReasonW]);
end;

function GetEventTextForYouWereAdded(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
var
  BytePos: LongWord;
  uin,hContact: integer;
  Nick,Name,Email: String;
  NickW: WideString;
begin
  //blob is: uin(DWORD), hContact(DWORD), nick(ASCIIZ), first(ASCIIZ), last(ASCIIZ), email(ASCIIZ)
  Uin := PDWord(EventInfo.pBlob)^;
  hContact := PInteger(Integer(Pointer(EventInfo.pBlob))+SizeOf(Integer))^;
  BytePos:=8;
    // read nick
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Nick,BytePos);
  if Nick='' then
    NickW := GetContactDisplayName(hContact)
  else
    NickW := AnsiToWideString(Nick,CP_ACP);
  // read first name
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  Name := Name+' ';
  // read last name
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  Name := Trim(Name);
  if Name <> '' then Name:=Name + ', ';
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  if Email <> '' then Email := Email + ', ';
  Result := WideFormat(TranslateWideW('You were added by %s (%s%d)'),
            [NickW,AnsiToWideString(Name+Email,hppCodepage),uin]);
end;

function GetEventTextForSms(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
begin
  Result := AnsiToWideString(PChar(EventInfo.pBlob),UseCP);
end;

function GetEventTextForContacts(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
var
  BytePos: LongWord;
  Contacts: String;
begin
  BytePos := 0;
  Contacts := '';
  While BytePos < EventInfo.cbBlob do begin
    Contacts := Contacts + #13#10;
    ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Contacts,BytePos);
    Contacts := Contacts + ' (';
    ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Contacts,BytePos);
    Contacts := Contacts + ')';
  end;
  if (EventInfo.Flags and DBEF_SENT)>0 then
    Result := TranslateWideW('Outgoing contacts: %s')
  else
    Result := TranslateWideW('Incoming contacts: %s');
  Result := WideFormat(Result ,[AnsiToWideString(Contacts,UseCP)]);
end;

function GetEventTextForWebPager(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
begin
  Result := AnsiToWideString(PChar(EventInfo.pBlob),hppCodepage);
end;

function GetEventTextForEmailExpress(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
begin
  Result := AnsiToWideString(PChar(EventInfo.pBlob),hppCodepage);
end;

function GetEventTextForStatusChange(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
begin
  Result := WideFormat(TranslateWideW('Status change: %s'),[GetEventTextForMessage(EventInfo,UseCP)]);
end;

function GetEventTextForOther(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
begin
  Result := AnsiToWideString(PChar(EventInfo.pBlob),UseCP);
end;

function GetEventText(EventInfo: TDBEventInfo; UseCP: Cardinal): WideString;
begin
  case EventInfo.eventType of
    EVENTTYPE_MESSAGE:
      Result := GetEventTextForMessage(EventInfo,UseCP);
    EVENTTYPE_URL:
      Result := GetEventTextForUrl(EventInfo,UseCP);
    EVENTTYPE_AUTHREQUEST:
      Result := GetEventTextForAuthRequest(EventInfo,UseCP);
    EVENTTYPE_ADDED:
      Result := GetEventTextForYouWereAdded(EventInfo,UseCP);
    EVENTTYPE_FILE:
      Result := GetEventTextForFile(EventInfo,UseCP);
    EVENTTYPE_CONTACTS:
      Result := GetEventTextForContacts(EventInfo,UseCP);
    ICQEVENTTYPE_SMS:
      Result := GetEventTextForSms(EventInfo,UseCP);
    ICQEVENTTYPE_WEBPAGER:
      Result := GetEventTextForWebPager(EventInfo,UseCP);
    ICQEVENTTYPE_EMAILEXPRESS:
      Result := GetEventTextForEmailExpress(EventInfo,UseCP);
    EVENTTYPE_STATUSCHANGE:
      //Result := GetEventTextForStatusChange(EventInfo,UseCP);
      Result := GetEventTextForStatusChange(EventInfo,hppCodepage);
  else
      Result := GetEventTextForOther(EventInfo,UseCP);
  end;
end;

function GetEventInfo(hDBEvent: DWord): TDBEventInfo;
var
  BlobSize:Integer;
begin
  ZeroMemory(@Result,SizeOf(Result));
  Result.cbSize:=SizeOf(Result);
  BlobSize:=PluginLink.CallService(MS_DB_EVENT_GETBLOBSIZE,hDBEvent,0);
  GetMem(Result.pBlob,BlobSize);
  Result.cbBlob:=BlobSize;
  PluginLink.CallService(MS_DB_EVENT_GET,hDBEvent,Integer(@Result));
end;

{function MessageTypeToEventType(mt: TMessageTypes): Word;
begin
  Result := 9999;
  if mtMessage in mt then begin
    Result := EVENTTYPE_MESSAGE; exit; end;
  if mtAdded in mt then begin
    Result := EVENTTYPE_ADDED; exit; end;
  if mtAuthRequest in mt then begin
    Result := EVENTTYPE_AUTHREQUEST; exit; end;
  if mtUrl in mt then begin
    Result := EVENTTYPE_URL; exit; end;
  if mtAuthRequest in mt then begin
    Result := EVENTTYPE_AUTHREQUEST; exit; end;
  if mtContacts in mt then begin
    Result := EVENTTYPE_CONTACTS; exit; end;
  if mtSMS in mt then begin
    Result := ICQEVENTTYPE_SMS; exit; end;
  if mtWebPager in mt then begin
    Result := ICQEVENTTYPE_WEBPAGER; exit; end;
  if mtEmailExpress in mt then begin
    Result := ICQEVENTTYPE_EMAILEXPRESS; exit; end;
end;}

// reads event from hDbEvent handle
// reads all THistoryItem fields
// *EXCEPT* Proto field. Fill it manually, plz
function ReadEvent(hDBEvent: THandle; UseCP: Cardinal = CP_ACP): THistoryItem;
var
  EventInfo: TDBEventInfo;
begin
  ZeroMemory(@Result,SizeOf(Result));
  Result.Height := -1;
  // get details
  EventInfo := GetEventInfo(hDBEvent);
  // get module
  Result.Module := EventInfo.szModule;
  // get proto
  Result.Proto := '';
  // read text
  Result.Text := GetEventText(EventInfo,UseCP);
  Result.Text := TntAdjustLineBreaks(Result.Text);
  Result.Text := TrimRight(Result.Text);
  // free mememory for message
  if Assigned(EventInfo.pBlob) then
    FreeMem(EventInfo.pBlob);
  // get incoming or outgoing
  if ((EventInfo.flags and DBEF_SENT)=0) then
    Result.MessageType := [mtIncoming]
  else
    Result.MessageType := [mtOutgoing];
  // MS_DB_TIMESTAMPTOLOCAL should fix some issues
  Result.Time := EventInfo.timestamp;
  //Time := PluginLink.CallService(MS_DB_TIME_TIMESTAMPTOLOCAL,Time,0);
  Result.EventType := EventInfo.EventType;
  case EventInfo.EventType of
    EVENTTYPE_MESSAGE:
      Include(Result.MessageType,mtMessage);
    EVENTTYPE_FILE:
      Include(Result.MessageType,mtFile);
    EVENTTYPE_URL:
      Include(Result.MessageType,mtUrl);
    EVENTTYPE_AUTHREQUEST:
      Include(Result.MessageType,mtSystem);
    EVENTTYPE_ADDED:
      Include(Result.MessageType,mtSystem);
    EVENTTYPE_CONTACTS:
      Include(Result.MessageType,mtContacts);
    ICQEVENTTYPE_SMS:
      Include(Result.MessageType,mtSMS);
    ICQEVENTTYPE_WEBPAGER:
      //Include(Result.MessageType,mtWebPager);
      Include(Result.MessageType,mtOther);
    ICQEVENTTYPE_EMAILEXPRESS:
      //Include(Result.MessageType,mtEmailExpress);
      Include(Result.MessageType,mtOther);
    EVENTTYPE_STATUSCHANGE:
      Include(Result.MessageType,mtStatus);
  else
    Include(Result.MessageType,mtOther);
  end;
end;

end.
