{-----------------------------------------------------------------------------
 EventDetailForm (historypp project)

 Version:   1.4
 Created:   31.03.2003
 Author:    Oxygen

 [ Description ]

 Form for details about event

 [ History ]

 1.4
 - Added horz scroll bar to memo

 1.0 (31.03.2003) - Initial version

 [ Modifications ]
 * (29.05.2003) Added scroll bar to memo

 [ Knows Inssues ]
 None

 Original file copyright (c) Christian Kastner
 Copyright (c) Art Fedorov, 2003
-----------------------------------------------------------------------------}


unit EventDetailForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, TntStdCtrls,
  HistoryGrid, HistoryForm,
  TntForms,
  m_globaldefs, m_api, hpp_messages,
  hpp_global, hpp_contacts, hpp_events, hpp_forms, hpp_richedit,
  TntExtCtrls, ComCtrls,
  Menus, TntMenus, RichEdit, Buttons, TntButtons, HistoryControls;

type

  TEventDetailsFrm = class(TTntForm)
    paBottom: THppPanel;
    Panel3: THppPanel;
    paInfo: THppPanel;
    GroupBox: TTntGroupBox;
    laType: TTntLabel;
    laDateTime: TTntLabel;
    EMsgType: THppEdit;
    bnReply: TTntButton;
    CloseBtn: TTntButton;
    laFrom: TTntLabel;
    laTo: TTntLabel;
    EFrom: THppEdit;
    ETo: THppEdit;
    EText: THPPRichedit;
    pmEText: TTntPopupMenu;
    CopyText: TTntMenuItem;
    CopyAll: TTntMenuItem;
    SelectAll: TTntMenuItem;
    N1: TTntMenuItem;
    ReplyQuoted1: TTntMenuItem;
    SendMessage1: TTntMenuItem;
    paText: THppPanel;
    N2: TTntMenuItem;
    ToogleItemProcessing: TTntMenuItem;
    EFromMore: THppSpeedButton;
    EDateTime: THppEdit;
    EToMore: THppSpeedButton;
    PrevBtn: THppSpeedButton;
    NextBtn: THppSpeedButton;
    OpenLinkNW: TTntMenuItem;
    OpenLink: TTntMenuItem;
    CopyLink: TTntMenuItem;
    N4: TTntMenuItem;
    procedure PrevBtnClick(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure EFromMoreClick(Sender: TObject);
    procedure EToMoreClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CloseBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bnReplyClick(Sender: TObject);
    procedure pmETextPopup(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure CopyTextClick(Sender: TObject);
    procedure CopyAllClick(Sender: TObject);
    procedure SendMessage1Click(Sender: TObject);
    procedure ReplyQuoted1Click(Sender: TObject);
    procedure ToogleItemProcessingClick(Sender: TObject);
    procedure ETextResizeRequest(Sender: TObject; Rect: TRect);
    procedure OpenLinkNWClick(Sender: TObject);
    procedure OpenLinkClick(Sender: TObject);
    procedure CopyLinkClick(Sender: TObject);
    procedure ETextMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    //FRowIdx: integer;
    FParentForm: THistoryFrm;
    FItem: Integer;
    Prev,Next: Integer;
    FRichHeight: Integer;
    FOverURL: Boolean;
    SavedLinkUrl: String;

//    procedure SetRowIdx(const Value: integer);
    procedure OnCNChar(var Message: TWMChar); message WM_CHAR;
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSysColorChange(var Message: TMessage); message WM_SYSCOLORCHANGE;
    procedure LoadPosition;
    procedure SavePosition;
    procedure SetItem(const Value: Integer);
    procedure TranslateForm;
    procedure LoadButtonIcons;
    { Private declarations }
    procedure HMIcons2Changed(var M: TMessage); message HM_NOTF_ICONS2CHANGED;
    procedure HMEventDeleted(var Message: TMessage); message HM_MIEV_EVENTDELETED;
  public
    TOhContact:THandle;
    FROMhContact:THandle;
    property ParentForm:THistoryFrm read FParentForm write fParentForm;
//   property RowIdx:integer read FRowIdx write SetRowIdx; //line of grid, whoms details should be shown
    property Item: Integer read FItem write SetItem;
    procedure ProcessRichEdit(const FItem: Integer);
  end;

var
  EventDetailsFrm: TEventDetailsFrm;

implementation

uses hpp_database, hpp_options, hpp_services;

{$R *.DFM}

{ TForm1 }

procedure TEventDetailsFrm.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
begin
  inherited;
  with Message.MinMaxInfo^ do begin
    ptMinTrackSize.x:= 376;
    ptMinTrackSize.y:= 240;
  end
end;

procedure TEventDetailsFrm.PrevBtnClick(Sender: TObject);
begin
  Item := Prev;
end;

procedure TEventDetailsFrm.ProcessRichEdit(const FItem: Integer);
var
  ItemRenderDetails: TItemRenderDetails;
begin
  ZeroMemory(@ItemRenderDetails,SizeOf(ItemRenderDetails));
  ItemRenderDetails.cbSize := SizeOf(ItemRenderDetails);
  ItemRenderDetails.hContact := ParentForm.hContact;
  ItemRenderDetails.hDBEvent := ParentForm.History[ParentForm.GridIndexToHistory(FItem)];
  ItemRenderDetails.pProto := PChar(ParentForm.hg.Items[FItem].Proto);
  ItemRenderDetails.pModule := PChar(ParentForm.hg.Items[FItem].Module);
  ItemRenderDetails.pText := nil;
  ItemRenderDetails.pExtended := PChar(ParentForm.hg.Items[FItem].Extended);
  ItemRenderDetails.dwEventTime := ParentForm.hg.Items[FItem].Time;
  ItemRenderDetails.wEventType := ParentForm.hg.Items[FItem].EventType;
  ItemRenderDetails.IsEventSent := (mtOutgoing in ParentForm.hg.Items[FItem].MessageType);
  {TODO: Add flag for special event details form treatment?}
  ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_EVENT;
  if ParentForm.hContact = 0 then
    ItemRenderDetails.bHistoryWindow := IRDHW_GLOBALHISTORY
  else
    ItemRenderDetails.bHistoryWindow := IRDHW_CONTACTHISTORY;
  PluginLink.NotifyEventHooks(hHppRichEditItemProcess,EText.Handle,Integer(@ItemRenderDetails));
end;

procedure TEventDetailsFrm.NextBtnClick(Sender: TObject);
begin
  Item := Next;
end;

procedure TEventDetailsFrm.EFromMoreClick(Sender: TObject);
begin
  PluginLink.CallService(MS_USERINFO_SHOWDIALOG,FROMhContact,0);
end;

procedure TEventDetailsFrm.EToMoreClick(Sender: TObject);
begin
  PluginLink.CallService(MS_USERINFO_SHOWDIALOG,TOhContact,0);
end;

procedure TEventDetailsFrm.FormDestroy(Sender: TObject);
begin
  try
  FParentForm.EventDetailFrom:=nil;
  except end;
end;

procedure TEventDetailsFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Mask: Integer;
begin
  if IsFormShortCut([pmEText],Key,Shift) then
    key := 0;

  with Sender as TWinControl do
    begin
      if Perform(CM_CHILDKEY, Key, Integer(Sender)) <> 0 then
        Exit;
      Mask := 0;
      case Key of
        VK_TAB:
          Mask := DLGC_WANTTAB;
        VK_RETURN, VK_EXECUTE, VK_ESCAPE, VK_CANCEL:
          Mask := DLGC_WANTALLKEYS;
      end;
      if (Mask <> 0)
        and (Perform(CM_WANTSPECIALKEY, Key, 0) = 0)
        and (Perform(WM_GETDLGCODE, 0, 0) and Mask = 0)
        and (Self.Perform(CM_DIALOGKEY, Key, 0) <> 0)
        then Exit;
    end;
end;

procedure TEventDetailsFrm.OnCNChar(var Message: TWMChar);
//make tabs work!
begin
  if not (csDesigning in ComponentState) then
    with Message do
    begin
      Result := 1;
      if (Perform(WM_GETDLGCODE, 0, 0) and DLGC_WANTCHARS = 0) and
        (GetParentForm(Self).Perform(CM_DIALOGCHAR,
        CharCode, KeyData) <> 0) then Exit;
      Result := 0;
    end;
end;


procedure TEventDetailsFrm.LoadPosition;
begin
  Utils_RestoreFormPosition(Self,0,hppDBName,'EventDetail.');
  // use MagneticWindows.dll
  PluginLink.CallService(MS_MW_ADDWINDOW,WindowHandle,0);
end;

procedure TEventDetailsFrm.SavePosition;
begin
  Utils_SaveFormPosition(Self,0,hppDBName,'EventDetail.');
  // use MagneticWindows.dll
  PluginLink.CallService(MS_MW_REMWINDOW,WindowHandle,0);
end;


procedure TEventDetailsFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=caFree;
  SavePosition;
end;

procedure TEventDetailsFrm.CloseBtnClick(Sender: TObject);
begin
  SavePosition;
  Self.Release;
end;

procedure TEventDetailsFrm.FormCreate(Sender: TObject);
//var
  //re_mask: integer;
begin
  Icon.ReleaseHandle;
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_CONTACTHISTORY].handle);

  DesktopFont := True;
  MakeFontsParent(Self);

  DoubleBuffered := True;
  MakeDoubleBufferedParent(Self);

  EText.Brush.Style := bsClear;

  LoadButtonIcons;
  TranslateForm;
  Prev := -1;
  Next := -1;
  //re_mask := SendMessage(EText.Handle,EM_GETEVENTMASK, 0, 0);
  //SendMessage(EText.Handle,EM_SETEVENTMASK,0,re_mask or ENM_LINK or ENM_REQUESTRESIZE);
  //SendMessage(EText.Handle,EM_AUTOURLDETECT,1,0);
  //SendMessage(EText.Handle,EM_SETMARGINS,EC_RIGHTMARGIN or EC_LEFTMARGIN,MakeLParam(3,3));
  //SendMessage(EText.Handle,EM_SETMARGINS,EC_RIGHTMARGIN or EC_LEFTMARGIN,0);
  LoadPosition;
