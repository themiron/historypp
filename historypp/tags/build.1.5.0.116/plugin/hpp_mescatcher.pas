(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (‘) 2006-2007 theMIROn, 2003-2006 Art Fedorov.
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

 Contributors: theMIROn
-----------------------------------------------------------------------------}

unit hpp_mescatcher;

interface

{$I compilers.inc}

uses
  Windows, Messages, Classes, Controls, Forms, Themes;

const
  hppMCWindowClassName = 'hppMessageCatcher';

procedure hppWakeMainThread(Sender: TObject);
function hppRegisterMessagesCatcher: Boolean;
function hppUnregisterMessagesCatcher: Boolean;

implementation

var
  MCWindow: HWND = 0;
  SavedWakeMainThread: TNotifyEvent = nil;

function MessageCatcherWndProc(hwndDlg: HWND; uMsg: Integer; wParam: WPARAM; lParam: LPARAM): Integer; stdcall;
begin
  Result := 0;
  case uMsg of
    // place for global hotkeys :)
    {WM_HOTKEY: begin
      if wParam = Hotkey then
        PluginLink.CallService(MS_HPP_SHOWGLOBALSEARCH,0,0);
    end;}
    WM_SETTINGCHANGE: begin
      Mouse.SettingChanged(wParam);
      Result := DefWindowProc(hwndDlg, uMsg, wParam, lParam);
    end;
    WM_FONTCHANGE: begin
      Screen.ResetFonts;
      Result := DefWindowProc(hwndDlg, uMsg, wParam, lParam);
    end;
    WM_THEMECHANGED:
      ThemeServices.ApplyThemeChange;
    WM_NULL:
      CheckSynchronize;
    else
      Result := DefWindowProc(hwndDlg, uMsg, wParam, lParam);
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
  if Result then begin
    SavedWakeMainThread := Classes.WakeMainThread;
    @Classes.WakeMainThread := @hppWakeMainThread;
  end;
end;

function hppUnregisterMessagesCatcher: Boolean;
begin
  if MCWindow <> 0 then begin
    DestroyWindow(MCWindow);
    MCWindow := 0;
  end;
  Result := Boolean(Windows.UnregisterClass(hppMCWindowClassName,GetModuleHandle(nil)));
  Classes.WakeMainThread := SavedWakeMainThread;
end;

procedure hppWakeMainThread(Sender: TObject);
begin
  PostMessage(MCWindow, WM_NULL, 0, 0);
  if Assigned(SavedWakeMainThread) then
    SavedWakeMainThread(Sender);
end;

end.
