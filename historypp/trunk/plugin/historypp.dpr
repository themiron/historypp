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

library historypp;

{$IMAGEBASE $02630000}

// use fast memory manager on pre-BDS2006
{$DEFINE USE_FASTMM}
// report leaks on exit, also enables USE_FASTMM
{.$DEFINE REPORT_LEAKS}

{%ToDo 'historypp.todo'}
{$R 'hpp_resource.res' 'hpp_resource.rc'}
{$R 'hpp_res_ver.res' 'hpp_res_ver.rc'}
{$R 'hpp_opt_dialog.res' 'hpp_opt_dialog.rc'}

{$I compilers.inc}

{$IFDEF REPORT_LEAKS}
  {$IFNDEF USE_FASTMM}
    {$DEFINE USE_FASTMM}
  {$ENDIF ~USE_FASTMM}
{$ENDIF ~REPORT_LEAKS}
{$IFDEF USE_FASTMM}
  // handle > 2Gb adresses with fastmm
  {$SetPEFlags $20}
  {$IFDEF DELPHI_10_UP}
    {$UNDEF USE_FASTMM}
  {$ENDIF ~DELPHI_10_UP}
{$ENDIF ~USE_FASTMM}

uses
  {$IFDEF USE_FASTMM}FastMM4,{$ENDIF}
  {$IFDEF EUREKALOG}ExceptionLog,{$ENDIF}
  RtlVclOptimize,
  Windows,
  SysUtils,
  {$IFDEF REPORT_LEAKS} Themes, {$ENDIF}
  m_globaldefs,
  m_api,
  TntSystem,
  Forms,
  hpp_global in 'hpp_global.pas',
  hpp_contacts in 'hpp_contacts.pas',
  hpp_database in 'hpp_database.pas',
  hpp_events in 'hpp_events.pas',
  hpp_services in 'hpp_services.pas',
  hpp_itemprocess in 'hpp_itemprocess.pas',
  hpp_options in 'hpp_options.pas',
  hpp_messages in 'hpp_messages.pas',
  HistoryGrid in 'HistoryGrid.pas',
  VertSB in 'VertSB.pas',
  HistoryForm in 'HistoryForm.pas' {HistoryFrm},
  EventDetailForm in 'EventDetailForm.pas' {EventDetailsFrm},
  EmptyHistoryForm in 'EmptyHistoryForm.pas' {EmptyHistoryFrm},
  PassForm in 'PassForm.pas' {fmPass},
  PassNewForm in 'PassNewForm.pas' {fmPassNew},
  PassCheckForm in 'PassCheckForm.pas' {fmPassCheck},
  GlobalSearch in 'GlobalSearch.pas' {fmGlobalSearch},
  hpp_searchthread in 'hpp_searchthread.pas',
  hpp_miranda_mmi in 'hpp_miranda_mmi.pas',
  hpp_bookmarks in 'hpp_bookmarks.pas',
  hpp_sessionsthread in 'hpp_sessionsthread.pas',
  hpp_arrays in 'hpp_arrays.pas',
  hpp_strparser in 'hpp_strparser.pas',
  hpp_forms in 'hpp_forms.pas',
  hpp_opt_dialog in 'hpp_opt_dialog.pas',
  hpp_eventfilters in 'hpp_eventfilters.pas',
  hpp_mescatcher in 'hpp_mescatcher.pas',
  CustomizeFiltersForm in 'CustomizeFiltersForm.pas' {fmCustomizeFilters},
  CustomizeToolbar in 'CustomizeToolbar.pas' {fmCustomizeToolbar},
  {$IFNDEF NO_EXTERNALGRID}
  hpp_external in 'hpp_external.pas',
  hpp_externalgrid in 'hpp_externalgrid.pas',
  {$ENDIF}
  hpp_richedit in 'hpp_richedit.pas',
  hpp_olesmileys in 'hpp_olesmileys.pas';

type
  TMenuHandles = record
    Handle: THandle;
    Name: String;
  end;

const
  UnicodeFlag: array[Boolean] of Byte = (0,UNICODE_AWARE);

