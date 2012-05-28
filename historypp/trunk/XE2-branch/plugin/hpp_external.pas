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

unit hpp_external;

interface

uses
  Classes, Windows, HistoryGrid,
  m_globaldefs, m_api,
  hpp_global, hpp_database, hpp_externalgrid;

type
  TExternalGrids = class(TObject)
  private
    FGrids: array[TExGridMode] of TList;
    procedure SetGroupLinked(Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const ExtGrid: TExternalGrid; GridMode: TExGridMode);
    function Find(Handle: HWND; GridMode: TExGridMode): TExternalGrid;
    function Delete(Handle: HWND; GridMode: TExGridMode): Boolean;
    function Clear(GridMode: TExGridMode): Boolean;
    procedure Perform(Msg: Cardinal; wParam: WPARAM; lParam: LPARAM);
    property GroupLinked: Boolean write SetGroupLinked;
  end;


const
  MS_HPP_EG_WINDOW         = 'History++/ExtGrid/NewWindow';
  MS_HPP_EG_EVENT	         = 'History++/ExtGrid/Event';
  MS_HPP_EG_NAVIGATE       = 'History++/ExtGrid/Navigate';
  ME_HPP_EG_OPTIONSCHANGED = 'History++/ExtGrid/OptionsChanged';

var
  hExtWindowIE, hExtEventIE, hExtNavigateIE, hExtOptChangedIE: THandle;
  hExtWindow, hExtEvent, hExtNavigate, hExtOptChanged: THandle;
  ImitateIEView: boolean;
  ExternalGrids: TExternalGrids;

procedure RegisterExtGridServices;
procedure UnregisterExtGridServices;

implementation

function _ExtWindow(wParam:WPARAM; lParam: LPARAM; GridMode: TExGridMode): int_ptr;
var
  par: PIEVIEWWINDOW;
  ExtGrid: TExternalGrid;
  ControlId: Cardinal;
begin
  Result := 0;
  //try
    par := PIEVIEWWINDOW(lParam);
    Assert(par <> nil, 'Empty IEVIEWWINDOW structure');
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
        ExtGrid := TExternalGrid.Create(par.Parent,ControlID);
        case par.dwMode of
          IEWM_MUCC,IEWM_CHAT: begin
            ExtGrid.ShowHeaders   := False;
            ExtGrid.GroupLinked   := False;
            ExtGrid.ShowBookmarks := False;
          end;
          IEWM_HISTORY:
            ExtGrid.GroupLinked := False;
        end;
        ExtGrid.SetPosition(par.x,par.y,par.cx,par.cy);
        ExternalGrids.Add(ExtGrid,GridMode);
        par.Hwnd := ExtGrid.GridHandle;
      end;
      IEW_DESTROY: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_DESTROY');
        {$ENDIF}
        ExternalGrids.Delete(par.Hwnd,GridMode);
      end;
      IEW_SETPOS: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_SETPOS');
        {$ENDIF}
        ExtGrid := ExternalGrids.Find(par.Hwnd,GridMode);
        if ExtGrid <> nil then
          ExtGrid.SetPosition(par.x,par.y,par.cx,par.cy);
      end;
      IEW_SCROLLBOTTOM: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_SCROLLBOTTOM');
        {$ENDIF}
        ExtGrid := ExternalGrids.Find(par.Hwnd,GridMode);
        if ExtGrid <> nil then
          ExtGrid.ScrollToBottom;
      end;
    end;
  //except
  //end;
end;

function ExtWindowNative(wParam:WPARAM; lParam: LPARAM): int_ptr; cdecl;
begin
  Result := _ExtWindow(wParam,lParam,gmNative);
end;

function ExtWindowIEView(wParam:WPARAM; lParam: LPARAM): int_ptr; cdecl;
begin
  Result := _ExtWindow(wParam,lParam,gmIEView);
end;

function _ExtEvent(wParam:WPARAM; lParam: LPARAM; GridMode: TExGridMode): int_ptr; cdecl;
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
  //try
    {$IFDEF DEBUG}
    OutputDebugString('MS_IEVIEW_EVENT');
    {$ENDIF}
    event := PIEVIEWEVENT(lParam);
    Assert(event <> nil, 'Empty IEVIEWEVENT structure');
    ExtGrid := ExternalGrids.Find(event.Hwnd,GridMode);
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
        while (eventCount <> 0) and (hDBNext <> 0) do
        begin
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
        while (eventCount <> 0) and (customEvent <> nil) do
        begin
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
      IEE_SAVE_DOCUMENT: begin
        ExtGrid.SaveSelected;
      end;
    end;
  //except
  //end;
end;

function ExtEventNative(wParam:WPARAM; lParam: LPARAM): int_ptr; cdecl;
begin
  Result := _ExtEvent(wParam,lParam,gmNative);
