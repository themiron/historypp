{-----------------------------------------------------------------------------
 hpp_global.pas (historypp project)

 Version:   1.5
 Created:   30.01.2006
 Author:    Oxygen

 [ Description ]

 After some refactoring, caused by dp_events, had to bring
 THistoryItem record into independant unit, so we don't have
 silly dependances of HisotoryGrid on dp_events (HistoryGrid
 doesn't depend on Miranda!) or dp_events on HistoryGrid (such
 a hog!)


 [ History ]

 1.5 (30.01.2006)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) theMIROn, 2006
-----------------------------------------------------------------------------}

unit hpp_global;

interface

uses
  Windows,SysUtils,m_globaldefs,m_api;

type

  // note: add new message types to the end, or it will mess users' saved filters
  //       don't worry about customization filters dialog, as mtOther will always
  //       be show as the last entry
  TMessageType = (mtUnknown,
                  mtIncoming, mtOutgoing,
                  mtMessage, mtUrl, mtFile, mtSystem,
                  mtContacts, mtSMS, mtWebPager, mtEmailExpress, mtStatus, mtSMTPSimple,
                  mtOther,
                  mtNickChange,mtAvatarChange,mtWATrack,mtStatusMessage,mtVoiceCall);
  TMessageTypes = set of TMessageType;
  PMessageTypes = ^TMessageTypes;

  TRTLMode = (hppRTLDefault,hppRTLEnable,hppRTLDisable);

  PHistoryItem = ^THistoryItem;
  THistoryItem = record
    Time: DWord;
    MessageType: TMessageTypes;
    EventType: Word;
    Height: Integer;
    Module: String;
    Proto: String;
    Text: WideString;
    Codepage: Cardinal;
    RTLMode: TRTLMode;
    HasHeader: Boolean;    // header for sessions
    LinkedToPrev: Boolean; // for future use to group messages from one contact together
    Bookmarked: Boolean;
    IsRead: Boolean;
    Extended: String;
  end;

  TCodePage = record
    cp: Cardinal;
    lid: LCID;
    name: WideString;
  end;

  PEventRecord = ^TEventRecord;
  TEventRecord = record
    Name: WideString;
    XML: String;
    i: SmallInt;
    iName: PChar;
    iSkin: SmallInt;
  end;

  TWideStrArray = array of WideString;
  TIntArray = array of Integer;

const

  hppName       = 'History++';
  hppShortName  = 'History++ (2in1)';
  hppShortNameV = hppShortName{$IFDEF ALPHA}+' [alpha '+{$I 'alpha.inc'}+']'{$ENDIF};
  hppDBName     = 'HistoryPlusPlus';
  hppVerMajor   = {MAJOR_VER}1{/MAJOR_VER};
  hppVerMinor   = {MINOR_VER}5{/MINOR_VER};
  hppVerRelease = {SUB_VER}0{/SUB_VER};
  hppVerBuild   = {BUILD}114{/BUILD};
  hppVerAlpha   = {$IFDEF ALPHA}True{$ELSE}False{$ENDIF};
  hppVersion    = hppVerMajor shl 24 + hppVerMinor shl 16 + hppVerRelease shl 8 + hppVerBuild;

  hppMUUID: TMUUID = (guid:'{B92282AC-686B-4541-A12D-6E9971A253B7}');

  hppDescription = 'Easy, fast and feature complete history viewer.';
  hppAuthor      = 'theMIROn, Art Fedorov';
  hppAuthorEmail = 'themiron@mail.ru, artemf@mail.ru';
  hppCopyright   = '� 2006-2007 theMIROn, 2003-2006 Art Fedorov. History+ parts � 2001 Christian Kastner';

  hppFLUpdateURL    = 'http://addons.miranda-im.org/feed.php?dlfile=2995';
  hppFLVersionURL   = 'http://addons.miranda-im.org/details.php?action=viewfile&id=2995';
  hppFLVersionPrefix= '<span class="fileNameHeader">'+hppShortName+' ';
  hppUpdateURL      = 'http://themiron.mirandaim.ru/historypp';
  hppVersionURL     = 'http://themiron.mirandaim.ru/version';
  hppVersionPrefix  = hppName+' version ';

  hppHomePageURL  = 'http://themiron.mirandaim.ru/';
  hppChangelogURL = 'http://themiron.mirandaim.ru/changelog';

  hppIPName     = 'historypp_icons.dll';

  hppLoadBlock  = 4096;
  hppFirstLoadBlock = 200;

  cpTable: array[0..14] of TCodePage = (
    (cp:  874; lid: $041E; name: 'Thai'),
    (cp:  932; lid: $0411; name: 'Japanese'),
    (cp:  936; lid: $0804; name: 'Simplified Chinese'),
    (cp:  949; lid: $0412; name: 'Korean'),
    (cp:  950; lid: $0404; name: 'Traditional Chinese'),
    (cp: 1250; lid: $0405; name: 'Central European'),
    (cp: 1251; lid: $0419; name: 'Cyrillic'),
    (cp: 1252; lid: $0409; name: 'Latin I'),
    (cp: 1253; lid: $0408; name: 'Greek'),
    (cp: 1254; lid: $041F; name: 'Turkish'),
    (cp: 1255; lid: $040D; name: 'Hebrew'),
    (cp: 1256; lid: $0801; name: 'Arabic'),
    (cp: 1257; lid: $0425; name: 'Baltic'),
    (cp: 1258; lid: $042A; name: 'Vietnamese'),
    (cp: 1361; lid: $0412; name: 'Korean (Johab)'));

