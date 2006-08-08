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
  hpp_global, hpp_contacts, hpp_events, hpp_forms, TntExtCtrls, ComCtrls,
  TntComCtrls, Menus, TntMenus, RichEdit;

type

  TEventDetailsFrm = class(TTntForm)
    paBottom: TTntPanel;
    Panel3: TTntPanel;
    paUser: TTntPanel;
    paInfo: TTntPanel;
    GroupBox1: TTntGroupBox;
    Label1: TTntLabel;
    Label2: TTntLabel;
    EMsgType: TTntEdit;
    EDateTime: TTntEdit;
    PrevBtn: TTntButton;
    NextBtn: TTntButton;
    bnReply: TTntButton;
    CloseBtn: TTntButton;
    Panel7: TTntPanel;
    Panel8: TTntPanel;
    GroupBox2: TTntGroupBox;
    Label3: TTntLabel;
    Label4: TTntLabel;
    EFromNick: TTntEdit;
    EFromUIN: TTntEdit;
    EFromMore: TTntButton;
    GroupBox3: TTntGroupBox;
    Label5: TTntLabel;
    Label6: TTntLabel;
    EToNick: TTntEdit;
    EToUIN: TTntEdit;
    EToMore: TTntButton;
    EText: TTntRichEdit;
    pmEText: TTntPopupMenu;
    CopyText: TTntMenuItem;
    CopyAll: TTntMenuItem;
    SelectAll: TTntMenuItem;
    N1: TTntMenuItem;
    ReplyQuoted1: TTntMenuItem;
    SendMessage1: TTntMenuItem;
    paText: TTntPanel;
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
    procedure FormResize(Sender: TObject);
    procedure pmETextPopup(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure CopyTextClick(Sender: TObject);
    procedure CopyAllClick(Sender: TObject);
    procedure SendMessage1Click(Sender: TObject);
    procedure ReplyQuoted1Click(Sender: TObject);
  private
    //FRowIdx: integer;
    FParentForm: THistoryFrm;
    FItem: Integer;
    Prev,Next: Integer;

//    procedure SetRowIdx(const Value: integer);
    procedure OnCNChar(var Message: TWMChar); message WM_CHAR;
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message wm_GetMinMaxInfo;
    procedure WMNotify(var Message: TWMNotify); message WM_Notify;
    procedure LoadPosition;
    procedure SavePosition;
    procedure SetItem(const Value: Integer);
    procedure ProcessRichEdit(const FItem: Integer);
    procedure TranslateForm;
    { Private declarations }
  public
    TOhContact:THandle;
    FROMhContact:THandle;
    property ParentForm:THistoryFrm read FParentForm write fParentForm;
//   property RowIdx:integer read FRowIdx write SetRowIdx; //line of grid, whoms details should be shown
    property Item: Integer read FItem write SetItem;
  end;

var
  EventDetailsFrm: TEventDetailsFrm;

implementation

uses hpp_database, hpp_options, hpp_services;

{$R *.DFM}

{ TForm1 }

procedure TEventDetailsFrm.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
  inherited;
  with Msg.MinMaxInfo^ do
    begin
    ptMinTrackSize.x:= 466;
    ptMinTrackSize.y:= 340;
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
  if (ssCtrl in Shift) then begin
    if key=Ord('R') then begin
      ReplyQuoted1.Click;
      key:=0;
    end;
    if key=Ord('M') then begin
      SendMessage1.Click;
      key:=0;
    end;
  end;
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
var
  re_mask: integer;
begin
  Icon.ReleaseHandle;
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_CONTACTHISTORY].handle);
  DesktopFont := True;
  MakeFontsParent(Self);
  TranslateForm;
  Prev := -1;
  Next := -1;
  //EText.Parent := Self;
  re_mask := SendMessage(EText.Handle,EM_GETEVENTMASK, 0, 0);
  SendMessage(EText.Handle,EM_SETMARGINS,EC_RIGHTMARGIN or EC_LEFTMARGIN,MakeLParam(3,3));
  SendMessage(EText.Handle,EM_SETEVENTMASK,0,re_mask or ENM_LINK);
  SendMessage(EText.Handle,EM_AUTOURLDETECT,1,0);

  LoadPosition;
end;

