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
  TntForms, TntComCtrls, TntExtCtrls, TntStdCtrls, TntSysUtils, TntGraphics, TntWindows,
  HistoryGrid,
  m_globaldefs, m_api,
  hpp_global, hpp_events, hpp_services, hpp_contacts,  hpp_database,  hpp_searchthread,
  hpp_eventfilters, hpp_bookmarks, hpp_richedit, RichEdit,
  ImgList, PasswordEditControl, Buttons, TntButtons, Math, CommCtrl,
  Contnrs, TntMenus, hpp_forms, ToolWin;

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
    paClient: TTntPanel;
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
    spContacts: TTntSplitter;
    paPassword: TtntPanel;
    edPass: TPasswordEdit;
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
    ToolBar: TTntToolBar;
    tbPassword: TTntToolButton;
    paAdvanced: TTntPanel;
    paRange: TTntPanel;
    rbAny: TTntRadioButton;
    rbAll: TTntRadioButton;
    rbExact: TTntRadioButton;
    laAdvancedHead: TTntLabel;
    sbAdvancedClose: TTntSpeedButton;
    sbRangeClose: TTntSpeedButton;
    sbPasswordClose: TTntSpeedButton;
    dtRange1: TTntDateTimePicker;
    laRange1: TTntLabel;
    laRange2: TTntLabel;
    dtRange2: TTntDateTimePicker;
    laPasswordHead: TTntLabel;
    laRangeHead: TTntLabel;
    tbEventsFilter: TTntSpeedButton;
    tbAdvanced: TTntToolButton;
    tbRange: TTntToolButton;
    TntToolButton3: TTntToolButton;
    ilToolbar: TImageList;
    bePassword: TTntBevel;
    beRange: TTntBevel;
    beAdvanced: TTntBevel;
    TntToolButton4: TTntToolButton;
    tbSearch: TTntToolButton;
    tbFilter: TTntToolButton;
    laPassNote: TTntLabel;
    pmEventsFilter: TTntPopupMenu;
    N4: TTntMenuItem;
    Customize1: TTntMenuItem;
    pmInline: TTntPopupMenu;
    InlineCopy: TTntMenuItem;
    InlineCopyAll: TTntMenuItem;
    InlineSelectAll: TTntMenuItem;
    TntMenuItem10: TTntMenuItem;
    InlineTextFormatting: TTntMenuItem;
    TntMenuItem6: TTntMenuItem;
    InlineSendMessage: TTntMenuItem;
    InlineReplyQuoted: TTntMenuItem;
    pmLink: TTntPopupMenu;
    OpenLink: TTntMenuItem;
    OpenLinkNW: TTntMenuItem;
    TntMenuItem2: TTntMenuItem;
    CopyLink: TTntMenuItem;
    mmAcc: TTntMainMenu;
    mmToolbar: TTntMenuItem;
    mmService: TTntMenuItem;
    mmHideMenu: TTntMenuItem;
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
    procedure edFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure hgSelect(Sender: TObject; Item, OldItem: Integer);
    procedure Copy1Click(Sender: TObject);
    procedure CopyText1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure hgRTLEnabled(Sender: TObject; BiDiMode: TBiDiMode);
    procedure Bookmark1Click(Sender: TObject);
    procedure hgBookmarkClick(Sender: TObject; Item: Integer);
    procedure lvContactsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure tbAdvancedClick(Sender: TObject);
    procedure tbRangeClick(Sender: TObject);
    procedure tbPasswordClick(Sender: TObject);
    procedure sbAdvancedCloseClick(Sender: TObject);
    procedure sbRangeCloseClick(Sender: TObject);
    procedure sbPasswordCloseClick(Sender: TObject);
    procedure tbEventsFilterClick(Sender: TObject);
    procedure EventsFilterItemClick(Sender: TObject);
    procedure Customize1Click(Sender: TObject);
    procedure InlineCopyClick(Sender: TObject);
    procedure hgInlinePopup(Sender: TObject);
    procedure hgInlineKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure InlineCopyAllClick(Sender: TObject);
    procedure InlineSelectAllClick(Sender: TObject);
    procedure InlineTextFormattingClick(Sender: TObject);
    procedure InlineReplyQuotedClick(Sender: TObject);
    procedure hgUrlPopup(Sender: TObject; Item: Integer; Url: String);
    procedure CopyLinkClick(Sender: TObject);
    procedure OpenLinkClick(Sender: TObject);
    procedure OpenLinkNWClick(Sender: TObject);
    procedure mmHideMenuClick(Sender: TObject);
    procedure mmToolbarClick(Sender: TObject);
    procedure pmEventsFilterPopup(Sender: TObject);
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
    SavedLinkUrl: String;

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
    procedure HMFiltersChanged(var M: TMessage); message HM_NOTF_FILTERSCHANGED;
    procedure HMAccChanged(var M: TMessage); message HM_NOTF_ACCCHANGED;
    procedure TranslateForm;

    procedure HookEvents;
    procedure UnhookEvents;

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
    procedure LoadPosition;
    procedure SavePosition;
    procedure WndProc(var Message: TMessage); override;

    procedure ToggleAdvancedPanel(Show: Boolean);
    procedure ToggleRangePanel(Show: Boolean);
    procedure TogglePasswordPanel(Show: Boolean);
    procedure OrganizePanels;
    procedure ToggleMainMenu(Enabled: Boolean);

    procedure SetEventFilter(FilterIndex: Integer = -1);
    procedure CreateEventsFilterMenu;
  public
    CustomizeFiltersForm: TForm;
    procedure SetRecentEventsPosition(OnTop: Boolean);
  published
    // fix for splitter baug:
    procedure AlignControls(Control: TControl; var ARect: TRect); override;

    function GetSearchItem(GridIndex: Integer): TSearchItem;
    procedure DisableFilter;
    procedure FilterOnContact(hContact: Integer);

    procedure LoadButtonIcons;
    procedure LoadContactsIcons;
    procedure LoadToolbarIcons;

    procedure LoadAccMenu;
    procedure LoadEventFilterButton;
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
  HistoryForm, CustomizeFiltersForm;

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
  // delphi 2006 doesn't save toolbar's flat property in dfm if it is True
  Toolbar.Flat := True;
  LoadToolbarIcons;
  LoadButtonIcons;
  LoadContactsIcons;

  TranslateForm;
  LoadAccMenu; // load accessability menu before LoadToolbar
               // put here because we want to translate everything
               // before copying to menu
  ToggleMainMenu(GetDBBool(hppDBName,'Accessability', False));
