unit WFindReplaceDialog;

{$R-,T-,H+,X+}

interface

uses
  SysUtils, Classes, CommDlg, Windows, Controls, Messages,
  Forms, Dialogs, TntSysUtils, TntClasses;

type
{ TWCommonDialog }

  TWCommonDialog = class(TComponent)
  private
    FCtl3D: Boolean;
    FDefWndProc: Pointer;
    FHelpContext: THelpContext;
    FHandle: HWnd;
    FObjectInstance: Pointer;
    FTemplateW: PWChar;
    FTemplateA: PChar;
    FOnClose: TNotifyEvent;
    FOnShow: TNotifyEvent;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure WMInitDialog(var Message: TWMInitDialog); message WM_INITDIALOG;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure MainWndProc(var Message: TMessage);
  protected
    procedure DoClose; dynamic;
    procedure DoShow; dynamic;
    procedure WndProc(var Message: TMessage); virtual;
    function MessageHook(var Msg: TMessage): Boolean; virtual;
    function TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool; virtual;
    property TemplateW: PWChar read FTemplateW write FTemplateW;
    property TemplateA: PChar read FTemplateA write FTemplateA;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; virtual; abstract;
    procedure DefaultHandler(var Message); override;
    property Handle: HWnd read FHandle;
  published
    property Ctl3D: Boolean read FCtl3D write FCtl3D default True;
    property HelpContext: THelpContext read FHelpContext write FHelpContext default 0;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
  end;

  TFindReplaceFuncW = function(var FindReplace: TFindReplaceW): HWnd stdcall;
  TFindReplaceFuncA = function(var FindReplace: TFindReplaceA): HWnd stdcall;

  TWFindDialog = class(TWCommonDialog)
  private
    FOptions: TFindOptions;
    FPosition: TPoint;
    FFindReplaceFuncW: TFindReplaceFuncW;
    FFindReplaceFuncA: TFindReplaceFuncA;
    FRedirector: TWinControl;
    FOnFind: TNotifyEvent;
    FOnReplace: TNotifyEvent;
    FFindHandle: HWnd;
    FFindReplaceW: TFindReplaceW;
    FFindReplaceA: TFindReplaceA;
    FFindTextW: array[0..255] of WChar;
    FFindTextA: array[0..255] of Char;
    FReplaceTextW: array[0..255] of WChar;
    FReplaceTextA: array[0..255] of Char;
    function GetFindText: Widestring;
    procedure SetFindTextA(const Value: String);
    procedure SetFindText(const Value: Widestring);
    function GetReplaceText: Widestring;
    procedure SetReplaceTextA(const Value: String);
    procedure SetReplaceText(const Value: Widestring);
    function GetLeft: Integer;
    function GetPosition: TPoint;
    function GetTop: Integer;
    procedure SetLeft(Value: Integer);
    procedure SetPosition(const Value: TPoint);
    procedure SetTop(Value: Integer);
    property ReplaceText: Widestring read GetReplaceText write SetReplaceText;
    property OnReplace: TNotifyEvent read FOnReplace write FOnReplace;
  protected
    function MessageHook(var Msg: TMessage): Boolean; override;
    procedure Find; dynamic;
    procedure Replace; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseDialog;
    function Execute: Boolean; override;
    property Left: Integer read GetLeft write SetLeft;
    property Position: TPoint read GetPosition write SetPosition;
    property Top: Integer read GetTop write SetTop;
  published
    property FindText: Widestring read GetFindText write SetFindText;
    property Options: TFindOptions read FOptions write FOptions default [frDown];
    property OnFind: TNotifyEvent read FOnFind write FOnFind;
  end;

{ TWReplaceDialog }

  TWReplaceDialog = class(TWFindDialog)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ReplaceText;
    property OnReplace;
  end;

procedure Register;

implementation

{ Private globals }

var
  CreationControl: TWCommonDialog = nil;
  HelpMsg: Cardinal;
  FindMsg: Cardinal;
  WndProcPtrAtom: TAtom = 0;

{ Center the given window on the screen }

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

{ Generic dialog hook. Centers the dialog on the screen in response to
  the WM_INITDIALOG message }

function DialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := 0;
  if Msg = WM_INITDIALOG then
  begin
    CenterWindow(Wnd);
    CreationControl.FHandle := Wnd;
    CreationControl.FDefWndProc := Pointer(SetWindowLong(Wnd, GWL_WNDPROC,
      Longint(CreationControl.FObjectInstance)));
    CallWindowProc(CreationControl.FObjectInstance, Wnd, Msg, WParam, LParam);
    CreationControl := nil;
  end;
end;

{ TWCommonDialog }

constructor TWCommonDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCtl3D := True;
{$IFDEF MSWINDOWS}
  FObjectInstance := Classes.MakeObjectInstance(MainWndProc);
{$ENDIF}
{$IFDEF LINUX}
  FObjectInstance := WinUtils.MakeObjectInstance(MainWndProc);
{$ENDIF}
end;

destructor TWCommonDialog.Destroy;
begin
{$IFDEF MSWINDOWS}   
  if FObjectInstance <> nil then Classes.FreeObjectInstance(FObjectInstance);
{$ENDIF}
{$IFDEF LINUX}
  if FObjectInstance <> nil then WinUtils.FreeObjectInstance(FObjectInstance);
{$ENDIF}   
  inherited Destroy;
end;

function TWCommonDialog.MessageHook(var Msg: TMessage): Boolean;
begin
  Result := False;
  if (Msg.Msg = HelpMsg) and (FHelpContext <> 0) then
  begin
    Application.HelpContext(FHelpContext);
    Result := True;
  end;
end;

procedure TWCommonDialog.DefaultHandler(var Message);
begin
  if FHandle <> 0 then
    with TMessage(Message) do
      Result := CallWindowProc(FDefWndProc, FHandle, Msg, WParam, LParam)
  else inherited DefaultHandler(Message);
end;

procedure TWCommonDialog.MainWndProc(var Message: TMessage);
begin
  try
    WndProc(Message);
  except
    Application.HandleException(Self);
  end;
end;

procedure TWCommonDialog.WndProc(var Message: TMessage);
begin
  Dispatch(Message);
end;

procedure TWCommonDialog.WMDestroy(var Message: TWMDestroy);
begin
  inherited;
  DoClose;
end;

procedure TWCommonDialog.WMInitDialog(var Message: TWMInitDialog);
begin
  { Called only by non-explorer style dialogs }
  DoShow;
  { Prevent any further processing }
  Message.Result := 0;
end;

procedure TWCommonDialog.WMNCDestroy(var Message: TWMNCDestroy);
begin
  inherited;
  FHandle := 0;
end;

function TWCommonDialog.TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool;
type
  TDialogFunc = function(var DialogData): Bool stdcall;
var
  ActiveWindow: HWnd;
  WindowList: Pointer;
  FPUControlWord: Word;
  FocusState: TFocusState;
begin
  ActiveWindow := GetActiveWindow;
  WindowList := DisableTaskWindows(0);
  FocusState := SaveFocusState;
  try
    Application.HookMainWindow(MessageHook);
    asm
      // Avoid FPU control word change in NETRAP.dll, NETAPI32.dll, etc
      FNSTCW  FPUControlWord
    end;
    try
      CreationControl := Self;
      Result := TDialogFunc(DialogFunc)(DialogData);
    finally
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
      Application.UnhookMainWindow(MessageHook);
    end;
  finally
    EnableTaskWindows(WindowList);
    SetActiveWindow(ActiveWindow);
    RestoreFocusState(FocusState);
  end;
end;

procedure TWCommonDialog.DoClose;
begin
  if Assigned(FOnClose) then FOnClose(Self);
end;

procedure TWCommonDialog.DoShow;
begin
  if Assigned(FOnShow) then FOnShow(Self);
end;


{ TRedirectorWindow }
{ A redirector window is used to put the find/replace dialog into the
  ownership chain of a form, but intercept messages that CommDlg.dll sends
  exclusively to the find/replace dialog's owner.  TRedirectorWindow
  creates its hidden window handle as owned by the target form, and the
  find/replace dialog handle is created as owned by the redirector.  The
  redirector wndproc forwards all messages to the find/replace component.
}

