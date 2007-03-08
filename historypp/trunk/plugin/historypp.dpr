library historypp;

(*

History++ Plugin
Version 1.5.0 (build #79 at 2004-08-24 10:32:21)
by Art Fedorov
for Miranda IM
written with Delphi 5 Pro
(based on source code of History+ by Christian Kastner)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*)

{%ToDo 'historypp.todo'}
{$R 'hpp_resource.res' 'hpp_resource.rc'}
{$R 'hpp_res_ver.res' 'hpp_res_ver.rc'}
{$R 'hpp_opt_dialog.res' 'hpp_opt_dialog.rc'}

{$I compilers.inc}

uses
  {$IFDEF REPORT_LEAKS}
  {$IFNDEF DELPHI_10_UP}
  FastMM4,
  {$ENDIF}
  {$ENDIF}
  {$IFDEF EUREKALOG}
  ExceptionLog,
  {$ENDIF}
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
  hpp_richedit_ole in 'hpp_richedit_ole.pas';

type
  TMenuHandles = record
    Handle: THandle;
    Count: integer;
    Name: String;
  end;

const
  MenuHandles: array[0..2] of TMenuHandles = (
    (Handle:0; Count:-1; Name:'View &History'),
    (Handle:0; Count:-1; Name:'&System History'),
    (Handle:0; Count:-1; Name:'His&tory Search'));

var
  Interfaces: array[0..1] of TMUUID;
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
  HookPreshutdown: THandle;

function OnModulesLoad(wParam,lParam:DWord):integer; cdecl; forward;
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
function OnPreshutdown(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;

//Tell Miranda about this plugin
function MirandaPluginInfo(mirandaVersion:DWord):PPLUGININFO; cdecl;
begin
  PluginInfo.cbSize := sizeof(TPLUGININFO);
  PluginInfo.shortName := hppShortHame{$IFDEF ALPHA}+' [alpha '+{$I 'alpha.inc'}+']'{$ENDIF};
  PluginInfo.version := hppVersion;
  PluginInfo.description := 'Easy, fast and feature complete history viewer.';
  PluginInfo.author := 'theMIROn, Art Fedorov';
  PluginInfo.authorEmail := 'themiron@mail.ru, artemf@mail.ru';
  PluginInfo.copyright := '© 2006-2007 theMIROn, 2003-2006 Art Fedorov. History+ parts © 2001 Christian Kastner';
  PluginInfo.homepage := hppHomePageURL;
  PluginInfo.flags := 0{UNICODE_AWARE};
  PluginInfo.replacesDefaultModule := DEFMOD_UIHISTORY;
  Result := @PluginInfo;
end;

//Tell Miranda about this plugin ExVersion
function MirandaPluginInfoEx(mirandaVersion:DWord):PPLUGININFOEX; cdecl;
begin
  PluginInfoEx.cbSize := sizeof(TPLUGININFOEX);
  PluginInfoEx.shortName := hppShortHame{$IFDEF ALPHA}+' [alpha '+{$I 'alpha.inc'}+']'{$ENDIF};
  PluginInfoEx.version := hppVersion;
  PluginInfoEx.description := 'Easy, fast and feature complete history viewer.';
  PluginInfoEx.author := 'theMIROn, Art Fedorov';
  PluginInfoEx.authorEmail := 'themiron@mail.ru, artemf@mail.ru';
  PluginInfoEx.copyright := '© 2006-2007 theMIROn, 2003-2006 Art Fedorov. History+ parts © 2001 Christian Kastner';
  PluginInfoEx.homepage := hppHomePageURL;
  PluginInfoEx.flags := 0{UNICODE_AWARE};
  PluginInfoEx.replacesDefaultModule := DEFMOD_UIHISTORY;
  PluginInfoEx.uuid.guid := hppMUUID.guid;
  Result := @PluginInfoEx;
end;

// tell Miranda about supported interfaces
function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  Interfaces[0] := hppMUUID;
  Interfaces[1] := MIID_LAST;
  Result := @Interfaces;
end;

//load function called by miranda
function Load(link:PPLUGINLINK):Integer; cdecl;
var
  pszVersion: array[0..55] of Char;
begin
  PluginLink := Pointer(link);
  // Checking if core is unicode
  PluginLink.CallService(MS_SYSTEM_GETVERSIONTEXT,SizeOf(pszVersion),integer(@pszVersion));
  hppCoreUnicode := StrPos(pszVersion,'Unicode') <> nil;
  // Getting langpack codepage for ansi translation
  hppCodepage := PluginLink.CallService(MS_LANGPACK_GETCODEPAGE,0,0);
  if (hppCodepage = CALLSERVICE_NOTFOUND) or
     (hppCodepage = CP_ACP) then hppCodepage := GetACP();
  // Checking if richedit 2.0 or 3.0 availible
  if not IsRichEdit20Available and (IDYES <>
    // single line to translation script
    hppMessagebox(0,
      TranslateWideW('History++ module could not be loaded, riched20.dll is missing. Press Yes to continue loading Miranda.'),
      TranslateWideW('Information'), MB_YESNO or MB_ICONINFORMATION)) then begin
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
  hppRegisterMessagesCatcher;
  Result := 0;
end;

//unload
function Unload:Integer; cdecl;
begin
  // why unload is never called????
  Result:=0;
end;

//init plugin
function OnModulesLoad(wParam{0},lParam{0}:DWord):integer; cdecl;
var
  i: integer;
  menuitem:TCLISTMENUITEM;
  upd: TUpdate;
begin

  // register
  hppRegisterGridOptions;

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

  //create menu item in contact menu
  menuitem.cbSize := SizeOf(menuItem);
  menuitem.Position := 1000090000;
  menuitem.flags := 0;
  menuitem.pszName := PChar(MenuHandles[0].Name);
  menuitem.pszService := MS_HISTORY_SHOWCONTACTHISTORY;
  //menuitem.hIcon := HistoryIcon;
  menuitem.hIcon := hppIcons[HPP_ICON_CONTACTHISTORY].handle;
  menuitem.pszContactOwner := nil;    //all contacts
  MenuHandles[0].Handle := PluginLink.CallService(MS_CLIST_ADDCONTACTMENUITEM,0,DWord(@menuItem));
  MenuHandles[0].Count := -1;
  //create menu item in main menu for system history
  menuitem.Position:=500060000;
  menuitem.pszName:=PChar(MenuHandles[1].Name);
  MenuHandles[1].Handle := PluginLink.CallService(MS_CLIST_ADDMAINMENUITEM,0,DWord(@menuitem));
  MenuHandles[1].Count := -1;
  //create menu item in main menu for history search
  menuitem.Position:=500060001;
  menuitem.pszService := MS_HPP_SHOWGLOBALSEARCH;
  //menuitem.hIcon := GlobalSearchIcon;
  menuitem.hIcon := hppIcons[HPP_ICON_GLOBALSEARCH].handle;
  menuitem.pszName:=PChar(MenuHandles[2].Name);
  MenuHandles[2].Handle := PluginLink.CallService(MS_CLIST_ADDMAINMENUITEM,0,DWord(@menuItem));
  MenuHandles[2].Count := -1;

  //Register in updater
  ZeroMemory(@upd,SizeOf(upd));
  upd.cpbVersion := SizeOf(upd);
  upd.szComponentName := hppShortHame;
  upd.pbVersion := @hppVersionStr[1];
  upd.cpbVersion := Length(hppVersionStr);

  upd.szUpdateURL := hppFLUpdateURL;
  upd.szVersionURL := hppFLVersionURL;
  upd.pbVersionPrefix := hppFLVersionPrefix;
  upd.cpbVersionPrefix := Length(hppFLVersionPrefix);

  upd.szBetaUpdateURL := hppUpdateURL;
  upd.szBetaVersionURL := hppVersionURL;
  upd.pbBetaVersionPrefix := hppVersionPrefix;
  upd.cpbBetaVersionPrefix := Length(hppVersionPrefix);

  upd.szBetaChangelogURL := hppChangelogURL;

  PluginLink.CallService(MS_UPDATE_REGISTER, 0, integer(@upd));

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
begin
  Result := 0;
  //Log('OnSettChanged','Started. wParam: '+IntToStr(wParam)+', lParam: '+IntToStr(lParam));
  if wParam <> 0 then exit;
  if GridOptions.Locked then exit;
  if PDBContactWriteSetting(lParam).szModule <> hppDBName then exit;
  // place our db settings reading here
  //
  if (PDBContactWriteSetting(lParam).szSetting = 'FormatCopy') then
    GridOptions.ClipCopyFormat := GetDBWideStr(hppDBName,'FormatCopy',DEFFORMAT_CLIPCOPY)
  else
  if (PDBContactWriteSetting(lParam).szSetting = 'FormatCopyText') then
    GridOptions.ClipCopyTextFormat := GetDBWideStr(hppDBName,'FormatCopyText',DEFFORMAT_CLIPCOPYTEXT)
  else
  if (PDBContactWriteSetting(lParam).szSetting = 'FormatReplyQuoted') then
    GridOptions.ReplyQuotedFormat := GetDBWideStr(hppDBName,'FormatReplyQuoted',DEFFORMAT_REPLYQUOTED)
  else
  if (PDBContactWriteSetting(lParam).szSetting = 'FormatReplyQuotedText') then
    GridOptions.ReplyQuotedTextFormat := GetDBWideStr(hppDBName,'FormatReplyQuotedText',DEFFORMAT_REPLYQUOTED)
  else
  if (PDBContactWriteSetting(lParam).szSetting = 'FormatSelection') then
    GridOptions.SelectionFormat := GetDBWideStr(hppDBName,'FormatSelection',DEFFORMAT_SELECTION)
  else
  if (PDBContactWriteSetting(lParam).szSetting = 'ProfileName') then
    GridOptions.ProfileName := GetDBWideStr(hppDBName,'ProfileName','')
  else
  if (PDBContactWriteSetting(lParam).szSetting = 'DateTimeFormat') then
    GridOptions.DateTimeFormat := GetDBStr(hppDBName,'DateTimeFormat',DEFFORMAT_DATETIME)
  else
  if (PDBContactWriteSetting(lParam).szSetting = 'ShowHistoryCount') then
    ShowHistoryCount := GetDBBool(hppDBName,'ShowHistoryCount',false);
  //LoadDefaultGridOptions;
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
  odp: TOptionsDialogPage;
begin
  ZeroMemory(@odp,sizeof(odp));
  odp.cbSize := sizeof(odp);
  odp.Position := 0;
  odp.hInstance := hInstance;
  odp.pszTemplate := MakeIntResource(IDD_OPT_HISTORYPP);
  //odp.pszTitle := Translate(hppName{TRANSLATE-IGNORE});
  //odp.pszGroup := Translate('History');
  odp.pszTitle := Translate('History');
  odp.pszGroup := nil;
  odp.pfnDlgProc := @OptDialogProc;
  odp.flags := ODPF_BOLDGROUPS;
  PluginLink.CallService(MS_OPT_ADDPAGE,wParam,dword(@odp));
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
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[0].Handle, DWord(@menuItem));
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[1].Handle, DWord(@menuItem));
  menuitem.hIcon := hppIcons[HPP_ICON_GLOBALSEARCH].handle;
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[2].Handle, DWord(@menuItem));
end;