end;

procedure TEventDetailsFrm.SetItem(const Value: Integer);
var
  FromContact,ToContact : boolean;
begin
  Assert(Assigned(FParentForm));
  FItem := Value;
  EMsgType.Text := TranslateWideW(GetMessageRecord(FParentForm.hg.Items[FItem].MessageType).Name{TRANSLATE-IGNORE});
  EMsgType.Text := WideFormat('%s #%u',[EMsgType.Text,FParentForm.hg.Items[FItem].EventType]);
  EDateTime.Text := TimestampToString(FParentForm.hg.Items[FItem].Time);
  FromContact := false;
  ToContact := false;
  if mtIncoming in FParentForm.hg.Items[FItem].MessageType then begin
    FROMhContact := FParentForm.hContact;
    if FROMhContact = 0 then FromContact := true;
    TOhContact:=0;
  end else begin
    TOhContact := FParentForm.hContact;
    if TOhContact = 0 then ToContact := true;
    FromhContact:=0;
  end;

  EFromMore.Enabled := not FromContact;
  EToMore.Enabled := not ToContact;
  EFrom.Text := GetContactDisplayName(FROMhContact,FParentForm.Protocol,FromContact)+
                ' ('+
                AnsiToWideString(FParentForm.Protocol+': '+GetContactID(FROMhContact,FParentForm.Protocol,FromContact),ParentForm.UserCodepage)+
                ')';
  ETo.Text   := GetContactDisplayName(TOhContact,FParentForm.Protocol,ToContact)+
                ' ('+
                AnsiToWideString(FParentForm.Protocol+': '+GetContactID(TOhContact,FParentForm.Protocol,ToContact),ParentForm.UserCodepage)+
                ')';

  EText.Lines.BeginUpdate;
  ParentForm.hg.ApplyItemToRich(FItem,EText,false,true);
  EText.SelStart := 0;
  //EText.SelLength := 0;
  SendMessage(EText.Handle,EM_REQUESTRESIZE,0,0);
  EText.Lines.EndUpdate;

  if FromContact or ToContact then
    bnReply.Enabled := False
  else
    bnReply.Enabled := True;

  // check forward and back buttons
  Prev := FParentForm.hg.GetPrev(FItem);
  Next := FParentForm.hg.GetNext(FItem);
  NextBtn.Enabled := (Next <> -1);
  PrevBtn.Enabled := (Prev <> -1);

  if FParentForm.hg.selected <> FItem then
    FParentForm.hg.Selected := FItem;