end;

procedure TfmGlobalSearch.SMFinished(var M: TMessage);
var
  sbt: WideString;
begin
  stime := GetTickCount - st.SearchStart;
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

  tbEventsFilter.Enabled := True;
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

  //hg.Filter := GenerateEvents(FM_EXCLUDE,[]);
  hg.Selected := -1;
  hg.Allocate(0);

  SetLength(FilterHistory,0);
  SetLength(History,0);

  IsSearching := True;
  bnSearch.Caption := TranslateWideW('Stop');

  tbEventsFilter.Enabled := False;
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

procedure TfmGlobalSearch.tbAdvancedClick(Sender: TObject);
begin
  // when called from menu item handler
  if Sender <> tbAdvanced then
    tbAdvanced.Down := not tbAdvanced.Down;
  ToggleAdvancedPanel(tbAdvanced.Down);
end;

procedure TfmGlobalSearch.tbEventsFilterClick(Sender: TObject);
var
  p: TPoint;
begin
  p := tbEventsFilter.ClientOrigin;
  tbEventsFilter.ClientToScreen(p);
  Application.CancelHint;
  tbEventsFilter.ShowHint := false;
  pmEventsFilter.Popup(p.X,p.Y+tbEventsFilter.Height);
  tbEventsFilter.ShowHint := true;
end;

procedure TfmGlobalSearch.tbPasswordClick(Sender: TObject);
begin
  if Sender <> tbRange then
    tbPassword.Down := not tbPassword.Down;
  TogglePasswordPanel(tbPassword.Down);
end;

procedure TfmGlobalSearch.tbRangeClick(Sender: TObject);
begin
  if Sender <> tbRange then
    tbRange.Down := not tbRange.Down;
  ToggleRangePanel(tbRange.Down);
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
  if Key in [VK_UP,VK_DOWN,VK_NEXT,VK_PRIOR] then begin
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
  if Assigned(CustomizeFiltersForm) then
    CustomizeFiltersForm.Release;
  ContactList.Free;
end;

procedure TfmGlobalSearch.TntFormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  Ctrl: TControl;
begin
  Handled := True;
  Ctrl := paClient.ControlAtPos(paClient.ScreenToClient(MousePos),False,True);
  {$RANGECHECKS OFF}
  if Assigned(Ctrl) then begin
    if Ctrl.Name = 'paContacts' then begin
      Handled := not TTntListView(Ctrl).Focused;
      if Handled then begin
        // ??? what to do here?
        // how to tell listview to scroll?
      end;
    end
    else begin
      hg.Perform(WM_MOUSEWHEEL,MakeLong(MK_CONTROL,WheelDelta),0);
    end;
  end;
  {$RANGECHECKS ON}
end;

procedure TfmGlobalSearch.ToggleAdvancedPanel(Show: Boolean);
var
  Lock: Boolean;
begin
  if Visible then Lock := LockWindowUpdate(Handle);
  try
    tbAdvanced.Down := Show;
    paAdvanced.Visible := Show;
    OrganizePanels;
  finally
    if Visible and Lock then LockWindowUpdate(0);
  end;
end;

procedure TfmGlobalSearch.TogglePasswordPanel(Show: Boolean);
var
  Lock: Boolean;
