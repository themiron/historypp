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
   grid doesn't return to the first iteam HotSearch started from
   unlike in HistoryForm. Probably shouldn'be done, because too much checking
   to reset LastHotIdx should be done, considering how much filtering &
   sorting is performed.

 Copyright (c) Art Fedorov, 2004
-----------------------------------------------------------------------------}

unit GlobalSearch;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus,
  TntForms, TntComCtrls, TntExtCtrls, TntStdCtrls,
  HistoryGrid,
  m_globaldefs, m_api,
  hpp_global, hpp_events, hpp_services, hpp_contacts,  hpp_database,  hpp_searchthread,
  ImgList, PasswordEditControl, Buttons, TntButtons;

const
  HM_EVENTDELETED = WM_APP + 100;
  HM_CONTACTDELETED = WM_APP + 101;
  HM_CONTACTICONCHANGED = WM_APP + 102;

type
  TSearchItem = record
    hDBEvent: THandle;
    hContact: THandle;
    Proto: String;
    ContactName: WideString;
    ProfileName: WideString;
    end;

  TContactInfo = class(TObject)
    private
      FHandle: Integer;
    public
      property Handle: Integer read FHandle write FHandle;
  end;

  TfmGlobalSearch = class(TTntForm)
    Panel1: TPanel;
    paSearch: TPanel;
    Label1: TLabel;
    edSearch: TtntEdit;
    bnSearch: TButton;
    paCommand: TPanel;
    paHistory: TPanel;
    hg: THistoryGrid;
    sb: TStatusBar;
    paProgress: TPanel;
    pb: TProgressBar;
    laProgress: TTntLabel;
    bnClose: TButton;
    pmGrid: TPopupMenu;
    Open1: TMenuItem;
    Copy1: TMenuItem;
    CopyText1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Button2: TButton;
    bnAdvanced: TButton;
    gbAdvanced: TGroupBox;
    rbAny: TRadioButton;
    rbAll: TRadioButton;
    rbExact: TRadioButton;
    spContacts: TTntSplitter;
    paPassword: TPanel;
    edPass: TPasswordEdit;
    cbPass: TTntCheckBox;
    laPass: TTntLabel;
    ilContacts: TImageList;
    paContacts: TTntPanel;
    lvContacts: TTntListView;
    SendMessage1: TMenuItem;
    ReplyQuoted1: TMenuItem;
    SaveSelected1: TMenuItem;
    SaveDialog: TSaveDialog;
    paFilter: TPanel;
    Image1: TImage;
    edFilter: TTntEdit;
    sbClearFilter: TTntSpeedButton;
    procedure sbClearFilterClick(Sender: TObject);
    procedure edPassKeyPress(Sender: TObject; var Key: Char);
    procedure edFilterKeyPress(Sender: TObject; var Key: Char);
    procedure edSearchKeyPress(Sender: TObject; var Key: Char);
    procedure hgItemDelete(Sender: TObject; Index: Integer);
    procedure OnCNChar(var Message: TWMChar); message WM_CHAR;
    procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);
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
    procedure bnCloseClick(Sender: TObject);
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
    CurContactName: WideString;
    CurProfileName: WideString;
    CurProto: String;
    st: TSearchThread;
    stime: DWord;
    ContactsFound: Integer;
    AllItems: Integer;
    AllContacts: Integer;
    procedure SMPrepare(var M: TMessage); message SM_PREPARE;
    procedure SMProgress(var M: TMessage); message SM_PROGRESS;
    procedure SMItemFound(var M: TMessage); message SM_ITEMFOUND; // OBSOLETE
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

implementation

uses hpp_options, PassForm, hpp_itemprocess, hpp_forms, hpp_messages,
  HistoryForm;


{$I m_langpack.inc}
{$I m_database.inc}
{$I m_icq.inc}
{$I m_clist.inc}
{$I m_historypp.inc}

{$R *.DFM}

// fix for infamous splitter bug!
// thanks to Greg Chapman
// http://groups.google.com/group/borland.public.delphi.objectpascal/browse_thread/thread/218a7511123851c3/5ada76e08038a75b%235ada76e08038a75b?sa=X&oi=groupsr&start=2&num=3
procedure TfmGlobalSearch.AlignControls(Control: TControl; var ARect: TRect);
{AlignControls is virtual}
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
end;

