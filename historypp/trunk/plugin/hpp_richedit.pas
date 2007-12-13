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
 hpp_richedit(historypp project)

 Version:   1.0
 Created:   12.09.2006
 Author:    theMIROn

 [ Description ]


 [ History ]

 1.0 (12.09.2006)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Contributors: theMIROn
-----------------------------------------------------------------------------}

unit hpp_richedit;

interface

uses
  Windows, Messages, Classes, RichEdit, ActiveX,
  Controls, StdCtrls, ComCtrls, Forms,
  TntControls,
  hpp_global;

const
  IID_IOleObject: TGUID = '{00000112-0000-0000-C000-000000000046}';
  IID_IRichEditOle: TGUID = '{00020D00-0000-0000-C000-000000000046}';
  IID_IRichEditOleCallback: TGUID = '{00020D03-0000-0000-C000-000000000046}';

type
  TReObject = packed record
    cbStruct: DWORD;          // Size of structure
    cp: Integer;              // Character position of object
    clsid: TCLSID;            // Class ID of object
    poleobj: IOleObject;      // OLE object interface
    pstg: IStorage;           // Associated storage interface
    polesite: IOLEClientSite; // Associated client site interface
    sizel: TSize;             // Size of object (may be 0,0)
    dvaspect: DWORD;          // Display aspect to use
    dwFlags: DWORD;           // Object status flags
    dwUser: DWORD;            // Dword for user's use
  end;

const

  // Flags to specify which interfaces should be returned in the structure above
  REO_GETOBJ_NO_INTERFACES  = $00000000;
  REO_GETOBJ_POLEOBJ        = $00000001;
  REO_GETOBJ_PSTG           = $00000002;
  REO_GETOBJ_POLESITE       = $00000004;
  REO_GETOBJ_ALL_INTERFACES = $00000007;

  // Place object at selection
  REO_CP_SELECTION  = ULONG(-1);

  // Use character position to specify object instead of index
  REO_IOB_SELECTION = ULONG(-1);
  REO_IOB_USE_CP    = ULONG(-1);

  // Object flags
  REO_NULL            = $00000000; // No flags
  REO_READWRITEMASK   = $0000003F; // Mask out RO bits
  REO_DONTNEEDPALETTE = $00000020; // Object doesn't need palette
  REO_BLANK           = $00000010; // Object is blank
  REO_DYNAMICSIZE     = $00000008; // Object defines size always
  REO_INVERTEDSELECT  = $00000004; // Object drawn all inverted if sel
  REO_BELOWBASELINE   = $00000002; // Object sits below the baseline
  REO_RESIZABLE       = $00000001; // Object may be resized
  REO_LINK            = $80000000; // Object is a link (RO)
  REO_STATIC          = $40000000; // Object is static (RO)
  REO_SELECTED        = $08000000; // Object selected (RO)
  REO_OPEN            = $04000000; // Object open in its server (RO)
  REO_INPLACEACTIVE   = $02000000; // Object in place active (RO)
  REO_HILITED         = $01000000; // Object is to be hilited (RO)
  REO_LINKAVAILABLE   = $00800000; // Link believed available (RO)
  REO_GETMETAFILE     = $00400000; // Object requires metafile (RO)

  // flags for IRichEditOle::GetClipboardData(),
  // IRichEditOleCallback::GetClipboardData() and
  // IRichEditOleCallback::QueryAcceptData()
  RECO_PASTE  = $00000000; // paste from clipboard
  RECO_DROP   = $00000001; // drop
  RECO_COPY   = $00000002; // copy to the clipboard
  RECO_CUT    = $00000003; // cut to the clipboard
  RECO_DRAG   = $00000004; // drag

