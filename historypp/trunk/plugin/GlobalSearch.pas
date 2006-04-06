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
  ImgList, PasswordEditControl, Buttons, TntButtons, Math, CommCtrl,
  Contnrs, TntMenus;

const
  HM_EVENTDELETED = WM_APP + 100;
  HM_CONTACTDELETED = WM_APP + 101;
  HM_CONTACTICONCHANGED = WM_APP + 102;

type
  TContactInfo = class(TObject)
    public
      Proto: String;
      Codepage: Cardinal;
      RTLMode: TRTLMode;
      Name: WideString;
      ProfileName: WideString;
      Handle: Integer;
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
    imFilter: TImage;
    sbClearFilter: TTntSpeedButton;
    edFilter: TTntEdit;
    imFilterWait: TImage;
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
    procedure TntFormDestroy(Sender: TObject);
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
  private
    WasReturnPressed: Boolean;
    LastUpdateTime: DWord;
    CloseAfterThreadFinish: Boolean;
    HotString: WideString;
    hHookContactIconChanged, hHookContactDeleted, hHookEventDeleted: THandle;
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
    procedure SMPrepare(var M: TMessage); message SM_PREPARE;
    procedure SMProgress(var M: TMessage); message SM_PROGRESS;
    procedure SMItemsFound(var M: TMessage); message SM_ITEMSFOUND;
    procedure SMNextContact(var M: TMessage); message SM_NEXTCONTACT;
    procedure SMFinished(var M: TMessage); message SM_FINISHED;

    procedure HMEventDeleted(var M: TMessage); message HM_EVENTDELETED;
    function FindHistoryItemByHandle(hDBEvent: THandle): Integer;
    procedure DeleteEventFromLists(Item: Integer);
    procedure HMContactDeleted(var M: TMessage); message HM_CONTACTDELETED;
    procedure HMContactIconChanged(var M: TMessage); message HM_CONTACTICONCHANGED;

    procedure TranslateForm;

    procedure HookEvents;
    procedure UnhookEvents;

    procedure ShowAdvancedPanel(Show: Boolean);
    procedure ShowContacts(Show: Boolean);

    procedure SearchNext(Rev: Boolean; Warp: Boolean = True);
    procedure ReplyQuoted(Item: Integer);
    procedure StartHotFilterTimer;
    procedure EndHotFilterTimer;
  private
    LastAddedContact: TContactInfo;
    ContactList: TObjectList;
    function FindContact(hContact: Integer): TContactInfo;
    function AddContact(hContact: Integer): TContactInfo;
  protected
    procedure LoadWindowPosition;
    procedure SaveWindowPosition;
  published
    // fix for splitter baug:
    procedure AlignControls(Control: TControl; var ARect: TRect); override;

    function GetSearchItem(GridIndex: Integer): TSearchItem;
    procedure DisableFilter;
    procedure FilterOnContact(hContact: Integer);
  public
    { Public declarations }
  end;

var
  fmGlobalSearch: TfmGlobalSearch;

const
  DEFAULT_SEARCH_TEXT = 'http: ftp: www. ftp.';

implementation

uses hpp_options, PassForm, hpp_itemprocess, hpp_forms, hpp_messages,
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

  ContactList := TObjectList.Create;
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
  st.Free;
  IsSearching := False;
  paProgress.Hide;
  //paFilter.Show;
  sb.SimpleText := sbt;
  bnSearch.Enabled := True;
  if Length(History) = 0 then
    ShowContacts(False);
  if CloseAfterThreadFinish then begin
    Close;
  end;
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
      li.StateIndex := -1;
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
  CloseAfterThreadFinish := False;
  LastUpdateTime := 0;
  ContactsFound := 0;
  AllItems := 0;
  AllContacts := 0;
  FFiltered := False;
  hg.Selected := -1;
  hg.Allocate(0);

  SetLength(FilterHistory,0);
  SetLength(History,0);

  bnSearch.Enabled := False;

  sb.SimpleText := TranslateWideW('Searching... Please wait.');
  IsSearching := True;
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
    imFilter.Visible := False;
    imFilterWait.Visible := True;
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

procedure TfmGlobalSearch.TntFormDestroy(Sender: TObject);
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
  ctrl := Panel1.ControlAtPos(MousePos,False,True);
  if Assigned(ctrl) then
    if Ctrl.Name = 'paContacts' then begin
      {$RANGECHECKS OFF}
      TListView(ctrl).Perform(WM_MOUSEWHEEL,MakeLong(MK_CONTROL,WheelDelta),0);
      {$RANGECHECKS ON}
      exit;
    end;
  {$RANGECHECKS OFF}
  hg.perform(WM_MOUSEWHEEL,MakeLong(MK_CONTROL,WheelDelta),0);
  {$RANGECHECKS ON}
end;

