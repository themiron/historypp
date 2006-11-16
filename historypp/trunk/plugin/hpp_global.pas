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
                  mtNickChange,mtAvatarChange,mtWATrack);
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

  TEventRecord = record
    Name: WideString;
    XML: String;
  end;

  TWideStrArray = array of WideString;
  TIntArray = array of Integer;

const

  hppName       = 'History++';
  hppShortHame  = 'History++ (2in1)';
  hppDBName     = 'HistoryPlusPlus';
  hppVerMajor   = {MAJOR_VER}1{/MAJOR_VER};
  hppVerMinor   = {MINOR_VER}5{/MINOR_VER};
  hppVerRelease = {SUB_VER}0{/SUB_VER};
  hppVerBuild   = {BUILD}109{/BUILD};
  hppVerAlpha    = {$IFDEF ALPHA}True{$ELSE}False{$ENDIF};
  hppVersion    = hppVerMajor shl 24 + hppVerMinor shl 16 + hppVerRelease shl 8 + hppVerBuild;

  hppFLUpdateURL    = 'http://addons.miranda-im.org/feed.php?dlfile=2995';
  hppFLVersionURL   = 'http://addons.miranda-im.org/details.php?action=viewfile&id=2995';
  hppFLVersionPrefix= '<span class="fileNameHeader">'+hppShortHame+' ';
  hppUpdateURL      = 'http://slav.pp.ru/miranda/historypp';
  hppVersionURL     = 'http://slav.pp.ru/miranda/version';
  hppVersionPrefix  = hppName+' version ';

  hppHomePageURL  = 'http://slav.pp.ru/miranda/';
  hppChangelogURL = 'http://slav.pp.ru/miranda/changelog';

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

var
  hppVersionStr: String;
  //hppVersionPrefix: String;
  //hppFLVersionPrefix: String;
  hppOSUnicode: Boolean;
  hppCoreUnicode: Boolean;
  hppCodepage: Cardinal;
  hppIconPack: String;
  hppProfileDir: String;

  EventRecords: array[TMessageType] of TEventRecord = (
    (Name:'Unknown';XML:''),
    (Name:'Incoming events';XML:''),
    (Name:'Outgoing events';XML:''),
    (Name:'Message';XML:'MSG'),
    (Name:'Link';XML:'URL'),
    (Name:'File transfer';XML:'FILE'),
    (Name:'System message';XML:'SYS'),
    (Name:'Contacts';XML:'ICQCNT'),
    (Name:'SMS message';XML:'SMS'),
    (Name:'Webpager message';XML:'ICQWP'),
    (Name:'EMail Express message';XML:'ICQEX'),
    (Name:'Status changes';XML:'STATUSCNG'),
    (Name:'SMTP Simple Email';XML:'SMTP'),
    (Name:'Other events (unknown)';XML:'OTHER'),
    (Name:'Nick changes';XML:'NICKCNG'),
    (Name:'Avatar changes';XML:'AVACNG'),
    (Name:'WATrack notify';XML:'WATRACK'));

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
function GetMessageRecord(MesType: TMessageTypes): TEventRecord;
function MakeTextXMLedA(Text: String): String;
function MakeTextXMLedW(Text: WideString): WideString;

implementation

uses TntSysUtils;

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
  Result := 0;
  for i := 0 to High(cpTable) do
    if cpTable[i].cp = CodePage then begin
      Result := cpTable[i].lid;
      break;
    end;
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
  AnsiStr := WideToAnsiString(WideStr,CodePage);
  ASize := Length(AnsiStr)+1;
  WSize := ASize*SizeOf(WideChar);
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

function GetMessageRecord(MesType: TMessageTypes): TEventRecord;
var
  mt: TMessageType;
begin
  exclude(MesType,mtIncoming);
  exclude(MesType,mtOutgoing);
  exclude(MesType,mtOther);
  for mt := Low(EventRecords) to High(EventRecords) do begin
    if mt in MesType then begin
      Result := EventRecords[mt];
      exit;
    end;
  end;
  Result := EventRecords[mtOther];
end;

function MakeTextXMLedA(Text: String): String;
begin;
  Result := Text;
  Result := StringReplace(Result,'&','&amp;',[rfReplaceAll]);
  Result := StringReplace(Result,'>','&gt;',[rfReplaceAll]);
  Result := StringReplace(Result,'<','&lt;',[rfReplaceAll]);
  Result := StringReplace(Result,'“','&quot;',[rfReplaceAll]);
  Result := StringReplace(Result,'‘','&apos;',[rfReplaceAll]);
end;

function MakeTextXMLedW(Text: WideString): WideString;
begin;
  Result := Text;
  Result := Tnt_WideStringReplace(Result,'&','&amp;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'>','&gt;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'<','&lt;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'“','&quot;',[rfReplaceAll]);
  Result := Tnt_WideStringReplace(Result,'‘','&apos;',[rfReplaceAll]);
end;

begin

  hppVersionStr := Format('%d.%d.%d.%d',[hppVerMajor,hppVerMinor,hppVerRelease,hppVerBuild]);
  //hppFLVersionPrefix := '<span class="fileNameHeader">History++ ';
  //hppVersionPrefix := 'History++ version ';
  hppOSUnicode := Win32PlatformIsUnicode;
  hppCoreUnicode := False;

end.