type
  THppRichEdit = class;

  IRichEditOle = interface(IUnknown)
    ['{00020d00-0000-0000-c000-000000000046}']
    function GetClientSite(out clientSite: IOleClientSite): HResult; stdcall;
    function GetObjectCount: HResult; stdcall;
    function GetLinkCount: HResult; stdcall;
    function GetObject(iob: Longint; out ReObject: TReObject; dwFlags: DWORD): HResult; stdcall;
    function InsertObject(var ReObject: TReObject): HResult; stdcall;
    function ConvertObject(iob: Longint; rclsidNew: TIID; lpstrUserTypeNew: LPCSTR): HResult; stdcall;
    function ActivateAs(rclsid: TIID; rclsidAs: TIID): HResult; stdcall; function SetHostNames(lpstrContainerApp: LPCSTR; lpstrContainerObj: LPCSTR): HResult; stdcall;
    function SetLinkAvailable(iob: Longint; fAvailable: BOOL): HResult; stdcall;
    function SetDvaspect(iob: Longint; dvaspect: DWORD): HResult; stdcall;
    function HandsOffStorage(iob: Longint): HResult; stdcall;
    function SaveCompleted(iob: Longint; const stg: IStorage): HResult; stdcall;
    function InPlaceDeactivate: HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    function GetClipboardData(var chrg: TCharRange; reco: DWORD; out dataobj: IDataObject): HResult; stdcall;
    function ImportDataObject(dataobj: IDataObject; cf: TClipFormat; hMetaPict: HGLOBAL): HResult; stdcall;
  end;

  IRichEditOleCallback = interface(IUnknown)
    ['{00020d03-0000-0000-c000-000000000046}']
    function GetNewStorage(out stg: IStorage): HResult; stdcall;
    function GetInPlaceContext(out Frame: IOleInPlaceFrame; out Doc: IOleInPlaceUIWindow; lpFrameInfo: POleInPlaceFrameInfo): HResult; stdcall;
    function ShowContainerUI(fShow: BOOL): HResult; stdcall;
    function QueryInsertObject(const clsid: TCLSID; const stg: IStorage; cp: Longint): HResult; stdcall;
    function DeleteObject(const oleobj: IOleObject): HResult; stdcall;
    function QueryAcceptData(const dataobj: IDataObject; var cfFormat: TClipFormat; reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    function GetClipboardData(const chrg: TCharRange; reco: DWORD; out dataobj: IDataObject): HResult; stdcall;
    function GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD; var dwEffect: DWORD): HResult; stdcall;
    function GetContextMenu(seltype: Word; const oleobj: IOleObject; const chrg: TCharRange; out menu: HMENU): HResult; stdcall;
  end;

  TRichEditOleCallback = class(TObject, IUnknown, IRichEditOleCallback)
    private
      FRefCount: Longint;
      FRichEdit: THppRichEdit;
    public
      constructor Create(RichEdit: THppRichEdit);
      destructor Destroy; override;
      function QueryInterface(const iid: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Longint; stdcall;
      function _Release: Longint; stdcall;
      function GetNewStorage(out stg: IStorage): HResult; stdcall;
      function GetInPlaceContext(out Frame: IOleInPlaceFrame; out Doc: IOleInPlaceUIWindow; lpFrameInfo: POleInPlaceFrameInfo): HResult; stdcall;
      function GetClipboardData(const chrg: TCharRange; reco: DWORD; out dataobj: IDataObject): HResult; stdcall;
      function GetContextMenu(seltype: Word; const oleobj: IOleObject; const chrg: TCharRange; out menu: HMENU): HResult; stdcall;
      function ShowContainerUI(fShow: BOOL): HResult; stdcall;
      function QueryInsertObject(const clsid: TCLSID; const stg: IStorage; cp: Longint): HResult;  stdcall;
      function DeleteObject(const oleobj: IOleObject): HResult;  stdcall;
      function QueryAcceptData(const dataobj: IDataObject; var cfFormat: TClipFormat; reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HResult;  stdcall;
      function ContextSensitiveHelp(fEnterMode: BOOL): HResult;  stdcall;
      function GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD; var dwEffect: DWORD): HResult;  stdcall;
  end;

  TURLClickEvent = procedure(Sender: TObject; const URLText: String; Button: TMouseButton) of object;

  THppRichEdit = class(TCustomRichEdit)
  private
    FVersion: Integer;
    FUnicodeAPI: Boolean;
    FCodepage: Cardinal;
    FClickRange: TCharRange;
    FClickBtn: TMouseButton;
    FOnURLClick: TURLClickEvent;
    FRichEditOleCallback: TRichEditOleCallback;
    FRichEditOle: IRichEditOle;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure WMDestroy(var Msg: TWMDestroy); message WM_DESTROY;
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMLangChange(var Message: TMessage); message WM_INPUTLANGCHANGE;
    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMKeyDown(var Message: TWMKey); message WM_KEYDOWN;
    procedure SetAutoKeyboard(Enabled: Boolean);
    function GetUnicodeAPI: Boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure URLClick(const URLText: String; Button: TMouseButton); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetTextRangeA(cpMin,cpMax: Integer): AnsiString;
    function GetTextRangeW(cpMin,cpMax: Integer): WideString;
    function GetTextLength: Integer;
    property Codepage: Cardinal read FCodepage write FCodepage default CP_ACP;
    property UnicodeAPI: Boolean read GetUnicodeAPI;
    property Version: Integer read FVersion;
  published
    published
    property Align;
    property Alignment;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind default bkNone;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HideScrollBars;
    property ImeMode;
    property ImeName;
    property Constraints;
    property Lines;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PlainText;
    property PopupMenu;
    property ReadOnly;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property WantTabs;
    property WantReturns;
    property WordWrap;
    property OnChange;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnProtectChange;
    property OnResizeRequest;
    property OnSaveClipboard;
    property OnSelectionChange;
    property OnStartDock;
    property OnStartDrag;
    property OnURLClick: TURLClickEvent read FOnURLClick write FOnURLClick;
  end;

  TImageDataObject = class(TInterfacedObject,IDataObject)
  private
    FBmp:hBitmap;
    FMedium:TStgMedium;
    FFormatEtc: TFormatEtc;
    procedure SetBitmap(bmp:hBitmap);
    function GetOleObject(OleClientSite:IOleClientSite; Storage:IStorage):IOleObject;
    // IDataObject
    function GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc; out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium; fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc: IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint; const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
  public
    destructor Destroy; override;
    function InsertBitmap(Wnd: HWND; Bitmap: hBitmap; cp: Cardinal): Boolean;
  end;

  PTextStream = ^TTextStream;
  TTextStream = record
    Size: Integer;
    case Boolean of
      false: (Data:  PAnsiChar);
      true:  (DataW: PWideChar);
  end;

function InitRichEditLibrary: Integer;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: WideString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer; overload;
function GetRichRTF(RichEditHandle: THandle; var RTFStream: AnsiString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer; overload;
function SetRichRTF(RichEditHandle: THandle; RTFStream: WideString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer; overload;
function SetRichRTF(RichEditHandle: THandle; RTFStream: AnsiString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer; overload;
function FormatString2RTF(Source: WideString; Suffix: String = ''): String; overload;
function FormatString2RTF(Source: AnsiString; Suffix: String = ''): String; overload;
//function FormatRTF2String(RichEditHandle: THandle; RTFStream: WideString): WideString; overload;
//function FormatRTF2String(RichEditHandle: THandle; RTFStream: AnsiString): WideString; overload;
function GetRichString(RichEditHandle: THandle; SelectionOnly: Boolean = false): WideString;

function RichEdit_SetOleCallback(Wnd: HWND; const Intf: IRichEditOleCallback): Boolean;
function RichEdit_GetOleInterface(Wnd: HWND; out Intf: IRichEditOle): Boolean;
function RichEdit_InsertBitmap(Wnd: HWND; Bitmap: hBitmap; cp: Cardinal): Boolean;

procedure Register;

implementation

uses SysUtils;

type
  EOleError = class(Exception);

const
  SOleError        = 'OLE2 error occured. Error code: %.8xH';

  SF_UNICODE = 16;
  SF_USECODEPAGE = 32;

  RICHEDIT_CLASS20A = 'RICHEDIT20A';
  RICHEDIT_CLASS20W = 'RICHEDIT20W';
  MSFTEDIT_CLASS    = 'RICHEDIT50W';

var
  FRichEditModule:  THandle = 0;
  FRichEditVersion: Integer = 0;

procedure Register;
begin
  RegisterComponents('History++', [THppRichedit]);
end;

function GetModuleVersionSpec(hModule: THandle): Integer;
type
  PDllVersionInfo = ^TDllVersionInfo;
  TDllVersionInfo = packed record
    cbSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformID: DWORD;
  end;
var
  DllGetVersionProc: function (Info: PDllVersionInfo): HRESULT; stdcall;
  Info: TDllVersionInfo;
begin
  Result := -1;
  if hModule = 0 then exit;
  try
    DllGetVersionProc := GetProcAddress(hModule, 'DllGetVersion');
    if Assigned(DllGetVersionProc) then begin
      ZeroMemory(@Info, SizeOf(Info));
      Info.cbSize := SizeOf(Info);
      if DllGetVersionProc(@Info) = 0 then
        Result := Info.dwMajorVersion;
    end;
  except
  end;
end;

function GetModuleVersionFile(hModule: THandle): Integer;
var
  dwVersion: Cardinal;
begin
  Result := -1;
  if hModule = 0 then exit;
  try
    dwVersion := GetFileVersion(GetModuleName(hModule));
    if dwVersion <> Cardinal(-1) then
      Result := LoWord(dwVersion);
  except
  end;
end;

function InitRichEditLibrary: Integer;
const
  RICHED20_DLL = 'RICHED20.DLL';
  MSFTEDIT_DLL = 'MSFTEDIT.DLL';
var
  hModule : THandle;
  emError : DWord;
begin
  if FRichEditModule = 0 then begin
    FRichEditVersion := -1;
    emError := SetErrorMode(SEM_NOOPENFILEERRORBOX);
    try
      hModule := LoadLibrary(RICHED20_DLL);
      if hModule <= HINSTANCE_ERROR then hModule := 0;
      FRichEditModule := hModule;
      if FRichEditModule <> 0 then
        FRichEditVersion := GetModuleVersionSpec(FRichEditModule);
      if FRichEditVersion <= 40 then begin
        hModule := LoadLibrary(MSFTEDIT_DLL);
        if hModule <= HINSTANCE_ERROR then hModule := 0;
        if hModule <> 0 then begin
          if FRichEditModule <> 0 then
            FreeLibrary(FRichEditModule);
          FRichEditModule := hModule;
          FRichEditVersion := GetModuleVersionSpec(hModule);
        end else
        if (FRichEditModule <> 0) and (FRichEditVersion < 0) then begin
          FRichEditVersion := GetModuleVersionFile(FRichEditModule);
          if FRichEditVersion = 0 then FRichEditVersion := 20;
        end;
      end;
    finally
      SetErrorMode(emError);
    end;
  end;
  Result := FRichEditVersion;
end;

function RichEditStreamLoad(dwCookie: Longint; pbBuff: PByte; cb: Longint; var pcb: Longint): Longint; stdcall;
var
  pBuff: PChar;
begin
  with PTextStream(dwCookie)^ do begin
    pBuff := Data;
    pcb := Size;
    if pcb > cb then pcb := cb;
    move(pBuff^,pbBuff^,pcb);
    Inc(Data,pcb);
    Dec(Size,pcb);
  end;
  Result := 0;
end;

function RichEditStreamSave(dwCookie: Longint; pbBuff: PByte; cb: Longint; var pcb: Longint): Longint; stdcall;
var
  prevSize: Integer;
begin
  with PTextStream(dwCookie)^ do begin
    prevSize := Size;
    Inc(Size,cb);
    ReallocMem(Data,Size);
    Move(pbBuff^,(Data+prevSize)^,cb);
    pcb := cb;
  end;
  Result := 0;
end;

function _GetRichRTF(RichEditHandle: THandle; TextStream: PTextStream;
                    SelectionOnly, PlainText, NoObjects, PlainRTF, Unicode: Boolean): Integer;
var
  es: TEditStream;
  format: Longint;
begin
  format := 0;
  if SelectionOnly then format := format or SFF_SELECTION;
  if PlainText then begin
    if NoObjects then format := format or SF_TEXT
                 else format := format or SF_TEXTIZED;
    if Unicode then   format := format or SF_UNICODE;
  end else begin
    if NoObjects then format := format or SF_RTFNOOBJS
                 else format := format or SF_RTF;
    if PlainRTF  then format := format or SFF_PLAINRTF;
    //if Unicode then   format := format or SF_USECODEPAGE or (CP_UTF16 shl 16);
  end;
  TextStream^.Size := 0;
  TextStream^.Data := nil;
  es.dwCookie := LPARAM(TextStream);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamSave;
  SendMessage(RichEditHandle, EM_STREAMOUT, format, LPARAM(@es));
  Result := es.dwError;
end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: WideString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Result := _GetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, NoObjects, PlainRTF, PlainText);
  if Assigned(Stream.DataW) then begin
    if PlainText then
      SetString(RTFStream,Stream.DataW,Stream.Size div SizeOf(WideChar)) else
      RTFStream := AnsiToWideString(Stream.Data,CP_ACP);
    FreeMem(Stream.Data,Stream.Size);
  end;
end;

function GetRichRTF(RichEditHandle: THandle; var RTFStream: AnsiString;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Result := _GetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, NoObjects, PlainRTF, False);
  if Assigned(Stream.Data) then begin
    SetString(RTFStream,Stream.Data,Stream.Size-1);
    FreeMem(Stream.Data,Stream.Size);
  end;
end;

function _SetRichRTF(RichEditHandle: THandle; TextStream: PTextStream;
                    SelectionOnly, PlainText, PlainRTF, Unicode: Boolean): Integer;
var
  es: TEditStream;
  format: Longint;
begin
  format := 0;
  if SelectionOnly then format := format or SFF_SELECTION;
  if PlainText then begin
    format := format or SF_TEXT;
    if Unicode then format := format or SF_UNICODE;
  end else begin
    format := format or SF_RTF;

    if PlainRTF then format := format or SFF_PLAINRTF;
    //if Unicode then  format := format or SF_USECODEPAGE or (CP_UTF16 shl 16);
  end;
  es.dwCookie := LPARAM(TextStream);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamLoad;
  SendMessage(RichEditHandle, EM_STREAMIN, format, LPARAM(@es));
  Result := es.dwError;
end;

function SetRichRTF(RichEditHandle: THandle; RTFStream: WideString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
  Buffer: AnsiString;
begin
  if PlainText then begin
    Stream.DataW := @RTFStream[1];
    Stream.Size  := Length(RTFStream)*SizeOf(WideChar);
  end else begin
    Buffer := WideToAnsiString(RTFStream,CP_ACP);
    Stream.Data := @Buffer[1];
    Stream.Size  := Length(Buffer);
  end;
  Result := _SetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, PlainRTF, PlainText);
end;

function SetRichRTF(RichEditHandle: THandle; RTFStream: AnsiString;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Stream.Data := @RTFStream[1];
  Stream.Size := Length(RTFStream);
  Result := _SetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, PlainRTF, False);
end;

function FormatString2RTF(Source: WideString; Suffix: String = ''): String;
var
  Text: PWideChar;
begin
  Text := PWideChar(Source);
  Result := '{\uc1 ';
  while Text[0] <> #0 do begin
    if (Text[0] = #13) and (Text[1] = #10) then begin
      Result := Result + '\par ';
      Inc(Text);
    end else
    case Text[0] of
      #10: Result := Result + '\par ';
      #09: Result := Result + '\tab ';
      '\','{','}': Result := Result + '\' + Text[0];
    else
    if word(Text[0]) < 128 then
      Result := Result + AnsiChar(Word(Text[0])) else
      Result := Result + Format('\u%d?',[word(Text[0])]);
    end;
    Inc(Text);
  end;
  Result := Result + Suffix + '}';
end;

function FormatString2RTF(Source: AnsiString; Suffix: String = ''): String;
var
  Text: PChar;
begin
  Text := PChar(Source);
  Result := '{';
  while Text[0] <> #0 do begin
    if (Text[0] = #13) and (Text[1] = #10) then begin
      Result := Result + '\line ';
      Inc(Text);
    end else
    case Text[0] of
      #10: Result := Result + '\line ';
      #09: Result := Result + '\tab ';
      '\','{','}': Result := Result + '\' + Text[0];
    else
      Result := Result + Text[0];
    end;
    Inc(Text);
  end;
  Result := Result + Suffix + '}';
end;

{function FormatRTF2String(RichEditHandle: THandle; RTFStream: WideString): WideString;
begin
  SetRichRTF(RichEditHandle,RTFStream,False,False,True);
  GetRichRTF(RichEditHandle,Result,False,True,True,True);
end;

function FormatRTF2String(RichEditHandle: THandle; RTFStream: AnsiString): WideString;
begin
  SetRichRTF(RichEditHandle,RTFStream,False,False,True);
  GetRichRTF(RichEditHandle,Result,False,True,True,True);
end;}

function GetRichString(RichEditHandle: THandle; SelectionOnly: Boolean = false): WideString;
begin
  GetRichRTF(RichEditHandle,Result,SelectionOnly,True,True,False);
end;

{ OLE Specific }

function FailedHR(hr: HResult): Boolean;
begin
  Result := Failed(hr);
end;

function OleErrorMsg(ErrorCode: HResult): string;
begin
  FmtStr(Result, SOleError, [Longint(ErrorCode)]);
end;

procedure OleError(ErrorCode: HResult);
begin
  raise EOleError.Create(OleErrorMsg(ErrorCode));
end;

procedure OleCheck(OleResult: HResult);
begin
  if FailedHR(OleResult) then OleError(OleResult);
end;

procedure ReleaseObject(var Obj);
begin
  if IUnknown(Obj) <> nil then IUnknown(Obj) := nil;
end;

procedure CreateStorage(var Storage: IStorage);
var
  LockBytes: ILockBytes;
begin
  OleCheck(CreateILockBytesOnHGlobal(0, True, LockBytes));
  try
    OleCheck(StgCreateDocfileOnILockBytes(LockBytes,
      STGM_READWRITE or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, Storage));
  finally
    ReleaseObject(LockBytes);
  end;
end;

{ THppRichEdit }

constructor THppRichedit.Create(AOwner: TComponent);
begin
  FUnicodeAPI := False;
  FClickRange.cpMin := -1;
  FClickRange.cpMax := -1;
  FRichEditOleCallback := TRichEditOleCallback.Create(Self);
  inherited;
end;

destructor THppRichedit.Destroy;
begin
  inherited Destroy;
  FRichEditOleCallback.Free;
end;

type
  TAccessCustomMemo = class(TCustomMemo);
  InheritedCreateParams = procedure(var Params: TCreateParams) of object;
procedure THppRichedit.CreateParams(var Params: TCreateParams);
const
  aHideScrollBars: array[Boolean] of DWORD = (ES_DISABLENOSCROLL, 0);
  aHideSelections: array[Boolean] of DWORD = (ES_NOHIDESEL, 0);
  aWordWrap:       array[Boolean] of DWORD = (WS_HSCROLL, 0);
var
  Method: TMethod;
begin
  FVersion := InitRichEditLibrary;
  Method.Code := @TAccessCustomMemo.CreateParams;
  Method.Data := Self;
  InheritedCreateParams(Method)(Params);
  if FVersion >= 20 then begin
    if FVersion = 41 then
      CreateSubClass(Params, MSFTEDIT_CLASS) else
      CreateSubClass(Params, RICHEDIT_CLASS20A);
  end;
  with Params do begin
    Style := Style or
             aHideScrollBars[HideScrollBars] or
             aHideSelections[HideSelection] and
             not aWordWrap[WordWrap]; // more compatible with RichEdit 1.0
    // Fix for updating rich in event details form
    WindowClass.style := WindowClass.style and
             not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure THppRichedit.CreateWindowHandle(const Params: TCreateParams);
begin
  if hppOSUnicode and (FVersion >= 20) then begin
    if FVersion = 41 then
      CreateUnicodeHandle(Self, Params, MSFTEDIT_CLASS) else
      CreateUnicodeHandle(Self, Params, RICHEDIT_CLASS20W);
  end else inherited;
  FUnicodeAPI := IsWindowUnicode(Handle);
end;

procedure THppRichedit.CreateWnd;
const
  EM_SETEDITSTYLE         = WM_USER + 204;
  SES_EXTENDBACKCOLOR     = 4;
begin
  inherited;
  SendMessage(Handle,EM_SETMARGINS,EC_LEFTMARGIN or EC_RIGHTMARGIN,0);
  SendMessage(Handle,EM_SETEDITSTYLE,SES_EXTENDBACKCOLOR,SES_EXTENDBACKCOLOR);
  SendMessage(Handle,EM_AUTOURLDETECT,1,0);
  SendMessage(Handle,EM_SETEVENTMASK,0,SendMessage(Handle,EM_GETEVENTMASK,0,0) or ENM_LINK);
  RichEdit_SetOleCallback(Handle, FRichEditOleCallback as IRichEditOleCallback);
  RichEdit_GetOleInterface(Handle, FRichEditOle);
end;

procedure THppRichedit.SetAutoKeyboard(Enabled: Boolean);
var
  re_options,new_options: DWord;
begin
  re_options := SendMessage(Handle,EM_GETLANGOPTIONS,0,0);
  if Enabled then
    new_options := re_options or IMF_AUTOKEYBOARD else
    new_options := re_options and not IMF_AUTOKEYBOARD;
  if re_options <> new_options then
    SendMessage(Handle,EM_SETLANGOPTIONS,0,new_options);
end;

function THppRichedit.GetUnicodeAPI: Boolean;
begin
  HandleNeeded;
  Result := FUnicodeAPI;
end;

function THppRichedit.GetTextRangeA(cpMin,cpMax: Integer): AnsiString;
var
  WideText: WideString;
  tr: TextRange;
begin
  tr.chrg.cpMin := cpMin;
  tr.chrg.cpMax := cpMax;
  if UnicodeAPI then begin
    SetLength(WideText,cpMax-cpMin);
    tr.lpstrText := @WideText[1];
  end else begin
    SetLength(Result,cpMax-cpMin);
    tr.lpstrText := @Result[1];
  end;
  Perform(EM_GETTEXTRANGE,0,LPARAM(@tr));
  if UnicodeAPI then
    Result := WideToAnsiString(WideText,Codepage);
end;

function THppRichedit.GetTextRangeW(cpMin,cpMax: Integer): WideString;
var
  AnsiText: WideString;
  tr: TextRange;
begin
  tr.chrg.cpMin := cpMin;
  tr.chrg.cpMax := cpMax;
  if UnicodeAPI then begin
    SetLength(Result,cpMax-cpMin);
    tr.lpstrText := @Result[1];
  end else begin
    SetLength(AnsiText,cpMax-cpMin);
    tr.lpstrText := @AnsiText[1];
  end;
  Perform(EM_GETTEXTRANGE,0,LPARAM(@tr));
  if not UnicodeAPI then
    Result := AnsiToWideString(AnsiText,Codepage);
end;

function THppRichedit.GetTextLength: Integer;
var
  gtxl: GETTEXTLENGTHEX;
begin
  gtxl.flags := GTL_DEFAULT or GTL_PRECISE;
  if UnicodeAPI then begin
    gtxl.codepage := 1200;
    gtxl.flags := gtxl.flags or GTL_NUMCHARS;
  end else
    gtxl.codepage := FCodepage;
  Result := Perform(EM_GETTEXTLENGTHEX, WPARAM(@gtxl), 0);
end;

procedure THppRichedit.URLClick(const URLText: String; Button: TMouseButton);
begin
  if Assigned(OnURLClick) then OnURLClick(Self, URLText, Button);
end;

procedure THppRichedit.CNNotify(var Message: TWMNotify);
begin
  inherited;
  if Message.NMHdr^.code <> EN_LINK then exit;
  with TENLink(Pointer(Message.NMHdr)^) do begin
    case Msg of
      WM_RBUTTONDOWN: begin
        FClickRange := chrg;
        FClickBtn := mbRight;
      end;
      WM_RBUTTONUP: begin
        if (FClickBtn = mbRight) and
           (FClickRange.cpMin = chrg.cpMin) and (FClickRange.cpMax = chrg.cpMax) then
          URLClick(GetTextRangeA(chrg.cpMin, chrg.cpMax), mbRight);
        FClickRange.cpMin := -1;
        FClickRange.cpMax := -1;
      end;
      WM_LBUTTONDOWN: begin
        FClickRange := chrg;
        FClickBtn := mbLeft;
      end;
      WM_LBUTTONUP: begin
        if (FClickBtn = mbLeft) and
           (FClickRange.cpMin = chrg.cpMin) and (FClickRange.cpMax = chrg.cpMax) then
          URLClick(GetTextRangeA(chrg.cpMin, chrg.cpMax), mbLeft);
        FClickRange.cpMin := -1;
        FClickRange.cpMax := -1;
      end;
    end;
  end;
end;

procedure THppRichedit.WMDestroy(var Msg: TWMDestroy);
begin
  ReleaseObject(FRichEditOle);
  inherited;
end;

type
  InheritedWMRButtonUp = procedure(var Message: TWMRButtonUp) of object;
procedure THppRichedit.WMRButtonUp(var Message: TWMRButtonUp);
  function GetDynamicMethod(AClass: TClass; Index: Integer): Pointer;
  asm call System.@FindDynaClass end;
var
  Method: TMethod;
begin
  Method.Code := GetDynamicMethod(TCustomMemo,WM_RBUTTONUP);
  Method.Data := Self;
  InheritedWMRButtonUp(Method)(Message);
  // RichEdit does not pass the WM_RBUTTONUP message to defwndproc,
  // so we get no WM_CONTEXTMENU message.
  // Simulate message here, after EN_LINK defwndproc's notyfy message
  if Assigned(FRichEditOleCallback) or (Win32MajorVersion < 5) then
    Perform(WM_CONTEXTMENU, Handle, LParam(PointToSmallPoint(
      ClientToScreen(SmallPointToPoint(TWMMouse(Message).Pos)))));
end;

procedure THppRichedit.WMSetFocus(var Message: TWMSetFocus);
begin
  SetAutoKeyboard(False);
  inherited;
end;

procedure THppRichedit.WMLangChange(var Message: TMessage);
begin
  SetAutoKeyboard(False);
  Message.Result:=1;
end;

procedure THppRichedit.WMCopy(var Message: TWMCopy);
var
  Text: WideString;
begin
  inherited;
  // do not empty clip to not to loose rtf data
  //EmptyClipboard();
  Text := GetRichString(Handle,True);
  CopyToClip(Text,Handle,FCodepage,False);
end;

procedure THppRichedit.WMKeyDown(var Message: TWMKey);
begin
  if (KeyDataToShiftState(Message.KeyData) = [ssCtrl]) then
    case Message.CharCode of
      Ord('E'),Ord('J'):
        Message.Result := 1;
      Ord('C'),VK_INSERT: begin
        PostMessage(Handle,WM_COPY,0,0);
        Message.Result := 1;
      end;
    end;
  if Message.Result = 1 then exit;
  inherited;
end;

{ TRichEditOleCallback }

constructor TRichEditOleCallback.Create(RichEdit: THppRichEdit);
begin
  inherited Create;
  FRichEdit := RichEdit;
end;

destructor TRichEditOleCallback.Destroy;
begin
  inherited Destroy;
end;

function TRichEditOleCallback.QueryInterface(const iid: TGUID; out Obj): HResult;
begin
  if GetInterface(iid, Obj) then
    Result := S_OK else
    Result := E_NOINTERFACE;
end;

function TRichEditOleCallback._AddRef: Longint;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TRichEditOleCallback._Release: Longint;
begin
  Dec(FRefCount);
  Result := FRefCount;
end;

function TRichEditOleCallback.GetNewStorage(out stg: IStorage): HResult;
begin
  try
    CreateStorage(stg);
    Result := S_OK;
  except
    Result:= E_OUTOFMEMORY;
  end;
end;

function TRichEditOleCallback.GetInPlaceContext(out Frame: IOleInPlaceFrame; out Doc: IOleInPlaceUIWindow; lpFrameInfo: POleInPlaceFrameInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TRichEditOleCallback.QueryInsertObject(const clsid: TCLSID; const stg: IStorage; cp: Longint): HResult;
begin
  Result := NOERROR;
end;

function TRichEditOleCallback.DeleteObject(const oleobj: IOleObject): HResult;
begin
  if Assigned(oleobj) then oleobj.Close(OLECLOSE_NOSAVE);
  Result := NOERROR;
end;

function TRichEditOleCallback.QueryAcceptData(const dataobj: IDataObject; var cfFormat: TClipFormat; reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HResult;
begin
  Result := S_OK;
end;

function TRichEditOleCallback.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

function TRichEditOleCallback.GetClipboardData(const chrg: TCharRange; reco: DWORD; out dataobj: IDataObject): HResult;
begin
  Result := E_NOTIMPL;
end;

function TRichEditOleCallback.GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD; var dwEffect: DWORD): HResult;
begin
  Result := E_NOTIMPL;
end;

function TRichEditOleCallback.GetContextMenu(seltype: Word; const oleobj: IOleObject; const chrg: TCharRange; out menu: HMENU): HResult;
begin
  Result := E_NOTIMPL;
end;

function TRichEditOleCallback.ShowContainerUI(fShow: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

function RichEdit_SetOleCallback(Wnd: HWND; const Intf: IRichEditOleCallback): Boolean;
begin
  Result := SendMessage(Wnd, EM_SETOLECALLBACK, 0, LPARAM(Intf)) <> 0;
end;

function RichEdit_GetOleInterface(Wnd: HWND; out Intf: IRichEditOle): Boolean;
begin
  Result := SendMessage(Wnd, EM_GETOLEINTERFACE, 0, LPARAM(@Intf)) <> 0;
end;

{ TImageDataObject }

function TImageDataObject.DAdvise(const formatetc: TFormatEtc; advf: Integer; const advSink: IAdviseSink; out dwConnection: Integer): HResult;
begin
  Result:=E_NOTIMPL;
end;

function TImageDataObject.DUnadvise(dwConnection: Integer): HResult;
begin
  Result:=E_NOTIMPL;
end;

function TImageDataObject.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
begin
  Result:=E_NOTIMPL;
end;

function TImageDataObject.EnumFormatEtc(dwDirection: Integer; out enumFormatEtc: IEnumFormatEtc): HResult;
begin
  Result:=E_NOTIMPL;
end;

function TImageDataObject.GetCanonicalFormatEtc(const formatetc: TFormatEtc; out formatetcOut: TFormatEtc): HResult;
begin
  Result:=E_NOTIMPL;
end;

function TImageDataObject.GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult;
begin
  Result:=E_NOTIMPL;
end;

function TImageDataObject.QueryGetData(const formatetc: TFormatEtc): HResult;
begin
  Result:=E_NOTIMPL;
end;

destructor TImageDataObject.Destroy;
begin
  ReleaseStgMedium(FMedium);
end;

function TImageDataObject.GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium): HResult;
begin
  medium.tymed := TYMED_GDI;
  medium.hBitmap :=  FMedium.hBitmap;
  medium.unkForRelease := nil;
  Result:=S_OK;
end;

function TImageDataObject.SetData(const formatetc: TFormatEtc; var medium: TStgMedium; fRelease: BOOL): HResult;
begin
  FFormatEtc := formatetc;
  FMedium := medium;
  Result:= S_OK;
end;

procedure TImageDataObject.SetBitmap(bmp: hBitmap);
var
  stgm: TStgMedium;
  fm: TFormatEtc;
begin
  stgm.tymed := TYMED_GDI;
  stgm.hBitmap := bmp;
  stgm.UnkForRelease := nil;
  fm.cfFormat := CF_BITMAP;
  fm.ptd := nil;
  fm.dwAspect := DVASPECT_CONTENT;
  fm.lindex := -1;
  fm.tymed := TYMED_GDI;
  SetData(fm, stgm, FALSE);
end;

function TImageDataObject.GetOleObject(OleClientSite: IOleClientSite; Storage: IStorage):IOleObject;
begin
  if (Fmedium.hBitmap=0) then
    Result := nil else
    OleCreateStaticFromData(Self, IID_IOleObject,
      OLERENDER_FORMAT, @FFormatEtc, OleClientSite, Storage, Result);
end;

function TImageDataObject.InsertBitmap(Wnd: HWND; Bitmap: hBitmap; cp: Cardinal): Boolean;
var
  RichEditOLE: IRichEditOLE;
  OleClientSite: IOleClientSite;
  Storage: IStorage;
  OleObject: IOleObject;
  ReObject: TReObject;
  clsid: TGUID;
begin
  Result := False;
  if Bitmap = 0 then exit;
  if not RichEdit_GetOleInterface(Wnd,RichEditOLE) then exit;
  FBmp := CopyImage(Bitmap,IMAGE_BITMAP,0,0,0);
  try
    SetBitmap(FBmp);
    RichEditOle.GetClientSite(OleClientSite);
    Storage := nil;
    try
      CreateStorage(Storage);
      if not (Assigned(OleClientSite) and Assigned(Storage)) then exit;
      try
        OleObject := GetOleObject(OleClientSite, Storage);
        if OleObject = nil then exit;
        OleSetContainedObject(OleObject, True);
        OleObject.GetUserClassID(clsid);
        ZeroMemory(@ReObject, SizeOf(ReObject));
        ReObject.cbStruct := SizeOf(ReObject);
        ReObject.clsid := clsid;
        ReObject.cp := cp;
        ReObject.dvaspect := DVASPECT_CONTENT;
        ReObject.poleobj := OleObject;
        ReObject.polesite := OleClientSite;
        ReObject.pstg := Storage;
        Result := (RichEditOle.InsertObject(ReObject) = NOERROR);
      finally
        ReleaseObject(OleObject);
      end;
    finally
      ReleaseObject(OleClientSite);
      ReleaseObject(Storage);
    end;
  finally
    DeleteObject(FBmp);
    ReleaseObject(RichEditOLE);
  end;
end;

function RichEdit_InsertBitmap(Wnd: HWND; Bitmap: hBitmap; cp: Cardinal): Boolean;
begin
  with TImageDataObject.Create do
  try
    Result := InsertBitmap(Wnd,Bitmap,cp);
  finally
    Free;
  end
end;

initialization

finalization
  if FRichEditModule <> 0 then FreeLibrary(FRichEditModule);

end.
