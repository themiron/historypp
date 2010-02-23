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

unit hpp_opt_dialog;

interface

uses
  Windows, Messages, CommCtrl,
  m_api, m_globaldefs,
  hpp_global, hpp_options, hpp_services
  {$IFNDEF NO_EXTERNALGRID}, hpp_external{$ENDIF};

const
  IDD_OPT_HISTORYPP   = 207; // dialog id

  ID_APPEARANCE_GROUP = 100; // "Appearance options" group
  IDC_SHOWEVENTICONS  = 101; // "Show event icons" checkbox
  IDC_RTLDEFAULT      = 102; // "RTL by default" checkbox
  IDC_OPENDETAILS     = 103; // "Open event details by Enter" checkbox
  IDC_SHOWEVENTSCOUNT = 104; // "Show events count in menu" checkbox
  IDC_SHOWAVATARS     = 105; // "Show avatars" checkbox

  ID_FORMATTING_GROUP = 200; // "Text formatting options" group
  IDC_BBCODE          = 201; // "Enable BBCodes" checkbox
  IDC_SMILEY          = 202; // "Enable SmileyAdd support" checkbox
  IDC_MATH            = 203; // "Enable MathModule support" checkbox
  IDC_RAWRTF          = 204; // "Enable raw RTF support" checkbox
  IDC_AVATARSHISTORY  = 205; // "Display chanage avatars" checkbox

  ID_MESSAGELOG_GROUP = 300; // "Message log options" group
  IDC_IEVIEWAPI       = 301; // "Imitate IEView API" checkbox
  IDC_GROUPLOGITEMS   = 302; // "Group messages" checkbox
  IDC_DISABLEBORDER   = 303; // "Disable border" checkbox
  IDC_DISABLESCROLL   = 304; // "Disable scrollbar" checkbox

  ID_HISTORYVIEW_GROUP = 500;// "History view options" group
  IDC_RECENTONTOP     = 501; // "Recent events on top" checkbox
  IDC_GROUPHISTITEMS  = 502; // "Group messages" checkbox

  ID_NEEDOPTIONS_LINK = 250; // "Visit Wiki page for more options" hyperlink

  ID_LOOK_GROUP       = 400;
  ID_LOOK_FONT1       = 401; // "To change fonts ..."
  ID_LOOK_FONT2       = 402;
  ID_LOOK_FONT_ICON   = 403;
  ID_LOOK_FONT_LINK   = 410; // "Download FontService plugin"
  ID_LOOK_ICO1        = 421; // "To change icons ..."
  ID_LOOK_ICO2        = 422;
  ID_LOOK_ICO_ICON    = 423;
  ID_LOOK_ICO_LINK    = 430; // "Download IcoLib plugin"
  ID_LOOK_INFO_LINK   = 440; // "More info on why ..."

  ID_NEED_RESTART     = 999; // "Please restart Miranda IM..."

const
  URL_FONTSERVICE = 'http://addons.miranda-im.org/details.php?action=viewfile&id=2065';
  URL_ICOLIB      = 'http://addons.miranda-im.org/details.php?action=viewfile&id=2700';
  URL_EXPLAIN     = 'http://code.google.com/p/historypp/wiki/CustomizationSupport';
  URL_NEEDOPTIONS = 'http://code.google.com/p/historypp/wiki/AdditionalOptions';

function OptDialogProc(hwndDlg: HWND; uMsg: Integer;
  wParam: WPARAM; lParam: LPARAM): Integer; stdcall;

var
  hDlg: HWND = 0;
  
implementation

uses hpp_database, HistoryForm, GlobalSearch;

function GetText(idCtrl: Integer): String;
var
  dlg_text: array[0..1023] of Char;
begin
  ZeroMemory(@dlg_text,SizeOf(dlg_text));
  GetDlgItemText(hDlg,idCtrl,@dlg_text,1023);
  Result := dlg_text;
end;

