{-----------------------------------------------------------------------------
 GlobalSearch (historypp project)

 Version:   1.0
 Created:   05.08.2004
 Author:    Oxygen

 [ Description ]

 Here we have the form and UI for global searching. Curious
 can go to hpp_searchthread for internals of searching.

 [ History ]

 1.5 (05.08.2004)
   First version

 [ Modifications ]
 none

 [ Known Issues ]

 * When doing HotSearch, and then backspacing to empty search string
   grid doesn't return to the first item HotSearch started from
   unlike in HistoryForm. Probably shouldn't be done, because too much checking
   to reset LastHotIdx should be done, considering how much filtering &
   sorting is performed.

 Copyright (c) Art Fedorov, 2004
-----------------------------------------------------------------------------}

unit GlobalSearch;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus,
  TntForms, TntComCtrls, TntExtCtrls, TntStdCtrls, TntSysUtils,
  HistoryGrid,
  m_globaldefs, m_api,
  hpp_global, hpp_events, hpp_services, hpp_contacts,  hpp_database,  hpp_searchthread,
  hpp_bookmarks, 
  ImgList, PasswordEditControl, Buttons, TntButtons, Math, CommCtrl,
  Contnrs, TntMenus, hpp_forms;

const
  HM_SRCH_EVENTDELETED       = HM_SRCH_BASE + 1;
  HM_SRCH_CONTACTDELETED     = HM_SRCH_BASE + 2;
  HM_SRCH_CONTACTICONCHANGED = HM_SRCH_BASE + 3;
  HM_SRCH_PRESHUTDOWN        = HM_SRCH_BASE + 4;

type
  TContactInfo = class(TObject)
    public
      Proto: String;
      Codepage: Cardinal;
      RTLMode: TRTLMode;
      Name: WideString;
      ProfileName: WideString;
      Handle: THandle;
  end;

  TSearchItem = record
    hDBEvent: THandle;
    Contact: TContactInfo;
    end;

  TfmGlobalSearch = class(TTntForm)
    Panel1: TtntPanel;
    paSearch: TtntPanel;
    laSearch: TTntLabel;
    edSearch: TtntEdit;
    bnSearch: TtntButton;
    sb: TtntStatusBar;
    paProgress: TtntPanel;
    pb: TProgressBar;
    laProgress: TTntLabel;
    pmGrid: TtntPopupMenu;
    Open1: TtntMenuItem;
    Copy1: TtntMenuItem;
    CopyText1: TtntMenuItem;
    N1: TtntMenuItem;
    N2: TtntMenuItem;
    bnAdvanced: TtntButton;
    gbAdvanced: TtntGroupBox;
    rbAny: TtntRadioButton;
    rbAll: TtntRadioButton;
    rbExact: TtntRadioButton;
    spContacts: TTntSplitter;
    paPassword: TtntPanel;
    edPass: TPasswordEdit;
    cbPass: TTntCheckBox;
    laPass: TTntLabel;
    ilContacts: TImageList;
    paContacts: TTntPanel;
    lvContacts: TTntListView;
    SendMessage1: TtntMenuItem;
    ReplyQuoted1: TtntMenuItem;
    SaveSelected1: TtntMenuItem;
    SaveDialog: TSaveDialog;
    tiFilter: TTimer;
    paHistory: TtntPanel;
    hg: THistoryGrid;
    paFilter: TtntPanel;
    sbClearFilter: TTntSpeedButton;
    edFilter: TTntEdit;
    pbFilter: TPaintBox;
    Delete1: TTntMenuItem;
    N3: TTntMenuItem;
    Bookmark1: TTntMenuItem;
    procedure pbFilterPaint(Sender: TObject);
    procedure edFilterKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tiFilterTimer(Sender: TObject);
    procedure sbClearFilterClick(Sender: TObject);
    procedure edPassKeyPress(Sender: TObject; var Key: Char);
    procedure edSearchKeyPress(Sender: TObject; var Key: Char);
    procedure hgItemDelete(Sender: TObject; Index: Integer);
    procedure OnCNChar(var Message: TWMChar); message WM_CHAR;
    procedure SaveSelected1Click(Sender: TObject);
    procedure hgPopup(Sender: TObject);
    procedure ReplyQuoted1Click(Sender: TObject);
    procedure SendMessage1Click(Sender: TObject);
    procedure edFilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure hgItemFilter(Sender: TObject; Index: Integer; var Show: Boolean);
    procedure edFilterChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure hgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure hgState(Sender: TObject; State: TGridState);
    procedure hgSearchFinished(Sender: TObject; Text: WideString;
      Found: Boolean);
    procedure hgSearchItem(Sender: TObject; Item, ID: Integer;
      var Found: Boolean);
    //procedure TntFormHide(Sender: TObject);
    procedure TntFormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure cbPassClick(Sender: TObject);
    procedure lvContactsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure hgNameData(Sender: TObject; Index: Integer; var Name: WideString);
    procedure hgTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bnSearchClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure hgItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
    procedure hgDblClick(Sender: TObject);
    procedure edSearchEnter(Sender: TObject);
    procedure edSearchKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure hgProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
    procedure FormShow(Sender: TObject);
    procedure hgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure hgUrlClick(Sender: TObject; Item: Integer; Url: String);
    procedure edPassKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure bnAdvancedClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure hgSelect(Sender: TObject; Item, OldItem: Integer);
    procedure Copy1Click(Sender: TObject);
    procedure CopyText1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure hgRTLEnabled(Sender: TObject; Enabled: Boolean);
    procedure Bookmark1Click(Sender: TObject);
    procedure hgBookmarkClick(Sender: TObject; Item: Integer);
    procedure lvContactsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private
    UserMenu: hMenu;
    UserMenuContact: THandle;
    WasReturnPressed: Boolean;
    LastUpdateTime: Cardinal;
    HotString: WideString;
    hHookContactIconChanged, hHookContactDeleted, hHookEventDeleted,
      hHookEventPreShutdown: THandle;
    FContactFilter: Integer;
    FFiltered: Boolean;
    IsSearching: Boolean;
    History: array of TSearchItem;
    FilterHistory: array of Integer;
    CurContact: THandle;
    st: TSearchThread;
    stime: DWord;
    ContactsFound: Integer;
    AllItems: Integer;
    AllContacts: Integer;
    HotFilterString: WideString;
    FormState: TGridState;

    procedure SMPrepare(var M: TMessage); message HM_STRD_PREPARE;
    procedure SMProgress(var M: TMessage); message HM_STRD_PROGRESS;
    procedure SMItemsFound(var M: TMessage); message HM_STRD_ITEMSFOUND;
    procedure SMNextContact(var M: TMessage); message HM_STRD_NEXTCONTACT;
    procedure SMFinished(var M: TMessage); message HM_STRD_FINISHED;

    procedure HMEventDeleted(var M: TMessage); message HM_SRCH_EVENTDELETED;
    function FindHistoryItemByHandle(hDBEvent: THandle): Integer;
    procedure DeleteEventFromLists(Item: Integer);
    procedure HMContactDeleted(var M: TMessage); message HM_SRCH_CONTACTDELETED;
    procedure HMContactIconChanged(var M: TMessage); message HM_SRCH_CONTACTICONCHANGED;
    procedure HMPreShutdown(var M: TMessage); message HM_SRCH_PRESHUTDOWN;

    procedure HMIcons2Changed(var M: TMessage); message HM_NOTF_ICONS2CHANGED;
    procedure HMBookmarksChanged(var M: TMessage); message HM_NOTF_BOOKMARKCHANGED;

    procedure TranslateForm;

    procedure HookEvents;
    procedure UnhookEvents;

    procedure ShowAdvancedPanel(Show: Boolean);
    procedure ShowContacts(Show: Boolean);

    procedure SearchNext(Rev: Boolean; Warp: Boolean = True);
    procedure ReplyQuoted(Item: Integer);
    procedure StartHotFilterTimer;
    procedure EndHotFilterTimer;

    procedure StopSearching;
  private
    LastAddedContact: TContactInfo;
    ContactList: TObjectList;
    //function FindContact(hContact: Integer): TContactInfo;
    function AddContact(hContact: Integer): TContactInfo;
  protected
    procedure LoadWindowPosition;
    procedure SaveWindowPosition;
    procedure WndProc(var Message: TMessage); override;
  public
    procedure SetRecentEventsPosition(OnTop: Boolean);
  published
    // fix for splitter baug:
    procedure AlignControls(Control: TControl; var ARect: TRect); override;

    function GetSearchItem(GridIndex: Integer): TSearchItem;
    procedure DisableFilter;
    procedure FilterOnContact(hContact: Integer);

    procedure LoadButtonIcons;
    procedure LoadContactsIcons;
  public
    { Public declarations }
  end;

