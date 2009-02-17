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

{-----------------------------------------------------------------------------
 EmptyHistoryForm (historypp project)

 Version:   1.0
 Created:   15.03.2008
 Author:    theMIROn

 [ Description ]

  Empty history dialog

 [ History ]

 1.0 (15.04.08) First version.

 [ Modifications ]

 [ Known Issues ]

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}

unit EmptyHistoryForm;

interface

uses Windows, Classes, Controls, Graphics, TntWindows,
  Forms, Buttons, StdCtrls, ExtCtrls,
  TntForms, TntButtons, TntStdCtrls, TntExtCtrls,
  HistoryControls,
  PassForm, PassCheckForm,
  hpp_global, hpp_forms, hpp_contacts, hpp_database, hpp_bookmarks,
  m_globaldefs, m_api;

type
  TEmptyHistoryFrm = class(TTntForm)
    btYes: THppButton;
    btNo: THppButton;
    paContacts: THppPanel;
    paButtons: THppPanel;
    Image: TImage;
    Text: TTntLabel;
    cbInclude: THppCheckBox;
    btCancel: THppButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btYesClick(Sender: TObject);
  private
    FContact: THandle;
    FContacts: Array of THandle;
    FPasswordMode: Boolean;
    procedure TranslateForm;
    procedure PrepareForm;
    procedure SetContact(const Value: THandle);
    procedure SetPasswordMode(const Value: Boolean);
    procedure EmptyHistory(hContact: THandle);
  protected
    function GetFormText: WideString;
  public
    property Contact: THandle read FContact write SetContact;
    property PasswordMode: Boolean read FPasswordMode write SetPasswordMode;
  end;

implementation

uses Math, SysUtils, TntSysUtils, HistoryForm;

{$R *.dfm}

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of WideChar;
  tm: TTextMetric;
begin
  for I := 0 to 25 do Buffer[I] := WideChar(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := WideChar(I + Ord('a'));
  GetTextMetrics(Canvas.Handle, tm);
  GetTextExtentPointW(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := (Result.X div 26 + 1) div 2;
  Result.Y := tm.tmHeight;
end;

function TEmptyHistoryFrm.GetFormText: WideString;
var
  DividerLine, ButtonCaptions, IncludeContacts: WideString;
  I: integer;
begin
  DividerLine := StringOfChar('-', 27) + sLineBreak;
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TButton then
      ButtonCaptions := ButtonCaptions +
                        TTntButton(Components[I]).Caption + StringOfChar(' ', 3);
  ButtonCaptions := Tnt_WideStringReplace(ButtonCaptions,'&','', [rfReplaceAll]);
  if paContacts.Visible then begin
    if cbInclude.Checked then
      IncludeContacts := '[x]' else
      IncludeContacts := '[ ]';
    IncludeContacts := sLineBreak + IncludeContacts + ' ' + cbInclude.Caption + sLineBreak;
  end else
    IncludeContacts := '';
  Result := DividerLine + Caption + sLineBreak +
            DividerLine + Text.Caption + sLineBreak +
            IncludeContacts +
            DividerLine + ButtonCaptions + sLineBreak +
            DividerLine;
end;

procedure TEmptyHistoryFrm.TranslateForm;
begin
  Caption := TranslateWideW(Caption);
  cbInclude.Caption := TranslateWideW(cbInclude.Caption);
  btYes.Caption := TranslateWideW(btYes.Caption);
  btNo.Caption := TranslateWideW(btNo.Caption);
  btCancel.Caption := TranslateWideW(btCancel.Caption);
end;

procedure TEmptyHistoryFrm.PrepareForm;
const
  mcSpacing = 8;
  mcButtonWidth = 50;
  mcButtonHeight = 14;
  mcButtonSpacing = 4;
var
  DialogUnits: TPoint;
  HorzSpacing, VertSpacing,
  ButtonWidth, ButtonHeight, ButtonSpacing, ButtonGroupWidth,
  IconTextWidth, IconTextHeight: Integer;
  TextRect,ContRect: TRect;
begin
  DialogUnits := GetAveCharSize(Canvas);
  HorzSpacing := MulDiv(mcSpacing, DialogUnits.X, 8);
  VertSpacing := MulDiv(mcSpacing, DialogUnits.X, 4);
  ButtonWidth := MulDiv(mcButtonWidth, DialogUnits.X, 4);
  ButtonHeight := MulDiv(mcButtonHeight, DialogUnits.Y, 8);
  ButtonSpacing := MulDiv(mcButtonSpacing, DialogUnits.X, 4);

  SetRect(TextRect, 0, 0, Screen.Width div 2, 0);
    Tnt_DrawTextW(Canvas.Handle, PWideChar(Text.Caption),
      Length(Text.Caption)+1, TextRect,
      DT_EXPANDTABS or DT_CALCRECT or DT_WORDBREAK or
      DrawTextBiDiModeFlagsReadingOnly);

  IconTextWidth := Image.Width + HorzSpacing + TextRect.Right;
  IconTextHeight := Max(Image.Height,TextRect.Bottom);

  if PasswordMode then
    ButtonGroupWidth := ButtonWidth else
    ButtonGroupWidth := ButtonWidth*2 + ButtonSpacing;

  BorderWidth := VertSpacing;
  ClientWidth := Max(IconTextWidth, ButtonGroupWidth);
  if paContacts.Visible then begin
    ContRect := Rect(0,0,0,0);
    Tnt_DrawTextW(Canvas.Handle,
      PWideChar(cbInclude.Caption), -1,
      ContRect, DT_CALCRECT or DT_LEFT or DT_SINGLELINE or
      DrawTextBiDiModeFlagsReadingOnly);
    Inc(ContRect.Right, HorzSpacing*4);
    cbInclude.SetBounds((ClientWidth - ContRect.Right) div 2,0,
      ContRect.Right, ContRect.Bottom);
    paContacts.Height := cbInclude.Height + VertSpacing;
    ClientHeight := IconTextHeight + VertSpacing + paContacts.Height + paButtons.Height;
  end else
    ClientHeight := IconTextHeight + VertSpacing + paButtons.Height;
  Text.SetBounds(Image.Width + HorzSpacing, 0,
    TextRect.Right, TextRect.Bottom);

  if PasswordMode then begin
    btCancel.SetBounds((ClientWidth - ButtonGroupWidth) div 2,0,
      ButtonWidth, ButtonHeight);
  end else begin
    btYes.SetBounds((ClientWidth - ButtonGroupWidth) div 2,0,
      ButtonWidth, ButtonHeight);
    btNo.SetBounds(btYes.Left + btYes.Width + ButtonSpacing,0,
      ButtonWidth, ButtonHeight);
  end;
end;

procedure TEmptyHistoryFrm.FormShow(Sender: TObject);
begin
  TranslateForm;
  PrepareForm;
end;

procedure TEmptyHistoryFrm.FormCreate(Sender: TObject);
var
  NonClientMetrics: TNonClientMetrics;
begin
  NonClientMetrics.cbSize := sizeof(NonClientMetrics);
  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
    Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);
  MakeFontsParent(Self);
  Canvas.Font := Font;
  DoubleBuffered := True;
  MakeDoubleBufferedParent(Self);
end;

procedure TEmptyHistoryFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = Word('C')) then begin
    CopyToClip(GetFormText,CP_ACP);
    Key := 0;
  end;