//the context menu for a contact is about to be built     v0.1.0.1+
//wParam=(WPARAM)(HANDLE)hContact
//lParam=0
//modules should use this to change menu items that are specific to the
//contact that has them
function OnBuildContactMenu(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  menuitem: TCLISTMENUITEM;
  count: integer;
begin
  Result := 0;
  count := PluginLink.CallService(MS_DB_EVENT_GETCOUNT,THandle(wParam),0);
  if count <> MenuHandles[0].Count then begin
    ZeroMemory(@menuitem,SizeOf(menuItem));
    menuitem.cbSize := SizeOf(menuItem);
    menuitem.flags := CMIM_FLAGS;
    if count = 0 then menuitem.flags := menuitem.flags or CMIF_GRAYED;
    if ShowHistoryCount then begin
      menuitem.flags := menuitem.flags or CMIM_NAME;
      menuitem.pszName := PChar(Format('%s [%u]',[MenuHandles[0].Name,count]))
    end;
    if PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[0].Handle, DWord(@menuItem)) = 0 then
      MenuHandles[0].Count := count;
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

//wParam=0
//lParam=0
//This hook is fired just before the thread unwind stack is used,
//it allows MT plugins to shutdown threads if they have any special
//processing to do, etc.
function OnPreshutdown(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  try
    NotifyAllForms(HM_MIEV_PRESHUTDOWN,0,0);
    // unhook events
    PluginLink.UnhookEvent(HookEventAdded);
    PluginLink.UnhookEvent(HookEventDeleted);
    PluginLink.UnhookEvent(HookPreshutdown);
    PluginLink.UnhookEvent(HookModulesLoad);
    PluginLink.UnhookEvent(hookOptInit);
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

    // destroy messages chatcher
    hppUnregisterMessagesCatcher;
    // unregistering events
    hppUnregisterServices;
    {$IFNDEF NO_EXTERNALGRID}
    UnregisterExtGridServices;
    {$ENDIF}
    // unregister bookmarks
    hppDeinitBookmarkServer;

  except
    on E: Exception do
      HppMessageBox(0,'Error while closing '+hppName+':'+#10#13+E.Message,hppName+' Error',MB_OK or MB_ICONERROR);
  end;
end;

exports
  MirandaPluginInfo,
  MirandaPluginInfoEx,
  MirandaPluginInterfaces,
  Load,
  Unload;

begin
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
