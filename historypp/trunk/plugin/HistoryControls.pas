unit HistoryControls;

{$I compilers.inc}

interface

uses
  Windows, Messages, Classes, Controls, Forms, StdCtrls, ExtCtrls, Buttons,
  TntSysUtils, TntStdCtrls, TntExtCtrls, TntButtons;

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

  THppSpeedButton = class(TTntSpeedButton)
  private
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
  protected
    procedure PaintButton; override;
    {$IFDEF COMPILER_7}
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    {$ENDIF}
  end;

procedure Register;

implementation

uses Themes;

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

procedure Register;
begin
  RegisterComponents('History++', [TPasswordEdit]);
  RegisterComponents('History++', [THppEdit]);
  RegisterComponents('History++', [THppPanel]);
  RegisterComponents('History++', [THppSpeedButton]);
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
      dec(ss);
      inc(sl);
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

{ THppSpeedButton }

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
// hack to avoid speed buttons always hovered in Deplhi 7
// since there we have no CM_MOUSEENTER and CM_MOUSELEAVE
// from Application.Idle;
procedure THppSpeedButton.MouseMove(Shift: TShiftState; X, Y: Integer);
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
    THackSpeedButton(Self).FMouseInControl := not Flat;
    MouseCapture := THackSpeedButton(Self).FDragging;
    if not THackSpeedButton(Self).FDragging then
      Perform(CM_MOUSELEAVE,0,0);
  end;
  inherited;
end;

procedure THppSpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  MouseMove(Shift,X,Y);
end;
{$ENDIF}

// hack to avoid speed buttons hovered after context menu
// show since we have no CM_MOUSEENTER and CM_MOUSELEAVE
// from Application.Idle;
procedure THppSpeedButton.WMContextMenu(var Message: TWMContextMenu);
begin
  inherited;
  if Message.Result <> 0 then Perform(CM_MOUSELEAVE, 0, 0);
end;

end.
