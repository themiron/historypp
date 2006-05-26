unit hpp_eventfilters;

interface

uses SysUtils, Windows, Classes, TntSysUtils, m_api, hpp_global;

const
  // filter modes
  FM_INCLUDE = 0; // show all events from filEvents (default)
  FM_EXCLUDE = 1; // show all events except from filEvents

const
  MAX_FILTER_NAME_LENGTH = 33; // make it uneven, so our db record would align in 4 bytes

type
  ThppEventFilter = record
    Name: WideString;
    Events: TMessageTypes; // resulting events mask generated from filMode and filEvents, filled in runtime
    filMode: Byte; // FM_* consts
    filEvents: TMessageTypes; // filter events which are combined with filMode
  end;

  ThppEventFilterArray = array of ThppEventFilter;

  ThppEventFilterRec = packed record
    Name: array[0..MAX_FILTER_NAME_LENGTH-1] of WideChar;
    filMode: Byte;
    filEvents: DWord;
    filFlags: Byte; // reserved for future use (??) added this field to make record byte-align
  end;
  PhppEventFilterRec = ^ThppEventFilterRec;

var
  hppEventFilters: ThppEventFilterArray;
  hppDefEventFilters: ThppEventFilterArray;

  procedure InitEventFilters;
  procedure ReadEventFilters;
  procedure WriteEventFilters;
  procedure ResetEventFiltersToDefault;
  procedure CopyEventFilters(var Src,Dest: ThppEventFilterArray);
  function GetShowAllEventsIndex(Arr: ThppEventFilterArray = nil): Integer;

  function MessageTypesToDWord(mt: TMessageTypes): DWord;

  // compile filMode & filEvents into Events:
  function GenerateEvents(filMode: Byte; filEvents: TMessageTypes): TMessageTypes;
  // compile filMode & filEvents into Events for all filters
  procedure GenerateEventFilters(var Filters: array of ThppEventFilter);

const
  AlwaysInclude: TMessageTypes = [];
  AlwaysExclude: TMessageTypes = [mtUnknown];

implementation

uses
  HistoryGrid, hpp_database, hpp_services, HistoryForm, Math, hpp_forms;

var
  filterAll: TMessageTypes;

const
  hppIntDefEventFilters: array[0..5] of ThppEventFilter = (
    (Name: 'Show all events'; Events: []; filMode: FM_EXCLUDE; filEvents: []),
    (Name: 'Messages'; Events: []; filMode: FM_INCLUDE; filEvents: [mtMessage,mtIncoming,mtOutgoing]),
    (Name: 'Link URLs'; Events: []; filMode: FM_INCLUDE; filEvents: [mtUrl,mtIncoming,mtOutgoing]),
    (Name: 'Files'; Events: []; filMode: FM_INCLUDE; filEvents: [mtFile,mtIncoming,mtOutgoing]),
    (Name: 'Status changes'; Events: [];  filMode: FM_INCLUDE; filEvents: [mtStatus,mtIncoming,mtOutgoing]),
    (Name: 'All except status'; Events: []; filMode: FM_EXCLUDE; filEvents: [mtStatus])
    );


function IsSameAsDefault: Boolean;
var
  i: Integer;
begin
  Result := False;
  if Length(hppDefEventFilters) <> Length(hppEventFilters) then exit;
  for i := 0 to Length(hppEventFilters) - 1 do begin
    if hppEventFilters[i].Name <> hppDefEventFilters[i].Name then exit;
    if hppEventFilters[i].Events <> hppDefEventFilters[i].Events then exit;
  end;
  Result := True;
end;

function DWordToMessageTypes(dwmt: DWord): TMessageTypes;
begin
  Result := [];
  Move(dwmt,Result,SizeOf(Result));
end;

function MessageTypesToDWord(mt: TMessageTypes): DWord;
begin
  Result := 0;
  Move(mt,Result,SizeOf(mt));
end;

procedure UpdateEventFiltersOnForms;
begin
  NotifyAllForms(HM_NOTF_FILTERSCHANGED,0,0);
end;

function GenerateEvents(filMode: Byte; filEvents: TMessageTypes): TMessageTypes;
begin
  if filMode = FM_INCLUDE then
    Result := filEvents
  else
    Result := filterAll - filEvents;
  Result := Result - AlwaysExclude + AlwaysInclude;
end;

procedure GenerateEventFilters(var Filters: array of ThppEventFilter);
var
  i: Integer;
begin
  for i := 0 to Length(Filters) - 1 do begin
    Filters[i].Events := GenerateEvents(Filters[i].filMode,Filters[i].filEvents);
  end;
end;

procedure CopyEventFilters(var Src,Dest: ThppEventFilterArray);
var
  i: Integer;
begin
  SetLength(Dest,Length(Src));
  for i := 0 to Length(Src) - 1 do begin
    Dest[i].Name := Src[i].Name;
    Dest[i].Events := Src[i].Events;
    Dest[i].filMode := Src[i].filMode;
    Dest[i].filEvents := Src[i].filEvents;
  end;
end;

function GetShowAllEventsIndex(Arr: ThppEventFilterArray = nil): Integer;
var
  i: Integer;
begin
  if Arr = nil then Arr := hppEventFilters;
  Result := 0;
  for i := 0 to Length(Arr) - 1 do
    if (Arr[i].filMode = FM_EXCLUDE) and
    (Arr[i].filEvents = []) then begin
      Result := i;
      break;
    end;
end;

procedure DeleteEventFilterSettings;
var
  i: Integer;