begin
  if Visible then Lock := LockWindowUpdate(Handle);
  try
    if GetPassMode = PASSMODE_PROTALL then Show := True;
    tbPassword.Down := Show;
    paPassword.Visible := Show;
    laPassNote.Caption := '';
    OrganizePanels;
  finally
    if Visible and Lock then LockWindowUpdate(0);
  end;
end;

procedure TfmGlobalSearch.ToggleRangePanel(Show: Boolean);
var
  Lock: Boolean;
begin
  if Visible then Lock := LockWindowUpdate(Handle);
  try
    tbRange.Down := Show;
    paRange.Visible := Show;
    edSearchChange(Self);
    OrganizePanels;
  finally
    if Visible and Lock then LockWindowUpdate(0);
  end;
end;

procedure TfmGlobalSearch.mmToolbarClick(Sender: TObject);
var
  i,n: Integer;
  pm: TTntPopupMenu;
  mi: TTntMenuItem;
begin
  for i := 0 to mmToolbar.Count - 1 do begin
    if mmToolbar.Items[i].Tag = 0 then continue;
    pm := TTntPopupMenu(Pointer(mmToolbar.Items[i].Tag));
    for n := pm.Items.Count-1 downto 0 do begin
      mi := TTntMenuItem(pm.Items[n]);
      pm.Items.Remove(mi);
      mmToolbar.Items[i].Insert(0,mi);
    end;
  end;
end;

procedure TfmGlobalSearch.sbAdvancedCloseClick(Sender: TObject);
begin
  ToggleAdvancedPanel(False);
end;

procedure TfmGlobalSearch.sbClearFilterClick(Sender: TObject);
begin
  edFilter.Text := '';
  EndHotFilterTimer;
  hg.SetFocus;
end;

procedure TfmGlobalSearch.sbPasswordCloseClick(Sender: TObject);
begin
  TogglePasswordPanel(False);
end;

procedure TfmGlobalSearch.sbRangeCloseClick(Sender: TObject);
begin
  ToggleRangePanel(False);
end;

procedure TfmGlobalSearch.TranslateForm;
begin
  Caption := TranslateWideW(Caption);

  laSearch.Caption := TranslateWideW(laSearch.Caption);
  bnSearch.Caption := TranslateWideW(bnSearch.Caption);
  laAdvancedHead.Caption := TranslateWideW(laAdvancedHead.Caption);
  rbAny.Caption := TranslateWideW(rbAny.Caption);
  rbAll.Caption := TranslateWideW(rbAll.Caption);
  rbExact.Caption := TranslateWideW(rbExact.Caption);

  laRangeHead.Caption := TranslateWideW(laRangeHead.Caption);
  laRange1.Caption := TranslateWideW(laRange1.Caption);
  laRange2.Caption := TranslateWideW(laRange2.Caption);

  laPasswordHead.Caption := TranslateWideW(laPasswordHead.Caption);
  laPass.Caption := TranslateWideW(laPass.Caption);
  sbClearFilter.Hint := TranslateWideW(sbClearFilter.Hint);

  SaveDialog.Title := Translate(PAnsiChar(SaveDialog.Title));

  TranslateToolbar(Toolbar);

  TranslateMenu(pmGrid.Items);
  TranslateMenu(pmInline.Items);
  TranslateMenu(pmLink.Items);
  TranslateMenu(pmEventsFilter.Items);

  hg.TxtFullLog := TranslateWideW(hg.txtFullLog);
  hg.TxtGenHist1 := TranslateWideW(hg.txtGenHist1);
  hg.TxtGenHist2 := TranslateWideW(hg.txtGenHist2);
  hg.TxtHistExport := TranslateWideW(hg.TxtHistExport);
  hg.TxtNoItems := TranslateWideW(hg.TxtNoItems);
  hg.TxtNoSuch := TranslateWideW(hg.TxtNoSuch);
  hg.TxtPartLog := TranslateWideW(hg.TxtPartLog);
  hg.TxtStartUp := TranslateWideW(hg.TxtStartUp);

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
    SavePosition;
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
var
  SearchProtected: Boolean;
  PassMode: Byte;