const

  HPP_ICON_CONTACTHISTORY    = 0;
  HPP_ICON_GLOBALSEARCH      = 1;
  HPP_ICON_SESS_DIVIDER      = 2;
  HPP_ICON_SESSION           = 3;
  HPP_ICON_SESS_SUMMER       = 4;
  HPP_ICON_SESS_AUTUMN       = 5;
  HPP_ICON_SESS_WINTER       = 6;
  HPP_ICON_SESS_SPRING       = 7;
  HPP_ICON_SESS_YEAR         = 8;
  HPP_ICON_HOTFILTER         = 9;
  HPP_ICON_HOTFILTERWAIT     = 10;
  HPP_ICON_SEARCH_ALLRESULTS = 11;
  HPP_ICON_TOOL_SAVEALL      = 12;
  HPP_ICON_HOTSEARCH         = 13;
  HPP_ICON_SEARCHUP          = 14;
  HPP_ICON_SEARCHDOWN        = 15;
  HPP_ICON_TOOL_DELETEALL    = 16;
  HPP_ICON_TOOL_DELETE       = 17;
  HPP_ICON_TOOL_SESSIONS     = 18;
  HPP_ICON_TOOL_SAVE         = 19;
  HPP_ICON_TOOL_COPY         = 20;
  HPP_ICON_SEARCH_ENDOFPAGE  = 21;
  HPP_ICON_SEARCH_NOTFOUND   = 22;
  HPP_ICON_HOTFILTERCLEAR    = 23;
  HPP_ICON_SESS_HIDE         = 24;
  HPP_ICON_DROPDOWNARROW     = 25;
  HPP_ICON_CONTACDETAILS     = 26;
  HPP_ICON_CONTACTMENU       = 27;
  HPP_ICON_BOOKMARK          = 28;
  HPP_ICON_BOOKMARK_ON       = 29;
  HPP_ICON_BOOKMARK_OFF      = 30;
  HPP_ICON_SEARCHADVANCED    = 31;
  HPP_ICON_SEARCHRANGE       = 32;
  HPP_ICON_SEARCHPROTECTED   = 33;

  HPP_ICON_EVENT_INCOMING    = 34;
  HPP_ICON_EVENT_OUTGOING    = 35;
  HPP_ICON_EVENT_SYSTEM      = 36;
  HPP_ICON_EVENT_CONTACTS    = 37;
  HPP_ICON_EVENT_SMS         = 38;
  HPP_ICON_EVENT_WEBPAGER    = 39;
  HPP_ICON_EVENT_EEXPRESS    = 40;
  HPP_ICON_EVENT_STATUS      = 41;
  HPP_ICON_EVENT_SMTPSIMPLE  = 42;
  HPP_ICON_EVENT_NICK        = 43;
  HPP_ICON_EVENT_AVATAR      = 44;
  HPP_ICON_EVENT_WATRACK     = 45;
  HPP_ICON_EVENT_STATUSMES   = 46;
  HPP_ICON_EVENT_VOICECALL   = 47;

  HppIconsCount              = 48;

  HPP_SKIN_EVENT_MESSAGE     = 0;
  HPP_SKIN_EVENT_URL         = 1;
  HPP_SKIN_EVENT_FILE        = 2;
  HPP_SKIN_OTHER_MIRANDA     = 3;

  SkinIconsCount             = 4;