end;

procedure TEventDetailsFrm.bnReplyClick(Sender: TObject);
begin
  FParentForm.ReplyQuoted(FItem);
end;

procedure TEventDetailsFrm.TranslateForm;
begin
  Caption := TranslateWideW(Caption);
  GroupBox.Caption:=TranslateWideW(GroupBox.Caption);
  laType.Caption:=TranslateWideW(laType.Caption);
  laDateTime.Caption:=TranslateWideW(laDateTime.Caption);
  laFrom.Caption:=TranslateWideW(laFrom.Caption);
  laTo.Caption:=TranslateWideW(laTo.Caption);
  EFromMore.Hint:=TranslateWideW(EFromMore.Hint);
  EToMore.Hint:=TranslateWideW(EToMore.Hint);
  PrevBtn.Caption:=TranslateWideW(PrevBtn.Caption);
  NextBtn.Caption:=TranslateWideW(NextBtn.Caption);
  CloseBtn.Caption:=TranslateWideW(CloseBtn.Caption);
  bnReply.Caption:=TranslateWideW(bnReply.Caption);
  TranslateMenu(pmEText.Items);
end;

procedure TEventDetailsFrm.pmETextPopup(Sender: TObject);
begin
  CopyText.Enabled := (EText.SelLength > 0);
  SendMessage1.Enabled := (ParentForm.hContact <> 0);
  ReplyQuoted1.Enabled := (ParentForm.hContact <> 0);
  ToogleItemProcessing.Checked := GridOptions.TextFormatting;
  OpenLinkNW.Visible := FOverURL;
  OpenLink.Visible := FOverURL;
  CopyLink.Visible := FOverURL;