procedure TfmGlobalSearch.SMFinished(var M: TMessage);
var
  sbt: String;
begin
  stime := st.SearchTime;
  AllContacts := st.AllContacts;
  AllItems := st.AllEvents;
  // if change, change also in hg.State:
  sbt := Format('%.0n items in %.0n contacts found. Searched for %.1f sec in %.0n items.',[Length(History)/1, ContactsFound/1, stime/1000, AllItems/1, AllContacts/1]);
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

// OBSOLETE:
procedure TfmGlobalSearch.SMItemFound(var M: TMessage);
var
  li: TtntListItem;
begin
  // wParam - hDBEvent, lParam - 0
  SetLength(History,Length(History)+1);
  History[High(History)].hDBEvent := m.wParam;
  History[High(History)].hContact := CurContact;
  History[High(History)].ContactName := CurContactName;
  History[High(History)].ProfileName := CurProfileName;
  History[High(History)].Proto := CurProto;

  if (lvContacts.Items.Count = 0) or (Integer(lvContacts.Items.Item[lvContacts.Items.Count-1].Data) <> CurContact) then begin
    li := lvContacts.Items.Add;
    li.Caption := CurContactName;
    li.Data := Pointer(CurContact);
  end;

  hg.Allocate(Length(History));

  if hg.Count = 1 then begin
    hg.Selected := 0;
    hg.SetFocus;
    end;

  Application.ProcessMessages;

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
  for i := 0 to BufCount - 1 do begin
    History[OldSize + i].hDBEvent := Buffer^[i];
    History[OldSize + i].hContact := CurContact;
    History[OldSize + i].ContactName := CurContactName;
    History[OldSize + i].ProfileName := CurProfileName;
    History[OldSize + i].Proto := CurProto;
  end;

  FreeMem(Buffer,SizeOf(Buffer));

  if (lvContacts.Items.Count = 0) or (Integer(lvContacts.Items.Item[lvContacts.Items.Count-1].Data) <> CurContact) then begin
    if lvContacts.Items.Count = 0 then begin
    li := lvContacts.Items.Add;
      li.Caption := 'All Results';
      li.StateIndex := -1;
      li.Selected := True;
    end;
    li := lvContacts.Items.Add;
    if CurContact = 0 then
      li.Caption := 'System History'
    else
      li.Caption := CurContactName;
    li.ImageIndex := PluginLink.CallService(MS_CLIST_GETCONTACTICON,CurContact,0);
    //meTest.Lines.Add(CurContactName+' icon is '+IntToStr(PluginLink.CallService(MS_CLIST_GETCONTACTICON,CurContact,0)));
    li.Data := Pointer(CurContact);
  end;

  if FFiltered then begin
    if CurContact = FContactFilter then begin
      FiltOldSize := Length(FilterHistory);
      for i := 0 to BufCount - 1 do
        FilterHistory[FiltOldSize+i] := OldSize + i;
    end;
    hg.Allocate(Length(FilterHistory));
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
  hg.Repaint;
  //Application.ProcessMessages;
end;

procedure TfmGlobalSearch.SMNextContact(var M: TMessage);
begin
  // wParam - hContact, lParam - 0
  CurContact := m.wParam;
  if CurContact <> 0 then Inc(ContactsFound);
  if CurContact = 0 then CurProto := 'ICQ'
                    else CurProto := GetContactProto(CurContact);
  CurContactName := GetContactDisplayName(CurContact,CurProto,true);
  CurProfileName := GetContactDisplayName(0, CurProto);
  laProgress.Caption := WideFormat(AnsiToWideString(Translate('Searching "%s"...'),hppCodepage),[CurContactName]);
  //Application.ProcessMessages;
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

  sb.SimpleText := 'Searching... Please wait.';
  IsSearching := True;
  laProgress.Caption := AnsiToWideString(Translate('Preparing search...'),hppCodepage);
  pb.Position := 0;
  paProgress.Show;
  paFilter.Visible := False;
  //ShowContacts(False);
  lvContacts.Items.Clear;
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
  sb.SimpleText := Format('Searching... %.0n items in %.0n contacts found',[Length(History)/1, ContactsFound/1]);
