(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (�) 2006-2007 theMIROn, 2003-2006 Art Fedorov.
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

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}

unit hpp_events;

interface

{$I compilers.inc}

uses
  Windows, TntSystem, SysUtils, TntSysUtils,
  {$IFDEF COMPILER_10}WideStrUtils,{$ENDIF} TntWideStrUtils,
  m_globaldefs, m_api, TntWindows,
  hpp_global, hpp_contacts, hpp_miranda_mmi;

type

  TTextFunction = procedure(EventInfo: TDBEventInfo; var Hi: THistoryItem);

  TEventTableItem = record
    EventType: Word;
    MessageType: TMessageType;
    TextFunction: TTextFunction;
  end;

  PEventRecord = ^TEventRecord;
  TEventRecord = record
    Name: WideString;
    XML: String;
    i: SmallInt;
    iName: PChar;
    iSkin: SmallInt;
  end;

const

  EVENTTYPE_STATUSCHANGE        = 25368;  // from srmm's
  EVENTTYPE_SMTPSIMPLE          = 2350;   // from SMTP Simple
  EVENTTYPE_NICKNAMECHANGE      = 9001;   // from pescuma
  EVENTTYPE_STATUSMESSAGECHANGE = 9002;   // from pescuma
  EVENTTYPE_AVATARCHANGE        = 9003;   // from pescuma
  EVENTTYPE_CONTACTLEFTCHANNEL  = 9004;   // from pescuma
  EVENTTYPE_VOICE_CALL          = 8739;   // from pescuma

  EventRecords: array[TMessageType] of TEventRecord = (
    (Name:'Unknown'; XML:''; i:-1; iSkin:-1),
    (Name:'Incoming events'; XML:''; i:HPP_ICON_EVENT_INCOMING; iName:'hppevn_inc'; iSkin:-1),
    (Name:'Outgoing events'; XML:''; i:HPP_ICON_EVENT_OUTGOING; iName:'hppevn_out'; iSkin:-1),
    (Name:'Message'; XML:'MSG'; i:HPP_SKIN_EVENT_MESSAGE; iSkin: SKINICON_EVENT_MESSAGE),
    (Name:'Link'; XML:'URL'; i:HPP_SKIN_EVENT_URL; iSkin:SKINICON_EVENT_URL),
    (Name:'File transfer'; XML:'FILE'; i:HPP_SKIN_EVENT_FILE; iSkin:SKINICON_EVENT_FILE),
    (Name:'System message'; XML:'SYS'; i:HPP_ICON_EVENT_SYSTEM; iName:'hppevn_sys'; iSkin:-1),
    (Name:'Contacts'; XML:'ICQCNT'; i:HPP_ICON_EVENT_CONTACTS; iName:'hppevn_icqcnt'; iSkin:-1),
    (Name:'SMS message'; XML:'SMS'; i:HPP_ICON_EVENT_SMS; iName:'hppevn_sms'; iSkin:-1),
    (Name:'Webpager message'; XML:'ICQWP'; i:HPP_ICON_EVENT_WEBPAGER; iName:'hppevn_icqwp'; iSkin:-1),
    (Name:'EMail Express message'; XML:'ICQEX'; i:HPP_ICON_EVENT_EEXPRESS; iName:'hppevn_icqex'; iSkin:-1),
    (Name:'Status changes'; XML:'STATUSCNG'; i:HPP_ICON_EVENT_STATUS; iName:'hppevn_status'; iSkin:-1),
    (Name:'SMTP Simple Email'; XML:'SMTP'; i:HPP_ICON_EVENT_SMTPSIMPLE; iName:'hppevn_smtp'; iSkin:-1),
    (Name:'Other events (unknown)'; XML:'OTHER'; i:HPP_SKIN_OTHER_MIRANDA; iSkin:SKINICON_OTHER_MIRANDA),
    (Name:'Nick changes'; XML:'NICKCNG'; i:HPP_ICON_EVENT_NICK; iName:'hppevn_nick'; iSkin:-1),
    (Name:'Avatar changes'; XML:'AVACNG'; i:HPP_ICON_EVENT_AVATAR; iName:'hppevn_avatar'; iSkin:-1),
    (Name:'WATrack notify'; XML:'WATRACK'; i:HPP_ICON_EVENT_WATRACK; iName:'hppevn_watrack'; iSkin:-1),
    (Name:'Status message changes'; XML:'STATUSMSGCHG'; i:HPP_ICON_EVENT_STATUSMES; iName:'hppevn_statuschng'; iSkin:-1),
    (Name:'Voice call'; XML:'VCALL'; i:HPP_ICON_EVENT_VOICECALL; iName:'hppevn_vcall'; iSkin:-1),
    (Name:'Custom'; XML:''; i:-1; iSkin:-1)
  );

