unit HistoryControls;

{$I compilers.inc}

interface

uses
  Windows, Messages, Classes,
  Controls, StdCtrls, ComCtrls, ExtCtrls, Buttons,
  TntControls, TntStdCtrls, TntComCtrls, TntExtCtrls, TntButtons;

type

  TPasswordEdit = class(TEdit)
  private
    FDummyPasswordChar: Char;
    function GetPasswordChar: Char;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  published
    property PasswordChar: Char read GetPasswordChar write FDummyPasswordChar default #0;
  end;

  THppEdit = class(TTntEdit)
  private
    procedure WMChar(var Message: TWMKey); message WM_CHAR;
  end;

  THppPanel = class(TTntPanel)
  public
    {$IFDEF COMPILER_7}
    constructor Create(AOwner: TComponent); override;
    {$ENDIF}
  end;

  THppToolButton = class(TTntToolButton)
  private
    FWholeDropDown: Boolean; // ignored unless Style = tbsDropDown is set
    procedure SetWholeDropDown(const Value: Boolean);
  published
    property WholeDropDown: Boolean read FWholeDropDown write SetWholeDropDown default False;
  end;

  THppToolBar = class(TTntToolBar)
  private
    procedure AddToolButtonStyle(const Control: TControl; var Style: Byte);
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

  THppSpeedButton = class(TTntSpeedButton)
  protected
    procedure PaintButton; override;
    {$IFDEF COMPILER_7}
    procedure UpdateTracking;
    procedure WndProc(var Message: TMessage); override;
    {$ENDIF}
  end;

procedure Register;

implementation

uses CommCtrl, Forms, Themes, TntSysUtils;

procedure Register;
begin
  RegisterComponents('History++', [TPasswordEdit]);
  RegisterComponents('History++', [THppEdit]);
  RegisterComponents('History++', [THppPanel]);
  RegisterComponents('History++', [THppSpeedButton]);
  RegisterComponents('History++', [THppToolBar]);
  RegisterComponents('History++', [THppToolButton]);
end;

procedure TPasswordEdit.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or ES_PASSWORD;
end;

function TPasswordEdit.GetPasswordChar: Char;
begin
  Result := #0;
end;

{ THppEdit }

