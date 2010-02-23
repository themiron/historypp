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
 hpp_richedit_ole (historypp project)

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

unit hpp_richedit_ole;

interface

uses
  Windows, Classes, ActiveX, RichEdit;

const

  IID_IOleObject: TGUID = (
    D1:$00000112;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IRichEditOleCallback: TGUID = (
    D1:$00020D03;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IDataObject: TGUID = (
    D1:$0000010E;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));

type

  TReObject = packed record
    cbStruct: DWORD; // Size of structure
    cp: integer; // Character position of object
    clsid: TCLSID; // Class ID of object
    poleobj: IOleObject; // OLE object interface
    pstg: IStorage; // Associated storage interface
    polesite: IOLEClientSite; // Associated client site interface
    sizel: TSize; // Size of object (may be 0,0)
    dvaspect: DWORD; // Display aspect to use
    dwFlags: DWORD; // Object status flags
    dwUser: DWORD; // Dword for user's use
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
    public
      constructor Create;
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
    destructor Destroy;override;
    procedure InsertBitmap(REHandle:HWND; Bitmap: hBitmap; cp: Integer = REO_CP_SELECTION);
  end;

procedure REInsertBitmap(REHandle:HWND; Bitmap: hBitmap; cp: Integer = REO_CP_SELECTION);

implementation

Uses SysUtils;

type
  EOleError = class(Exception);

const
  SOleError        = 'OLE2 error occured. Error code: %.8xH';

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
  if IUnknown(Obj) <> nil then begin
    IUnknown(Obj)._Release;
    IUnknown(Obj) := nil;
  end;
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

{ TRichEditOleCallback }

constructor TRichEditOleCallback.Create;
begin
  inherited Create;
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
  Result := NOERROR;
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

procedure TImageDataObject.InsertBitmap(REHandle:HWND; Bitmap: hBitmap; cp: Integer = REO_CP_SELECTION);
var
  RichEditOLE:IRichEditOLE;
  OleClientSite:IOleClientSite;
  Storage:IStorage;
  LockBytes:ILockBytes;
  OleObject:IOleObject;
  ReObject:TReObject;
  clsid:TGUID;
begin
  SendMessage(REHandle, EM_GETOLEINTERFACE, 0, LPARAM(@RichEditOle));
  if (RichEditOle = nil) or (Bitmap = 0)then exit;
  FBmp := CopyImage(Bitmap,IMAGE_BITMAP,0,0,0);
  if FBmp = 0 then exit;
  try
    SetBitmap(FBmp);
    RichEditOle.GetClientSite(OleClientSite);
    if OleClientSite = nil then exit;
    if CreateILockBytesOnHGlobal(0, True, LockBytes) <> S_OK then exit;
    if StgCreateDocfileOnILockBytes(LockBytes,
      STGM_SHARE_EXCLUSIVE or STGM_CREATE or STGM_READWRITE, 0,Storage) <> S_OK then begin
      LockBytes._Release;
      exit;
    end;
    if Storage = nil then exit;
    OleObject := GetOleObject(OleClientSite, Storage);
    if OleObject = nil then exit;
    OleSetContainedObject(OleObject, True);
    OleObject.GetUserClassID(clsid);
    ZeroMemory(@ReObject, SizeOf(ReObject));
    ReObject.cbStruct := SizeOf(ReObject);
    ReObject.clsid := clsid;
    ReObject.cp := cp;
    //ReObject.dvaspect := DVASPECT_CONTENT or REO_BELOWBASELINE;
    ReObject.dvaspect := DVASPECT_CONTENT;
    ReObject.poleobj := OleObject;
    ReObject.polesite := OleClientSite;
    ReObject.pstg := Storage;
    RichEditOle.InsertObject(ReObject);
  finally
    DeleteObject(FBmp);
    RichEditOLE := nil;
    OleObject := nil;
  end;
end;

procedure REInsertBitmap(REHandle:HWND; Bitmap: hBitmap; cp: Integer = REO_CP_SELECTION);
begin
  with TImageDataObject.Create do
  try
    InsertBitmap(REHandle,Bitmap,cp);
  finally
    Free;
  end
end;

end.
