unit hpp_forms;

interface

uses Graphics, Windows, Forms, TntStdCtrls, StdCtrls, Controls, TntControls, Messages;

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

  // notification messages:
  HM_NOTF_ICONSCHANGED   = HM_NOTF_BASE + 1; // Skin icons has changed
  HM_NOTF_ICONS2CHANGED  = HM_NOTF_BASE + 2; // IcoLib icons has changed
  HM_NOTF_FILTERSCHANGED = HM_NOTF_BASE + 3; // Filters has changed
  HM_NOTF_TOOLBARCHANGED = HM_NOTF_BASE + 4; // Toolbar has changed
  HM_NOTF_BOOKMARKCHANGED = HM_NOTF_BASE + 5; // Toolbar has changed

procedure NotifyAllForms(Msg,wParam,lParam: DWord);
procedure BringFormToFront(Form: TForm);
procedure MakeFontsParent(Control: TControl);

function Utils_RestoreFormPosition(Form: TForm; hContact: THandle; Module,Prefix: String): Boolean;
function Utils_SaveFormPosition(Form: TForm; hContact: THandle; Module,Prefix: String): Boolean;

implementation

uses hpp_global, hpp_services, HistoryForm, GlobalSearch, hpp_opt_dialog,
  CustomizeFiltersForm, hpp_database, CustomizeToolbar;

function Utils_RestoreFormPosition(Form: TForm; hContact: THandle; Module,Prefix: String): Boolean;
var
  w,h,l,t: Integer;
  max: Boolean;
begin
  Result := True;
  w := GetDBInt(Module,Prefix+'width',Form.Width);
  h := GetDBInt(Module,Prefix+'height',Form.Height);
  l := GetDBInt(Module,Prefix+'x',(Screen.Width - w) div 2);
  t := GetDBInt(Module,Prefix+'y',(Screen.Height - h) div 2);
  max := GetDBBool(Module,Prefix+'maximized',False);

  // just to be safe, don't let window jump out of the screen
  // at least 40 px from each side should be visible
  if t+h < 40 then t := 40-h;
  if l+w < 40 then l := 40-w;
  if Screen.Width - l < 40 then l := Screen.Width - 40;
  if Screen.Height - t < 40 then t := Screen.Height - 40;

  Form.SetBounds(l,t,w,h);
  if max then
    Form.WindowState := wsMaximized;
end;

function Utils_SaveFormPosition(Form: TForm; hContact: THandle; Module,Prefix: String): Boolean;
var
  w,h,l,t: Integer;
  wp: TWindowPlacement;
  max: Boolean;
begin
  Result := True;
  if Form.WindowState = wsMaximized then begin
    wp.length := SizeOf(wp);
    GetWindowPlacement(Form.Handle,@wp);
    l := wp.rcNormalPosition.Left;
    t := wp.rcNormalPosition.Top;
    h := wp.rcNormalPosition.Bottom - wp.rcNormalPosition.Top;
    w := wp.rcNormalPosition.Right - wp.rcNormalPosition.Left;
    max := True;
  end
  else begin
    w := Form.Width;
    h := Form.Height;
    l := Form.Left;
    t := Form.Top;
    max := False;
  end;

  WriteDBInt(Module,Prefix+'width',w);
  WriteDBInt(Module,Prefix+'height',h);
  WriteDBInt(Module,Prefix+'x',l);
  WriteDBInt(Module,Prefix+'y',t);
  WriteDBBool(Module,Prefix+'maximized',max);
end;

procedure BringFormToFront(Form: TForm);
begin
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

end.