procedure TfmGlobalSearch.sbClearFilterClick(Sender: TObject);
begin
  edFilter.Text := '';
  EndHotFilterTimer;
  hg.SetFocus;
end;

procedure TfmGlobalSearch.TranslateForm;
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

  Open1.Caption := TranslateWideW(Open1.Caption);
  SendMessage1.Caption := TranslateWideW(SendMessage1.Caption);
  ReplyQuoted1.Caption := TranslateWideW(ReplyQuoted1.Caption);
  Copy1.Caption := TranslateWideW(Copy1.Caption);
  CopyText1.Caption := TranslateWideW(CopyText1.Caption);
  SaveSelected1.Caption := TranslateWideW(SaveSelected1.Caption);

  hg.TxtFullLog := Translate(PChar(hg.txtFullLog));
  hg.TxtGenHist1 := Translate(PChar(hg.txtGenHist1));
  hg.TxtGenHist2 := Translate(PChar(hg.txtGenHist2));
  hg.TxtHistExport := Translate(PChar(hg.TxtHistExport));
  hg.TxtNoItems := Translate(PChar(hg.TxtNoItems));
  hg.TxtNoSuch := Translate(PChar(hg.TxtNoSuch));
  hg.TxtPartLog := Translate(PChar(hg.TxtPartLog));
  hg.txtStartUp := Translate(PChar(hg.txtStartUp));

  edSearch.Left := laSearch.Left + laSearch.Width + 5;
  edSearch.Width := bnSearch.Left - edSearch.Left - 5;
  laPass.Left := edPass.Left - laPass.Width - 5;


  //edPass.Left := laPass.Left + laPass.Width + 10;
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

function TfmGlobalSearch.FindContact(hContact: Integer): TContactInfo;
begin

end;

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

procedure TfmGlobalSearch.bnSearchClick(Sender: TObject);
begin
  {TODO: Text}
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
  DelIdx,i: Integer;
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
  hg.Allocate(Length(History));
  hg.Selected := 0;
  // dirty hack: readjust scrollbars
  hg.Perform(WM_SIZE,SIZE_RESTORED,MakeLParam(hg.ClientWidth,hg.ClientHeight));
end;

procedure TfmGlobalSearch.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if IsSearching then begin
    // put before Terminate;
    CanClose := False;
    CloseAfterThreadFinish := True;
    st.Terminate;
    laProgress.Caption := TranslateWideW('Please wait while closing the window...');
    laProgress.Font.Style := [fsBold];
    pb.Visible := False;
    //Application.ProcessMessages;
    //st.WaitFor;
    end;
end;

procedure TfmGlobalSearch.hgItemData(Sender: TObject; Index: Integer;
  var Item: THistoryItem);
begin
  Item := ReadEvent(GetSearchItem(Index).hDBEvent,GetSearchItem(Index).Contact.Codepage);
  Item.Proto := GetSearchItem(Index).Contact.Proto;
  Item.RTLMode := GetSearchItem(Index).Contact.RTLMode;
end;

procedure TfmGlobalSearch.hgItemDelete(Sender: TObject; Index: Integer);
var
  idx: Integer;
begin
  if FFiltered then
    Index := FilterHistory[Index];
  DeleteEventFromLists(Index);
end;

procedure TfmGlobalSearch.hgItemFilter(Sender: TObject; Index: Integer;
  var Show: Boolean);
begin
  if HotFilterString = '' then exit;
  if Pos(WideUpperCase(HotFilterString),WideUpperCase(hg.Items[Index].Text)) = 0 then
    Show := False;
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

procedure TfmGlobalSearch.LoadWindowPosition;
var
  n: Integer;
  AdvancedOptions: Integer;
begin
  if Utils_RestoreWindowPosition(Self.Handle,0,0,hppDBName,'GlobalSearchWindow.') <> 0 then begin
    Self.Left := (Screen.Width-Self.Width) div 2;
    Self.Top := (Screen.Height - Self.Height) div 2;
  end;
    // if we are passord-protected (cbPass.Enabled) and
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


  hg.Reversed := (GetDBInt(hppDBName,'SortOrder',0) = 0);

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

procedure TfmGlobalSearch.lvContactsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  i,hCont,Index: Integer;
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

procedure TfmGlobalSearch.ReplyQuoted(Item: Integer);
var
  Txt: WideString;
begin
  if GetSearchItem(Item).Contact.Handle = 0 then exit;
  if (item < 0) or (item > hg.Count-1) then exit;
  if mtIncoming in hg.Items[Item].MessageType then
    Txt := GetSearchItem(Item).Contact.Name
  else
    Txt := GetSearchItem(Item).Contact.ProfileName;
  Txt := Txt+', '+TimestampToString(hg.Items[item].Time)+' :';
  Txt := Txt+#13#10+QuoteText(hg.Items[item].Text);
  SendMessageTo(GetSearchItem(Item).Contact.Handle,Txt);
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

  // if we are passord-protected (cbPass.Enabled) and
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
  WriteDBStr(hppDBName,'GlobalSearchWindow.LastSearch',LastSearch);
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
  imFilter.Visible := True;
  imFilterWait.Visible := False;
