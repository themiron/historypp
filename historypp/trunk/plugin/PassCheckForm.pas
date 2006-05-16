unit PassCheckForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Checksum, ExtCtrls, m_GlobalDefs, m_api, hpp_forms,
  PasswordEditControl, TntForms, TntStdCtrls, TntExtCtrls;

type
  TfmPassCheck = class(TTntForm)
    Label1: TTntLabel;
    edPass: TPasswordEdit;
    bnOK: TTntButton;
    bnCancel: TTntButton;
    Image1: TTntImage;
    Label2: TTntLabel;
    Label3: TTntLabel;
    Bevel1: TTntBevel;
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bnOKClick(Sender: TObject);
    procedure bnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edPassKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    procedure TranslateForm;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmPassCheck: TfmPassCheck;

implementation

uses hpp_options, hpp_global, PassForm;

{$R *.DFM}

procedure TfmPassCheck.FormDestroy(Sender: TObject);
begin
try
  PassCheckFm := nil;
except
  end;
end;

procedure TfmPassCheck.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action := caFree;
end;

procedure TfmPassCheck.bnOKClick(Sender: TObject);
begin
if CheckPassword(edPass.Text) then begin
  if not Assigned(PassFm) then begin
    PassFm := TfmPass.Create(nil);
    end;
  PassFm.Show;
  Close;
  end
else begin
  {DONE: sHure}
  HppMessageBox(Handle, TranslateWideW('You have entered the wrong password.'),
  TranslateWideW('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
  end;
end;

procedure TfmPassCheck.bnCancelClick(Sender: TObject);
begin
Close;
end;

procedure TfmPassCheck.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TfmPassCheck.edPassKeyPress(Sender: TObject; var Key: Char);
begin
if (key = Chr(VK_RETURN)) or (key = Chr(VK_TAB)) or (key = Chr(VK_ESCAPE)) then
  key := #0;
end;

procedure TfmPassCheck.TranslateForm;
begin
Caption := TranslateWideW(Caption);
Label3.Caption := TranslateWideW(Label3.Caption);
Label2.Caption := TranslateWideW(Label2.Caption);
Label1.Caption := TranslateWideW(Label1.Caption);
bnOK.Caption := TranslateWideW(bnOK.Caption);
bnCancel.Caption := TranslateWideW(bnCancel.Caption);
end;

procedure TfmPassCheck.FormCreate(Sender: TObject);
begin
  DesktopFont := True;
  MakeFontsParent(Self);
  TranslateForm;
  Image1.Picture.Icon.Handle := CopyIcon(hppIntIcons[0].handle);
end;

end.
