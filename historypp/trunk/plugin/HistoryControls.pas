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

unit HistoryControls;

{$I compilers.inc}

interface

uses
  Windows, Messages, Classes, TntWindows,
  Controls, StdCtrls, ComCtrls, ExtCtrls, Buttons, {Dialogs,} Graphics,
  TntControls, TntStdCtrls, TntComCtrls, TntExtCtrls, TntButtons, TntGraphics,
  TntForms;

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

  THppToolBar = class(TTntToolBar)
  private
    procedure AddToolButtonStyle(const Control: TControl; var Style: Byte);
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

  THppToolButton = class(TTntToolButton)
  private
    FWholeDropDown: Boolean; // ignored unless Style = tbsDropDown is set
    procedure SetWholeDropDown(const Value: Boolean);
  published
    property WholeDropDown: Boolean read FWholeDropDown write SetWholeDropDown default False;
  end;

  THppSpeedButton = class(TTntSpeedButton)
  protected
    procedure PaintButton; override;
    {$IFDEF COMPILER_7}
    procedure UpdateTracking;
    procedure WndProc(var Message: TMessage); override;
    procedure UpdateInternalGlyphList; override;
    {$ENDIF}
  end;

  THppButton = class(TTntButton)
  private
    {$IFDEF COMPILER_7}
    procedure CNCtlColorStatic(var Message: TWMCtlColorStatic); message CN_CTLCOLORSTATIC;
    procedure CNCtlColorBtn(var Message: TWMCtlColorBtn); message CN_CTLCOLORBTN;
    {$ENDIF}
  end;

  THppRadioButton = class(TTntRadioButton)
  private
    {$IFDEF COMPILER_7}
    procedure CNCtlColorStatic(var Message: TWMCtlColorStatic); message CN_CTLCOLORSTATIC;
    {$ENDIF}
  end;

  THppCheckBox = class(TTntCheckBox)
  private
    {$IFDEF COMPILER_7}
    procedure CNCtlColorStatic(var Message: TWMCtlColorStatic); message CN_CTLCOLORSTATIC;
    {$ENDIF}
  end;

  THppGroupBox = class(TTntGroupBox)
  protected
    procedure Paint; override;
  end;

  THppForm = class(TTntForm)
  private
    FIconBig: TIcon;
    function IsIconBigStored: Boolean;
    procedure IconChanged(Sender: TObject);
    procedure SetIcons(hIcon: HICON; hIconBig: HICON);
    procedure SetIconBig(Value: TIcon);
    procedure CMIconChanged(var Message: TMessage); message CM_ICONCHANGED;
  protected
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property IconBig: TIcon read FIconBig write SetIconBig stored IsIconBigStored;
  end;

  { //Saved for probably future use
  THppSaveDialog = class(TSaveDialog)
  private
    FShowModal: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
  protected
    function TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool; override;
  published
    property ShowModal: Boolean read FShowModal write FShowModal;
  end;
  }

procedure Register;

implementation

uses CommCtrl, {CommDlg,} Forms, Themes, UxTheme, SysUtils, TntSysUtils;

procedure Register;
begin
  RegisterComponents('History++', [TPasswordEdit]);
  RegisterComponents('History++', [THppEdit]);
  RegisterComponents('History++', [THppPanel]);
  RegisterComponents('History++', [THppToolBar]);
  RegisterComponents('History++', [THppToolButton]);
  RegisterComponents('History++', [THppSpeedButton]);
  RegisterComponents('History++', [THppButton]);
  RegisterComponents('History++', [THppRadioButton]);
  RegisterComponents('History++', [THppCheckBox]);
  RegisterComponents('History++', [THppGroupBox]);
  RegisterComponents('History++', [THppForm]);
  {RegisterComponents('History++', [THppSaveDialog]);}
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
  {$IFDEF THEME_7_UP}
  if ThemeServices.ThemesEnabled then
    ParentBackground := StoredParentBackground;
  {$ENDIF}
end;
{$ENDIF}

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

{ THppSpeedButton }

type

  THackSpeedButton_D6_D7_D9_D10 = class(TGraphicControl)
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
  THackSpeedButton = THackSpeedButton_D6_D7_D9_D10;
  {$ENDIF}