var
  PluginInfoEx: TPLUGININFOEX = (
    cbSize: SizeOf(TPLUGININFOEX);
    shortName: hppShortNameV;
    version: hppVersion;
    description: hppDescription;
    author: hppAuthor;
    authorEmail: hppAuthorEmail;
    copyright: hppCopyright;
    homepage: hppHomePageURL;
    replacesDefaultModule: DEFMOD_UIHISTORY;
    uuid: MIID_HISTORYPP;
  );

  PluginInfo: TPLUGININFO = (
    cbSize: SizeOf(TPLUGININFO);
    shortName: hppShortNameV;
    version: hppVersion;
    description: hppDescription;
    author: hppAuthor;
    authorEmail: hppAuthorEmail;
    copyright: hppCopyright;
    homepage: hppHomePageURL;
    replacesDefaultModule: DEFMOD_UIHISTORY;
  );

  PluginInterfaces: array[0..2] of TGUID = (
    MIID_UIHISTORY,
    MIID_LOGWINDOW,
    MIID_LAST);

const
  miContact  = 0;
  miSystem   = 1;
  miSearch   = 2;
  miEmpty    = 3;
  miSysEmpty = 4;

var
  MenuCount: Integer = -1;
  PrevShowHistoryCount: Boolean = False;
  MenuHandles: array[0..4] of TMenuHandles = (
    (Handle:0; Name:'View &History'),
    (Handle:0; Name:'&System History'),
    (Handle:0; Name:'His&tory Search'),
    (Handle:0; Name:'&Empty History'),
    (Handle:0; Name:'&Empty System History'));

var
  HookModulesLoad,
  HookOptInit,
  HookSettingsChanged,
  HookSmAddChanged,
  HookIconChanged,
  HookIcon2Changed,
  //hookContactChanged,
  HookContactDelete,
  HookFSChanged,
  HookTTBLoaded,
  HookBuildMenu,
  HookEventAdded,
  HookEventDeleted,
  HookMetaDefaultChanged,
  HookPreshutdown: THandle;

