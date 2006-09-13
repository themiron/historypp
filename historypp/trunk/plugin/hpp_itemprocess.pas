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

 Copyright (c) Art Fedorov, 2004
-----------------------------------------------------------------------------}

{$DEFINE _OLD_RTF_BBCODES}
{$DEFINE _OLD_MATHMOD}

unit hpp_itemprocess;

interface

uses
  Windows, Messages, SysUtils, Graphics,
  m_globaldefs, m_api,
  hpp_global, hpp_contacts, hpp_rtf, RichEdit;

type

  TBBCookie = (
    BBS_BOLD_S, BBS_BOLD_E,
    BBS_ITALIC_S, BBS_ITALIC_E,
    BBS_UNDERLINE_S, BBS_UNDERLINE_E,
    BBS_STRIKEOUT_S, BBS_STRIKEOUT_E,
    BBS_COLOR_S, BBS_COLOR_E);

  {$IFDEF OLD_RTF_BBCODES}
  TRTFColorTable = record
    szw: WideString;
    sza: String;
    col: COLORREF;
  end;
  {$ELSE}
  TRTFColorTable = record
    sz: String;
    col: COLORREF;
  end;
  {$ENDIF}

  WideAnsiRecord = record
    w: WideString;
    a: AnsiString;
  end;

  TBBCodeInfo = record
    ss: WideAnsiRecord;
    es: WideAnsiRecord;
    simple: boolean;
    cookie: TBBCookie;
    ssrtf: String;
    esrtf: String;
    sshtml: String;
    eshtml: String;
  end;

  function DoSupportSmileys(wParam, lParam: DWord): Integer;
  function DoSupportBBCodes(wParam, lParam: DWord): Integer;
  function DoSupportMathModule(wParam, lParam: DWord): Integer;
  function DoSupportBBCodesHTML(S: String): String;
  function DoStripBBCodes(S: WideString): WideString;

implementation

uses StrUtils, TntSysUtils;

const

  EM_FINDTEXTEXW = WM_USER + 124;
  FR_DOWN        = $00000001;
  FR_WHOLEWORD   = $00000002;
  FR_MATCHCASE   = $00000004;

  bbCodes: array[0..9] of TBBCodeInfo = (
    (ss:(w:'[b]';     a:'[b]');     es:(w:''; a:'');  simple:true;  cookie:BBS_BOLD_S;      ssrtf:'\b ';       esrtf:'';  sshtml:'<b>';          eshtml:''),
    (ss:(w:'[/b]';    a:'[/b]');    es:(w:''; a:'');  simple:true;  cookie:BBS_BOLD_E;      ssrtf:'\b0 ';      esrtf:'';  sshtml:'</b>';         eshtml:''),
    (ss:(w:'[i]';     a:'[i]');     es:(w:''; a:'');  simple:true;  cookie:BBS_ITALIC_S;    ssrtf:'\i ';       esrtf:'';  sshtml:'<i>';          eshtml:''),
    (ss:(w:'[/i]';    a:'[/i]');    es:(w:''; a:'');  simple:true;  cookie:BBS_ITALIC_E;    ssrtf:'\i0 ';      esrtf:'';  sshtml:'</i>';         eshtml:''),
    (ss:(w:'[u]';     a:'[u]');     es:(w:''; a:'');  simple:true;  cookie:BBS_UNDERLINE_S; ssrtf:'\ul ';      esrtf:'';  sshtml:'<u>';          eshtml:''),
    (ss:(w:'[/u]';    a:'[/u]');    es:(w:''; a:'');  simple:true;  cookie:BBS_UNDERLINE_E; ssrtf:'\ul0 ';     esrtf:'';  sshtml:'</u>';         eshtml:''),
    (ss:(w:'[s]';     a:'[s]');     es:(w:''; a:'');  simple:true;  cookie:BBS_STRIKEOUT_S; ssrtf:'\strike ';  esrtf:'';  sshtml:'<s>';          eshtml:''),
    (ss:(w:'[/s]';    a:'[/s]');    es:(w:''; a:'');  simple:true;  cookie:BBS_STRIKEOUT_E; ssrtf:'\strike0 '; esrtf:'';  sshtml:'</s>';         eshtml:''),
    (ss:(w:'[color='; a:'[color='); es:(w:']';a:']'); simple:false; cookie:BBS_COLOR_S;     ssrtf:'\cf';       esrtf:' '; sshtml:'<font color='; eshtml:'>'),
    (ss:(w:'[/color]';a:'[/color]');es:(w:''; a:'');  simple:true;  cookie:BBS_COLOR_E;     ssrtf:'\cf1 ';     esrtf:'';  sshtml:'</font>';      eshtml:''));

  {$IFDEF OLD_RTF_BBCODES}
  rtf_ctable: array[0..7] of TRTFColorTable = (
    (szw:'black';   sza:'black';   col:$000000),
    (szw:'red';     sza:'red';     col:$0000FF),
    (szw:'blue';    sza:'blue';    col:$FF0000),
    (szw:'green';   sza:'green';   col:$00FF00),
    (szw:'magenta'; sza:'magenta'; col:$FF00FF),
    (szw:'cyan';    sza:'cyan';    col:$FFFF00),
    (szw:'yellow';  sza:'yellow';  col:$00FFFF),
    (szw:'white';   sza:'white';   col:$FFFFFF));
  {$ELSE}
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
  {$ENDIF}