procedure SetText(idCtrl: Integer; Text: String);
begin
  SetDlgItemText(hDlg,idCtrl,@Text[1]);
end;

procedure SetChecked(idCtrl: Integer; Checked: Boolean);
begin
  if Checked then
    SendDlgItemMessage(hDlg,idCtrl,BM_SETCHECK,BST_CHECKED,0) else
    SendDlgItemMessage(hDlg,idCtrl,BM_SETCHECK,BST_UNCHECKED,0);
end;

function GetChecked(idCtrl: Integer): Boolean;
begin
  Result := (SendDlgItemMessage(hDlg,idCtrl,BM_GETCHECK,0,0) = BST_CHECKED);
end;

function AreOptionsChanged: Boolean;
begin
  Result := True;

  if GetChecked(IDC_SHOWEVENTICONS) <> GridOptions.ShowIcons then exit;
  if GetChecked(IDC_RTLDEFAULT) <> GridOptions.RTLEnabled then exit;
  if GetChecked(IDC_OPENDETAILS) <> GridOptions.OpenDetailsMode then exit;
  if GetChecked(IDC_SHOWEVENTSCOUNT) <> ShowHistoryCount then exit;
  //if GetChecked(IDC_SHOWAVATARS) <> GridOptions.ShowAvatars then exit;

  if GetChecked(IDC_BBCODE) <> GridOptions.BBCodesEnabled then exit;
  if SmileyAddEnabled then
    if GetChecked(IDC_SMILEY) <> GridOptions.SmileysEnabled then exit;
  if MathModuleEnabled then
    if GetChecked(IDC_MATH) <> GridOptions.MathModuleEnabled then exit;
  if GetChecked(IDC_RAWRTF) <> GridOptions.RawRTFEnabled then exit;
  if GetChecked(IDC_AVATARSHISTORY) <> GridOptions.AvatarsHistoryEnabled then exit;

  if GetChecked(IDC_RECENTONTOP) <> GetDBBool(hppDBName,'SortOrder',false) then exit;
  if GetChecked(IDC_GROUPHISTITEMS) <> GetDBBool(hppDBName,'GroupHistoryItems',false) then exit;

  {$IFNDEF NO_EXTERNALGRID}
  if GetChecked(IDC_IEVIEWAPI) <> GetDBBool(hppDBName,'IEViewAPI',false) then exit;
  if GetChecked(IDC_GROUPLOGITEMS) <> GetDBBool(hppDBName,'GroupLogItems',false) then exit;
  if GetChecked(IDC_DISABLEBORDER) <> GetDBBool(hppDBName,'NoLogBorder',false) then exit;
  if GetChecked(IDC_DISABLESCROLL) <> GetDBBool(hppDBName,'NoLogScrollBar',false) then exit;
  {$ENDIF}

  Result := False;
end;

procedure SaveChangedOptions;
var
  ShowRestart: Boolean;
  Checked: Boolean;
  i: Integer;
