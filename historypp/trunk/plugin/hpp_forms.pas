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

procedure NotifyAllForms(Msg,wParam,lParam: DWord);
procedure BringFormToFront(Form: TForm);
procedure MakeFontsParent(Control: TControl);
function HppMessageBox(Handle: THandle; const Text: WideString; const Caption: WideString; Flags: Integer): Integer;

implementation

uses hpp_global, hpp_services, HistoryForm, GlobalSearch, hpp_opt_dialog,
  CustomizeFiltersForm;

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
      SendMessage(THistoryFrm(HstWindowList[i]).EventDetailFrom.Handle,Msg,wParam,lParam);
    SendMessage(THistoryFrm(HstWindowList[i]).Handle,Msg,wParam,lParam);
  end;

  if Assigned(fmGlobalSearch) then
    SendMessage(fmGlobalSearch.Handle,Msg,wParam,lParam);

  if Assigned(fmCustomizeFilters) then
    SendMessage(fmCustomizeFilters.Handle,Msg,wParam,lParam);
end;

function HppMessageBox(Handle: THandle; const Text: WideString; const Caption: WideString; Flags: Integer): Integer;
begin
  if not hppOSUnicode then begin
    // ansi ver
    Result := MessageBox(Handle,PAnsiChar(WideToAnsiString(Text,hppCodepage)),PAnsiChar(WideToAnsiString(Caption,hppCodepage)),Flags);
  end
  else begin
    // unicode ver
    Result := MessageBoxW(Handle,PWideChar(Text),PWideChar(Caption),Flags);
  end;
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