end;

procedure TfmGlobalSearch.edFilterChange(Sender: TObject);
begin
  hg.UpdateFilter;
end;

procedure TfmGlobalSearch.edFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
begin
  inherited;
  if Key in [VK_UP,VK_DOWN,VK_NEXT, VK_PRIOR] then begin
    SendMessage(hg.Handle,WM_KEYDOWN,Key,0);
    Key := 0;
  end;
  if Key = VK_RETURN then begin
    //edFilter.Text := '';
    hg.SetFocus;
    key := 0;
  end;
end;

procedure TfmGlobalSearch.edFilterKeyPress(Sender: TObject; var Key: Char);
begin
if (key = Chr(VK_RETURN)) or (key = Chr(VK_TAB)) or (key = Chr(VK_ESCAPE)) then
  key := #0;
end;

procedure TfmGlobalSearch.TntFormDestroy(Sender: TObject);
begin
  fmGlobalSearch := nil;
end;

procedure TfmGlobalSearch.TntFormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
  if Assigned(ControlAtPos(MousePos,False,True)) then
    //if ControlAtPos(MousePos,False,True,True) is TListView then begin
    if ControlAtPos(MousePos,False,True) is TListView then begin
      {$RANGECHECKS OFF}
      TListView(ControlAtPos(MousePos,False,True)).Perform(WM_MOUSEWHEEL,MakeLong(MK_CONTROL,WheelDelta),0);
      {$RANGECHECKS ON}
      exit;
    end;
  (* we can get range check error (???) here
  it looks that without range check it works ok
  so turn it off *)
  {$RANGECHECKS OFF}
  hg.perform(WM_MOUSEWHEEL,MakeLong(MK_CONTROL,WheelDelta),0);
  {$RANGECHECKS ON}
end;

procedure TfmGlobalSearch.sbClearFilterClick(Sender: TObject);
begin
  edFilter.Text := '';
  hg.SetFocus;
end;

procedure TfmGlobalSearch.TranslateForm;
begin
  {TODO: Translate form}
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
    if History[i].hContact = hContact then begin
      SetLength(FilterHistory,Length(FilterHistory)+1);
      FilterHistory[High(FilterHistory)] := i;
    end;
  end;
  hg.Allocate(0);
  hg.Allocate(Length(FilterHistory));
  if hg.Count > 0 then begin
    hg.Selected := 0;
    // dirty hack: readjust scrollbars
    hg.Perform(WM_SIZE,SIZE_RESTORED,MakeLParam(hg.ClientWidth,hg.ClientHeight));
  end;
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
  Action := caFree;
  SaveWindowPosition;
  UnhookEvents;
end;

