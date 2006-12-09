unit hpp_forms;

interface

uses Graphics, Windows, Messages, Forms, Controls, StdCtrls, Menus, ComCtrls,
  TntControls, TntForms, TntMenus, TntComCtrls, TntStdCtrls, Classes;

type
  THppHintWindow = class (TTntHintWindow)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

const
  HM_BASE = WM_APP + 10214; // base for all history++ messages
  HM_HIST_BASE = HM_BASE + 100; // base for contact's history specific messages
  HM_SRCH_BASE = HM_BASE + 200; // base for global search specific messages
  HM_SESS_BASE = HM_BASE + 300; // base for session thread specific messages
  HM_STRD_BASE = HM_BASE + 400; // base for search thread specific messages
  HM_NOTF_BASE = HM_BASE + 500; // base for plugin-wide notification messages
  HM_MIEV_BASE = HM_BASE + 600; // base for miranda event messages

  // notification messages:
  HM_NOTF_ICONSCHANGED    = HM_NOTF_BASE + 1; // Skin icons has changed
  HM_NOTF_ICONS2CHANGED   = HM_NOTF_BASE + 2; // IcoLib icons has changed
  HM_NOTF_FILTERSCHANGED  = HM_NOTF_BASE + 3; // Filters has changed
  HM_NOTF_TOOLBARCHANGED  = HM_NOTF_BASE + 4; // Toolbar has changed
  HM_NOTF_BOOKMARKCHANGED = HM_NOTF_BASE + 5; // Bookmarks has changed
  HM_NOTF_ACCCHANGED      = HM_NOTF_BASE + 6; // Accessability prefs changed (menu toggle)

  // miranda events
  HM_MIEV_EVENTADDED      = HM_MIEV_BASE + 1; // ME_DB_EVENT_ADDED
  HM_MIEV_EVENTDELETED    = HM_MIEV_BASE + 2; // ME_DB_EVENT_DELETED
  HM_MIEV_PRESHUTDOWN     = HM_MIEV_BASE + 3; // ME_SYSTEM_PRESHUTDOWN
  HM_MIEV_CONTACTDELETED  = HM_MIEV_BASE + 4; // ME_DB_CONTACT_DELETED

procedure NotifyAllForms(Msg,wParam,lParam: DWord);
procedure BringFormToFront(Form: TForm);
procedure MakeFontsParent(Control: TControl);

procedure TranslateMenu(mi: TMenuItem);
procedure TranslateToolbar(const tb: TTntToolBar);

function ShiftStateToKeyData(ShiftState :TShiftState):Longint;
function IsFormShortCut(List: Array of TComponent; Key: DWord; ShiftState: TShiftState): Boolean;

function Utils_RestoreFormPosition(Form: TTntForm; hContact: THandle; Module,Prefix: String): Boolean;
function Utils_SaveFormPosition(Form: TTntForm; hContact: THandle; Module,Prefix: String): Boolean;

implementation

uses hpp_global, hpp_services, hpp_opt_dialog, hpp_database,
  HistoryForm, GlobalSearch,
  {$IFNDEF NO_EXTERNALGRID}hpp_external,{$ENDIF}
  CustomizeFiltersForm,
  CustomizeToolbar;

function IsFormShortCut(List: Array of TComponent; Key: DWord; ShiftState: TShiftState): Boolean;
var
  i: integer;
  mes: TWMKey;
begin
  if Key = VK_INSERT then begin
    if ShiftState = [ssCtrl] then begin
      Key := Ord('C')
    end else
    if ShiftState = [ssShift] then begin
      Key := Ord('V'); ShiftState := [ssCtrl];
    end;
  end;
  Result := False;
  mes.CharCode := Key;
  mes.KeyData := ShiftStateToKeyData(ShiftState);
  for i := 0 to High(List) do begin
    if List[i] is TMenu then begin
      Result := TMenu(List[i]).IsShortCut(mes);
    end else
    if List[i] is TForm then begin
      Result := (TForm(List[i]).Menu <> nil) and
                (TForm(List[i]).Menu.WindowHandle <> 0) and
                (TForm(List[i]).Menu.IsShortCut(mes));
    end;
    if Result then break;
  end;
