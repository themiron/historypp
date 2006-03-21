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
  m_globaldefs, m_api, hpp_messages,
  hpp_global, hpp_contacts, hpp_events, hpp_forms;

type
  TEventDetailsFrm = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    EMsgType: TEdit;
    EDateTime: TTntEdit;
    PrevBtn: TButton;
    NextBtn: TButton;
    bnReply: TButton;
    CloseBtn: TButton;
    GroupBox4: TGroupBox;
    Panel1: TPanel;
    EText: TTntMemo;
    Panel7: TPanel;
    Panel8: TPanel;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    EFromNick: TTntEdit;
    EFromUIN: TEdit;
    EFromMore: TButton;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    EToNick: TTntEdit;
    EToUIN: TEdit;
    EToMore: TButton;
    procedure PrevBtnClick(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure EFromMoreClick(Sender: TObject);
    procedure EToMoreClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CloseBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure bnReplyClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    //FRowIdx: integer;
    FParentForm: THistoryFrm;
    FItem: Integer;
    Prev,Next: Integer;
//    procedure SetRowIdx(const Value: integer);
    procedure OnCNChar(var Message: TWMChar); message WM_CHAR;
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);message wm_GetMinMaxInfo;
    procedure LoadPosition;
    procedure SavePosition;
    procedure SetItem(const Value: Integer);

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

uses hpp_database;

{$I m_database.inc}
{$I m_langpack.inc}
{$I m_clist.inc}
{$I m_userinfo.inc}
{$I m_icq.inc}

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
//load last position and filter setting
begin
  if DBGetContactSettingDWord(0,'HistoryPlusPlus','EDPosWidth',0)<>0 then begin
    Top:=DBGetContactSettingDWord(0,'HistoryPlusPlus','EDPosTop',0);
    Left:=DBGetContactSettingDWord(0,'HistoryPlusPlus','EDPosLeft',0);
    Height:=DBGetContactSettingDWord(0,'HistoryPlusPlus','EDPosHeight',0);
    Width:=DBGetContactSettingDWord(0,'HistoryPlusPlus','EDPosWidth',0);
  end;
end;

procedure TEventDetailsFrm.SavePosition;
//load position and filter setting
begin
  DBWriteContactSettingDWord(0,'HistoryPlusPlus','EDPosTop',Top);
  DBWriteContactSettingDWord(0,'HistoryPlusPlus','EDPosLeft',Left);
  DBWriteContactSettingDWord(0,'HistoryPlusPlus','EDPosHeight',Height);
  DBWriteContactSettingDWord(0,'HistoryPlusPlus','EDPosWidth',Width);
end;


procedure TEventDetailsFrm.FormShow(Sender: TObject);
begin
  LoadPosition;
end;

procedure TEventDetailsFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TEventDetailsFrm.CloseBtnClick(Sender: TObject);
begin
  Self.Release;
end;

procedure TEventDetailsFrm.FormCreate(Sender: TObject);
begin
  DesktopFont := True;
  MakeFontsParent(Self);
  TranslateForm;
  Prev := -1;
  Next := -1;
end;

procedure TEventDetailsFrm.SetItem(const Value: Integer);
var
  FromContact,ToContact : boolean;

  function GetMsgType(MesType: TMessageTypes; EventInfo: Word): string;
  begin
    if mtMessage in MesType then
      Result := Translate('Message')
    else if mtURL in MesType then
      Result := Translate('URL')
    else if mtFile in MesType then
      Result := Translate('File Transfer')
    else if mtContacts in MesType then
      Result := Translate('Contacts')
    //else if mtAdded in MesType then
    //  Result := Translate('You Were Added Message')
    //else if mtAuthRequest in MesType then
    //  Result := Translate('Authorisation Request')
    else if mtSystem in MesType then
      Result := Translate('System message')
    else if mtSMS in MesType then
      Result := Translate('SMS Message')
    else if mtWebPager in MesType then
      Result := Translate('WebPager')
    else if mtEmailExpress in MesType then
      Result := Translate('EMail Express')
    else if mtOther in MesType then
      Result := Translate('Other event')+' '+IntToStr(EventInfo);
  end;

begin
  Assert(Assigned(FParentForm));
  FItem := Value;
  EMsgType.Text := GetMsgType(FParentForm.hg.Items[Item].MessageType,FParentForm.hg.Items[Item].EventType);
  EDateTime.Text := TimestampToString(FParentForm.hg.Items[Item].Time);
  FromContact := false;
  ToContact := false;
  if mtIncoming in FParentForm.hg.Items[Item].MessageType then begin
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
  EFromUIN.Text := GetContactID(FROMhContact,FParentForm.Protocol,FromContact);
  EToNick.Text := GetContactDisplayName(TOhContact,FParentForm.Protocol,ToContact);
  EToUIN.Text := GetContactID(TOhContact,FParentForm.Protocol,ToContact);
  //EText.Lines.Clear
  EText.Lines.Text:=FParentForm.hg.Items[Item].Text;
  //EText.Lines.
  if FromContact or ToContact then
    bnReply.Enabled := False
  else
    bnReply.Enabled := True;
  // check forward and back buttons
  Prev := FParentForm.hg.GetPrev(Item);
  Next := FParentForm.hg.GetNext(Item);
  NextBtn.Enabled := (Next <> -1);
  PrevBtn.Enabled := (Prev <> -1);
  if FParentForm.hg.selected <> Item then
    FParentForm.hg.Selected := Item;
end;

procedure TEventDetailsFrm.FormHide(Sender: TObject);
begin
  SavePosition;
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
begin
  Caption := Translate(PChar(Caption));
  GroupBox1.Caption:=Translate(PChar(GroupBox1.Caption));
  GroupBox2.Caption:=Translate(PChar(GroupBox2.Caption));
  GroupBox3.Caption:=Translate(PChar(GroupBox3.Caption));
  GroupBox4.Caption:=Translate(PChar(GroupBox4.Caption));
  Label1.Caption:=Translate(PChar(Label1.Caption));
  Label2.Caption:=Translate(PChar(Label2.Caption));
  Label3.Caption:=Translate(PChar(Label3.Caption));
  Label4.Caption:=Translate(PChar(Label4.Caption));
  Label5.Caption:=Translate(PChar(Label5.Caption));
  Label6.Caption:=Translate(PChar(Label6.Caption));
  EFromMore.Caption:=Translate(PChar(EFromMore.Caption));
  EToMore.Caption:=Translate(PChar(EToMore.Caption));
  PrevBtn.Caption:=Translate(PChar(PrevBtn.Caption));
  NextBtn.Caption:=Translate(PChar(NextBtn.Caption));
  CloseBtn.Caption:=Translate(PChar(CloseBtn.Caption));
  bnReply.Caption:=Translate(PChar(bnReply.Caption));
end;

end.
