unit PassNewForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, m_GlobalDefs, m_api, PasswordEditControl;

type
  TfmPassNew = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edPass: TPasswordEdit;
    edConf: TPasswordEdit;
    Label3: TLabel;
    bnCancel: TButton;
    bnOK: TButton;
    Label4: TLabel;
    Image1: TImage;
    Label5: TLabel;
    Bevel1: TBevel;
    procedure bnCancelClick(Sender: TObject);
    procedure bnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure TranslateForm;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmPassNew: TfmPassNew;

implementation

{$I m_langpack.inc}
{$R *.DFM}

procedure TfmPassNew.bnCancelClick(Sender: TObject);
begin
ModalResult := mrCancel;
end;

procedure TfmPassNew.bnOKClick(Sender: TObject);
begin
if edPass.Text <> edConf.Text then begin
  MessageBox(Handle, Translate('Password and Confirm fields should be similar'),
  Translate('Error'), MB_OK or MB_DEFBUTTON1 or MB_ICONEXCLAMATION);
  exit;
  end;
ModalResult := mrOK;
end;

procedure TfmPassNew.TranslateForm;
begin
Caption := Translate(PChar(Caption));
Label1.Caption := Translate(PChar(Label1.Caption));
Label5.Caption := Translate(PChar(Label5.Caption));
Label2.Caption := Translate(PChar(Label2.Caption));
Label3.Caption := Translate(PChar(Label3.Caption));
Label4.Caption := Translate(PChar(Label4.Caption));
bnOK.Caption := Translate(PChar(bnOK.Caption));
bnCancel.Caption := Translate(PChar(bnCancel.Caption));
end;

procedure TfmPassNew.FormCreate(Sender: TObject);
begin
TranslateForm;
end;

end.