var
  fmGlobalSearch: TfmGlobalSearch;

const
  DEFAULT_SEARCH_TEXT = 'http: ftp: www. ftp.';

var
  GlobalSearchAllResultsIcon: Integer = -1;

implementation

uses hpp_options, PassForm, hpp_itemprocess, hpp_messages,
  HistoryForm;

{$R *.DFM}

function TfmGlobalSearch.AddContact(hContact: Integer): TContactInfo;
var
  ci: TContactInfo;
begin
  ci := TContactInfo.Create;
  ci.Handle := hContact;
  ci.Proto := GetContactProto(CurContact);
  ci.Codepage := GetContactCodePage(hContact,ci.Proto);
  ci.Name := GetContactDisplayName(ci.Handle,ci.Proto,true);
  ci.ProfileName := GetContactDisplayName(0,ci.Proto);
  ci.RTLMode := GetContactRTLModeTRTL(ci.handle,ci.Proto);
  ContactList.Add(ci);
  Result := ci;
end;

// fix for infamous splitter bug!
// thanks to Greg Chapman
// http://groups.google.com/group/borland.public.delphi.objectpascal/browse_thread/thread/218a7511123851c3/5ada76e08038a75b%235ada76e08038a75b?sa=X&oi=groupsr&start=2&num=3
procedure TfmGlobalSearch.AlignControls(Control: TControl; var ARect: TRect);
begin
  inherited;
  if paContacts.Width = 0 then
    paContacts.Left := spContacts.Left;
end;

procedure TfmGlobalSearch.FormCreate(Sender: TObject);
//var
//  NonClientMetrics: TNonClientMetrics;
begin
//  Setting different system font different way. For me works the same
//  but some said it produces better results than DesktopFont
//  Leave it here for possible future use.
//
//  NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
//  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0);
//  Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);
//  if Scaled then begin
//    Font.Height := NonClientMetrics.lfMessageFont.lfHeight;
//  end;
  DesktopFont := True;
  MakeFontsParent(Self);

  FormState := gsIdle;

  ContactList := TObjectList.Create;

  ilContacts.Handle := PluginLink.CallService(MS_CLIST_GETICONSIMAGELIST,0,0);
  LoadButtonIcons;
  LoadContactsIcons;
end;

procedure TfmGlobalSearch.SMFinished(var M: TMessage);
var
  sbt: WideString;
begin
  stime := st.SearchTime;
  AllContacts := st.AllContacts;
  AllItems := st.AllEvents;
  // if change, change also in hg.State:
  sbt := WideFormat(TranslateWideW('%.0n items in %d contacts found. Searched for %.1f sec in %.0n items.'),[Length(History)/1, ContactsFound, stime/1000, AllItems/1]);
  st.WaitFor;
  FreeAndNil(st);
  IsSearching := False;
  bnSearch.Caption := TranslateWideW('Search');
  paProgress.Hide;
  //paFilter.Show;
  sb.SimpleText := sbt;
  if Length(History) = 0 then
    ShowContacts(False);
end;

procedure TfmGlobalSearch.SMItemsFound(var M: TMessage);
var
  li: TtntListItem;
  ci: TContactInfo;
  Buffer: PDBArray;
  FiltOldSize,OldSize,i,BufCount: Integer;
begin
  // wParam - array of hDBEvent, lParam - array size
  Buffer := PDBArray(m.wParam);
  BufCount := Integer(m.LParam);
  OldSize := Length(History);
  SetLength(History,OldSize+BufCount);

  if (LastAddedContact = nil) or (LastAddedContact.Handle <> CurContact) then begin
    ci := AddContact(CurContact);
    LastAddedContact := ci;
  end;

  for i := 0 to BufCount - 1 do begin
    History[OldSize + i].hDBEvent := Buffer^[i];
    History[OldSize + i].Contact := LastAddedContact;
    //History[OldSize + i].hContact := CurContact;
    //History[OldSize + i].ContactName := CurContactName;
    //History[OldSize + i].ProfileName := CurProfileName;
    //History[OldSize + i].Proto := CurProto;
  end;

  FreeMem(Buffer,SizeOf(Buffer^));

  if (lvContacts.Items.Count = 0) or (Integer(lvContacts.Items.Item[lvContacts.Items.Count-1].Data) <> CurContact) then begin
    if lvContacts.Items.Count = 0 then begin
    li := lvContacts.Items.Add;
      li.Caption := TranslateWideW('All Results');
      li.ImageIndex := GlobalSearchAllResultsIcon;
      li.Selected := True;
    end;
    li := lvContacts.Items.Add;
    if CurContact = 0 then
      li.Caption := TranslateWideW('System History')
    else begin
      li.Caption := LastAddedContact.Name;
      //li.Caption := CurContactName;
      Inc(ContactsFound);
    end;
    li.ImageIndex := PluginLink.CallService(MS_CLIST_GETCONTACTICON,CurContact,0);
    //meTest.Lines.Add(CurContactName+' icon is '+IntToStr(PluginLink.CallService(MS_CLIST_GETCONTACTICON,CurContact,0)));
    li.Data := Pointer(CurContact);
  end;

  if FFiltered then begin
    if CurContact = FContactFilter then begin
      FiltOldSize := Length(FilterHistory);
      for i := 0 to BufCount - 1 do
        FilterHistory[FiltOldSize+i] := OldSize + i;
      hg.Allocate(Length(FilterHistory));
    end;
  end
  else
    hg.Allocate(Length(History));

  if (hg.Count > 0) and (hg.Selected = -1) then
    hg.Selected := 0;

  paFilter.Visible := True;
  if not paContacts.Visible then begin
     ShowContacts(True);
     hg.Selected := 0;
     hg.SetFocus;
  end;

  // dirty hack: readjust scrollbars
  hg.Perform(WM_SIZE,SIZE_RESTORED,MakeLParam(hg.ClientWidth,hg.ClientHeight));
  //hg.Repaint;
  //Application.ProcessMessages;
