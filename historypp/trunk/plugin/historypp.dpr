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

uses
  {$IFDEF EUREKALOG}
  ExceptionLog,
  {$ENDIF}
  Windows,
  SysUtils,
  Graphics,
  Classes,
  {$IFDEF REPORT_LEAKS} Themes, {$ENDIF}
  m_globaldefs,
  m_api,
  tntSystem,
  Forms,
  TntControls,
  CommCtrl,
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
  hpp_strparser in 'hpp_strparser.pas';

var
  hookModulesLoad,
  //hookOptInit,
  hookSettingsChanged,
  hookIconChanged,
  HookIcon2Changed,
  //hookContactChanged,
  hookContactDelete,
  hookFSChanged: THandle;
  //HistoryIcon, GlobalSearchIcon: HIcon;
  MenuHandles: array[0..2] of THandle;

function OnModulesLoad(wParam,lParam:DWord):integer;cdecl; forward;
function OnSettingsChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnIconChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnIcon2Changed(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
//function OnOptInit(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
function OnContactChanged(wParam: wParam; lParam: LPARAM): Integer; cdecl; forward;
function OnContactDelete(wParam: wParam; lParam: LPARAM): Integer; cdecl; forward;
function OnFSChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;

//Tell Miranda about this plugin
function MirandaPluginInfo(mirandaVersion:DWord):PPLUGININFO;cdecl;
begin
  PluginInfo.cbSize := sizeof(TPLUGININFO);
  PluginInfo.shortName := hppName + ' (2in1)';
  PluginInfo.version := hppVersion;
  PluginInfo.description := 'Easy, fast and feature complete history viewer';
  PluginInfo.author := 'theMIROn, Art Fedorov';
  PluginInfo.authorEmail := 'themiron@mail.ru, artemf@mail.ru';
  PluginInfo.copyright := '© 2006 theMIROn, 2003-2004 Art Fedorov. History+ parts © 2001 Christian Kastner';
  PluginInfo.homepage := hppHomePageURL;
  PluginInfo.isTransient := 0;
  PluginInfo.replacesDefaultModule := DEFMOD_UIHISTORY;
  Result := @PluginInfo;
end;

//load function called by miranda
function Load(link:PPLUGINLINK):Integer;cdecl;
begin
  PluginLink := Pointer(link);
  //init history functions later
  HookModulesLoad := PluginLink.HookEvent(ME_SYSTEM_MODULESLOADED,OnModulesLoad);
  hppRegisterServices;
  //hppRegisterItemProcessSamples;
  InitMMI;
  //HistoryIcon := LoadIcon(hInstance,hppIcons[0].name);
  //GlobalSearchIcon := LoadIcon(hInstance,hppIcons[1].name);
  Result:=0;
end;

//unload
function Unload:Integer;cdecl;
begin
  // unregistering events
  hppUnregisterServices;
  //hppUnregisterItemProcessSamples;
  // unhook events
  PluginLink.UnhookEvent(HookModulesLoad);
  PluginLink.UnhookEvent(HookSettingsChanged);
  PluginLink.UnhookEvent(HookIconChanged);
  PluginLink.UnhookEvent(HookIcon2Changed);
  //PluginLink.UnhookEvent(HookContactChanged);
  PluginLink.UnhookEvent(HookContactDelete);
  PluginLink.UnhookEvent(HookFSChanged);
  // delete icons
  //DeleteObject(HistoryIcon);
  //DeleteObject(GlobalSearchIcon);
  // return successfully
  Result:=0;
end;

//init plugin
function OnModulesLoad(wParam{0},lParam{0}:DWord):integer;cdecl;
var
  menuitem:TCLISTMENUITEM;
  pszVersion: array[0..55] of Char;
  upd: TUpdate;
begin
  hppRegisterGridOptions;

  LoadIcons;
  LoadIcons2;

  ZeroMemory(@menuitem,SizeOf(menuItem));
  // Checking if core is unicode
  PluginLink.CallService(MS_SYSTEM_GETVERSIONTEXT,SizeOf(pszVersion),integer(@pszVersion));
  hppCoreUnicode := StrPos(pszVersion,'Unicode') <> nil;

  // Getting langpack codepage for ansi translation
  hppCodepage := PluginLink.CallService(MS_LANGPACK_GETCODEPAGE,0,0);
  if hppCodepage = CALLSERVICE_NOTFOUND then hppCodepage := CP_ACP;

  //create menu item in contact menu
  menuitem.cbSize := SizeOf(menuItem);
  menuitem.Position := 1000090000;
  menuitem.flags := 0;
  menuitem.pszName := PChar(translate('View &History'));
  menuitem.pszService := MS_HISTORY_SHOWCONTACTHISTORY;
  //menuitem.hIcon := HistoryIcon;
  menuitem.hIcon := hppIcons[HPP_ICON_CONTACTHISTORY].handle;
  menuitem.pszContactOwner := nil;    //all contacts
  MenuHandles[0] := PluginLink.CallService(MS_CLIST_ADDCONTACTMENUITEM,0,DWord(@menuItem));
  //create menu item in main menu for system history
  menuitem.Position:=500060000;
  menuitem.pszName:=PChar(translate('&System History'));
  MenuHandles[1] := PluginLink.CallService(MS_CLIST_ADDMAINMENUITEM,0,DWord(@menuitem));
  //create menu item in main menu for history search
  menuitem.Position:=500060001;
  menuitem.pszService := MS_HPP_SHOWGLOBALSEARCH;
  //menuitem.hIcon := GlobalSearchIcon;
  menuitem.hIcon := hppIcons[HPP_ICON_GLOBALSEARCH].handle;
  menuitem.pszName:=PChar(translate('His&tory Search'));
  MenuHandles[2] := PluginLink.CallService(MS_CLIST_ADDMAINMENUITEM,0,DWord(@menuItem));

  //Register in updater
  ZeroMemory(@upd,SizeOf(upd));
  upd.cpbVersion := SizeOf(upd);
  upd.szComponentName := PluginInfo.shortName;
  upd.pbVersion := @hppVersionStr[1];
  upd.cpbVersion := Length(hppVersionStr);
  //upd.szUpdateURL := hppUpdateURL;
  upd.szBetaUpdateURL := hppUpdateURL;
  //upd.szVersionURL := hppVersionURL;
  upd.szBetaVersionURL := hppVersionURL;
  //upd.pbVersionPrefix := @hppVersionPrefix[1];
  upd.pbBetaVersionPrefix := @hppVersionPrefix[1];
  //upd.cpbVersionPrefix := Length(hppVersionPrefix);
  upd.cpbBetaVersionPrefix := Length(hppVersionPrefix);
  PluginLink.CallService(MS_UPDATE_REGISTER, 0, integer(@upd));

  LoadGridOptions;

  HookSettingsChanged := PluginLink.HookEvent(ME_DB_CONTACT_SETTINGCHANGED,OnSettingsChanged);
  HookIconChanged := PluginLink.HookEvent(ME_SKIN_ICONSCHANGED,OnIconChanged);
  HookIcon2Changed := PluginLink.HookEvent(ME_SKIN2_ICONSCHANGED,OnIcon2Changed);
  //HookContactChanged := PluginLink.HookEvent(ME_DB_CONTACT_DELETED,OnContactChanged);
  HookContactDelete := PluginLink.HookEvent(ME_DB_CONTACT_DELETED,OnContactDelete);
  HookFSChanged := PluginLink.HookEvent(ME_FONT_RELOAD,OnFSChanged);
  // return successfully
  Result:=0;
end;

// Called when setting in DB have changed
// wParam = hContact, lParam = PDbContactWriteSetting
function OnSettingsChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  //Log('OnSettChanged','Started. wParam: '+IntToStr(wParam)+', lParam: '+IntToStr(lParam));
  if wParam <> 0 then exit;
  if GridOptions.Locked then exit;
  if (PDBContactWriteSetting(lParam).szModule <> 'HistoryPlusPlus') and
    (PDBContactWriteSetting(lParam).szModule <> 'SRMsg') then exit;
  //LoadDefaultGridOptions;
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
var
  i: Integer;
  w: THistoryFrm;
begin
  w := nil;
  for i:=0 to HstWindowList.Count-1 do
    if THistoryFrm(HstWindowList[i]).hcontact=wParam then
      w := THistoryFrm(HstWindowList[i]);
  try
    if Assigned(w) then w.Close;
  except
  end;
  Result := 0;
end;

{function OnOptInit(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  odp:tOPTIONSDIALOGPAGE;
  fmOpt: TfmOptions;
  WndProc: Pointer;
begin
  fmOpt := TfmOptions.Create(nil);
  TfmOptions(fmOpt).DateGrid.ProfileName := 'Self';
  TfmOptions(fmOpt).Load;
  fmOpt.Show;
  ZeroMemory(@odp,sizeof(odp));
  odp.cbSize:=sizeof(odp);
  odp.Position:=900003000;
  odp.hInstance:=hInstance;
  odp.pszTemplate:=pchar(101);
  odp.pszTitle:=Translate(PChar('History++'));
  odp.pszGroup:=Translate(PChar('Plugins'));
  odp.pfnDlgProc:=Pointer(GetWindowLong(fmOpt.Handle,GWL_WNDPROC));
  PluginLink.CallService(MS_OPT_ADDPAGE,wParam,dword(@odp));
  Result:=0;
end;}

function OnIconChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  if not GridOptions.ShowIcons then exit;
  LoadIcons;
end;

function OnIcon2Changed(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  menuitem: TCLISTMENUITEM;
  i: Integer;
begin
  Result := 0;
  LoadIcons2;
  if Assigned(fmGlobalSearch) then begin
    fmGlobalSearch.Icon.Handle := CopyIcon(hppIcons[HPP_ICON_GLOBALSEARCH].handle);
    fmGlobalSearch.pbFilter.Repaint;
    if GlobalSearchAllResultsIcon <> -1 then begin
      fmGlobalSearch.lvContacts.Items.BeginUpdate;
      ImageList_ReplaceIcon(fmGlobalSearch.ilContacts.Handle,
        GlobalSearchAllResultsIcon,hppIcons[HPP_ICON_SEARCH_ALLRESULTS].Handle);
      fmGlobalSearch.lvContacts.Items.EndUpdate;
    end;
  end;
  for i:=0 to HstWindowList.Count-1 do begin
    THistoryFrm(HstWindowList[i]).Icon.Handle := CopyIcon(hppIcons[HPP_ICON_CONTACTHISTORY].handle);
    THistoryFrm(HstWindowList[i]).LoadSessionIcons;
  end;
  //change menu icons
  ZeroMemory(@menuitem,SizeOf(menuItem));
  menuitem.cbSize := SizeOf(menuItem);
  menuitem.flags := CMIM_ICON;
  menuitem.hIcon := hppIcons[HPP_ICON_CONTACTHISTORY].handle;
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[0], DWord(@menuItem));
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[1], DWord(@menuItem));
  menuitem.hIcon := hppIcons[HPP_ICON_GLOBALSEARCH].handle;
  PluginLink.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandles[2], DWord(@menuItem));
end;

exports
  MirandaPluginInfo,
  Load,
  Unload;

begin
  // decreasing ref count to oleaut32.dll as said
  // in plugins doc
  FreeLibrary(GetModuleHandle('oleaut32.dll'));

  TntSystem.InstallTntSystemUpdates;
  Forms.HintWindowClass := TntControls.TTntHintWindow;

  {$IFDEF REPORT_LEAKS}
  // TThemeServices leaks on exit, looks like it's ok
  // to leave it leaking, just ignore the leak report
  RegisterExpectedMemoryLeak(ThemeServices);
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
end.