begin
  if IsSearching then begin
    StopSearching;
    exit;
  end;
  //if edSearch.Text = '' then
  //  raise Exception.Create('Enter text to search');

  SearchProtected := False;
  if paPassword.Visible then begin
    PassMode := GetPassMode;
    if PassMode = PASSMODE_PROTNONE then
      laPassNote.Caption := TranslateWideW('History is not protected, searching all contacts')
    else begin
      if (PassMode <> PASSMODE_PROTALL) and (edPass.Text = '') then
        laPassNote.Caption := TranslateWideW('Searching unprotected contacts only')
      else begin
        if CheckPassword(edPass.Text) then begin
          SearchProtected := True;
          laPassNote.Caption := 'Searching all contacts';
        end
        else begin
          HppMessageBox(Handle,TranslateWideW('You have entered the wrong password.'),
            TranslateWideW('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
          edPass.SetFocus;
          edPass.SelectAll;
          laPassNote.Caption := 'Wrong password';
          exit;
        end;
      end;
    end;
  end;

  st := TSearchThread.Create(True);

  if edSearch.text = '' then
    st.SearchMethod := smNoText
  else if rbAny.Checked then
    st.SearchMethod := smAnyWord
  else if rbAll.Checked then
    st.SearchMethod := smAllWords
  else
    st.SearchMethod := smExact;

  st.SearchRange := paRange.Visible;
  if st.SearchRange then begin
    st.SearchRangeFrom := dtRange1.Date;
    st.SearchRangeTo := dtRange2.Date;
  end;
  st.Priority := tpLower;
  st.ParentHandle := Self.Handle;
  st.SearchText := edSearch.text;
  st.SearchProtectedContacts := SearchProtected;
  st.Resume;
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

procedure TfmGlobalSearch.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Flag: UINT;
  AppSysMenu: THandle;
begin
  CanClose := (hg.State in [gsIdle,gsInline]);
  if CanClose and IsSearching then begin
    // disable close button
    AppSysMenu:=GetSystemMenu(Handle,False);
    Flag:=MF_GRAYED;
    EnableMenuItem(AppSysMenu,SC_CLOSE,MF_BYCOMMAND or Flag);
    laProgress.Caption := TranslateWideW('Please wait while closing the window...');
    laProgress.Font.Style := [fsBold];
    pb.Visible := False;
    st.Terminate;
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
  bnSearch.Enabled := (edSearch.Text <> '') or paRange.Visible;
end;

procedure TfmGlobalSearch.edSearchEnter(Sender: TObject);
begin
  //edSearch.SelectAll;
end;

procedure TfmGlobalSearch.LoadAccMenu;
var
  i: Integer;
  wstr: WideString;
  menuitem: TTntMenuItem;
  pm: TTntPopupMenu;
begin
  mmToolbar.Clear;
  for i := Toolbar.ButtonCount - 1 downto 0 do begin
    if Toolbar.Buttons[i].Style = tbsSeparator then begin
      menuitem := TTntMenuItem.Create(mmToolbar);
      menuitem.Caption := '-';
      mmToolbar.Insert(0,menuitem);
    end else begin
      wstr := Toolbar.Buttons[i].Caption;
      if wstr = '' then wstr := Toolbar.Buttons[i].Hint;
      if wstr <> '' then begin
        menuitem := TTntMenuItem.Create(mmToolbar);
        pm := TTntPopupMenu(Toolbar.Buttons[i].PopupMenu);
        if pm = nil then
          menuitem.OnClick := Toolbar.Buttons[i].OnClick
        else begin
          menuitem.Tag := Integer(Pointer(pm));
        end;
        menuitem.Caption := wstr;
        menuitem.ShortCut := WideTextToShortCut(Toolbar.Buttons[i].HelpKeyword);
        menuitem.Visible := Toolbar.Buttons[i].Visible;
        //menuitem.Enabled := Toolbar.Buttons[i].Enabled;
        mmToolbar.Insert(0,menuitem);
      end;
    end;
  end;
  mmToolbar.RethinkHotkeys;
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

procedure TfmGlobalSearch.LoadEventFilterButton;
var
  pad: DWord;
  PadH, PadV, GlyphHeight: Integer;
  sz: TSize;
  FirstName, Name: WideString;
  PaintRect: TRect;
  DrawTextFlags: Cardinal;
  GlyphWidth: Integer;
begin
  FirstName := hppEventFilters[0].Name;
  Name := hppEventFilters[tbEventsFilter.Tag].Name;
  tbEventsFilter.Hint := Name; // show hint because the whole name may not fit in button

  pad := SendMessage(Toolbar.Handle,TB_GETPADDING,0,0);
  PadV := HiWord(pad);
  PadH := LoWord(pad);

  tbEventsFilter.Glyph.Canvas.Font := tbEventsFilter.Font;
  sz := WideCanvasTextExtent(tbEventsFilter.Glyph.Canvas,FirstName);
  GlyphHeight := Max(sz.cy,16);
  GlyphWidth := 16+sz.cx+tbEventsFilter.Spacing;

  tbEventsFilter.Glyph.Height := GlyphHeight;
  tbEventsFilter.Glyph.Width := GlyphWidth*2;
  tbEventsFilter.Glyph.Canvas.Brush.Color := Toolbar.Color;
  tbEventsFilter.Glyph.Canvas.FillRect(tbEventsFilter.Glyph.Canvas.ClipRect);
  DrawIconEx(tbEventsFilter.Glyph.Canvas.Handle,sz.cx+tbEventsFilter.Spacing,((GlyphHeight-16) div 2),
             hppIcons[HPP_ICON_TOOL_EVENTSFILTER].Handle,16,16,0,tbEventsFilter.Glyph.Canvas.Brush.Handle,DI_NORMAL);
  DrawState(tbEventsFilter.Glyph.Canvas.Handle,0,nil,Integer(hppIcons[HPP_ICON_TOOL_EVENTSFILTER].Handle),
            0,sz.cx+tbEventsFilter.Spacing+GlyphWidth,((GlyphHeight-16) div 2),0,0,DST_ICON or DSS_DISABLED);
  PaintRect := Rect(0,((GlyphHeight-sz.cy) div 2),GlyphWidth-16-tbEventsFilter.Spacing,tbEventsFilter.Glyph.Height);
  DrawTextFlags := DT_END_ELLIPSIS or DT_NOPREFIX or DT_CENTER;
  tbEventsFilter.Glyph.Canvas.Font.Color := clWindowText;
  Tnt_DrawTextW(tbEventsFilter.Glyph.Canvas.Handle,@Name[1],Length(Name),PaintRect,DrawTextFlags);
  OffsetRect(PaintRect,GlyphWidth,0);
  tbEventsFilter.Glyph.Canvas.Font.Color := clGrayText;
  Tnt_DrawTextW(tbEventsFilter.Glyph.Canvas.Handle,@Name[1],Length(Name),PaintRect,DrawTextFlags);
  tbEventsFilter.Width := GlyphWidth+2*PadH;
  tbEventsFilter.NumGlyphs := 2;
end;

procedure TfmGlobalSearch.LoadPosition;
var
  n: Integer;
begin
  //if Utils_RestoreWindowPosition(Self.Handle,0,0,hppDBName,'GlobalSearchWindow.') <> 0 then begin
  //  Self.Left := (Screen.Width-Self.Width) div 2;
  //  Self.Top := (Screen.Height - Self.Height) div 2;
  //end;
  Utils_RestoreFormPosition(Self,0,hppDBName,'GlobalSearchWindow.');
  // use MagneticWindows.dll
  PluginLink.CallService(MS_MW_ADDWINDOW,WindowHandle,0);
  // if we are password-protected (cbPass.Enabled) and
  // have PROTSEL (not (cbPass.Checked)) then load
  // checkbox from DB
  if not paPassword.Visible then
    TogglePasswordPanel(GetDBBool(hppDBName,'GlobalSearchWindow.PassChecked',False));

  n := GetDBInt(hppDBName,'GlobalSearchWindow.ContactListWidth',-1);
  if n <> -1 then begin
    paContacts.Width := n;
  end;
  spContacts.Left := paContacts.Left + paContacts.Width + 1;
  edFilter.Width := paFilter.Width - edFilter.Left - 2;

  SetRecentEventsPosition(GetDBInt(hppDBName,'SortOrder',0) <> 0);

  ToggleAdvancedPanel(GetDBBool(hppDBName,'GlobalSearchWindow.ShowAdvanced',False));
  case GetDBInt(hppDBName,'GlobalSearchWindow.AdvancedOptions',0) of
    0: rbAny.Checked := True;
    1: rbAll.Checked := True;
    2: rbExact.Checked := True
  else
    rbAny.Checked := True;
  end;

  ToggleRangePanel(GetDBBool(hppDBName,'GlobalSearchWindow.ShowRange',False));
  dtRange1.Date := Trunc(GetDBDateTime(hppDBName,'GlobalSearchWindow.RangeFrom',Now));
  dtRange2.Date := Trunc(GetDBDateTime(hppDBName,'GlobalSearchWindow.RangeTo',Now));
  edSearch.Text := AnsiToWideString(GetDBStr(hppDBName,'GlobalSearchWindow.LastSearch',DEFAULT_SEARCH_TEXT),hppCodepage);
end;

procedure TfmGlobalSearch.LoadToolbarIcons;
var
  il: HIMAGELIST;
  ii: Integer;
begin
  ImageList_Remove(ilToolbar.Handle,-1); // clears image list
  il := ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,10,2);
  if il <> 0 then
    ilToolbar.Handle := il
  else
    il := ilToolbar.Handle;
  Toolbar.Images := ilToolbar;

  ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_SEARCHADVANCED].Handle);
  tbAdvanced.ImageIndex := ii;
  ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_SEARCHRANGE].Handle);
  tbRange.ImageIndex := ii;
  ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_SEARCHPROTECTED].Handle);
  tbPassword.ImageIndex := ii;

  ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_HOTFILTER].Handle);
  tbFilter.ImageIndex := ii;
  ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_HOTSEARCH].Handle);
  tbSearch.ImageIndex := ii;

  LoadEventFilterButton;
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