end;

procedure TfmGlobalSearch.SMNextContact(var M: TMessage);
var
  CurProto: String;
begin
  // wParam - hContact, lParam - 0
  CurContact := m.wParam;
  if CurContact = 0 then CurProto := 'ICQ'
                    else CurProto := GetContactProto(CurContact);
  laProgress.Caption := WideFormat(TranslateWideW('Searching "%s"...'),[GetContactDisplayName(CurContact,CurProto,true)]);
end;

procedure TfmGlobalSearch.SMPrepare(var M: TMessage);
begin
  LastUpdateTime := 0;
  ContactsFound := 0;
  AllItems := 0;
  AllContacts := 0;
  FFiltered := False;
  hg.Selected := -1;
  hg.Allocate(0);

  SetLength(FilterHistory,0);
  SetLength(History,0);

  IsSearching := True;
  bnSearch.Caption := TranslateWideW('Stop');

  sb.SimpleText := TranslateWideW('Searching... Please wait.');
  laProgress.Caption := TranslateWideW('Preparing search...');
  pb.Position := 0;
  paProgress.Show;
  paFilter.Visible := False;
  //ShowContacts(False);
  lvContacts.Items.Clear;
  ContactList.Clear;
  LastAddedContact := nil;
end;

procedure TfmGlobalSearch.SMProgress(var M: TMessage);
begin
  // wParam - progress; lParam - max

  if (GetTickCount - LastUpdateTime) < 100 then exit;
  LastUpdateTime := GetTickCount;

  pb.Max := m.LParam;
  pb.Position := m.Wparam;
  //Application.ProcessMessages;

  // if change, change also in hg.OnState
  sb.SimpleText := WideFormat(TranslateWideW('Searching... %.0n items in %d contacts found'),[Length(History)/1, ContactsFound]);
end;

procedure TfmGlobalSearch.StartHotFilterTimer;
begin
  if tiFilter.Interval = 0 then
    EndHotFilterTimer
  else begin
    tiFilter.Enabled := False;
    tiFilter.Enabled := True;
    if pbFilter.Tag <> 1 then begin // use Tag to not repaint every keystroke
      pbFilter.Tag := 1;
      pbFilter.Repaint;
    end;
  end;
end;

procedure TfmGlobalSearch.tiFilterTimer(Sender: TObject);
begin
  EndHotFilterTimer;
end;

procedure TfmGlobalSearch.edFilterChange(Sender: TObject);
begin
  StartHotFilterTimer;
end;

procedure TfmGlobalSearch.edFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_UP,VK_DOWN,VK_NEXT, VK_PRIOR] then begin
    SendMessage(hg.Handle,WM_KEYDOWN,Key,0);
    Key := 0;
  end;
end;

procedure TfmGlobalSearch.edFilterKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    hg.SetFocus;
    key := 0;
  end;
end;

procedure TfmGlobalSearch.FormDestroy(Sender: TObject);
begin
  fmGlobalSearch := nil;
  ContactList.Free;
end;

procedure TfmGlobalSearch.TntFormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  ctrl: TControl;
begin
  Handled := True;
  ctrl := Panel1.ControlAtPos(Panel1.ScreenToClient(MousePos),False,True);
  {$RANGECHECKS OFF}
  if Assigned(ctrl) then begin
    if Ctrl.Name = 'paContacts' then begin
      Handled := not TTntListView(ctrl).Focused;
      if Handled then begin
        // ??? what to do here?
        // how to tell listview to scroll?
      end;
    end
    else begin
      hg.perform(WM_MOUSEWHEEL,MakeLong(MK_CONTROL,WheelDelta),0);
    end;
  end;
  {$RANGECHECKS ON}
end;

procedure TfmGlobalSearch.sbClearFilterClick(Sender: TObject);
begin
  edFilter.Text := '';
  EndHotFilterTimer;
  hg.SetFocus;
end;

procedure TfmGlobalSearch.TranslateForm;

procedure TranslateMenu(mi: TMenuItem);
  var
    i: integer;
  begin
    for i := 0 to mi.Count-1 do
      if mi.Items[i].Caption <> '-' then begin
        TTntMenuItem(mi.Items[i]).Caption := TranslateWideW(mi.Items[i].Caption{TRANSLATE-IGNORE});
          if mi.Items[i].Count > 0 then TranslateMenu(mi.Items[i]);
      end;
  end;

begin
  Caption := TranslateWideW(Caption);

  laSearch.Caption := TranslateWideW(laSearch.Caption);
  bnSearch.Caption := TranslateWideW(bnSearch.Caption);
  bnAdvanced.Caption := TranslateWideW(bnAdvanced.Caption);
  gbAdvanced.Caption := TranslateWideW(gbAdvanced.Caption);
  rbAny.Caption := TranslateWideW(rbAny.Caption);
  rbAll.Caption := TranslateWideW(rbAll.Caption);
  rbExact.Caption := TranslateWideW(rbExact.Caption);

  cbPass.Caption := TranslateWideW(cbPass.Caption);
  laPass.Caption := TranslateWideW(laPass.Caption);
  sbClearFilter.Hint := TranslateWideW(sbClearFilter.Hint);

  SaveDialog.Title := Translate(PAnsiChar(SaveDialog.Title));

  TranslateMenu(pmGrid.Items);

  hg.TxtFullLog := TranslateWideW(hg.txtFullLog);
  hg.TxtGenHist1 := TranslateWideW(hg.txtGenHist1);
  hg.TxtGenHist2 := TranslateWideW(hg.txtGenHist2);
  hg.TxtHistExport := TranslateWideW(hg.TxtHistExport);
  hg.TxtNoItems := TranslateWideW(hg.TxtNoItems);
  hg.TxtNoSuch := TranslateWideW(hg.TxtNoSuch);
  hg.TxtPartLog := TranslateWideW(hg.TxtPartLog);
  hg.txtStartUp := TranslateWideW(hg.txtStartUp);

  edSearch.Left := laSearch.Left + laSearch.Width + 5;
  edSearch.Width := bnSearch.Left - edSearch.Left - 5;

  edPass.Left := laPass.Left + laPass.Width + 10;
end;

procedure TfmGlobalSearch.FilterOnContact(hContact: Integer);
var
  i: Integer;