procedure THppEdit.WMChar(var Message: TWMKey);
var
  ss,sl: integer;
  txt: WideString;
  lastWS: Boolean;
  currentWS: Boolean;

  function IsWordSeparator(WC: WideChar): Boolean;
  begin
    Result := (WC = WideChar(#0)) or IsWideCharSpace(WC) or IsWideCharPunct(WC);
  end;

begin
  // Ctrl+Backspace workaround
  if (Message.CharCode = 127) and (KeyDataToShiftState(Message.KeyData) = [ssCtrl]) then begin
    Message.Result := 0;
    Perform(EM_GETSEL,wParam(@ss),lParam(@sl));
    if (ss = 0) or (ss <> sl) then exit;
    sl := 0;
    txt := Text;
    lastWS := IsWordSeparator(txt[ss]);
    while ss > 0 do begin
      currentWS := IsWordSeparator(txt[ss]);
      if not lastWS and currentWS then break;
      lastWS := currentWS;
      Dec(ss);
      Inc(sl);
    end;
    Delete(txt,ss+1,sl);
    Text := txt;
    Perform(EM_SETSEL,wParam(@ss),lParam(@ss));
  end else
    inherited;
end;

{ THppPanel }

{$IFDEF DELPHI_7}
// hack to make panel really ParentBackground'ed.
// VCL bug. http://qc.borland.com/wc/qcmain.aspx?d=2534
constructor THppPanel.Create(AOwner: TComponent);
var
  StoredParentBackground: Boolean;
begin
  StoredParentBackground := ParentBackground;
  inherited Create(AOwner);
  //ControlStyle := ControlStyle - [csParentBackground] + [csOpaque];
  if ThemeServices.ThemesEnabled then
    ParentBackground := StoredParentBackground;
end;
{$ENDIF}

{ THppToolButton }

// Note: ignored unless Style = tbsDropDown is set
procedure THppToolButton.SetWholeDropDown(const Value: Boolean);
begin
  if FWholeDropDown = Value then exit;
  FWholeDropDown := Value;
  RefreshControl;
  // Trick: resize tool buttons.
  // TODO: refresh only when theme is loaded.
  if Assigned(FToolBar) then FToolBar.Invalidate;
  Width := 1;
end;

{ THppToolBar }

procedure THppToolBar.AddToolButtonStyle(const Control: TControl; var Style: Byte);
const
  BTNS_WHOLEDROPDOWN = $0080;
  WholeDropDownStyles: array[Boolean] of DWORD = (0, BTNS_WHOLEDROPDOWN);
begin
  if Control.InheritsFrom(THppToolButton) and
    (GetComCtlVersion >= ComCtlVersionIE5) then
      Style := Style or WholeDropDownStyles[THppToolButton(Control).WholeDropDown];
end;

procedure THppToolBar.WndProc(var Message: TMessage);
var
  BT: PTBButton;
  BI: PTBButtonInfoW;
begin
  case Message.Msg of
    TB_INSERTBUTTON: begin
      BT := PTBButton(Message.LParam);
      AddToolButtonStyle(TControl(BT.dwData), BT.fsStyle);
    end;
    TB_SETBUTTONINFO: begin
      BI := PTBButtonInfoW(Message.LParam);
      AddToolButtonStyle(TControl(BI.lParam), BI.fsStyle);
    end;
  end;
  inherited;
end;

{ THppSpeedButton }

type

  THackSpeedButton_D6_D7_D9 = class(TGraphicControl)
  protected
    FxxxxGroupIndex: Integer;
    FGlyph: Pointer;
    FxxxxDown: Boolean;
    FDragging: Boolean;
    {$IFDEF DELPHI_7}
    FxxxxAllowAllUp: Boolean;
    FxxxxLayout: TButtonLayout;
    FxxxxSpacing: Integer;
    FxxxxTransparent: Boolean;
    FxxxxMargin: Integer;
    FxxxxFlat: Boolean;
    FMouseInControl: Boolean;
    {$ENDIF}
  end;

  {$IFDEF COMPILER_6_UP} // verified against VCL source in Delphi 6 and BCB 6
  THackSpeedButton = THackSpeedButton_D6_D7_D9;
  {$ENDIF}

// hack to prepaint non transparent sppedbuttons with themed
// parent control, such as doublebuffered toolbar.
// VCL bug.
procedure THppSpeedButton.PaintButton;
begin
  with ThemeServices do
    if not Transparent and ThemesEnabled and Assigned(Parent) then
      DrawParentBackground(Parent.Handle, Canvas.Handle, nil, True);
  inherited;
end;

{$IFDEF DELPHI_7}
procedure THppSpeedButton.UpdateTracking;
var
  P : TPoint;
begin
  GetCursorPos(P);
  if FindDragTarget(P, True) = Self then begin
    if not (THackSpeedButton(Self).FDragging or
            THackSpeedButton(Self).FMouseInControl)
            then Perform(CM_MOUSEENTER,0,0);
    MouseCapture := True;
  end else begin
    MouseCapture := THackSpeedButton(Self).FDragging;
    if THackSpeedButton(Self).FDragging then
      THackSpeedButton(Self).FMouseInControl := not Flat else
      Perform(CM_MOUSELEAVE,0,0);
  end;
end;

// hack to avoid speed buttons always hovered in Deplhi 7
// since there we have no CM_MOUSEENTER and CM_MOUSELEAVE
// from Application.Idle;
procedure THppSpeedButton.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_MOUSEMOVE,WM_NCMOUSEMOVE:
      UpdateTracking;
  end;
  inherited;
  case Message.Msg of
    WM_LBUTTONUP,WM_RBUTTONUP,WM_MBUTTONUP,WM_CONTEXTMENU:
      UpdateTracking;
  end;
end;
{$ENDIF}

end.