// General timstamp function
function UnixTimeToDateTime(const UnixTime: DWord): TDateTime;
function DateTimeToUnixTime(const DateTime: TDateTime): DWord;
// Miranda timestamp to TDateTime
function TimestampToDateTime(const Timestamp: DWord): TDateTime;
function TimestampToString(const Timestamp: DWord): WideString;
// general routine
function ReadEvent(hDBEvent: THandle; UseCP: Cardinal = CP_ACP): THistoryItem;
function GetEventInfo(hDBEvent: DWord): TDBEventInfo;
function GetEventTimestamp(hDBEvent: THandle): DWord;
function GetEventDateTime(hDBEvent: THandle): TDateTime;
function GetEventRecord(const Hi: THistoryItem): PEventRecord;
// global routines
function GetEventCoreText(EventInfo: TDBEventInfo; var Hi: THistoryItem): Boolean;
function GetEventModuleText(EventInfo: TDBEventInfo; var Hi: THistoryItem): Boolean;
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
procedure GetEventTextForICQClientChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForICQCheckStatus(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForICQIgnoreCheckStatus(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForICQBroadcast(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForJabberChatStates(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextWATrackRequest(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextWATrackAnswer(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextWATrackError(EventInfo: TDBEventInfo; var Hi: THistoryItem);
procedure GetEventTextForOther(EventInfo: TDBEventInfo; var Hi: THistoryItem);
// service routines
function TextHasUrls(var Text: WideString): Boolean;
function AllocateTextBuffer(len: integer): integer;
procedure CleanupTextBuffer;
procedure ShrinkTextBuffer;

implementation

uses
  hpp_options;

type
  TModuleEventRecord = record
    EventDesc: PDBEVENTTYPEDESCR;
    EventRecord: TEventRecord;
  end;

// OXY:
// Routines UnixTimeToDate and DateTimeToUnixTime are taken
// from JclDateTime.pas
// See JclDateTime.pas for copyright and license information
// JclDateTime.pas is part of Project JEDI Code Library (JCL)
// [http://www.delphi-jedi.org], [http://jcl.sourceforge.net]
const

  // 1970-01-01T00:00:00 in TDateTime
  UnixTimeStart = 25569;
  SecondsPerDay = 60* 24 * 60;

var

  EventTable: array[0..28] of TEventTableItem = (
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
    (EventType: ICQEVENTTYPE_SMS; MessageType: mtSMS; TextFunction: GetEventTextForSMS),
    (EventType: ICQEVENTTYPE_WEBPAGER; MessageType: mtWebPager; TextFunction: GetEventTextForWebPager),
    (EventType: ICQEVENTTYPE_EMAILEXPRESS; MessageType: mtEmailExpress; TextFunction: GetEventTextForEmailExpress),
    (EventType: EVENTTYPE_NICKNAMECHANGE; MessageType: mtNickChange; TextFunction: GetEventTextForMessage),
    (EventType: EVENTTYPE_STATUSMESSAGECHANGE; MessageType: mtStatusMessage; TextFunction: GetEventTextForMessage),
    (EventType: EVENTTYPE_AVATARCHANGE; MessageType: mtAvatarChange; TextFunction: GetEventTextForAvatarChange),
    (EventType: ICQEVENTTYPE_AUTH_GRANTED; MessageType: mtSystem; TextFunction: GetEventTextForICQAuthGranted),
    (EventType: ICQEVENTTYPE_AUTH_DENIED; MessageType: mtSystem; TextFunction: GetEventTextForICQAuthDenied),
    (EventType: ICQEVENTTYPE_SELF_REMOVE; MessageType: mtSystem; TextFunction: GetEventTextForICQSelfRemove),
    (EventType: ICQEVENTTYPE_FUTURE_AUTH; MessageType: mtSystem; TextFunction: GetEventTextForICQFutureAuth),
    (EventType: ICQEVENTTYPE_CLIENT_CHANGE; MessageType: mtSystem; TextFunction: GetEventTextForICQClientChange),
    (EventType: ICQEVENTTYPE_CHECK_STATUS; MessageType: mtSystem; TextFunction: GetEventTextForICQCheckStatus),
    (EventType: ICQEVENTTYPE_IGNORECHECK_STATUS; MessageType: mtSystem; TextFunction: GetEventTextForICQIgnoreCheckStatus),
    (EventType: ICQEVENTTYPE_BROADCAST; MessageType: mtSystem; TextFunction: GetEventTextForICQBroadcast),
    (EventType: JABBER_DB_EVENT_TYPE_CHATSTATES; MessageType: mtStatus; TextFunction: GetEventTextForJabberChatStates),
    (EventType: EVENTTYPE_CONTACTLEFTCHANNEL; MessageType: mtStatus; TextFunction: GetEventTextForMessage),
    (EventType: EVENTTYPE_WAT_REQUEST; MessageType: mtWATrack; TextFunction: GetEventTextWATrackRequest),
    (EventType: EVENTTYPE_WAT_ANSWER; MessageType: mtWATrack; TextFunction: GetEventTextWATrackAnswer),
    (EventType: EVENTTYPE_WAT_ERROR; MessageType: mtWATrack; TextFunction: GetEventTextWATrackError),
    (EventType: EVENTTYPE_VOICE_CALL; MessageType: mtVoiceCall; TextFunction: GetEventTextForMessage)
  );

  ModuleEventRecords: array of TModuleEventRecord;

function UnixTimeToDateTime(const UnixTime: DWord): TDateTime;
begin
  Result:= UnixTimeStart + (UnixTime / SecondsPerDay);
end;

function DateTimeToUnixTime(const DateTime: TDateTime): DWord;
begin
  Result := Trunc((DateTime-UnixTimeStart) * SecondsPerDay);
end;

// Miranda timestamp to TDateTime
function TimestampToDateTime(const Timestamp: DWord): TDateTime;
begin
  Result := UnixTimeToDateTime(PluginLink.CallService(MS_DB_TIME_TIMESTAMPTOLOCAL,Timestamp,0));
end;

// should probably add function param to use
// custom grid options object and not the global one
function TimestampToString(const Timestamp: DWord): WideString;
begin
  Result := FormatDateTime(GridOptions.DateTimeFormat,TimestampToDateTime(Timestamp));
end;

function GetEventTimestamp(hDBEvent: THandle): DWord;
var
  Event: TDBEventInfo;
begin
  ZeroMemory(@Event,SizeOf(Event));
  Event.cbSize:=SizeOf(Event);
  Event.cbBlob := 0;
  PluginLink.CallService(MS_DB_EVENT_GET,hDBEvent,LPARAM(@Event));
  Result := Event.timestamp;
end;

function GetEventDateTime(hDBEvent: THandle): TDateTime;
begin
  Result := TimestampToDateTime(GetEventTimestamp(hDBEvent));
end;

function GetEventRecord(const Hi: THistoryItem): PEventRecord;
var
  MesType: TMessageTypes;
  mt: TMessageType;
  etd: PDBEVENTTYPEDESCR;
  i,count: integer;
begin
  MesType := hi.MessageType;
  exclude(MesType,mtIncoming);
  exclude(MesType,mtOutgoing);
  exclude(MesType,mtOther);
  for mt := Low(EventRecords) to High(EventRecords) do begin
    if mt in MesType then begin
      Result := @EventRecords[mt];
      exit;
    end;
  end;
  etd := Pointer(PluginLink.CallService(MS_DB_EVENT_GETTYPE,WPARAM(PChar(hi.Module)),LPARAM(hi.EventType)));
  if etd = nil then begin
    Result := @EventRecords[mtOther];
    exit;
  end;
  count := Length(ModuleEventRecords);
  for i := 0 to count-1 do
    if ModuleEventRecords[i].EventDesc = etd then begin
      Result := @ModuleEventRecords[i].EventRecord;
      exit;
    end;
  SetLength(ModuleEventRecords,count+1);
  ModuleEventRecords[count].EventDesc := etd;
  ModuleEventRecords[count].EventRecord := EventRecords[mtOther];
  ModuleEventRecords[count].EventRecord.Name := AnsiToWideString(etd.descr,CP_ACP);
  Result := @ModuleEventRecords[count].EventRecord;
end;

var
  buffer: PChar = nil;
  buflen: Integer = 0;

const
  SHRINK_ON_CALL = 50;
  SHRINK_TO_LEN  = 512;

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
    len := ((len shr 4)+1) shl 4;
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
  BlobSize: integer;
begin
  ZeroMemory(@Result,SizeOf(Result));
  Result.cbSize := SizeOf(Result);
  BlobSize := PluginLink.CallService(MS_DB_EVENT_GETBLOBSIZE,hDBEvent,0);
  if BlobSize > 0 then
    GetMem(Result.pBlob,BlobSize) else
    BlobSize := 0;
  Result.cbBlob := BlobSize;
  if PluginLink.CallService(MS_DB_EVENT_GET,hDBEvent,LPARAM(@Result)) = 0 then
    Result.cbBlob := BlobSize else
    Result.cbBlob := 0;
end;

// reads event from hDbEvent handle
// reads all THistoryItem fields
// *EXCEPT* Proto field. Fill it manually, plz
function ReadEvent(hDBEvent: THandle; UseCP: Cardinal = CP_ACP): THistoryItem;
var
  EventInfo: TDBEventInfo;
  i,EventIndex: integer;
begin
  ZeroMemory(@Result,SizeOf(Result));
  Result.Height := -1;
  EventInfo := GetEventInfo(hDBEvent);
  try
    Result.Module := EventInfo.szModule;
    Result.Proto := '';
    Result.Time := EventInfo.timestamp;
    Result.EventType := EventInfo.EventType;
    Result.IsRead := Boolean(EventInfo.flags and DBEF_READ);
    // enable autoRTL feature
    if Boolean(EventInfo.flags and DBEF_RTL) then
     Result.RTLMode := hppRTLEnable;
    EventIndex := 0;
    for i := 1 to High(EventTable) do
      if EventTable[i].EventType = EventInfo.EventType then begin
        EventIndex := i;
        break;
      end;
    Result.Codepage := UseCP;
    Result.MessageType := [EventTable[EventIndex].MessageType];
    //if not (DatabaseNewAPI and GetEventCoreText(EventInfo,Result)) then
    if not (DatabaseNewAPI and GetEventModuleText(EventInfo,Result)) then
      EventTable[EventIndex].TextFunction(EventInfo,Result);
    if (Result.MessageType = [mtMessage]) and TextHasUrls(Result.Text) then
      Result.MessageType := [mtUrl];
    if (EventInfo.flags and DBEF_SENT) = 0 then
      include(Result.MessageType,mtIncoming) else
      include(Result.MessageType,mtOutgoing);
    Result.Text := TntAdjustLineBreaks(Result.Text);
    Result.Text := TrimRight(Result.Text);
  finally
    if Assigned(EventInfo.pBlob) then FreeMem(EventInfo.pBlob);
  end;
end;

procedure ReadStringTillZeroA(Text: PChar; Size: LongWord; var Result: String; var Pos: LongWord);
begin
  while (Pos < Size) and ((Text+Pos)^ <> #0) do begin
    Result := Result + (Text+Pos)^;
    Inc(Pos);
  end;
  Inc(Pos);
end;

procedure ReadStringTillZeroW(Text: PWideChar; Size: LongWord; var Result: WideString; var Pos: LongWord);
begin
  while (Pos < Size) and (PWideChar(Pchar(Text)+Pos)^ <> #0) do begin
    Result := Result + PWideChar(Pchar(Text)+Pos)^;
    Inc(Pos,SizeOf(WideChar));
  end;
  Inc(Pos,SizeOf(WideChar));
end;

function GetEventCoreText(EventInfo: TDBEventInfo; var Hi: THistoryItem): Boolean;
const
  datatypes: Array[False..True] of Integer = (DBVT_ASCIIZ,DBVT_WCHAR);
var
   dbegt: TDBEVENTGETTEXT;
   msg: Pointer;
begin
  dbegt.dbei := @EventInfo;
  dbegt.datatype := datatypes[hppCoreUnicode];
  dbegt.codepage := hi.Codepage;
  msg := Pointer(PluginLink.CallService(MS_DB_EVENT_GETTEXT,0,LPARAM(@dbegt)));
  Result := (msg <> nil);
  if Result then begin
    if hppCoreUnicode then
      SetString(hi.Text,PWideChar(msg),WStrLen(PWideChar(msg))) else
      hi.Text := AnsiToWideString(PChar(msg),hi.Codepage,StrLen(PChar(msg)));
    MirandaFree(msg);
  end;
end;

function GetEventModuleText(EventInfo: TDBEventInfo; var Hi: THistoryItem): Boolean;
var
   dbegt: TDBEVENTGETTEXT;
   msgW: PWideChar;
   szServiceName: array[0..99] of Char;
begin
  dbegt.dbei := @EventInfo;
  dbegt.datatype := DBVT_WCHAR;
  dbegt.codepage := hi.Codepage;
  StrFmt(szServiceName,'%s/GetEventText%d',[EventInfo.szModule,EventInfo.eventType]);
  Result := False;
  if Boolean(PluginLink.ServiceExists(szServiceName)) then begin
    msgW := PWideChar(PluginLink.CallService(szServiceName,0,LPARAM(@dbegt)));
    Result := (msgW <> nil);
    if Result then begin
      SetString(hi.Text,msgW,WStrLen(msgW));
      MirandaFree(msgW);
    end;
  end;
end;

procedure GetEventTextForMessage(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  msgA: PAnsiChar;
  msgW: PWideChar;
  msglen,lenW: Cardinal;
  i: integer;
begin
  msgA := PChar(EventInfo.pBlob);
  msglen := lstrlenA(PChar(EventInfo.pBlob))+1;
  if msglen > EventInfo.cbBlob then msglen := EventInfo.cbBlob;
  if Boolean(EventInfo.flags and DBEF_UTF) then begin
    SetLength(hi.Text,msglen);
    msgW := PWideChar(hi.Text);
    lenW := Utf8ToUnicode(msgW,msglen,msgA,msglen);
    if lenW > 0 then
      SetLength(hi.Text,lenW-1) else
      hi.Text := AnsiToWideString(msgA,hi.Codepage,msglen);
  end else begin
    lenW := 0;
    if EventInfo.cbBlob >= msglen*SizeOf(WideChar) then begin
      msgW := PWideChar(msgA+msglen);
      for i := 0 to ((EventInfo.cbBlob-msglen) div SizeOf(WideChar))-1 do
        if msgW[i] = #0 then begin
          LenW := i;
          break;
        end;
    end;
    if (lenW > 0) and (lenW < msglen) then
      SetString(hi.Text,msgW,lenW) else
      hi.Text := AnsiToWideString(msgA,hi.Codepage,msglen);
  end;
end;

procedure GetEventTextForUrl(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos:LongWord;
  Url,Desc: String;
  cp: Cardinal;
begin
  BytePos:=0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Url,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Desc,BytePos);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hi.Codepage;
  hi.Text := WideFormat(TranslateWideW('URL: %s'),[AnsiToWideString(url+#13#10+desc,cp)]);
  hi.Extended := Url;
end;

procedure GetEventTextForFile(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  FileName,Desc: String;
  cp: Cardinal;
begin
  //blob is: sequenceid(DWORD),filename(ASCIIZ),description(ASCIIZ)
  BytePos:=4;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Filename,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Desc,BytePos);
  if Boolean(EventInfo.Flags and DBEF_SENT) then
    hi.Text := TranslateWideW('Outgoing file transfer: %s') else
    hi.Text := TranslateWideW('Incoming file transfer: %s');
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hi.Codepage;
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(FileName+#13#10+Desc,cp)]);
  hi.Extended := FileName;
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
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Nick,BytePos);
  if Nick='' then
    NickW := GetContactDisplayName(hContact,'',true) else
    NickW := AnsiToWideString(Nick,CP_ACP);
  // read first name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  Name := Name+' ';
  // read last name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  Name := Trim(Name);
  if Name <> '' then Name:=Name + ', ';
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  if Email <> '' then Email := Email + ', ';
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Reason,BytePos);
  ReasonUTF := AnsiToWideString(Reason,CP_UTF8);
  ReasonACP := AnsiToWideString(Reason,hppCodepage);
  if (Length(ReasonUTF) > 0) and (Length(ReasonUTF) < Length(ReasonACP)) then
    ReasonW := ReasonUTF else
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
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Nick,BytePos);
  if Nick='' then
    NickW := GetContactDisplayName(hContact,'',True) else
    NickW := AnsiToWideString(Nick,CP_ACP);
  // read first name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  Name := Name+' ';
  // read last name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  Name := Trim(Name);
  if Name <> '' then Name:=Name + ', ';
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  if Email <> '' then Email := Email + ', ';
  hi.Text := WideFormat(TranslateWideW('You were added by %s (%s%d)'),
                        [NickW,AnsiToWideString(Name+Email,hppCodepage),uin]);
end;

procedure GetEventTextForSms(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  cp: Cardinal;
begin
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hi.Codepage;
  hi.Text := AnsiToWideString(PChar(EventInfo.pBlob),cp);
end;

procedure GetEventTextForContacts(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Contacts: String;
  cp: Cardinal;
begin
  BytePos := 0;
  Contacts := '';
  While BytePos < EventInfo.cbBlob do begin
    Contacts := Contacts + #13#10;
    ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Contacts,BytePos);
    Contacts := Contacts + ' (ICQ: ';
    ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Contacts,BytePos);
    Contacts := Contacts + ')';
  end;
  if Boolean(EventInfo.flags and DBEF_SENT) then
    hi.Text := TranslateWideW('Outgoing contacts: %s') else
    hi.Text := TranslateWideW('Incoming contacts: %s');
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hi.Codepage;
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(Contacts,cp)]);
end;

procedure GetEventTextForWebPager(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: String;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  hi.Text := TranslateWideW('Webpager message from %s (%s): %s');
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hppCodepage;
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(Name,cp),
                                 AnsiToWideString(Email,cp),
                                 AnsiToWideString(#13#10+Body,cp)]);
end;

procedure GetEventTextForEmailExpress(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: String;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  hi.Text := TranslateWideW('Email express from %s (%s): %s');
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hppCodepage;
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(Name,cp),
                                 AnsiToWideString(Email,cp),
                                 AnsiToWideString(#13#10+Body,cp)]);
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
  msglen,lenW: Cardinal;
  i: integer;
begin
  msgA := PChar(EventInfo.pBlob);
  msglen := lstrlenA(PChar(EventInfo.pBlob))+1;
  if msglen > EventInfo.cbBlob then msglen := EventInfo.cbBlob;
  if Boolean(EventInfo.flags and DBEF_UTF) then begin
    SetLength(hi.Text,msglen);
    msgW := PWideChar(hi.Text);
    lenW := Utf8ToUnicode(msgW,msglen,msgA,msglen);
    if lenW > 0 then
      SetLength(hi.Text,lenW-1) else
      hi.Text := AnsiToWideString(msgA,hi.Codepage,msglen);
  end else begin
    LenW := 0;
    if EventInfo.cbBlob >= msglen*SizeOf(WideChar) then begin
      msgW := PWideChar(msgA+msglen);
      for i := 0 to ((EventInfo.cbBlob-msglen) div SizeOf(WideChar))-1 do
        if msgW[i] = #0 then begin
          LenW := i;
          break;
        end;
    end;
    if (lenW > 0) and (lenW < msglen) then
      SetString(hi.Text,msgW,lenW) else
      hi.Text := AnsiToWideString(msgA,hi.Codepage,msglen);
    msglen := msglen+(lenW+1)*SizeOf(WideChar);
  end;
  if msglen < EventInfo.cbBlob then begin
    msgA := msgA + msglen;
    if lstrlenA(msgA) > 0 then hi.Extended := msgA;
  end;
end;

function GetEventTextForICQSystem(EventInfo: TDBEventInfo; Template: WideString): WideString;
var
  BytePos: LongWord;
  Body: String;
  uin: Integer;
  Name: WideString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  if EventInfo.cbBlob < (BytePos+4) then
    uin := 0 else
    uin := PDWord(PChar(EventInfo.pBlob)+BytePos)^;
  if EventInfo.cbBlob < (BytePos+8) then
    Name := TranslateW('''(Unknown Contact)'''{TRANSLATE-IGNORE}) else
    Name := GetContactDisplayName(PDWord(PChar(EventInfo.pBlob)+BytePos+4)^,'',true);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hppCodepage;
  Result := WideFormat(Template ,[Name,uin,AnsiToWideString(#13#10+Body,cp)]);
end;

procedure GetEventTextForICQAuthGranted(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateWideW('Authorization request granted by %s (%d): %s'));
end;

procedure GetEventTextForICQAuthDenied(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateWideW('Authorization request denied by %s (%d): %s'));
end;

procedure GetEventTextForICQSelfRemove(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateWideW('User %s (%d) removed himself from your contact list: %s'));
end;

procedure GetEventTextForICQFutureAuth(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateWideW('Authorization future request by %s (%d): %s'));
end;

procedure GetEventTextForICQClientChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateWideW('User %s (%d) changed icq client: %s'));
end;

procedure GetEventTextForICQCheckStatus(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateWideW('Status request by %s (%d):%s'));
end;

procedure GetEventTextForICQIgnoreCheckStatus(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateWideW('Ignored status request by %s (%d):%s'));
end;

procedure GetEventTextForICQBroadcast(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: String;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  hi.Text := TranslateWideW('Broadcast message from %s (%s): %s');
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hppCodepage;
  hi.Text := WideFormat(hi.Text,[AnsiToWideString(Name,cp),
                                 AnsiToWideString(Email,cp),
                                 AnsiToWideString(#13#10+Body,cp)]);
end;

procedure GetEventTextForJabberChatStates(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  if EventInfo.cbBlob = 0 then exit;
  case PByte(EventInfo.pBlob)^ of
    JABBER_DB_EVENT_CHATSTATES_GONE:
      hi.Text := TranslateWideW('closed chat session');
  end;
end;

procedure GetEventTextWATrackRequest(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := TranslateWideW('WATrack: information request');
end;

procedure GetEventTextWATrackAnswer(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Artist,Title,Album,Template: WideString;
begin
  BytePos := 0;
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Artist,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Title,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Album,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Template,BytePos);
  if (Artist <> '') or (Title <> '') or (Album <> '') then begin
    if Template <> '' then Template := Template + #13#10;
    Template := Template + WideFormat(FormatCString(
      TranslateWideW('Artist: %s\r\nTitle: %s\r\nAlbum: %s')),
      [Artist,Title,Album]);
  end;
  hi.Text := TranslateWideW('WATrack: %s');
  hi.Text := WideFormat(hi.Text,[Template]);
end;

procedure GetEventTextWATrackError(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := TranslateWideW('WATrack: request denied');
end;

procedure GetEventTextForOther(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  cp: Cardinal;
begin
  AllocateTextBuffer(EventInfo.cbBlob+1);
  StrLCopy(buffer,PChar(EventInfo.pBlob),EventInfo.cbBlob);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8 else
    cp := hi.Codepage;
  hi.Text := AnsiToWideString(buffer,cp);
end;

initialization
  // allocate some mem, so first ReadEvents would start faster
  calls_count := SHRINK_ON_CALL + 1;
  ShrinkTextBuffer;
finalization
  CleanupTextBuffer;
  SetLength(ModuleEventRecords,0);
end.