procedure TfmGlobalSearch.OrganizePanels;
var
  PrevPanel: TTntPanel;
begin
  PrevPanel := paSearch;
  if paAdvanced.Visible then begin
    paAdvanced.Top := PrevPanel.Top+PrevPanel.Width;
    PrevPanel := paAdvanced;
  end;
  if paRange.Visible then begin
    paRange.Top := PrevPanel.Top+PrevPanel.Width;
    PrevPanel := paRange;
  end;
  if paPassword.Visible then begin
    paPassword.Top := PrevPanel.Top+PrevPanel.Width;
    PrevPanel := paPassword;
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

procedure TfmGlobalSearch.pmEventsFilterPopup(Sender: TObject);
var
  i: Integer;
  pmi,mi: TTntMenuItem;
begin
  if Customize1.Parent <> pmEventsFilter.Items then begin
    pmi := TTntMenuItem(Customize1.Parent);
    for i := pmi.Count - 1 downto 0 do begin
      mi := TTntMenuItem(pmi.Items[i]);
      pmi.Remove(mi);
      pmEventsFilter.Items.Insert(0,mi);
    end;
  end;
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

procedure TfmGlobalSearch.SavePosition;
var
  LastSearch: WideString;
begin
  //Utils_SaveWindowPosition(Self.Handle,0,'HistoryPlusPlus','GlobalSearchWindow.');
  Utils_SaveFormPosition(Self,0,hppDBName,'GlobalSearchWindow.');
  // use MagneticWindows.dll
  PluginLink.CallService(MS_MW_REMWINDOW,WindowHandle,0);
  // if we are password-protected (cbPass.Enabled) and
  // have PROTSEL (GetPassMode = PASSMODE_PROTSEL) then save
  // checkbox to DB
  WriteDBBool(hppDBName,'GlobalSearchWindow.PassChecked',paPassword.Visible);

  WriteDBInt(hppDBName,'GlobalSearchWindow.ContactListWidth',paContacts.Width);

  WriteDBBool(hppDBName,'GlobalSearchWindow.ShowAdvanced',paAdvanced.Visible);
  if rbAny.Checked then
    WriteDBInt(hppDBName,'GlobalSearchWindow.AdvancedOptions',0)
  else if rbAll.Checked then
    WriteDBInt(hppDBName,'GlobalSearchWindow.AdvancedOptions',1)
  else
    WriteDBInt(hppDBName,'GlobalSearchWindow.AdvancedOptions',2);

  WriteDBBool(hppDBName,'GlobalSearchWindow.ShowRange',paRange.Visible);
  if Trunc(dtRange1.Date) <> Trunc(Now) then
    WriteDBDateTime(hppDBName,'GlobalSearchWindow.RangeFrom',Trunc(dtRange1.Date));
  if Trunc(dtRange2.Date) <> Trunc(Now) then
    WriteDBDateTime(hppDBName,'GlobalSearchWindow.RangeTo',Trunc(dtRange2.Date));

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