end;

var
  ItemRenderDetails: TItemRenderDetails;

procedure TfmGlobalSearch.hgPopup(Sender: TObject);
begin
  //SaveSelected1.Visible := False;
  if hg.Selected <> -1 then begin
    if GetSearchItem(hg.Selected).Contact.Handle = 0 then begin
      SendMessage1.Visible := False;
      ReplyQuoted1.Visible := False;
    end;
    //Delete1.Visible := True;
    //if hg.SelCount > 1 then
    //  SaveSelected1.Visible := True;
    //AddMenu(Options1,pmAdd,pmGrid,-1);
    //AddMenu(ANSICodepage1,pmAdd,pmGrid,-1);
    //AddMenu(ContactRTLmode1,pmAdd,pmGrid,-1);
    pmGrid.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
  end;
end;

procedure TfmGlobalSearch.hgProcessRichText(Sender: TObject;
  Handle: Cardinal; Item: Integer);
begin
  ZeroMemory(@ItemRenderDetails,SizeOf(ItemRenderDetails));
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
  hHookEventDeleted := PluginLink.HookEventMessage(ME_DB_EVENT_DELETED,Self.Handle,HM_EVENTDELETED);
  hHookContactDeleted := PluginLink.HookEventMessage(ME_DB_CONTACT_DELETED,Self.Handle,HM_CONTACTDELETED);
  hHookContactIconChanged :=PluginLink.HookEventMessage(ME_CLIST_CONTACTICONCHANGED,Self.Handle,HM_CONTACTICONCHANGED);
end;

procedure TfmGlobalSearch.UnhookEvents;
begin
  PluginLink.UnhookEvent(hHookEventDeleted);
  PluginLink.UnhookEvent(hHookContactDeleted);
  PluginLink.UnhookEvent(hHookContactIconChanged);
end;

procedure TfmGlobalSearch.FormShow(Sender: TObject);
var
  PassMode: Byte;
begin
  paFilter.Visible := False;
  ShowAdvancedPanel(False);
  ShowContacts(False);

  IsSearching := False;
  Icon.Handle := CopyIcon(hppIcons[1].handle);

  hg.Options := GridOptions;
  hg.TxtStartup := Translate('Ready to search')+
    #10#13#10#13+Translate('Click Search button to start');

  PassMode := GetPassMode;
  cbPass.Enabled := (PassMode <> PASSMODE_PROTNONE);
  cbPass.Checked := (PassMode = PASSMODE_PROTALL) and (cbPass.Enabled);
  laPass.Enabled := cbPass.Checked and cbPass.Enabled;
  edPass.Enabled := cbPass.Checked and cbPass.Enabled;

  TranslateForm;
  LoadWindowPosition;

  ilContacts.Handle := PluginLink.CallService(MS_CLIST_GETICONSIMAGELIST,0,0);

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
// event is deleted
for i := 0 to hg.Count - 1 do begin
  if (GetSearchItem(i).hDBEvent = M.lParam) then begin
    hg.Delete(i);
    exit;
  end;
end;
// exit if we searched all
if not FFiltered then exit;

// if event is not in filter, we must search the overall array
i := FindHistoryItemByHandle(m.LParam);
if i <> -1 then
  DeleteEventFromLists(i);
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
  Mes: WideString;
  si: TSearchItem;
begin
 si := GetSearchItem(Index);
 if FFiltered then begin
   if mtIncoming in hg.Items[Index].MessageType then
     Name := si.Contact.Name+':'
   else
     Name := si.Contact.ProfileName+':';
 end else begin
   if mtIncoming in hg.Items[Index].MessageType then
     Name := WideFormat(TranslateWideW('From %s:'),[si.Contact.Name])
   else
     Name := WideFormat(TranslateWideW('To %s:'),[si.Contact.Name]);
 end;
end;

procedure TfmGlobalSearch.hgUrlClick(Sender: TObject; Item: Integer; Url: String);
var
  bNewWindow: Integer;
begin
  bNewWindow := 1; // yes, use existing
  PluginLink.CallService(MS_UTILS_OPENURL,bNewWindow,Integer(Pointer(Url)));
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

procedure TfmGlobalSearch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Mask: Integer;
begin
  if (key = VK_F3) and ((Shift=[]) or (Shift=[ssShift])) and (Length(History) > 0) then begin
    SearchNext(ssShift in Shift,True);
    key := 0;
    end;

  if (Key = VK_ESCAPE) then close;

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
var
  i,hCont,Index: Integer;
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
  Idle: Boolean;
  t: WideString;
begin
  if csDestroying in ComponentState then
    exit;
  Idle := (State <> gsDelete);

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

initialization
  fmGlobalSearch := nil;

end.