type
  TRedirectorWindow = class(TWinControl)
  private
    FFindReplaceDialog: TWFindDialog;
    FFormHandle: THandle;
    procedure CMRelease(var Message); message CM_Release;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  end;

procedure TRedirectorWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_VISIBLE or WS_POPUP;
    WndParent := FFormHandle;
  end;
end;

procedure TRedirectorWindow.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if (Message.Result = 0) and (Message.Msg <> CM_RELEASE) and
    Assigned(FFindReplaceDialog) then
    Message.Result := Integer(FFindReplaceDialog.MessageHook(Message));
end;

procedure TRedirectorWindow.CMRelease(var Message);
begin
  Free;
end;

{ Find and Replace dialog routines }

function FindReplaceWndProc(Wnd: HWND; Msg, WParam, LParam: Longint): Longint; stdcall;

  function CallDefWndProc: Longint;
  begin
    Result := CallWindowProc(Pointer(GetProp(Wnd,
      MakeIntAtom(WndProcPtrAtom))), Wnd, Msg, WParam, LParam);
  end;

begin
  case Msg of
    WM_DESTROY:
      if Application.DialogHandle = Wnd then Application.DialogHandle := 0;
    WM_NCACTIVATE:
      if WParam <> 0 then
      begin
        if Application.DialogHandle = 0 then Application.DialogHandle := Wnd;
      end else
      begin
        if Application.DialogHandle = Wnd then Application.DialogHandle := 0;
      end;
    WM_NCDESTROY:
      begin
        Result := CallDefWndProc;
        RemoveProp(Wnd, MakeIntAtom(WndProcPtrAtom));
        Exit;
      end;
   end;
   Result := CallDefWndProc;
end;

function FindReplaceDialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := DialogHook(Wnd, Msg, wParam, lParam);
  if Msg = WM_INITDIALOG then
  begin
    with TWFindDialog(PFindReplace(LParam)^.lCustData) do
      if (Left <> -1) or (Top <> -1) then
        SetWindowPos(Wnd, 0, Left, Top, 0, 0, SWP_NOACTIVATE or
          SWP_NOSIZE or SWP_NOZORDER);
    SetProp(Wnd, MakeIntAtom(WndProcPtrAtom), GetWindowLong(Wnd, GWL_WNDPROC));
    SetWindowLong(Wnd, GWL_WNDPROC, Longint(@FindReplaceWndProc));
    Result := 1;
  end;
end;

const
  FindOptions: array[TFindOption] of DWORD = (
    FR_DOWN, FR_FINDNEXT, FR_HIDEMATCHCASE, FR_HIDEWHOLEWORD,
    FR_HIDEUPDOWN, FR_MATCHCASE, FR_NOMATCHCASE, FR_NOUPDOWN, FR_NOWHOLEWORD,
    FR_REPLACE, FR_REPLACEALL, FR_WHOLEWORD, FR_SHOWHELP);

{ TWFindDialog }

constructor TWFindDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [frDown];
  FPosition.X := -1;
  FPosition.Y := -1;
  if Win32PlatformIsUnicode then begin
    with FFindReplaceW do
    begin
      lStructSize := SizeOf(TFindReplace);
      hWndOwner := Application.Handle;
      hInstance := SysInit.HInstance;
      lpstrFindWhat := FFindTextW;
      wFindWhatLen := SizeOf(FFindTextW);
      lpstrReplaceWith := FReplaceTextW;
      wReplaceWithLen := SizeOf(FReplaceTextW);
      lCustData := Longint(Self);
      lpfnHook := FindReplaceDialogHook;
    end;
    FFindReplaceFuncW := @CommDlg.FindTextW;
  end else begin
    with FFindReplaceA do
    begin
      lStructSize := SizeOf(TFindReplace);
      hWndOwner := Application.Handle;
      hInstance := SysInit.HInstance;
      lpstrFindWhat := FFindTextA;
      wFindWhatLen := SizeOf(FFindTextA);
      lpstrReplaceWith := FReplaceTextA;
      wReplaceWithLen := SizeOf(FReplaceTextA);
      lCustData := Longint(Self);
      lpfnHook := FindReplaceDialogHook;
    end;
    FFindReplaceFuncA := @CommDlg.FindTextA;
  end;