begin
  ShowRestart := False;
  GridOptions.StartChange;
  try
    GridOptions.ShowIcons := GetChecked(IDC_SHOWEVENTICONS);
    GridOptions.RTLEnabled := GetChecked(IDC_RTLDEFAULT);
    GridOptions.OpenDetailsMode := GetChecked(IDC_OPENDETAILS);

    ShowHistoryCount := GetChecked(IDC_SHOWEVENTSCOUNT);
    if ShowHistoryCount <> GetDBBool(hppDBName,'ShowHistoryCount',false) then
      WriteDBBool(hppDBName,'ShowHistoryCount',ShowHistoryCount);

    //GridOptions.ShowAvatars := GetChecked(IDC_SHOWAVATARS);

    GridOptions.BBCodesEnabled := GetChecked(IDC_BBCODE);
    if SmileyAddEnabled then
      GridOptions.SmileysEnabled := GetChecked(IDC_SMILEY);
    if MathModuleEnabled then
      GridOptions.MathModuleEnabled := GetChecked(IDC_MATH);
    GridOptions.RawRTFEnabled := GetChecked(IDC_RAWRTF);
    GridOptions.AvatarsHistoryEnabled := GetChecked(IDC_AVATARSHISTORY);

    SaveGridOptions;
  finally
    GridOptions.EndChange;
  end;

  Checked := GetChecked(IDC_RECENTONTOP);
  if Checked <> GetDBBool(hppDBName,'SortOrder',false) then begin
    WriteDBBool(hppDBName,'SortOrder',Checked);
    for i := 0 to HstWindowList.Count - 1 do begin
      THistoryFrm(HstWindowList[i]).SetRecentEventsPosition(Checked);
    end;
    if Assigned(fmGlobalSearch) then
      fmGlobalSearch.SetRecentEventsPosition(Checked);
  end;

  Checked := GetChecked(IDC_GROUPHISTITEMS);
  if Checked <> GetDBBool(hppDBName,'GroupHistoryItems',false) then begin
    WriteDBBool(hppDBName,'GroupHistoryItems',Checked);
    for i := 0 to HstWindowList.Count - 1 do
      THistoryFrm(HstWindowList[i]).hg.GroupLinked := Checked;
  end;

  {$IFNDEF NO_EXTERNALGRID}
  Checked := GetChecked(IDC_IEVIEWAPI);
  if Checked <> GetDBBool(hppDBName,'IEViewAPI',false) then
    WriteDBBool(hppDBName,'IEViewAPI',Checked);
  ShowRestart := ShowRestart or (Checked <> ImitateIEView);

  Checked := GetChecked(IDC_GROUPLOGITEMS);
  if Checked <> GetDBBool(hppDBName,'GroupLogItems',false) then begin
    WriteDBBool(hppDBName,'GroupLogItems',Checked);
    ExternalGrids.GroupLinked := Checked;
  end;

  Checked := GetChecked(IDC_DISABLEBORDER);
  if Checked <> GetDBBool(hppDBName,'NoLogBorder',false) then
    WriteDBBool(hppDBName,'NoLogBorder',Checked);
  //ShowRestart := ShowRestart or (Checked <> DisableLogBorder);

  Checked := GetChecked(IDC_DISABLESCROLL);
  if Checked <> GetDBBool(hppDBName,'NoLogScrollBar',false) then
    WriteDBBool(hppDBName,'NoLogScrollBar',Checked);
  //ShowRestart := ShowRestart or (Checked <> DisableLogScrollbar);
  {$ENDIF}

  if ShowRestart then
    ShowWindow(GetDlgItem(hDlg,ID_NEED_RESTART),SW_SHOW) else
    ShowWindow(GetDlgItem(hDlg,ID_NEED_RESTART),SW_HIDE);
end;