begin
  if FFiltered and (FContactFilter = hContact) then exit;
  FFiltered := True;
  FContactFilter := hContact;
  SetLength(FilterHistory,0);
  for i := 0 to Length(History)-1 do begin
    if History[i].Contact.Handle = hContact then begin
      SetLength(FilterHistory,Length(FilterHistory)+1);
      FilterHistory[High(FilterHistory)] := i;
    end;
  end;
  hg.Allocate(0);
  hg.Allocate(Length(FilterHistory));
  if hg.Count > 0 then begin
    // dirty hack: readjust scrollbars
    hg.Perform(WM_SIZE,SIZE_RESTORED,MakeLParam(hg.ClientWidth,hg.ClientHeight));
    hg.Selected := 0;
  end;
end;

{function TfmGlobalSearch.FindContact(hContact: Integer): TContactInfo;
begin
  Result := nil;
end;}

function TfmGlobalSearch.FindHistoryItemByHandle(hDBEvent: THandle): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(History) - 1 do begin
    if History[i].hDBEvent = hDBEvent then begin
      Result := i;
      break;
    end;
  end;
end;

procedure TfmGlobalSearch.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  try
    Action := caFree;
    SaveWindowPosition;
    UnhookEvents;
  except
  end;
end;

procedure TfmGlobalSearch.StopSearching;
begin
  bnSearch.Enabled := False;
  try
    st.Terminate;
    while IsSearching do
      Application.ProcessMessages;
  finally
    bnSearch.Enabled := True;
  end;
  edSearch.SetFocus;
  exit;
end;

