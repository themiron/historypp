unit CustomizeToolbar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, TntCheckLst, TntComCtrls, ComCtrls, CommCtrl,
  TntStdCtrls, ExtCtrls, TntExtCtrls, m_api;

type
  TfmCustomizeToolbar = class(TForm)
    bnAdd: TTntButton;
    bnRemove: TTntButton;
    lbAdded: TTntListBox;
    lbAvailable: TTntListBox;
    TntLabel1: TTntLabel;
    TntLabel2: TTntLabel;
    bnUp: TTntButton;
    bnDown: TTntButton;
    TntBevel1: TTntBevel;
    TntButton1: TTntButton;
    TntButton2: TTntButton;
    TntButton3: TTntButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbAvailableDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbAddedDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbAddedDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbAvailableDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbAvailableDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TntButton3Click(Sender: TObject);
    procedure OnWMChar(var Message: TWMChar); message WM_CHAR;
    procedure bnAddClick(Sender: TObject);
  private
    DragOverIndex: Integer;

    procedure FillButtons;
    procedure TranslateForm;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmCustomizeToolbar: TfmCustomizeToolbar;

implementation

uses HistoryForm, hpp_forms, hpp_global, hpp_database;

{$R *.dfm}

procedure TfmCustomizeToolbar.lbAddedDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  src,dst: Integer;
begin
  if Source = lbAvailable then begin
    src := lbAvailable.ItemIndex;
    dst := lbAdded.ItemAtPos(Point(x,y),False);
    lbAdded.AddItem(lbAvailable.Items[src],lbAvailable.Items.Objects[src]);
    if lbAvailable.Items[src] <> '-' then
      lbAvailable.Items.Delete(src);
    if dst <> lbAdded.Count-1 then begin
      lbAdded.Items.Move(lbAdded.Count-1,dst);
    end;
  end
  else begin
    src := lbAdded.ItemIndex;
    dst := lbAdded.ItemAtPos(Point(x,y),True);
    lbAdded.Items.Move(src,dst);
  end;
  lbAdded.ItemIndex := dst;
end;

procedure TfmCustomizeToolbar.lbAddedDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  idx: Integer;
  r: TRect;
begin
  Accept := True;

  idx := DragOverIndex;
  if idx = lbAdded.Count then Dec(idx);
  r := lbAdded.ItemRect(idx);
  InvalidateRect(lbAdded.Handle,@r,False);
  DragOverIndex := lbAdded.ItemAtPos(Point(x,y),False);
  idx := DragOverIndex;
  if idx = lbAdded.Count then Dec(idx);
  r := lbAdded.ItemRect(idx);
  InvalidateRect(lbAdded.Handle,@r,False);
  lbAdded.Update;
end;

procedure TfmCustomizeToolbar.lbAvailableDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  but: TControl;
  n: Integer;
begin
  n := lbAdded.ItemIndex;
  but := TControl(lbAdded.Items.Objects[n]);
  if (but = nil) or ((but is TTntToolButton) and (TTntToolButton(but).Style in [tbsSeparator,tbsDivider])) then begin
    lbAdded.Items.Delete(n);
    exit;
  end;
  // delete last item -- separator
  lbAvailable.Items.Delete(lbAvailable.Items.Count-1);
  // add item
  lbAvailable.AddItem(lbAdded.Items[n],lbAdded.Items.Objects[n]);
  // sort
  lbAvailable.Sorted := True;
  lbAvailable.Sorted := False;
  // add separator back
  lbAvailable.AddItem('-',nil);

  lbAdded.Items.Delete(n);
end;

procedure TfmCustomizeToolbar.lbAvailableDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = lbAdded);
end;

procedure TfmCustomizeToolbar.lbAvailableDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  txtW: WideString;
  r: TRect;
  r2: TRect;
  but: TTntToolButton;
  fm: THistoryFrm;
  BrushColor: TColor;
  src,dst: Integer;
  lb: TTntListBox;
  can: TCanvas;
  tf: DWord;
  DrawLineTop,DrawLineBottom: Boolean;
