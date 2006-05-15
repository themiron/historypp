unit hpp_eventfilters;

interface

uses SysUtils, Windows, m_api, hpp_global;

const
  // filter modes
  FM_INCLUDE = 0; // show all events from filEvents (default)
  FM_EXCLUDE = 1; // show all events except from filEvents

type
  ThppEventFilter = record
    Name: WideString;
    Events: TMessageTypes; // resulting events mask generated from filMode and filEvents, filled in runtime
    filMode: Byte; // FM_* consts
    filEvents: TMessageTypes; // filter events which are combined with filMode
  end;

  ThppEventFilterRec = packed record
    Name: array[0..63] of WideChar; // max 63 char length (64'th char for zero)
    Events: DWord;
  end;
  PhppEventFilterRec = ^ThppEventFilterRec;

var
  hppEventFilters: array of ThppEventFilter;

  procedure ReadEventFilters;
  procedure WriteEventFilters;
  procedure ResetEventFiltersToDefault;

implementation

uses
  HistoryGrid, hpp_database, hpp_services, HistoryForm, Math;

const
  hppDefEventFilters: array[0..6] of ThppEventFilter = (
    (Name: 'Show all events'; Events: filAll; filMode: 1; filEvents: []),
    (Name: 'Messages'; Events: [mtMessage,mtIncoming,mtOutgoing]; filMode: 0; filEvents: [mtMessage,mtIncoming,mtOutgoing]),
    (Name: 'Link URLs'; Events: [mtUrl,mtIncoming,mtOutgoing]; filMode: 0; filEvents: [mtUrl,mtIncoming,mtOutgoing]),
    (Name: 'Files'; Events: [mtFile,mtIncoming,mtOutgoing]; filMode: 0; filEvents: [mtFile,mtIncoming,mtOutgoing]),
    (Name: 'Status changes'; Events: [mtStatus,mtIncoming,mtOutgoing];  filMode: 0; filEvents: [mtStatus,mtIncoming,mtOutgoing]),
    (Name: 'SMTP Simple'; Events: [mtSMTPSimple,mtIncoming,mtOutgoing];  filMode: 0; filEvents: [mtSMTPSimple,mtIncoming,mtOutgoing]),
    (Name: 'All except status'; Events: filAll - [mtStatus]; filMode: 1; filEvents: [mtStatus])
    );

function IsSameAsDefault: Boolean;
var
  i: Integer;
begin
  Result := False;
  if Length(hppDefEventFilters) <> Length(hppEventFilters) then exit;
  for i := 0 to Length(hppEventFilters) - 1 do begin
    if hppEventFilters[i].Name <> TranslateWideW(hppDefEventFilters[i].Name{TRANSLATE-IGNORE}) then exit;
    if hppEventFilters[i].Events <> hppDefEventFilters[i].Events then exit;
  end;
  Result := True;
end;

function DWordToMessageTypes(dwmt: DWord): TMessageTypes;
begin
  Result := [];
  Move(PByte(Integer(@dwmt)+(SizeOf(dwmt)-SizeOf(Result)))^,Result,SizeOf(Result));
end;

function MessageTypesToDWord(mt: TMessageTypes): DWord;
begin
  Result := 0;
  Move(mt,PByte(Integer(@Result)+(SizeOf(Result)-SizeOf(mt)))^,SizeOf(mt));
  //Result := DWord(PWord(@mt)^);
end;

procedure UpdateEventFiltersOnForms;
var
  i: Integer;
begin
  for i := 0 to HstWindowList.Count - 1 do begin
    THistoryFrm(HstWindowList[i]).CreateEventsFilterMenu;
  end;
end;

procedure ResetEventFiltersToDefault;
var
  i: Integer;
begin
  SetLength(hppEventFilters,Length(hppDefEventFilters));
  for i := 0 to Length(hppDefEventFilters) - 1 do begin
    hppEventFilters[i].Name := TranslateWideW(hppDefEventFilters[i].Name{TRANSLATE-IGNORE});
    hppEventFilters[i].Events := hppDefEventFilters[i].Events;
    hppEventFilters[i].filEvents := hppDefEventFilters[i].filEvents;
    hppEventFilters[i].filMode := hppDefEventFilters[i].filMode;
  end;
  DBDeleteContactSetting(0,hppDBName,'EventFilters');
  UpdateEventFiltersOnForms;
end;

procedure ReadEventFilters;
var
  mem: Pointer;
  mem_size: Integer;
  i: Integer;
  ef_count,ef_size: Integer;
  efr: PhppEventFilterRec;
begin
  SetLength(hppEventFilters,0);
  try
    if not GetDBBlob(hppDBName,'EventFilters',mem,mem_size) then
      raise EAbort.Create('Custom event filters not found');

    // load event filters from db
    ef_count := PInteger(mem)^;
    if ef_count < 1 then
      raise EAbort.Create('Negative custom event filters count');
    ef_size := PInteger(Integer(mem)+SizeOf(Integer))^;
    if ef_size <> SizeOf(efr) then
      raise EAbort.Create('Unknown record size for custom event filters');
    if mem_size <> (ef_size*ef_count+SizeOf(Integer)*2) then
      raise EAbort.Create('Incorrect blob size for custom events');
    mem := Pointer(Integer(mem)+SizeOf(Integer)*2);
    for i := 0 to ef_count - 1 do begin
      efr := PhppEventFilterRec(Integer(mem)+i*SizeOf(efr^));
      hppEventFilters[i].Name := efr^.Name;
      //hppEventFilters[i].Events := TMessageTypes(efr^.Events);
    end;
    WriteDBBlob(hppDBName,'EventFilters',mem,mem_size);
    FreeMem(mem,mem_size);
  except
    ResetEventFiltersToDefault;
  end;
end;

procedure WriteEventFilters;
var
  i: Integer;
  mem: Pointer;
  mem_size: Integer;
  efr: ThppEventFilterRec;
  name_len: Integer;
begin
  if Length(hppEventFilters) = 0 then begin
    ResetEventFiltersToDefault;
    exit;
  end;
  if IsSameAsDefault then begin
    // revert to default state
    DBDeleteContactSetting(0,hppDBName,'FilterEvents');
    exit;
  end;
  mem_size := SizeOf(Integer)*2+Length(hppEventFilters)*SizeOf(ThppEventFilterRec);
  GetMem(mem,mem_size);
  PInteger(mem)^ := Length(hppEventFilters);
  Inc(Integer(mem),SizeOf(Integer));
  PInteger(mem)^ := SizeOf(ThppEventFilterRec);
  Inc(Integer(mem),SizeOf(Integer));

  for i := 0 to Length(hppEventFilters) - 1 do begin
    ZeroMemory(@efr,SizeOf(efr));
    name_len := Length(hppEventFilters[i].Name);
    name_len := Min(name_len,Length(efr.Name)-1);
    Move(hppEventFilters[i].Name[1],efr.Name[0],name_len*SizeOf(WideChar));
    efr.Events := MessageTypesToDWord(hppEventFilters[i].Events);
    Move(efr,PByte(Integer(mem)+i*SizeOf(efr))^,SizeOf(efr));
  end;

  UpdateEventFiltersOnForms;
end;

end.