end;

destructor TWFindDialog.Destroy;
begin
  if FFindHandle <> 0 then SendMessage(FFindHandle, WM_CLOSE, 0, 0);
  if Assigned(FRedirector) then
    TRedirectorWindow(FRedirector).FFindReplaceDialog := nil;
  FreeAndNil(FRedirector);
  inherited Destroy;
end;

procedure TWFindDialog.CloseDialog;
begin
  if FFindHandle <> 0 then PostMessage(FFindHandle, WM_CLOSE, 0, 0);
end;

function GetTopWindow(Wnd: THandle; var ReturnVar: THandle):Bool; stdcall;
var
  Test: TWinControl;
begin
  Test := FindControl(Wnd);
  Result := True;
  if Assigned(Test) and (Test is TForm) then
  begin
    ReturnVar := Wnd;
    Result := False;
   end;
end;

function TWFindDialog.Execute: Boolean;
var
  Option: TFindOption;
begin
  if FFindHandle <> 0 then
  begin
    BringWindowToTop(FFindHandle);
    Result := True;
  end else
  begin
    if Win32PlatformIsUnicode then begin
      FFindReplaceW.Flags := FR_ENABLEHOOK;
      FFindReplaceW.lpfnHook := FindReplaceDialogHook;
    end else begin
      FFindReplaceA.Flags := FR_ENABLEHOOK;
      FFindReplaceA.lpfnHook := FindReplaceDialogHook;
    end;
    FRedirector := TRedirectorWindow.Create(nil);
    with TRedirectorWindow(FRedirector) do begin
      FFindReplaceDialog := Self;
      EnumThreadWindows(GetCurrentThreadID, @GetTopWindow, LPARAM(@FFormHandle));
    end;
    if Win32PlatformIsUnicode then begin
      FFindReplaceW.hWndOwner := FRedirector.Handle;
      for Option := Low(Option) to High(Option) do
        if Option in FOptions then
          FFindReplaceW.Flags := FFindReplaceW.Flags or FindOptions[Option];
      if TemplateW <> nil then begin
         FFindReplaceW.Flags := FFindReplaceW.Flags or FR_ENABLETEMPLATE;
         FFindReplaceW.lpTemplateName := TemplateW;
      end;
    end else begin
      FFindReplaceA.hWndOwner := FRedirector.Handle;
      for Option := Low(Option) to High(Option) do
        if Option in FOptions then
          FFindReplaceA.Flags := FFindReplaceA.Flags or FindOptions[Option];
      if TemplateA <> nil then begin
         FFindReplaceA.Flags := FFindReplaceA.Flags or FR_ENABLETEMPLATE;
         FFindReplaceA.lpTemplateName := TemplateA;
      end;
    end;
    CreationControl := Self;
    if Win32PlatformIsUnicode then
      FFindHandle := FFindReplaceFuncW(FFindReplaceW)
    else
      FFindHandle := FFindReplaceFuncA(FFindReplaceA);
    Result := FFindHandle <> 0;
  end;
end;

procedure TWFindDialog.Find;
begin
  if Assigned(FOnFind) then FOnFind(Self);
end;

function TWFindDialog.GetFindText: Widestring;
begin
  if Win32PlatformIsUnicode then
    Result := FFindTextW
  else
    Result := AnsiString(FFindTextA);
end;

function TWFindDialog.GetLeft: Integer;
begin
  Result := Position.X;
end;

function TWFindDialog.GetPosition: TPoint;
var
  Rect: TRect;
begin
  Result := FPosition;
  if FFindHandle <> 0 then
  begin
    GetWindowRect(FFindHandle, Rect);
    Result := Rect.TopLeft;
  end;
end;

function TWFindDialog.GetReplaceText: Widestring;
begin
  if Win32PlatformIsUnicode then
    Result := FReplaceTextW
  else
    Result := AnsiString(FReplaceTextA);
end;

function TWFindDialog.GetTop: Integer;
begin
  Result := Position.Y;
end;

function TWFindDialog.MessageHook(var Msg: TMessage): Boolean;
var
  Option: TFindOption;
  Rect: TRect;
  Flags: Cardinal;
  Found: boolean;
