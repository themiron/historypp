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

unit hpp_itemprocess;

interface

uses
  Windows, Messages, SysUtils, Graphics,
  m_globaldefs, m_api,
  hpp_global, hpp_contacts, RichEdit;

type

  TBBCookie = (
    BBS_BOLD_S, BBS_BOLD_E,
    BBS_ITALIC_S, BBS_ITALIC_E,
    BBS_UNDERLINE_S, BBS_UNDERLINE_E,
    BBS_STRIKEOUT_S, BBS_STRIKEOUT_E,
    BBS_COLOR_S, BBS_COLOR_E);

  TRTFColorTable = record
    szw: WideString;
    sza: String;
    col: COLORREF;
  end;

  TBBCodeInfo = record
    ssw: WideString;
    esw: WideString;
    ssa: String;
    esa: String;
    cookie: TBBCookie;
    ssha: String;
    esha: String;
  end;


  function DoSupportSmileys(wParam, lParam: DWord): Integer; cdecl;
  function DoSupportBBCodes(wParam, lParam: DWord): Integer; cdecl;
  function DoSupportBBCodesHTML(S: String): String; cdecl;
  // math module support is out of order
  function DoSupportMathModule(wParam, lParam: DWord): Integer; cdecl;

implementation

uses StrUtils;

const

  bbCodes: array[0..9] of TBBCodeInfo = (
    (ssw:'[b]';  esw:''; ssa:'[b]';  esa:''; cookie:BBS_BOLD_S;          ssha: '<b>'; esha:''),
    (ssw:'[/b]'; esw:''; ssa:'[/b]'; esa:''; cookie:BBS_BOLD_E;          ssha: '</b>'; esha:''),
    (ssw:'[i]';  esw:''; ssa:'[i]';  esa:''; cookie:BBS_ITALIC_S;        ssha: '<i>'; esha:''),
    (ssw:'[/i]'; esw:''; ssa:'[/i]'; esa:''; cookie:BBS_ITALIC_E;        ssha: '</i>'; esha:''),
    (ssw:'[u]';  esw:''; ssa:'[u]';  esa:''; cookie:BBS_UNDERLINE_S;     ssha: '<u>'; esha:''),
    (ssw:'[/u]'; esw:''; ssa:'[/u]'; esa:''; cookie:BBS_UNDERLINE_E;     ssha: '</u>'; esha:''),
    (ssw:'[s]';  esw:''; ssa:'[s]';  esa:''; cookie:BBS_STRIKEOUT_S;     ssha: '<s>'; esha:''),
    (ssw:'[/s]'; esw:''; ssa:'[/s]'; esa:''; cookie:BBS_STRIKEOUT_E;     ssha: '</s>'; esha:''),
    (ssw:'[color='; esw:']'; ssa:'[color='; esa:']'; cookie:BBS_COLOR_S; ssha: '<font color='; esha:'>'),
    (ssw:'[/color]'; esw:''; ssa:'[/color]'; esa:''; cookie:BBS_COLOR_E; ssha: '</font>'; esha:''));

  rtf_ctable: array[0..7] of TRTFColorTable = (
    (szw:'red'; sza:'red'; col:$0000FF),
    (szw:'blue'; sza:'blue'; col:$FF0000),
    (szw:'green'; sza:'green'; col:$00FF00),
    (szw:'magenta'; sza:'magenta'; col:$FF00FF),
    (szw:'cyan'; sza:'cyan'; col:$FFFF00),
    (szw:'yellow'; sza:'yellow'; col:$00FFFF),
    (szw:'black'; sza:'black'; col:$000000),
    (szw:'white'; sza:'white'; col:$FFFFFF));