type
  EAbortPaint = class(EAbort);

  THackTntSpeedButton = class(TSpeedButton)
  protected
    FPaintInherited: Boolean;
  end;

// hack to prepaint non transparent sppedbuttons with themed
// parent control, such as doublebuffered toolbar.
// VCL bug.
procedure THppSpeedButton.PaintButton;
begin
  {$IFDEF THEME_7_UP}
  with ThemeServices do
    if not Transparent and ThemesEnabled and Assigned(Parent) then
      DrawParentBackground(Parent.Handle, Canvas.Handle, nil, True);
  {$ENDIF}
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

// hack to avoid only first TntSpeedButton painted in Deplhi 7
// on panels in case of full repainting panel
procedure THppSpeedButton.UpdateInternalGlyphList;
begin
  THackTntSpeedButton(Self).FPaintInherited := True;
  try
    Paint;
  finally
    THackTntSpeedButton(Self).FPaintInherited := False;
  end;
  Invalidate;
  raise EAbortPaint.Create('');
end;
{$ENDIF}

{ THppButton }

{$IFDEF DELPHI_7}
// hack to make Button really ParentBackground'ed.
// VCL bug. http://qc.borland.com/wc/qcmain.aspx?d=2537
procedure THppButton.CNCtlColorStatic(var Message: TWMCtlColorStatic);
begin
  {$IFDEF THEME_7_UP}
  with ThemeServices do
  if ThemesEnabled and Assigned(Parent) and Parent.DoubleBuffered then begin
    PerformEraseBackground(Self, Message.ChildDC);
    Message.Result := GetStockObject(NULL_BRUSH);
  end else
  {$ENDIF}
  inherited;
end;

procedure THppButton.CNCtlColorBtn(var Message: TWMCtlColorBtn);
begin
  {$IFDEF THEME_7_UP}
  with ThemeServices do
  if ThemesEnabled and Assigned(Parent) and Parent.DoubleBuffered then begin
    PerformEraseBackground(Self, Message.ChildDC);
    Message.Result := GetStockObject(NULL_BRUSH);
  end else
  {$ENDIF}
  inherited;
end;
{$ENDIF}

{ THppRadioButton }

{$IFDEF DELPHI_7}
// hack to make RadioButton really ParentBackground'ed.
// VCL bug. http://qc.borland.com/wc/qcmain.aspx?d=2537
procedure THppRadioButton.CNCtlColorStatic(var Message: TWMCtlColorStatic);
begin
  {$IFDEF THEME_7_UP}
  with ThemeServices do
  if ThemesEnabled and Assigned(Parent) and Parent.DoubleBuffered then begin
    PerformEraseBackground(Self, Message.ChildDC);
    Message.Result := GetStockObject(NULL_BRUSH);
  end else
  {$ENDIF}
  inherited;
end;
{$ENDIF}

{ THppCheckBox }

{$IFDEF DELPHI_7}
// hack to make CheckBox really ParentBackground'ed.
// VCL bug. http://qc.borland.com/wc/qcmain.aspx?d=2537
procedure THppCheckBox.CNCtlColorStatic(var Message: TWMCtlColorStatic);
begin
  {$IFDEF THEME_7_UP}
  with ThemeServices do
  if ThemesEnabled and Assigned(Parent) and Parent.DoubleBuffered then begin
    PerformEraseBackground(Self, Message.ChildDC);
    Message.Result := GetStockObject(NULL_BRUSH);
  end else
  {$ENDIF}
  inherited;
end;
{$ENDIF}

{ THppGroupBox }