procedure TfmGlobalSearch.bnSearchClick(Sender: TObject);
begin
  if IsSearching then begin
    StopSearching;
    exit;
  end;
  if edSearch.Text = '' then
    raise Exception.Create('Enter text to search');
  if edPass.Enabled then begin
    if edPass.Text = '' then begin
      HppMessageBox(Handle,TranslateWideW('Enter the history password to search.'),
        TranslateWideW('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
      edPass.SetFocus;
      edPass.SelectAll;
      exit;
    end;
    if not CheckPassword(edPass.Text) then begin
      HppMessageBox(Handle,TranslateWideW('You have entered the wrong password.'),
        TranslateWideW('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
      edPass.SetFocus;
      edPass.SelectAll;
      exit;
    end;
  end;

  st := TSearchThread.Create(True);
  if rbAny.Checked then
    st.SearchMethod := smAnyWord
  else if rbAll.Checked then
    st.SearchMethod := smAllWords
  else
    st.SearchMethod := smExact;

  st.Priority := tpLower;
  st.ParentHandle := Self.Handle;
  st.SearchText := edSearch.text;
  st.SearchProtectedContacts := edPass.Enabled;
  st.Resume;
end;


procedure TfmGlobalSearch.cbPassClick(Sender: TObject);
begin
  laPass.Enabled := cbPass.Enabled and cbPass.Checked;
  edPass.Enabled := cbPass.Enabled and cbPass.Checked;
end;

// takes index from *History* array as parameter
procedure TfmGlobalSearch.DeleteEventFromLists(Item: Integer);
var
  i: Integer;
  EventDeleted: Boolean;
begin
  if Item = -1 then exit;
  for i := Item to Length(History) - 2 do begin
    History[i] := History[i+1];
  end;
  SetLength(History,Length(History)-1);

  if not FFiltered then exit;

  EventDeleted := False;
  for i := 0 to Length(FilterHistory) - 1 do begin
    if FilterHistory[i] = Item then EventDeleted := True;
    if (EventDeleted) and (i < Length(FilterHistory)-1) then FilterHistory[i] := FilterHistory[i+1];
    if EventDeleted then Dec(FilterHistory[i]);

  end;
  if EventDeleted then SetLength(FilterHistory,Length(FilterHistory)-1);
end;

procedure TfmGlobalSearch.DisableFilter;
begin
  if not FFiltered then exit;
  FFiltered := False;
  SetLength(FilterHistory,0);
  hg.Allocate(0);
  if Length(History) > 0 then begin
    hg.Allocate(Length(History));
    hg.Selected := 0;
  end else
    hg.Selected := -1;
  // dirty hack: readjust scrollbars
  hg.Perform(WM_SIZE,SIZE_RESTORED,MakeLParam(hg.ClientWidth,hg.ClientHeight));
end;

procedure TfmGlobalSearch.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Flag: UINT;
  AppSysMenu: THandle;
begin
  if IsSearching then begin
    // disable close button
    AppSysMenu:=GetSystemMenu(Handle,False);
    Flag:=MF_GRAYED;
    EnableMenuItem(AppSysMenu,SC_CLOSE,MF_BYCOMMAND or Flag);

    st.Terminate;
    laProgress.Caption := TranslateWideW('Please wait while closing the window...');
    laProgress.Font.Style := [fsBold];
    pb.Visible := False;
    if IsSearching then
      SetThreadPriority(st.Handle, THREAD_PRIORITY_ABOVE_NORMAL);
    while IsSearching do
      Application.ProcessMessages;
    end;
end;

procedure TfmGlobalSearch.hgItemData(Sender: TObject; Index: Integer;
  var Item: THistoryItem);
begin
  Item := ReadEvent(GetSearchItem(Index).hDBEvent,GetSearchItem(Index).Contact.Codepage);
  Item.Proto := GetSearchItem(Index).Contact.Proto;
  Item.RTLMode := GetSearchItem(Index).Contact.RTLMode;
  Item.Bookmarked := BookmarkServer[GetSearchItem(Index).Contact.Handle].Bookmarked[GetSearchItem(Index).hDBEvent];
end;

procedure TfmGlobalSearch.hgItemDelete(Sender: TObject; Index: Integer);
var
  si: TSearchItem;
begin
  si := GetSearchItem(Index);
  if (FormState = gsDelete) and (si.hDBEvent <> 0) then
    PluginLink.CallService(MS_DB_EVENT_DELETE,si.Contact.Handle,si.hDBEvent);
  if FFiltered then
    Index := FilterHistory[Index];
  DeleteEventFromLists(Index);
  hgState(hg,hg.State);
  Application.ProcessMessages;
end;

procedure TfmGlobalSearch.hgItemFilter(Sender: TObject; Index: Integer;
  var Show: Boolean);
begin
  if HotFilterString = '' then exit;
  if Pos(WideUpperCase(HotFilterString),WideUpperCase(hg.Items[Index].Text)) = 0 then
    Show := False;
end;

procedure TfmGlobalSearch.hgBookmarkClick(Sender: TObject; Item: Integer);
var
  val: boolean;
  hContact,hDBEvent: THandle;
begin
  hContact := GetSearchItem(Item).Contact.Handle;
  hDBEvent := GetSearchItem(Item).hDBEvent;
  val := not BookmarkServer[hContact].Bookmarked[hDBEvent];
  BookmarkServer[hContact].Bookmarked[hDBEvent] := val;
end;

procedure TfmGlobalSearch.hgDblClick(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  PluginLink.CallService(MS_HPP_OPENHISTORYEVENT,GetSearchItem(hg.Selected).hDBEvent,GetSearchItem(hg.Selected).Contact.Handle);
end;

procedure TfmGlobalSearch.edSearchChange(Sender: TObject);
begin
  bnSearch.Enabled := (edSearch.Text <> '');
end;

procedure TfmGlobalSearch.edSearchEnter(Sender: TObject);
begin
  //edSearch.SelectAll;
end;

procedure TfmGlobalSearch.LoadButtonIcons;
begin
  with sbClearFilter.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := paFilter.Color;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      hppIcons[HPP_ICON_HOTFILTERCLEAR].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
end;

procedure TfmGlobalSearch.LoadContactsIcons;
begin
  lvContacts.Items.BeginUpdate;

  if GlobalSearchAllResultsIcon = -1 then
    GlobalSearchAllResultsIcon := ImageList_AddIcon(ilContacts.Handle,hppIcons[HPP_ICON_SEARCH_ALLRESULTS].Handle)
  else
    ImageList_ReplaceIcon(ilContacts.Handle,GlobalSearchAllResultsIcon,hppIcons[HPP_ICON_SEARCH_ALLRESULTS].Handle);

  lvContacts.Items.EndUpdate;
end;

procedure TfmGlobalSearch.LoadWindowPosition;
var
  n: Integer;
begin
  if Utils_RestoreWindowPosition(Self.Handle,0,0,hppDBName,'GlobalSearchWindow.') <> 0 then begin
    Self.Left := (Screen.Width-Self.Width) div 2;
    Self.Top := (Screen.Height - Self.Height) div 2;
  end;
    // if we are password-protected (cbPass.Enabled) and
  // have PROTSEL (not (cbPass.Checked)) then load
  // checkbox from DB
  if (cbPass.Enabled) and not (cbPass.Checked) then begin
    cbPass.Checked := GetDBBool(hppDBName,'GlobalSearchWindow.PassChecked',False);
    cbPassClick(cbPass);
  end;

  n := GetDBInt(hppDBName,'GlobalSearchWindow.ContactListWidth',-1);
  if n <> -1 then begin
    paContacts.Width := n;
  end;
  spContacts.Left := paContacts.Left + paContacts.Width + 1;
  edFilter.Width := paFilter.Width - edFilter.Left - 2;


  SetRecentEventsPosition(GetDBInt(hppDBName,'SortOrder',0) <> 0);

  ShowAdvancedPanel(GetDBBool(hppDBName,'GlobalSearchWindow.ShowAdvanced',False));
  case GetDBInt(hppDBName,'GlobalSearchWindow.AdvancedOptions',0) of
    0: rbAny.Checked := True;
    1: rbAll.Checked := True;
    2: rbExact.Checked := True
  else
    rbAny.Checked := True;
  end;

  edSearch.Text := AnsiToWideString(GetDBStr(hppDBName,'GlobalSearchWindow.LastSearch',DEFAULT_SEARCH_TEXT),hppCodepage);
end;

procedure TfmGlobalSearch.lvContactsContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TTntListItem;
  hContact: THandle;
begin
  Handled := True;
  Item := TTntListItem(lvContacts.GetItemAt(MousePos.X,MousePos.Y));
  if Item = nil then exit;
  hContact := Integer(Item.Data);
  if hContact = 0 then exit;  
  UserMenu := PluginLink.CallService(MS_CLIST_MENUBUILDCONTACT,hContact,0);
  if UserMenu <> 0 then begin
    UserMenuContact := hContact;
    MousePos := lvContacts.ClientToScreen(MousePos);
    TrackPopupMenu(UserMenu,TPM_TOPALIGN or TPM_LEFTALIGN or TPM_LEFTBUTTON,MousePos.x,MousePos.y,0,Handle,nil);
    DestroyMenu(UserMenu);
    UserMenu := 0;
    //UserMenuContact := 0;
  end;
end;

procedure TfmGlobalSearch.lvContactsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  hCont: Integer;
  //i,Index: Integer;
begin
  if not Selected then exit;

  {Index := -1;
  hCont := Integer(Item.Data);
  for i := 0 to Length(History) - 1 do
    if History[i].hContact = hCont then begin
      Index := i;
      break;
    end;
  if Index = -1 then exit;
  hg.Selected := Index;}

  // OXY: try to make selected item the topmost
  //while hg.GetFirstVisible <> Index do begin
  //  if hg.VertScrollBar.Position = hg.VertScrollBar.Range then break;
  //  hg.VertScrollBar.Position := hg.VertScrollBar.Position + 1;
  //end;

  if Item.Index = 0 then
    DisableFilter
  else begin
    hCont := Integer(Item.Data);
    FilterOnContact(hCont);
  end;
end;

procedure TfmGlobalSearch.OnCNChar(var Message: TWMChar);
//make tabs work!
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

procedure TfmGlobalSearch.pbFilterPaint(Sender: TObject);
var
  ic: hIcon;
begin
  if tiFilter.Enabled then
    ic := hppIcons[HPP_ICON_HOTFILTERWAIT].Handle
  else
    ic := hppIcons[HPP_ICON_HOTFILTER].Handle;

  DrawIconEx(pbFilter.Canvas.Handle,0,0,ic,
    16,16,0,pbFilter.Canvas.Brush.Handle,DI_NORMAL);
end;

procedure TfmGlobalSearch.ReplyQuoted(Item: Integer);
begin
  if (GetSearchItem(Item).Contact.Handle = 0) or (hg.SelCount = 0) then exit;
  SendMessageTo(GetSearchItem(Item).Contact.Handle,hg.FormatSelected(hg.Options.ReplyQuotedFormat));
end;

procedure TfmGlobalSearch.ReplyQuoted1Click(Sender: TObject);
begin
  if hg.Selected <> -1 then begin
    if GetSearchItem(hg.Selected).Contact.Handle = 0 then exit;
    ReplyQuoted(hg.Selected);
  end;
end;

procedure TfmGlobalSearch.SaveSelected1Click(Sender: TObject);
var
  t,t1: String;
  SaveFormat: TSaveFormat;
  RecentFormat: TSaveFormat;
begin
  RecentFormat := TSaveFormat(GetDBInt(hppDBName,'ExportFormat',0));
  SaveFormat := RecentFormat;
  PrepareSaveDialog(SaveDialog,SaveFormat,True);
  t1 := TranslateWideW('Partial History [%s] - [%s]');
  t1 := WideFormat(t1,[hg.ProfileName,hg.ContactName]);
  t := MakeFileName(WideToAnsiString(t1,hppCodepage));
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  case SaveDialog.FilterIndex of
    1: SaveFormat := sfHtml;
    2: SaveFormat := sfXml;
    3: SaveFormat := sfUnicode;
    4: SaveFormat := sfText;
  end;
  RecentFormat := SaveFormat;
  hg.SaveSelected(SaveDialog.Files[0],SaveFormat);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure TfmGlobalSearch.SaveWindowPosition;
var
  LastSearch: WideString;
begin
Utils_SaveWindowPosition(Self.Handle,0,'HistoryPlusPlus','GlobalSearchWindow.');

  // if we are password-protected (cbPass.Enabled) and
  // have PROTSEL (GetPassMode = PASSMODE_PROTSEL) then save
  // checkbox to DB
  if (cbPass.Enabled) and (GetPassMode = PASSMODE_PROTSEL) then
    WriteDBBool(hppDBName,'GlobalSearchWindow.PassChecked',cbPass.Checked);

  WriteDBInt(hppDBName,'GlobalSearchWindow.ContactListWidth',paContacts.Width);

  WriteDBBool(hppDBName,'GlobalSearchWindow.ShowAdvanced',gbAdvanced.Visible);
  if rbAny.Checked then
    WriteDBInt(hppDBName,'GlobalSearchWindow.AdvancedOptions',0)
  else if rbAll.Checked then
    WriteDBInt(hppDBName,'GlobalSearchWindow.AdvancedOptions',1)
  else
    WriteDBInt(hppDBName,'GlobalSearchWindow.AdvancedOptions',2);

  LastSearch := WideToAnsiString(edSearch.Text,hppCodepage);
  WriteDBWideStr(hppDBName,'GlobalSearchWindow.LastSearch',LastSearch);
end;

procedure TfmGlobalSearch.edSearchKeyPress(Sender: TObject; var Key: Char);
begin
if (key = Chr(VK_RETURN)) or (key = Chr(VK_TAB)) or (key = Chr(VK_ESCAPE)) then
  key := #0;
end;

procedure TfmGlobalSearch.edSearchKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and bnSearch.Enabled then
    bnSearch.Click;
end;

procedure TfmGlobalSearch.EndHotFilterTimer;
begin
  tiFilter.Enabled := False;
  HotFilterString := edFilter.Text;
  hg.UpdateFilter;
  if pbFilter.Tag <> 0 then begin
    pbFilter.Tag := 0;
    pbFilter.Repaint;
  end;
end;

procedure TfmGlobalSearch.hgPopup(Sender: TObject);
begin
  //SaveSelected1.Visible := False;
  if hg.Selected <> -1 then begin
    if GetSearchItem(hg.Selected).Contact.Handle = 0 then begin
      SendMessage1.Visible := False;
      ReplyQuoted1.Visible := False;
    end;
    if hg.Items[hg.Selected].Bookmarked then
      Bookmark1.Caption := TranslateWideW('Remove &Bookmark')
    else
      Bookmark1.Caption := TranslateWideW('Set &Bookmark');
    pmGrid.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
  end;
end;

procedure TfmGlobalSearch.hgProcessRichText(Sender: TObject;
  Handle: Cardinal; Item: Integer);
var
  ItemRenderDetails: TItemRenderDetails;
begin
  ZeroMemory(@ItemRenderDetails,SizeOf(ItemRenderDetails));
  ItemRenderDetails.cbSize := SizeOf(ItemRenderDetails);
  ItemRenderDetails.hContact := GetSearchItem(Item).Contact.Handle;
  ItemRenderDetails.hDBEvent := GetSearchItem(Item).hDBEvent;
  ItemRenderDetails.pProto := Pointer(hg.Items[Item].Proto);
  ItemRenderDetails.pModule := Pointer(hg.Items[Item].Module);
  ItemRenderDetails.dwEventTime := hg.Items[Item].Time;
  ItemRenderDetails.wEventType := hg.Items[Item].EventType;
  ItemRenderDetails.IsEventSent := (mtOutgoing in hg.Items[Item].MessageType);

  if Handle = hg.InlineRichEdit.Handle then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_INLINE;
  if hg.IsSelected(Item) then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_SELECTED;

  ItemRenderDetails.bHistoryWindow := IRDHW_GLOBALSEARCH;

  PluginLink.NotifyEventHooks(hHppRichEditItemProcess,Handle,Integer(@ItemRenderDetails));
end;

procedure TfmGlobalSearch.hgTranslateTime(Sender: TObject; Time: Cardinal;  var Text: WideString);
begin
  Text := TimestampToString(Time);
end;

procedure TfmGlobalSearch.HookEvents;
begin
  hHookEventDeleted := PluginLink.HookEventMessage(ME_DB_EVENT_DELETED,Self.Handle,HM_SRCH_EVENTDELETED);
  hHookContactDeleted := PluginLink.HookEventMessage(ME_DB_CONTACT_DELETED,Self.Handle,HM_SRCH_CONTACTDELETED);
  hHookContactIconChanged :=PluginLink.HookEventMessage(ME_CLIST_CONTACTICONCHANGED,Self.Handle,HM_SRCH_CONTACTICONCHANGED);
  hHookEventPreShutdown :=PluginLink.HookEventMessage(ME_SYSTEM_PRESHUTDOWN,Self.Handle,HM_SRCH_PRESHUTDOWN);
  // use MagneticWindows.dll
  PluginLink.CallService(MS_MW_ADDWINDOW,WindowHandle,0);
end;

procedure TfmGlobalSearch.UnhookEvents;
begin
  PluginLink.UnhookEvent(hHookEventDeleted);
  PluginLink.UnhookEvent(hHookContactDeleted);
  PluginLink.UnhookEvent(hHookContactIconChanged);
  PluginLink.UnhookEvent(hHookEventPreShutdown);
  // use MagneticWindows.dll
  PluginLink.CallService(MS_MW_REMWINDOW,WindowHandle,0);
end;

procedure TfmGlobalSearch.WndProc(var Message: TMessage);
var
  res: Integer;
begin
  case Message.Msg of
    WM_COMMAND: begin
      res := PluginLink.CallService(MS_CLIST_MENUPROCESSCOMMAND,MAKEWPARAM(Message.WParamLo,MPCF_CONTACTMENU),UserMenuContact);
      if res = 0 then exit;
    end;
    WM_MEASUREITEM: begin
      Message.Result := PluginLink.CallService(MS_CLIST_MENUMEASUREITEM,Message.WParam,Message.LParam);
      exit;
    end;
    WM_DRAWITEM:
      if TWMDrawItem(Message).DrawItemStruct^.hwndItem = UserMenu then begin
		    Message.Result := PluginLink.CallService(MS_CLIST_MENUDRAWITEM,Message.WParam,Message.LParam);
        exit;
      end;
  end;
  inherited;
end;

procedure TfmGlobalSearch.FormShow(Sender: TObject);
var
  PassMode: Byte;
begin
  paFilter.Visible := False;
  ShowAdvancedPanel(False);
  ShowContacts(False);

  IsSearching := False;
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_GLOBALSEARCH].handle);

  hg.Codepage := hppCodepage;
  hg.RTLMode := hppRTLDefault;
  //hg.Options := GridOptions;

  hg.TxtStartup := TranslateWideW('Ready to search')+
    #10#13#10#13+TranslateWideW('Click Search button to start');

  PassMode := GetPassMode;
  cbPass.Enabled := (PassMode <> PASSMODE_PROTNONE);
  cbPass.Checked := (PassMode = PASSMODE_PROTALL) and (cbPass.Enabled);
  laPass.Enabled := cbPass.Checked and cbPass.Enabled;
  edPass.Enabled := cbPass.Checked and cbPass.Enabled;

  TranslateForm;
  LoadWindowPosition;

  HookEvents;

  edSearch.SetFocus;
  edSearch.SelectAll;

  bnSearch.Enabled := (edSearch.Text <> '');

  //ilFilterHandle := ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,4,1);
  //ImageList_AddIcon(ilFilterHandle,LoadIcon(hInstance,'historypp_hotfilter'));

  //FilterIcon := TIcon.Create;
  //FilterIcon.Handle := CopyIcon(hppicons[1].Handle);
  //ilFilter.AddIcon(FilterIcon);
  //ilFilter.ResInstLoad(hInstance,rtIcon,'historypp_search',0);
  //RaiseLastWin32Error;
  //ilFilter.GetIcon(0,imFilter.Picture.Icon);

  //imFilter.Picture.Icon.Handle := ImageList_GetIcon(ilFilterHandle,0,ILD_NORMAL);
end;

function TfmGlobalSearch.GetSearchItem(GridIndex: Integer): TSearchItem;
begin
  if not FFiltered then
    Result := History[GridIndex]
  else
    Result :=  History[FilterHistory[GridIndex]];
end;

procedure TfmGlobalSearch.HMContactDeleted(var M: TMessage);
begin
{wParam - hContact; lParam - zero}
// do here something because the contact is deleted
if IsSearching then exit;
end;

procedure TfmGlobalSearch.HMContactIconChanged(var M: TMessage);
var
  i: Integer;
begin
  {wParam - hContact; lParam - IconID}
  // contact icon has changed
  //meTest.Lines.Add(GetContactDisplayName(M.wParam)+' changed icon to '+IntToStr(m.LParam));
  if not paContacts.Visible then exit;
  for i := 0 to lvContacts.Items.Count - 1 do begin
    if Integer(m.wParam) = Integer(lvContacts.Items[i].Data) then begin
      lvContacts.Items[i].ImageIndex := Integer(m.lParam);
      break;
    end;
  end;

end;

procedure TfmGlobalSearch.HMEventDeleted(var M: TMessage);
var
  i: Integer;
begin
  {wParam - hContact; lParam - hDBEvent}
  if hg.State <> gsDelete then
    for i := 0 to hg.Count - 1 do begin
      if GetSearchItem(i).hDBEvent = M.lParam then begin
        hg.Delete(i);
        hgState(hg,hg.State);
        exit;
      end;
    end;
  // exit if we searched all
  if not FFiltered then exit;
  // if event is not in filter, we must search the overall array
  i := FindHistoryItemByHandle(m.LParam);
  if i <> -1 then DeleteEventFromLists(i);
end;

procedure TfmGlobalSearch.HMIcons2Changed(var M: TMessage);
begin
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_GLOBALSEARCH].handle);
  LoadButtonIcons;
  pbFilter.Repaint;
  LoadContactsIcons;
  hg.Repaint;
end;

procedure TfmGlobalSearch.HMBookmarksChanged(var M: TMessage);
var
  i: integer;
  found: boolean;
begin
  found := false;
  for i := 0 to hg.Count-1 do
    if GetSearchItem(i).hDBEvent = M.lParam then begin
      hg.ResetItem(i);
      found := true;
    end;
  if found then
    hg.Repaint;
end;

procedure TfmGlobalSearch.HMPreShutdown(var M: TMessage);
begin
  Close;
end;

procedure TfmGlobalSearch.hgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  WasReturnPressed := (Key = VK_RETURN);
end;

procedure TfmGlobalSearch.hgKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not WasReturnPressed then exit;

  if (Key = VK_RETURN) and (Shift = []) then begin
    if hg.Selected <> -1 then
      hg.EditInline(hg.Selected);
    end;
  if (Key = VK_RETURN) and (Shift = [ssCtrl]) then begin
    hgDblClick(hg);
    end;
end;

procedure TfmGlobalSearch.hgNameData(Sender: TObject; Index: Integer; var Name: WideString);
var
  si: TSearchItem;
begin
 si := GetSearchItem(Index);
 if FFiltered then begin
   if mtIncoming in hg.Items[Index].MessageType then
     Name := si.Contact.Name
   else
     Name := si.Contact.ProfileName;
 end else begin
   if mtIncoming in hg.Items[Index].MessageType then
     Name := WideFormat(TranslateWideW('From %s'),[si.Contact.Name])
   else
     Name := WideFormat(TranslateWideW('To %s'),[si.Contact.Name]);
 end;
end;

procedure TfmGlobalSearch.hgUrlClick(Sender: TObject; Item: Integer; Url: String);
var
  bNewWindow: Integer;
begin
  if Url = '' then exit;
  bNewWindow := 1; // yes, use existing
  PluginLink.CallService(MS_UTILS_OPENURL,bNewWindow,Integer(Pointer(@Url[1])));
end;

procedure TfmGlobalSearch.edPassKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = Chr(VK_RETURN)) or (key = Chr(VK_TAB)) or (key = Chr(VK_ESCAPE)) then
    key := #0;
