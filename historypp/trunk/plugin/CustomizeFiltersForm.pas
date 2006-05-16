unit CustomizeFiltersForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,TntForms, StdCtrls, TntStdCtrls, CheckLst, TntCheckLst, hpp_global,
  hpp_eventfilters;

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
  private
    LocalFilters: array of ThppEventFilter;
    procedure LoadLocalFilters;
    procedure FillFiltersList;
    procedure FillEventsCheckListBox;

    procedure UpdateUpDownButtons;
    { Private declarations }
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

uses hpp_forms, HistoryForm, hpp_options, TypInfo;

const
  FilterNames: array[0..11] of TMessageTypeNameRec = (
  // !!! mtUnknown is used internally for not loaded events, should not be shown to users, should not be selectable
  (mt: mtIncoming; Name: 'Incoming events'),
  (mt: mtOutgoing; Name: 'Outgoing events'),
  (mt: mtMessage; Name: 'Message'),
  (mt: mtUrl; Name: 'Link URL'),
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
  ef: ThppEventFilter;
  i: Integer;
begin
  if lbFilters.ItemIndex = -1 then exit;
  if lbFilters.ItemIndex = lbFilters.Count-1 then exit;

  i := lbFilters.ItemIndex;
  lbFilters.Items.Move(i,i+1);
  ef := LocalFilters[i+1];
  LocalFilters[i+1] := LocalFilters[i];
  LocalFilters[i] := ef;
  lbFilters.ItemIndex := i+1;
  UpdateUpDownButtons;
end;

procedure TfmCustomizeFilters.bnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TfmCustomizeFilters.bnUpClick(Sender: TObject);
var
  ef: ThppEventFilter;
  i: Integer;
begin
  if lbFilters.ItemIndex = -1 then exit;
  if lbFilters.ItemIndex = 0 then exit;

  i := lbFilters.ItemIndex;
  lbFilters.Items.Move(i,i-1);
  ef := LocalFilters[i-1];
  LocalFilters[i-1] := LocalFilters[i];
  LocalFilters[i] := ef;
  lbFilters.ItemIndex := i-1;
  UpdateUpDownButtons;
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
        mt_name := 'Incoming & Outgoing'
      else
        mt_name := 'Events';
      i := clEvents.Items.Add(mt_name);
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

  edFilterName.Enabled := (lbFilters.ItemIndex <> GetShowAllEventsIndex);
  laFilterName.Enabled := edFilterName.Enabled;
  rbInclude.Enabled := edFilterName.Enabled;
  rbExclude.Enabled := edFilterName.Enabled;
  clEvents.Enabled := edFilterName.Enabled;
  bnDelete.Enabled := edFilterName.Enabled;

  UpdateUpDownButtons;
end;

procedure TfmCustomizeFilters.LoadLocalFilters;
var
  i: Integer;
begin
  SetLength(LocalFilters,Length(hppEventFilters));
  for i := 0 to Length(hppEventFilters) - 1 do begin
    LocalFilters[i].Name := hppEventFilters[i].Name;
    LocalFilters[i].Events := hppEventFilters[i].Events;
    LocalFilters[i].filMode := hppEventFilters[i].filMode;
    LocalFilters[i].filEvents := hppEventFilters[i].filEvents;
  end;
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

procedure TfmCustomizeFilters.UpdateUpDownButtons;
begin
  bnUp.Enabled := (lbFilters.ItemIndex <> 0);
  bnDown.Enabled := (lbFilters.ItemIndex <> lbFilters.Count-1);
end;

end.