procedure TfmGlobalSearch.EventsFilterItemClick(Sender: TObject);
begin
  SetEventFilter(TTntMenuItem(Sender).Tag);
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
  ItemRenderDetails.pProto := PChar(hg.Items[Item].Proto);
  ItemRenderDetails.pModule := PChar(hg.Items[Item].Module);
  ItemRenderDetails.pText := nil;
  ItemRenderDetails.pExtended := PChar(hg.Items[Item].Extended);
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
end;

procedure TfmGlobalSearch.UnhookEvents;
begin
  PluginLink.UnhookEvent(hHookEventDeleted);
  PluginLink.UnhookEvent(hHookContactDeleted);
  PluginLink.UnhookEvent(hHookContactIconChanged);
  PluginLink.UnhookEvent(hHookEventPreShutdown);
end;

procedure TfmGlobalSearch.WndProc(var Message: TMessage);
var
  res: Integer;
begin
  case Message.Msg of
    WM_COMMAND: begin
      if mmAcc.DispatchCommand(Message.WParam) then exit;
      if PluginLink.CallService(MS_CLIST_MENUPROCESSCOMMAND,
        MAKEWPARAM(Message.WParamLo,MPCF_CONTACTMENU),UserMenuContact) = 0 then
        exit;
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
  ToggleAdvancedPanel(False);
  ShowContacts(False);

  IsSearching := False;
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_GLOBALSEARCH].handle);

  hg.Codepage := hppCodepage;
  hg.RTLMode := hppRTLDefault;
  //hg.Options := GridOptions;

  hg.TxtStartup := TranslateWideW('Ready to search')+
    #10#13#10#13+TranslateWideW('Click Search button to start');

  PassMode := GetPassMode;
  if (PassMode = PASSMODE_PROTALL) then
    TogglePasswordPanel(True);

  LoadPosition;

  HookEvents;

  edSearch.SetFocus;
  edSearch.SelectAll;

  edSearchChange(Self);
  CreateEventsFilterMenu;
  //SetEventFilter(0);
  SetEventFilter(GetShowAllEventsIndex);
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

procedure TfmGlobalSearch.HMFiltersChanged(var M: TMessage);
begin
  CreateEventsFilterMenu;
  SetEventFilter(0);
end;

procedure TfmGlobalSearch.HMIcons2Changed(var M: TMessage);
begin
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_GLOBALSEARCH].handle);
  LoadToolbarIcons;
  LoadButtonIcons;
  pbFilter.Repaint;
  LoadContactsIcons;
  hg.Repaint;
end;

