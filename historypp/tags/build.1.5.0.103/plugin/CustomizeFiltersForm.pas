unit CustomizeFiltersForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,TntForms, StdCtrls, TntStdCtrls, CheckLst, TntCheckLst, TntGraphics, TntWindows,
  hpp_global, hpp_eventfilters;

type
  TfmCustomizeFilters = class(TTntForm)
    bnOK: TTntButton;
    bnCancel: TTntButton;
    gbFilter: TTntGroupBox;
    edFilterName: TTntEdit;
    clEvents: TTntCheckListBox;
    bnReset: TTntButton;
    rbExclude: TTntRadioButton;
    rbInclude: TTntRadioButton;
    gbFilters: TTntGroupBox;
    lbFilters: TTntListBox;
    bnDown: TTntButton;
    bnUp: TTntButton;
    bnDelete: TTntButton;
    bnAdd: TTntButton;
    laFilterName: TTntLabel;
    procedure FormCreate(Sender: TObject);
    procedure bnOKClick(Sender: TObject);
    procedure TntFormClose(Sender: TObject; var Action: TCloseAction);
    procedure TntFormDestroy(Sender: TObject);
    procedure lbFiltersClick(Sender: TObject);
    procedure edFilterNameChange(Sender: TObject);
    procedure bnAddClick(Sender: TObject);
    procedure bnCancelClick(Sender: TObject);
    procedure bnUpClick(Sender: TObject);
    procedure bnDownClick(Sender: TObject);
    procedure bnDeleteClick(Sender: TObject);
    procedure clEventsClickCheck(Sender: TObject);
    procedure bnResetClick(Sender: TObject);
    procedure rbIncludeClick(Sender: TObject);
    procedure lbFiltersDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbFiltersDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure clEventsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbFiltersDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure TntFormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    LocalFilters: ThppEventFilterArray;

    IncOutWrong: Boolean;
    EventsWrong: Boolean;
    EventsHeaderIndex: Integer;

    DragOverIndex: Integer;

    procedure LoadLocalFilters;
    procedure SaveLocalFilters;
    procedure FillFiltersList;
    procedure FillEventsCheckListBox;

    procedure MoveItem(Src,Dst: Integer);
    procedure UpdateEventsState;
    procedure UpdateUpDownButtons;

    procedure TranslateForm;
  public
    { Public declarations }
  end;

  TMessageTypeNameRec = record
    mt: TMessageType;
    Name: WideString;
  end;

var
  fmCustomizeFilters: TfmCustomizeFilters = nil;

implementation

uses hpp_forms, HistoryForm, hpp_options, TypInfo, Math;

const
  FilterNames: array[0..11] of TMessageTypeNameRec = (
  // !!! mtUnknown is used internally for not loaded events, should not be shown to users, should not be selectable
  (mt: mtIncoming; Name: 'Incoming events'),
  (mt: mtOutgoing; Name: 'Outgoing events'),
  (mt: mtMessage; Name: 'Message'),
  (mt: mtUrl; Name: 'Link URLs'),
  (mt: mtFile; Name: 'File'),
  (mt: mtContacts; Name: 'Contact'),
  (mt: mtSMS; Name: 'SMS'),
  (mt: mtWebPager; Name: 'Web pager'),
  (mt: mtEmailExpress; Name: 'Email Express'),
  (mt: mtSMTPSimple; Name: 'SMTP Simple Email'),
  (mt: mtStatus; Name: 'Status'),
  (mt: mtOther; Name: 'Other (unknown)')
  );

  IgnoreEvents: TMessageTypes = [mtSystem, mtWebPager, mtEmailExpress];
  
{$R *.dfm}

procedure TfmCustomizeFilters.bnAddClick(Sender: TObject);
var
  NewNameFmt,NewName: WideString;
  NameExists: Boolean;
  num,i: Integer;
begin
  NewNameFmt := TranslateWideW('New Filter #%d');
  num := 1;
  while True do begin
    NewName := Format(NewNameFmt,[num]);
    NameExists := False;
    for i := 0 to Length(LocalFilters) - 1 do
      if NewName = LocalFilters[i].Name then begin
        NameExists := true;
        break;
      end;
    if not NameExists then break;
    Inc(num);
  end;

  i := Length(LocalFilters);
  SetLength(LocalFilters,i+1);
  LocalFilters[i].Name := NewName;
  LocalFilters[i].filMode := FM_INCLUDE;
  LocalFilters[i].filEvents := [mtIncoming,mtOutgoing,mtMessage,mtUrl,mtFile];
  LocalFilters[i].Events := GenerateEvents(LocalFilters[i].filMode,LocalFilters[i].filEvents);

  lbFilters.Items.Add(NewName);
  lbFilters.ItemIndex := i;
  lbFiltersClick(Self);
  edFilterName.SetFocus;
