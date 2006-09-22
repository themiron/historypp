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

 Copyright (c) theMIROn, 2006
-----------------------------------------------------------------------------}

unit hpp_richedit_ole;

interface

uses
  Windows, Classes, ActiveX, RichEdit, ComCtrls;

const

  IID_IDataObject: TGUID = (
    D1:$0000010E;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleObject: TGUID = (
    D1:$00000112;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IRichEditOleCallback: TGUID = (
    D1:$00020D03;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));

  REO_CP_SELECTION    = ULONG(-1);
  REO_IOB_SELECTION   = ULONG(-1);
  REO_GETOBJ_POLEOBJ  =  $00000001;

type

  TReobject = record
    cbStruct: DWORD;
    cp: ULONG;
    clsid: TCLSID;
    poleobj: IOleObject;
    pstg: IStorage;
    polesite: IOleClientSite;
    sizel: TSize;
    dvAspect: Longint;
    dwFlags: DWORD;
    dwUser: DWORD;
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
      FRichEdit: TRichEdit;
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

  IRichEditOle = interface(IUnknown)
    ['{00020d00-0000-0000-c000-000000000046}']
    function GetClientSite(out clientSite: IOleClientSite): HResult; stdcall;
    function GetObjectCount: HResult; stdcall;
    function GetLinkCount: HResult; stdcall;
    function GetObject(iob: Longint; out reobject: TReObject; dwFlags: DWORD): HResult; stdcall;
    function InsertObject(var reobject: TReObject): HResult; stdcall;
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

  TImageDataObject = class(TInterfacedObject,IDataObject)
  private
    FBmp:hBitmap;
    FMedium:TStgMedium;
    FFormatEtc: TFormatEtc;
    procedure SetBitmap(bmp:hBitmap);
    function GetOleObject(OleClientSite:IOleClientSite; Storage:IStorage):IOleObject;
    destructor Destroy;override;

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
    procedure InsertBitmap(wnd:HWND; Bitmap:hBitmap);
  end;

  procedure InsertBitmapToRichEdit(Wnd:HWND; bmp:hBitmap);

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
    OleCheck(StgCreateDocfileOnILockBytes(LockBytes, STGM_READWRITE or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, Storage));
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
  if GetInterface(iid, Obj) then Result := S_OK
  else Result := E_NOINTERFACE;
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
  if (Fmedium.hBitmap=0) then Result:=nil else
  OleCreateStaticFromData(self, IID_IOleObject, OLERENDER_FORMAT, @FFormatEtc, OleClientSite, Storage, Result);
end;

procedure TImageDataObject.InsertBitmap(wnd:HWND; Bitmap: hBitmap);
var
  OleClientSite:IOleClientSite;
  RichEditOLE:IRichEditOLE;
  Storage:IStorage;
  LockBytes:ILockBytes;
  OleObject:IOleObject;
  reobject:TReobject;
  clsid:TGUID;
begin
  if (SendMessage(wnd, EM_GETOLEINTERFACE, 0, cardinal(@RichEditOle))=0) then exit;
  FBmp:=CopyImage(Bitmap,IMAGE_BITMAP,0,0,0);
  if FBmp=0 then exit;
  try
    SetBitmap(Fbmp);
    RichEditOle.GetClientSite(OleClientSite);
    if (OleClientSite=nil) then exit;

    CreateILockBytesOnHGlobal(0, TRUE,LockBytes);
    if (LockBytes = nil) then exit;
    if (StgCreateDocfileOnILockBytes(LockBytes, STGM_SHARE_EXCLUSIVE or STGM_CREATE or STGM_READWRITE, 0,Storage) <> S_OK) then begin
      LockBytes._Release;
      exit;
    end;

    if (Storage = nil) then exit;
    OleObject:=GetOleObject(OleClientSite, Storage);
    if (OleObject = nil) then exit;
    OleSetContainedObject(OleObject, TRUE);

    ZeroMemory(@reobject, sizeof(TReobject));
    reobject.cbStruct := sizeof(TReobject);
    OleObject.GetUserClassID(clsid);
    reobject.clsid := clsid;
    reobject.cp := REO_CP_SELECTION;
    reobject.dvaspect := DVASPECT_CONTENT;
    reobject.poleobj := OleObject;
    reobject.polesite := OleClientSite;
    reobject.pstg := Storage;

    RichEditOle.InsertObject(reobject);
  finally
    DeleteObject(FBmp)
  end;
end;


procedure InsertBitmapToRichEdit(Wnd:HWND; bmp:hBitmap);
begin
  with TImageDataObject.Create do
  try
    InsertBitmap(Wnd,Bmp);
  finally
    Free;
  end
end;

end.
