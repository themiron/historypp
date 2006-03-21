unit PassForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, TntComCtrls, Menus, Checksum, ExtCtrls, StdCtrls,
  m_GlobalDefs, m_api,
  hpp_global, hpp_contacts, hpp_database, hpp_forms;

type
  TfmPass = class(TForm)
    Image1: TImage;
    rbProtAll: TRadioButton;
    rbProtSel: TRadioButton;
    lvCList: TTntListView;
    bnPass: TButton;
    laPassState: TLabel;
    Bevel1: TBevel;
    bnCancel: TButton;
    bnOK: TButton;
    PopupMenu1: TPopupMenu;
    Refresh1: TMenuItem;
    Label1: TLabel;
    procedure bnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rbProtSelClick(Sender: TObject);
    procedure bnPassClick(Sender: TObject);
    procedure bnOKClick(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    PassMode: Byte;
    Password: String;
    FLastContact: THandle;
    procedure FillList;
    procedure UpdatePassword;
    procedure SetlastContact(const Value: THandle);
    procedure TranslateForm;
  public
    property LastContact: THandle read FLastContact write SetLastContact;
    { Public declarations }
  end;

var
  fmPass: TfmPass;

const
  PASSMODE_PROTNONE = 0; // no protection, not used
  PASSMODE_PROTALL = 1; // protect all contacts
  PASSMODE_PROTSEL = 2; // protect ONLY selected contacts
  PASSMODE_PROTNOTSEL = 3; // protect ALL, except selected contacts (not used)

function ReadPassModeFromDB: Byte;
function GetPassMode: Byte;
function GetPassword: String;
function IsPasswordBlank(Password: String): Boolean;
function IsUserProtected(hContact: THandle): Boolean;
function CheckPassword(Pass: String): Boolean;

procedure RunPassForm;

implementation

uses PassNewForm, hpp_options, PassCheckForm;

{$I m_database.inc}
{$I m_langpack.inc}
{$I m_clist.inc}

{$R *.DFM}

procedure RunPassForm;
begin
if Assigned(PassFm) then begin
  PassFm.Show;
  exit;
  end;
if Assigned(PassCheckFm) then begin
  PassCheckFm.Show;
  exit;
  end;
if IsPasswordBlank(GetPassword) then begin
  if not Assigned(PassFm) then begin
    PassFm := TfmPass.Create(nil);
    end;
  PassFm.Show;
  end
else begin
  PassCheckFm := TfmPassCheck.Create(nil);
  PassCheckFm.Show;
  end;
end;

function CheckPassword(Pass: String): Boolean;
begin
  Result := (DigToBase(HashString(Pass)) = GetPassword);
end;

function IsUserProtected(hContact: THandle): Boolean;
var
mode: Byte;
begin
  Result := False;
  mode := GetPassMode;
  if mode = PASSMODE_PROTNONE then Result := False;
  if mode = PASSMODE_PROTALL then Result := True;
  if mode = PASSMODE_PROTSEL then
    Result := (DBGetContactSettingByte(hContact,hppDBName,'PasswordProtect',0) = 1);
  if mode = PASSMODE_PROTNOTSEL then
    Result := (DBGetContactSettingByte(hContact,hppDBName,'PasswordProtect',1) = 1);
  if IsPasswordBlank(GetPassword) then
  
end;

function IsPasswordBlank(Password: String): Boolean;
begin
  Result := (Password = DigToBase(HashString('')));
end;

function GetPassword: String;
begin
  Result := GetDBStr(hppDBName,'Password',DigToBase(HashString('')));
end;

function ReadPassModeFromDB: Byte;
begin
  Result := GetDBByte(hppDBName,'PasswordMode',PASSMODE_PROTALL);
end;

function GetPassMode: Byte;
begin
Result := ReadPassModeFromDB;
if IsPasswordBlank(GetPassword) then
  Result := PASSMODE_PROTNONE;
end;

procedure TfmPass.bnCancelClick(Sender: TObject);
begin
close;
end;

procedure TfmPass.FillList;
  procedure AddContact(Contact: THandle);
  var
  li: TTntListItem;
  Check: Byte;
  Capt: WideString;
  begin
  li := lvCList.Items.Add;
  if Contact = 0 then begin
    Capt := GetContactDisplayName(Contact,'ICQ');
    Capt := AnsiToWideString(Translate('System History'),CP_ACP)+' ('+Capt+')';
  end else
    Capt := GetContactDisplayName(Contact);
  li.Caption := Capt;
  li.Data := Pointer(Contact);
  Check := DBGetContactSettingByte(Contact,hppDBName,'PasswordProtect',0);
  if Check = 1 then
    li.Checked := True;
  end;
var
hCont: THandle;
begin
lvCList.Items.BeginUpdate;
try
  lvCList.Items.Clear;
  hCont := PluginLink.CallService(MS_DB_CONTACT_FINDFIRST,0,0);
  while hCont <> 0 do begin
    AddContact(hCont);
    hCont := PluginLink.CallService(MS_DB_CONTACT_FINDNEXT,hCont,0);
  end;
  AddContact(0);
  lvCList.SortType := stNone;
  lvCList.SortType := stText;
finally
  lvCList.Items.EndUpdate;
  end;
end;

procedure TfmPass.FormCreate(Sender: TObject);
begin
  DesktopFont := True;
  MakeFontsParent(Self);
  TranslateForm;
  FillList;
  PassMode := ReadPassModeFromDB;
  if not (PassMode in [PASSMODE_PROTALL,PASSMODE_PROTSEL]) then
    PassMode := PASSMODE_PROTALL;
  Password := GetPassword;

  if PassMode = PASSMODE_PROTSEL then
    rbProtSel.Checked := true
  else
    rbProtAll.Checked := true;
  rbProtSelClick(Self);
  UpdatePassword;
end;

procedure TfmPass.rbProtSelClick(Sender: TObject);
begin
if rbProtSel.Checked then
  PassMode := PASSMODE_PROTSEL;
if rbProtAll.Checked then
  PassMode := PASSMODE_PROTALL;

if rbProtSel.Checked then begin
  lvCList.Enabled := True;
  lvCList.Color := clWindow;
  end
else begin
  lvCList.Color := clInactiveBorder;
  lvCList.Enabled := False;
  end;
end;

procedure TfmPass.bnPassClick(Sender: TObject);
begin
with TfmPassNew.Create(Self) do begin
  if ShowModal = mrOK then begin
    Password := DigToBase(HashString(edPass.Text));
    UpdatePassword;
    end;
  Free;
  end;
end;

procedure TfmPass.UpdatePassword;
begin
if Password = DigToBase(HashString('')) then begin
  // password not set
  laPassState.Font.Style := laPassState.Font.Style + [fsBold];
  laPassState.Caption := Translate('Password not set');
  end
else begin
  // password set
  laPassState.ParentFont := True;
  laPassState.Caption := Translate('Password set');
  end;
end;

procedure TfmPass.bnOKClick(Sender: TObject);
var
i: Integer;
li: TListItem;
begin
WriteDBByte(hppDBName,'PasswordMode',PassMode);
WriteDBStr(hppDBName,'Password',Password);
if PassMode = PASSMODE_PROTSEL then begin
  for i := 0 to lvCList.Items.Count-1 do begin
    li := lvCList.Items[i];
    if li.Checked then
      DBWriteContactSettingByte(Integer(li.Data),hppDBName,'PasswordProtect',1)
    else
      DBDeleteContactSetting(Integer(li.Data),hppDBName,'PasswordProtect');
    end;
  end;

Close;
end;

procedure TfmPass.SetlastContact(const Value: THandle);
begin
FLastContact := Value;
end;

procedure TfmPass.Refresh1Click(Sender: TObject);
begin
FillList;
end;

procedure TfmPass.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action := caFree;
end;

procedure TfmPass.FormDestroy(Sender: TObject);
begin
try
  PassFm := nil;
except
  end;
end;

procedure TfmPass.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TfmPass.TranslateForm;
begin
Caption := Translate(PChar(Caption));
Label1.Caption := Translate(PChar(Label1.Caption));
rbProtAll.Caption := Translate(PChar(rbProtAll.Caption));
rbProtSel.Caption := Translate(PChar(rbProtSel.Caption));
bnPass.Caption := Translate(PChar(bnPass.Caption));
bnOK.Caption := Translate(PChar(bnOK.Caption));
bnCancel.Caption := Translate(PChar(bnCancel.Caption));
Refresh1.Caption := Translate(PChar(Refresh1.Caption));
end;

end.