end;

procedure TfmCustomizeFilters.bnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfmCustomizeFilters.bnDeleteClick(Sender: TObject);
var
  n,i: Integer;
begin
  if lbFilters.ItemIndex = -1 then exit;
  n := lbFilters.ItemIndex;
  if (LocalFilters[n].filMode = FM_EXCLUDE) and
  (LocalFilters[n].filEvents = []) then exit; // don't delete Show All Events
  for i := n to Length(LocalFilters) - 2 do
    LocalFilters[i] := LocalFilters[i+1];
  SetLength(LocalFilters,Length(LocalFilters)-1);
  lbFilters.DeleteSelected;
  if n >= lbFilters.Count then
    Dec(n);
  lbFilters.ItemIndex := n;
  lbFiltersClick(Self);
end;

procedure TfmCustomizeFilters.bnDownClick(Sender: TObject);
var
  i: Integer;
begin
  if lbFilters.ItemIndex = -1 then exit;
  if lbFilters.ItemIndex = lbFilters.Count-1 then exit;
  i := lbFilters.ItemIndex;
  MoveItem(i,i+1);
end;

procedure TfmCustomizeFilters.bnOKClick(Sender: TObject);
begin
  SaveLocalFilters;
  Close;
end;

procedure TfmCustomizeFilters.bnResetClick(Sender: TObject);
begin
  CopyEventFilters(hppDefEventFilters,LocalFilters);

  FillFiltersList;
  FillEventsCheckListBox;

  SaveLocalFilters;

  if lbFilters.Items.Count > 0 then lbFilters.ItemIndex := 0;
  lbFiltersClick(Self);
end;

procedure TfmCustomizeFilters.bnUpClick(Sender: TObject);
var
  i: Integer;
begin
  if lbFilters.ItemIndex = -1 then exit;
  if lbFilters.ItemIndex = 0 then exit;
  i := lbFilters.ItemIndex;
  MoveItem(i,i-1);
end;

procedure TfmCustomizeFilters.clEventsClickCheck(Sender: TObject);
var
  n,i: Integer;
begin
  UpdateEventsState;
  if EventsWrong or IncOutWrong then exit;
  n := lbFilters.ItemIndex;
  if rbInclude.Checked then
    LocalFilters[n].filMode := FM_INCLUDE
  else
    LocalFilters[n].filMode := FM_EXCLUDE;
  LocalFilters[n].filEvents := [];
  for i := 0 to clEvents.Count - 1 do begin
    if clEvents.Header[i] then continue;
    if clEvents.Checked[i] then
      Include(LocalFilters[n].filEvents,TMessageType(Integer(clEvents.Items.Objects[i])));
  end;
  LocalFilters[n].Events := GenerateEvents(LocalFilters[n].filMode,LocalFilters[n].filEvents);
end;

procedure TfmCustomizeFilters.clEventsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  txtW: WideString;
  r: TRect;
  tf: DWord;
  BrushColor: TColor;
begin
  BrushColor := clEvents.Canvas.Brush.Color;
  txtW := clEvents.Items[Index];
  r := Rect;
  tf := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
  InflateRect(r,-2,0);

  if clEvents.Header[Index] then begin
    if (EventsWrong) and (Index = EventsHeaderIndex) then
      if BrushColor = clEvents.HeaderBackgroundColor then clEvents.Canvas.Brush.Color := $008080FF;
    if (IncOutWrong) and (Index <> EventsHeaderIndex) then
      if BrushColor = clEvents.HeaderBackgroundColor then clEvents.Canvas.Brush.Color := $008080FF;
    clEvents.Canvas.FillRect(Rect);
    Tnt_DrawTextW(clEvents.Canvas.Handle,PWideChar(txtW),Length(txtW),r,tf);
    clEvents.Canvas.Brush.Color := BrushColor;
    exit;
  end;

  if (EventsWrong) and (Index > EventsHeaderIndex) then
    if BrushColor = clEvents.Color then clEvents.Canvas.Brush.Color := $008080FF;
  if (IncOutWrong) and (Index < EventsHeaderIndex) then
    if BrushColor = clEvents.Color then clEvents.Canvas.Brush.Color := $008080FF;
  clEvents.Canvas.FillRect(Rect);
  Tnt_DrawTextW(clEvents.Canvas.Handle,PWideChar(txtW),Length(txtW),r,tf);
  clEvents.Canvas.Brush.Color := BrushColor;
