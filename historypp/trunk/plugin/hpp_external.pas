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

unit hpp_external;

interface

uses
  Windows, HistoryGrid, m_globaldefs, m_api, hpp_global, hpp_database, hpp_externalgrid;

const
  MS_HPP_EG_WINDOW         = 'History++/ExtGrid/NewWindow';
  MS_HPP_EG_EVENT	         = 'History++/ExtGrid/Event';
  MS_HPP_EG_NAVIGATE       = 'History++/ExtGrid/Navigate';
  MS_HPP_EG_OPTIONSCHANGED = 'History++/ExtGrid/OptionsChanged';

var
  hExtWindowIE, hExtEventIE, hExtNavigateIE, hExtOptChangedIE: THandle;
  hExtWindow, hExtEvent, hExtNavigate, hExtOptChanged: THandle;
  ImitateIEView: boolean;
  ExternalGrids: array of TExternalGrid;

function FindExtGridByHandle(var Handle: HWND): TExternalGrid;
function DeleteExtGridByHandle(var Handle: HWND): Boolean;
function DeleteExtGrids: Boolean;

procedure RegisterExtGridServices;
procedure UnregisterExtGridServices;

implementation

function _ExtWindow(wParam, lParam: DWord; GridMode: TExGridMode): Integer;
var
  par: PIEVIEWWINDOW;
  ExtGrid: TExternalGrid;
  n: Integer;
  ControlId: Cardinal;
begin
  Result := 0;
  try
    par := PIEVIEWWINDOW(lParam);
    case par.iType of
      IEW_CREATE: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_CREATE');
        {$ENDIF}
        case par.dwMode of
          IEWM_TABSRMM: ControlID := 1006;  // IDC_LOG from tabSRMM
          IEWM_SCRIVER: ControlID := 1001;  // IDC_LOG from Scriver
          IEWM_MUCC:    ControlID := 0;
          IEWM_CHAT:    ControlID := 0;
          IEWM_HISTORY: ControlID := 0;
        else            ControlID := 0;
        end;
        n := Length(ExternalGrids);
        SetLength(ExternalGrids,n+1);
        ExternalGrids[n] := TExternalGrid.Create(par.Parent,ControlID);
        ExternalGrids[n].GridMode := GridMode;
        case par.dwMode of
          IEWM_MUCC,IEWM_CHAT: begin
            ExternalGrids[n].ShowHeaders := False;
            ExternalGrids[n].GroupLinked := False;
            ExternalGrids[n].ShowBookmarks := False;
          end;
          IEWM_HISTORY:
            ExternalGrids[n].GroupLinked := False;
        end;
        ExternalGrids[n].SetPosition(par.x,par.y,par.cx,par.cy,False);
        par.Hwnd := ExternalGrids[n].GridHandle;
      end;
      IEW_DESTROY: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_DESTROY');
        {$ENDIF}
        DeleteExtGridByHandle(par.Hwnd);
      end;
      IEW_SETPOS: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_SETPOS');
        {$ENDIF}
        ExtGrid := FindExtGridByHandle(par.Hwnd);
        if ExtGrid <> nil then
          ExtGrid.SetPosition(par.x,par.y,par.cx,par.cy);
      end;
      IEW_SCROLLBOTTOM: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_SCROLLBOTTOM');
        {$ENDIF}
        ExtGrid := FindExtGridByHandle(par.Hwnd);
        if ExtGrid <> nil then
          ExtGrid.ScrollToBottom;
      end;
    end;
  except
  end;
end;

function ExtWindowNative(wParam, lParam: DWord): Integer; cdecl;
begin
  Result := _ExtWindow(wParam,lParam,gmNative);
end;

function ExtWindowIEView(wParam, lParam: DWord): Integer; cdecl;
begin
  Result := _ExtWindow(wParam,lParam,gmIEView);
end;

function ExtEvent(wParam, lParam: DWord): Integer; cdecl;
var
  event: PIEVIEWEVENT;
  customEvent: PIEVIEWEVENTDATA;
  UsedCodepage: Cardinal;
  hDBNext: THandle;
  eventCount: Integer;
  ExtGrid: TExternalGrid;
  CustomItem: TExtCustomItem;
