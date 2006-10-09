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
    Position: integer;
    Data: PString;
  end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: String;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean;
                    Unicode: Boolean = false): Integer;
function SetRichRTF(RichEditHandle: THandle; RTFStream: String;
                    SelectionOnly, PlainText, PlainRTF: Boolean;
                    Unicode: Boolean = false): Integer;
function FormatTextUnicodeRTF(Text: WideString): String;
function GetRichWideString(RichEditHandle: THandle; SelectionOnly: Boolean = false): WideString;
function RtfToWideString(RichEditHandle: THandle; RTFStream: WideString): WideString;

implementation

Uses SysUtils;

const
  SF_UNICODE = 16;
  SF_USECODEPAGE = 32;

function RichEditStreamLoad(dwCookie: Longint; pbBuff: PByte; cb: Longint; var pcb: Longint): Longint; stdcall;
var
  pBuff: PByte;
begin
  pBuff := @PTextStream(dwCookie)^.Data^[1+PTextStream(dwCookie)^.Position];
  pcb := Length(PTextStream(dwCookie)^.Data^)-PTextStream(dwCookie)^.Position;
  if pcb > cb then pcb := cb;
  move(pBuff^,pbBuff^,pcb);
  Inc(PTextStream(dwCookie)^.Position,pcb);
  Result := 0;
end;

function RichEditStreamSave(dwCookie: Longint; pbBuff: PByte; cb: Longint; var pcb: Longint): Longint; stdcall;
var
  pBuff: PChar;
  prevlen: integer;
begin
  prevlen := Length(PTextStream(dwCookie)^.Data^);
  SetLength(PTextStream(dwCookie)^.Data^,prevlen+cb);
  pBuff := @PTextStream(dwCookie)^.Data^[1+prevlen];
  Move(pbBuff^,pBuff^,cb);
  pcb := cb;
  Result := 0;
end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: String;
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
  ts.Position := 0;
  ts.Data := @RTFStream;
  es.dwCookie := integer(@ts);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamSave;
  SendMessage(RichEditHandle, EM_STREAMOUT, format, integer(@es));
  Result := es.dwError;
end;

function SetRichRTF(RichEditHandle: THandle; RTFStream: AnsiString;
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
  ts.Position := 0;
  ts.Data := @RTFStream;
  es.dwCookie := integer(@ts);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamLoad;
  SendMessage(RichEditHandle, EM_STREAMIN, format, integer(@es));
  Result := es.dwError;
end;

function FormatTextUnicodeRTF(Text: WideString): String;
var
  i: integer;
begin
  Result := '{\uc1 ';
  for i := 1 to Length(Text) do begin
    case Text[i] of
      #13: ;
      #10: Result := Result + '\line ';
      #09: Result := Result + '\tab ';
      '\': Result := Result + '\\';
      '{': Result := Result + '\{';
      '}': Result := Result + '\}';
    else
      if integer(Text[i]) < 128 then Result := Result + AnsiChar(integer(Text[i]))
                                else Result := Result + Format('\u%d ?',[integer(Text[i])]);
    end;
  end;
  Result := Result + '}';
end;

function GetRichWideString(RichEditHandle: THandle; SelectionOnly: Boolean = false): WideString;
var
  buffer: AnsiString;
begin
  GetRichRTF(RichEditHandle,buffer,SelectionOnly,True,True,True,True);
  Result := WideString(PWideChar(@buffer[1]));
end;

function RtfToWideString(RichEditHandle: THandle; RTFStream: WideString): WideString;
begin
  SetRichRTF(RichEditHandle,RTFStream,false,false,true,false);
  Result := GetRichWideString(RichEditHandle);
end;

end.
