unit hpp_external;

interface

{$DEFINE _IMITATE_IEVIEW}

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
{$IFDEF _IMITATE_IEVIEW}
  MS_HPP_IE_WINDOW = 'IEVIEW/NewWindow';
  MS_HPP_IE_EVENT	 = 'IEVIEW/Event';
  MS_HPP_IE_UTILS  = 'IEVIEW/Utils';
  MS_HPP_IE_OPTIONSCHANGED = 'IEVIEW/OptionsChanged';
  MS_HPP_IE_NOTIFICATION   = 'IEVIEW/Notification';
{$ELSE}
  MS_HPP_IE_WINDOW = 'History++/IEVIEW/NewWindow';
  MS_HPP_IE_EVENT	 = 'History++/IEVIEW/Event';
  MS_HPP_IE_UTILS  = 'History++/IEVIEW/Utils';
  MS_HPP_IE_OPTIONSCHANGED = 'History++/IEVIEW/OptionsChanged';
  MS_HPP_IE_NOTIFICATION   = 'History++/IEVIEW/Notification';
{$ENDIF}

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
  ExtGrid: TExternalGrid;
  i,n: Integer;
begin
  try
    par := PIEVIEWWINDOW(lParam);
    case par.iType of
      IEW_CREATE: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_CREATE');
        {$ENDIF}
        n := Length(ExternalGrids);
        SetLength(ExternalGrids,n+1);
        ExternalGrids[n] := TExternalGrid.Create(par.Parent);
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
        ExtGrid.SetPosition(par.x,par.y,par.cx,par.cy);
      end;
      IEW_SCROLLBOTTOM: begin
        {$IFDEF DEBUG}
        OutputDebugString('IEW_SCROLLBOTTOM');
        {$ENDIF}
        ExtGrid := FindExtGridByHandle(par.Hwnd);
        ExtGrid.ScrollToBottom;
      end;
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
  ExtGrid: TExternalGrid;
begin
  try
    {$IFDEF DEBUG}
    OutputDebugString('MS_IEVIEW_EVENT');
    {$ENDIF}
    event := PIEVIEWEVENT(lParam);
    ExtGrid := FindExtGridByHandle(event.Hwnd);
    case event.iType of
      IEE_LOG_DB_EVENTS: begin
        ExtGrid.BeginUpdate;
        if event.Count = -1 then begin
          hDBNext := event.hDBEventFirst;
          while hDBNext <> 0 do begin
            ExtGrid.AddEvent(event.hContact, hDBNext, event.Codepage, boolean(event.dwFlags and IEEF_RTL));
            hDBNext := PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBNext,0);
          end
        end else begin
          hDBNext := event.hDBEventFirst;
          for i := 0 to event.count - 1 do begin
            if hDBNext = 0 then break;
            ExtGrid.AddEvent(event.hContact, hDBNext, event.Codepage, boolean(event.dwFlags and IEEF_RTL));
            if i < event.count -1 then
            hDBNext := PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBNext,0);
          end;
        end;
        ExtGrid.EndUpdate;
      end;
      IEE_CLEAR_LOG: begin
        ExtGrid.BeginUpdate;
        ExtGrid.Clear;
        ExtGrid.EndUpdate;
        Result := 1;
      end;
      IEE_GET_SELECTION: begin
        Result := integer(ExtGrid.GetSelection(boolean(event.dwFlags and IEEF_NO_UNICODE)));
      end;
    else
      Result := 0;
    end;
  except
    Result := 1;
  end;
end;

function ExtUtils(wParam, lParam: DWord): Integer; cdecl;
begin
  try
    {$IFDEF DEBUG}
    OutputDebugString('MS_IEVIEW_UTILS');
    {$ENDIF}
    Result := 0;
  except
    Result := 1;
  end;
end;

procedure RegisterExtGridServices;
begin
  hExtWindow := PluginLink.CreateServiceFunction(MS_HPP_IE_WINDOW,ExtWindow);
  hExtEvent := PluginLink.CreateServiceFunction(MS_HPP_IE_EVENT,ExtEvent);
  hExtUtils := PluginLink.CreateServiceFunction(MS_HPP_IE_UTILS,ExtUtils);
  hExtOptChanged := PluginLink.CreateHookableEvent(MS_HPP_IE_OPTIONSCHANGED);
  hExtNotification := PluginLink.CreateHookableEvent(MS_HPP_IE_NOTIFICATION);
end;

procedure UnregisterExtGridServices;
begin
  PluginLink.DestroyServiceFunction(hExtWindow);
  PluginLink.DestroyServiceFunction(hExtEvent);
  PluginLink.DestroyServiceFunction(hExtUtils);
  PluginLink.DestroyHookableEvent(hExtOptChanged);
  PluginLink.DestroyHookableEvent(hExtNotification);
end;

end.
