(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (‘) 2006-2007 theMIROn, 2003-2006 Art Fedorov.
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

 Contributors: theMIROn
-----------------------------------------------------------------------------}

unit hpp_richedit;

interface

uses
  Windows, Classes, RichEdit, hpp_global;

type
  PTextStream = ^TTextStream;
  TTextStream = record
    Size: Integer;
    case Boolean of
      false: (Data:  PAnsiChar);
      true:  (DataW: PWideChar);
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
//function FormatRTF2String(RichEditHandle: THandle; RTFStream: WideString): WideString; overload;
//function FormatRTF2String(RichEditHandle: THandle; RTFStream: AnsiString): WideString; overload;
function GetRichString(RichEditHandle: THandle; SelectionOnly: Boolean = false): WideString;

implementation

Uses SysUtils;

const
  SF_UNICODE = 16;
  SF_USECODEPAGE = 32;

function RichEditStreamLoad(dwCookie: Longint; pbBuff: PByte; cb: Longint; var pcb: Longint): Longint; stdcall;
var
  pBuff: PChar;
begin
  with PTextStream(dwCookie)^ do begin
    pBuff := Data;
    pcb := Size;
    if pcb > cb then pcb := cb;
    move(pBuff^,pbBuff^,pcb);
    Inc(Data,pcb);
    Dec(Size,pcb);
  end;
  Result := 0;
end;

function RichEditStreamSave(dwCookie: Longint; pbBuff: PByte; cb: Longint; var pcb: Longint): Longint; stdcall;
var
  prevSize: Integer;
begin
  with PTextStream(dwCookie)^ do begin
    prevSize := Size;
    Inc(Size,cb);
    ReallocMem(Data,Size);
    Move(pbBuff^,(Data+prevSize)^,cb);
    pcb := cb;
  end;
  Result := 0;
end;

function _GetRichRTF(RichEditHandle: THandle; TextStream: PTextStream;
                    SelectionOnly, PlainText, NoObjects, PlainRTF, Unicode: Boolean): Integer;
var
  es: TEditStream;
  format: Longint;
begin
  format := 0;
  if SelectionOnly then format := format or SFF_SELECTION;
  if PlainText then begin
    if NoObjects then format := format or SF_TEXT
                 else format := format or SF_TEXTIZED;
    if Unicode then   format := format or SF_UNICODE;
  end else begin
    if NoObjects then format := format or SF_RTFNOOBJS
                 else format := format or SF_RTF;
    if PlainRTF  then format := format or SFF_PLAINRTF;
    //if Unicode then   format := format or SF_USECODEPAGE or (CP_UTF16 shl 16);
  end;
  TextStream^.Size := 0;
  TextStream^.Data := nil;
  es.dwCookie := LPARAM(TextStream);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamSave;
  SendMessage(RichEditHandle, EM_STREAMOUT, format, LPARAM(@es));
  Result := es.dwError;
end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: WideString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Result := _GetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, NoObjects, PlainRTF, PlainText);
  if Assigned(Stream.DataW) then begin
    if PlainText then
      SetString(RTFStream,Stream.DataW,Stream.Size div SizeOf(WideChar)) else
      RTFStream := AnsiToWideString(Stream.Data,CP_ACP);
    FreeMem(Stream.Data,Stream.Size);
  end;
end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: AnsiString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Result := _GetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, NoObjects, PlainRTF, False);
  if Assigned(Stream.Data) then begin
    SetString(RTFStream,Stream.Data,Stream.Size-1);
    FreeMem(Stream.Data,Stream.Size);
  end;
end;

function _SetRichRTF(RichEditHandle: THandle; TextStream: PTextStream;
                    SelectionOnly, PlainText, PlainRTF, Unicode: Boolean): Integer;
var
  es: TEditStream;
  format: Longint;
begin
  format := 0;
  if SelectionOnly then format := format or SFF_SELECTION;
  if PlainText then begin
    format := format or SF_TEXT;
    if Unicode then format := format or SF_UNICODE;
  end else begin
    format := format or SF_RTF;

    if PlainRTF then format := format or SFF_PLAINRTF;
    //if Unicode then  format := format or SF_USECODEPAGE or (CP_UTF16 shl 16);
  end;
  es.dwCookie := LPARAM(TextStream);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamLoad;
  SendMessage(RichEditHandle, EM_STREAMIN, format, LPARAM(@es));
  Result := es.dwError;
end;

function SetRichRTF(RichEditHandle: THandle; RTFStream: WideString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
  Buffer: AnsiString;
begin
  if PlainText then begin
    Stream.DataW := @RTFStream[1];
    Stream.Size  := Length(RTFStream)*SizeOf(WideChar);
  end else begin
    Buffer := WideToAnsiString(RTFStream,CP_ACP);
    Stream.Data := @Buffer[1];
    Stream.Size  := Length(Buffer);
  end;
  Result := _SetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, PlainRTF, PlainText);
end;

function SetRichRTF(RichEditHandle: THandle; RTFStream: AnsiString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Stream.Data := @RTFStream[1];
  Stream.Size := Length(RTFStream);
  Result := _SetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, PlainRTF, False);
end;

function FormatString2RTF(Source: WideString; Suffix: String = ''): String;
var
  Text: PWideChar;
begin
  Text := PWideChar(Source);
  Result := '{\uc1 ';
  while Text[0] <> #0 do begin
    if (Text[0] = #13) and (Text[1] = #10) then begin
      Result := Result + '\par ';
      Inc(Text);
    end else
    case Text[0] of
      #10: Result := Result + '\par ';
      #09: Result := Result + '\tab ';
      '\','{','}': Result := Result + '\' + Text[0];
    else
    if word(Text[0]) < 128 then
      Result := Result + AnsiChar(Word(Text[0])) else
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
      '\','{','}': Result := Result + '\' + Text[0];
    else
      Result := Result + Text[0];
    end;
    Inc(Text);
  end;
  Result := Result + Suffix + '}';
end;

{function FormatRTF2String(RichEditHandle: THandle; RTFStream: WideString): WideString;
begin
  SetRichRTF(RichEditHandle,RTFStream,False,False,True);
  GetRichRTF(RichEditHandle,Result,False,True,True,True);
end;

function FormatRTF2String(RichEditHandle: THandle; RTFStream: AnsiString): WideString;
begin
  SetRichRTF(RichEditHandle,RTFStream,False,False,True);
  GetRichRTF(RichEditHandle,Result,False,True,True,True);
end;}

function GetRichString(RichEditHandle: THandle; SelectionOnly: Boolean = false): WideString;
begin
  GetRichRTF(RichEditHandle,Result,SelectionOnly,True,True,True);
end;

end.