end;

function ExtEventIEView(wParam:WPARAM; lParam: LPARAM): int_ptr; cdecl;
begin
  Result := _ExtEvent(wParam,lParam,gmIEView);
end;

function ExtNavigate(wParam:WPARAM; lParam: LPARAM): int_ptr; cdecl;
begin
  Result := 0;
  //try
    {$IFDEF DEBUG}
    OutputDebugString('MS_IEVIEW_NAVIGATE');
    {$ENDIF}
  //except
  //end;
end;

procedure RegisterExtGridServices;
begin
  ExternalGrids := TExternalGrids.Create;
  ImitateIEView := GetDBBool(hppDBName,'IEViewAPI',false);
  if ImitateIEView then
  begin
    hExtWindowIE     := PluginLink.CreateServiceFunction(MS_IEVIEW_WINDOW,ExtWindowIEView);
    hExtEventIE      := PluginLink.CreateServiceFunction(MS_IEVIEW_EVENT,ExtEventIEView);
    hExtNavigateIE   := PluginLink.CreateServiceFunction(MS_IEVIEW_NAVIGATE,ExtNavigate);
    hExtOptChangedIE := PluginLink.CreateHookableEvent(ME_IEVIEW_OPTIONSCHANGED);
  end;
  hExtWindow     := PluginLink.CreateServiceFunction(MS_HPP_EG_WINDOW,ExtWindowNative);
  hExtEvent      := PluginLink.CreateServiceFunction(MS_HPP_EG_EVENT,ExtEventNative);
  hExtNavigate   := PluginLink.CreateServiceFunction(MS_HPP_EG_NAVIGATE,ExtNavigate);
  hExtOptChanged := PluginLink.CreateHookableEvent(ME_HPP_EG_OPTIONSCHANGED);
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
  ExternalGrids.Destroy;
end;

constructor TExternalGrids.Create;
var
  GridMode: TExGridMode;
begin
  for GridMode := Low(TExGridMode) to High(TExGridMode) do
    FGrids[GridMode] := TList.Create;
end;

destructor TExternalGrids.Destroy;
var
  GridMode: TExGridMode;
begin
  for GridMode := Low(TExGridMode) to High(TExGridMode) do begin
    Clear(GridMode);
    FGrids[GridMode].Free;
  end;
  inherited;
end;

procedure TExternalGrids.Add(const ExtGrid: TExternalGrid; GridMode: TExGridMode);
begin
  FGrids[GridMode].Add(ExtGrid);
end;

function TExternalGrids.Find(Handle: HWND; GridMode: TExGridMode): TExternalGrid;
var
  i: Integer;
  ExtGrid: TExternalGrid;
begin
  Result := nil;
  for i := 0 to FGrids[GridMode].Count-1 do
  begin
    ExtGrid := TExternalGrid(FGrids[GridMode].Items[i]);
    if ExtGrid.GridHandle = Handle then
    begin
      Result := ExtGrid;
      break;
    end;
  end;
end;

function TExternalGrids.Delete(Handle: HWND; GridMode: TExGridMode): Boolean;
var
  i: Integer;
  ExtGrid: TExternalGrid;
begin
  Result := True;
  for i := 0 to FGrids[GridMode].Count-1 do
  begin
    ExtGrid := TExternalGrid(FGrids[GridMode].Items[i]);
    if ExtGrid.GridHandle = Handle then
    begin
      try
        ExtGrid.Free;
      except
        Result := False;
      end;
      FGrids[GridMode].Delete(i);
      break;
    end;
  end;
end;

function TExternalGrids.Clear(GridMode: TExGridMode): Boolean;
var
  i: Integer;
  ExtGrid: TExternalGrid;
begin
  Result := True;
  for i := 0 to FGrids[GridMode].Count-1 do
  begin
    ExtGrid := TExternalGrid(FGrids[GridMode].Items[i]);
    try
      ExtGrid.Free;
    except
      Result := False;
    end;
  end;
  FGrids[GridMode].Clear;
end;

procedure TExternalGrids.Perform(Msg: Cardinal; wParam: WPARAM; lParam: LPARAM);
var
  i: Integer;
  GridMode: TExGridMode;
begin
  for GridMode := Low(TExGridMode) to High(TExGridMode) do
    for i := FGrids[GridMode].Count-1 downto 0 do
      TExternalGrid(FGrids[GridMode].Items[i]).Perform(Msg,wParam,lParam);
end;

procedure TExternalGrids.SetGroupLinked(Value: Boolean);
var
  i: Integer;
  GridMode: TExGridMode;
begin
  for GridMode := Low(TExGridMode) to High(TExGridMode) do
    for i := FGrids[GridMode].Count-1 downto 0 do
      TExternalGrid(FGrids[GridMode].Items[i]).GroupLinked := Value;
end;

end.