end;

procedure TEventDetailsFrm.SelectAllClick(Sender: TObject);
begin
  EText.SelectAll;
end;

procedure TEventDetailsFrm.CopyTextClick(Sender: TObject);
begin
  EText.CopyToClipboard;
end;

procedure TEventDetailsFrm.CopyAllClick(Sender: TObject);
var
  ss,sl: integer;
begin
  //CopyToClip(EText.Lines.Text,Handle,ParentForm.UserCodepage);
  EText.Lines.BeginUpdate;
  ss := EText.SelStart;
  sl := EText.SelLength;
  EText.SelectAll;
  EText.CopyToClipboard;
  EText.SelStart := ss;
  EText.SelLength := sl;
  EText.Lines.EndUpdate;
end;

procedure TEventDetailsFrm.SendMessage1Click(Sender: TObject);
begin
  if ParentForm.hContact = 0 then exit;
  SendMessageTo(ParentForm.hContact);
end;

procedure TEventDetailsFrm.ReplyQuoted1Click(Sender: TObject);
begin
  if ParentForm.hContact = 0 then exit;
  FParentForm.ReplyQuoted(FItem);
end;

procedure TEventDetailsFrm.WMNotify(var Message: TWMNotify);
var
  p: TPoint;
  link: TENLink;
  tr: TextRange;
