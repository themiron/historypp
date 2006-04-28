{-----------------------------------------------------------------------------
 hpp_services (historypp project)

 Version:   1.5
 Created:   05.08.2004
 Author:    Oxygen

 [ Description ]

 Module with history's own services

 [ History ]

 1.5 (05.08.2004)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) Art Fedorov, 2004
-----------------------------------------------------------------------------}

unit hpp_services;

interface

uses
  Classes, Windows,
  m_globaldefs, m_api,
  hpp_options,
  HistoryForm;


var
  hHppRichEditItemProcess,
  hAllHistoryRichEditProcess,
  hHppGetVersion,
  hHppShowGlobalSearch,
  hHppOpenHistoryEvent: THandle;
  HstWindowList:TList;

  procedure hppRegisterServices;
  procedure hppUnregisterServices;

  procedure CloseGlobalSearchWindow;
  procedure CloseHistoryWindows;
  function FindContactWindow(hContact: THandle): THistoryFrm;
  function OpenContactHistory(hContact: THandle; index: integer = -1): THistoryFrm;

  function AllHistoryRichEditProcess(wParam, lParam: DWord): Integer; cdecl;

implementation

uses
  {Dialogs, }GlobalSearch, hpp_global, hpp_itemprocess;

// our own processing of RichEdit for all history windows
function AllHistoryRichEditProcess(wParam{hRichEdit}, lParam{PItemRenderDetails}: DWord): Integer; cdecl;
begin

  // first bbcodes, then smileys, should fix freezes, when smile is inside bbcode
  if GridOptions.BBCodesEnabled then
    DoSupportBBCodes(wParam,lParam);

  if GridOptions.SmileysEnabled then
    DoSupportSmileys(wParam,lParam);

  if GridOptions.MathModuleEnabled then
    DoSupportMathModule(wParam,lParam);
    
  Result := 0;
end;

procedure CloseHistoryWindows;
var
  i: Integer;
begin
  try
    for i := 0 to HstWindowList.Count-1 do
      THistoryFrm(HstWindowList[i]).Free;
  except
  end;
end;

procedure CloseGlobalSearchWindow;
begin
  if Assigned(fmGlobalSearch) then begin
    fmGlobalSearch.Free;
  end;
end;

function FindContactWindow(hContact: THandle): THistoryFrm;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to HstWindowList.Count-1 do begin
    if THistoryFrm(HstWindowList[i]).hContact = hContact then begin
      Result := THistoryFrm(HstWindowList[i]);
      exit;
      end;
    end;
end;

function OpenContactHistory(hContact: THandle; index: integer = -1): THistoryFrm;
var
  wHistory: THistoryFrm;
  Lock: Boolean;
  r: TRect;
begin
  //check if window exists, otherwise create one
  wHistory := FindContactWindow(hContact);
  if not Assigned(wHistory) then begin
    wHistory := THistoryFrm.Create(nil);
    HstWindowList.Add(wHistory);
    wHistory.WindowList := HstWindowList;
    wHistory.hg.Options := GridOptions;
    wHistory.hContact := hContact;
    wHistory.Load;

    Lock := LockWindowUpdate(wHistory.Handle);
    try
      if index <> -1 then
        wHistory.hg.Selected := index
      else begin
        if wHistory.hg.Count > 0 then
          wHistory.hg.Selected := 0;
      end;
      //wHistory.hg.EndUpdate;
      //if not wHistory.PasswordMode then
      //  wHistory.hg.PrePaintWindow;
      wHistory.Show;
    finally
      if Lock then LockWindowUpdate(0);
    end;
  end else begin
    wHistory.ShowAllEvents;
    if index <> -1 then wHistory.hg.Selected := index;
    // restore even if minimized
    // and we ain't have no double hooks
    ShowWindow(wHistory.Handle,SW_SHOWNORMAL);
    wHistory.BringToFront;
  end;
  Result := wHistory;
end;

