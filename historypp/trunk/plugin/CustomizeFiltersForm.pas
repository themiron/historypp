unit CustomizeFiltersForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,TntForms, StdCtrls, TntStdCtrls, CheckLst, TntCheckLst, hpp_global;

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
  private
    procedure FillFiltersList;
    procedure FillEventsCheckListBox;
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

uses hpp_forms, HistoryForm, hpp_options, hpp_eventfilters, TypInfo;

const
  FilterNames: array[0..11] of TMessageTypeNameRec = (
  // !!! mtUnknown is used internally for not loaded events, should not be shown to users, should not be selectable
  (mt: mtIncoming; Name: 'Show incoming events'),
  (mt: mtOutgoing; Name: 'Show outgoing events'),
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

procedure TfmCustomizeFilters.bnOKClick(Sender: TObject);
begin
  Close;
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
  for i := 0 to Length(hppEventFilters) - 1 do begin
    lbFilters.Items.Add(hppEventFilters[i].Name);
  end;
  //meEvents.Lines.Clear;
end;

procedure TfmCustomizeFilters.FormCreate(Sender: TObject);
begin
  fmCustomizeFilters := Self;
  
  DesktopFont := True;
  MakeFontsParent(Self);

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
  rbInclude.Checked := (hppEventFilters[lbFilters.ItemIndex].filMode = FM_INCLUDE);
  rbExclude.Checked := (hppEventFilters[lbFilters.ItemIndex].filMode = FM_EXCLUDE);
  for i := 0 to clEvents.Items.Count - 1 do begin
    clEvents.Checked[i] := TMessageType(Pointer(clEvents.Items.Objects[i])) in hppEventFilters[lbFilters.ItemIndex].filEvents;
  end;
  edFilterName.Text := lbFilters.Items[lbFilters.ItemIndex];

  edFilterName.Enabled := (lbFilters.ItemIndex <> GetShowAllEventsIndex);
  laFilterName.Enabled := edFilterName.Enabled;
  rbInclude.Enabled := edFilterName.Enabled;
  rbExclude.Enabled := edFilterName.Enabled;
  clEvents.Enabled := edFilterName.Enabled;
  bnDelete.Enabled := edFilterName.Enabled;
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

end.