procedure THppGroupBox.Paint;
var
  spCaption: WideString;

  {$IFDEF THEME_7_UP}
  procedure PaintThemedGroupBox;
  var
    CaptionRect: TRect;
    OuterRect: TRect;
    Box: TThemedButton;
    Details: TThemedElementDetails;
  begin
    if Enabled then
      Box := tbGroupBoxNormal else
      Box := tbGroupBoxDisabled;
    Details := ThemeServices.GetElementDetails(Box);
    with Canvas do begin
      if spCaption <> '' then begin
        with Details do
          UxTheme.GetThemeTextExtent(ThemeServices.Theme[Element],Handle,
            Part,State,PWideChar(spCaption),Length(spCaption),DT_LEFT, nil,CaptionRect);
        if not UseRightToLeftAlignment then
          OffsetRect(CaptionRect, 8, 0) else
          OffsetRect(CaptionRect, Width - 8 - CaptionRect.Right, 0);
      end else
        CaptionRect := Rect(0, 0, 0, 0);

      OuterRect := ClientRect;
      OuterRect.Top := (CaptionRect.Bottom - CaptionRect.Top) div 2;
      with CaptionRect do
        ExcludeClipRect(Handle, Left, Top, Right, Bottom);
      ThemeServices.DrawElement(Handle, Details, OuterRect);

      SelectClipRgn(Handle, 0);
      if Caption <> '' then
        ThemeServices.DrawText(Handle, Details, spCaption, CaptionRect, DT_LEFT, 0);
    end;
  end;
  {$ENDIF}

  procedure PaintGroupBox;
  var
    H: Integer;
    R: TRect;
    Flags: Longint;
  begin
    with Canvas do begin
      H := WideCanvasTextHeight(Canvas, '0');
      R := Rect(0, H div 2 - 1, Width, Height);
      if Ctl3D then
      begin
        Inc(R.Left);
        Inc(R.Top);
        Brush.Color := clBtnHighlight;
        FrameRect(R);
        OffsetRect(R, -1, -1);
        Brush.Color := clBtnShadow;
      end else
        Brush.Color := clWindowFrame;
      FrameRect(R);
      if spCaption <> '' then
      begin
        if not UseRightToLeftAlignment then
          R := Rect(8, 0, 0, H)
        else
          R := Rect(R.Right - WideCanvasTextWidth(Canvas, spCaption) - 8, 0, 0, H);
        Flags := DrawTextBiDiModeFlags(DT_SINGLELINE);
        Tnt_DrawTextW(Handle, PWideChar(spCaption), Length(spCaption), R, Flags or DT_CALCRECT);
        Brush.Color := Color;
        Tnt_DrawTextW(Handle, PWideChar(spCaption), Length(spCaption), R, Flags);
      end;
    end;
  end;

begin
  if Win32PlatformIsUnicode then begin
    spCaption := Caption;
    if spCaption <> '' then spCaption := ' '+spCaption+' ';
    Canvas.Font := Self.Font;
    {$IFDEF THEME_7_UP}
    if ThemeServices.ThemesEnabled then PaintThemedGroupBox else
    {$ENDIF}
    PaintGroupBox;
  end else
    inherited;
end;

{ THppForm }

function THppForm.IsIconBigStored: Boolean;
begin
  Result := not IsControl and (FIconBig.Handle <> 0);
end;

procedure THppForm.SetIcons(hIcon: HICON; hIconBig: HICON);
begin
  if NewStyleControls then begin
    if HandleAllocated and (BorderStyle <> bsDialog) then begin
        SendMessage(Handle, WM_SETICON, ICON_SMALL, hIcon);
        SendMessage(Handle, WM_SETICON, ICON_BIG, hIconBig);
    end;
  end else
    if IsIconic(Handle) then Invalidate;
end;

procedure THppForm.IconChanged(Sender: TObject);
begin
  if FIconBig.Handle = 0 then
    SetIcons(0, Icon.Handle) else
    SetIcons(Icon.Handle, FIconBig.Handle);
end;

procedure THppForm.SetIconBig(Value: TIcon);
begin
  FIconBig.Assign(Value);
end;

procedure THppForm.CMIconChanged(var Message: TMessage);
begin
  if (Icon.Handle = 0) or (FIconBig.Handle = 0) then
    IconChanged(nil);
end;

procedure THppForm.CreateWnd;
begin
  inherited CreateWnd;
  if NewStyleControls then
    if BorderStyle <> bsDialog then
      IconChanged(nil) else
      SetIcons(0, 0);
end;

constructor THppForm.Create(AOwner: TComponent);
begin
  FIconBig := TIcon.Create;
  FIconBig.Width := GetSystemMetrics(SM_CXICON);
  FIconBig.Height := GetSystemMetrics(SM_CYICON);
  FIconBig.OnChange := IconChanged;
  inherited Create(AOwner);
  Icon.OnChange := IconChanged;