// MS_HISTORY_SHOWCONTACTHISTORY service
// show history called by miranda
function OnHistoryShow(wParam{hContact},lParam{0}: DWord): Integer; cdecl;
begin
  OpenContactHistory(wParam);
  Result:=0;
end;

// MS_HPP_GETVERSION service
// See m_historypp.inc for details
function HppGetVersion(wParam{0}, lParam{0}: DWord): Integer; cdecl;
begin
  Result := hppVersion;
end;

// MS_HPP_SHOWGLOBALSEARCH service
// See m_historypp.inc for details
function HppShowGlobalSearch(wParam{0}, lParam{0}: DWord): Integer; cdecl;
begin
  if not Assigned(fmGlobalSearch) then begin
    fmGlobalSearch := TfmGlobalSearch.Create(nil);
    fmGlobalSearch.Show;
  end;
  ShowWindow(fmGlobalSearch.Handle,SW_SHOWNORMAL);
  fmGlobalSearch.BringToFront;
  Result := 0;
end;

// MS_HPP_OPENHISTORYEVENT service
// See m_historypp.inc for details
function HppOpenHistoryEvent(wParam{hDBEvent}, lParam{hContact}: DWord): Integer; cdecl;
var
  hContact: THandle;
  wHistory: THistoryFrm;
  hDbEvent,item,sel: Integer;
begin
  // first, let's get contact
  // WHAT THE F*CK? Why this service always return ZERO?
  // Because of that I had to change API to include hContact!
  // DAMN!
  //hContact := PluginLink.CallService(MS_DB_EVENT_GETCONTACT, wParam,0);
  hContact := lParam;

  //PluginLink.CallService(MS_HISTORY_SHOWCONTACTHISTORY,hContact,0);
  //wHistory := FindContactWindow(hContact);

  hDbEvent := PluginLink.CallService(MS_DB_EVENT_FINDLAST,hContact,0);
  item := 0;
  sel := -1;
  while (hDbEvent <> wParam) and (hDbEvent <> 0) do begin
    hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDbEvent,0);
    inc(item);
  end;
  if hDbEvent = wParam then sel := item;

  wHistory := OpenContactHistory(hContact,sel);

  // if we have password prompt -- remove
  wHistory.PasswordMode := False;
  // and find the item
  //item := wHistory.hg.SearchItem(wParam);
  // make it selected

  Result := 0;
end;

procedure hppRegisterServices;
begin
  HstWindowList := TList.Create;
  PluginLink.CreateServiceFunction(MS_HISTORY_SHOWCONTACTHISTORY,OnHistoryShow);
  hHppGetVersion := PluginLink.CreateServiceFunction(MS_HPP_GETVERSION,HppGetVersion);
  hHppShowGlobalSearch := PluginLink.CreateServiceFunction(MS_HPP_SHOWGLOBALSEARCH,HppShowGlobalSearch);
  hHppOpenHistoryEvent := PluginLink.CreateServiceFunction(MS_HPP_OPENHISTORYEVENT,HppOpenHistoryEvent);
  hHppRichEditItemProcess := PluginLink.CreateHookableEvent(ME_HPP_RICHEDIT_ITEMPROCESS);
  hAllHistoryRichEditProcess := PluginLink.HookEvent(ME_HPP_RICHEDIT_ITEMPROCESS,AllHistoryRichEditProcess);
end;

procedure hppUnregisterServices;
begin
  PluginLink.UnhookEvent(hAllHistoryRichEditProcess);
  PluginLink.DestroyServiceFunction(hHppGetVersion);
  PluginLink.DestroyServiceFunction(hHppShowGlobalSearch);
  PluginLink.DestroyServiceFunction(hHppOpenHistoryEvent);
  PluginLink.DestroyHookableEvent(hHppRichEditItemProcess);
  CloseHistoryWindows;
  HstWindowList.Free;
  CloseGlobalSearchWindow;
end;

end.