end;

function ShiftStateToKeyData(ShiftState :TShiftState):Longint;
const
  AltMask = $20000000;
begin
  Result := 0;
  if ssShift in ShiftState then
    Result := Result or VK_SHIFT;
  if ssCtrl in ShiftState then
    Result := Result or VK_CONTROL;
  if ssAlt in ShiftState then
    Result := Result or AltMask;
end;

function Utils_RestoreFormPosition(Form: TTntForm; hContact: THandle; Module,Prefix: String): Boolean;
var
  w,h,l,t,mon: Integer;
  wp: TWindowPlacement;
  maximized: Boolean;
begin
  Result := True;
  mon := GetDBWord(Module,Prefix+'monitor',Form.Monitor.MonitorNum);
  if mon >= Screen.MonitorCount then mon := Form.Monitor.MonitorNum;
  w := GetDBWord(Module,Prefix+'width',Form.Width);
  h := GetDBWord(Module,Prefix+'height',Form.Height);
  l := GetDBWord(Module,Prefix+'x',Screen.Monitors[mon].Left+((Screen.Monitors[mon].Width-w) div 2));
  t := GetDBWord(Module,Prefix+'y',Screen.Monitors[mon].Top+((Screen.Monitors[mon].Height-h) div 2));
  maximized := GetDBBool(Module,Prefix+'maximized',False);
  // just to be safe, don't let window jump out of the screen
  // at least 50 px from each side should be visible
  if l+50 > Screen.DesktopWidth then l := Screen.DesktopWidth-50;
  if t+50 > Screen.DesktopHeight then t := Screen.DesktopHeight-50;
  if l+w < 50 then l := 50-w;
  if t+h < 50 then t := 50-h;
  if Form.HandleAllocated then begin
    wp.length := SizeOf(TWindowPlacement);
    GetWindowPlacement(Form.Handle,@wp);
    wp.rcNormalPosition := Rect(l,t,l+w,t+h);
    if Form.Visible then
      wp.showCmd := SW_SHOWNA
    else
      wp.showCmd := SW_HIDE;
    SetWindowPlacement(Form.Handle,@wp);
  end else
    Form.SetBounds(l,t,w,h);
  if maximized then Form.WindowState := wsMaximized;
end;

function Utils_SaveFormPosition(Form: TTntForm; hContact: THandle; Module,Prefix: String): Boolean;
var
  w,h,l,t: Integer;
  wp: TWindowPlacement;
  maximized: Boolean;
begin
  Result := True;
  maximized := (Form.WindowState = wsMaximized);
  if maximized then begin
    wp.length := SizeOf(TWindowPlacement);
    GetWindowPlacement(Form.Handle,@wp);
    l := wp.rcNormalPosition.Left;
    t := wp.rcNormalPosition.Top;
    w := wp.rcNormalPosition.Right - wp.rcNormalPosition.Left;
    h := wp.rcNormalPosition.Bottom - wp.rcNormalPosition.Top;
  end else begin
    l := Form.Left;
    t := Form.Top;
    w := Form.Width;
    h := Form.Height;
  end;
  WriteDBWord(Module,Prefix+'x',l);
  WriteDBWord(Module,Prefix+'y',t);
  WriteDBWord(Module,Prefix+'width',w);
  WriteDBWord(Module,Prefix+'height',h);
  WriteDBWord(Module,Prefix+'monitor',Form.Monitor.MonitorNum);
  WriteDBBool(Module,Prefix+'maximized',maximized);
end;

procedure BringFormToFront(Form: TForm);
begin
  if Form.WindowState = wsMaximized then
    ShowWindow(Form.Handle,SW_SHOWMAXIMIZED)
  else
    ShowWindow(Form.Handle,SW_SHOWNORMAL);
  Form.BringToFront;
