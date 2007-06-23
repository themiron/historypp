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
 hpp_itemprocess (historypp project)

 Version:   1.5
 Created:   05.08.2004
 Author:    Oxygen

 [ Description ]

 Module for people to help get aquanted with ME_HPP_RICHEDIT_ITEMPROCESS
 Has samples for SmileyAdd, TextFormat, Math Module and new procedure
 called SeparateDialogs. It makes message black if previous was hour ago,
 kinda of conversation separation

 [ History ]

 1.5 (05.08.2004)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}

{$DEFINE _OLD_MATHMOD}

unit hpp_itemprocess;

interface

uses
  Windows, Messages, SysUtils,
  m_globaldefs, m_api,
  hpp_global, hpp_events, hpp_richedit, hpp_richedit_ole;

type

  TRTFColorTable = record
    sz: String;
    col: COLORREF;
  end;

  WideAnsiRecord = record
    w: WideString;
    a: AnsiString;
  end;

  TBBCodeInfo = record
    ss: WideAnsiRecord;
    es: WideAnsiRecord;
    simple: boolean;
    rtf: String;
    sshtml: String;
    eshtml: String;
  end;

var
  rtf_ctable_text: String;

  function DoSupportBBCodesHTML(S: String): String;
  function DoSupportBBCodesRTF(S: String; StartColor: integer; doColorBBCodes: boolean): String;
  function DoStripBBCodes(S: WideString): WideString;

  function DoSupportSmileys(wParam, lParam: DWord): Integer;
  function DoSupportMathModule(wParam, lParam: DWord): Integer;
  function DoSupportAvatarHistory(wParam, lParam: DWord): Integer;

implementation

uses StrUtils, TntSysUtils, RichEdit;

const

  bbCodes: array[0..9] of TBBCodeInfo = (
    (ss:(w:'[b]';     a:'[b]');     es:(w:''; a:'');  simple:true;  rtf:'\b ';       sshtml:'<b>';          eshtml:''),
    (ss:(w:'[/b]';    a:'[/b]');    es:(w:''; a:'');  simple:true;  rtf:'\b0 ';      sshtml:'</b>';         eshtml:''),
    (ss:(w:'[i]';     a:'[i]');     es:(w:''; a:'');  simple:true;  rtf:'\i ';       sshtml:'<i>';          eshtml:''),
    (ss:(w:'[/i]';    a:'[/i]');    es:(w:''; a:'');  simple:true;  rtf:'\i0 ';      sshtml:'</i>';         eshtml:''),
    (ss:(w:'[u]';     a:'[u]');     es:(w:''; a:'');  simple:true;  rtf:'\ul ';      sshtml:'<u>';          eshtml:''),
    (ss:(w:'[/u]';    a:'[/u]');    es:(w:''; a:'');  simple:true;  rtf:'\ul0 ';     sshtml:'</u>';         eshtml:''),
    (ss:(w:'[s]';     a:'[s]');     es:(w:''; a:'');  simple:true;  rtf:'\strike ';  sshtml:'<s>';          eshtml:''),
    (ss:(w:'[/s]';    a:'[/s]');    es:(w:''; a:'');  simple:true;  rtf:'\strike0 '; sshtml:'</s>';         eshtml:''),
    (ss:(w:'[color='; a:'[color='); es:(w:']';a:']'); simple:false; rtf:'\cf%u ';    sshtml:'<font color='; eshtml:'>'),
    (ss:(w:'[/color]';a:'[/color]');es:(w:''; a:'');  simple:true;  rtf:'\cf0 ';     sshtml:'</font>';      eshtml:''));

  rtf_ctable: array[0..7] of TRTFColorTable = (
    //                 BBGGRR
    (sz:'black';  col:$000000),
    (sz:'red';    col:$0000FF),
    (sz:'blue';   col:$FF0000),
    (sz:'green';  col:$00FF00),
    (sz:'magenta';col:$FF00FF),
    (sz:'cyan';   col:$FFFF00),
    (sz:'yellow'; col:$00FFFF),
    (sz:'white';  col:$FFFFFF));

var
  i: integer;

function GetColorRTF(code: String; colcount: integer): integer;
var
  i: integer;
begin
  Result := 0;
  if colcount >= 0 then
    for i := 0 to High(rtf_ctable) do
      if code = rtf_ctable[i].sz then begin
        Result := colcount+i;
        break;
      end;
end;

function DoSupportBBCodesRTF(S: String; StartColor: integer; doColorBBCodes: boolean): String;
var
  i,spos,epos,cpos: integer;
  trail,code: WideString;
  color: integer;
  RTFStream: String;
begin
  RTFStream := S;
  for i := 0 to High(bbCodes) do begin
    if bbCodes[i].simple then
      RTFStream := StringReplace(RTFStream,bbCodes[i].ss.a,bbCodes[i].rtf,[rfReplaceAll])
    else repeat
      spos := Pos(bbCodes[i].ss.a,RTFStream);
      if spos > 0 then begin
        cpos := spos+Length(bbCodes[i].ss.a);
        epos := PosEx(bbCodes[i].es.a,RTFStream,cpos);
        if epos > cpos then begin
          code := Copy(RTFStream,cpos,epos-cpos);
          cpos := epos+Length(bbCodes[i].es.a);
          trail := Copy(RTFStream,cpos,Length(RTFStream)-cpos+1);
          SetLength(RTFStream,spos-1);
          if doColorBBCodes then color := GetColorRTF(code,StartColor)
                            else color := 0;
          RTFStream := RTFStream+Format(bbCodes[i].rtf,[color])+trail;
        end;
      end;
    until (spos = 0) or (epos = 0);
  end;
  Result := RTFStream;