begin
  i := 1;
  while True do begin
    if not DBDelete(hppDBName,'EventFilter'+IntToStr(i)) then break;
    Inc(i);
  end;
end;

procedure ResetEventFiltersToDefault;
begin
  CopyEventFilters(hppDefEventFilters,hppEventFilters);
  DeleteEventFilterSettings;
  UpdateEventFiltersOnForms;
end;


procedure ReadEventFilters;
var
  i: Integer;
  FilterStr: WideString;
  hex3,hex2,hex1: String;
  idx: Integer;
  filEvents: DWord;
  filMode: Byte;
  filFlags: Byte;
begin
  SetLength(hppEventFilters,0);
  try
    i := 1;
    while True do begin
      if not DBExists(hppDBName,'EventFilter'+IntToStr(i)) then begin
        if Length(hppEventFilters) = 0 then
          raise EAbort.Create('No filters')
        else
          break;
      end;
      FilterStr := GetDBWideStr(hppDBName,'EventFilter'+IntToStr(i),'');
      if FilterStr = '' then break;
      SetLength(hppEventFilters,Length(hppEventFilters)+1);
      // parse string
      idx := WideLastDelimiter(',',FilterStr);
      if (idx = 0) or (FilterStr[idx] <> ',') then
        raise EAbort.Create('Wrong filter ('+IntToStr(i)+') format');
      hex3 := Copy(FilterStr,idx+1,Length(FilterStr));
      Delete(FilterStr,idx,Length(FilterStr));
      idx := WideLastDelimiter(',',FilterStr);
      if (idx = 0) or (FilterStr[idx] <> ',') then
        raise EAbort.Create('Wrong filter ('+IntToStr(i)+') format');
      hex2 := Copy(FilterStr,idx+1,Length(FilterStr));
      Delete(FilterStr,idx,Length(FilterStr));
      idx := WideLastDelimiter(',',FilterStr);
      if (idx = 0) or (FilterStr[idx] <> ',') then
        raise EAbort.Create('Wrong filter ('+IntToStr(i)+') format');
      hex1 := Copy(FilterStr,idx+1,Length(FilterStr));
      Delete(FilterStr,idx,Length(FilterStr));

      if Length(FilterStr) = 0 then
        raise EAbort.Create('Wrong filter ('+IntToStr(i)+') format, name can not be empty');

      hppEventFilters[i-1].Name := FilterStr;
      filMode := 0;
      filEvents := 0;
      filFlags := 0;
      HexToBin(PChar(hex1),@filMode,SizeOf(filMode));
      HexToBin(PChar(hex2),@filEvents,SizeOf(filEvents));
      HexToBin(PChar(hex3),@filFlags,SizeOf(filFlags));
      hppEventFilters[i-1].filMode := filMode;
      hppEventFilters[i-1].filEvents := DWordToMessageTypes(filEvents);

      Inc(i);
    end;
    GenerateEventFilters(hppEventFilters);
  except
    ResetEventFiltersToDefault;
  end;
end;

procedure WriteEventFilters;
var
  i: Integer;
  FilterStr: WideString;
  hex: String;
begin
  if Length(hppEventFilters) = 0 then begin
    ResetEventFiltersToDefault;
    exit;
  end;
  if IsSameAsDefault then begin
    // revert to default state
    DeleteEventFilterSettings;
    UpdateEventFiltersOnForms;
    exit;
  end;

  for i := 0 to Length(hppEventFilters) - 1 do begin
    FilterStr := Copy(hppEventFilters[i].Name,1,MAX_FILTER_NAME_LENGTH);
    // add filMode
    SetLength(hex,SizeOf(hppEventFilters[i].filMode)*2);
    BinToHex(@hppEventFilters[i].filMode,@hex[1],SizeOf(hppEventFilters[i].filMode));
    FilterStr := FilterStr + ','+hex;
    // add filEvents
    SetLength(hex,SizeOf(hppEventFilters[i].filEvents)*2);
    BinToHex(@hppEventFilters[i].filEvents,@hex[1],SizeOf(hppEventFilters[i].filEvents));
    FilterStr := FilterStr + ','+hex;
    // add filFlags
    //SetLength(hex,SizeOf(Byte)*2);
    //BinToHex(@hppEventFilters[i].filFlags,@hex[1],SizeOf(hppEventFilters[i].filFlags));
    hex := '00';
    FilterStr := FilterStr + ','+hex;
    WriteDBWideStr(hppDBName,'EventFilter'+IntToStr(i+1),FilterStr);
  end;
  // delete left filters if we have more than Length(hppEventFilters)
  i := Length(hppEventFilters)+1;
  while True do begin
    if not DBDelete(hppDBName,'EventFilter'+IntToStr(i)) then break;
    Inc(i);
  end;
  UpdateEventFiltersOnForms;
end;

procedure InitEventFilters;
var
  i: Integer;
  mt: TMessageType;
begin
  // translate and copy internal default static array to dynamic array
  SetLength(hppDefEventFilters,Length(hppIntDefEventFilters));
  for i := 0 to High(hppIntDefEventFilters) do begin
    hppDefEventFilters[i].Name := Copy(TranslateWideW(hppIntDefEventFilters[i].Name),1,MAX_FILTER_NAME_LENGTH);
    hppDefEventFilters[i].filMode := hppIntDefEventFilters[i].filMode;
    hppDefEventFilters[i].filEvents := hppIntDefEventFilters[i].filEvents;
  end;

  filterAll := [];
  for mt := Low(TMessageType) to High(TMessageType) do
    Include(filterAll,mt);

  GenerateEventFilters(hppDefEventFilters);
end;

end.
