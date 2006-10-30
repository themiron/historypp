{-----------------------------------------------------------------------------
 hpp_events (historypp project)

 Version:   1.5
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

{$I compilers.inc}

uses
  Windows, TntSystem, SysUtils, TntSysUtils,
  {$IFDEF COMPILER_10}WideStrUtils,{$ENDIF} TntWideStrUtils,
  m_globaldefs, m_api, TntWindows,
  hpp_global, hpp_contacts;

type

  TTextFunction = procedure(EventInfo: TDBEventInfo; var Hi: THistoryItem);

  TEventTableItem = record
    EventType: Word;
    MessageType: TMessageType;
    TextFunction: TTextFunction;
  end;

const

  EVENTTYPE_STATUSCHANGE    = 25368;	  // from srmm's
  EVENTTYPE_SMTPSIMPLE      = 2350;		  // from SMTP Simple
  EVENTTYPE_NICKNAMECHANGE  = 9001;		  // from prescuma
  EVENTTYPE_STATUSCHANGE2   = 9002;		  // from prescuma
  EVENTTYPE_AVATARCHANGE    = 9003;     // from prescuma
  EVENTTYPE_CONTACTLEFTCHANNEL = 9004;  // from tabSRMM

// Miranda timestamp to TDateTime
function TimestampToDateTime(Timestamp: DWord): TDateTime;
function TimestampToString(Timestamp: DWord): WideString;
// general routine
function ReadEvent(hDBEvent: THandle; UseCP: Cardinal = CP_ACP): THistoryItem;
function GetEventInfo(hDBEvent: DWord): TDBEventInfo;
function GetEventTimestamp(hDBEvent: THandle): DWord;
function GetEventDateTime(hDBEvent: THandle): TDateTime;
// specific routines
procedure GetEventTextForMessage(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForFile(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForUrl(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForAuthRequest(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForYouWereAdded(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForSms(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForContacts(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForWebPager(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForEmailExpress(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForStatusChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForAvatarChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForICQAuthGranted(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForICQAuthDenied(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForICQSelfRemove(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForICQFutureAuth(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForICQBroadcast(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForOther(EventInfo: TDBEventInfo; var Hi: THistoryItem);
// service routines
function TextHasUrls(var Text: WideString): Boolean;
function AllocateTextBuffer(len: integer): integer;
procedure CleanupTextBuffer;
procedure ShrinkTextBuffer;

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

var

  EventTable: array[0..20] of TEventTableItem = (
    // must be the first item in array for unknown events
    (EventType: MaxWord; MessageType: mtOther; TextFunction: GetEventTextForOther),
    // events definitions
    (EventType: EVENTTYPE_MESSAGE; MessageType: mtMessage; TextFunction: GetEventTextForMessage),
    (EventType: EVENTTYPE_FILE; MessageType: mtFile; TextFunction: GetEventTextForFile),
    (EventType: EVENTTYPE_URL; MessageType: mtUrl; TextFunction: GetEventTextForUrl),
    (EventType: EVENTTYPE_AUTHREQUEST; MessageType: mtSystem; TextFunction: GetEventTextForAuthRequest),
    (EventType: EVENTTYPE_ADDED; MessageType: mtSystem; TextFunction: GetEventTextForYouWereAdded),
    (EventType: EVENTTYPE_CONTACTS; MessageType: mtContacts; TextFunction: GetEventTextForContacts),
    (EventType: EVENTTYPE_STATUSCHANGE; MessageType: mtStatus; TextFunction: GetEventTextForStatusChange),
    (EventType: EVENTTYPE_SMTPSIMPLE; MessageType: mtSMTPSimple; TextFunction: GetEventTextForMessage),
    (EventType: ICQEVENTTYPE_SMS; MessageType: mtOther; TextFunction: GetEventTextForSMS),
    (EventType: ICQEVENTTYPE_WEBPAGER; MessageType: mtOther; TextFunction: GetEventTextForWebPager),
    (EventType: ICQEVENTTYPE_EMAILEXPRESS; MessageType: mtOther; TextFunction: GetEventTextForEmailExpress),
    (EventType: EVENTTYPE_NICKNAMECHANGE; MessageType: mtNickChange; TextFunction: GetEventTextForMessage),
    (EventType: EVENTTYPE_STATUSCHANGE2; MessageType: mtStatus; TextFunction: GetEventTextForMessage),
    (EventType: EVENTTYPE_AVATARCHANGE; MessageType: mtAvatarChange; TextFunction: GetEventTextForAvatarChange),
    (EventType: ICQEVENTTYPE_AUTH_GRANTED; MessageType: mtSystem; TextFunction: GetEventTextForICQAuthGranted),
    (EventType: ICQEVENTTYPE_AUTH_DENIED; MessageType: mtSystem; TextFunction: GetEventTextForICQAuthDenied),
    (EventType: ICQEVENTTYPE_SELF_REMOVE; MessageType: mtSystem; TextFunction: GetEventTextForICQSelfRemove),
    (EventType: ICQEVENTTYPE_FUTURE_AUTH; MessageType: mtSystem; TextFunction: GetEventTextForICQFutureAuth),
    (EventType: ICQEVENTTYPE_BROADCAST; MessageType: mtSystem; TextFunction: GetEventTextForICQBroadcast),
    (EventType: EVENTTYPE_CONTACTLEFTCHANNEL; MessageType: mtStatus; TextFunction: GetEventTextForMessage)
  );

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

function GetEventDateTime(hDBEvent: THandle): TDateTime;
begin
  Result := TimestampToDateTime(GetEventTimestamp(hDBEvent));
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
{var
  strdatetime: array [0..64] of Char;
  dbtts: TDBTimeToString;}
begin
  {dbtts.cbDest := sizeof(strdatetime);
  dbtts.szDest := @strdatetime;
  dbtts.szFormat := 'd s';
  PluginLink.CallService(MS_DB_TIME_TIMESTAMPTOSTRING,timestamp,Integer(@dbtts));
  Result := strdatetime;}
  Result := DateTimeToStr(TimestampToDateTime(Timestamp));
end;

var
  buffer: PChar = nil;
  buflen: Integer = 0;

const
  SHRINK_ON_CALL = 50;
  SHRINK_TO_LEN  = 500;

var
  calls_count: Integer = 0;

procedure CleanupTextBuffer;
begin
  FreeMem(buffer,buflen);
  buffer := nil;
  buflen := 0;
end;

procedure ShrinkTextBuffer;
begin
  // shrink find_buf on every SHRINK_ON_CALL event, so it's not growing to infinity
  if calls_count >= SHRINK_ON_CALL then begin
    buflen := SHRINK_TO_LEN;
    ReallocMem(buffer,buflen);
    calls_count := 0;
  end else
    Inc(calls_count);
end;

function AllocateTextBuffer(len: integer): integer;
begin
  ShrinkTextBuffer;
  if len > buflen then begin
    ReallocMem(buffer,len);
    buflen := len;
  end;
  Result := len;
end;

function TextHasUrls(var Text: WideString): Boolean;
var
  len,lenW: Integer;
  HasProto, HasWWW: Boolean;
begin
  Result := False;
  HasProto := WStrPos(@Text[1],'://') <> nil;
  HasWWW := WStrPos(@Text[1],'www.') <> nil;
  if (not HasProto) and (not HasWWW) then exit;
  if HasWWW then begin
    Result := True;
    exit;
  end;

  len := Length(Text);
  lenW := AllocateTextBuffer((len+1)*SizeOf(WideChar));
  Move(Text[1],PWideChar(buffer)^,lenW);
  Tnt_CharLowerBuffW(PWideChar(buffer),len);

  if HasProto then begin
    // note: we can make it one big OR clause, but it's more readable this way
    // list strings in order of probability
    Result := WStrPos(PWideChar(buffer), 'http://') <> nil;
    if Result then exit;
    Result := WStrPos(PWideChar(buffer), 'ftp://') <> nil;
    if Result then exit;
    Result := WStrPos(PWideChar(buffer), 'https://') <> nil;
    if Result then exit;
    Result := WStrPos(PWideChar(buffer), 'nntp://') <> nil;
    if Result then exit;
    Result := WStrPos(PWideChar(buffer), 'irc://') <> nil;
    if Result then exit;
    Result := WStrPos(PWideChar(buffer), 'news://') <> nil;
    if Result then exit;
    Result := WStrPos(PWideChar(buffer), 'file://') <> nil;
    if Result then exit;
    //Result := WStrPos(find_buf, 'opera:') <> nil;
    //if Result then exit;
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

// reads event from hDbEvent handle
// reads all THistoryItem fields
// *EXCEPT* Proto field. Fill it manually, plz
function ReadEvent(hDBEvent: THandle; UseCP: Cardinal = CP_ACP): THistoryItem;
var
  EventInfo: TDBEventInfo;
  i,EventIndex: integer;
  mt: TMessageType;
begin
  ZeroMemory(@Result,SizeOf(Result));
  Result.Height := -1;
  EventInfo := GetEventInfo(hDBEvent);
  Result.Module := EventInfo.szModule;
  Result.Proto := '';
  Result.Time := EventInfo.timestamp;
  Result.EventType := EventInfo.EventType;
  Result.IsRead := boolean(EventInfo.flags and DBEF_READ);
  // enable autoRTL feature
  if boolean(EventInfo.flags and DBEF_RTL) then
   Result.RTLMode := hppRTLEnable;
  EventIndex := 0;
  for i := 1 to High(EventTable) do
    if EventTable[i].EventType = EventInfo.EventType then begin
      EventIndex := i;
      break;
    end;
  Result.Codepage := UseCP;
  Result.MessageType := [EventTable[EventIndex].MessageType];
  EventTable[EventIndex].TextFunction(EventInfo,Result);
  if (EventInfo.flags and DBEF_SENT) = 0 then
    include(Result.MessageType,mtIncoming)
  else
    include(Result.MessageType,mtOutgoing);
  Result.Text := TntAdjustLineBreaks(Result.Text);
  Result.Text := TrimRight(Result.Text);
  if Assigned(EventInfo.pBlob) then FreeMem(EventInfo.pBlob);
end;

procedure ReadStringTillZero(Text: PChar; TextLength: LongWord; var Result: String; var Pos: LongWord);
begin
  while ((Text+Pos)^ <> #0) and (Pos < TextLength) do begin
    Result := Result + (Text+Pos)^;
    Inc(Pos);
  end;
  Inc(Pos);
end;

procedure GetEventTextForMessage(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  msgA: PAnsiChar;
  msgW: PWideChar;
  msglen: integer;
  i,lenW: integer;
  UseUnicode: boolean;
begin
  msgA := PChar(EventInfo.pBlob);
  msglen := lstrlenA(PChar(EventInfo.pBlob))+1;
  if EventInfo.cbBlob >= msglen*SizeOf(WideChar) then begin
    msgW := PWideChar(msgA+msglen);
    LenW := 0;
    for i := 0 to (EventInfo.cbBlob-msglen) div SizeOf(WideChar) do
      if msgW[i] = #0 then begin
        LenW := i;
        break;
      end;
    UseUnicode := (lenW <= (msglen-1)) and (lenW > 0);
  end else UseUnicode := false;
  if UseUnicode then
    SetString(hi.Text,msgW,lenW)
  else
    hi.Text := AnsiToWideString(msgA,hi.Codepage);
  if TextHasUrls(hi.Text) then
    hi.MessageType := [mtUrl];
end;

procedure GetEventTextForUrl(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos:LongWord;
  Url,Desc: String;
begin
  BytePos:=0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Url,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Desc,BytePos);
  Hi.Text := WideFormat(TranslateWideW('URL: %s'),[AnsiToWideString(url+#13#10+desc,hi.Codepage)]);
  Hi.FileRecord := Url;
end;

procedure GetEventTextForFile(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  FileName,Desc: String;
begin
  //blob is: sequenceid(DWORD),filename(ASCIIZ),description(ASCIIZ)
  BytePos:=4;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Filename,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Desc,BytePos);
  if (EventInfo.Flags and DBEF_SENT)>0 then
    hi.Text := TranslateWideW('Outgoing file transfer: %s')
  else
    hi.Text := TranslateWideW('Incoming file transfer: %s');
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(FileName+#13#10+Desc,hi.Codepage)]);
  hi.FileRecord := FileName;
end;

procedure GetEventTextForAuthRequest(EventInfo: TDBEventInfo; var Hi: THistoryItem);
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
    NickW := GetContactDisplayName(hContact,'',true)
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
  hi.Text := WideFormat(TranslateWideW('Authorisation request by %s (%s%d): %s'),
                        [NickW,AnsiToWideString(Name+Email,hppCodepage),uin,ReasonW]);
end;

procedure GetEventTextForYouWereAdded(EventInfo: TDBEventInfo; var Hi: THistoryItem);
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
    NickW := GetContactDisplayName(hContact,'',true)
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
  hi.Text := WideFormat(TranslateWideW('You were added by %s (%s%d)'),
                        [NickW,AnsiToWideString(Name+Email,hppCodepage),uin]);
end;

procedure GetEventTextForSms(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := AnsiToWideString(PChar(EventInfo.pBlob),hi.Codepage);
end;

procedure GetEventTextForContacts(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Contacts: String;
begin
  BytePos := 0;
  Contacts := '';
  While BytePos < EventInfo.cbBlob do begin
    Contacts := Contacts + #13#10;
    ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Contacts,BytePos);
    Contacts := Contacts + ' (ICQ: ';
    ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Contacts,BytePos);
    Contacts := Contacts + ')';
  end;
  if (EventInfo.flags and DBEF_SENT) = 0 then
    hi.Text := TranslateWideW('Incoming contacts: %s')
  else
    hi.Text := TranslateWideW('Outgoing contacts: %s');
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(Contacts,hi.Codepage)]);
end;

procedure GetEventTextForWebPager(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: String;
begin
  BytePos := 0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  hi.Text := TranslateWideW('Webpager message from %s (%s): %s');
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(Name,hppCodepage),
                                 AnsiToWideString(Email,hppCodepage),
                                 AnsiToWideString(#13#10+Body,hppCodepage)]);
end;

procedure GetEventTextForEmailExpress(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: String;
begin
  BytePos := 0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  hi.Text := TranslateWideW('Email express from %s (%s): %s');
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(Name,hppCodepage),
                                 AnsiToWideString(Email,hppCodepage),
                                 AnsiToWideString(#13#10+Body,hppCodepage)]);
end;

procedure GetEventTextForStatusChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  tmp: THistoryItem;
begin
  tmp.Codepage := hppCodepage;
  GetEventTextForMessage(EventInfo,tmp);
  hi.Text := WideFormat(TranslateWideW('Status change: %s'),[tmp.Text]);
end;

procedure GetEventTextForAvatarChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  msgA: PAnsiChar;
  msgW: PWideChar;
  msglen: integer;
  i,lenW: integer;
  UseUnicode: boolean;
  Link: WideString;
begin
  msgA := PChar(EventInfo.pBlob);
  msglen := lstrlenA(PChar(EventInfo.pBlob))+1;
  LenW := 0;
  if EventInfo.cbBlob >= msglen*SizeOf(WideChar) then begin
    msgW := PWideChar(msgA+msglen);
    for i := 0 to (EventInfo.cbBlob-msglen) div SizeOf(WideChar) do
      if msgW[i] = #0 then begin
        LenW := i;
        break;
      end;
    UseUnicode := (lenW <= (msglen-1)) and (lenW > 0);
  end else UseUnicode := false;
  if UseUnicode then
    SetString(hi.Text,msgW,lenW)
  else
    hi.Text := AnsiToWideString(msgA,hi.Codepage);
  msglen := msglen+(lenW+1)*SizeOf(WideChar);
  if msglen < EventInfo.cbBlob then begin
    msgA := msgA + msglen;
    if lstrlenA(msgA) > 0 then hi.FileRecord := msgA;
  end;
end;

function GetEventTextForICQAuth(EventInfo: TDBEventInfo; Template: WideString): WideString;
var
  BytePos: LongWord;
  Body: String;
  uin: integer;
  Name: WideString;
begin
  BytePos := 0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  if EventInfo.cbBlob < (BytePos+4) then uin := 0
  else uin := PDWord(PChar(EventInfo.pBlob)+BytePos)^;
  if EventInfo.cbBlob < (BytePos+8) then Name := TranslateW('''(Unknown Contact)'''{TRANSLATE-IGNORE})
  else Name := GetContactDisplayName(PDWord(PChar(EventInfo.pBlob)+BytePos+4)^,'',true);
  Result := WideFormat(Template ,[Name,uin,AnsiToWideString(#13#10+Body,hppCodepage)]);
end;

procedure GetEventTextForICQAuthGranted(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQAuth(EventInfo,
    TranslateWideW('Authorization request granted by %s (%d): %s'));
end;

procedure GetEventTextForICQAuthDenied(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQAuth(EventInfo,
    TranslateWideW('Authorization request denied by %s (%d): %s'));
end;

procedure GetEventTextForICQSelfRemove(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQAuth(EventInfo,
    TranslateWideW('User %s (%d) removed himself from your contact list: %s'));
end;

procedure GetEventTextForICQFutureAuth(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQAuth(EventInfo,
    TranslateWideW('Authorization future request by %s (%d): %s'));
end;

procedure GetEventTextForICQBroadcast(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: String;
begin
  BytePos := 0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  hi.Text := TranslateWideW('Broadcast message from %s (%s): %s');
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(Name,hppCodepage),
                                 AnsiToWideString(Email,hppCodepage),
                                 AnsiToWideString(#13#10+Body,hppCodepage)]);
end;

procedure GetEventTextForOther(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  AllocateTextBuffer(EventInfo.cbBlob+1);
  StrLCopy(buffer,PChar(EventInfo.pBlob),EventInfo.cbBlob);
  hi.Text := AnsiToWideString(buffer,hi.Codepage);
end;

initialization
  // allocate some mem, so first ReadEvents would start faster
  calls_count := SHRINK_ON_CALL + 1;
  ShrinkTextBuffer;
finalization
  CleanupTextBuffer;
end.