procedure TfmGlobalSearch.mmHideMenuClick(Sender: TObject);
begin
  WriteDBBool(hppDBName,'Accessability', False);
  NotifyAllForms(HM_NOTF_ACCCHANGED,DWord(False),0);
end;

procedure TfmGlobalSearch.HMAccChanged(var M: TMessage);
begin
  ToggleMainMenu(Boolean(M.WParam));
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
      break;
    end;
  if found then hg.Repaint;
end;

procedure TfmGlobalSearch.HMPreShutdown(var M: TMessage);
begin
  Close;
end;

procedure TfmGlobalSearch.hgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Shift=[]) then begin
    Delete1.Click;
    Key := 0;
    exit;
  end;
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

procedure TfmGlobalSearch.ShowContacts(Show: Boolean);
begin
  paContacts.Visible := Show;
  spContacts.Visible := Show;
  if (Show) and (paContacts.Width > 0) then
    spContacts.LEft := paContacts.Width + paContacts.Left + 1;
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

procedure TfmGlobalSearch.SetEventFilter(FilterIndex: Integer);
var
  i,fi: Integer;
  mi: TTntMenuItem;
begin
  if FilterIndex = -1 then begin
    fi := tbEventsFilter.Tag+1;
    if fi > High(hppEventFilters) then fi := 0;
  end else
    fi := FilterIndex;

  mi := TTntMenuItem(Customize1.Parent);
  tbEventsFilter.Tag := fi;
  LoadEventFilterButton;
  for i := 0 to mi.Count-1 do
    if mi[i].RadioItem then
      mi[i].Checked := (pmEventsFilter.Items[i].Tag = fi);

  hg.Filter := hppEventFilters[fi].Events;
end;

procedure TfmGlobalSearch.SetRecentEventsPosition(OnTop: Boolean);
begin
  hg.Reversed := not OnTop;
end;

procedure TfmGlobalSearch.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Mask: Integer;
begin
  if (Key = VK_ESCAPE) or ((Key = VK_F4) and (ssAlt in Shift)) then begin
    if (Key = VK_ESCAPE) and IsSearching then
      StopSearching
    else
      close;
    Key := 0;
    exit;
  end;

  if (Key = VK_F10) and (Shift=[]) then begin
    WriteDBBool(hppDBName,'Accessability', true);
    NotifyAllForms(HM_NOTF_ACCCHANGED,DWord(True),0);
    exit;
  end;

  if (key = VK_F3) and ((Shift=[]) or (Shift=[ssShift])) and (Length(History) > 0) then begin
    SearchNext(ssShift in Shift,True);
    key := 0;
    end;

  if hg.State = gsInline then exit;

  if (Shift = [ssCtrl]) and (Key = VK_INSERT) then Key := Ord('C');
  if IsFormShortCut([mmAcc,pmGrid],Key,Shift) then begin
    Key := 0;
    exit;
  end;

  {if (ssCtrl in Shift) then begin
    if (key=Ord('R')) then begin
      if hg.Selected <> -1 then ReplyQuoted(hg.Selected);
      key:=0;
    end;
    if (key=Ord('M')) then begin
      if hg.Selected <> -1 then SendMessage1.Click;
      key:=0;
    end;
    if (key=Ord('B')) then begin
      Bookmark1.Click;
      key:=0;
    end;
    if (key=Ord('C')) or (key = VK_INSERT) then begin
      Copy1.Click;
      key:=0;
    end;
    if (key=Ord('T')) then begin
      CopyText1.Click;
      key:=0;
    end;
    if key=VK_RETURN then begin
      if hg.Selected <> -1 then hgDblClick(Sender);
      key:=0;
    end;
  end; }

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

procedure TfmGlobalSearch.CreateEventsFilterMenu;
var
  i: Integer;
  mi: TTntMenuItem;
  ShowAllEventsIndex: Integer;
begin
  for i := pmEventsFilter.Items.Count - 1 downto 0 do
    if pmEventsFilter.Items[i].RadioItem then
      pmEventsFilter.Items.Delete(i);

  ShowAllEventsIndex := GetShowAllEventsIndex;
  for i := 0 to Length(hppEventFilters) - 1 do begin
    mi := TTntMenuItem.Create(pmEventsFilter);
    mi.Caption := Tnt_WideStringReplace(hppEventFilters[i].Name,'&','&&',[rfReplaceAll]);
    mi.GroupIndex := 1;
    mi.RadioItem := True;
    mi.Tag := i;
    mi.OnClick := EventsFilterItemClick;
    if i = ShowAllEventsIndex then mi.Default := True;
    pmEventsFilter.Items.Insert(i,mi);
  end;
end;

procedure TfmGlobalSearch.Customize1Click(Sender: TObject);
begin
  if not Assigned(fmCustomizeFilters)  then begin
    CustomizeFiltersForm := TfmCustomizeFilters.Create(Self);
    CustomizeFiltersForm.Show;
  end
  else begin
    BringFormToFront(fmCustomizeFilters);
  end;
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