end;

procedure TfmCustomizeFilters.edFilterNameChange(Sender: TObject);
begin
  if lbFilters.ItemIndex = -1 then exit;
  if edFilterName.Text = '' then
    edFilterName.Color := $008080FF
  else
    edFilterName.Color := clWindow;
  if edFilterName.Text <> '' then
    LocalFilters[lbFilters.ItemIndex].Name := edFilterName.Text;
  lbFilters.Items.BeginUpdate;
  lbFilters.Items[lbFilters.ItemIndex] := LocalFilters[lbFilters.ItemIndex].Name;
  lbFilters.Items.EndUpdate;
end;

procedure TfmCustomizeFilters.FillEventsCheckListBox;
var
  mt: TMessageType;
  mt_name, pretty_name: WideString;
  i: Integer;
begin
  clEvents.Items.Clear;

  // add all types except mtOther (we'll add it at the end) and
  // message types in AlwaysExclude and AlwaysInclude
  for mt := Low(TMessageType) to High(TMessageType) do begin
    if (mt in AlwaysExclude) or (mt in AlwaysInclude) or (mt in IgnoreEvents) then continue;
    if mt = mtOther then continue; // we'll add mtOther at the end
    if mt in [mtIncoming,mtMessage] then begin // insert header before incoming and message
      if mt = mtIncoming then
        mt_name := TranslateWideW('Incoming & Outgoing')
      else
        mt_name := TranslateWideW('Events');
      i := clEvents.Items.Add(mt_name);
      EventsHeaderIndex := i;
      clEvents.Header[i] := True;
    end;

    pretty_name := GetEnumName(TypeInfo(TMessageType),Ord(mt));
    Delete(pretty_name,1,2);
    // find filter names if we have substitute
    for i := 0 to Length(FilterNames) - 1 do
      if FilterNames[i].mt = mt then begin
        pretty_name := FilterNames[i].Name;
        break;
      end;

    pretty_name := TranslateWideW(pretty_name{TRANSLATE-IGNORE});
    clEvents.Items.AddObject(pretty_name,Pointer(Ord(mt)));
  end;

  // add mtOther at the end
  mt := mtOther;
  pretty_name := GetEnumName(TypeInfo(TMessageType),Ord(mt));
  Delete(pretty_name,1,2);
  // find filter names if we have substitute
  for i := 0 to Length(FilterNames) - 1 do
    if FilterNames[i].mt = mt then begin
      pretty_name := FilterNames[i].Name;
      break;
    end;

  pretty_name := TranslateWideW(pretty_name{TRANSLATE-IGNORE});
  clEvents.Items.AddObject(pretty_name,Pointer(Ord(mt)));
end;

procedure TfmCustomizeFilters.FillFiltersList;
var
  i: Integer;
begin
  lbFilters.Items.Clear;
  for i := 0 to Length(LocalFilters) - 1 do begin
    lbFilters.Items.Add(LocalFilters[i].Name);
  end;
  //meEvents.Lines.Clear;
end;

procedure TfmCustomizeFilters.FormCreate(Sender: TObject);
begin
  fmCustomizeFilters := Self;

  DesktopFont := True;
  MakeFontsParent(Self);
  TranslateForm;

  LoadLocalFilters;
  FillFiltersList;
  FillEventsCheckListBox;

  if lbFilters.Items.Count > 0 then lbFilters.ItemIndex := 0;
  lbFiltersClick(Self);
  edFilterName.MaxLength := MAX_FILTER_NAME_LENGTH;
end;

procedure TfmCustomizeFilters.lbFiltersClick(Sender: TObject);
var
  i: Integer;
