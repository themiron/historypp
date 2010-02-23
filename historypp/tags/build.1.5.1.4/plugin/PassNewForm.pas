(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.
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

unit PassNewForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, m_GlobalDefs, m_api, HistoryControls, hpp_forms,
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
