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

uses
  Windows, TntSystem, SysUtils, TntSysUtils, WideStrUtils, TntWideStrUtils,
  m_globaldefs, m_api, TntWindows,
  hpp_global, hpp_contacts;

type

  TTextFunction = function(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;

  TEventTableItem = record
    EventType: Word;
    MessageType: TMessageType;
    TextFunction: TTextFunction;
  end;

// Miranda timestamp to TDateTime
function TimestampToDateTime(Timestamp: DWord): TDateTime;
function TimestampToString(Timestamp: DWord): WideString;
// general routine
function ReadEvent(hDBEvent: THandle; UseCP: Cardinal = CP_ACP): THistoryItem;
function GetEventTimestamp(hDBEvent: THandle): DWord;
// specific routines
function GetEventTextForMessage(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForFile(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForUrl(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForAuthRequest(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForYouWereAdded(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForSms(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForContacts(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForWebPager(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForEmailExpress(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForStatusChange(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForAvatarChange(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
//function GetEventTextForICQAuth(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForICQAuthGranted(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForICQAuthDenied(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForICQSelfRemove(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForICQFutureAuth(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForICQBroadcast(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
function GetEventTextForOther(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
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

  EventTable: array[0..19] of TEventTableItem = (
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
    (EventType: ICQEVENTTYPE_BROADCAST; MessageType: mtSystem; TextFunction: GetEventTextForICQBroadcast)
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
  if (EventInfo.flags and DBEF_SENT) = 0 then
    Result.MessageType := [mtIncoming]
  else
    Result.MessageType := [mtOutgoing];
  EventIndex := 0;
  for i := 1 to High(EventTable) do
    if EventTable[i].EventType = EventInfo.EventType then begin
      EventIndex := i;
      break;
    end;
  mt := EventTable[EventIndex].MessageType;
  Result.Text := EventTable[EventIndex].TextFunction(EventInfo,UseCP,mt);
  Result.Text := TntAdjustLineBreaks(Result.Text);
  Result.Text := TrimRight(Result.Text);
  include(Result.MessageType,mt);
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

function GetEventTextForMessage(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
var
  lenW,lenA : Cardinal;
  PBlobEnd: Pointer;
  PUnicode: PWideChar;
  Source,Dest: PWideChar;
begin
  PBlobEnd := PChar(EventInfo.pBlob) + EventInfo.cbBlob;
  AllocateTextBuffer(EventInfo.cbBlob+3);
  lenA :=  StrLen(StrLCopy(buffer,PChar(EventInfo.pBlob),EventInfo.cbBlob));
  PUnicode := Pointer(buffer+lenA+1);
  Dest := PUnicode;
  Source := Pointer(PChar(EventInfo.pBlob)+lenA+1);
  lenW := 0;
  While (Source < PBlobEnd) and (Source^ <> #0) do begin
    Dest^ := Source^;
    Inc(Source);
    Inc(Dest);
    Inc(lenW);
  end;
  if lenA = lenW then begin
    Dest^ := #0;
    SetString(Result,PUnicode,lenW);
  end else
    Result := AnsiToWideString(buffer,UseCP);
  if TextHasUrls(Result) then MessType := mtUrl;
end;

function GetEventTextForUrl(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
var
  BytePos:LongWord;
  Url,Desc: String;
begin
  BytePos:=0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Url,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Desc,BytePos);
  Result := WideFormat(TranslateWideW('URL: %s'),[AnsiToWideString(url+#13#10+desc,UseCP)]);
end;

function GetEventTextForFile(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
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

function GetEventTextForAuthRequest(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
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
  Result := WideFormat(TranslateWideW('Authorisation request by %s (%s%d): %s'),
            [NickW,AnsiToWideString(Name+Email,hppCodepage),uin,ReasonW]);
end;

function GetEventTextForYouWereAdded(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
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
  Result := WideFormat(TranslateWideW('You were added by %s (%s%d)'),
            [NickW,AnsiToWideString(Name+Email,hppCodepage),uin]);
end;

function GetEventTextForSms(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
begin
  Result := AnsiToWideString(PChar(EventInfo.pBlob),UseCP);
end;

function GetEventTextForContacts(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
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

function GetEventTextForWebPager(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
var
  BytePos: LongWord;
  Body,Name,Email: String;
begin
  BytePos := 0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  Result := TranslateWideW('Webpager message from %s (%s): %s');
  Result := WideFormat(Result ,[AnsiToWideString(Name,hppCodepage),
                                AnsiToWideString(Email,hppCodepage),
                                AnsiToWideString(#13#10+Body,hppCodepage)]);
end;

function GetEventTextForEmailExpress(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
var
  BytePos: LongWord;
  Body,Name,Email: String;
begin
  BytePos := 0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  Result := TranslateWideW('Email express from %s (%s): %s');
  Result := WideFormat(Result ,[AnsiToWideString(Name,hppCodepage),
                                AnsiToWideString(Email,hppCodepage),
                                AnsiToWideString(#13#10+Body,hppCodepage)]);
end;

function GetEventTextForStatusChange(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
var
  mt: TMessageType;
begin
  Result := WideFormat(TranslateWideW('Status change: %s'),[GetEventTextForMessage(EventInfo,hppCodepage,mt)]);
end;

function GetEventTextForAvatarChange(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
var
  lenW,lenA : Cardinal;
  PBlobEnd: Pointer;
  PUnicode: PWideChar;
  Source,Dest: PWideChar;
  Link: WideString;
begin
  PBlobEnd := PChar(EventInfo.pBlob) + EventInfo.cbBlob;
  AllocateTextBuffer(EventInfo.cbBlob+3);
  lenA :=  StrLen(StrLCopy(buffer,PChar(EventInfo.pBlob),EventInfo.cbBlob));
  PUnicode := Pointer(buffer+lenA+1);
  Dest := PUnicode;
  Source := Pointer(PChar(EventInfo.pBlob)+lenA+1);
  lenW := 0;
  While (Source < PBlobEnd) and (Source^ <> #0) do begin
    Dest^ := Source^;
    Inc(Source);
    Inc(Dest);
    Inc(lenW);
  end;
  if lenA = lenW then begin
    Dest^ := #0;
    SetString(Result,PUnicode,lenW)
  end else begin
    Result := AnsiToWideString(buffer,UseCP);
    lenW := 0;
  end;
  lenA := (lenA+1)+(lenW+1)*2;
  if lenA < EventInfo.cbBlob then begin
    StrLCopy(buffer,PChar(EventInfo.pBlob)+lenA,EventInfo.cbBlob-lenA);
    if StrLen(buffer) > 0 then begin
      Link := URLEncode(hppProfileDir+'/'+buffer);
      Result := Result + #13#10 + 'file://localhost/'+AnsiToWideString(Link,CP_ACP);
    end;
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

function GetEventTextForICQAuthGranted(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
begin
  Result := GetEventTextForICQAuth(EventInfo,
    TranslateWideW('Authorization request granted by %s (%d): %s'));
end;

function GetEventTextForICQAuthDenied(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
begin
  Result := GetEventTextForICQAuth(EventInfo,
    TranslateWideW('Authorization request denied by %s (%d): %s'));
end;

function GetEventTextForICQSelfRemove(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
begin
  Result := GetEventTextForICQAuth(EventInfo,
    TranslateWideW('User %s (%d) removed himself from your contact list: %s'));
end;

function GetEventTextForICQFutureAuth(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
begin
  Result := GetEventTextForICQAuth(EventInfo,
    TranslateWideW('Authorization future request by %s (%d): %s'));
end;

function GetEventTextForICQBroadcast(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
var
  BytePos: LongWord;
  Body,Name,Email: String;
begin
  BytePos := 0;
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZero(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  Result := TranslateWideW('Broadcast message from %s (%s): %s');
  Result := WideFormat(Result ,[AnsiToWideString(Name,hppCodepage),
                                AnsiToWideString(Email,hppCodepage),
                                AnsiToWideString(#13#10+Body,hppCodepage)]);
end;

function GetEventTextForOther(EventInfo: TDBEventInfo; UseCP: Cardinal; var MessType: TMessageType): WideString;
begin
  AllocateTextBuffer(EventInfo.cbBlob+1);
  StrLCopy(buffer,PChar(EventInfo.pBlob),EventInfo.cbBlob);
  Result := AnsiToWideString(buffer,UseCP);
end;

initialization
  // allocate some mem, so first ReadEvents would start faster
  calls_count := SHRINK_ON_CALL + 1;
  ShrinkTextBuffer;
finalization
  CleanupTextBuffer;
end.