end;

procedure TfmGlobalSearch.edPassKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    bnSearch.Click;
    Key := 0;
  end;
end;

procedure TfmGlobalSearch.ShowAdvancedPanel(Show: Boolean);
begin
  if Show then begin
    if not gbAdvanced.Visible then
      paSearch.Height := paSearch.Height + gbAdvanced.Height + 8;
    gbAdvanced.Show;
    end
  else begin
    if gbAdvanced.Visible then
      paSearch.Height := paSearch.Height - gbAdvanced.Height - 8;
    gbAdvanced.Hide;
    end;
  if gbAdvanced.Visible then
    bnAdvanced.Caption := TranslateWideW('Advanced <<')
  else
    bnAdvanced.Caption := TranslateWideW('Advanced >>');
end;


procedure TfmGlobalSearch.ShowContacts(Show: Boolean);
begin
  paContacts.Visible := Show;
  spContacts.Visible := Show;
  if (Show) and (paContacts.Width > 0) then
    spContacts.LEft := paContacts.Width + paContacts.Left + 1;
end;

procedure TfmGlobalSearch.bnAdvancedClick(Sender: TObject);
begin
  ShowAdvancedPanel(not gbAdvanced.Visible);
end;

procedure TfmGlobalSearch.SearchNext(Rev: Boolean; Warp: Boolean = True);
var
  stext: WideString;
  res: Integer;
  mcase,down: Boolean;
  WndHandle: HWND;