var
  i: integer;
  rtf_ctable_text: String;

function DoSupportSmileys(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer;
var
  sare: TSmAddRichEdit3;
  ird: PItemRenderDetails;
  RTFStream: String;
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
  PluginLink.CallService(MS_SMILEYADD_REPLACESMILEYS,0,Integer(@sare));
  Result := 0;
end;

{$IFDEF OLD_RTF_BBCODES}

procedure bbCodeSimpleFunc(RichHandle: DWord; range: TCharRange; txtw: WideString; txta: string; cookie: TBBCookie; var defcf: TCharFormat);
const
  em: WideString = '';
var
  cf: TCharFormat;
  i: integer;
  found: boolean;
begin
  ZeroMemory(@cf,SizeOf(cf));
  cf.cbSize := SizeOf(cf);
  case cookie of
    BBS_BOLD_S: begin
      cf.dwMask := CFM_BOLD;
      cf.dwEffects := CFE_BOLD;
    end;
    BBS_BOLD_E: cf.dwMask := CFM_BOLD;
    BBS_ITALIC_S: begin
      cf.dwMask := CFM_ITALIC;
      cf.dwEffects := CFE_ITALIC;
    end;
    BBS_ITALIC_E: cf.dwMask := CFM_ITALIC;
    BBS_UNDERLINE_S: begin
      cf.dwMask := CFM_UNDERLINE;
      cf.dwEffects := CFE_UNDERLINE;
    end;
    BBS_UNDERLINE_E: cf.dwMask := CFM_UNDERLINE;
    BBS_STRIKEOUT_S: begin
      cf.dwMask := CFM_STRIKEOUT;
      cf.dwEffects := CFE_STRIKEOUT;
    end;
    BBS_STRIKEOUT_E: cf.dwMask := CFM_STRIKEOUT;
    BBS_COLOR_S: begin
      for i := 0 to high(rtf_ctable) do begin
        if hppOSUnicode then found := rtf_ctable[i].szw = txtw
                        else found := rtf_ctable[i].sza = txta;
        if found then begin
          cf.crTextColor := rtf_ctable[i].col;
          cf.dwMask := CFM_COLOR;
          break;
        end;
      end;
    end;
    BBS_COLOR_E: begin
      cf.dwMask := CFM_COLOR;
      cf.crTextColor := defcf.crTextColor;
    end;
  end;
  SendMessage(RichHandle, EM_SETSEL, range.cpMin, -1);
  SendMessage(RichHandle, EM_SETCHARFORMAT, SCF_SELECTION, integer(@cf));
  SendMessage(RichHandle, EM_SETSEL, range.cpMin, range.cpMax);
  SendMessage(RichHandle, EM_REPLACESEL, 0, integer(PWideChar(em)));
end;

function DoSupportbbCodes(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer;
var
  pos,i: integer;
  found: boolean;
  fRange,range: CharRange;
  cf: TCharFormat;
  fTextW: WideString;
  fTextA: String;
  fBBCode: TBBCodeInfo;
  fteW: FindTextExW;
  fteA: FindTextExA;
  trgW: TextRangeW;
  trgA: TextRangeA;
begin
  ZeroMemory(@cf,SizeOf(cf));
  cf.cbSize := SizeOf(cf);
  cf.dwMask := CFM_COLOR;
  SendMessage(wParam, EM_GETCHARFORMAT, 0, integer(@cf));
  pos := 0;
  repeat
    found := false;
    fRange.cpMin := -1;
    for i := 0 to High(bbCodes) do begin
      if hppOSUnicode then begin
        ftew.chrg.cpMin := pos;
        ftew.chrg.cpMax := -1;
        ftew.lpstrText := PWideChar(bbCodes[i].ss.w);
        if SendMessage(wParam, EM_FINDTEXTEXW, FR_DOWN, integer(@ftew)) < 0 then continue;
        range := ftew.chrgText;
      end else begin
        ftea.chrg.cpMin := pos;
        ftea.chrg.cpMax := -1;
        ftea.lpstrText := PChar(bbCodes[i].ss.a);
        if SendMessage(wParam, EM_FINDTEXTEX, FR_DOWN, integer(@ftea)) < 0 then continue;
        range := ftea.chrgText;
      end;
      if bbCodes[i].es.w <> '' then begin
        if hppOSUnicode then begin
          ftew.chrg.cpMin := ftew.chrgText.cpMax;
          ftew.lpstrText := PWideChar(bbCodes[i].es.w);
          if SendMessage(wParam, EM_FINDTEXTEXW, FR_DOWN, integer(@ftew)) < 0 then continue;
          range.cpMax := ftew.chrgText.cpMax;
        end else begin
          ftea.chrg.cpMin := ftea.chrgText.cpMax;
          ftea.lpstrText := PChar(bbCodes[i].es.a);
          if SendMessage(wParam, EM_FINDTEXTEX, FR_DOWN, integer(@ftea)) < 0 then continue;
          range.cpMax := ftea.chrgText.cpMax;
        end;
      end;
      if ((fRange.cpMin = -1) or (fRange.cpMin > range.cpMin)) then begin
        fRange := range;
        fBBCode := bbCodes[i];
        found := true;
        if hppOSUnicode then begin
          if fTextW <> '' then fTextW := '';
        end else begin
          if fTextA <> '' then fTextA := '';
        end;
        if bbCodes[i].es.w <> '' then begin
          if hppOSUnicode then begin
            trgw.chrg.cpMin := ftew.chrg.cpMin;
            trgw.chrg.cpMax := ftew.chrgText.cpMin;
            SetLength(fTextW,trgw.chrg.cpMax - trgw.chrg.cpMin);
            trgw.lpstrText := @fTextW[1];
            SendMessage(wParam, EM_GETTEXTRANGE, 0, integer(@trgw));
          end else begin
            trga.chrg.cpMin := ftea.chrg.cpMin;
            trga.chrg.cpMax := ftea.chrgText.cpMin;
            SetLength(fTextA,trga.chrg.cpMax - trga.chrg.cpMin);
            trga.lpstrText := @fTextA[1];
            SendMessage(wParam, EM_GETTEXTRANGE, 0, integer(@trga));
          end;
        end;
      end;
    end;
    if found then begin
      bbCodeSimpleFunc(wParam, fRange, fTextW, fTextA, fBBCode.cookie,cf);
      if hppOSUnicode then begin
        if fTextW <> '' then fTextW := '';
      end else begin
        if fTextA <> '' then fTextA := '';
      end;
    end;
  until not found;
  Result := 0;
end;
{$ELSE}

function InsertRTFTable(var RTFStream:String): integer;
var
  spos,epos: integer;
begin
  Result := 0;
  spos := AnsiPos('\colortbl',RTFStream);
  if spos > 0 then begin
    epos := PosEx('}',RTFStream,spos);
    spos := PosEx('\red',RTFStream,spos);
    while (spos > 0) and (spos < epos) do begin
      spos := PosEx('\red',RTFStream,spos+1);
      Inc(Result);
    end;
    Insert(rtf_ctable_text,RTFStream,epos);
  end else begin
    spos := AnsiPos('{\fonttbl',RTFStream);
    if spos > 0 then
      Insert('{\colortbl ;'+rtf_ctable_text+'}',RTFStream,spos)
    else
      Result := -1;
  end;
end;

function GetColorRTF(code: String; colcount: integer): String;
var
  i: integer;
begin
  Result := '1';
  if colcount >= 0 then
    for i := 0 to High(rtf_ctable) do
      if code = rtf_ctable[i].sz then begin
        Result := intToStr(colcount+i+1);
        break;
      end;
end;

//function GetLinkRTF(code,data: String): String;
//begin
//  Result := '{\field {\*\fldinst HYPERLINK "'+code+'"}{\fldrslt '+data+'}}';
//end;

function DoSupportBBCodes(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer;
var
  RTFStream,code,trail: String;
  i,colcount: integer;
  spos,epos,cpos,expos: integer;
  temp: String;
  NoRTFTable: boolean;
begin
  NoRTFTable := true;
  GetRichRTF(wParam,RTFStream,False,False,False,False);
  for i := 0 to High(bbCodes) do begin
    if bbCodes[i].simple then
      RTFStream := StringReplace(RTFStream,bbCodes[i].ss.a,bbCodes[i].ssrtf,[rfReplaceAll,rfIgnoreCase])
    else begin
      if NoRTFTable then begin
        colcount := InsertRTFTable(RTFStream);
        NoRTFTable := false;
      end;
      repeat
        spos := AnsiPos(bbCodes[i].ss.a,RTFStream);
        if spos > 0 then begin
          cpos := spos+Length(bbCodes[i].ss.a);
          epos := PosEx(bbCodes[i].es.a,RTFStream,cpos);
          if epos > cpos then begin
            code := Copy(RTFStream,cpos,epos-cpos);
            cpos := epos+Length(bbCodes[i].es.a);
            //if (i < High(High(bbCodes))) and (not bbCodes[i+1].simple) then begin
            //  expos := PosEx(bbCodes[i+1].ss.a,RTFStream,cpos);
            //  if expos > 0 then begin
            //    temp := Copy(RTFStream,cpos,expos-cpos);
            //    cpos := expos+Length(bbCodes[i+1].ss.a);
            //  end else temp := '';
            //end;
            trail := Copy(RTFStream,cpos,Length(RTFStream)-cpos+1);
            SetLength(RTFStream,spos-1);
            temp := GetColorRTF(code,colcount);
            RTFStream := RTFStream+bbCodes[i].ssrtf+temp+bbCodes[i].esrtf+trail;
          end;
        end;
      until (spos = 0) or (epos = 0);
    end;
  end;
  SetRichRTF(wParam,RTFStream,False,False,False);
  Result := 0;
end;
{$ENDIF}

function DoSupportBBCodesHTML(S: String): String;
var
  temp,temp1,temp2: String;
  i,pos: integer;
begin
  temp := S;
  for i := 0 to High(bbCodes) do begin
    if bbCodes[i].es.a = '' then
      temp := StringReplace(temp,bbCodes[i].ss.a,bbCodes[i].sshtml,[rfReplaceAll,rfIgnoreCase])
    else repeat
      pos := AnsiPos(bbCodes[i].ss.a,temp);
      if pos > 0 then begin
        temp1 := Copy(temp,1,pos-1);
        temp2 := Copy(temp,pos,Length(temp)-pos+1);
        temp2 := StringReplace(temp2,bbCodes[i].ss.a,bbCodes[i].sshtml,[rfIgnoreCase]);
        temp2 := StringReplace(temp2,bbCodes[i].es.a,bbCodes[i].eshtml,[rfIgnoreCase]);
        temp := temp1+temp2;
      end;
    until pos = 0;
  end;
  Result := temp;
end;

function DoStripBBCodes(S: WideString): WideString;
var
  temp,temp1,temp2: WideString;
  i,p,p2: integer;
begin
  temp := S;
  for i := 0 to High(bbCodes) do begin
    if bbCodes[i].es.w = '' then
      temp := Tnt_WideStringReplace(temp,bbCodes[i].ss.w,'',[rfReplaceAll,rfIgnoreCase])
    else repeat
      p := Pos(bbCodes[i].ss.w,temp);
      if p > 0 then begin
        temp1 := Copy(temp,1,p-1);
        temp2 := Copy(temp,p,Length(temp)-p+1);
        p2 := Pos(bbCodes[i].es.w,temp2);
        if p2 > 0 then
          temp2 := Copy(temp2,p2+Length(bbCodes[i].es.w),Length(temp2)-p2-Length(bbCodes[i].es.w)+1);
        temp := temp1+temp2;
      end;
    until p = 0;
  end;
  Result := temp;
end;

{$IFDEF OLD_MATHMOD}

function DoSupportMathModule(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer;
var
  sd,ed: PChar;
  sdW,edW: WideString;
  sdA,edA: String;
  fteW: FindTextExW;
  fteA: FindTextExA;
  range: CharRange;
  fTextW: WideString;
  fTextA: String;
  trgW: TextRangeW;
  trgA: TextRangeA;
  len: integer;
begin
  sd := PChar(PluginLink.CallService(MATH_GET_STARTDELIMITER,0,0));
  if hppOSUnicode then sdW := AnsiToWideString(sd,CP_ACP)
                  else SetString(sdA,sd,StrLen(sd));
  PluginLink.CallService(MTH_FREE_MATH_BUFFER,0,DWord(sd));
  ed := PChar(PluginLink.CallService(MATH_GETENDDELIMITER,0,0));
  if hppOSUnicode then edW := AnsiToWideString(ed,CP_ACP)
                  else SetString(edA,ed,StrLen(ed));
  PluginLink.CallService(MTH_FREE_MATH_BUFFER, 0, integer(ed));
  while True do begin
    if hppOSUnicode then begin
      ftew.chrg.cpMin := 0;
      ftew.chrg.cpMax := -1;
      ftew.lpstrText := PWideChar(sdW);
      if SendMessage(wParam, EM_FINDTEXTEXW, FR_DOWN+FT_MATCHCASE, integer(@ftew)) < 0 then break;
      range.cpMin := ftew.chrgText.cpMin;
    end else begin
      ftea.chrg.cpMin := 0;
      ftea.chrg.cpMax := -1;
      ftea.lpstrText := PChar(sdA);
      if SendMessage(wParam, EM_FINDTEXTEX, FR_DOWN+FT_MATCHCASE, integer(@ftea)) < 0 then break;
      range.cpMin := ftea.chrgText.cpMin;
    end;
    if hppOSUnicode then begin
      ftew.chrg.cpMin := ftew.chrgText.cpMax;
      ftew.chrg.cpMax := -1;
      ftew.lpstrText := PWideChar(edW);
      if SendMessage(wParam, EM_FINDTEXTEXW, FR_DOWN+FT_MATCHCASE, integer(@ftew)) < 0 then break;
      range.cpMax := ftew.chrgText.cpMax;
    end else begin
      ftea.chrg.cpMin := ftea.chrgText.cpMax;
      ftea.chrg.cpMax := -1;
      ftea.lpstrText := PChar(edA);
      if SendMessage(wParam, EM_FINDTEXTEX, FR_DOWN+FT_MATCHCASE, integer(@ftea)) < 0 then break;
      range.cpMax := ftea.chrgText.cpMax;
    end;
    if range.cpMin < range.cpMax then begin
      if hppOSUnicode then begin
        SetLength(fTextW,range.cpMax-range.cpMin+1);
        trgw.chrg := range;
        trgw.lpstrText := @fTextW[1];
        SendMessage(wParam, EM_GETTEXTRANGE, 0, integer(@trgw));
        fTextA := WideToAnsiString(fTextW,CP_ACP);
      end else begin
        SetLength(fTextA,range.cpMax-range.cpMin+1);
        trga.chrg := range;
        trga.lpstrText := @fTextA[1];
        SendMessage(wParam, EM_GETTEXTRANGE, 0, integer(@trga));
      end;
      sd := PChar(PluginLink.CallService(MTH_GET_RTF_BITMAPTEXT,0,Integer(@FTextA[1])));
      len := StrLen(sd);
      SetString(fTextA,sd,len);
      PluginLink.CallService(MTH_FREE_RTF_BITMAPTEXT, 0, integer(sd));
      //SendMessage(wParam, EM_EXSETSEL, 0, integer(@range));
      SetRichRTF(wParam,fTextA,False,False,False);
    end;
  end;
  Result := 0;
end;
{$ELSE}

function DoSupportMathModule(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer;
var
  mrei: TMathRicheditInfo;
begin
  mrei.hwndRichEditControl := wParam;
  mrei.sel := nil;
  mrei.disableredraw := integer(true);
  Result := PluginLink.CallService(MATH_RTF_REPLACE_FORMULAE,0,DWord(@mrei));
end;
{$ENDIF}

initialization

{$IFNDEF OLD_RTF_BBCODES}
  rtf_ctable_text := '';
  for i := 0 to High(rtf_ctable) do begin
    rtf_ctable_text := rtf_ctable_text + format('\red%d\green%d\blue%d;',[rtf_ctable[i].col and $FF,(rtf_ctable[i].col shr 8) and $FF,(rtf_ctable[i].col shr 16) and $FF]);
  end;
{$ENDIF}

end.