begin
  Result := inherited MessageHook(Msg);
  if not Result then
    if Msg.Msg = FindMsg then begin
      Found := false;
      Flags := 0;
      if (Win32PlatformIsUnicode and (Pointer(Msg.LParam) = @FFindReplaceW)) then begin
        Found := true;
        Flags := FFindReplaceW.Flags;
      end else if (not Win32PlatformIsUnicode and (Pointer(Msg.LParam) = @FFindReplaceA)) then begin
        Found := true;
        Flags := FFindReplaceA.Flags;
      end;
      if Found then begin
        FOptions := [];
        for Option := Low(Option) to High(Option) do
          if (Flags and FindOptions[Option]) <> 0 then
            Include(FOptions, Option);
        if (Flags and FR_FINDNEXT) <> 0 then
          Find
        else
        if (Flags and (FR_REPLACE or FR_REPLACEALL)) <> 0 then
          Replace
        else
        if (Flags and FR_DIALOGTERM) <> 0 then
        begin
          GetWindowRect(FFindHandle, Rect);
          FPosition := Rect.TopLeft;
          FFindHandle := 0;
          PostMessage(FRedirector.Handle,CM_RELEASE,0,0); // free redirector later
          FRedirector := nil;
        end;
        Result := True;
      end;
    end;
end;

procedure TWFindDialog.Replace;
begin
  if Assigned(FOnReplace) then FOnReplace(Self);
end;

procedure TWFindDialog.SetFindTextA(const Value: String);
begin
  StrLCopy(PChar(Value),FFindTextA,254);
end;

procedure TWFindDialog.SetFindText(const Value: Widestring);
var
  i, l: Integer;
begin
  l := length(Value)-1;
  if l > 254 then l := 254;
  for i := 0 to l do
    FFindTextW[i] := Value[i+1];
  FFindTextW[l+1] := #0;
  SetFindTextA(Value);
end;

procedure TWFindDialog.SetLeft(Value: Integer);
begin
  SetPosition(Point(Value, Top));
end;

procedure TWFindDialog.SetPosition(const Value: TPoint);
begin
  if (FPosition.X <> Value.X) or (FPosition.Y <> Value.Y) then
  begin
    FPosition := Value;
    if FFindHandle <> 0 then
      SetWindowPos(FFindHandle, 0, Value.X, Value.Y, 0, 0,
        SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
  end;
end;

procedure TWFindDialog.SetReplaceTextA(const Value: String);
begin
  StrLCopy(PChar(Value),FReplaceTextA,254);
end;

procedure TWFindDialog.SetReplaceText(const Value: Widestring);
var
  i, l: Integer;
begin
  l := length(Value)-1;
  if l > 254 then l := 254;
  for i := 0 to l do
    FReplaceTextW[i] := Value[i+1];
  FReplaceTextW[l+1] := #0;
  SetReplaceTextA(Value);
end;

procedure TWFindDialog.SetTop(Value: Integer);
begin
  SetPosition(Point(Left, Value));
end;

{ TWReplaceDialog }

constructor TWReplaceDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if Win32PlatformIsUnicode then
    FFindReplaceFuncW := CommDlg.ReplaceTextW
  else
    FFindReplaceFuncA := CommDlg.ReplaceTextA;
end;


procedure Register;
begin
  RegisterComponents('Tnt Dialogs', [TWFindDialog]);
  RegisterComponents('Tnt Dialogs', [TWReplaceDialog]);
end;

{ Initialization and cleanup }

procedure InitGlobals;
var
  AtomText: array[0..31] of Char;
begin
  HelpMsg := RegisterWindowMessage(HelpMsgString);
  FindMsg := RegisterWindowMessage(FindMsgString);
  WndProcPtrAtom := GlobalAddAtom(StrFmt(AtomText,
    'WndProcPtr%.8X%.8X', [HInstance, GetCurrentThreadID]));
end;

initialization
  InitGlobals;
  StartClassGroup(TControl);
  ActivateClassGroup(TControl);
  GroupDescendentsWith(TWCommonDialog, TControl);
finalization
  if WndProcPtrAtom <> 0 then GlobalDeleteAtom(WndProcPtrAtom);
end.