begin
  if Message.NMHdr^.code = EN_LINK then begin
    p := EText.ScreenToClient(Mouse.CursorPos);
    if p.Y <= FRichHeight then begin
      FOverURL := True;
      link := TENLink(Pointer(Message.NMHdr)^);
      tr.chrg := link.chrg;
      SetLength(SavedLinkUrl,link.chrg.cpMax-link.chrg.cpMin);
      tr.lpstrText := @SavedLinkUrl[1];
      EText.Perform(EM_GETTEXTRANGE,0,LongInt(@tr));
      if link.msg = WM_LBUTTONUP then begin
        OpenLinkNW.Click;
      end;
    end;
  end;
  inherited;
end;

procedure TEventDetailsFrm.WMSetCursor(var Message: TWMSetCursor);
var
  p: TPoint;
begin
  if (FRichHeight > 0) and (Message.CursorWnd = EText.Handle) and (Message.HitTest = HTCLIENT) then begin
    p := EText.ScreenToClient(Mouse.CursorPos);
    if p.Y > FRichHeight then begin
      if Windows.GetCursor <> Screen.Cursors[crIBeam] then
        Windows.SetCursor(Screen.Cursors[crIBeam]);
      Message.Result := 1;
      exit;
    end;
  end;
  inherited;
end;

procedure TEventDetailsFrm.ToogleItemProcessingClick(Sender: TObject);
begin
  GridOptions.TextFormatting := not GridOptions.TextFormatting;
end;

procedure TEventDetailsFrm.LoadButtonIcons;
begin
  with EFromMore.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := paInfo.Color;
    Canvas.FillRect(Canvas.ClipRect);
    DrawIconEx(Canvas.Handle,0,0,hppIcons[HPP_ICON_CONTACDETAILS].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with EToMore.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := paInfo.Color;
    Canvas.FillRect(Canvas.ClipRect);
    DrawIconEx(Canvas.Handle,0,0,hppIcons[HPP_ICON_CONTACDETAILS].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with PrevBtn.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := paInfo.Color;
    Canvas.FillRect(Canvas.ClipRect);
    DrawIconEx(Canvas.Handle,0,0,hppIcons[HPP_ICON_SEARCHUP].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with NextBtn.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := paInfo.Color;
    Canvas.FillRect(Canvas.ClipRect);
    DrawIconEx(Canvas.Handle,0,0,hppIcons[HPP_ICON_SEARCHDOWN].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
end;

procedure TEventDetailsFrm.HMIcons2Changed(var M: TMessage);
begin
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_CONTACTHISTORY].handle);
  LoadButtonIcons;
end;

procedure TEventDetailsFrm.ETextResizeRequest(Sender: TObject; Rect: TRect);
begin
  FRichHeight := Rect.Bottom - Rect.Top;
end;

procedure TEventDetailsFrm.HMEventDeleted(var Message: TMessage);
begin
  if Message.WParam = ParentForm.History[ParentForm.GridIndexToHistory(FItem)] then
    Close;
end;

procedure TEventDetailsFrm.WMSysColorChange(var Message: TMessage);
begin
  inherited;
  LoadButtonIcons;
  Repaint;
end;

procedure TEventDetailsFrm.OpenLinkNWClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  PluginLink.CallService(MS_UTILS_OPENURL,1,LPARAM(@SavedLinkUrl[1]));
  SavedLinkUrl := '';
end;

procedure TEventDetailsFrm.OpenLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  PluginLink.CallService(MS_UTILS_OPENURL,0,LPARAM(@SavedLinkUrl[1]));
  SavedLinkUrl := '';
end;

procedure TEventDetailsFrm.CopyLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  CopyToClip(AnsiToWideString(SavedLinkUrl,CP_ACP),Handle,CP_ACP);
  SavedLinkUrl := '';
end;

procedure TEventDetailsFrm.ETextMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FOverURL := False;
end;

end.

