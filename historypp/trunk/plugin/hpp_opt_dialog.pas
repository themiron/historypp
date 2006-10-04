unit hpp_opt_dialog;

interface

uses
  Windows,
  Messages,
  commctrl,
  m_api,
  m_globaldefs,
  hpp_global, hpp_options, hpp_services, hpp_external;

const
  IDD_OPT_HISTORYPP   = 207; // dialog id
  ID_GRID_GROUP       = 100;
  IDC_SHOWEVENTICONS  = 101; // "Show event icons" checkbox
  IDC_RECENTONTOP     = 102; // "Recent events on top" checkbox
  IDC_RTLDEFAULT      = 103; // "RTL by default" checkbox
  IDC_OPENDETAILS     = 104; // "Open event details by Enter" checkbox
  IDC_IEVIEWAPI       = 105; // "Imitate IEView API" checkbox
  ID_FORMATTING_GROUP = 200;
  IDC_BBCODE          = 201; // "Enable BBCodes" checkbox
  IDC_SMILEY          = 202; // "Enable SmileyAdd support" checkbox
  IDC_MATH            = 203; // "Enable MathModule support" checkbox
  IDC_RAWRTF          = 204; // "Enable raw RTF support" checkbox
  ID_LOOK_GROUP       = 300;
  ID_LOOK_FONT1       = 301; // "To change fonts ..."
  ID_LOOK_FONT2       = 302;
  ID_LOOK_FONT_ICON   = 303;
  ID_LOOK_FONT_LINK   = 310; // "Download FontService plugin"
  ID_LOOK_ICO1        = 321; // "To change icons ..."
  ID_LOOK_ICO2        = 322;
  ID_LOOK_ICO_ICON    = 323;
  ID_LOOK_ICO_LINK    = 330; // "Download IcoLib plugin"
  ID_LOOK_INFO_LINK   = 340; // "More info on why ..."
  ID_NEED_RESTART     = 999; // "Please restart Miranda IM..."

const
  URL_FONTSERVICE = 'http://addons.miranda-im.org/details.php?action=viewfile&id=2065';
  URL_ICOLIB      = 'http://addons.miranda-im.org/details.php?action=viewfile&id=2700';
  URL_EXPLAIN     = 'https://opensvn.csie.org/traccgi/historypp/trac.cgi/wiki/CustomizationSupport';

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
    SendDlgItemMessage(hDlg,idCtrl,BM_SETCHECK,BST_CHECKED,0)
  else
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
  if GetChecked(IDC_RECENTONTOP) <> GetDBBool(hppDBName,'SortOrder',false) then exit;
  if GetChecked(IDC_RTLDEFAULT) <> GridOptions.RTLEnabled then exit;
  if GetChecked(IDC_OPENDETAILS) <> GridOptions.OpenDetailsMode then exit;
  if GetChecked(IDC_IEVIEWAPI) <> GetDBBool(hppDBName,'IEViewAPI',false) then exit;

  if GetChecked(IDC_BBCODE) <> GridOptions.BBCodesEnabled then exit;
  if SmileyAddEnabled then
    if GetChecked(IDC_SMILEY) <> GridOptions.SmileysEnabled then exit;
  if MathModuleEnabled then
    if GetChecked(IDC_MATH) <> GridOptions.MathModuleEnabled then exit;
  if GetChecked(IDC_RAWRTF) <> GridOptions.RawRTFEnabled then exit;

  Result := False;
end;

procedure SaveChangedOptions;
var
  Checked: Boolean;
  i: Integer;
begin
  GridOptions.StartChange;
  try
    GridOptions.ShowIcons := GetChecked(IDC_SHOWEVENTICONS);
    //GridOptions.RecentOnTop := GetChecked(IDC_RECENTONTOP);
    GridOptions.RTLEnabled := GetChecked(IDC_RTLDEFAULT);
    GridOptions.OpenDetailsMode := GetChecked(IDC_OPENDETAILS);

    GridOptions.BBCodesEnabled := GetChecked(IDC_BBCODE);
    if SmileyAddEnabled then
      GridOptions.SmileysEnabled := GetChecked(IDC_SMILEY);
    if MathModuleEnabled then
      GridOptions.MathModuleEnabled := GetChecked(IDC_MATH);
    GridOptions.RawRTFEnabled := GetChecked(IDC_RAWRTF);

    SaveGridOptions;
  finally
    GridOptions.EndChange;
  end;

  Checked := GetChecked(IDC_RECENTONTOP);
  if Checked <> (GetDBBool(hppDBName,'SortOrder',false) <> false) then begin
    WriteDBBool(hppDBName,'SortOrder',Checked);
    for i := 0 to HstWindowList.Count - 1 do begin
      THistoryFrm(HstWindowList[i]).SetRecentEventsPosition(Checked);
    end;
    if Assigned(fmGlobalSearch) then
      fmGlobalSearch.SetRecentEventsPosition(Checked);
  end;

  Checked := GetChecked(IDC_IEVIEWAPI);
  if Checked <> (GetDBBool(hppDBName,'IEViewAPI',false) <> false) then
    WriteDBBool(hppDBName,'IEViewAPI',Checked);
  if Checked <> ImitateIEView then
    ShowWindow(GetDlgItem(hDlg,ID_NEED_RESTART),SW_SHOW)
  else
    ShowWindow(GetDlgItem(hDlg,ID_NEED_RESTART),SW_HIDE);
end;

// WM_INITDIALOG message handler
function InitDlg: Integer;
begin
  if FontServiceEnabled then begin
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_FONT_LINK),SW_HIDE);
  end
  else begin
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_FONT2),SW_HIDE);
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_FONT_ICON),SW_HIDE);
  end;

  if IcoLibEnabled then begin
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_ICO_LINK),SW_HIDE);
  end
  else begin
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_ICO2),SW_HIDE);
    ShowWindow(GetDlgItem(hDlg,ID_LOOK_ICO_ICON),SW_HIDE);
  end;

  SetChecked(IDC_SHOWEVENTICONS,GridOptions.ShowIcons);
  SetChecked(IDC_RECENTONTOP,GetDBBool(hppDBName,'SortOrder',false));
  SetChecked(IDC_RTLDEFAULT,GridOptions.RTLEnabled);
  SetChecked(IDC_OPENDETAILS,GridOptions.OpenDetailsMode);
  SetChecked(IDC_IEVIEWAPI,GetDBBool(hppDBName,'IEViewAPI',false));

  SetChecked(IDC_BBCODE,GridOptions.BBCodesEnabled);
  EnableWindow(GetDlgItem(hDlg,IDC_SMILEY),SmileyAddEnabled);
  if SmileyAddEnabled then
    SetChecked(IDC_SMILEY,GridOptions.SmileysEnabled);
  EnableWindow(GetDlgItem(hDlg,IDC_MATH),MathModuleEnabled);
  if MathModuleEnabled then
    SetChecked(IDC_MATH,GridOptions.MathModuleEnabled);
  SetChecked(IDC_RAWRTF,GridOptions.RawRTFEnabled);

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
    ID_LOOK_FONT_LINK: PluginLink.CallService(MS_UTILS_OPENURL,Integer(True),Integer(@URL_FONTSERVICE[1]));
    ID_LOOK_ICO_LINK: PluginLink.CallService(MS_UTILS_OPENURL,Integer(True),Integer(@URL_ICOLIB[1]));
    ID_LOOK_INFO_LINK: PluginLink.CallService(MS_UTILS_OPENURL,Integer(True),Integer(@URL_EXPLAIN[1]));
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
