unit PassNewForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, m_GlobalDefs, m_api, PasswordEditControl, hpp_forms,
  TntStdCtrls, TntExtCtrls, TntForms;

type
  TfmPassNew = class(TTntForm)
    Label1: TTntLabel;
    Label2: TTntLabel;
    edPass: TPasswordEdit;
    edConf: TPasswordEdit;
    Label3: TTntLabel;
    bnCancel: TTntButton;
    bnOK: TTntButton;
    Label4: TTntLabel;
    Image1: TTntImage;
    Label5: TTntLabel;
    Bevel1: TTntBevel;
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

uses hpp_global, hpp_options;

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
Caption := TranslateWideW(Caption);
Label1.Caption := TranslateWideW(Label1.Caption);
Label5.Caption := TranslateWideW(Label5.Caption);
Label2.Caption := TranslateWideW(Label2.Caption);
Label3.Caption := TranslateWideW(Label3.Caption);
Label4.Caption := TranslateWideW(Label4.Caption);
bnOK.Caption := TranslateWideW(bnOK.Caption);
bnCancel.Caption := TranslateWideW(bnCancel.Caption);
end;

procedure TfmPassNew.FormCreate(Sender: TObject);
begin
  TranslateForm;
  DesktopFont := True;
  MakeFontsParent(Self);
  Image1.Picture.Icon.Handle := CopyIcon(hppIntIcons[0].handle);
end;

end.
