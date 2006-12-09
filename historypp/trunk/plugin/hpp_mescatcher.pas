{-----------------------------------------------------------------------------
 hpp_mescatcher (historypp project)

 Version:   1.0
 Created:   09.12.2006
 Author:    theMIROn

 [ Description ]

 Hidden window, used for catching WM messages and hotkeys

 [ History ]

 1.0 (09.12.2006)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) theMIROn, 2006
-----------------------------------------------------------------------------}

unit hpp_mescatcher;

interface

{$I compilers.inc}

uses
  Windows, Messages, Controls, Forms, Themes;

const
  hppMCWindowClassName = 'hppMessageCatcher';

function hppRegisterMessagesCatcher: Boolean;
function hppUnregisterMessagesCatcher: Boolean;

implementation

var
  MCWindow: HWND;

function MessageCatcherWndProc(hwndDlg: HWND; uMsg: Integer; wParam: WPARAM; lParam: LPARAM): Integer; stdcall;
begin
  Result := 1;
  case uMsg of
    // place for global hotkeys :)
    {WM_HOTKEY: begin
      if wParam = Hotkey then
        PluginLink.CallService(MS_HPP_SHOWGLOBALSEARCH,0,0);
    end;}
    WM_SETTINGCHANGE:
      Mouse.SettingChanged(wParam);
    WM_FONTCHANGE:
      Screen.ResetFonts;
    WM_THEMECHANGED: begin
      ThemeServices.ApplyThemeChange;
      Result := 0;
    end;
  end;
end;

function hppRegisterMessagesCatcher: Boolean;
var
  WndClass: TWNDCLASS;
begin
  Result := False;
  ZeroMemory(@WndClass,SizeOf(WndClass));
  WndClass.lpfnWndProc   := @MessageCatcherWndProc;
  WndClass.hInstance     := GetModuleHandle(nil);
  WndClass.lpszClassName := hppMCWindowClassName;
  if Windows.RegisterClass(WndClass) = 0 then exit;
  MCWindow := CreateWindow(hppMCWindowClassName,'hppMessageCatcher',WS_DISABLED,
              0,0,0,0,0,0,WndClass.hInstance,nil);
  Result := (MCWindow <> 0);
end;

function hppUnregisterMessagesCatcher: Boolean;
begin
  if MCWindow <> 0 then begin
    DestroyWindow(MCWindow);
    MCWindow := 0;
  end;
  Result := Boolean(Windows.UnregisterClass(hppMCWindowClassName,GetModuleHandle(nil)));
end;

end.