var
  hppVersionStr: String;
  //hppVersionPrefix: String;
  //hppFLVersionPrefix: String;
  hppOSUnicode: Boolean;
  hppCoreUnicode: Boolean;
  hppCodepage: Cardinal;
  hppIconPack: String;
  hppProfileDir: String;
  hppPluginsDir: String;
  hppDllName: String;

const

  EventRecords: array[TMessageType] of TEventRecord = (
    (Name:'Unknown'; XML:''; i:-1),
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
    (Name:'Voice call'; XML:'VCALL'; i:HPP_ICON_EVENT_VOICECALL; iName:'hppevn_vcall'; iSkin:-1)
  );

{$I m_historypp.inc}

function AnsiToWideString(const S: AnsiString; CodePage: Cardinal): WideString;
function WideToAnsiString(const WS: WideString; CodePage: Cardinal): AnsiString;
function TranslateAnsiW(const S: AnsiString{TRANSLATE-IGNORE}): WideString;
function TranslateWideW(const WS: WideString{TRANSLATE-IGNORE}): WideString;
function MakeFileName(FileName: AnsiString): AnsiString;
function GetLCIDfromCodepage(Codepage: Cardinal): LCID;
procedure CopyToClip(WideStr: WideString; Handle: Hwnd; CodePage: Cardinal = CP_ACP; Clear: Boolean = True);
function HppMessageBox(Handle: THandle; const Text: WideString; const Caption: WideString; Flags: Integer): Integer;
function URLEncode(const ASrc: string): string;
function GetMessageRecord(MesType: TMessageTypes): PEventRecord;
function MakeTextXMLedA(Text: String): String;
function MakeTextXMLedW(Text: WideString): WideString;
function FormatCString(Text: WideString): WideString;

implementation

uses TntSystem,TntSysUtils;

function URLEncode(const ASrc: string): string;
const
  UnsafeChars = ['*', '#', '%', '<', '>', '+', ' '];  {do not localize}
var
  i: Integer;