end;

function DoSupportBBCodesHTML(S: String): String;
var
  HTMLStream: String;
  i,spos,epos,cpos: integer;
  trail,code: WideString;
begin
  HTMLStream := S;
  for i := 0 to High(bbCodes) do begin
    if bbCodes[i].simple then
      HTMLStream := StringReplace(HTMLStream,bbCodes[i].ss.a,bbCodes[i].sshtml,[rfReplaceAll])
    else repeat
      spos := Pos(bbCodes[i].ss.a,HTMLStream);
      if spos > 0 then begin
        cpos := spos+Length(bbCodes[i].ss.a);
        epos := PosEx(bbCodes[i].es.a,HTMLStream,cpos);
        if epos > cpos then begin
          code := Copy(HTMLStream,cpos,epos-cpos);
          cpos := epos+Length(bbCodes[i].es.a);
          trail := Copy(HTMLStream,cpos,Length(HTMLStream)-cpos+1);
          SetLength(HTMLStream,spos-1);
          HTMLStream := HTMLStream+bbCodes[i].sshtml+code+bbCodes[i].eshtml+trail;
        end;
      end;
    until (spos = 0) or (epos = 0);
  end;
  Result := HTMLStream;
end;

function DoStripBBCodes(S: WideString): WideString;
var
  HTMLStream: WideString;
  i,spos,epos,cpos: integer;
  trail: WideString;
begin
  HTMLStream := S;
  for i := 0 to High(bbCodes) do begin
    if bbCodes[i].simple then
      HTMLStream := Tnt_WideStringReplace(HTMLStream,bbCodes[i].ss.w,'',[rfReplaceAll])
    else repeat
      spos := Pos(bbCodes[i].ss.w,HTMLStream);
      if spos > 0 then begin
        cpos := spos+Length(bbCodes[i].ss.w);
        epos := PosEx(bbCodes[i].es.a,HTMLStream,cpos);
        if epos > cpos then begin
          cpos := epos+Length(bbCodes[i].es.w);
          trail := Copy(HTMLStream,cpos,Length(HTMLStream)-cpos+1);
          SetLength(HTMLStream,spos-1);
          HTMLStream := HTMLStream+trail;
        end;
      end;
    until (spos = 0) or (epos = 0);
  end;
  Result := HTMLStream;
end;

function DoSupportSmileys(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer;
var
  sare: SMADD_RICHEDIT3;
  ird: PItemRenderDetails;
begin
  ird := Pointer(lParam);
  sare.cbSize := SizeOf(sare);
  sare.hwndRichEditControl := wParam;
  sare.rangeToReplace := nil;
  sare.ProtocolName := ird^.pProto;
  //sare.flags := SAFLRE_INSERTEMF;
  sare.flags := 0;
  sare.disableRedraw := True;
  sare.hContact := ird^.hContact;
  PluginLink.CallService(MS_SMILEYADD_REPLACESMILEYS,0,DWord(@sare));
  Result := 0;
end;

function DoSupportMathModule(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer;
var
  mrei: TMathRicheditInfo;
begin
  mrei.hwndRichEditControl := wParam;
  mrei.sel := nil;
  mrei.disableredraw := integer(false);
  Result := PluginLink.CallService(MATH_RTF_REPLACE_FORMULAE,0,DWord(@mrei));
end;

(*
function DoSupportAvatars(wParam, lParam: DWord): Integer;
const
  crlf: String = '{\line }';
var
  ird: PItemRenderDetails;
  ave: PAvatarCacheEntry;
  msglen: integer;
begin
  ird := Pointer(lParam);
  ave := Pointer(PluginLink.CallService(MS_AV_GETAVATARBITMAP,ird.hContact,0));
  if (ave <> nil) and (ave.hbmPic <> 0) then begin
    msglen := SendMessage(wParam,WM_GETTEXTLENGTH,0,0);
    SendMessage(wParam,EM_SETSEL,msglen,msglen);
    SetRichRTF(wParam,crlf,True,False,True);
    InsertBitmapToRichEdit(wParam,ave.hbmPic);
  end;
  Result := 0;
end;
*)

function DoSupportAvatarHistory(wParam, lParam: DWord): Integer;
const
  crlf: String = '{\rtf1{\line }}';
var
  ird: PItemRenderDetails;
  Link: String;
  msglen: integer;
  hBmp: hBitmap;
  cr: CHARRANGE;
begin
  Result := 0;
  ird := Pointer(lParam);
  if ird.wEventType <> EVENTTYPE_AVATARCHANGE then exit;
  if (ird.pExtended = nil) or (lstrlenA(ird.pExtended) = 0) then exit;
  Link := hppProfileDir+'\'+ird.pExtended;
  hBmp := PluginLink.CallService(MS_UTILS_LOADBITMAP,0,Cardinal(@Link[1]));
  if hBmp <> 0 then begin
    cr.cpMin := SendMessage(wParam,WM_GETTEXTLENGTH,0,0);
    cr.cpMax := cr.cpMin;
    SendMessage(wParam,EM_EXSETSEL,0,integer(@cr));
    SetRichRTF(wParam,crlf,True,False,True);
    REInsertBitmap(wParam,hBmp,-1);
  end;
end;

initialization

  rtf_ctable_text := '';
  for i := 0 to High(rtf_ctable) do begin
    rtf_ctable_text := rtf_ctable_text + format('\red%d\green%d\blue%d;',[rtf_ctable[i].col and $FF,(rtf_ctable[i].col shr 8) and $FF,(rtf_ctable[i].col shr 16) and $FF]);
  end;

end.
