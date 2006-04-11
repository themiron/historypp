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

  ThppIconsRec = record
    name: PChar;
    desc: PChar;
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

  hppIcons : array[0..2] of ThppIconsRec = (
    (name:'historypp_contact'; desc:'Contact history'; i:0; handle:0),
    (name:'historypp_search'; desc:'History search'; i:1; handle:0),
    (name:'historypp_session_div'; desc:'Conversations divider'; i:2; handle:0)
  );

  hppFontItems: array[0..15] of ThppFontsRec = (
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
    (name: 'Other events'; Mes: [mtOther,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $FFFFFF)
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
procedure OnShowIcons;
//procedure LoadDefaultGridOptions;
procedure hppRegisterGridOptions;

implementation

uses hpp_database;

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

procedure LoadIcons2;
var
  hic: HIcon;
  i: integer;
begin
  for i := 0 to High(hppIcons) do begin
    if IcoLibEnabled then
      hic := PluginLink.CallService(MS_SKIN2_GETICON,0,integer(hppIcons[i].name))
    else
      hic := LoadIcon(hInstance,hppIcons[i].name);
    if (hic <> 0) then
      hppIcons[i].handle := hic;
  end;
end;

{procedure LoadDefaultGridOptions;
  procedure LoadFont(Font: TFont; SettName: String);
  var
    fname: String;
    fsize: Integer;
    fcolor: TColor;
    fset: TFontCharset;
    fstyle: Byte;
    fbold,fitalic: Boolean;
  begin
    fname := GetDBStr('SRMsg',SettName+'','');
    if fname = '' then exit;
    fsize := GetDBInt('SRMsg',PChar(SettName+'Size'),-11);
    fcolor := GetDBInt('SRMsg',PChar(SettName+'Col'),clWindowText);
    fstyle := GetDBInt('SRMsg',PChar(SettName+'Sty'),0);
    if (fstyle = 1) or (fstyle=3) then
      fbold := True
    else
      fbold := False;
    if (fstyle = 2) or (fstyle=3) then
      fitalic := True
    else
      fitalic := False;
    fset := GetDBDWord('SRMsg',PChar(SettName+'Set'),DEFAULT_CHARSET);
    Font.Name := fname;
    Font.Height := fsize;
    Font.Charset := fset;
    Font.Color := fcolor;

    Font.Style := [];
    if fbold then
      Font.Style := Font.Style + [fsBold];
    if fitalic then
      Font.Style := Font.Style + [fsItalic];
    end;
begin
  GridOptions.StartChange;
  try
  GridOptions.ShowIcons := GetDBBool('SRMsg','ShowLogIcons',True);
  // Font 0  -- Outgoing Messages
  // Font 1  -- Outgoing URL
  // Font 2  -- Outgoing Files
  // Font 3  -- Incoming Messages
  // Font 4  -- Incoming Urls
  // Font 5  -- Incoming Files
  // Font 6  -- Profile Name
  // Font 7  -- Profile Time
  // Font 8  --
  // Font 9  -- Contact Name
  // Font 10 -- Contact Time

  LoadFont(GridOptions.TextOutMes,'Font0');
  LoadFont(GridOptions.TextOutUrl,'Font1');
  LoadFont(GridOptions.TextOutFile,'Font2');
  LoadFont(GridOptions.TextIncMes,'Font3');
  LoadFont(GridOptions.TextIncUrl,'Font4');
  LoadFont(GridOptions.TextIncFile,'Font5');
  LoadFont(GridOptions.TextProfile,'Font6');
  LoadFont(GridOptions.TextProfileDate,'Font7');
  LoadFont(GridOptions.TextContact,'Font9');
  LoadFont(GridOptions.TextContactDate,'Font10');
  finally
  GridOptions.EndChange;
  end;
end;}

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
      lstrcpy(fid.name,Translate(hppFontItems[Order].name));
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
  // load colors
  GridOptions.ColorDivider := LoadColorDB(0);
  GridOptions.ColorSelectedText := LoadColorDB(1);
  GridOptions.ColorSelected := LoadColorDB(2);
  // load mestype-related
  for i :=  3 to High(hppFontItems) do begin
    if (i-3) > High(GridOptions.ItemOptions) then GridOptions.AddItemOptions;
    GridOptions.ItemOptions[i-3].MessageType := hppFontItems[i].Mes;
    LoadFont(i,GridOptions.ItemOptions[i-3].textFont);
    GridOptions.ItemOptions[i-3].textColor := LoadColorDB(i);
  end;
  // load others
  GridOptions.ShowIcons := GetDBBool(hppDBName,'ShowIcons',True);

  GridOptions.RTLEnabled := GetContactRTLMode(0,'');

  GridOptions.SmileysEnabled := GetDBBool(hppDBName,'Smileys',SmileyAddEnabled);
  GridOptions.BBCodesEnabled := GetDBBool(hppDBName,'BBCodes',True);
  GridOptions.MathModuleEnabled := GetDBBool(hppDBName,'MathModule',MathModuleEnabled);
  GridOptions.UnderlineURLEnabled := GetDBBool(hppDBName,'UnderlineURL',True);
  GridOptions.FindURLEnabled := GetDBBool(hppDBName,'FindURL',True);
  finally
  GridOptions.EndChange;
  end;
end;

procedure SaveGridOptions;
begin
  GridOptions.StartChange;
  try
  WriteDBBool(hppDBName,'ShowIcons',GridOptions.ShowIcons);
  //WriteDBBool(hppDBName,'RTL',GridOptions.RTLEnabled);
  WriteDBBool(hppDBName,'Smileys',GridOptions.SmileysEnabled);
  WriteDBBool(hppDBName,'BBCodes',GridOptions.BBCodesEnabled);
  WriteDBBool(hppDBName,'MathModule',GridOptions.MathModuleEnabled);
  WriteDBBool(hppDBName,'UnderlineURL',GridOptions.UnderlineURLEnabled);
  WriteDBBool(hppDBName,'FindURL',GridOptions.FindURLEnabled);
  finally
  GridOptions.EndChange;
  end;
end;

procedure hppRegisterGridOptions;
var
  sid: TSKINICONDESC;
  defFont : FontSettings;
  i: integer;
  hppdll: string;
//  upd: TUpdate;
begin
  //
  SmileyAddEnabled := Boolean(PluginLink.ServiceExists(MS_SMILEYADD_REPLACESMILEYS));
  MathModuleEnabled := Boolean(PluginLink.ServiceExists(MATH_GET_STARTDELIMITER));
  // Register in IcoLib
  IcoLibEnabled := Boolean(PluginLink.ServiceExists(MS_SKIN2_ADDICON));
  if IcoLibEnabled then begin
    SetLength(hppdll, MAX_PATH);
    SetLength(hppdll,GetModuleFileName(hInstance,PAnsiChar(hppdll),Length(hppdll)));
    ZeroMemory(@sid,SizeOf(sid));
    sid.cbSize := SizeOf(sid);
    sid.pszSection := hppName;
    sid.pszDefaultFile := PChar(hppdll);
    for i := 0 to High(hppIcons) do begin
      sid.pszName := hppIcons[i].name;
      sid.pszDescription := translate(hppIcons[i].desc);
      sid.iDefaultIndex := hppIcons[i].i;
      PluginLink.CallService(MS_SKIN2_ADDICON,0,DWord(@sid));
    end;
  end;
  // Register in FontService
  FontServiceEnabled := Boolean(PluginLink.ServiceExists(MS_FONT_GET));
  if FontServiceEnabled then begin
    defFont.szFace := 'Tahoma';
    defFont.charset := DEFAULT_CHARSET;
    RegisterFont(Translate(hppFontItems[0].name),0,defFont);
    RegisterFont(Translate(hppFontItems[1].name),1,defFont);
    RegisterFont(Translate(hppFontItems[2].name),2,defFont);
    RegisterColor(Translate(hppFontItems[0].nameColor),0,ColorToRGB(hppFontItems[0].back));
    RegisterColor(Translate(hppFontItems[1].nameColor),1,ColorToRGB(hppFontItems[1].back));
    RegisterColor(Translate(hppFontItems[2].nameColor),2,ColorToRGB(hppFontItems[2].back));
    for i := 3 to High(hppFontItems) do begin
      GridOptions.AddItemOptions;
      RegisterFont(Translate(hppFontItems[i].name),i,defFont);
      RegisterColor(Translate(hppFontItems[i].name),i,hppFontItems[i].back);
    end;
  end;
end;

initialization

  GridOptions := TGridOptions.Create;
  GridOptions.OnShowIcons := OnShowIcons;

finalization

  GridOptions.Free;

end.