// WM_INITDIALOG message handler
function InitDlg: Integer;
begin
  if FontServiceEnabled then
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_FONT_LINK),SW_HIDE)
  else begin
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_FONT2),SW_HIDE);
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_FONT_ICON),SW_HIDE);
  end;

  if IcoLibEnabled then
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_ICO_LINK),SW_HIDE)
  else begin
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_ICO2),SW_HIDE);
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_ICO_ICON),SW_HIDE);
  end;

  SetChecked(IDC_SHOWEVENTICONS,GridOptions.ShowIcons);
  SetChecked(IDC_RTLDEFAULT,GridOptions.RTLEnabled);
  SetChecked(IDC_OPENDETAILS,GridOptions.OpenDetailsMode);
  SetChecked(IDC_SHOWEVENTSCOUNT,ShowHistoryCount);
  //SetChecked(IDC_SHOWAVATARS,GridOptions.ShowAvatars);

  SetChecked(IDC_BBCODE,GridOptions.BBCodesEnabled);
  EnableWindow(GetDlgItem(hDlg,IDC_SMILEY),SmileyAddEnabled);
  if SmileyAddEnabled then
    SetChecked(IDC_SMILEY,GridOptions.SmileysEnabled);
  EnableWindow(GetDlgItem(hDlg,IDC_MATH),MathModuleEnabled);
  if MathModuleEnabled then
    SetChecked(IDC_MATH,GridOptions.MathModuleEnabled);
  SetChecked(IDC_RAWRTF,GridOptions.RawRTFEnabled);
  SetChecked(IDC_AVATARSHISTORY,GridOptions.AvatarsHistoryEnabled);

  SetChecked(IDC_RECENTONTOP,GetDBBool(hppDBName,'SortOrder',false));
  SetChecked(IDC_GROUPHISTITEMS,GetDBBool(hppDBName,'GroupHistoryItems',false));

  {$IFNDEF NO_EXTERNALGRID}
  SetChecked(IDC_IEVIEWAPI,GetDBBool(hppDBName,'IEViewAPI',false));
  SetChecked(IDC_GROUPLOGITEMS,GetDBBool(hppDBName,'GroupLogItems',false));
  SetChecked(IDC_DISABLEBORDER,GetDBBool(hppDBName,'NoLogBorder',false));
  SetChecked(IDC_DISABLESCROLL,GetDBBool(hppDBName,'NoLogScrollBar',false));
  {$ELSE}
  ShowWindow(GetDlgItem(hDlg,IDC_IEVIEWAPI),SW_HIDE);
  ShowWindow(GetDlgItem(hDlg,IDC_GROUPLOGITEMS),SW_HIDE);
  ShowWindow(GetDlgItem(hDlg,IDC_DISABLEBORDER),SW_HIDE);
  ShowWindow(GetDlgItem(hDlg,IDC_DISABLESCROLL),SW_HIDE);
  {$ENDIF}

  TranslateDialogDefault(hDlg);
  Result := 0;
end;

// WM_NOTIFY message handler
function NotifyDlg(idCtrl: Integer; nmhdr: TNMHDR): Integer;
begin
  Result := 0;
  if nmhdr.code <> PSN_APPLY then exit;
  Result := 1;
  // apply changes here
  SaveChangedOptions;
end;

// WM_COMMAND message handler
function CommandDlg(idCtrl: Integer; hCtrl: HWND; wNotifyCode: Integer): Integer;
begin
  Result := 1;
  case idCtrl of
    ID_LOOK_FONT_LINK: PluginLink.CallService(MS_UTILS_OPENURL,WPARAM(True),LPARAM(@URL_FONTSERVICE[1]));
    ID_LOOK_ICO_LINK: PluginLink.CallService(MS_UTILS_OPENURL,WPARAM(True),LPARAM(@URL_ICOLIB[1]));
    ID_LOOK_INFO_LINK: PluginLink.CallService(MS_UTILS_OPENURL,WPARAM(True),LPARAM(@URL_EXPLAIN[1]));
    ID_NEEDOPTIONS_LINK: PluginLink.CallService(MS_UTILS_OPENURL,WPARAM(True),LPARAM(@URL_NEEDOPTIONS[1]));
  else
    Result := 0;
  end;
  if Result = 1 then exit;
  if AreOptionsChanged then begin
    Result := 1;
    SendMessage(GetParent(hDlg),PSM_CHANGED,hDlg,0);
  end;
end;

function OptDialogProc(hwndDlg: HWND; uMsg: Integer;
  wParam: WPARAM; lParam: LPARAM): Integer;
begin
  Result := 0;
  case uMsg of
    WM_INITDIALOG: begin hDlg := hwndDlg; Result := InitDlg; end;
    WM_NOTIFY:     Result := NotifyDlg(wParam,PNMHDR(lParam)^);
    WM_COMMAND:    Result := CommandDlg(LoWord(wParam),lParam,HiWord(wParam));
    WM_DESTROY:    hDlg := 0;
  end;
end;

end.