procedure TEventDetailsFrm.SetItem(const Value: Integer);
var
  FromContact,ToContact : boolean;

  function GetMsgType(MesType: TMessageTypes; EventInfo: Word): WideString;
  var
    mt: TMessageType;
  begin
    exclude(MesType,mtIncoming);
    exclude(MesType,mtOutgoing);
    exclude(MesType,mtOther);
    for mt := Low(EventNames) to High(EventNames) do begin
      if mt in MesType then begin
        Result := TranslateWideW(EventNames[mt]{TRANSLATE-IGNORE});
        exit;
      end;
    end;
    Result := TranslateWideW(EventNames[mtOther])+' '+IntToStr(EventInfo{TRANSLATE-IGNORE});
  end;

begin
  Assert(Assigned(FParentForm));
  FItem := Value;

  EMsgType.Text := GetMsgType(FParentForm.hg.Items[FItem].MessageType,FParentForm.hg.Items[FItem].EventType);
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
  EFromNick.Text := GetContactDisplayName(FROMhContact,FParentForm.Protocol,FromContact);
  EFromUIN.Text := AnsiToWideString(GetContactID(FROMhContact,FParentForm.Protocol,FromContact),ParentForm.UserCodepage);
  EToNick.Text := GetContactDisplayName(TOhContact,FParentForm.Protocol,ToContact);
  EToUIN.Text := AnsiToWideString(GetContactID(TOhContact,FParentForm.Protocol,ToContact),ParentForm.UserCodepage);

  // BeginUpdate and EndUpdate needed 'cose we have visual artefacts on screen
  // but it's better to lock and unlock rich in DoSupport... services
  EText.Lines.BeginUpdate;
  EText.Clear;
  if ParentForm.hg.GetItemRTL(FItem) then EText.BiDiMode := bdRightToLeft
                                     else EText.BiDiMode := bdLeftToRight;
  //ParentForm.hg.SetRichRTL(ParentForm.hg.GetItemRTL(FItem),EText,false);

  EText.Text:=FParentForm.hg.Items[FItem].Text;
  ProcessRichEdit(FItem);
  // 'cose smileys are selected sometimes
  EText.SelLength := 0;
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

procedure TEventDetailsFrm.FormResize(Sender: TObject);
begin
  Panel8.Width := ClientWidth div 2;
end;

procedure TEventDetailsFrm.TranslateForm;

  procedure TranslateMenu(mi: TMenuItem);
  var
    i: integer;
  begin
    for i := 0 to mi.Count-1 do
      if mi.Items[i].Caption <> '-' then begin
        TTntMenuItem(mi.Items[i]).Caption := TranslateWideW(mi.Items[i].Caption{TRANSLATE-IGNORE});
          if mi.Items[i].Count > 0 then TranslateMenu(mi.Items[i]);
      end;
  end;

begin
  Caption := TranslateWideW(Caption);
  GroupBox1.Caption:=TranslateWideW(GroupBox1.Caption);
  GroupBox2.Caption:=TranslateWideW(GroupBox2.Caption);
  GroupBox3.Caption:=TranslateWideW(GroupBox3.Caption);
  Label1.Caption:=TranslateWideW(Label1.Caption);
  Label2.Caption:=TranslateWideW(Label2.Caption);
  Label3.Caption:=TranslateWideW(Label3.Caption);
  Label4.Caption:=TranslateWideW(Label4.Caption);
  Label5.Caption:=TranslateWideW(Label5.Caption);
  Label6.Caption:=TranslateWideW(Label6.Caption);
  EFromMore.Caption:=TranslateWideW(EFromMore.Caption);
  EToMore.Caption:=TranslateWideW(EToMore.Caption);
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
  link: TENLink;
  tr: TextRange;
  WideURL: WideString;
  AnsiURL: String;
begin
  if Message.NMHdr^.code = EN_LINK then begin
    link := TENLink(Pointer(Message.NMHdr)^);
    if link.msg = WM_LBUTTONUP then begin
      tr.chrg := link.chrg;
      if hppOSUnicode then begin
        SetLength(WideURL,link.chrg.cpMax-link.chrg.cpMin);
        tr.lpstrText := @WideURL[1];
      end else begin
        SetLength(AnsiUrl,link.chrg.cpMax-link.chrg.cpMin);
        tr.lpstrText := @AnsiUrl[1];
      end;
      EText.Perform(EM_GETTEXTRANGE,0,LongInt(@tr));
      if hppOSUnicode then AnsiURL := WideToAnsiString(WideURL,CP_ACP);
      PluginLink.CallService(MS_UTILS_OPENURL,1,Integer(Pointer(@AnsiURL[1])));
    end;
  end;
  inherited;
end;

end.