end;

procedure NotifyAllForms(Msg,wParam,lParam: DWord);
var
  i: Integer;
begin
  if hDlg <> 0 then
    SendMessage(hDlg,Msg,wParam,lParam);

  // we are going backwards here because history forms way want to
  // close themselves on the message, so we would have AVs if go from 0 to Count

  {$IFNDEF NO_EXTERNALGRID}
  for i := Length(ExternalGrids)-1 downto 0 do
    ExternalGrids[i].Perform(Msg,wParam,lParam);
  {$ENDIF}

  for i := HstWindowList.Count - 1 downto 0 do begin
    if Assigned(THistoryFrm(HstWindowList[i]).EventDetailFrom) then
      THistoryFrm(HstWindowList[i]).EventDetailFrom.Perform(Msg,wParam,lParam);
    THistoryFrm(HstWindowList[i]).Perform(Msg,wParam,lParam);
  end;

  if Assigned(fmGlobalSearch) then
    fmGlobalSearch.Perform(Msg,wParam,lParam);

  if Assigned(fmCustomizeFilters) then
    fmCustomizeFilters.Perform(Msg,wParam,lParam);

  if Assigned(fmCustomizeToolbar) then
    fmCustomizeToolbar.Perform(Msg,wParam,lParam);
end;

// This procedure scans all control children and if they have
// no ParentFont, sets ParentFont to true but reapplies font styles,
// so even having parent font and size, controls remain bold or italic
//
// Of course it can be done cleaner and for all controls supporting fonts
// property through TPropertyEditor and GetPropInfo, but then it would
// need vcl sources to compile, so not a best alternative for open source plugin
procedure MakeFontsParent(Control: TControl);
var
  i: Integer;
  fs: TFontStyles;
begin
  // Set TLabel & TtntLabel
  if (Control is TLabel) and (not TLabel(Control).ParentFont) then begin
    fs := TLabel(Control).Font.Style;
    TLabel(Control).ParentFont := True;
    TLabel(Control).Font.Style := fs;
  end;
  if (Control is TtntLabel) and (not TtntLabel(Control).ParentFont) then begin
    fs := TtntLabel(Control).Font.Style;
    TtntLabel(Control).ParentFont := True;
    TtntLabel(Control).Font.Style := fs;
  end;
  // Process children
  for i := 0 to Control.ComponentCount - 1 do begin
    if Control.Components[i] is TControl then begin
      MakeFontsParent(TControl(Control.Components[i]));
    end;
  end;
end;

{ THppHintWindow }

procedure THppHintWindow.CreateParams(var Params: TCreateParams);
begin
  // standard delphi's hint window leaves shadow border after hint
  // closes, this is workaround until real fix is found
  inherited CreateParams(Params);
  Params.WindowClass.Style := Params.WindowClass.style and not CS_DROPSHADOW;
end;

procedure TranslateMenu(mi: TMenuItem);
var
  i: integer;
begin
  for i := 0 to mi.Count-1 do
    if mi.Items[i].Caption <> '-' then begin
      TTntMenuItem(mi.Items[i]).Caption := TranslateWideW(mi.Items[i].Caption{TRANSLATE-IGNORE});
        if mi.Items[i].Count > 0 then TranslateMenu(mi.Items[i]);
    end;
end;

procedure TranslateToolbar(const tb: TTntToolBar);
var
  i: integer;
begin
  for i := 0 to tb.ButtonCount-1 do
    if tb.Buttons[i].Style <> tbsSeparator then begin
      TTntToolBar(tb.Buttons[i]).Hint := TranslateWideW(tb.Buttons[i].Hint{TRANSLATE-IGNORE});
      TTntToolBar(tb.Buttons[i]).Caption := TranslateWideW(tb.Buttons[i].Caption{TRANSLATE-IGNORE});
    end;
end;

end.