begin
  if lbFilters.ItemIndex = -1 then exit;
  rbInclude.Checked := (LocalFilters[lbFilters.ItemIndex].filMode = FM_INCLUDE);
  rbExclude.Checked := (LocalFilters[lbFilters.ItemIndex].filMode = FM_EXCLUDE);
  for i := 0 to clEvents.Items.Count - 1 do begin
    if clEvents.Header[i] then continue;
    clEvents.Checked[i] := TMessageType(Pointer(clEvents.Items.Objects[i])) in LocalFilters[lbFilters.ItemIndex].filEvents;
  end;
  edFilterName.Text := lbFilters.Items[lbFilters.ItemIndex];

  edFilterName.Enabled := (lbFilters.ItemIndex <> GetShowAllEventsIndex(LocalFilters));
  laFilterName.Enabled := edFilterName.Enabled;
  rbInclude.Enabled := edFilterName.Enabled;
  rbExclude.Enabled := edFilterName.Enabled;
  clEvents.Enabled := edFilterName.Enabled;
  bnDelete.Enabled := edFilterName.Enabled;

  UpdateUpDownButtons;
  UpdateEventsState;
end;

procedure TfmCustomizeFilters.lbFiltersDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  src,dst: Integer;
begin
  // we insert always *before* droped item, unless we drop on the empty area
  // in this case be insert dragged item at the end
  dst := lbFilters.ItemAtPos(Point(x,y),False);
  src := lbFilters.ItemIndex;
  if src = dst then exit;
  if src < dst then Dec(dst);
  if src = dst then exit;
  MoveItem(src,dst);
end;

procedure TfmCustomizeFilters.lbFiltersDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  r: TRect;
  idx: Integer;
begin
  Accept := True;
  idx := DragOverIndex;
  if idx = lbFilters.Count then Dec(idx);
  r := lbFilters.ItemRect(idx);
  DragOverIndex := lbFilters.ItemAtPos(Point(x,y),False);
  InvalidateRect(lbFilters.Handle,@r,False);
  idx := DragOverIndex;
  if idx = lbFilters.Count then Dec(idx);
  r := lbFilters.ItemRect(idx);
  InvalidateRect(lbFilters.Handle,@r,False);
  lbFilters.Update;
end;

procedure TfmCustomizeFilters.lbFiltersDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  BrushColor: TColor;
  txtW: WideString;
  r: TRect;
  tf: DWord;
  src,dst: Integer;
begin
  BrushColor := lbFilters.Canvas.Brush.Color;
  txtW := lbFilters.Items[Index];
  r := Rect;
  InflateRect(r,-2,0);
  lbFilters.Canvas.FillRect(Rect);
  tf := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
  Tnt_DrawTextW(lbFilters.Canvas.Handle,PWideChar(txtW),Length(txtW),r,tf);
  if lbFilters.Dragging then begin
    src := lbFilters.ItemIndex;
    dst := DragOverIndex;
    if (dst = lbFilters.Count) and (Index = lbFilters.Count-1) then begin
      lbFilters.Canvas.Brush.Color := clHighlight;
      r := Classes.Rect(Rect.Left,Rect.Bottom-1,Rect.Right,Rect.Bottom);
      lbFilters.Canvas.FillRect(r);
    end;
    if (dst = Index) then begin
      lbFilters.Canvas.Brush.Color := clHighlight;
      r := Classes.Rect(Rect.Left,Rect.Top,Rect.Right,Rect.Top+1);
      lbFilters.Canvas.FillRect(r);
    end;
  end;
  lbFilters.Canvas.Brush.Color := BrushColor;
end;

procedure TfmCustomizeFilters.LoadLocalFilters;
begin
  CopyEventFilters(hppEventFilters,LocalFilters);
end;

procedure TfmCustomizeFilters.MoveItem(Src, Dst: Integer);
var
  ef: ThppEventFilter;
  i: Integer;
begin
  if src = dst then exit;

  lbFilters.Items.Move(src,dst);

  ef := LocalFilters[src];
  if dst > src then
    for i := src to dst-1 do
      LocalFilters[i] := LocalFilters[i+1]
  else
    for i := src downto dst+1 do
      LocalFilters[i] := LocalFilters[i-1];
  LocalFilters[dst] := ef;

  lbFilters.ItemIndex := dst;
  UpdateUpDownButtons;
end;

procedure TfmCustomizeFilters.rbIncludeClick(Sender: TObject);
var
  n: Integer;
begin
  n := lbFilters.ItemIndex;
  UpdateEventsState;
  if IncOutWrong or EventsWrong then exit;
  if rbInclude.Checked then
    LocalFilters[n].filMode := FM_INCLUDE
  else
    LocalFilters[n].filMode := FM_EXCLUDE;
  LocalFilters[n].Events := GenerateEvents(LocalFilters[n].filMode,LocalFilters[n].filEvents);