procedure TfmGlobalSearch.hgRTLEnabled(Sender: TObject; BiDiMode: TBiDiMode);
begin
  edPass.BiDiMode := BiDiMode;
  edSearch.BiDiMode := BiDiMode;
  edFilter.BiDiMode := BiDiMode;
  dtRange1.BiDiMode := BiDiMode;
  dtRange2.BiDiMode := BiDiMode;
  //lvContacts.BiDiMode := BiDiMode;
end;

procedure TfmGlobalSearch.Bookmark1Click(Sender: TObject);
var
  val: boolean;
  hDBEvent: THandle;
begin
  hDBEvent := GetSearchItem(hg.Selected).hDBEvent;
  val := not BookmarkServer[GetSearchItem(hg.Selected).Contact.Handle].Bookmarked[hDBEvent];
  BookmarkServer[GetSearchItem(hg.Selected).Contact.Handle].Bookmarked[hDBEvent] := val;
end;

procedure TfmGlobalSearch.hgInlinePopup(Sender: TObject);
begin
  InlineCopy.Enabled := hg.InlineRichEdit.SelLength > 0;
  InlineReplyQuoted.Enabled := InlineCopy.Enabled;
  InlineTextFormatting.Checked := hg.ProcessInline;
  if hg.Selected <> -1 then begin
    InlineSendMessage.Visible := (GetSearchItem(hg.Selected).Contact.Handle <> 0);
    InlineReplyQuoted.Visible := (GetSearchItem(hg.Selected).Contact.Handle <> 0);
  end;
  pmInline.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
end;

procedure TfmGlobalSearch.InlineCopyClick(Sender: TObject);
begin
  if hg.InlineRichEdit.SelLength = 0 then exit;
  hg.InlineRichEdit.CopyToClipboard;
end;

procedure TfmGlobalSearch.InlineCopyAllClick(Sender: TObject);
var
  cr: TCharRange;
begin
  hg.InlineRichEdit.Lines.BeginUpdate;
  hg.InlineRichEdit.Perform(EM_EXGETSEL,0,LPARAM(@cr));
  hg.InlineRichEdit.SelectAll;
  hg.InlineRichEdit.CopyToClipboard;
  hg.InlineRichEdit.Perform(EM_EXSETSEL,0,LPARAM(@cr));
  hg.InlineRichEdit.Lines.EndUpdate;
end;

procedure TfmGlobalSearch.InlineSelectAllClick(Sender: TObject);
begin
  hg.InlineRichEdit.SelectAll;
end;

procedure TfmGlobalSearch.InlineTextFormattingClick(Sender: TObject);
begin
  hg.ProcessInline := not hg.ProcessInline;
end;

procedure TfmGlobalSearch.InlineReplyQuotedClick(Sender: TObject);
begin
  if hg.Selected <> -1 then begin
    if GetSearchItem(hg.Selected).Contact.Handle = 0 then exit;
    if hg.InlineRichEdit.SelLength = 0 then exit;
    SendMessageTo(GetSearchItem(hg.Selected).Contact.Handle,hg.FormatSelected(DEFFORMAT_REPLYQUOTEDTEXT));
  end;
end;

procedure TfmGlobalSearch.hgInlineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if IsFormShortCut([mmAcc,pmInline],Key,Shift) then begin
    key:=0;
    exit;
  end;
  {if (ssCtrl in Shift) then begin
    if key=Ord('T') then begin
      InlineCopyAll.Click;
      key:=0;
    end;
    if key=Ord('P') then begin
      InlineTextFormatting.Click;
      key:=0;
    end;
    if key=Ord('M') then begin
      SendMessage1.Click;
      key:=0;
    end;
    if key=Ord('R') then begin
      InlineReplyQuoted.Click;
      key:=0;
    end;
  end;}
end;

procedure TfmGlobalSearch.hgUrlPopup(Sender: TObject; Item: Integer; Url: String);
begin
  SavedLinkUrl := Url;
  pmLink.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
end;

procedure TfmGlobalSearch.OpenLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  PluginLink.CallService(MS_UTILS_OPENURL,0,Integer(Pointer(@SavedLinkUrl[1])));
  SavedLinkUrl := '';
end;

procedure TfmGlobalSearch.OpenLinkNWClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  PluginLink.CallService(MS_UTILS_OPENURL,1,Integer(Pointer(@SavedLinkUrl[1])));
  SavedLinkUrl := '';
end;

procedure TfmGlobalSearch.CopyLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  CopyToClip(AnsiToWideString(SavedLinkUrl,CP_ACP),Handle,CP_ACP);
  SavedLinkUrl := '';
end;

procedure TfmGlobalSearch.ToggleMainMenu(Enabled: Boolean);
begin
  if Enabled then begin
    Toolbar.EdgeBorders := [ebTop];
    Menu := mmAcc
  end else begin
    Toolbar.EdgeBorders := [];
    Menu := nil;
  end;
end;

initialization
  fmGlobalSearch := nil;

end.
