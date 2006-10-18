{-----------------------------------------------------------------------------
 hpp_richedit(historypp project)

 Version:   1.0
 Created:   12.09.2006
 Author:    theMIROn

 [ Description ]


 [ History ]

 1.0 (12.09.2006)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) theMIROn, 2006
-----------------------------------------------------------------------------}

unit hpp_richedit;

interface

uses
  Windows, Classes, RichEdit, hpp_global;

type
  PTextStream = ^TTextStream;
  TTextStream = record
    Size: integer;
    case Boolean of
      True: (DataIn: PByte);
      False: (DataOut: PString);
  end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: WideString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer; overload;
function GetRichRTF(RichEditHandle: THandle; var RTFStream: AnsiString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer; overload;
function SetRichRTF(RichEditHandle: THandle; RTFStream: WideString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer; overload;
function SetRichRTF(RichEditHandle: THandle; RTFStream: AnsiString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer; overload;
function FormatString2RTF(Source: WideString; Suffix: String = ''): String; overload;
function FormatString2RTF(Source: AnsiString; Suffix: String = ''): String; overload;
function FormatRTF2String(RichEditHandle: THandle; RTFStream: WideString): WideString; overload;
function FormatRTF2String(RichEditHandle: THandle; RTFStream: AnsiString): WideString; overload;
function GetRichString(RichEditHandle: THandle; SelectionOnly: Boolean = false): WideString;

implementation

Uses SysUtils, TntSysUtils;

const
  SF_UNICODE = 16;
  SF_USECODEPAGE = 32;

function RichEditStreamLoad(dwCookie: Longint; pbBuff: PByte; cb: Longint; var pcb: Longint): Longint; stdcall;
var
  pBuff: PByte;
begin
  with PTextStream(dwCookie)^ do begin
    pBuff := DataIn;
    pcb := Size;
    if pcb > cb then pcb := cb;
    move(pBuff^,pbBuff^,pcb);
    Inc(DataIn,pcb);
    Dec(Size,pcb);
  end;
  Result := 0;
end;

function RichEditStreamSave(dwCookie: Longint; pbBuff: PByte; cb: Longint; var pcb: Longint): Longint; stdcall;
var
  pBuff: PChar;
  prevlen: integer;
begin
  with PTextStream(dwCookie)^ do begin
    prevlen := Length(DataOut^);
    SetLength(DataOut^,prevlen+cb);
    pBuff := @DataOut^[1+prevlen];
    Move(pbBuff^,pBuff^,cb);
    pcb := cb;
  end;
  Result := 0;
end;

function _GetRichRTF(RichEditHandle: THandle; var RTFStream: String;
                    SelectionOnly, PlainText, NoObjects, PlainRTF, Unicode: Boolean): Integer;
var
  es: TEditStream;
  ts: TTextStream;
  format: Longint;
begin
  format := 0;
  if Unicode then format := format or SF_UNICODE;
  if SelectionOnly then format := format or SFF_SELECTION;
  if PlainRTF then format := format or SFF_PLAINRTF;
  if PlainText then begin
    if NoObjects then format := format or SF_TEXT
                 else format := format or SF_TEXTIZED;
  end else begin
    if NoObjects then format := format or SF_RTFNOOBJS
                 else format := format or SF_RTF;
  end;
  RTFStream := '';
  ts.Size := 0;
  ts.DataOut := @RTFStream;
  es.dwCookie := integer(@ts);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamSave;
  SendMessage(RichEditHandle, EM_STREAMOUT, format, integer(@es));
  Result := es.dwError;
end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: WideString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
var
  Buffer: AnsiString;
begin
  _GetRichRTF(RichEditHandle,Buffer,SelectionOnly,PlainText,NoObjects,PlainRTF,True);
  SetString(RTFStream,PWideChar(@Buffer[1]),Length(Buffer) div SizeOf(WideChar));
  if PlainText then RTFStream := TntAdjustLineBreaks(RTFStream);
end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: AnsiString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
begin
  _GetRichRTF(RichEditHandle,RTFStream,SelectionOnly,PlainText,NoObjects,PlainRTF,False);
  if PlainText then RTFStream := AdjustLineBreaks(RTFStream);
end;

function _SetRichRTF(RichEditHandle: THandle; Buffer: PByte; Length: integer;
                    SelectionOnly, PlainText, PlainRTF, Unicode: Boolean): Integer;
var
  es: TEditStream;
  ts: TTextStream;
  format: Longint;
begin
  format := 0;
  if Unicode then format := format or SF_UNICODE;
  if SelectionOnly then format := format or SFF_SELECTION;
  if PlainRTF then format := format or SFF_PLAINRTF;
  if PlainText then format := format or SF_TEXT
               else format := format or SF_RTF;
  ts.DataIn := Buffer;
  ts.Size := Length;
  es.dwCookie := integer(@ts);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamLoad;
  SendMessage(RichEditHandle, EM_STREAMIN, format, integer(@es));
  Result := es.dwError;
end;

function SetRichRTF(RichEditHandle: THandle; RTFStream: WideString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
begin
  _SetRichRTF(RichEditHandle,@RTFStream[1],Length(RTFStream),SelectionOnly,PlainText,PlainRTF,True);
end;

function SetRichRTF(RichEditHandle: THandle; RTFStream: AnsiString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
begin
  _SetRichRTF(RichEditHandle,@RTFStream[1],Length(RTFStream),SelectionOnly,PlainText,PlainRTF,False);
end;

function FormatString2RTF(Source: WideString; Suffix: String = ''): String;
var
  Text: PWideChar;
begin
  Text := PWideChar(Source);
  Result := '{\uc1 ';
  while Text[0] <> #0 do begin
    if (Text[0] = #13) and (Text[1] = #10) then begin
      Result := Result + '\line ';
      Inc(Text);
    end else
    case Text[0] of
      #10: Result := Result + '\line ';
      #09: Result := Result + '\tab ';
      '\','{','}': Result := Result + Text[1];
    else
      if word(Text[0]) < word(High(AnsiChar)) then
        Result := Result + AnsiChar(integer(Text[0]))
      else
        Result := Result + Format('\u%d?',[word(Text[0])]);
    end;
    Inc(Text);
  end;
  Result := Result + Suffix + '}';
end;

function FormatString2RTF(Source: AnsiString; Suffix: String = ''): String;
var
  Text: PChar;
begin
  Text := PChar(Source);
  Result := '{';
  while Text[0] <> #0 do begin
    if (Text[0] = #13) and (Text[1] = #10) then begin
      Result := Result + '\line ';
      Inc(Text);
    end else
    case Text[0] of
      #10: Result := Result + '\line ';
      #09: Result := Result + '\tab ';
      '\','{','}': Result := Result + Text[1];
    else
      Result := Result + Text[0];
    end;
    Inc(Text);
  end;
  Result := Result + Suffix + '}';
end;

function FormatRTF2String(RichEditHandle: THandle; RTFStream: WideString): WideString;
begin
  SetRichRTF(RichEditHandle,RTFStream,false,false,true);
  GetRichRTF(RichEditHandle,Result,False,True,True,True);
  Result := TntAdjustLineBreaks(Result);
end;

function FormatRTF2String(RichEditHandle: THandle; RTFStream: AnsiString): WideString;
begin
  SetRichRTF(RichEditHandle,RTFStream,false,false,true);
  GetRichRTF(RichEditHandle,Result,False,True,True,True);
  Result := TntAdjustLineBreaks(Result);
end;

function GetRichString(RichEditHandle: THandle; SelectionOnly: Boolean = false): WideString;
begin
  GetRichRTF(RichEditHandle,Result,SelectionOnly,True,True,True);
end;

end.