begin
  Result := 0;
  try
    {$IFDEF DEBUG}
    OutputDebugString('MS_IEVIEW_EVENT');
    {$ENDIF}
    event := PIEVIEWEVENT(lParam);
    ExtGrid := FindExtGridByHandle(event.Hwnd);
    if ExtGrid = nil then exit;
    case event.iType of
      IEE_LOG_DB_EVENTS: begin
        if event.cbSize >= IEVIEWEVENT_SIZE_V2 then
          UsedCodepage := event.Codepage
        else
          UsedCodepage := CP_ACP;
        eventCount := event.Count;
        hDBNext := event.data.hDBEventFirst;
        ExtGrid.BeginUpdate;
        while (eventCount <> 0) and (hDBNext <> 0) do begin
          ExtGrid.AddEvent(event.hContact, hDBNext, UsedCodepage,
                           boolean(event.dwFlags and IEEF_RTL),
                           not boolean(event.dwFlags and IEEF_NO_SCROLLING));
          if eventCount > 0 then Dec(eventCount);
          if eventCount <> 0 then
            hDBNext := PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBNext,0);
        end;
        ExtGrid.EndUpdate;
      end;
      IEE_LOG_MEM_EVENTS: begin
        if event.cbSize >= IEVIEWEVENT_SIZE_V2 then
          UsedCodepage := event.Codepage
        else
          UsedCodepage := CP_ACP;
        eventCount := event.Count;
        customEvent := event.data.eventData;
        ExtGrid.BeginUpdate;
        while (eventCount <> 0) and (customEvent <> nil) do begin
          if boolean(customEvent.dwFlags and IEEDF_UNICODE_TEXT) then
            SetString(CustomItem.Text,customEvent.pszText.w,lstrlenW(customEvent.pszText.w))
          else
            CustomItem.Text := AnsiToWideString(AnsiString(customEvent.pszText.a),UsedCodepage);
          if boolean(customEvent.dwFlags and IEEDF_UNICODE_NICK) then
            SetString(CustomItem.Nick,customEvent.pszNick.w,lstrlenW(customEvent.pszNick.w))
          else
            CustomItem.Nick := AnsiToWideString(AnsiString(customEvent.pszNick.a),UsedCodepage);
          CustomItem.Sent := boolean(customEvent.bIsMe);
          CustomItem.Time := customEvent.time;
          ExtGrid.AddCustomEvent(event.hContact, CustomItem, UsedCodepage,
                             boolean(event.dwFlags and IEEF_RTL),
                             not boolean(event.dwFlags and IEEF_NO_SCROLLING));
          if eventCount > 0 then Dec(eventCount);
          customEvent := customEvent.next;
        end;
        ExtGrid.EndUpdate;
      end;
      IEE_CLEAR_LOG: begin
        ExtGrid.BeginUpdate;
        ExtGrid.Clear;
        ExtGrid.EndUpdate;
      end;
      IEE_GET_SELECTION: begin
        Result := integer(ExtGrid.GetSelection(boolean(event.dwFlags and IEEF_NO_UNICODE)));
      end;
    end;
  except
  end;
end;

function ExtNavigate(wParam, lParam: DWord): Integer; cdecl;
begin
  Result := 0;
  try
    {$IFDEF DEBUG}
    OutputDebugString('MS_IEVIEW_NAVIGATE');
    {$ENDIF}
  except
  end;
end;

procedure RegisterExtGridServices;
begin
  ImitateIEView := GetDBBool(hppDBName,'IEViewAPI',false);
  if ImitateIEView then begin
    hExtWindowIE := PluginLink.CreateServiceFunction(MS_IEVIEW_WINDOW,ExtWindowIEView);
    hExtEventIE := PluginLink.CreateServiceFunction(MS_IEVIEW_EVENT,ExtEvent);
    hExtNavigateIE := PluginLink.CreateServiceFunction(MS_IEVIEW_NAVIGATE,ExtNavigate);
    hExtOptChangedIE := PluginLink.CreateHookableEvent(ME_IEVIEW_OPTIONSCHANGED);
  end;
  hExtWindow := PluginLink.CreateServiceFunction(MS_HPP_EG_WINDOW,ExtWindowNative);
  hExtEvent := PluginLink.CreateServiceFunction(MS_HPP_EG_EVENT,ExtEvent);
  hExtNavigate := PluginLink.CreateServiceFunction(MS_HPP_EG_NAVIGATE,ExtNavigate);
  hExtOptChanged := PluginLink.CreateHookableEvent(MS_HPP_EG_OPTIONSCHANGED);
end;

procedure UnregisterExtGridServices;
begin
  if ImitateIEView then begin
    PluginLink.DestroyServiceFunction(hExtWindowIE);
    PluginLink.DestroyServiceFunction(hExtEventIE);
    PluginLink.DestroyServiceFunction(hExtNavigateIE);
    PluginLink.DestroyHookableEvent(hExtOptChangedIE);
  end;
  PluginLink.DestroyServiceFunction(hExtWindow);
  PluginLink.DestroyServiceFunction(hExtEvent);
  PluginLink.DestroyServiceFunction(hExtNavigate);
  PluginLink.DestroyHookableEvent(hExtOptChanged);
  DeleteExtGrids;
end;

function FindExtGridByHandle(var Handle: HWND): TExternalGrid;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Length(ExternalGrids) - 1 do begin
    if ExternalGrids[i].GridHandle = Handle then begin
      Result := ExternalGrids[i];
      break;
    end;
  end;
end;

function DeleteExtGridByHandle(var Handle: HWND): Boolean;
var
  i,n: Integer;
begin
  Result := False;
  n := -1;
  for i := 0 to Length(ExternalGrids) - 1 do begin
    if ExternalGrids[i].GridHandle = Handle then begin
      n := i;
      break;
    end;
  end;
  if n = -1 then exit;
  ExternalGrids[n].Free;
  for i := n to Length(ExternalGrids) - 2 do begin
    ExternalGrids[i] := ExternalGrids[i+1];
  end;
  SetLength(ExternalGrids,Length(ExternalGrids)-1);
  Result := True;
end;

function DeleteExtGrids: Boolean;
var
  i: Integer;
begin
  Result := True;
  try
    for i := 0 to Length(ExternalGrids) - 1 do
      ExternalGrids[i].Free;
  except
    Result := False;
  end;
end;


end.