end;

destructor THppForm.Destroy;
begin
  inherited Destroy;
  FIconBig.Free;
end;

{ THppSaveDialog }
{ //Saved for probably future use

type
  THackCommonDialog = class(TComponent)
  protected
    FCtl3D: Boolean;
    FDefWndProc: Pointer;
    FHelpContext: THelpContext;
    FHandle: HWnd;
    FObjectInstance: Pointer;
    FTemplate: PChar;
  end;
var
  sCreationControl: TCommonDialog = nil;

procedure CenterWindow(Wnd: HWnd);
var
  Rect: TRect;
  Monitor: TMonitor;
begin
  GetWindowRect(Wnd, Rect);
  if Application.MainForm <> nil then
  begin
    if Assigned(Screen.ActiveForm) then
      Monitor := Screen.ActiveForm.Monitor
      else
        Monitor := Application.MainForm.Monitor;
  end
  else
    Monitor := Screen.Monitors[0];
  SetWindowPos(Wnd, 0,
    Monitor.Left + ((Monitor.Width - Rect.Right + Rect.Left) div 2),
    Monitor.Top + ((Monitor.Height - Rect.Bottom + Rect.Top) div 3),
    0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
end;

function DialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := 0;
  if Msg = WM_INITDIALOG then
  begin
    CenterWindow(Wnd);
    THackCommonDialog(sCreationControl).FHandle := Wnd;
    THackCommonDialog(sCreationControl).FDefWndProc := Pointer(SetWindowLong(Wnd, GWL_WNDPROC,
      Longint(THackCommonDialog(sCreationControl).FObjectInstance)));
    CallWindowProc(THackCommonDialog(sCreationControl).FObjectInstance, Wnd, Msg, WParam, LParam);
    sCreationControl := nil;
  end;
end;

function ExplorerHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := 0;
  if Msg = WM_INITDIALOG then
  begin
    THackCommonDialog(sCreationControl).FHandle := Wnd;
    THackCommonDialog(sCreationControl).FDefWndProc := Pointer(SetWindowLong(Wnd, GWL_WNDPROC,
      Longint(THackCommonDialog(sCreationControl).FObjectInstance)));
    CallWindowProc(THackCommonDialog(sCreationControl).FObjectInstance, Wnd, Msg, WParam, LParam);
    sCreationControl := nil;
  end
  else if (Msg = WM_NOTIFY) and (POFNotify(LParam)^.hdr.code = CDN_INITDONE) then
    CenterWindow(GetWindowLong(Wnd, GWL_HWNDPARENT));
end;

constructor THppSaveDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FShowModal := False;
end;

function THppSaveDialog.TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool;
type
  TDialogFunc = function(var DialogData): Bool stdcall;
var
  ActiveWindow: HWnd;
  FPUControlWord: Word;
  FocusState: TFocusState;
  WasEnabled: Boolean;
begin
  if FShowModal then
    Result := inherited TaskModalDialog(DialogFunc,DialogData)
  else begin
    if (ofOldStyleDialog in Options) or not NewStyleControls then
      TOpenFilename(DialogData).lpfnHook := DialogHook else
      TOpenFilename(DialogData).lpfnHook := ExplorerHook;
    ActiveWindow := GetActiveWindow;
    WasEnabled := IsWindowEnabled(ActiveWindow);
    if WasEnabled then EnableWindow(ActiveWindow, False);
    FocusState := SaveFocusState;
    try
      Application.HookMainWindow(MessageHook);
      asm
        // Avoid FPU control word change in NETRAP.dll, NETAPI32.dll, etc
        FNSTCW  FPUControlWord
      end;
      try
        sCreationControl := Self;
        Result := TDialogFunc(DialogFunc)(DialogData);
      finally
        asm
          FNCLEX
          FLDCW FPUControlWord
        end;
        Application.UnhookMainWindow(MessageHook);
      end;
    finally
      if WasEnabled then EnableWindow(ActiveWindow, True);
      SetActiveWindow(ActiveWindow);
      RestoreFocusState(FocusState);
    end;
  end;
end;}

end.
