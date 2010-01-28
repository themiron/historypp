(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.
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

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}


unit hpp_options;

interface

uses
  Graphics, Classes, SysUtils, Windows, Dialogs,
  m_globaldefs, m_api,
  HistoryGrid,
  hpp_global, hpp_contacts, hpp_events, hpp_mescatcher;

type

  ThppIntIconsRec = record
    handle: hIcon;
    case boolean of
      true:  (name: PChar);
      false: (id: SmallInt);
  end;

  ThppIconsRec = record
    name: PChar;
    desc: PChar;
    group: PChar;
    i: shortint;
  end;

  ThppFontType = set of (hppFont, hppColor);

  ThppFontsRec = record
    _type: ThppFontType;
    name: PChar;
    nameColor: PChar;
    mes: TMessageTypes;
    style: byte;
    size: Integer;
    color: TColor;
    back: TColor;
  end;

  TSaveFilter = record
    Index: Integer;
    Filter: String;
    DefaultExt: String;
    Owned: TSaveFormats;
    OwnedIndex: Integer;
  end;

const
  DEFFORMAT_CLIPCOPY        = '%nick%, %smart_datetime%:\n%mes%\n';
  DEFFORMAT_CLIPCOPYTEXT    = '%mes%\n';
  DEFFORMAT_REPLYQUOTED     = '%nick%, %smart_datetime%:\n%quot_mes%\n';
  DEFFORMAT_REPLYQUOTEDTEXT = '%quot_selmes%\n';
  DEFFORMAT_SELECTION       = '%selmes%\n';
  DEFFORMAT_DATETIME        = 'c'; // ShortDateFormat + LongTimeFormat

  hppIconsDefs : array[0..33] of ThppIconsRec = (
    (name:'historypp_01'; desc:'Contact history'; group: nil; i:HPP_ICON_CONTACTHISTORY),
    (name:'historypp_02'; desc:'History search'; group: nil; i:HPP_ICON_GLOBALSEARCH),
    (name:'historypp_03'; desc:'Conversation divider'; group: 'Conversations'; i:HPP_ICON_SESS_DIVIDER),
    (name:'historypp_04'; desc:'Conversation icon'; group: 'Conversations'; i:HPP_ICON_SESSION),
    (name:'historypp_05'; desc:'Conversation summer'; group: 'Conversations'; i:HPP_ICON_SESS_SUMMER),
    (name:'historypp_06'; desc:'Conversation autumn'; group: 'Conversations'; i:HPP_ICON_SESS_AUTUMN),
    (name:'historypp_07'; desc:'Conversation winter'; group: 'Conversations'; i:HPP_ICON_SESS_WINTER),
    (name:'historypp_08'; desc:'Conversation spring'; group: 'Conversations'; i:HPP_ICON_SESS_SPRING),
    (name:'historypp_09'; desc:'Conversation year'; group: 'Conversations'; i:HPP_ICON_SESS_YEAR),
    (name:'historypp_10'; desc:'Filter'; group: 'Toolbar'; i:HPP_ICON_HOTFILTER),
    (name:'historypp_11'; desc:'In-place filter wait'; group: 'Search panel'; i:HPP_ICON_HOTFILTERWAIT),
    (name:'historypp_12'; desc:'Search All Results'; group: nil; i:HPP_ICON_SEARCH_ALLRESULTS),
    (name:'historypp_13'; desc:'Save All'; group: 'Toolbar'; i:HPP_ICON_TOOL_SAVEALL),
    (name:'historypp_14'; desc:'Search'; group: 'Toolbar'; i:HPP_ICON_HOTSEARCH),
    (name:'historypp_15'; desc:'Search Up'; group: 'Search panel'; i:HPP_ICON_SEARCHUP),
    (name:'historypp_16'; desc:'Search Down'; group: 'Search panel'; i:HPP_ICON_SEARCHDOWN),
    (name:'historypp_17'; desc:'Delete All'; group: 'Toolbar'; i:HPP_ICON_TOOL_DELETEALL),
    (name:'historypp_18'; desc:'Delete'; group: 'Toolbar'; i:HPP_ICON_TOOL_DELETE),
    (name:'historypp_19'; desc:'Conversations'; group: 'Toolbar'; i:HPP_ICON_TOOL_SESSIONS),
    (name:'historypp_20'; desc:'Save'; group: 'Toolbar'; i:HPP_ICON_TOOL_SAVE),
    (name:'historypp_21'; desc:'Copy'; group: 'Toolbar'; i:HPP_ICON_TOOL_COPY),
    (name:'historypp_22'; desc:'End of page'; group: 'Search panel'; i:HPP_ICON_SEARCH_ENDOFPAGE),
    (name:'historypp_23'; desc:'Phrase not found'; group: 'Search panel'; i:HPP_ICON_SEARCH_NOTFOUND),
    (name:'historypp_24'; desc:'Clear in-place filter'; group: 'Search panel'; i:HPP_ICON_HOTFILTERCLEAR),
    (name:'historypp_25'; desc:'Conversation hide'; group: 'Conversations'; i:HPP_ICON_SESS_HIDE),
    (name:'historypp_26'; desc:'Drop down arrow'; group: 'Toolbar'; i:HPP_ICON_DROPDOWNARROW),
    (name:'historypp_27'; desc:'User Details'; group: 'Toolbar'; i:HPP_ICON_CONTACDETAILS),
    (name:'historypp_28'; desc:'User Menu'; group: 'Toolbar'; i:HPP_ICON_CONTACTMENU),
    (name:'historypp_29'; desc:'Bookmarks'; group: 'Toolbar'; i:HPP_ICON_BOOKMARK),
    (name:'historypp_30'; desc:'Bookmark enabled'; group: nil; i:HPP_ICON_BOOKMARK_ON),
    (name:'historypp_31'; desc:'Bookmark disabled'; group: nil; i:HPP_ICON_BOOKMARK_OFF),
    (name:'historypp_32'; desc:'Advanced Search Options'; group: 'Toolbar'; i:HPP_ICON_SEARCHADVANCED),
    (name:'historypp_33'; desc:'Limit Search Range'; group: 'Toolbar'; i:HPP_ICON_SEARCHRANGE),
    (name:'historypp_34'; desc:'Search Protected Contacts'; group: 'Toolbar'; i:HPP_ICON_SEARCHPROTECTED)
  );

  hppFontItems: array[0..29] of ThppFontsRec = (
    (_type:[hppFont,hppColor]; name: 'Incoming nick'; nameColor: 'Divider'; Mes: []; style:DBFONTF_BOLD; size: -11; color: $6B3FC8; back: clGray),
    (_type:[hppFont,hppColor]; name: 'Outgoing nick'; nameColor: 'Selected text'; Mes: []; style:DBFONTF_BOLD; size: -11; color: $BD6008; back: clHighlightText),
    (_type:[hppColor];         nameColor: 'Selected background'; Mes: []; back: clHighlight),
    (_type:[hppFont,hppColor]; name: 'Incoming message'; Mes: [mtMessage,mtIncoming]; style:0; size: -11; color: $000000; back: $DBDBDB),
    (_type:[hppFont,hppColor]; name: 'Outgoing message'; Mes: [mtMessage,mtOutgoing]; style:0; size: -11; color: $000000; back: $EEEEEE),
    (_type:[hppFont,hppColor]; name: 'Incoming file'; Mes: [mtFile,mtIncoming]; style:0; size: -11; color: $000000; back: $9BEEE3),
    (_type:[hppFont,hppColor]; name: 'Outgoing file'; Mes: [mtFile,mtOutgoing]; style:0; size: -11; color: $000000; back: $9BEEE3),
    (_type:[hppFont,hppColor]; name: 'Incoming url'; Mes: [mtUrl,mtIncoming]; style:0; size: -11; color: $000000; back: $F4D9CC),
    (_type:[hppFont,hppColor]; name: 'Outgoing url'; Mes: [mtUrl,mtOutgoing]; style:0; size: -11; color: $000000; back: $F4D9CC),
    (_type:[hppFont,hppColor]; name: 'Incoming SMS Message'; Mes: [mtSMS,mtIncoming]; style:0; size: -11; color: $000000; back: $CFF4FE),
    (_type:[hppFont,hppColor]; name: 'Outgoing SMS Message'; Mes: [mtSMS,mtOutgoing]; style:0; size: -11; color: $000000; back: $CFF4FE),
    (_type:[hppFont,hppColor]; name: 'Incoming contacts'; Mes: [mtContacts,mtIncoming]; style:0; size: -11; color: $000000; back: $FEF4CF),
    (_type:[hppFont,hppColor]; name: 'Outgoing contacts'; Mes: [mtContacts,mtOutgoing]; style:0; size: -11; color: $000000; back: $FEF4CF),
    (_type:[hppFont,hppColor]; name: 'System message'; Mes: [mtSystem,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $CFFEDC),
    (_type:[hppFont,hppColor]; name: 'Status changes'; Mes: [mtStatus,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $F0F0F0),
    (_type:[hppFont,hppColor]; name: 'SMTP Simple Email'; Mes: [mtSMTPSimple,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $FFFFFF),
    (_type:[hppFont,hppColor]; name: 'Other events (unknown)'; Mes: [mtOther,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $FFFFFF),
    (_type:[hppFont,hppColor]; name: 'Conversation header'; Mes: []; style:0; size: -11; color: $000000; back: $00D7FDFF),
    (_type:[hppFont,hppColor]; name: 'Nick changes'; Mes: [mtNickChange,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $00D7FDFF),
    (_type:[hppFont,hppColor]; name: 'Avatar changes'; Mes: [mtAvatarChange,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $00D7FDFF),
    (_type:[hppFont];          name: 'Incoming timestamp'; Mes: []; style:0; size: -11; color: $000000),
    (_type:[hppFont];          name: 'Outgoing timestamp'; Mes: []; style:0; size: -11; color: $000000),
    (_type:[hppFont,hppColor]; name: 'Grid messages'; nameColor: 'Grid background'; Mes: []; style:0; size: -11; color: $000000; back: $E9EAEB),
    (_type:[hppFont,hppColor]; name: 'Incoming WATrack notify'; Mes: [mtWATrack,mtIncoming]; style:0; size: -11; color: $C08000; back: $C8FFFF),
    (_type:[hppFont,hppColor]; name: 'Outgoing WATrack notify'; Mes: [mtWATrack,mtOutgoing]; style:0; size: -11; color: $C08000; back: $C8FFFF),
    (_type:[hppFont,hppColor]; name: 'Status message changes'; Mes: [mtStatusMessage,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $F0F0F0),
    (_type:[hppFont,hppColor]; name: 'Voice calls'; Mes: [mtVoiceCall,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $E9DFAB),
    (_type:[hppFont,hppColor]; name: 'Webpager message'; Mes: [mtWebPager,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $FFFFFF),
    (_type:[hppFont,hppColor]; name: 'EMail Express message'; Mes: [mtEmailExpress,mtIncoming,mtOutgoing]; style:0; size: -11; color: $000000; back: $FFFFFF),
    (_type:[hppColor];         nameColor: 'Link'; Mes: []; back: clBlue)
    );

  SaveFormatsDef: array[TSaveFormat] of TSaveFilter = (
    (Index: -1; Filter:'All files'; DefaultExt:'*.*'; Owned:[]; OwnedIndex: -1),
    (Index: 1;  Filter:'HTML file'; DefaultExt:'*.html'; Owned:[]; OwnedIndex: -1),
    (Index: 2;  Filter:'XML file'; DefaultExt:'*.xml'; Owned:[]; OwnedIndex: -1),
    (Index: 3;  Filter:'RTF file'; DefaultExt:'*.rtf'; Owned:[]; OwnedIndex: -1),
    (Index: 4;  Filter:'mContacts files'; DefaultExt:'*.dat'; Owned:[]; OwnedIndex: -1),
    (Index: 5;  Filter:'Unicode text file'; DefaultExt:'*.txt'; Owned:[sfUnicode,sfText]; OwnedIndex: 1),
    (Index: 6;  Filter:'Text file'; DefaultExt:'*.txt'; Owned:[sfUnicode,sfText]; OwnedIndex: 2));

var
  hppIntIcons: array[0..0] of ThppIntIconsRec = (
    (handle: 0; name:'z_password_protect')
  );

var
  GridOptions: TGridOptions;
  IcoLibEnabled: Boolean;
  FontServiceEnabled: Boolean;
  SmileyAddEnabled: Boolean;
  MathModuleEnabled: Boolean;
  MetaContactsEnabled: Boolean;
  MetaContactsProto: String;
  DatabaseNewAPI: Boolean;
  MeSpeakEnabled: Boolean;
  ShowHistoryCount: Boolean;
  hppIcons: array of ThppIntIconsRec;
  skinIcons: array of ThppIntIconsRec;
  SaveFormats: array[TSaveFormat] of TSaveFilter;

procedure LoadGridOptions;
procedure SaveGridOptions;
procedure LoadIcons;
procedure LoadIcons2;
procedure LoadIntIcons;
procedure OnShowIcons;
procedure OnTextFormatting(Value: Boolean);
procedure hppRegisterGridOptions;
procedure hppPrepareTranslation;
procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);

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
  fid.deffontsettings.colour := ColorToRGB(hppFontItems[Order].color);
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
  cid.defcolour := ColorToRGB(defColor);
  PluginLink.CallService(MS_COLOUR_REGISTER,integer(@cid),0);
end;

procedure OnShowIcons;
begin
  if GridOptions.ShowIcons then LoadIcons;
end;

procedure OnTextFormatting(Value: Boolean);
begin
  WriteDBBool(hppDBName,'InlineTextFormatting',Value);
end;

{function LoadIconFromDB(ID: Integer; Icon: TIcon): Boolean;
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
end;}

procedure LoadIcons;
var
  i: Integer;
  ic: hIcon;
  Changed: Boolean;
begin
  Changed := False;
  GridOptions.StartChange;
  try
    //LoadIconFromDB(SKINICON_EVENT_MESSAGE,GridOptions.IconMessage);
    //LoadIconFromDB(SKINICON_EVENT_URL,GridOptions.IconUrl);
    //LoadIconFromDB(SKINICON_EVENT_FILE,GridOptions.IconFile);
    //LoadIconFromDB(SKINICON_OTHER_MIRANDA,GridOptions.IconOther);
    for i := 0 to High(skinIcons) do begin
      ic := LoadSkinnedIcon(skinIcons[i].id);
      if skinIcons[i].handle <> ic then begin
        skinIcons[i].handle := ic;
        Changed := True;
      end;
    end;
  finally
    GridOptions.EndChange(Changed);
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
  i: integer;
  NeedIcons,CountIconsDll: Integer;
  SmallIcons: array of hIcon;
  ic: hIcon;
  Changed: Boolean;
begin
  Changed := False;
  GridOptions.StartChange;
  try
    if IcoLibEnabled then begin
      for i := 0 to High(hppIcons) do begin
        ic := PluginLink.CallService(MS_SKIN2_GETICON,0,LPARAM(hppIcons[i].name));
        if hppIcons[i].handle <> ic then begin
          hppIcons[i].handle := ic;
          Changed := True;
        end;
      end;
    end else begin
      CountIconsDll := ExtractIconEx(PChar(hppIconPack),-1,HICON(nil^),HICON(nil^),0);
      NeedIcons := Min(Length(hppIcons),CountIconsDll);
      if NeedIcons > 0 then begin
        SetLength(SmallIcons,NeedIcons);
        CountIconsDll := ExtractIconEx(PChar(hppIconPack),0,HICON(nil^),SmallIcons[0],NeedIcons);
        for i := 0 to CountIconsDll - 1 do
          hppIcons[i].handle := SmallIcons[i];
        Finalize(SmallIcons);
        Changed := True;
      end;
    end;
  finally
    GridOptions.EndChange(Changed);
  end;
end;

procedure LoadGridOptions;

  function LoadColorDB(Order: integer): TColor;
  begin
    Result := GetDBInt(hppDBName,PChar('Color'+intToStr(Order)),ColorToRGB(hppFontItems[Order].back));
  end;

  function LoadFont(Order: integer; F: TFont): TFont;
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
      F.Color := ColorToRGB(hppFontItems[Order].color);
    end;
    Result := F;
  end;

var
  i,index: integer;
begin
  GridOptions.StartChange;
  try
    // load fonts
  LoadFont(0,GridOptions.FontContact);
  GridOptions.FontProfile := LoadFont(1,GridOptions.FontProfile);
  //GridOptions.FontSelected := LoadFont(2,GridOptions.FontSelected);
  GridOptions.FontSessHeader := LoadFont(17,GridOptions.FontSessHeader);
  GridOptions.FontIncomingTimestamp := LoadFont(20,GridOptions.FontIncomingTimestamp);
  GridOptions.FontOutgoingTimestamp := LoadFont(21,GridOptions.FontOutgoingTimestamp);
  GridOptions.FontMessage := LoadFont(22,GridOptions.FontMessage);
  // load colors
  GridOptions.ColorDivider := LoadColorDB(0);
  GridOptions.ColorSelectedText := LoadColorDB(1);
  GridOptions.ColorSelected := LoadColorDB(2);
  GridOptions.ColorSessHeader := LoadColorDB(17);
  GridOptions.ColorBackground := LoadColorDB(22);
  GridOptions.ColorLink := LoadColorDB(29);

  // load mestype-related
  index := 0;
  for i :=  0 to High(hppFontItems) do begin
    if hppFontItems[i].mes <> [] then begin
      if index > High(GridOptions.ItemOptions) then GridOptions.AddItemOptions;
      GridOptions.ItemOptions[index].MessageType := hppFontItems[i].Mes;
      GridOptions.ItemOptions[index].textFont := LoadFont(i,GridOptions.ItemOptions[index].textFont);
      GridOptions.ItemOptions[index].textColor := LoadColorDB(i);
      Inc(index);
    end;
  end;

  //for i :=  3 to High(hppFontItems)-1 do begin
  //  if (i-3) > High(GridOptions.ItemOptions) then GridOptions.AddItemOptions;
  //  GridOptions.ItemOptions[i-3].MessageType := hppFontItems[i].Mes;
  //  LoadFont(i,GridOptions.ItemOptions[i-3].textFont);
  //  GridOptions.ItemOptions[i-3].textColor := LoadColorDB(i);
  //end;

  // load others
  GridOptions.ShowIcons := GetDBBool(hppDBName,'ShowIcons',True);
  GridOptions.RTLEnabled := GetContactRTLMode(0,'');  // we have no per-proto rtl setup ui, use global instead
  //GridOptions.ShowAvatars := GetDBBool(hppDBName,'ShowAvatars',False);

  GridOptions.SmileysEnabled := GetDBBool(hppDBName,'Smileys',SmileyAddEnabled);
  GridOptions.BBCodesEnabled := GetDBBool(hppDBName,'BBCodes',True);
  GridOptions.MathModuleEnabled := GetDBBool(hppDBName,'MathModule',MathModuleEnabled);
  GridOptions.RawRTFEnabled := GetDBBool(hppDBName,'RawRTF',True);
  GridOptions.AvatarsHistoryEnabled := GetDBBool(hppDBName,'AvatarsHistory',True);

  GridOptions.OpenDetailsMode := GetDBBool(hppDBName,'OpenDetailsMode',False);

  GridOptions.ClipCopyFormat := GetDBWideStr(hppDBName,'FormatCopy',DEFFORMAT_CLIPCOPY);
  GridOptions.ClipCopyTextFormat := GetDBWideStr(hppDBName,'FormatCopyText',DEFFORMAT_CLIPCOPYTEXT);
  GridOptions.ReplyQuotedFormat := GetDBWideStr(hppDBName,'FormatReplyQuoted',DEFFORMAT_REPLYQUOTED);
  GridOptions.ReplyQuotedTextFormat := GetDBWideStr(hppDBName,'FormatReplyQuotedText',DEFFORMAT_REPLYQUOTEDTEXT);
  GridOptions.SelectionFormat := GetDBWideStr(hppDBName,'FormatSelection',DEFFORMAT_SELECTION);
  GridOptions.ProfileName := GetDBWideStr(hppDBName,'ProfileName','');
  GridOptions.DateTimeFormat := GetDBStr(hppDBName,'DateTimeFormat',DEFFORMAT_DATETIME);
  GridOptions.TextFormatting := GetDBBool(hppDBName,'InlineTextFormatting',True);

  ShowHistoryCount := GetDBBool(hppDBName,'ShowHistoryCount',false);
  finally
  GridOptions.EndChange;
  end;
end;

procedure SaveGridOptions;
begin
  GridOptions.StartChange;
  try
  WriteDBBool(hppDBName,'ShowIcons',GridOptions.ShowIcons);
  WriteDBBool(hppDBName,'RTL',GridOptions.RTLEnabled);
  //WriteDBBool(hppDBName,'ShowAvatars',GridOptions.ShowAvatars);

  WriteDBBool(hppDBName,'BBCodes',GridOptions.BBCodesEnabled);
  WriteDBBool(hppDBName,'Smileys',GridOptions.SmileysEnabled);
  WriteDBBool(hppDBName,'MathModule',GridOptions.MathModuleEnabled);
  WriteDBBool(hppDBName,'RawRTF',GridOptions.RawRTFEnabled);
  WriteDBBool(hppDBName,'AvatarsHistory',GridOptions.AvatarsHistoryEnabled);

  WriteDBBool(hppDBName,'OpenDetailsMode',GridOptions.OpenDetailsMode);

  //WriteDBWideStr(hppDBName,'FormatCopy',GridOptions.ClipCopyFormat);
  //WriteDBWideStr(hppDBName,'FormatCopyText',GridOptions.ClipCopyTextFormat);
  finally
  GridOptions.EndChange;
  end;
end;

function FindIconsDll(ForceCheck: Boolean): string;
var
  hppIconsDir: string;
  hppMessage: WideString;
  CountIconsDll: Integer;
  DoCheck: Boolean;
begin
  DoCheck := ForceCheck or GetDBBool(hppDBName,'CheckIconPack',True);
  hppIconsDir := ExpandFileName(hppPluginsDir+'..\Icons\');
  if FileExists(hppIconsDir+hppIPName) then
    Result := hppIconsDir+hppIPName
  else
  if FileExists(hppPluginsDir+hppIPName) then
    Result := hppPluginsDir+hppIPName
  else begin
    Result := hppPluginsDir+hppDllName;
    if DoCheck then begin
      DoCheck := False;
      hppMessage := WideFormat(FormatCString(
        TranslateWideW('Cannot load icon pack (%s) from:\r\n%s\r\nThis can cause no icons will be shown.')),
        [hppIPName,hppIconsDir+#13#10+hppPluginsDir]);
      hppMessageBox(hppMainWindow,hppMessage,hppName+' Error',MB_ICONERROR or MB_OK);
    end;
  end;
  if DoCheck then begin
    CountIconsDll := ExtractIconEx(PChar(Result),-1,HICON(nil^),HICON(nil^),0);
    if CountIconsDll < HppIconsCount then begin
      hppMessage := WideFormat(FormatCString(
        TranslateWideW('You are using old icon pack from:\r\n%s\r\nThis can cause missing icons, so update the icon pack.')),
        [AnsiToWideString(Result,hppCodepage)]);
      hppMessageBox(hppMainWindow,hppMessage,hppName+' Warning',MB_ICONWARNING or MB_OK);
    end;
  end;
end;

procedure hppRegisterGridOptions;
var
  sid: TSKINICONDESC;
  defFont : FontSettings;
  //sarc: SMADD_REGCAT;
  i: integer;
  mt: TMessageType;
  str: PChar;
begin
  // Register in IcoLib
  IcoLibEnabled := Boolean(PluginLink.ServiceExists(MS_SKIN2_ADDICON));
  hppIconPack := FindIconsDll(not IcoLibEnabled);
  if IcoLibEnabled then begin
    ZeroMemory(@sid,SizeOf(sid));
    sid.cbSize := SizeOf(sid);
    sid.pszDefaultFile := PChar(hppIconPack);
    for i := 0 to High(hppIconsDefs) do begin
      hppIcons[hppIconsDefs[i].i].name := hppIconsDefs[i].name;
      sid.pszName := hppIconsDefs[i].name;
      sid.pszDescription := Translate(hppIconsDefs[i].desc{TRANSLATE-IGNORE});
      if hppIconsDefs[i].group = nil then
        sid.pszSection := Translate(hppName{TRANSLATE-IGNORE}) else
        sid.pszSection := PChar(Translate(hppName){TRANSLATE-IGNORE}+'/'+Translate(hppIconsDefs[i].group){TRANSLATE-IGNORE});
      sid.iDefaultIndex := hppIconsDefs[i].i;
      PluginLink.CallService(MS_SKIN2_ADDICON,0,LPARAM(@sid));
    end;
  end;
  for mt := Low(EventRecords) to High(EventRecords) do begin
    if EventRecords[mt].i = -1 then continue;
    if EventRecords[mt].iSkin = -1 then begin
      if IcoLibEnabled then begin
        hppIcons[EventRecords[mt].i].name := EventRecords[mt].iName;
        sid.pszName := hppIcons[EventRecords[mt].i].name;
        sid.pszDescription := Translate(PChar(WideToAnsiString(EventRecords[mt].Name,hppCodepage)){TRANSLATE-IGNORE});
        sid.pszSection := PChar(Translate(hppName){TRANSLATE-IGNORE}+'/'+Translate('Events'){TRANSLATE-IGNORE});
        sid.iDefaultIndex := EventRecords[mt].i;
        PluginLink.CallService(MS_SKIN2_ADDICON,0,LPARAM(@sid));
      end;
    end else
      skinIcons[EventRecords[mt].i].id := EventRecords[mt].iSkin;
  end;

  // Register in FontService
  FontServiceEnabled := Boolean(PluginLink.ServiceExists(MS_FONT_GET));
  if FontServiceEnabled then begin
    defFont.szFace := 'Tahoma';
    defFont.charset := DEFAULT_CHARSET;
    for i := 0 to High(hppFontItems) do begin
      if hppFontItems[i].mes <> [] then GridOptions.AddItemOptions;
      if hppFont in hppFontItems[i]._type then begin
        RegisterFont(Translate(hppFontItems[i].name),i,defFont{TRANSLATE-IGNORE});
      end;
      if hppColor in hppFontItems[i]._type then begin
        if hppFontItems[i].nameColor = '' then
          RegisterColor(Translate(hppFontItems[i].name),i,hppFontItems[i].back{TRANSLATE-IGNORE})
        else
          RegisterColor(Translate(hppFontItems[i].nameColor),i,hppFontItems[i].back{TRANSLATE-IGNORE});
      end;
    end;
  end;
  // Register in SmileyAdd
  SmileyAddEnabled := Boolean(PluginLink.ServiceExists(MS_SMILEYADD_REPLACESMILEYS));
  {if SmileyAddEnabled then begin
    ZeroMemory(@sarc,SizeOf(sarc));
    sarc.cbSize := SizeOf(sarc);
    sarc.name := hppName;
    sarc.dispname := hppName;
    PluginLink.CallService(MS_SMILEYADD_REGISTERCATEGORY,0,LPARAM(@sarc));
  end;}
  // Register in MathModule
  MathModuleEnabled := Boolean(PluginLink.ServiceExists(MATH_RTF_REPLACE_FORMULAE));
  // Checking MetaContacts
  MetaContactsEnabled := Boolean(PluginLink.ServiceExists(MS_MC_GETMOSTONLINECONTACT));
  if MetaContactsEnabled then begin
    str := PChar(PluginLink.CallService(MS_MC_GETPROTOCOLNAME,0,0));
    if Assigned(str) then
      MetaContactsProto := AnsiString(str) else
      MetaContactsEnabled := False;
  end;
  // Checking MS_DB_EVENT_GETTEXT database service
  DatabaseNewAPI := Boolean(PluginLink.ServiceExists(MS_DB_EVENT_GETTEXT));
  // Checking presence of speech api
  MeSpeakEnabled := Boolean(PluginLink.ServiceExists(MS_SPEAK_SAY_W)) or
                    Boolean(PluginLink.ServiceExists(MS_SPEAK_SAY_A));
end;

procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);
var
  sf: TSaveFormat;
begin
  SaveDialog.Filter := '';
  if SaveFormat = sfAll then SaveFormat := Succ(SaveFormat);
  if AllFormats then begin
    for sf := Low(SaveFormats) to High(SaveFormats) do
      if sf <> sfAll then
        SaveDialog.Filter := SaveDialog.Filter + SaveFormats[sf].Filter+'|';
    SaveDialog.FilterIndex := SaveFormats[SaveFormat].Index;
  end else begin
    if SaveFormats[SaveFormat].Owned = [] then begin
      SaveDialog.Filter := SaveFormats[SaveFormat].Filter+'|';
      SaveDialog.Filter := SaveDialog.Filter+SaveFormats[sfAll].Filter;
      SaveDialog.FilterIndex := 1;
    end else begin
      for sf := Low(SaveFormats) to High(SaveFormats) do
        if sf in SaveFormats[SaveFormat].Owned then
          SaveDialog.Filter := SaveDialog.Filter + SaveFormats[sf].Filter+'|';
      SaveDialog.FilterIndex := SaveFormats[SaveFormat].OwnedIndex;
    end;
  end;
  SaveDialog.DefaultExt := SaveFormats[SaveFormat].DefaultExt;
end;

procedure hppPrepareTranslation;
var
  sf: TSaveFormat;
begin
  for sf := Low(SaveFormatsDef) to High(SaveFormatsDef) do begin
    SaveFormats[sf] := SaveFormatsDef[sf];
    SaveFormats[sf].Filter := Format('%s (%s)|%s',
      [TranslateString(SaveFormatsDef[sf].Filter{TRANSLATE-IGNORE}),
       SaveFormatsDef[sf].DefaultExt,SaveFormatsDef[sf].DefaultExt]);
  end;
end;

initialization

  GridOptions := TGridOptions.Create;
  GridOptions.OnShowIcons := OnShowIcons;
  GridOptions.OnTextFormatting := OnTextFormatting;
  SetLength(hppIcons,HppIconsCount);
  SetLength(skinIcons,SkinIconsCount);

finalization

  for i := 0 to High(hppIntIcons) do
    if hppIntIcons[i].handle <> 0 then DestroyIcon(hppIntIcons[i].handle);
  if not IcoLibEnabled then
    for i := 0 to High(hppIcons) do
      if hppIcons[i].handle <> 0 then DestroyIcon(hppIcons[i].handle);
  Finalize(hppIcons);
  Finalize(skinIcons);

  GridOptions.Free;

end.