function OnModulesLoad(wParam,lParam:DWORD):integer; cdecl; forward;
function OnSettingsChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnSmAddSettingsChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnIconChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnIcon2Changed(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnOptInit(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnContactChanged(wParam: wParam; lParam: LPARAM): Integer; cdecl; forward;
function OnContactDelete(wParam: wParam; lParam: LPARAM): Integer; cdecl; forward;
function OnFSChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnTTBLoaded(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnBuildContactMenu(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnEventAdded(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnEventDeleted(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnMetaDefaultChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnPreshutdown(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;

//Tell Miranda about this plugin
function MirandaPluginInfo(mirandaVersion:DWORD): PPLUGININFO; cdecl;
begin
  if mirandaVersion >= $0400 then
    Result := @PluginInfo else
    Result := nil;
end;

// tell Miranda about this plugin ExVersion
function MirandaPluginInfoEx(mirandaVersion:DWORD): PPLUGININFOEX; cdecl;
begin
  Result := @PluginInfoEx;
end;

// tell Miranda about supported interfaces
function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  Result := @PluginInterfaces;
end;

// load function called by miranda
function Load(link:PPLUGINLINK):Integer; cdecl;
var
  pszVersion: array[0..55] of Char;
begin
  PluginLink := Pointer(link);
  PluginLink.CallService(MS_SYSTEM_GETVERSIONTEXT,SizeOf(pszVersion),LPARAM(@pszVersion));
  StrLower(@pszVersion);
  // Checking if core is unicode
  hppCoreUnicode := (StrPos(pszVersion,'unicode') <> nil);
  // Getting langpack codepage for ansi translation
  hppCodepage := PluginLink.CallService(MS_LANGPACK_GETCODEPAGE,0,0);
  if (hppCodepage = CALLSERVICE_NOTFOUND) or
     (hppCodepage = CP_ACP) then hppCodepage := GetACP();
  // Checking the version of richedit is available, need 2.0+
  hppRichEditVersion := InitRichEditLibrary;
  if hppRichEditVersion < 20 then begin
    hppMessagebox(hppMainWindow, FormatCString( // single line to translation script
      TranslateWideW('History++ module could not be loaded, richedit 2.0+ module is missing.\nPress OK to continue loading Miranda.')),
      hppName+' Information', MB_OK or MB_ICONINFORMATION);
    Result := 1;
    exit;
  end;
  // Get profile dir
  SetLength(hppProfileDir,MAX_PATH);
  PluginLink.CallService(MS_DB_GETPROFILEPATH,MAX_PATH,LParam(@hppProfileDir[1]));
  SetLength(hppProfileDir,StrLen(@hppProfileDir[1]));
  // Get plugins dir
  SetLength(hppPluginsDir,MAX_PATH);
  SetLength(hppPluginsDir,GetModuleFileName(hInstance,@hppPluginsDir[1],MAX_PATH));
  hppDllName := ExtractFileName(hppPluginsDir);
  hppPluginsDir := ExtractFilePath(hppPluginsDir);
  //init history functions later
  HookModulesLoad := PluginLink.HookEvent(ME_SYSTEM_MODULESLOADED,OnModulesLoad);
  hookOptInit := PluginLink.HookEvent(ME_OPT_INITIALISE,OnOptInit);
  InitMMI;
  hppRegisterServices;
  {$IFNDEF NO_EXTERNALGRID}
  RegisterExtGridServices;
  {$ENDIF}
  hppRegisterMainWindow;
  Result := 0;
end;

// unload
function Unload:Integer; cdecl;
begin
  Result:=0;

  // unhook events
  PluginLink.UnhookEvent(hookOptInit);
  PluginLink.UnhookEvent(HookPreshutdown);
  PluginLink.UnhookEvent(HookModulesLoad);

  PluginLink.UnhookEvent(HookEventAdded);
  PluginLink.UnhookEvent(HookEventDeleted);
  PluginLink.UnhookEvent(HookSettingsChanged);
  PluginLink.UnhookEvent(HookIconChanged);
  PluginLink.UnhookEvent(HookContactDelete);
  PluginLink.UnhookEvent(HookBuildMenu);

  if SmileyAddEnabled then
    PluginLink.UnhookEvent(HookSmAddChanged);
  if IcoLibEnabled then
    PluginLink.UnhookEvent(HookIcon2Changed);
  if FontServiceEnabled then
    PluginLink.UnhookEvent(HookFSChanged);
  if MetaContactsEnabled then
    PluginLink.UnhookEvent(HookMetaDefaultChanged);

  try
    // destroy hidden main window
    hppUnregisterMainWindow;
    {$IFNDEF NO_EXTERNALGRID}
    UnregisterExtGridServices;
    {$ENDIF}
    // unregistering events
    hppUnregisterServices;
    // unregister bookmarks
    hppDeinitBookmarkServer;

  except
    on E: Exception do
      HppMessageBox(hppMainWindow,
        'Error while closing '+hppName+':'+#10#13+E.Message,
        hppName+' Error',MB_OK or MB_ICONERROR);
  end;
end;

// init plugin
function OnModulesLoad(wParam{0},lParam{0}:DWORD):integer; cdecl;
var
  i: integer;
  menuitem:TCLISTMENUITEM;
  upd: TUpdate;
begin

  // register
  hppRegisterGridOptions;
  // pretranslate strings
  hppPrepareTranslation;

  LoadIcons;
  LoadIcons2;
  LoadIntIcons;

  // TopToolBar support
  HookTTBLoaded := PluginLink.HookEvent(ME_TTB_MODULELOADED,OnTTBLoaded);

  hppInitBookmarkServer;

  InitEventFilters;
  ReadEventFilters;

  for i := 0 to High(MenuHandles) do
    MenuHandles[i].Name := TranslateString(MenuHandles[i].Name{TRANSLATE-IGNORE});

  ZeroMemory(@menuitem,SizeOf(menuItem));

  //create contact item in contact menu
  menuitem.cbSize := SizeOf(menuItem);
  menuitem.pszContactOwner := nil;    //all contacts
  menuitem.flags := 0;
  menuitem.Position := 1000090000;
  menuitem.pszName := PChar(MenuHandles[miContact].Name);
  menuitem.pszService := MS_HISTORY_SHOWCONTACTHISTORY;
  menuitem.hIcon := hppIcons[HPP_ICON_CONTACTHISTORY].handle;
  MenuHandles[miContact].Handle := PluginLink.CallService(MS_CLIST_ADDCONTACTMENUITEM,0,DWORD(@menuItem));

  //create empty item in contact menu
  menuitem.Position := 1000090001;
  menuitem.pszName := PChar(MenuHandles[miEmpty].Name);
  menuitem.pszService := MS_HPP_EMPTYHISTORY;
  menuitem.hIcon := hppIcons[HPP_ICON_TOOL_DELETEALL].handle;
  MenuHandles[miEmpty].Handle := PluginLink.CallService(MS_CLIST_ADDCONTACTMENUITEM,0,DWORD(@menuItem));

  //create menu item in main menu for system history
  menuitem.Position:=500060000;
  menuitem.pszName:=PChar(MenuHandles[miSystem].Name);
  menuitem.pszService := MS_HISTORY_SHOWCONTACTHISTORY;
  menuitem.hIcon := hppIcons[HPP_ICON_CONTACTHISTORY].handle;
  MenuHandles[miSystem].Handle := PluginLink.CallService(MS_CLIST_ADDMAINMENUITEM,0,DWORD(@menuitem));

  //create menu item in main menu for history search
  menuitem.Position:=500060001;
  menuitem.pszName:=PChar(MenuHandles[miSearch].Name);
  menuitem.pszService := MS_HPP_SHOWGLOBALSEARCH;
  menuitem.hIcon := hppIcons[HPP_ICON_GLOBALSEARCH].handle;
  MenuHandles[miSearch].Handle := PluginLink.CallService(MS_CLIST_ADDMAINMENUITEM,0,DWORD(@menuItem));

  //create menu item in main menu for empty system history
  menuitem.Position:=500060002;
  menuitem.pszName:=PChar(MenuHandles[miSysEmpty].Name);
  menuitem.pszService := MS_HPP_EMPTYHISTORY;
  menuitem.hIcon := hppIcons[HPP_ICON_TOOL_DELETEALL].handle;
  MenuHandles[miSysEmpty].Handle := PluginLink.CallService(MS_CLIST_ADDMAINMENUITEM,0,DWORD(@menuItem));

  LoadGridOptions;

  HookSettingsChanged := PluginLink.HookEvent(ME_DB_CONTACT_SETTINGCHANGED,OnSettingsChanged);
  HookIconChanged := PluginLink.HookEvent(ME_SKIN_ICONSCHANGED,OnIconChanged);
  HookContactDelete := PluginLink.HookEvent(ME_DB_CONTACT_DELETED,OnContactDelete);
  HookBuildMenu := PluginLink.HookEvent(ME_CLIST_PREBUILDCONTACTMENU,OnBuildContactMenu);

  HookEventAdded := PluginLink.HookEvent(ME_DB_EVENT_ADDED,OnEventAdded);
  HookEventDeleted := PluginLink.HookEvent(ME_DB_EVENT_DELETED,OnEventDeleted);
  HookPreshutdown := PluginLink.HookEvent(ME_SYSTEM_PRESHUTDOWN,OnPreshutdown);

  if SmileyAddEnabled then
    HookSmAddChanged := PluginLink.HookEvent(ME_SMILEYADD_OPTIONSCHANGED,OnSmAddSettingsChanged);
  if IcoLibEnabled then
    HookIcon2Changed := PluginLink.HookEvent(ME_SKIN2_ICONSCHANGED,OnIcon2Changed);
  if FontServiceEnabled then
    HookFSChanged := PluginLink.HookEvent(ME_FONT_RELOAD,OnFSChanged);
  if MetaContactsEnabled then
    HookMetaDefaultChanged := PluginLink.HookEvent(ME_MC_DEFAULTTCHANGED,OnMetaDefaultChanged);

  // Register in updater
  if Boolean(PluginLink.ServiceExists(MS_UPDATE_REGISTER)) then begin
    ZeroMemory(@upd,SizeOf(upd));
    upd.cbSize := SizeOf(upd);
    upd.szComponentName := hppShortName;
    upd.pbVersion := @hppVersionStr[1];
    upd.cpbVersion := Length(hppVersionStr);
    // file listing section
    //upd.szUpdateURL = UPDATER_AUTOREGISTER;
    upd.szUpdateURL := hppFLUpdateURL;
    upd.szVersionURL := hppFLVersionURL;
    upd.pbVersionPrefix := hppFLVersionPrefix;
    upd.cpbVersionPrefix := Length(hppFLVersionPrefix);
    // alpha-beta section
    upd.szBetaUpdateURL := hppUpdateURL;
    upd.szBetaVersionURL := hppVersionURL;
    upd.pbBetaVersionPrefix := hppVersionPrefix;
    upd.cpbBetaVersionPrefix := Length(hppVersionPrefix);
    upd.szBetaChangelogURL := hppChangelogURL;
    PluginLink.CallService(MS_UPDATE_REGISTER, 0, DWORD(@upd));
  end;

  // Register in dbeditor
  PluginLink.CallService(MS_DBEDIT_REGISTERSINGLEMODULE, DWORD(PChar(hppDBName)), 0);

  // return successfully
  Result:=0;
end;

// Called when the toolbar services are available
// wParam = lParam = 0
function OnTTBLoaded(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  ttb: TTBButtonV2;
begin
  if Boolean(PluginLink.ServiceExists(MS_TTB_ADDBUTTON)) then begin
    ZeroMemory(@ttb,SizeOf(ttb));
    ttb.cbSize := SizeOf(ttb);

    ttb.hIconUp := hppIcons[HPP_ICON_GLOBALSEARCH].handle;
    ttb.hIconDn := hppIcons[HPP_ICON_GLOBALSEARCH].handle;

    ttb.pszServiceUp := MS_HPP_SHOWGLOBALSEARCH;
    ttb.pszServiceDown := MS_HPP_SHOWGLOBALSEARCH;
    ttb.dwFlags := TTBBF_VISIBLE or TTBBF_SHOWTOOLTIP;
    ttb.name := PChar(Translate('Global History Search'));
    ttb.tooltipUp := ttb.name;
    ttb.tooltipDn := ttb.name;
    PluginLink.CallService(MS_TTB_ADDBUTTON,integer(@ttb), 0);
    PluginLink.UnhookEvent(HookTTBLoaded);
  end;
  Result := 0;
end;

// Called when setting in DB have changed
// wParam = hContact, lParam = PDbContactWriteSetting
function OnSettingsChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  cws: PDBContactWriteSetting;
  szProto: PChar;
begin
  Result := 0;
  //Log('OnSettChanged','Started. wParam: '+IntToStr(wParam)+', lParam: '+IntToStr(lParam));
  cws := PDBContactWriteSetting(lParam);

  if wParam = 0 then begin
    // check for own nick changed
    if (StrPos('Nick,yahoo_id',cws.szSetting) <> nil) then begin
      NotifyAllForms(HM_NOTF_NICKCHANGED,0,0)
    end else
    // check for history++ setings changed
    if StrComp(cws.szModule,hppDBName) = 0 then begin
      if GridOptions.Locked then exit;
      if StrComp(cws.szSetting,'FormatCopy',) = 0 then
        GridOptions.ClipCopyFormat := GetDBWideStr(hppDBName,'FormatCopy',DEFFORMAT_CLIPCOPY)
      else
      if StrComp(cws.szSetting,'FormatCopyText') = 0 then
        GridOptions.ClipCopyTextFormat := GetDBWideStr(hppDBName,'FormatCopyText',DEFFORMAT_CLIPCOPYTEXT)
      else
      if StrComp(cws.szSetting,'FormatReplyQuoted') = 0 then
        GridOptions.ReplyQuotedFormat := GetDBWideStr(hppDBName,'FormatReplyQuoted',DEFFORMAT_REPLYQUOTED)
      else
      if StrComp(cws.szSetting,'FormatReplyQuotedText') = 0 then
        GridOptions.ReplyQuotedTextFormat := GetDBWideStr(hppDBName,'FormatReplyQuotedText',DEFFORMAT_REPLYQUOTEDTEXT)
      else
      if StrComp(cws.szSetting,'FormatSelection') = 0 then
        GridOptions.SelectionFormat := GetDBWideStr(hppDBName,'FormatSelection',DEFFORMAT_SELECTION)
      else
      if StrComp(cws.szSetting,'ProfileName') = 0 then
        GridOptions.ProfileName := GetDBWideStr(hppDBName,'ProfileName','')
      else
      if StrComp(cws.szSetting,'DateTimeFormat') = 0 then
        GridOptions.DateTimeFormat := GetDBStr(hppDBName,'DateTimeFormat',DEFFORMAT_DATETIME);
    end;
    exit;
  end;

  szProto := PChar(CallService(MS_PROTO_GETCONTACTBASEPROTO,wParam,0));
  if (StrComp(cws.szModule,'CList') <> 0) and
     ((szProto = nil) or (StrComp(cws.szModule,szProto) <> 0)) then exit;

  if MetaContactsEnabled and
    (StrComp(cws.szModule,PChar(MetaContactsProto)) = 0) and
    (StrComp(cws.szSetting,'Nick') = 0) then exit;

  // check for contact nick changed
  if (StrPos('MyHandle,Nick',cws.szSetting) <> nil) then
    NotifyAllForms(HM_NOTF_NICKCHANGED,wParam,0);
end;

// Called when smilayadd settings have changed
//wParam = Contact handle which options have changed, NULL if global options changed
//lParam = (LPARAM) 0; not used
function OnSmAddSettingsChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  if GridOptions.Locked then exit;
  LoadGridOptions;
end;

// Called when setting in FontService have changed
// wParam = 0, lParam = 0
function OnFSChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  if GridOptions.Locked then exit;
  LoadGridOptions;
end;

// Called when setting in DB have changed
// wParam = hContact, lParam = PDbContactWriteSetting
function OnContactChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  if GridOptions.Locked then exit;
  LoadGridOptions;
end;

// Called when contact is deleted
// wParam - hContact
function OnContactDelete(wParam: wParam; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  NotifyAllForms(HM_MIEV_CONTACTDELETED,wParam,lParam);
end;

function OnOptInit(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  odp: TOPTIONSDIALOGPAGE;
begin
  ZeroMemory(@odp,SizeOf(odp));
  odp.cbSize := sizeof(odp);
  odp.Position := 0;
  odp.hInstance := hInstance;
  odp.pszTemplate := MakeIntResource(IDD_OPT_HISTORYPP);
  odp.pszTitle.a := Translate('History');
  odp.pszGroup.a := nil;
  odp.pfnDlgProc := @OptDialogProc;
  odp.flags := ODPF_BOLDGROUPS;
  PluginLink.CallService(MS_OPT_ADDPAGE,wParam,DWORD(@odp));
  Result:=0;
end;

//sent when the icons DLL has been changed in the options dialog, and everyone
//should re-make their image lists
//wParam=lParam=0
function OnIconChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  if not GridOptions.ShowIcons then exit;
  LoadIcons;
  NotifyAllForms(HM_NOTF_ICONSCHANGED,0,0);
end;

function OnIcon2Changed(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  menuitem: TCLISTMENUITEM;
begin
  Result := 0;
  LoadIcons2;
  NotifyAllForms(HM_NOTF_ICONS2CHANGED,0,0);
  //change menu icons
  ZeroMemory(@menuitem,SizeOf(menuItem));
  menuitem.cbSize := SizeOf(menuItem);
  menuitem.flags := CMIM_ICON;
  menuitem.hIcon := hppIcons[HPP_ICON_CONTACTHISTORY].handle;
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[miContact].Handle, DWORD(@menuItem));
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[miSystem].Handle, DWORD(@menuItem));
  menuitem.hIcon := hppIcons[HPP_ICON_GLOBALSEARCH].handle;
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[miSearch].Handle, DWORD(@menuItem));
  menuitem.hIcon := hppIcons[HPP_ICON_TOOL_DELETEALL].handle;
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[miEmpty].Handle, DWORD(@menuItem));
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[miSysEmpty].Handle, DWORD(@menuItem));
end;

//the context menu for a contact is about to be built     v0.1.0.1+
//wParam=(WPARAM)(HANDLE)hContact
//lParam=0
//modules should use this to change menu items that are specific to the
//contact that has them
function OnBuildContactMenu(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  menuItem: TCLISTMENUITEM;
  count: Integer;
  res: Integer;
begin
  Result := 0;
  count := PluginLink.CallService(MS_DB_EVENT_GETCOUNT,THandle(wParam),0);
  if (PrevShowHistoryCount xor ShowHistoryCount)
  or (count <> MenuCount) then begin
    ZeroMemory(@menuitem,SizeOf(menuItem));
    menuitem.cbSize := SizeOf(menuItem);
    menuitem.flags := CMIM_FLAGS;
    if count = 0 then menuitem.flags := menuitem.flags or CMIF_HIDDEN;
    PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[miEmpty].Handle, DWORD(@menuItem));
    if ShowHistoryCount then begin
      menuitem.flags := menuitem.flags or CMIM_NAME;
      menuitem.pszName := PChar(Format('%s [%u]',[MenuHandles[miContact].Name,count]));
    end else
    if PrevShowHistoryCount then begin
      menuitem.flags := menuitem.flags or CMIM_NAME;
      menuitem.pszName := PChar(MenuHandles[miContact].Name);
    end;
    res := PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[miContact].Handle, DWORD(@menuItem));
    if res = 0 then MenuCount := count;
    PrevShowHistoryCount := ShowHistoryCount;
  end;
end;

//wParam : HCONTACT
//lParam : HDBCONTACT
//Called when a new event has been added to the event chain
//for a contact, HCONTACT contains the contact who added the event,
//HDBCONTACT a handle to what was added.
function OnEventAdded(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  NotifyAllForms(HM_MIEV_EVENTADDED,wParam,lParam);
end;

//wParam : HCONTACT
//lParam : HDBEVENT
//Affect : Called when an event is about to be deleted from the event chain
//for a contact, see notes
function OnEventDeleted(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  NotifyAllForms(HM_MIEV_EVENTDELETED,wParam,lParam);
end;

//wParam : hMetaContact
//lParam : hDefaultContact
//Affect : Called when a metacontact's default contact changes
function OnMetaDefaultChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  NotifyAllForms(HM_MIEV_METADEFCHANGED,wParam,lParam);
end;

//wParam=0
//lParam=0
//This hook is fired just before the thread unwind stack is used,
//it allows MT plugins to shutdown threads if they have any special
//processing to do, etc.
function OnPreshutdown(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  NotifyAllForms(HM_MIEV_PRESHUTDOWN,0,0);
end;

exports
  MirandaPluginInfo,
  MirandaPluginInfoEx,
  MirandaPluginInterfaces,
  Load,
  Unload;

begin

  // filling used plugin structures
  PluginInfo.flags    := UnicodeFlag[hppOSUnicode];
  PluginInfoEx.flags  := UnicodeFlag[hppOSUnicode];

  // decreasing ref count to oleaut32.dll as said
  // in plugins doc
  FreeLibrary(GetModuleHandle('oleaut32.dll'));
  // to use RTL on LTR systems
  SysLocale.MiddleEast := true;

  TntSystem.InstallTntSystemUpdates;
  // shadow is back again...
  Forms.HintWindowClass := THppHintWindow;

  {$IFDEF REPORT_LEAKS}
  // TThemeServices leaks on exit, looks like it's ok
  // to leave it leaking, just ignore the leak report
  RegisterExpectedMemoryLeak(ThemeServices);
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

end.