begin
  Result := '';    {Do not Localize}
  for i := 1 to Length(ASrc) do begin
    //if (ASrc[i] in UnsafeChars) or (ASrc[i] >= #$80) or (ASrc[1] < #32) then begin
    if (ASrc[i] in UnsafeChars) or (ASrc[1] < #32) then begin
      Result := Result + '%' + IntToHex(Ord(ASrc[i]), 2);  {do not localize}
    end else if ASrc[i] = '\' then begin
      Result := Result + '/';
    end else begin
      Result := Result + ASrc[i];
    end;
  end;
end;

function AnsiToWideString(const S: AnsiString; CodePage: Cardinal): WideString;
var
  InputLength,
  OutputLength: Integer;
begin
  if CodePage = CP_UTF8 then begin
    Result := UTF8Decode(S);         // CP_UTF8 not supported on Windows 95
  end else begin
    InputLength := Length(S);
    OutputLength := MultiByteToWideChar(CodePage,0,PChar(S),InputLength,nil,0);
    SetLength(Result,OutputLength);
    MultiByteToWideChar(CodePage,MB_PRECOMPOSED,PChar(S),InputLength,PWideChar(Result),OutputLength);
  end;
end;

function WideToAnsiString(const WS: WideString; CodePage: Cardinal): AnsiString;
var
  InputLength,
  OutputLength: Integer;
begin
  if CodePage = CP_UTF8 then
    Result := UTF8Encode(WS) // CP_UTF8 not supported on Windows 95
  else begin
    InputLength := Length(WS);
    OutputLength := WideCharToMultiByte(CodePage, 0, PWideChar(WS), InputLength, nil, 0, nil, nil);
    SetLength(Result, OutputLength);
    WideCharToMultiByte(CodePage, 0, PWideChar(WS), InputLength, PAnsiChar(Result), OutputLength, nil, nil);
  end;
end;

function TranslateAnsiW(const S: AnsiString{TRANSLATE-IGNORE}): WideString;
begin
  Result := AnsiToWideString(Translate(PChar(S)),hppCodepage{TRANSLATE-IGNORE});
end;

function TranslateWideW(const WS: WideString{TRANSLATE-IGNORE}): WideString;
begin
  if hppCoreUnicode then
    Result := TranslateW(PWideChar(WS){TRANSLATE-IGNORE})
  else
    Result := AnsiToWideString(Translate(PChar(WideToAnsiString(WS,hppCodepage))),hppCodepage{TRANSLATE-IGNORE});
end;

(*
This function gets only name of the file
and tries to make it FAT-happy, so we trim out and
":"-s, "\"-s and so on...
*)
function MakeFileName(FileName: AnsiString): AnsiString;
begin
  Result := FileName;
  Result := StringReplace(Result,':','_',[rfReplaceAll]);
  Result := StringReplace(Result,'\','_',[rfReplaceAll]);
  Result := StringReplace(Result,'/','_',[rfReplaceAll]);
  Result := StringReplace(Result,'*','_',[rfReplaceAll]);
  Result := StringReplace(Result,'?','_',[rfReplaceAll]);
  Result := StringReplace(Result,'"','''',[rfReplaceAll]);
  Result := StringReplace(Result,'<',']',[rfReplaceAll]);
  Result := StringReplace(Result,'>','[',[rfReplaceAll]);
  Result := StringReplace(Result,'|','',[rfReplaceAll]);
end;

function GetLCIDfromCodepage(Codepage: Cardinal): LCID;
var
  i: integer;
begin
  if CodePage = CP_ACP then CodePage := GetACP;
  for i := 0 to High(cpTable) do
    if cpTable[i].cp = Codepage then begin
      Result := cpTable[i].lid;
      exit;
    end;
  for i := 0 to Languages.Count-1 do
    if LCIDToCodePage(Languages.LocaleID[i]) = Codepage then begin
      Result := Languages.LocaleID[i];
      exit;
    end;
  Result := 0;
end;

procedure CopyToClip(WideStr: WideString; Handle: Hwnd; CodePage: Cardinal = CP_ACP; Clear: Boolean = True);

  function StrAllocW(Size: Cardinal): PWideChar;
  begin
    Size := SizeOf(WideChar) * Size + SizeOf(Cardinal);
    GetMem(Result, Size);
    FillChar(Result^, Size, 0);
    Cardinal(Pointer(Result)^) := Size;
    Inc(Result, SizeOf(Cardinal) div SizeOf(WideChar));
  end;

  procedure StrDisposeW(Str: PWideChar);
  begin
    if Str <> nil then begin
      Dec(Str, SizeOf(Cardinal) div SizeOf(WideChar));
      FreeMem(Str, Cardinal(Pointer(Str)^));
    end;
  end;

var
  WData, AData, LData: THandle;
  LDataPtr: PCardinal;
  WDataPtr: PWideChar;
  ADataPtr: PAnsiChar;
  ASize,WSize: Integer;
  AnsiStr: AnsiString;
begin
  WSize := (Length(WideStr)+1)*SizeOf(WideChar);
  if WSize = SizeOf(WideChar) then exit;
  AnsiStr := WideToAnsiString(WideStr,CodePage);
  ASize := Length(AnsiStr)+1;
  OpenClipboard(Handle);
  try
    if Clear then EmptyClipboard;
    WData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, WSize);
    AData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, ASize);
    LData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, SizeOf(Cardinal));
    try
      WDataPtr := GlobalLock(WData);
      ADataPtr := GlobalLock(AData);
      LDataPtr := GlobalLock(LData);
      try
        Move(WideStr[1],WDataPtr^,WSize);
        Move(AnsiStr[1],ADataPtr^,ASize);
        LDataPtr^ := GetLCIDfromCodepage(CodePage);
        SetClipboardData(CF_UNICODETEXT, WData);
        SetClipboardData(CF_TEXT, AData);
        SetClipboardData(CF_LOCALE, LData);
      finally
        GlobalUnlock(WData);
        GlobalUnlock(AData);
        GlobalUnlock(LData);
      end;
    except
      GlobalFree(WData);
      GlobalFree(AData);
      GlobalFree(LData);
    raise;
    end;
  finally
    CloseClipBoard;
  end;
end;

function HppMessageBox(Handle: THandle; const Text: WideString; const Caption: WideString; Flags: Integer): Integer;
begin
  if not hppOSUnicode then begin
    // ansi ver
    Result := MessageBox(Handle,PAnsiChar(WideToAnsiString(Text,hppCodepage)),PAnsiChar(WideToAnsiString(Caption,hppCodepage)),Flags);
  end
  else begin
    // unicode ver
    Result := MessageBoxW(Handle,PWideChar(Text),PWideChar(Caption),Flags);
  end;
end;

function GetMessageRecord(MesType: TMessageTypes): PEventRecord;
var
  mt: TMessageType;
begin
  exclude(MesType,mtIncoming);
  exclude(MesType,mtOutgoing);
  exclude(MesType,mtOther);
  for mt := Low(EventRecords) to High(EventRecords) do begin
    if mt in MesType then begin
      Result := @EventRecords[mt];
      exit;
    end;
  end;
  Result := @EventRecords[mtOther];
end;

function MakeTextXMLedA(Text: String): String;
begin;
  Result := Text;
  Result := StringReplace(Result,'&','&amp;',[rfReplaceAll]);
  Result := StringReplace(Result,'>','&gt;',[rfReplaceAll]);
  Result := StringReplace(Result,'<','&lt;',[rfReplaceAll]);
  Result := StringReplace(Result,'�','&quot;',[rfReplaceAll]);
  Result := StringReplace(Result,'�','&apos;',[rfReplaceAll]);
end;

function MakeTextXMLedW(Text: WideString): WideString;
begin;
  Result := Text;
  Result := Tnt_WideStringReplace(Result,'&','&amp;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'>','&gt;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'<','&lt;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'�','&quot;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'�','&apos;',[rfReplaceAll]);
end;

function FormatCString(Text: WideString): WideString;
var
  inlen,inpos,outpos: integer;
begin
  inlen := Length(Text);
  SetLength(Result,inlen);
  if inlen = 0 then exit;
  inpos := 1;
  outpos := 0;
  while inpos <= inlen do begin
    inc(outpos);
    if (Text[inpos] = '\') and (inpos < inlen) then begin
      case Text[inpos+1] of
        'r': begin Result[outpos] := #13; inc(inpos); end;
        'n': begin Result[outpos] := #10; inc(inpos); end;
        't': begin Result[outpos] := #09; inc(inpos); end;
        '\': begin Result[outpos] := '\'; inc(inpos); end;
      else         Result[outpos] := Text[inpos];
      end;
    end else
      Result[outpos] := Text[inpos];
    inc(inpos);
  end;
  SetLength(Result,outpos);
end;

begin

  hppVersionStr := Format('%d.%d.%d.%d',[hppVerMajor,hppVerMinor,hppVerRelease,hppVerBuild]);
  //hppFLVersionPrefix := '<span class="fileNameHeader">History++ ';
  //hppVersionPrefix := 'History++ version ';
  hppOSUnicode := Win32PlatformIsUnicode;
  hppCoreUnicode := False;

end.
