{-----------------------------------------------------------------------------
 hpp_options (historypp project)

 Version:   1.0
 Created:   31.03.2003
 Author:    Oxygen

 [ Description ]

 Options module which has one global options variable and
 manages all options throu all history windows

 [ History ]
 1.0 (31.03.2003) - Initial version

 [ Modifications ]

 [ Knows Inssues ]
 None

 Copyright (c) Art Fedorov, 2003
-----------------------------------------------------------------------------}


unit hpp_options;

interface

uses
  Graphics, Classes, SysUtils, Windows,
  m_globaldefs, m_api,
  HistoryGrid, {OptionsForm, }PassForm, PassCheckForm,
  hpp_global, hpp_contacts;

type

  ThppIntIconsRec = record
    name: PChar;
    handle: hIcon;
  end;

  ThppIconsRec = record
    name: PChar;
    desc: PChar;
    group: PChar;
    i: shortint;
    handle: hIcon;
  end;

  ThppFontsRec = record
    name: PChar;
    nameColor: PChar;
    mes: TMessageTypes;
    style: byte;
    size: longint;
    color: TColor;
    back: TColor;
  end;

  TCodePage = record
    cp: Cardinal;
    name: WideString;
  end;

const
  DEFFORMAT_CLIPCOPY     = '%nick%, %smart_datetime%:\n%mes%\n';
  DEFFORMAT_CLIPCOPYTEXT = '%mes%\n';
  DEFFORMAT_REPLYQUOTED  = '%nick%, %smart_datetime%:\n%quot_mes%\n';

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
  HPP_ICON_TOOL_EVENTSFILTER = 25;
  HPP_ICON_CONTACDETAILS     = 26;
  HPP_ICON_CONTACTMENU       = 27;
  HPP_ICON_BOOKMARK          = 28;
  HPP_ICON_BOOKMARK_ON       = 29;
  HPP_ICON_BOOKMARK_OFF      = 30;

  hppIcons : array[0..30] of ThppIconsRec = (
    (name:'historypp_01'; desc:'Contact history'; group: 'Main'; i:HPP_ICON_CONTACTHISTORY; handle:0),
    (name:'historypp_02'; desc:'History search'; group: 'Main'; i:HPP_ICON_GLOBALSEARCH; handle:0),
    (name:'historypp_03'; desc:'Conversation divider'; group: 'Conversations'; i:HPP_ICON_SESS_DIVIDER; handle:0),
    (name:'historypp_04'; desc:'Conversation icon'; group: 'Conversations'; i:HPP_ICON_SESSION; handle:0),
    (name:'historypp_05'; desc:'Conversation summer'; group: 'Conversations'; i:HPP_ICON_SESS_SUMMER; handle:0),
    (name:'historypp_06'; desc:'Conversation autumn'; group: 'Conversations'; i:HPP_ICON_SESS_AUTUMN; handle:0),
    (name:'historypp_07'; desc:'Conversation winter'; group: 'Conversations'; i:HPP_ICON_SESS_WINTER; handle:0),
    (name:'historypp_08'; desc:'Conversation spring'; group: 'Conversations'; i:HPP_ICON_SESS_SPRING; handle:0),
    (name:'historypp_09'; desc:'Conversation year'; group: 'Conversations'; i:HPP_ICON_SESS_YEAR; handle:0),
    (name:'historypp_10'; desc:'Filter'; group: 'Toolbar'; i:HPP_ICON_HOTFILTER; handle:0),
    (name:'historypp_11'; desc:'In-place filter wait'; group: 'Search panel'; i:HPP_ICON_HOTFILTERWAIT; handle:0),
    (name:'historypp_12'; desc:'Search All Results'; group: 'Main'; i:HPP_ICON_SEARCH_ALLRESULTS; handle:0),
    (name:'historypp_13'; desc:'Save All'; group: 'Toolbar'; i:HPP_ICON_TOOL_SAVEALL; handle:0),
    (name:'historypp_14'; desc:'Search'; group: 'Toolbar'; i:HPP_ICON_HOTSEARCH; handle:0),
    (name:'historypp_15'; desc:'Search Up'; group: 'Search panel'; i:HPP_ICON_SEARCHUP; handle:0),
    (name:'historypp_16'; desc:'Search Down'; group: 'Search panel'; i:HPP_ICON_SEARCHDOWN; handle:0),
    (name:'historypp_17'; desc:'Delete All'; group: 'Toolbar'; i:HPP_ICON_TOOL_DELETEALL; handle:0),
    (name:'historypp_18'; desc:'Delete'; group: 'Toolbar'; i:HPP_ICON_TOOL_DELETE; handle:0),
    (name:'historypp_19'; desc:'Conversations'; group: 'Toolbar'; i:HPP_ICON_TOOL_SESSIONS; handle:0),
    (name:'historypp_20'; desc:'Save'; group: 'Toolbar'; i:HPP_ICON_TOOL_SAVE; handle:0),
    (name:'historypp_21'; desc:'Copy'; group: 'Toolbar'; i:HPP_ICON_TOOL_COPY; handle:0),
    (name:'historypp_22'; desc:'End of page'; group: 'Search panel'; i:HPP_ICON_SEARCH_ENDOFPAGE; handle:0),
    (name:'historypp_23'; desc:'Phrase not found'; group: 'Search panel'; i:HPP_ICON_SEARCH_NOTFOUND; handle:0),
    (name:'historypp_24'; desc:'Clear in-place filter'; group: 'Search panel'; i:HPP_ICON_HOTFILTERCLEAR; handle:0),
    (name:'historypp_25'; desc:'Conversation hide'; group: 'Conversations'; i:HPP_ICON_SESS_HIDE; handle:0),
    (name:'historypp_26'; desc:'Events filter'; group: 'Toolbar'; i:HPP_ICON_TOOL_EVENTSFILTER; handle:0),
    (name:'historypp_27'; desc:'User Details'; group: 'Toolbar'; i:HPP_ICON_CONTACDETAILS; handle:0),
    (name:'historypp_28'; desc:'User Menu'; group: 'Toolbar'; i:HPP_ICON_CONTACTMENU; handle:0),
    (name:'historypp_29'; desc:'Bookmarks'; group: 'Toolbar'; i:HPP_ICON_BOOKMARK; handle:0),
    (name:'historypp_30'; desc:'Bookmark enabled'; group: 'Main'; i:HPP_ICON_BOOKMARK_ON; handle:0),
    (name:'historypp_31'; desc:'Bookmark disabled'; group: 'Main'; i:HPP_ICON_BOOKMARK_OFF; handle:0)
  );

  hppIntIcons: array[0..0] of ThppIntIconsRec = (
    (name:'z_password_protect'; handle: 0)
  );

  hppFontItems: array[0..17] of ThppFontsRec = (
    (name: 'Incoming nick'; nameColor: 'Divider'; Mes: []; style:DBFONTF_BOLD; size: -11; color: $6B3FC8; back: clGray),
    (name: 'Outgoing nick'; nameColor: 'Selected text'; Mes: []; style:DBFONTF_BOLD; size: -11; color: $BD6008; back: clHighlightText),
    (name: 'Timestamp'; nameColor: 'Selected background'; Mes: []; style:0; size: -11; color: $000000; back: clHighlight),
    (name: 'Incoming message'; Mes: [mtMessage,mtIncoming]; style:0; size: -11; color: $000000; back: $DBDBDB),
    (name: 'Outgoing message'; Mes: [mtMessage,mtOutgoing]; style:0; size: -11; color: $000000; back: $EEEEEE),
    (name: 'Incoming file'; Mes: [mtFile,mtIncoming]; style:0; size: -11; color: $000000; back: $9BEEE3),
    (name: 'Outgoing file'; Mes: [mtFile,mtOutgoing]; style:0; size: -11; color: $000000; back: $9BEEE3),
    (name: 'Incoming url'; Mes: [mtUrl,mtIncoming]; style:0; size: -11; color: $000000; back: $F4D9CC),
    (name: 'Outgoing url'; Mes: [mtUrl,mtOutgoing]; style:0; size: -11; color: $000000; back: $F4D9CC),
    (name: 'Incoming SMS Message'; Mes: [mtSMS,mtIncoming]; style:0; size: -11; color: $000000; back: $CFF4FE),
    (name: 'Outgoing SMS Message'; Mes: [mtSMS,mtOutgoing]; style:0; size: -11; color: $000000; back: $CFF4FE),
    (name: 'Incoming contacts'; Mes: [mtContacts,mtIncoming]; style:0; size: -11; color: $000000; back: $FEF4CF),
    (name: 'Outgoing contacts'; Mes: [mtContacts,mtOutgoing]; style:0; size: -11; color: $000000; back: $FEF4CF),
    (name: 'System message'; Mes: [mtSystem,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $CFFEDC),
    (name: 'Status change'; Mes: [mtStatus,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $F0F0F0),
    (name: 'SMTP Simple'; Mes: [mtSMTPSimple,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $FFFFFF),
    (name: 'Other events'; Mes: [mtOther,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $FFFFFF),
    (name: 'Conversation header'; Mes: []; style:0; size: -11; color: $000000; back: $00D7FDFF)
    );

  cpTable: array[0..14] of TCodePage = (
    (cp:  874; name: 'Thai' ),
    (cp:	932; name: 'Japanese' ),
    (cp:  936; name: 'Simplified Chinese' ),
    (cp:  949; name: 'Korean' ),
    (cp:  950; name: 'Traditional Chinese' ),
    (cp: 1250; name: 'Central European' ),
    (cp: 1251; name: 'Cyrillic' ),
    (cp: 1252; name: 'Latin I' ),
    (cp: 1253; name: 'Greek' ),
    (cp: 1254; name: 'Turkish' ),
    (cp: 1255; name: 'Hebrew' ),
    (cp: 1256; name: 'Arabic' ),
    (cp: 1257; name: 'Baltic' ),
    (cp: 1258; name: 'Vietnamese' ),
    (cp: 1361; name: 'Korean (Johab)' ));

var
  GridOptions: TGridOptions;
  PassFm: TfmPass;
  PassCheckFm: TfmPassCheck;
  IcoLibEnabled: Boolean;
  FontServiceEnabled: Boolean;
  SmileyAddEnabled: Boolean;
  MathModuleEnabled: Boolean;

procedure LoadGridOptions;
procedure SaveGridOptions;
procedure LoadIcons;
procedure LoadIcons2;
procedure LoadIntIcons;
procedure OnShowIcons;
procedure hppRegisterGridOptions;

implementation

uses hpp_database, ShellAPI, Math;

var i: integer;

procedure RegisterFont(Name:PChar; Order:integer; defFont:FontSettings);
var
  fid: FontID;
begin
  fid.cbSize := sizeof(fid);
  fid.group := hppName;
  fid.dbSettingsGroup := hppDBName;
  fid.flags := FIDF_DEFAULTVALID+FIDF_ALLOWEFFECTS;
  fid.order := Order;
  lstrcpy(fid.name,Name);
  lstrcpy(fid.prefix,PChar('Font'+intToStr(Order)));
  fid.deffontsettings := defFont;
  fid.deffontsettings.size := hppFontItems[Order].size;
  fid.deffontsettings.style := hppFontItems[Order].style;
  fid.deffontsettings.colour := hppFontItems[Order].color;
  PluginLink.CallService(MS_FONT_REGISTER,integer(@fid),0);
end;

procedure RegisterColor(Name:PChar; Order:integer; defColor:TColor);
var
  cid: ColourID;
begin
  cid.cbSize := sizeof(cid);
  cid.group := hppName;
  cid.dbSettingsGroup := hppDBName;
  cid.order := Order;
  lstrcpy(cid.name,Name);
  lstrcpy(cid.setting,PChar('Color'+intToStr(Order)));
  cid.defcolour := defColor;
  PluginLink.CallService(MS_COLOUR_REGISTER,integer(@cid),0);
end;

procedure OnShowIcons;
begin
  if GridOptions.ShowIcons then LoadIcons;
end;

function LoadIconFromDB(ID: Integer; Icon: TIcon): Boolean;
var
  hic: HIcon;
begin
  Result := False;
  hic := LoadSkinnedIcon(ID);
  if (hic <> 0) then begin
    hic := CopyIcon(hic);
    Icon.Handle := hic;
    Result := True;
  end;
end;

procedure LoadIcons;
begin
  GridOptions.StartChange;
  try
    LoadIconFromDB(SKINICON_EVENT_MESSAGE,GridOptions.IconMessage);
    LoadIconFromDB(SKINICON_EVENT_URL,GridOptions.IconUrl);
    LoadIconFromDB(SKINICON_EVENT_FILE,GridOptions.IconFile);
    LoadIconFromDB(SKINICON_OTHER_MIRANDA,GridOptions.IconOther);
  finally
    GridOptions.EndChange;
  end;
end;

procedure LoadIntIcons;
var
  i: Integer;
begin
  for i := 0 to High(hppIntIcons) do
    hppIntIcons[i].handle := LoadIcon(hInstance,hppIntIcons[i].name);
end;

procedure LoadIcons2;
var
  lhic,hic: HIcon;
  i: integer;
  NeedIcons,CountIconsDll: Integer;
  SmallIcons: array of HICON;
begin
  if IcoLibEnabled then begin
    for i := 0 to High(hppIcons) do
      hppIcons[i].handle := PluginLink.CallService(MS_SKIN2_GETICON,0,longint(hppIcons[i].name));
  end
  else begin
    CountIconsDll := ExtractIconEx(PChar(hppIconPack),-1,HICON(nil^),HICON(nil^),0);
    NeedIcons := Min(Length(hppIcons),CountIconsDll);
    if NeedIcons <= 0 then exit;
    SetLength(SmallIcons,NeedIcons);
    CountIconsDll := ExtractIconEx(PChar(hppIconPack),0,HICON(nil^),SmallIcons[0],NeedIcons);
    for i := 0 to CountIconsDll - 1 do
      hppIcons[i].handle := SmallIcons[i];
    Finalize(SmallIcons);
  end;
end;

procedure LoadGridOptions;
  function LoadColorDB(Order: integer): TColor;
  begin
    Result := GetDBInt(hppDBName,PChar('Color'+intToStr(Order)),ColorToRGB(hppFontItems[Order].back));
  end;
  procedure LoadFont(Order: integer; F: TFont);
  const
    size: integer = -11;
  var
    fid: FontID;
    lf: TLogFont;
    col: TColor;
    fs: TFontStyles;
  begin
    if FontServiceEnabled then begin
      fid.cbSize := sizeof(fid);
      fid.group := hppName;
      lstrcpy(fid.name,Translate(hppFontItems[Order].name){TRANSLATE-IGNORE});
      col := PluginLink.CallService(MS_FONT_GET,integer(@fid),integer(@lf));
      F.Handle := CreateFontIndirect(lf);
      F.Color := col;
    end else begin
      F.Name := 'Tahoma';
      F.Height := size;
      fs := [];
      if (hppFontItems[Order].style and DBFONTF_BOLD) > 0 then include(fs,fsBold);
      F.Style := fs;
      F.Color := hppFontItems[Order].color;
    end;
  end;
var
  i: integer;
begin
  GridOptions.StartChange;
  try
    // load fonts
  LoadFont(0,GridOptions.FontContact);
  LoadFont(1,GridOptions.FontProfile);
  LoadFont(2,GridOptions.FontTimestamp);
  LoadFont(High(hppFontItems),GridOptions.FontSessHeader);
  // load colors
  GridOptions.ColorDivider := LoadColorDB(0);
  GridOptions.ColorSelectedText := LoadColorDB(1);
  GridOptions.ColorSelected := LoadColorDB(2);
  GridOptions.ColorSessHeader := LoadColorDB(High(hppFontItems));
  // load mestype-related
  for i :=  3 to High(hppFontItems)-1 do begin
    if (i-3) > High(GridOptions.ItemOptions) then GridOptions.AddItemOptions;
    GridOptions.ItemOptions[i-3].MessageType := hppFontItems[i].Mes;
    LoadFont(i,GridOptions.ItemOptions[i-3].textFont);
    GridOptions.ItemOptions[i-3].textColor := LoadColorDB(i);
  end;
  // load others
  GridOptions.ShowIcons := GetDBBool(hppDBName,'ShowIcons',True);

  // we have no per-proto rtl setup ui, use global instead
  GridOptions.RTLEnabled := GetContactRTLMode(0,'');

  GridOptions.SmileysEnabled := GetDBBool(hppDBName,'Smileys',SmileyAddEnabled);
  GridOptions.BBCodesEnabled := GetDBBool(hppDBName,'BBCodes',True);
  GridOptions.MathModuleEnabled := GetDBBool(hppDBName,'MathModule',MathModuleEnabled);

  //GridOptions.ClipCopyFormat := DEFFORMAT_CLIPCOPY;
  //GridOptions.ClipCopyTextFormat := DEFFORMAT_CLIPCOPYTEXT;
  GridOptions.ClipCopyFormat := GetDBWideStr(hppDBName,'FormatCopy',DEFFORMAT_CLIPCOPY);
  GridOptions.ClipCopyTextFormat := GetDBWideStr(hppDBName,'FormatCopyText',DEFFORMAT_CLIPCOPYTEXT);
  GridOptions.ReplyQuotedFormat := GetDBWideStr(hppDBName,'FormatReplyQuoted',DEFFORMAT_REPLYQUOTED);

  finally
  GridOptions.EndChange;
  end;
end;

procedure SaveGridOptions;
begin
  GridOptions.StartChange;
  try
  WriteDBBool(hppDBName,'ShowIcons',GridOptions.ShowIcons);
  // we have no per-proto rtl setup ui, use global instead
  WriteDBBool(hppDBName,'RTL',GridOptions.RTLEnabled);
  WriteDBBool(hppDBName,'Smileys',GridOptions.SmileysEnabled);
  WriteDBBool(hppDBName,'BBCodes',GridOptions.BBCodesEnabled);
  WriteDBBool(hppDBName,'MathModule',GridOptions.MathModuleEnabled);
  //WriteDBWideStr(hppDBName,'FormatCopy',GridOptions.ClipCopyFormat);
  //WriteDBWideStr(hppDBName,'FormatCopyText',GridOptions.ClipCopyTextFormat);
  finally
  GridOptions.EndChange;
  end;
end;

function FindIconsDll: string;
var
  dir: string;
  str: WideString;
  //hIcons: Cardinal;
begin
  SetLength(dir,MAX_PATH);
  SetLength(dir,GetModuleFileName(hInstance,PAnsiChar(dir),Length(dir)));
  Result := dir;
  dir := ExtractFilePath(dir);
  if FileExists(dir+hppIPName) then
    Result := dir+hppIPName
  else if FileExists(dir+'..\Icons\'+hppIPName) then
    Result := ExpandFileName(dir+'..\Icons\'+hppIPName)
  else if FileExists(dir+'..\'+hppIPName) then
    Result := ExpandFileName(dir+'..\'+hppIPName)
  else begin
    str :=  'Cannot load icon pack '+hppIPName+' from:'+#13#10+
            #13#10+
            dir+#13#10+
            ExpandFileName(dir+'..\Icons\')+#13#10+
            ExpandFileName(dir+'..\')+#13#10+
            #13#10+
            'No icons will be shown.';
    hppMessageBox(0,str,hppName+' Error',MB_ICONERROR or MB_OK);
  end;
end;

procedure hppRegisterGridOptions;
var
  sid: TSKINICONDESC;
  defFont : FontSettings;
  i: integer;
begin
  SmileyAddEnabled := Boolean(PluginLink.ServiceExists(MS_SMILEYADD_REPLACESMILEYS));
  MathModuleEnabled := Boolean(PluginLink.ServiceExists(MATH_GET_STARTDELIMITER));
  // Register in IcoLib
  IcoLibEnabled := Boolean(PluginLink.ServiceExists(MS_SKIN2_ADDICON));
  hppIconPack := FindIconsDll;
  if IcoLibEnabled then begin
    ZeroMemory(@sid,SizeOf(sid));
    sid.cbSize := SizeOf(sid);
    sid.pszDefaultFile := PChar(hppIconPack);
    for i := 0 to High(hppIcons) do begin
      sid.pszName := hppIcons[i].name;
      sid.pszDescription := translate(hppIcons[i].desc{TRANSLATE-IGNORE});
      if StrLen(hppIcons[i].group) = 0 then
        sid.pszSection := hppName
      else
        sid.pszSection := PChar(hppName+'/'+translate(hppIcons[i].group){TRANSLATE-IGNORE});
      sid.iDefaultIndex := hppIcons[i].i;
      PluginLink.CallService(MS_SKIN2_ADDICON,0,DWord(@sid));
    end;
  end;
  // Register in FontService
  FontServiceEnabled := Boolean(PluginLink.ServiceExists(MS_FONT_GET));
  if FontServiceEnabled then begin
    defFont.szFace := 'Tahoma';
    defFont.charset := DEFAULT_CHARSET;
    RegisterFont(Translate(hppFontItems[0].name),0,defFont{TRANSLATE-IGNORE});
    RegisterFont(Translate(hppFontItems[1].name),1,defFont{TRANSLATE-IGNORE});
    RegisterFont(Translate(hppFontItems[2].name),2,defFont{TRANSLATE-IGNORE});
    RegisterFont(Translate(hppFontItems[High(hppFontItems)].name),High(hppFontItems),defFont{TRANSLATE-IGNORE});
    RegisterColor(Translate(hppFontItems[0].nameColor),0,ColorToRGB(hppFontItems[0].back){TRANSLATE-IGNORE});
    RegisterColor(Translate(hppFontItems[1].nameColor),1,ColorToRGB(hppFontItems[1].back){TRANSLATE-IGNORE});
    RegisterColor(Translate(hppFontItems[2].nameColor),2,ColorToRGB(hppFontItems[2].back){TRANSLATE-IGNORE});
    RegisterColor(Translate(hppFontItems[High(hppFontItems)].name),High(hppFontItems),ColorToRGB(hppFontItems[High(hppFontItems)].back){TRANSLATE-IGNORE});
    for i := 3 to High(hppFontItems)-1 do begin
      GridOptions.AddItemOptions;
      RegisterFont(Translate(hppFontItems[i].name),i,defFont{TRANSLATE-IGNORE});
      RegisterColor(Translate(hppFontItems[i].name),i,hppFontItems[i].back{TRANSLATE-IGNORE});
    end;
  end;
end;

initialization

  GridOptions := TGridOptions.Create;
  GridOptions.OnShowIcons := OnShowIcons;

finalization

  if not IcoLibEnabled then
    for i := 0 to High(hppIcons) do
      if hppIcons[i].handle <> 0 then
        DestroyIcon(hppIcons[i].handle);

  GridOptions.Free;

end.