function DoSupportSmileys(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer; cdecl;
var
  sare: TSmAddRichEdit2;
  ird: PItemRenderDetails;
begin
  ird := Pointer(lParam);
  sare.cbSize := SizeOf(sare);
  sare.hwndRichEditControl := wParam;
  sare.rangeToReplace := nil;
  sare.ProtocolName := ird^.pProto;
  sare.useSounds := False;
  sare.disableRedraw := True;
  PluginLink.CallService(MS_SMILEYADD_REPLACESMILEYS,0,Integer(@sare));
  Result := 0;
end;

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

function DoSupportBBCodes(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer; cdecl;
const
  EM_FINDTEXTEXW = WM_USER + 124;
const
  FR_DOWN        = $00000001;
  FR_WHOLEWORD   = $00000002;
  FR_MATCHCASE   = $00000004;
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
        ftew.lpstrText := PWideChar(bbCodes[i].ssw);
        if SendMessage(wParam, EM_FINDTEXTEXW, FR_DOWN, integer(@ftew)) < 0 then continue;
        range := ftew.chrgText;
      end else begin
        ftea.chrg.cpMin := pos;
        ftea.chrg.cpMax := -1;
        ftea.lpstrText := PChar(bbCodes[i].ssa);
        if SendMessage(wParam, EM_FINDTEXTEX, FR_DOWN, integer(@ftea)) < 0 then continue;
        range := ftea.chrgText;
      end;
      if bbCodes[i].esw <> '' then begin
        if hppOSUnicode then begin
          ftew.chrg.cpMin := ftew.chrgText.cpMax;
          ftew.lpstrText := PWideChar(bbCodes[i].esw);
          if SendMessage(wParam, EM_FINDTEXTEXW, FR_DOWN, integer(@ftew)) < 0 then continue;
          range.cpMax := ftew.chrgText.cpMax;
        end else begin
          ftea.chrg.cpMin := ftea.chrgText.cpMax;
          ftea.lpstrText := PChar(bbCodes[i].esa);
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
        if bbCodes[i].esw <> '' then begin
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

function DoSupportBBCodesHTML(S: String): String; cdecl;
var
  temp,temp1,temp2: String;
  i,pos: integer;
begin
  temp := S;
  for i := 0 to High(bbCodes) do begin
    if bbCodes[i].esa = '' then
      temp := StringReplace(temp,bbCodes[i].ssa,bbCodes[i].ssha,[rfReplaceAll,rfIgnoreCase])
    else repeat
      pos := AnsiPos(bbCodes[i].ssa,temp);
      if pos > 0 then begin
        temp1 := Copy(temp,1,pos-1);
        temp2 := Copy(temp,pos,Length(temp)-pos+1);
        temp2 := StringReplace(temp2,bbCodes[i].ssa,bbCodes[i].ssha,[rfIgnoreCase]);
        temp2 := StringReplace(temp2,bbCodes[i].esa,bbCodes[i].esha,[rfIgnoreCase]);
        temp := temp1+temp2;
      end;
    until pos = 0;
  end;
  Result := temp;
end;

function DoSupportMathModule(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer; cdecl;
var
  pc: PChar;
  //cont,sd,ed: String;
  cont,sd,ed: WideString;
  cr_int, cr_big: TCharRange;
  tr: TextRange;
  //fte: TFindTextEx;
  fte: TFindTextExW;
  //r: Integer;
begin
  Result := 1;
  exit;
  pc := PChar(PluginLink.CallService(MATH_GET_STARTDELIMITER,0,0));
  sd := AnsiToWideString(pc,CP_ACP);
  PluginLink.CallService(MTH_FREE_MATH_BUFFER,0,Integer(pc));
  pc := PChar(PluginLink.CallService(MATH_GETENDDELIMITER,0,0));
  ed := AnsiToWideString(pc,CP_ACP);
  PluginLink.CallService(MTH_FREE_MATH_BUFFER,0,Integer(pc));
  while True do begin
    fte.chrg.cpMin := 0;
    fte.chrg.cpMax := -1;
    fte.lpstrText := PWideChar(sd);
    if SendMessage(wParam,EM_FINDTEXTEX,FT_MATCHCASE,Integer(@fte)) = -1 then
      break;
    cr_big.cpMin := fte.chrgText.cpMin;
    cr_int.cpMin := fte.chrgText.cpMax;
    fte.chrg.cpMin := fte.chrgText.cpMax;
    fte.lpstrText := PWideChar(ed);
    if SendMessage(wParam,EM_FINDTEXTEX,0{FT_MATCHCASE},Integer(@fte)) = -1 then
      break;
    cr_big.cpMax := fte.chrgText.cpMax;
    cr_int.cpMax := fte.chrgText.cpMin;
    if cr_int.cpMin < cr_int.cpMax then begin
      // check here for no objects in cr_big
      SetLength(cont, cr_int.cpMax-cr_int.cpMin+1);
      tr.lpstrText := @cont[1];
      tr.chrg := cr_int;
      SendMessage(wParam,EM_GETTEXTRANGE,0,Integer(@tr));
      pc := PChar(PluginLink.CallService(MTH_GET_RTF_BITMAPTEXT,0,Integer(@cont[1])));
      cont := AnsiToWideString(pc,CP_ACP);
      PluginLink.CallService(MTH_FREE_RTF_BITMAPTEXT,0,Integer(pc));
      end;
    SendMessage(wParam,EM_EXSETSEL,0,Integer(@cr_big));
    // set contens of selection
    end;
  { Math module plugin doesn't have any simple
    function that will do the most job for me
    like SmileyAdd and TextFormat have. So we'll
    let the author write this part of the sample :) }
end;

end.