end;

procedure TfmCustomizeFilters.SaveLocalFilters;
begin
  CopyEventFilters(LocalFilters,hppEventFilters);
  WriteEventFilters;
end;

procedure TfmCustomizeFilters.TntFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfmCustomizeFilters.TntFormDestroy(Sender: TObject);
begin
  fmCustomizeFilters := nil;
  try
    THistoryFrm(Owner).CustomizeFiltersForm := nil;
  except
    // "eat" exceptions if any
  end;
end;

procedure TfmCustomizeFilters.TntFormKeyDown(Sender: TObject; var Key: Word;
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

procedure TfmCustomizeFilters.TranslateForm;
begin
  Caption := TranslateWideW(Caption);
  gbFilters.Caption := TranslateWideW(gbFilters.Caption);
  bnAdd.Caption := TranslateWideW(bnAdd.Caption);
  bnDelete.Caption := TranslateWideW(bnDelete.Caption);
  bnUp.Caption := TranslateWideW(bnUp.Caption);
  bnDown.Caption := TranslateWideW(bnDown.Caption);
  gbFilter.Caption := TranslateWideW(gbFilter.Caption);
  laFilterName.Caption := TranslateWideW(laFilterName.Caption);
  rbInclude.Caption := TranslateWideW(rbInclude.Caption);
  rbExclude.Caption := TranslateWideW(rbExclude.Caption);
  bnOK.Caption := TranslateWideW(bnOK.Caption);
  bnCancel.Caption := TranslateWideW(bnCancel.Caption);
  bnReset.Caption := TranslateWideW(bnReset.Caption);
end;

procedure TfmCustomizeFilters.UpdateEventsState;
var
  IncOutChecked,IncOutUnchecked,
  EventsChecked,EventsUnchecked: Boolean;
  InsideEvents: Boolean;
  InsideIncOut: Boolean;
  HeadEvents: Integer;
  i: Integer;
begin
  if not clEvents.Enabled then begin
    IncOutWrong := False;
    EventsWrong := False;
    bnOk.Enabled := True;
    exit;
  end;
  IncOutChecked := True;
  IncOutUnchecked := True;
  EventsChecked := True;
  EventsUnchecked := True;
  InsideEvents := False;
  InsideIncOut := False;
  HeadEvents := 0;
  for i := 0 to clEvents.Count - 1 do begin

    if clEvents.Header[i] then begin
      if InsideIncOut then begin
        HeadEvents := i;
        InsideEvents := True;
      end
      else
        InsideIncOut := True;
      continue;
    end;

    if InsideEvents then begin
      if EventsChecked and (not clEvents.Checked[i]) then
        EventsChecked := False;
      if EventsUnchecked and clEvents.Checked[i] then
        EventsUnchecked := False;
      if (not EventsChecked) and (not EventsUnchecked) then break;
    end
    else begin
      if IncOutChecked and (not clEvents.Checked[i]) then
        IncOutChecked := False;
      if IncOutUnchecked and clEvents.Checked[i] then
        IncOutUnchecked := False;
    end;

  end;

  if rbInclude.Checked then begin
    EventsWrong := EventsUnchecked;
    IncOutWrong := IncOutUnchecked;
  end
  else begin
    EventsWrong := EventsChecked;
    IncOutWrong := IncOutChecked;
  end;


  // we probably need some help text to show why the filter selection is wrong
  // explanation is given in comments below
  if (rbExclude.Checked) and (EventsUnchecked) and (IncOutUnchecked) then begin
    EventsWrong := True;
    IncOutWrong := True;
    // not allowed to duplicate Show All Events filter
  end
  else
  if (rbInclude.Checked) and (EventsChecked) and (IncOutChecked) then begin
    EventsWrong := True;
    IncOutWrong := True;
    // not allowed to quasi-duplicate Show All Events filter
  end
  else begin
    if (EventsWrong) or (IncOutWrong) then
      ;// no events will be shown
  end;

  clEvents.Repaint;
  bnOk.Enabled := not (EventsWrong or IncOutWrong);
end;

procedure TfmCustomizeFilters.UpdateUpDownButtons;
begin
  bnUp.Enabled := (lbFilters.ItemIndex <> 0);
  bnDown.Enabled := (lbFilters.ItemIndex <> lbFilters.Count-1);
end;

end.