begin
  if Control = lbAdded then
    lb := lbAdded
  else
    lb := lbAvailable;
  can := lb.Canvas;

  r := Rect;
  if (odSelected in State) then begin
    can.Brush.Color := clHighlight;
    can.Font.Color := clHighlightText;
  end;
  if lb.Items[Index] = '-' then begin
    can.Brush.Color := clWindow;
    can.Font.Color := clWindowText;
  end;

  tf := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
  BrushColor := can.Brush.Color;
  txtW := lb.Items[Index];
  if txtW <> '-' then begin
    can.FillRect(Rect);
    r.Left := r.Left + 20+4;
    DrawTextW(can.Handle,PWideChar(txtW),Length(txtW),r,tf);
    r2 := Classes.Rect(Rect.Left+2,Rect.Top+2,Rect.Left+20+2,Rect.Bottom-2);
    can.Brush.Color := clBtnFace;
    can.FillRect(r2);
    fm := THistoryFrm(Owner);
    if lb.Items.Objects[Index] is TTntToolButton then begin
      but := TTntToolButton(lb.Items.Objects[Index]);
      ImageList_Draw(fm.ilToolbar.Handle,but.ImageIndex,can.Handle,
      r2.Left+2,r2.Top+2,ILD_NORMAL);
    end;
  end
  else begin
    can.FillRect(Rect);
    r := Classes.Rect(Rect.Left,Rect.Top+((Rect.Bottom-Rect.Top) div 2),
    Rect.Right,Rect.Bottom);
    r.Bottom := r.Top + 1;
    InflateRect(r,-((r.Right-r.Left) div 10),0);
    can.Pen.Color := clWindowText;
    can.MoveTo(r.left,r.top);
    can.LineTo(r.right,r.top);
  end;

  if (lbAdded.Dragging) or (lbAvailable.Dragging) and (lb = lbAdded) then begin
    DrawLineTop := False;
    DrawLineBottom := False;
    dst := DragOverIndex;
    can.Pen.Color := clHighlight;
    if lbAdded.Dragging then begin
      src := lbAdded.ItemIndex;
      if Index = dst then begin
        if (dst < src) then
          DrawLineTop := True
        else
          DrawLineBottom := True
      end;
    end
    else begin
      if Index = dst then
        DrawLineTop := True;
    end;
    if (dst = lb.Count) and (Index = lb.Count-1) then
      DrawLineBottom := True;

    if DrawLineTop then begin
      can.MoveTo(rect.left,rect.Top);
      can.LineTo(rect.right,rect.Top);
    end;
    if DrawLineBottom then begin
      can.MoveTo(rect.left,rect.Bottom-1);
      can.LineTo(rect.right,rect.Bottom-1);
    end;
  end;

  can.Brush.Color := BrushColor;
end;

procedure TfmCustomizeToolbar.OnWMChar(var Message: TWMChar);
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

procedure TfmCustomizeToolbar.bnAddClick(Sender: TObject);
begin
  ShowMessage('Jo');
end;

procedure TfmCustomizeToolbar.FillButtons;
var
  i: Integer;
  fm: THistoryFrm;
  but: TControl;
  txt: WideString;
begin
  lbAdded.Clear;
  lbAvailable.Clear;
  fm := THistoryFrm(Owner);

  for i := 0 to fm.Toolbar.ButtonCount - 1 do begin
    but := fm.Toolbar.Buttons[i];
    txt := '';
    if but is TTntToolButton then begin
      if TTntToolButton(but).Style in [tbsSeparator,tbsDivider] then
        txt := '-'
      else
        txt := TTntToolButton(but).Hint
    end
    else if but = fm.tbEventsFilter then
      txt := 'Event Filters';
    if txt <> '' then begin
      if but.Visible then
        lbAdded.AddItem(txt,but)
      else
        lbAvailable.AddItem(txt,but);
    end;
  end;
  lbAvailable.Sorted := True;
  lbAvailable.Sorted := False;
  lbAvailable.AddItem('-',nil);
end;

procedure TfmCustomizeToolbar.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfmCustomizeToolbar.FormCreate(Sender: TObject);
begin
  fmCustomizeToolbar := Self;

  DesktopFont := True;
  MakeFontsParent(Self);
  TranslateForm;

  FillButtons;
end;

procedure TfmCustomizeToolbar.FormDestroy(Sender: TObject);
begin
  fmCustomizeToolbar := nil;
  try
    THistoryFrm(Owner).CustomizeToolbarForm := nil;
  except
    // "eat" exceptions if any
  end;
end;

procedure TfmCustomizeToolbar.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TfmCustomizeToolbar.TntButton3Click(Sender: TObject);
begin
  DBDeleteContactSetting(0,hppDBName,'HistoryToolbar');
  NotifyAllForms(HM_NOTF_TOOLBARCHANGED,0,0);
  FillButtons;
end;

procedure TfmCustomizeToolbar.TranslateForm;
begin
  ;
end;

end.