end;

procedure TEmptyHistoryFrm.SetContact(const Value: THandle);
var
  hContact: THandle;
  Proto: String;
  i,num: Integer;
begin
  FContact := Value;
  SetLength(FContacts,0);
  GetContactProto(FContact,hContact,Proto);
  if Value <> hContact then begin
    num := PluginLink.CallService(MS_MC_GETNUMCONTACTS,FContact,0);
    for i := 0 to num-1 do begin
      hContact := PluginLink.CallService(MS_MC_GETSUBCONTACT,FContact,i);
      if hContact <> THandle(-1) then begin
        SetLength(FContacts,Length(FContacts)+1);
        FContacts[High(FContacts)] := hContact;
      end;
    end;
  end;
  if Assigned(Owner) and (Owner is THistoryFrm) then
    PasswordMode := THistoryFrm(Owner).PasswordMode else
    PasswordMode := (not IsPasswordBlank(GetPassword)) and
                    IsUserProtected(FContact);
  paContacts.Visible := not PasswordMode and (Length(FContacts) > 0);
end;

procedure TEmptyHistoryFrm.SetPasswordMode(const Value: Boolean);
begin
  FPasswordMode := Value;
  if PasswordMode then begin
    Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);
    Text.Caption := TranslateWideW('History of this contact is password protected');
  end else begin
    Image.Picture.Icon.Handle := LoadIcon(0, IDI_QUESTION);
    Text.Caption :=
      TranslateWideW('Do you really want to delete ALL items for this contact?')+#10#13+
      #10#13+
      TranslateWideW('Note: It can take several minutes for large histories');
  end;
  btYes.Visible := not FPasswordMode;
  btYes.Default := not FPasswordMode;
  btNo.Visible := not FPasswordMode;
  btCancel.Visible := FPasswordMode;
  btCancel.Default := FPasswordMode;
end;

procedure TEmptyHistoryFrm.EmptyHistory(hContact: THandle);
var
  hDbEvent,prevhDbEvent: Integer;
begin
  BookmarkServer.Contacts[hContact].Clear;
  hDbEvent := PluginLink.CallService(MS_DB_EVENT_FINDLAST,hContact,0);
  SetSafetyMode(False);
  while hDbEvent <> 0 do begin
    prevhDbEvent := PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDbEvent,0);
    if PluginLink.CallService(MS_DB_EVENT_DELETE,hContact,hDBEvent) = 0 then
      hDBEvent := prevhDbEvent else
      hDBEvent := 0;
  end;
  SetSafetyMode(True);
end;

procedure TEmptyHistoryFrm.btYesClick(Sender: TObject);
var
  i: Integer;
begin
  if Assigned(Owner) and (Owner is THistoryFrm) then
    THistoryFrm(Owner).EmptyHistory else
    EmptyHistory(FContact);
  if paContacts.Visible and cbInclude.Checked then
    for i := 0 to High(FContacts) do
      EmptyHistory(FContacts[i]);
end;

end.