begin
  stext := HotString;
  mcase := False;
  if stext = '' then exit;
  down := not hg.reversed;
  if Rev then Down := not Down;
  res := hg.Search(stext, mcase, not Warp, False, Warp, Down);
  if res <> -1 then begin
    // found
    hg.Selected := res;
    sb.SimpleText := WideFormat(TranslateWideW('HotSearch: %s (F3 to find next)'),[stext]);
  end else begin
    WndHandle := Handle;
    // not found
    if Warp and (down = not hg.Reversed) then begin
      // do warp?
      if hppMessageBox(WndHandle,TranslateWideW('You have reached the end of the history.')+
        #10#13+TranslateWideW('Do you want to continue searching at the beginning?'),
        TranslateWideW('History++ Search'),
        MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = ID_YES then
          SearchNext(Rev,False);
    end else begin
      // not warped
      hgState(Self,gsIdle);
      hppMessageBox(WndHandle,WideFormat('"%s" not found',[stext]),
        TranslateWideW('History++ Search'),MB_OK or MB_DEFBUTTON1 or 0);
    end;
  end;
end;

procedure TfmGlobalSearch.SendMessage1Click(Sender: TObject);
begin
  if hg.Selected <> -1 then begin
    if GetSearchItem(hg.Selected).Contact.Handle = 0 then exit;
    SendMessageTo(GetSearchItem(hg.Selected).Contact.Handle);
  end;
end;

procedure TfmGlobalSearch.SetRecentEventsPosition(OnTop: Boolean);
begin
  hg.Reversed := not OnTop;
end;

procedure TfmGlobalSearch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Mask: Integer;
begin
  if (key = VK_F3) and ((Shift=[]) or (Shift=[ssShift])) and (Length(History) > 0) then begin
    SearchNext(ssShift in Shift,True);
    key := 0;
    end;

  if (Key = VK_ESCAPE) then begin
    if IsSearching then begin
      StopSearching;
      exit;
    end else
      close;
  end;

  if hg.State = gsInline then begin
    exit;
    end;

  if (ssCtrl in Shift) then begin
    if (key=Ord('R')) then begin
      if hg.Selected <> -1 then ReplyQuoted(hg.Selected);
      key:=0;
    end;
    if (key=Ord('M')) then begin
      if hg.Selected <> -1 then SendMessage1.Click;
      key:=0;
    end;
    if key=VK_RETURN then begin
      if hg.Selected <> -1 then hgDblClick(Sender);
      key:=0;
    end;
  end;

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

procedure TfmGlobalSearch.hgSearchFinished(Sender: TObject; Text: WideString;
  Found: Boolean);
var
  t: WideString;
begin
  if Text = '' then begin
    HotString := Text;
    hgState(Self,gsIdle);
    exit;
  end;
  HotString := Text;

  if not Found then t := HotString
               else t := Text;
  sb.SimpleText := WideFormat(TranslateWideW('HotSearch: %s (F3 to find next)'),[t]);
end;

procedure TfmGlobalSearch.hgSearchItem(Sender: TObject; Item, ID: Integer;
  var Found: Boolean);
begin
  Found := (ID = GetSearchItem(Item).hDBEvent);
end;

procedure TfmGlobalSearch.hgSelect(Sender: TObject; Item, OldItem: Integer);
{var
  i,hCont,Index: Integer;}
begin
if hg.HotString = '' then begin
  hgState(hg,gsIdle);
  end;

  {  if Item = -1 then exit;
  index := -1;
  hCont := History[Item].hContact;
  for i := 0 to lvContacts.Items.Count-1 do
    if integer(lvContacts.Items.Item[i].Data) = hCont then begin
      Index := i;
      break;
    end;
  if Index = -1 then exit;
  lvContacts.OnSelectItem := nil;
  lvContacts.Items.Item[index].MakeVisible(false);
  lvContacts.Items.Item[index].Selected := true;
  lvContacts.OnSelectItem := self.lvContactsSelectItem;}
end;

procedure TfmGlobalSearch.hgState(Sender: TObject; State: TGridState);
var
  t: WideString;
begin
  if csDestroying in ComponentState then
    exit;

  case State of
    // if change, change also in SMFinished:
    gsIdle:   t := WideFormat(TranslateWideW('%.0n items in %d contacts found. Searched for %.1f sec in %.0n items.'),[Length(History)/1, ContactsFound, stime/1000, AllItems/1]);
    gsLoad:   t := TranslateWideW('Loading...');
    gsSave:   t := TranslateWideW('Saving...');
    gsSearch: t := TranslateWideW('Searching...');
    gsDelete: t := TranslateWideW('Deleting...');
  end;
  if IsSearching then
    // if change, change also in SMProgress
    sb.SimpleText := WideFormat(TranslateWideW('Searching... %.0n items in %d contacts found'),[Length(History)/1, ContactsFound])
  else
    sb.SimpleText := t;
end;

procedure TfmGlobalSearch.Copy1Click(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  CopyToClip(hg.FormatSelected(hg.Options.ClipCopyFormat),Handle,GetSearchItem(hg.Selected).Contact.Codepage);
end;

procedure TfmGlobalSearch.CopyText1Click(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  CopyToClip(hg.FormatSelected(hg.Options.ClipCopyTextFormat),Handle,GetSearchItem(hg.Selected).Contact.Codepage);
end;

procedure TfmGlobalSearch.Delete1Click(Sender: TObject);
begin
  if hg.SelCount = 0 then exit;
  if hg.SelCount > 1 then begin
    if HppMessageBox(Handle,
      WideFormat(TranslateWideW('Do you really want to delete selected items (%.0f)?'),
      [hg.SelCount/1]), TranslateWideW('Delete Selected'),
      MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = IDNO then exit;
  end else begin
    if HppMessageBox(Handle, TranslateWideW('Do you really want to delete selected item?'),
    TranslateWideW('Delete'), MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = IDNO then exit;
  end;
  SetSafetyMode(False);
  try
    FormState := gsDelete;
    hg.DeleteSelected;
    FormState := gsIdle;
  finally
    SetSafetyMode(True);
  end;
end;

procedure TfmGlobalSearch.hgRTLEnabled(Sender: TObject; Enabled: Boolean);
var
  Flag: TBiDiMode;
begin
  if Enabled then Flag := bdRightToLeft
             else Flag := bdLeftToRight;
  edPass.BiDiMode := Flag;
  edSearch.BiDiMode := Flag;
  edFilter.BiDiMode := Flag;
  //lvContacts.BiDiMode := Flag;
  hg.BiDiMode := Flag;
end;

procedure TfmGlobalSearch.Bookmark1Click(Sender: TObject);
var
  val: boolean;
  hDBEvent: THandle;
begin
  hDBEvent := GetSearchItem(hg.Selected).hDBEvent;
  val := not BookmarkServer[GetSearchItem(hg.Selected).Contact.Handle].Bookmarked[hDBEvent];
  BookmarkServer[GetSearchItem(hg.Selected).Contact.Handle].Bookmarked[hDBEvent] := val;
  //NotifyAllForms(HM_NOTF_BOOKMARKCHANGED,GetSearchItem(hg.Selected).Contact.Handle,hDBEvent);
end;

initialization
  fmGlobalSearch := nil;

end.