procedure TfmGlobalSearch.bnSearchClick(Sender: TObject);
begin
  {TODO: Text}
  if edSearch.Text = '' then
    raise Exception.Create('Enter text to search');
  if edPass.Enabled then begin
    if edPass.Text = '' then begin
      MessageBox(Handle, PChar(String(Translate('Enter the history password to search.'))),
      Translate('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
      edPass.SetFocus;
      edPass.SelectAll;
      exit;
    end;
    if not CheckPassword(edPass.Text) then begin
      MessageBox(Handle, PChar(String(Translate('You have entered the wrong password.'))+
      #10#13+String(Translate('Make sure you have CAPS LOCK turned off.'))),
      Translate('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
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
    laProgress.Caption := 'Please wait while closing the window...';
    laProgress.Font.Style := [fsBold];
    pb.Visible := False;
    //Application.ProcessMessages;
    //st.WaitFor;
    end;
end;

procedure TfmGlobalSearch.hgItemData(Sender: TObject; Index: Integer;
  var Item: THistoryItem);
begin
  Item := ReadEvent(GetSearchItem(Index).hDBEvent);
  Item.Proto := GetSearchItem(Index).Proto;
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
  if edFilter.Text = '' then exit;
  if Pos(WideUpperCase(edFilter.Text),WideUpperCase(hg.Items[Index].Text)) = 0 then
    Show := False;
end;

procedure TfmGlobalSearch.hgDblClick(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  PluginLink.CallService(MS_HPP_OPENHISTORYEVENT,GetSearchItem(hg.Selected).hDBEvent,GetSearchItem(hg.Selected).hContact);
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

  edSearch.Text := AnsiToWideString(GetDBStr(hppDBName,'GlobalSearchWindow.LastSearch',''),hppCodepage);
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
  if GetSearchItem(Item).hContact = 0 then exit;
  if (item < 0) or (item > hg.Count-1) then exit;
  if mtIncoming in hg.Items[Item].MessageType then
    Txt := GetSearchItem(Item).ContactName
  else
    Txt := GetSearchItem(Item).ProfileName;
  Txt := Txt+', '+TimestampToString(hg.Items[item].Time)+' :';
  Txt := Txt+#13#10+QuoteText(hg.Items[item].Text);
  SendMessageTo(GetSearchItem(Item).hContact,Txt);
end;

procedure TfmGlobalSearch.ReplyQuoted1Click(Sender: TObject);
begin
  if hg.Selected <> -1 then begin
    if GetSearchItem(hg.Selected).hContact = 0 then exit;
    ReplyQuoted(hg.Selected);
  end;
end;

var
  HtmlFilter: String = 'HTML file (*.html; *.htm)|*.html;*.htm';
  XmlFilter: String = 'XML file (*.xml)|*.xml';
  UnicodeFilter: String = 'Unicode text file (*.txt)|*.txt';
  TextFilter: String = 'Text file (*.txt)|*.txt';
  AllFilter: String = 'All files (*.*)|*.*';
  HtmlDef: String = '.html';
  XmlDef: String = '.xml';
  TextDef: String = '.txt';

procedure TfmGlobalSearch.PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);
begin
  if AllFormats then begin
    SaveDialog.Filter := HtmlFilter+'|'+XmlFilter+'|'+UnicodeFilter+'|'+TextFilter+'|'+AllFilter;
    case SaveFormat of
      sfHTML: SaveDialog.FilterIndex := 1;
      sfXML: SaveDialog.FilterIndex := 2;
      sfUnicode: SaveDialog.FilterIndex := 3;
      sfText: SaveDialog.FilterIndex := 4;
    end;
  end else begin
    case SaveFormat of
      sfHTML: begin SaveDialog.Filter := HtmlFilter; SaveDialog.FilterIndex := 1; end;
      sfXML:  begin SaveDialog.Filter := XmlFilter; SaveDialog.FilterIndex := 1; end;
      sfUnicode: begin SaveDialog.Filter := UnicodeFilter+'|'+TextFilter; SaveDialog.FilterIndex := 1; end;
      sfText: begin SaveDialog.Filter := UnicodeFilter+'|'+TextFilter; SaveDialog.FilterIndex := 2; end;
    end;
    SaveDialog.Filter := SaveDialog.Filter + '|' + AllFilter;
  end;
  case SaveFormat of
    sfHTML: SaveDialog.DefaultExt := HtmlDef;
    sfXML: SaveDialog.DefaultExt := XmlDef;
    sfUnicode: SaveDialog.DefaultExt := TextDef;
    sfText: SaveDialog.DefaultExt := TextDef;
  end;
end;

procedure TfmGlobalSearch.SaveSelected1Click(Sender: TObject);
var
  t: String;
  SaveFormat: TSaveFormat;
  RecentFormat: TSaveFormat;
begin
  RecentFormat := TSaveFormat(GetDBInt(hppDBName,'ExportFormat',0));
  SaveFormat := RecentFormat;
  PrepareSaveDialog(SaveDialog,SaveFormat,True);
  t := Translate('Partial History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
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

procedure TfmGlobalSearch.bnCloseClick(Sender: TObject);
begin
  close;
end;

var
  ItemRenderDetails: TItemRenderDetails;

procedure TfmGlobalSearch.hgPopup(Sender: TObject);
begin
  //SaveSelected1.Visible := False;
  if hg.Selected <> -1 then begin
    if GetSearchItem(hg.Selected).hContact = 0 then begin
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
  ItemRenderDetails.hContact := GetSearchItem(Item).hContact;
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
  hg.TxtStartup := Translate('Ready to search'#10#13#10#13'Click Search button to start');
  HG.TxtNoItems := Translate('No items found');


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
     Name := si.ContactName+':'
   else
     Name := si.ProfileName+':';
 end else begin
   if mtIncoming in hg.Items[Index].MessageType then
     Name := 'From '+si.ContactName+':'
   else
     Name := 'To '+si.ContactName+':';
   //Name := WideFormat(AnsiToWideString(Translate('%s''s history'),hppCodepage),[si.ContactName]);
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
    bnAdvanced.Caption := Translate('Advanced <<')
  else
    bnAdvanced.Caption := Translate('Advanced >>');
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
  t,tCap: string;
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
    t := Translate('HotSearch: %s (F3 to find next)');
    sb.SimpleText := WideFormat(AnsiToWideString(t,hppCodepage),[stext]);
  end else begin
    WndHandle := Handle;
    tCap := Translate('History++ Search');
    // not found
    if Warp and (down = not hg.Reversed) then begin
      // do warp?
      if MessageBox(WndHandle, PChar(String(Translate('You have reached the end of the history.'))+
      #10#13+String(Translate('Do you want to continue searching at the beginning?'))),
      PChar(tCap), MB_YESNO or MB_DEFBUTTON1 or MB_ICONQUESTION) = ID_YES then
        SearchNext(Rev,False);
    end else begin
      // not warped
      hgState(Self,gsIdle);
      t := Translate('"%s" not found');
      if hppOSUnicode then
        MessageBoxW(WndHandle, PWideChar(WideFormat(AnsiToWideString(t,hppCodepage),[stext])),
        PWideChar(AnsiToWideString(tCap,hppCodepage)), MB_OK or MB_DEFBUTTON1 or 0)
      else
        MessageBox(WndHandle, PChar(Format(t,[stext])),
        PChar(tCap), MB_OK or MB_DEFBUTTON1 or 0);
    end;
  end;
end;

procedure TfmGlobalSearch.SendMessage1Click(Sender: TObject);
begin
  if hg.Selected <> -1 then begin
    if GetSearchItem(hg.Selected).hContact = 0 then exit;
    if GetSearchItem(hg.Selected).hContact <> 0 then SendMessageTo(GetSearchItem(hg.Selected).hContact);
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
  //if LastSearch <> lsHotSearch then
  //  LastHotIdx := hg.Selected;
  //LastSearch := lsHotSearch;
  if Text = '' then begin
    //if (LastHotIdx <> -1) and (HotString <> '') then
    //  hg.Selected := LastHotIdx;
    //LastSearch := lsNone;
    HotString := Text;
    hgState(Self,gsIdle);
    exit;
  end;
  HotString := Text;
  {
  if Found then t := 'Search: "'+Text+'" (Ctrl+Enter to search again)'
  else t := 'Search: "'+Text+'" (not found)';
  sb.SimpleText := t;
  }

  if not Found then t := HotString
               else t := Text;
  sb.SimpleText := WideFormat(AnsiToWideString(Translate('HotSearch: %s (F3 to find next)'),hppCodepage),[t]);
  //if Found then HotString := Text;
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
  t: String;
begin
  if csDestroying in ComponentState then
    exit;
  Idle := (State <> gsDelete);

  case State of
    // if change, change also in SMFinished:
    gsIdle:   t := Format('%.0n items in %.0n contacts found. Searched for %.1f sec in %.0n items.',[Length(History)/1, ContactsFound/1, stime/1000, AllItems/1, AllContacts/1]);
    gsLoad:   t := Translate('Loading...');
    gsSave:   t := Translate('Saving...');
    gsSearch: t := Translate('Searching...');
    gsDelete: t := Translate('Deleting...');
  end;
  if IsSearching then
    // if change, change also in SMProgress
    sb.SimpleText := Format('Searching... %.0n items in %.0n contacts found',[Length(History)/1, ContactsFound/1]);
  sb.SimpleText := AnsiToWideString(t,hppCodepage);
end;

initialization
  fmGlobalSearch := nil;

end.
