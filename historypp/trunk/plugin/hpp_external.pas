unit hpp_external;

interface

{$DEFINE IMITATE_IEVIEW}

uses
  Windows, HistoryGrid, m_globaldefs, m_api;

type

  IEVIEWWINDOW = packed record
    cbSize: Integer;  // size of the strusture
    iType: Integer;   // one of IEW_* values
    dwMode: DWord;    // compatibility mode - one of IEWM_* values
    dwFlags: DWord;   // flags, one of IEWF_* values
    Parent: HWND;     // parent window HWND
    Hwnd: HWND;       // IEW_CREATE returns WebBrowser control's HWND here
    x: Integer;       // IE control horizontal position
    y: Integer;       // IE control vertical position
    cx: Integer;      // IE control horizontal size
    cy: Integer;      // IE control vertical size
  end;

  PIEVIEWWINDOW = ^IEVIEWWINDOW;

  IEVIEWEVENT = record
    cbSize: Integer;        // size of the strusture
    iType: Integer;         // one of IEE_* values
    dwFlags: DWord;         // one of IEEF_* values
    Hwnd: HWND;             // HWND returned by IEW_CREATE
    hContact: THandle;      // contact
    hDBEventFirst: THandle; // first event to log, when IEE_LOG_EVENTS returns it will contain
                            // the last event actually logged or NULL if no event was logged (IEE_LOG_EVENTS)
    Count: Integer;         // number of events to log
    Codepage: Integer;      // ANSI codepage
    pszProto: PChar;        // Name of the protocol
  end;

  PIEVIEWEVENT = ^IEVIEWEVENT;
  
  (*typedef struct {
	union {
		HANDLE 		hDbEventFirst;      /

		IEVIEWEVENTDATA *eventData;	    // the pointer to an array of IEVIEWEVENTDATA objects (IEE_LOG_IEV_EVENTS)
	};
} IEVIEWEVENT; *)
const
  IEW_CREATE       = 1; // create new window (control)
  IEW_DESTROY      = 2; // destroy control
  IEW_SETPOS       = 3; // set window position and size
  IEW_SCROLLBOTTOM = 4; // scroll text to bottom

  IEE_LOG_DB_EVENTS  = 1; // log specified number of DB events
  IEE_CLEAR_LOG	     = 2; // clear log
  IEE_GET_SELECTION	 = 3; // get selected text
  IEE_SAVE_DOCUMENT	 = 4; // save current document
  IEE_LOG_MEM_EVENTS = 5; // log specified number of IEView events

  IEEF_RTL          = 1; // turn on RTL support
  IEEF_NO_UNICODE   = 2; // disable Unicode support
  IEEF_NO_SCROLLING = 4; // do not scroll logs to bottom
  
const
  MS_IEVIEW_WINDOW = 'IEVIEW/NewWindow';
  MS_IEVIEW_EVENT	 = 'IEVIEW/Event';
  MS_IEVIEW_UTILS  = 'IEVIEW/Utils';

  ME_IEVIEW_OPTIONSCHANGED = 'IEVIEW/OptionsChanged';
  ME_IEVIEW_NOTIFICATION   = 'IEVIEW/Notification';

var
  hExtWindow, hExtEvent, hExtUtils: THandle;
  hExtOptChanged, hExtNotification: THandle;

procedure RegisterExtGridServices;
procedure UnregisterExtGridServices;

implementation

uses hpp_externalgrid;

function ExtWindow(wParam, lParam: DWord): Integer; cdecl;
var
  par: PIEVIEWWINDOW;
  grid: TExternalGrid;
  i,n: Integer;
begin
  try
    par := PIEVIEWWINDOW(lParam);
    if par.iType = IEW_CREATE then begin
      OutputDebugString('IEW_CREATE');
      n := Length(ExternalGrids);
      SetLength(ExternalGrids,n+1);
      ExternalGrids[n] := TExternalGrid.Create(par.Parent);
      par.Hwnd := ExternalGrids[n].GridHandle;
    end
    else if par.iType = IEW_DESTROY then begin
      OutputDebugString('IEW_DESTROY');
      DeleteExtGridByHandle(par.Hwnd);
    end
    else if par.iType = IEW_SETPOS then begin
      OutputDebugString('IEW_SETPOS');
      grid := FindExtGridByHandle(par.Hwnd);
      grid.SetPosition(par.x,par.y,par.cx,par.cy);
    end
    else if par.iType = IEW_SCROLLBOTTOM then begin
      OutputDebugString('IEW_SCROLLBOTTOM');
      grid := FindExtGridByHandle(par.Hwnd);
      grid.ScrollToBottom;
    end;
    Result := 0;
  except
    Result := 1;
  end;
end;

function ExtEvent(wParam, lParam: DWord): Integer; cdecl;
var
  event: PIEVIEWEVENT;
  hDBNext: THandle;
  i,n: Integer;
  grid: TExternalGrid;
begin
  try
    OutputDebugString('MS_IEVIEW_EVENT');
    event := PIEVIEWEVENT(lParam);
    grid := FindExtGridByHandle(event.Hwnd);
    if event.iType = IEE_LOG_DB_EVENTS then begin
      if event.Count = -1 then begin
        hDBNext := event.hDBEventFirst;
        while hDBNext <> 0 do begin
          grid.AddEvent(event.hContact, hDBNext, event.Codepage, boolean(event.dwFlags and IEEF_RTL));
          hDBNext := PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBNext,0);
        end
      end
      else begin
        hDBNext := event.hDBEventFirst;
        for i := 0 to event.count - 1 do begin
          if hDBNext = 0 then break;
          grid.AddEvent(event.hContact, hDBNext, event.Codepage, boolean(event.dwFlags and IEEF_RTL));
          if i < event.count -1 then
            hDBNext := PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBNext,0);
        end;
      end;
    end
    else if event.iType = IEE_CLEAR_LOG then begin
      grid.Clear;
      Result := 1;
    end
    else if event.iType = IEE_GET_SELECTION then begin
      Result := integer(grid.GetSelection(boolean(event.dwFlags and IEEF_NO_UNICODE)));
    end
    else
      Result := 0;
  except
    Result := 1;
  end;
end;

function ExtUtils(wParam, lParam: DWord): Integer; cdecl;
begin
  try
    OutputDebugString('MS_IEVIEW_UTILS');
    Result := 0;
  except
    Result := 1;
  end;
end;

procedure RegisterExtGridServices;
begin
  {$IFDEF IMITATE_IEVIEW}
  hExtWindow := PluginLink.CreateServiceFunction(MS_IEVIEW_WINDOW,ExtWindow);
  hExtEvent := PluginLink.CreateServiceFunction(MS_IEVIEW_EVENT,ExtEvent);
  hExtUtils := PluginLink.CreateServiceFunction(MS_IEVIEW_UTILS,ExtUtils);
  hExtOptChanged := PluginLink.CreateHookableEvent(ME_IEVIEW_OPTIONSCHANGED);
  hExtNotification := PluginLink.CreateHookableEvent(ME_IEVIEW_NOTIFICATION);
  {$ENDIF}
end;

procedure UnregisterExtGridServices;
begin
  {$IFDEF IMITATE_IEVIEW}
  PluginLink.DestroyServiceFunction(hExtWindow);
  PluginLink.DestroyServiceFunction(hExtEvent);
  PluginLink.DestroyServiceFunction(hExtUtils);
  PluginLink.DestroyHookableEvent(hExtOptChanged);
  PluginLink.DestroyHookableEvent(hExtNotification);
  {$ENDIF}
end;

end.
