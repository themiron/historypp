(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.
    History+ parts (C) 2001 Christian Kastner

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

{-----------------------------------------------------------------------------
 HistoryForm (historypp project)

 Version:   1.4
 Created:   xx.03.2003
 Author:    Oxygen

 [ Description ]

  Main window with history listing

 [ History ]

 1.4
 - Fixed bug on closing history window with FindDialog opened

 1.3 ()
 + Added XML export
 + URL & File highlight handling
 * "Reply Quoted" now is "Forward Message", and it forwards now,
   instead of sending
 - Fixed possible bug when opening hist. window and deleting contact
   now hist. window closes on contact deletion.
 1.2
 1.1
 1.0 (xx.02.03) First version.

 [ Modifications ]
 * (29.05.2003) Added FindDialog.CloseDialog to Form.OnClose so now
   closing history window without closing find dialog don't throws
   exception

 [ Known Issues ]

 * Not very good support of EmailExpress events (togeter
   with HistoryGrid.pas)

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}


unit HistoryForm;

interface

uses
  Windows, Messages, SysUtils, Classes, RichEdit,
  Graphics, Controls, Forms, Dialogs, Buttons, StdCtrls, Menus, ComCtrls, ExtCtrls,
  TntWindows, TntSysUtils,
  TntGraphics, TntForms, TntDialogs, TntButtons, TntStdCtrls, TntMenus, TntComCtrls, TntExtCtrls,
  m_globaldefs, m_api,
  hpp_global, hpp_database, hpp_messages, hpp_events, hpp_contacts, hpp_itemprocess,
  hpp_bookmarks, hpp_forms, hpp_richedit, hpp_sessionsthread,
  HistoryGrid, Checksum, DateUtils,
  ImgList, HistoryControls, CommCtrl, ToolWin, ShellAPI, Themes;

type

  TLastSearch = (lsNone,lsHotSearch,lsSearch);
  TSearchMode = (smNone, smSearch, smFilter, smHotSearch); // smHotSearch for possible future use
  THistoryPanel = (hpSessions, hpBookmarks);
  THistoryPanels = set of THistoryPanel;

  THistoryFrm = class(THppForm)
    SaveDialog: TSaveDialog;
    pmGrid: TTntPopupMenu;
    paClient: THppPanel;
    paGrid: THppPanel;
    hg: THistoryGrid;
    sb: TTntStatusBar;
    pmLink: TTntPopupMenu;
    paSess: THppPanel;
    spHolder: TTntSplitter;
    ilSessions: TImageList;
    paSessInt: THppPanel;
    laSess: TTntLabel;
    sbCloseSess: THppSpeedButton;
    N13: TTntMenuItem;
    SaveSelected1: TTntMenuItem;
    N2: TTntMenuItem;
    Delete1: TTntMenuItem;
    CopyText1: TTntMenuItem;
    Copy1: TTntMenuItem;
    N12: TTntMenuItem;
    ReplyQuoted1: TTntMenuItem;
    SendMessage1: TTntMenuItem;
    N8: TTntMenuItem;
    Details1: TTntMenuItem;
    CopyLink: TTntMenuItem;
    N1: TTntMenuItem;
    OpenLinkNW: TTntMenuItem;
    OpenLink: TTntMenuItem;
    ContactRTLmode: TTntMenuItem;
    ANSICodepage: TTntMenuItem;
    RTLDisabled2: TTntMenuItem;
    RTLEnabled2: TTntMenuItem;
    RTLDefault2: TTntMenuItem;
    SystemCodepage: TTntMenuItem;
    sbClearFilter: THppSpeedButton;
    pbFilter: TPaintBox;
    tiFilter: TTimer;
    ilToolbar: TImageList;
    Toolbar: THppToolBar;
    paPassHolder: THppPanel;
    paPassword: THppPanel;
    laPass: TTntLabel;
    Image1: TImage;
    laPass2: TTntLabel;
    edPass: TPasswordEdit;
    bnPass: TTntButton;
    pmHistory: TTntPopupMenu;
    SaveasMContacts2: TTntMenuItem;
    SaveasRTF2: TTntMenuItem;
    SaveasXML2: TTntMenuItem;
    SaveasHTML2: TTntMenuItem;
    SaveasText2: TTntMenuItem;
    tbSearch: THppToolButton;
    TntToolButton3: THppToolButton;
    paSearch: THppPanel;
    tbFilter: THppToolButton;
    tbDelete: THppToolButton;
    tbSessions: THppToolButton;
    TntToolButton2: THppToolButton;
    paSearchStatus: THppPanel;
    laSearchState: TTntLabel;
    paSearchPanel: THppPanel;
    sbSearchNext: THppSpeedButton;
    sbSearchPrev: THppSpeedButton;
    edSearch: THppEdit;
    pbSearch: TPaintBox;
    tvSess: TTntTreeView;
    tbSave: THppToolButton;
    tbCopy: THppToolButton;
    tbHistorySearch: THppToolButton;
    imSearchEndOfPage: TTntImage;
    imSearchNotFound: TTntImage;
    TntToolButton4: THppToolButton;
    N4: TTntMenuItem;
    EmptyHistory1: TTntMenuItem;
    pmEventsFilter: TTntPopupMenu;
    ShowAll1: TTntMenuItem;
    Customize1: TTntMenuItem;
    N6: TTntMenuItem;
    Passwordprotection1: TTntMenuItem;
    TopPanel: THppPanel;
    paSearchButtons: THppPanel;
    pmSessions: TTntPopupMenu;
    SessCopy: TTntMenuItem;
    SessSelect: TTntMenuItem;
    SessDelete: TTntMenuItem;
    N7: TTntMenuItem;
    SessSave: TTntMenuItem;
    tbUserMenu: THppToolButton;
    tbUserDetails: THppToolButton;
    TntToolButton1: THppToolButton;
    tbEventsFilter: THppSpeedButton;
    TntToolButton5: THppToolButton;
    pmToolbar: TTntPopupMenu;
    Customize2: TTntMenuItem;
    Bookmark1: TTntMenuItem;
    paBook: THppPanel;
    paBookInt: THppPanel;
    laBook: TTntLabel;
    sbCloseBook: THppSpeedButton;
    lvBook: TTntListView;
    ilBook: TImageList;
    tbBookmarks: THppToolButton;
    pmBook: TTntPopupMenu;
    DeleteBookmark1: TTntMenuItem;
    N3: TTntMenuItem;
    SaveSelected2: TTntMenuItem;
    N11: TTntMenuItem;
    RenameBookmark1: TTntMenuItem;
    pmInline: TTntPopupMenu;
    InlineReplyQuoted: TTntMenuItem;
    TntMenuItem6: TTntMenuItem;
    InlineCopy: TTntMenuItem;
    InlineCopyAll: TTntMenuItem;
    TntMenuItem10: TTntMenuItem;
    InlineSelectAll: TTntMenuItem;
    InlineTextFormatting: TTntMenuItem;
    InlineSendMessage: TTntMenuItem;
    N5: TTntMenuItem;
    mmAcc: TTntMainMenu;
    mmToolbar: TTntMenuItem;
    mmService: TTntMenuItem;
    mmHideMenu: TTntMenuItem;
    mmShortcuts: TTntMenuItem;
    mmBookmark: TTntMenuItem;
    SelectAll1: TTntMenuItem;
    tbHistory: THppToolButton;
    paHolder: THppPanel;
    spBook: TTntSplitter;
    UnknownCodepage: TTntMenuItem;
    OpenFileFolder: TTntMenuItem;
    BrowseReceivedFiles: TTntMenuItem;
    N9: TTntMenuItem;
    CopyFilename: TTntMenuItem;
    FileActions: TTntMenuItem;
    N10: TTntMenuItem;
    pmFile: TTntPopupMenu;
    SpeakMessage1: TTntMenuItem;
    procedure tbHistoryClick(Sender: TObject);
    procedure SaveasText2Click(Sender: TObject);
    procedure SaveasMContacts2Click(Sender: TObject);
    procedure SaveasRTF2Click(Sender: TObject);
    procedure SaveasXML2Click(Sender: TObject);
    procedure SaveasHTML2Click(Sender: TObject);
    procedure tbSessionsClick(Sender: TObject);
    procedure pbSearchStatePaint(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure sbSearchPrevClick(Sender: TObject);
    procedure sbSearchNextClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure hgChar(Sender: TObject; var Char: WideChar; Shift: TShiftState);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edSearchKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tbSearchClick(Sender: TObject);
    procedure tbFilterClick(Sender: TObject);
    procedure pbSearchPaint(Sender: TObject);
    procedure paPassHolderResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tvSessMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    //procedure tvSessClick(Sender: TObject);
    procedure sbCloseSessClick(Sender: TObject);
    procedure hgItemFilter(Sender: TObject; Index: Integer; var Show: Boolean);
    procedure tvSessChange(Sender: TObject; Node: TTreeNode);
    //procedure bnConversationClick(Sender: TObject);

    procedure LoadHistory(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnCNChar(var Message: TWMChar); message WM_CHAR;

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure hgItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
    procedure hgTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
    procedure hgPopup(Sender: TObject);

    procedure hgSearchFinished(Sender: TObject; Text: WideString; Found: Boolean);
    procedure hgDblClick(Sender: TObject);
    procedure tbSaveClick(Sender: TObject);
    procedure hgItemDelete(Sender: TObject; Index: Integer);
    procedure tbCopyClick(Sender: TObject);
    procedure Details1Click(Sender: TObject);
    procedure hgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure hgState(Sender: TObject; State: TGridState);
    
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure hgSelect(Sender: TObject; Item, OldItem: Integer);
    procedure hgXMLData(Sender: TObject; Index: Integer; var Item: TXMLItem);
    procedure hgMCData(Sender: TObject; Index: Integer; var Item: TMCItem; Stage: TSaveStage);
    procedure OpenLinkClick(Sender: TObject);
    procedure OpenLinkNWClick(Sender: TObject);
    procedure CopyLinkClick(Sender: TObject);
    procedure bnPassClick(Sender: TObject);
    procedure edPassKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edPassKeyPress(Sender: TObject; var Key: Char);
    procedure CopyText1Click(Sender: TObject);
    procedure hgUrlClick(Sender: TObject; Item: Integer; URLText: WideString; Button: TMouseButton);
    procedure hgProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
    procedure hgSearchItem(Sender: TObject; Item, ID: Integer; var Found: Boolean);
    procedure hgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ContactRTLmode1Click(Sender: TObject);
    procedure SendMessage1Click(Sender: TObject);
    procedure ReplyQuoted1Click(Sender: TObject);
    procedure CodepageChangeClick(Sender: TObject);
    procedure sbClearFilterClick(Sender: TObject);
    procedure pbFilterPaint(Sender: TObject);
    procedure StartHotFilterTimer;
    procedure EndHotFilterTimer(DoClearFilter: Boolean = False);
    procedure tiFilterTimer(Sender: TObject);
    procedure tbHistorySearchClick(Sender: TObject);
    procedure EmptyHistory1Click(Sender: TObject);
    procedure EventsFilterItemClick(Sender: TObject);
    procedure Passwordprotection1Click(Sender: TObject);
    procedure SessSelectClick(Sender: TObject);
    procedure pmGridPopup(Sender: TObject);
    procedure pmHistoryPopup(Sender: TObject);
    procedure tbUserMenuClick(Sender: TObject);
    procedure tvSessGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure Customize1Click(Sender: TObject);
    procedure tbEventsFilterClick(Sender: TObject);
    procedure hgRTLEnabled(Sender: TObject; BiDiMode: TBiDiMode);
    procedure ToolbarDblClick(Sender: TObject);
    procedure Customize2Click(Sender: TObject);
    procedure Bookmark1Click(Sender: TObject);
    procedure tbUserDetailsClick(Sender: TObject);
    procedure hgBookmarkClick(Sender: TObject; Item: Integer);
    procedure tbBookmarksClick(Sender: TObject);
    procedure sbCloseBookClick(Sender: TObject);
    procedure lvBookSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvBookContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure lvBookEdited(Sender: TObject; Item: TTntListItem;
      var S: WideString);
    procedure RenameBookmark1Click(Sender: TObject);
    procedure hgProcessInlineChange(Sender: TObject; Enabled: Boolean);
    procedure hgInlinePopup(Sender: TObject);
    procedure InlineCopyClick(Sender: TObject);
    procedure InlineCopyAllClick(Sender: TObject);
    procedure InlineSelectAllClick(Sender: TObject);
    procedure InlineTextFormattingClick(Sender: TObject);
    procedure hgInlineKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure InlineReplyQuotedClick(Sender: TObject);
    procedure pmEventsFilterPopup(Sender: TObject);
    procedure mmToolbarClick(Sender: TObject);
    procedure mmHideMenuClick(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure lvBookKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvSessKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure paHolderResize(Sender: TObject);
    procedure spBookMoved(Sender: TObject);
    procedure pmToolbarPopup(Sender: TObject);
    procedure hgFilterChange(Sender: TObject);
    procedure OpenFileFolderClick(Sender: TObject);
    procedure BrowseReceivedFilesClick(Sender: TObject);
    procedure SpeakMessage1Click(Sender: TObject);
    procedure hgOptionsChange(Sender: TObject);
  private
    DelayedFilter: TMessageTypes;
    StartTimestamp: DWord;
    EndTimestamp: DWord;
    FhContact,FhSubContact: THandle;
    FProtocol,FSubProtocol: String;
    FPasswordMode: Boolean;
    SavedLinkUrl: WideString;
    SavedFileDir: String;
    HotFilterString: WideString;
    FormState: TGridState;
    PreHotSearchMode: TSearchMode;
    FSearchMode: TSearchMode;
    UserMenu: hMenu;
    FPanel: THistoryPanels;
    IsLoadingSessions: Boolean;

    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure WMSysColorChange(var Message: TMessage); message WM_SYSCOLORCHANGE;
    procedure LoadPosition;
    procedure SavePosition;

    procedure HMEventAdded(var Message: TMessage); message HM_MIEV_EVENTADDED;
    procedure HMEventDeleted(var Message: TMessage); message HM_MIEV_EVENTDELETED;
    procedure HMPreShutdown(var Message: TMessage); message HM_MIEV_PRESHUTDOWN;
    procedure HMContactDeleted(var Message: TMessage); message HM_MIEV_CONTACTDELETED;
    procedure HMMetaDefaultChanged(var M: TMessage); message HM_MIEV_METADEFCHANGED;

    procedure HMIcons2Changed(var M: TMessage); message HM_NOTF_ICONS2CHANGED;
    procedure HMAccChanged(var M: TMessage); message HM_NOTF_ACCCHANGED;
    procedure HMNickChanged(var M: TMessage); message HM_NOTF_NICKCHANGED;


    procedure OpenDetails(Item: Integer);
    procedure SetPasswordMode(const Value: Boolean);
    procedure ProcessPassword;
    procedure TranslateForm;

    procedure SethContact(const Value: THandle);
    procedure LoadInOptions();
    function IsFileEvent(Index: Integer): Boolean;

    procedure PreLoadHistory;
    procedure PostLoadHistory;
    procedure SetSearchMode(const Value: TSearchMode);
    procedure SetPanel(const Value: THistoryPanels);
    procedure ToggleMainMenu(Enabled: Boolean);

  protected
    procedure LoadPendingHeaders(rowidx: integer; count: integer);
    property SearchMode: TSearchMode read FSearchMode write SetSearchMode;
    property Panel: THistoryPanels read FPanel write SetPanel;
    procedure WndProc(var Message: TMessage); override;

  public
    UserCodepage: Cardinal;
    UseDefaultCP: boolean;
    LastSearch: TLastSearch;
    HotString: WideString;
    LastHotIdx: Integer;
    EventDetailForm: TForm;
    CustomizeFiltersForm: TForm;
    CustomizeToolbarForm: TForm;
    WindowList:TList;
    History:array of THandle;
    HistoryLength:integer;
    RecentFormat: TSaveFormat;
    SessThread: TSessionsThread;
    Sessions: TSessArray;
    SeparatorButtonWidth: Integer;

    procedure SearchNext(Rev: Boolean; Warp: Boolean = True);
    procedure DeleteHistoryItem(ItemIdx:Integer);
    procedure AddHistoryItem(hDBEvent: THandle);
    procedure Load;
    function GridIndexToHistory(Index: Integer): Integer;
    function HistoryIndexToGrid(Index: Integer): Integer;
    function GetItemData(Index: Integer): THistoryItem;

    procedure ReplyQuoted(Item: Integer);
    procedure OpenPassword;
    procedure EmptyHistory;

    procedure SMPrepare(var M: TMessage); message HM_SESS_PREPARE;
    procedure SMItemsFound(var M: TMessage); message HM_SESS_ITEMSFOUND;
    procedure SMFinished(var M: TMessage); message HM_SESS_FINISHED;
    procedure AddEventToSessions(hDBEvent: THandle);
    procedure DeleteEventFromSessions(ItemIdx: Integer);

    procedure LoadSessionIcons;
    procedure LoadBookIcons;
    procedure LoadToolbarIcons;
    procedure LoadEventFilterButton;
    procedure LoadButtonIcons;

    procedure CustomizeToolbar;
    procedure LoadToolbar;
    procedure LoadAccMenu;
    procedure HMToolbarChanged(var M: TMessage); message HM_NOTF_TOOLBARCHANGED;

    procedure SetRecentEventsPosition(OnTop: Boolean);
    procedure Search(Next: Boolean; FromNext: Boolean = False);

    procedure ShowAllEvents;
    procedure ShowItem(Value: Integer);
    procedure SetEventFilter(FilterIndex: Integer = -1; DelayApply: Boolean = false);
    procedure CreateEventsFilterMenu;
    procedure HMFiltersChanged(var M: TMessage); message HM_NOTF_FILTERSCHANGED;

    procedure FillBookmarks;
    procedure HMBookmarkChanged(var M: TMessage); message HM_NOTF_BOOKMARKCHANGED;

    property PasswordMode: Boolean read FPasswordMode write SetPasswordMode;
    property hContact: THandle read FhContact write SethContact;
    property Protocol: String read FProtocol;
    property hSubContact: THandle read FhSubContact;
    property SubProtocol: String read FSubProtocol;
  published
    procedure AlignControls(Control: TControl; var ARect: TRect); override;
  end;

var
  HistoryFrm: THistoryFrm;

const
  DEF_HISTORY_TOOLBAR='[SESS][BOOK] [SEARCH][FILTER] [EVENTS] [COPY][DELETE] [HISTORY]';

//function ParseUrlItem(Item: THistoryItem; out Url,Mes: WideString): Boolean;
//function ParseFileItem(Item: THistoryItem; out FileName,Mes: WideString): Boolean;

implementation

uses EventDetailForm, PassForm, hpp_options, hpp_services, hpp_eventfilters,
  CustomizeFiltersForm, CustomizeToolbar;

{$R *.DFM}

const
  HPP_SESS_YEARFORMAT  = 'yyyy';
  HPP_SESS_MONTHFORMAT = 'mmmm';
  HPP_SESS_DAYFORMAT   = 'd (h:nn)';

function Max(a,b:integer):integer;
begin if b>a then Result:=b else Result:=a end;
function NotZero(x:dword):dword;//used that array doesn't store 0 for already loaded data
begin if x=0 then Result:=1 else Result:=x end;

{function ParseUrlItem(Item: THistoryItem; out Url,Mes: WideString): Boolean;
var
  tmp1,tmp2: WideString;
  n: Integer;
begin
  Url := '';
  Mes := '';
  Result := False;
  if not (mtUrl in Item.MessageType) then exit;
  tmp1 := Item.Text;
  if tmp1 = '' then exit;
  Result := True;

  n := Pos(#10,tmp1);
  if n <> 0 then begin
    tmp2 := Copy(tmp1,1,n-2);
    Delete(tmp1,1,n);
  end else begin
    tmp2 := tmp1;
    tmp1 := '';
  end;

  Mes := tmp1;

  n := Pos(':',tmp2);
  if n <> 0 then begin
    tmp2 := Copy(tmp2,n+2,Length(tmp2));
  end else begin
    Result := False;
    tmp2 := '';
  end;

  url := tmp2;
end;}

{function ParseFileItem(Item: THistoryItem; out FileName,Mes: WideString): Boolean;
var
  tmp1,tmp2: string;
  n: Integer;
begin
  Result := False;
  FileName := '';
  Mes := '';
  if not (mtFile in Item.MessageType) then exit;
  tmp1 := Item.Text;

  n := Pos(#10,tmp1);
  if n <> 0 then begin
    Delete(tmp1,1,n)
  end else
    exit;

  Result := True;

  n := Pos(#10,tmp1);
  if n <> 0 then begin
    tmp2 := tmp1;
    tmp1 := Copy(tmp2,1,n-2);
    Delete(tmp2,1,n);
  end;

  Mes := tmp2;
  FileName := tmp1;
end;}

{function GetEventInfo(hDBEvent: DWord): TDBEVENTINFO;
var
  BlobSize:Integer;
begin
  ZeroMemory(@Result,SizeOf(Result));
  Result.cbSize:=SizeOf(Result);
  Result.pBlob:=nil;
  BlobSize:=PluginLink.CallService(MS_DB_EVENT_GETBLOBSIZE,hDBEvent,0);

  GetMem(Result.pBlob,BlobSize);
  Result.cbBlob:=BlobSize;

  PluginLink.CallService(MS_DB_EVENT_GET,hDBEvent,Integer(@Result));
end;}

(*
This function gets only name of the file
and tries to make it FAT-happy, so we trim out and
":"-s, "\"-s and so on...
*)
function MakeFileName(FileName: String): String;
begin
  Result := FileName;
  Result := StringReplace(Result,':','_',[rfReplaceAll]);
  Result := StringReplace(Result,'\','_',[rfReplaceAll]);
  Result := StringReplace(Result,'/','_',[rfReplaceAll]);
  Result := StringReplace(Result,'*','_',[rfReplaceAll]);
  Result := StringReplace(Result,'?','_',[rfReplaceAll]);
  Result := StringReplace(Result,'"','''',[rfReplaceAll]);
  Result := StringReplace(Result,'<',']',[rfReplaceAll]);
  Result := StringReplace(Result,'>','[',[rfReplaceAll]);
  Result := StringReplace(Result,'|','',[rfReplaceAll]);
end;

procedure THistoryFrm.LoadHistory(Sender: TObject);
//Load the History from the Database and Display it in the grid
  procedure FastLoadHandles;
  var
    hDbEvent: THandle;
    LineIdx: integer;
    ToRead: integer;
  begin
    HistoryLength := PluginLink.CallService(MS_DB_EVENT_GETCOUNT,hContact,0);
    if HistoryLength = -1 then begin
      // contact is missing
      // or other error ?
      HistoryLength := 0;
    end;
    SetLength(History,HistoryLength);
    if HistoryLength = 0 then Exit;
    hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDLAST,hContact,0);
    History[HistoryLength-1] := NotZero(hDbEvent);
    {if NeedhDBEvent = 0 then toRead := Max(0,HistoryLength-hppLoadBlock-1)
                        else toRead := 0;}
    toRead := Max(0,HistoryLength-hppFirstLoadBlock-1);
    LineIdx:=HistoryLength-2;
    repeat
      hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDbEvent,0);
      History[LineIdx] :=NotZero(hDbEvent);
      {if NeedhDBEvent = hDbEvent then begin
        Result := HistoryLength-LineIdx-1;
        toRead := Max(0,Result-hppLoadBlock shr 1);
      end;}
      dec(LineIdx);
    until LineIdx < toRead;
  end;
begin
  FastLoadHandles;

  hg.Contact := hContact;
  hg.Protocol := Protocol;
  // hContact,hSubContact,Protocol,SubProtocol should be
  // already filled by calling hContact := Value;
  hg.ProfileName := GetContactDisplayName(0, SubProtocol);
  hg.ContactName := GetContactDisplayName(hContact, Protocol, True);
  UserCodepage := GetContactCodePage(hContact,Protocol,UseDefaultCP);
  hg.Codepage := UserCodepage;
  hg.RTLMode := GetContactRTLModeTRTL(hContact,Protocol);
  UnknownCodepage.Tag := Integer(UserCodepage);
  UnknownCodepage.Caption := WideFormat(
        TranslateWideW('Unknown codepage %u'),
        [UserCodepage]);
  if hContact = 0 then
    Caption := TranslateWideW('System History') else
    Caption := WideFormat(TranslateWideW('%s - History++'),[hg.ContactName]);
  hg.Allocate(HistoryLength);
end;

procedure THistoryFrm.FormCreate(Sender: TObject);
var
  i: integer;
  mi: TTntMenuItem;
begin
  hg.BeginUpdate;

  Icon.ReleaseHandle;
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_CONTACTHISTORY].handle);

  // delphi 2006 doesn't save toolbar's flat property in dfm if it is True
  // delphi 2006 doesn't save toolbar's edgeborder property in dfm
  Toolbar.Flat := True;
  Toolbar.EdgeBorders := [];

  LoadToolbarIcons;
  LoadButtonIcons;
  LoadSessionIcons;
  LoadBookIcons;
  Image1.Picture.Icon.Handle := CopyIcon(hppIntIcons[0].handle);

  DesktopFont := True;
  MakeFontsParent(Self);

  DoubleBuffered := True;
  MakeDoubleBufferedParent(Self);
  TopPanel.DoubleBuffered := False;
  hg.DoubleBuffered := False;

  IsLoadingSessions := False;
  SessThread := nil;

  FormState := gsIdle;

  DelayedFilter := [];
  // if we do so, we'll never get selected if filters match
  //hg.Filter := GenerateEvents(FM_EXCLUDE,[]);

  for i := 0 to High(cpTable) do begin
    mi := WideNewItem(cpTable[i].name,0,false,true,nil,0,'cp'+intToStr(i));
    mi.Tag := cpTable[i].cp;
    mi.OnClick := CodepageChangeClick;
    mi.AutoCheck := True;
    mi.RadioItem := True;
    ANSICodepage.Add(mi);
  end;

  TranslateForm;

  // File actions from context menu support
  AddMenuArray(pmGrid,[FileActions],-1);

  LoadAccMenu; // load accessability menu before LoadToolbar
               // put here because we want to translate everything
               // before copying to menu

  //cbFilter.ItemIndex := 0;
  RecentFormat := sfHtml;
  //hg.InlineRichEdit.PopupMenu := pmGridInline;
  //for i := 0 to pmOptions.Items.Count-1 do
  //  pmOptions.Items.Remove(pmOptions.Items[0]);
end;

procedure THistoryFrm.LoadPosition;
//load last position and filter setting
//var
  //filt: Integer;
  //w,h,l,t: Integer;
begin
  // removed Utils_RestoreWindowPosition because it shows window sooner than we expect
  Utils_RestoreFormPosition(Self,0,hppDBName,'HistoryWindow.');
  // use MagneticWindows.dll
  PluginLink.CallService(MS_MW_ADDWINDOW,WindowHandle,0);
  SearchMode := TSearchMode(GetDBByte(hppDBName,'SearchMode',0));
end;

procedure THistoryFrm.LoadSessionIcons;
var
  il: THandle;
begin
  tvSess.Items.BeginUpdate;
  try
    ImageList_Remove(ilSessions.Handle,-1); // clears image list
    il := ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,8,2);
    if il <> 0 then
      ilSessions.Handle := il
    else
      il := ilSessions.Handle;

    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESSION].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_SUMMER].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_AUTUMN].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_WINTER].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_SPRING].handle);
    ImageList_AddIcon(il,hppIcons[HPP_ICON_SESS_YEAR].handle);
  finally
    tvSess.Items.EndUpdate;
    //tvSess.Update;
  end;

  // simple hack to avoid dark icons
  ilSessions.BkColor := tvSess.Color;

end;

// to do:
// SAVEALL (???)
// DELETEALL
// SENDMES (???)
// REPLQUOTED (???)
// COPYTEXT (???)
procedure THistoryFrm.LoadToolbar;
var
  tool: array of TControl;
  i,n: Integer;
  tb_butt: THppToolButton;
  butt: TControl;
  butt_str,tb_str,str: String;
begin
  tb_str := GetDBStr(hppDBName,'HistoryToolbar',DEF_HISTORY_TOOLBAR);

  if (tb_str = '') then begin // toolbar is disabled
    Toolbar.Visible := False;
    // should add "else T.Visible := True" to make it dynamic in run-time, but I will ignore it
    // you can never know which Toolbar bugs & quirks you'll trigger with it :)
  end;

  if hContact = 0 then begin
    tb_str := StringReplace(tb_str,'[SESS]','',[rfReplaceAll]);
    //tb_str := StringReplace(tb_str,'[BOOK]','',[rfReplaceAll]);
    //tb_str := StringReplace(tb_str,'[EVENTS]','',[rfReplaceAll]);
  end;
  str := tb_str;

  i := 0;
  while True do begin
    if i = Toolbar.ControlCount then break;
    if Toolbar.Controls[i] is THppToolButton then begin
      tb_butt := THppToolButton(Toolbar.Controls[i]);
      if (tb_butt.Style = tbsSeparator) or (tb_butt.Style = tbsDivider) then begin
        // adding separator in runtime results in too wide separators
        // we'll remeber the currect width and later re-apply it
        SeparatorButtonWidth := tb_butt.Width;
        tb_butt.Free;
        Dec(i);
      end
      else
        tb_butt.Visible := False;
    end
    else if Toolbar.Controls[i] is THppSpeedButton then
      THppSpeedButton(Toolbar.Controls[i]).Visible := False;
    Inc(i);
  end;

  try
    while True do begin
      if str = '' then break;
      if (str[1] = ' ') or (str[1] = '|') then begin
        if (Length(tool) > 0) and (tool[High(tool)] is THppToolButton) then begin
          // don't add separator if previous button is separator
          tb_butt := THppToolButton(tool[High(tool)]);
          if (tb_butt.Style = tbsDivider) or (tb_butt.Style = tbsSeparator) then begin
            Delete(str,1,1);
            continue;
          end;
        end
        else if (Length(tool) = 0) then begin
          // don't add separator as first button
          Delete(str,1,1);
          continue;
        end;
        SetLength(tool,Length(tool)+1);
        tb_butt := THppToolButton.Create(Toolbar);
        tb_butt.Visible := False;
        if str[1] = ' ' then
          tb_butt.Style := tbsSeparator
        else
          tb_butt.Style := tbsDivider;
        Delete(str,1,1);
        tb_butt.Parent := Toolbar;
        tb_butt.Width := SeparatorButtonWidth;
        tool[High(tool)] := tb_butt;
      end
      else if str[1]='[' then begin
        n := Pos(']',str);
        if n = -1 then
          raise EAbort.Create('Wrong toolbar string format');
        butt_str := Copy(str,2,n-2);
        Delete(str,1,n);
        butt := nil;
        if butt_str = 'SESS' then butt := tbSessions;
        if butt_str = 'BOOK' then butt := tbBookmarks;
        if butt_str = 'SEARCH' then butt := tbSearch;
        if butt_str = 'FILTER' then butt := tbFilter;
        if butt_str = 'COPY' then butt := tbCopy;
        if butt_str = 'DELETE' then butt := tbDelete;
        if butt_str = 'SAVE' then butt := tbSave;
        if butt_str = 'HISTORY' then butt := tbHistory;
        if butt_str = 'GLOBSEARCH' then butt := tbHistorySearch;
        if butt_str = 'EVENTS' then butt := tbEventsFilter;
        if butt_str = 'USERMENU' then butt := tbUserMenu;
        if butt_str = 'USERDETAILS' then butt := tbUserDetails;
        if butt <> nil then begin
          SetLength(tool,Length(tool)+1);
          tool[High(tool)] := butt;
        end;
      end
      else
        raise EAbort.Create('Wrong toolbar string format');
    end;
  except
    // if we have error, try loading default toolbar config or
    // show error if it doesn't work
    if tb_str = DEF_HISTORY_TOOLBAR then begin
      // don't think it should be translated:
      hppMessageBox(Handle,'Can not apply default toolbar configuration.'+#10#13+
      'Looks like it is an internal problem.'+#10#13+
      #10#13+
      'Download new History++ version or report the error to the authors'+#10#13+
      '(include plugin version number and file date in the report).'+#10#13+
      #10#13+
      'You can find authors'' emails and plugin website in the Options->Plugins page.',
      TranslateWideW('Error'),MB_OK or MB_ICONERROR);
      exit;
    end
    else begin
      DBDeleteContactSetting(0,hppDBName,'HistoryToolbar');
      LoadToolbar;
      exit;
    end;
  end;

  // move buttons in reverse order and set parent afterwards
  // thanks Luu Tran for this tip
  // http://groups.google.com/group/borland.public.delphi.vcl.components.using/browse_thread/thread/da4e4da814baa745/c1ce8b671c1dac20
  for i := High(tool) downto 0 do begin
    if not (tool[i] is THppSpeedButton) then tool[i].Parent := nil;
    tool[i].Left := -3;
    tool[i].Visible := True;
    if not (tool[i] is THppSpeedButton) then tool[i].Parent := Toolbar;
  end;

  // Thanks Primoz Gabrijeleie for this trick!
  // http://groups.google.com/group/alt.comp.lang.borland-delphi/browse_thread/thread/da77e8db6d8f418a/dc4fd87eee6b1d54
  // This f***ing toolbar has almost got me!
  // A bit of explanation: without the following line loading toolbar when
  // window is show results in unpredictable buttons placed on toolbar
  ToolBar.Perform(CM_RECREATEWND, 0, 0);
end;

procedure THistoryFrm.LoadToolbarIcons;
var
  il: HIMAGELIST;
  ii: Integer;
begin
  try
    ImageList_Remove(ilToolbar.Handle,-1); // clears image list
    il := ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,10,2);
    if il <> 0 then
      ilToolbar.Handle := il
    else
      il := ilToolbar.Handle;
    Toolbar.Images := ilToolbar;

    // add other icons without processing
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_CONTACDETAILS].Handle);
    tbUserDetails.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_CONTACTMENU].Handle);
    tbUserMenu.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_HOTFILTER].Handle);
    tbFilter.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_HOTSEARCH].Handle);
    tbSearch.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_DELETE].Handle);
    tbDelete.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_SESSIONS].Handle);
    tbSessions.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_SAVE].Handle);
    tbSave.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_TOOL_COPY].Handle);
    tbCopy.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_GLOBALSEARCH].Handle);
    tbHistorySearch.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_BOOKMARK].Handle);
    tbBookmarks.ImageIndex := ii;
    ii := ImageList_AddIcon(il,hppIcons[HPP_ICON_CONTACTHISTORY].Handle);
    tbHistory.ImageIndex := ii;

    LoadEventFilterButton;
  finally
  end;
end;

procedure THistoryFrm.SavePosition;
//save position and filter setting
var
  SearchModeForSave: TSearchMode;
begin
  Utils_SaveFormPosition(Self,0,hppDBName,'HistoryWindow.');
  // use MagneticWindows.dll
  PluginLink.CallService(MS_MW_REMWINDOW,WindowHandle,0);

  if (not PasswordMode) and (HistoryLength > 0) then begin
    if hContact = 0 then begin
      WriteDBBool(hppDBName,'ShowBookmarksSystem',paBook.Visible);
      if paBook.Visible then
        WriteDBInt(hppDBName,'PanelWidth',paBook.Width);
    end else begin
      WriteDBBool(hppDBName,'ShowSessions',paSess.Visible);
      WriteDBBool(hppDBName,'ShowBookmarks',paBook.Visible);
      if paHolder.Visible then
        WriteDBInt(hppDBName,'PanelWidth',paHolder.Width);
      if spBook.Visible then
        WriteDBByte(hppDBName,'PanelSplit',spBook.Tag);
    end;
  end;

  if hContact <> 0 then
    WriteDBBool(hppDBName,'ExpandHeaders',hg.ExpandHeaders);
  if SearchMode = smHotSearch then
    SearchModeForSave := PreHotSearchMode
  else
    SearchModeForSave := SearchMode;
  WriteDBByte(hppDBName,'SearchMode',Byte(SearchModeForSave));
end;

procedure THistoryFrm.HMEventAdded(var Message: TMessage);
//new message added to history (wparam=hcontact, lparam=hdbevent)
begin
  //if for this contact
  if Cardinal(message.wParam)=hContact then begin
    //receive message from database
    AddHistoryItem(message.lParam);
    hgState(hg,hg.State);
  end;
end;

procedure THistoryFrm.HMEventDeleted(var Message: TMessage);
var
  i: Integer;
begin
  {wParam - hContact; lParam - hDBEvent}
  if hg.State = gsDelete then exit;
  if Cardinal(message.wParam) <> hContact then exit;
  for i := 0 to hg.Count - 1 do
    if (History[GridIndexToHistory(i)] = Cardinal(Message.lParam)) then begin
      hg.Delete(i);
      hgState(hg,hg.State);
      exit;
    end;
end;

procedure THistoryFrm.HMFiltersChanged(var M: TMessage);
begin
  CreateEventsFilterMenu;
  SetEventFilter(0);
end;

procedure THistoryFrm.HMIcons2Changed(var M: TMessage);
begin
  Icon.Handle := CopyIcon(hppIcons[HPP_ICON_CONTACTHISTORY].handle);
  LoadToolbarIcons;
  LoadButtonIcons;
  LoadSessionIcons;
  LoadBookIcons;
  pbFilter.Repaint;
  //hg.Repaint;
end;

procedure THistoryFrm.HMAccChanged(var M: TMessage);
begin
  ToggleMainMenu(Boolean(M.WParam));
end;

procedure THistoryFrm.HMBookmarkChanged(var M: TMessage);
var
  i: integer;
begin
  if Cardinal(M.WParam) <> hContact then exit;
  for i := 0 to hg.Count-1 do
    if History[GridIndexToHistory(i)] = Cardinal(M.LParam) then begin
      hg.Bookmarked[i] := BookmarkServer[hContact].Bookmarked[M.LParam];
      break;
    end;
  FillBookmarks;
end;

procedure THistoryFrm.HMPreShutdown(var Message: TMessage);
begin
  Close;
end;

procedure THistoryFrm.HMContactDeleted(var Message: TMessage);
begin
  if Cardinal(Message.wParam) <> hContact then exit;
  Close;
end;

procedure THistoryFrm.HMToolbarChanged(var M: TMessage);
begin
  LoadToolbar;
end;

procedure THistoryFrm.HMNickChanged(var M: TMessage);
begin
  if SubProtocol = '' then exit;
  hg.BeginUpdate;
  if M.WParam = 0 then
    hg.ProfileName := GetContactDisplayName(0, SubProtocol)
  else
  if Cardinal(M.WParam) = hContact then begin
    hg.ProfileName := GetContactDisplayName(0, SubProtocol);
    hg.ContactName := GetContactDisplayName(hContact, Protocol, True);
    Caption := WideFormat(TranslateWideW('%s - History++'),[hg.ContactName]);
  end;
  hg.EndUpdate;
  hg.Invalidate;
  if Assigned(EventDetailForm) then
    TEventDetailsFrm(EventDetailForm).ResetItem;
end;

procedure THistoryFrm.HMMetaDefaultChanged(var M: TMessage);
var
  newSubContact: THandle;
  newSubProtocol: String;
begin
  if Cardinal(M.WParam) <> hContact then exit;
  GetContactProto(hContact,newSubContact,newSubProtocol);
  if (hSubContact <> newSubContact) or (SubProtocol <> newSubProtocol) then begin
    hg.BeginUpdate;
    FhSubContact := newSubContact;
    FSubProtocol := newSubProtocol;
    hg.ProfileName := GetContactDisplayName(0, newSubProtocol);
    hg.ContactName := GetContactDisplayName(hContact, Protocol, True);
    Caption := WideFormat(TranslateWideW('%s - History++'),[hg.ContactName]);
    hg.EndUpdate;
    hg.Invalidate;
    if Assigned(EventDetailForm) then
      TEventDetailsFrm(EventDetailForm).ResetItem;
  end;
end;

{Unfortunatly when you make a form from a dll this form won't become the
normal messages specified by the VCL but only the basic windows messages.
Therefore neither tabs nor button shortcuts work on this form. As a workaround
i've make some functions:}

procedure THistoryFrm.OnCNChar(var Message: TWMChar);
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

procedure THistoryFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Mask: Integer;
begin
  if (Key = VK_ESCAPE) or ((Key = VK_F4) and (ssAlt in Shift)) then begin
    if (Key = VK_ESCAPE) and edSearch.Focused then
      SearchMode := smNone else
      close;
    Key := 0;
    exit;
  end;

  if (Key = VK_F10) and (Shift=[]) and (not PasswordMode) then begin
    WriteDBBool(hppDBName,'Accessability', true);
    NotifyAllForms(HM_NOTF_ACCCHANGED,DWord(True),0);
    Key := 0;
    exit;
  end;

  if (key = VK_F3) and ((Shift=[]) or (Shift=[ssShift])) and (not PasswordMode) and (SearchMode in [smSearch,smHotSearch]) then begin
    if ssShift in Shift then
      sbSearchPrev.Click else
      sbSearchNext.Click;
    key := 0;
  end;

  // let only search keys be accepted if inline
  if hg.State = gsInline then exit;

  if not PasswordMode then begin
    if IsFormShortCut([mmAcc],Key,Shift) then begin
      Key := 0;
      exit;
    end;
  end;

  with Sender as TWinControl do begin
    if Perform(CM_CHILDKEY, Key, LPARAM(Sender)) <> 0 then Exit;
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
        and (Perform(CM_DIALOGKEY, Key, 0) <> 0)
        then Exit;
    end;
end;

procedure THistoryFrm.FillBookmarks;
var
  li: TTntListItem;
  cb: TContactBookmarks;
  i: Integer;
  hi: THistoryItem;
  hDBEvent: THandle;
  txt: WideString;
begin
  lvBook.Items.BeginUpdate;
  try
    lvBook.Items.Clear;
    // prefetch contact bookmarks object so we don't seek for it every time
    cb := BookmarkServer[hContact];
    for i := 0 to cb.Count-1 do begin
      li := lvBook.Items.Add;
      hDBEvent := cb.Items[i];
      txt := cb.Names[i];
      if txt = '' then begin
        hi := ReadEvent(hDBEvent,UserCodepage);
        txt := Copy(hi.Text,1,100);
        txt := Tnt_WideStringReplace(txt,#13#10,' ',[rfReplaceAll]);
        // without freeing Module string mem manager complains about memory leak! WTF???
        Finalize(hi);
        //hi.Module := '';
        //hi.Proto := '';
        //hi.Text := '';
      end;
      // compress spaces here!
      li.Caption := txt;
      li.Data := Pointer(hDBEvent);
      li.ImageIndex := 0;
    end;
  finally
    lvBook.Items.EndUpdate;
  end;
end;

procedure THistoryFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    Action:=caFree;
    if Assigned(WindowList) then begin
      if WindowList.Count = 1 then begin
        // we are the last left
        if Assigned(PassCheckFm) then
          FreeAndNil(PassCheckFm);
        if Assigned(PassFm) then
          FreeAndNil(PassFm);
        end;
      WindowList.Delete(WindowList.IndexOf(Self));
      //Windows.ShowCaret(Handle);
      //Windows.ShowCursor(True);
    end;
    SavePosition;
  except
  end;
end;

procedure THistoryFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Flag: UINT;
  AppSysMenu: THandle;
begin
  CanClose := (hg.State in [gsIdle,gsInline]);
  if CanClose and IsLoadingSessions then begin
    // disable close button
    AppSysMenu := GetSystemMenu(Handle,False);
    Flag := MF_GRAYED;
    EnableMenuItem(AppSysMenu,SC_CLOSE,MF_BYCOMMAND or Flag);
    sb.SimpleText := TranslateWideW('Please wait while closing the window...');
    // terminate thread
    SessThread.Terminate(tpHigher);
    repeat
      Application.ProcessMessages
    until not IsLoadingSessions;
  end;
  if CanClose and Assigned(SessThread) then
    FreeAndNil(SessThread);
end;

procedure THistoryFrm.Load;
begin
  PreLoadHistory;
  LoadHistory(Self);
  PostLoadHistory;
end;

procedure THistoryFrm.LoadAccMenu;
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
    end else begin
      menuitem := TTntMenuItem.Create(Toolbar.Buttons[i]);
      wstr := Toolbar.Buttons[i].Caption;
      if wstr = '' then wstr := Toolbar.Buttons[i].Hint;
      if wstr <> '' then begin
        pm := TTntPopupMenu(Toolbar.Buttons[i].PopupMenu);
        if pm = nil then
          menuitem.OnClick := Toolbar.Buttons[i].OnClick
        else begin
          menuitem.Tag := Integer(Pointer(pm));
        end;
        menuitem.Caption := wstr;
        menuitem.ShortCut := WideTextToShortCut(Toolbar.Buttons[i].HelpKeyword);
        menuitem.Enabled := Toolbar.Buttons[i].Enabled;
        menuitem.Visible := Toolbar.Buttons[i].Visible;
      end;
    end;
    mmToolbar.Insert(0,menuitem);
  end;
  mmToolbar.RethinkHotkeys;
end;

var
  SearchUpHint: WideString = 'Search Up (Ctrl+Up)';
  SearchDownHint: WideString = 'Search Down (Ctrl+Down)';

procedure THistoryFrm.LoadBookIcons;
var
  il: THandle;
begin
  lvBook.Items.BeginUpdate;
  try
    ImageList_Remove(ilBook.Handle,-1); // clears image list
    il := ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,8,2);
    if il <> 0 then
      ilBook.Handle := il
    else
      il := ilBook.Handle;

    ImageList_AddIcon(il,hppIcons[HPP_ICON_BOOKMARK_ON].handle);
  finally
    lvBook.Items.EndUpdate;
  end;
  // simple hack to avoid dark icons
  ilBook.BkColor := lvBook.Color;
end;

procedure THistoryFrm.LoadButtonIcons;
var
  previc: HICON;
  nextic: HICON;
  //prev_hint, next_hint: WideString;
begin
  if hg.Reversed then begin
    nextic := hppIcons[HPP_ICON_SEARCHUP].Handle;
    previc := hppIcons[HPP_ICON_SEARCHDOWN].Handle;
    sbSearchNext.Hint := SearchUpHint;
    sbSearchPrev.Hint := SearchDownHint;
  end
  else begin
    nextic := hppIcons[HPP_ICON_SEARCHDOWN].Handle;
    previc := hppIcons[HPP_ICON_SEARCHUP].Handle;
    sbSearchNext.Hint := SearchDownHint;
    sbSearchPrev.Hint := SearchUpHint;
  end;

  with sbSearchPrev.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      previc,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with sbSearchNext.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      nextic,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with sbClearFilter.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      hppIcons[HPP_ICON_HOTFILTERCLEAR].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with sbCloseSess.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      hppIcons[HPP_ICON_SESS_HIDE].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;
  with sbCloseBook.Glyph do begin
    Width := 16;
    Height := 16;
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(Canvas.ClipRect);
    DrawiconEx(Canvas.Handle,0,0,
      hppIcons[HPP_ICON_SESS_HIDE].Handle,16,16,0,Canvas.Brush.Handle,DI_NORMAL);
  end;

  imSearchNotFound.Picture.Icon.Handle := CopyIcon(hppIcons[HPP_ICON_SEARCH_NOTFOUND].handle);
  imSearchEndOfPage.Picture.Icon.Handle := CopyIcon(hppIcons[HPP_ICON_SEARCH_ENDOFPAGE].handle);
end;

procedure THistoryFrm.LoadEventFilterButton;
var
  pad: DWord;
  PadV, PadH, GlyphHeight: Integer;
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
  tbEventsFilter.Glyph.Canvas.Brush.Color := clBtnFace;
  tbEventsFilter.Glyph.Canvas.FillRect(tbEventsFilter.Glyph.Canvas.ClipRect);
  DrawIconEx(tbEventsFilter.Glyph.Canvas.Handle,sz.cx+tbEventsFilter.Spacing,((GlyphHeight-16) div 2),
            hppIcons[HPP_ICON_DROPDOWNARROW].Handle,16,16,
            0,tbEventsFilter.Glyph.Canvas.Brush.Handle,DI_NORMAL);
  DrawState(tbEventsFilter.Glyph.Canvas.Handle,0,nil,
            Integer(hppIcons[HPP_ICON_DROPDOWNARROW].Handle),0,
            sz.cx+tbEventsFilter.Spacing+GlyphWidth,((GlyphHeight-16) div 2),0,0,
            DST_ICON or DSS_DISABLED);

  tbEventsFilter.Glyph.Canvas.Brush.Style := bsClear;
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

procedure THistoryFrm.LoadPendingHeaders(rowidx: integer; count: integer);
//reads hDBEvents from the database until this row (begin from end which was loaded at the startup)
// 2006.02.13 reads a windows with rowidx at center. Prefeching
var
  //startrowidx: integer;
  fromRow,tillRow: integer;
  fromRowIdx,tillRowIdx: integer;
  ridx: integer;
  hDBEvent: THandle;
begin
  if History[rowidx] <> 0 then Exit;
  {$IFDEF DEBUG}
  OutPutDebugString(PChar('Loading pending headers = '+intToStr(rowidx)));
  {$ENDIF}
  Screen.Cursor:=crHourGlass;
  try
    fromRow := rowidx + hppLoadBlock shr 1;
    if fromRow > HistoryLength-1 then fromRow := HistoryLength-1;
    fromRowIdx := rowidx;
    repeat
      Inc(fromRowIdx)
    until (fromRowIdx > HistoryLength-1) or (History[fromRowIdx] <> 0);

    tillRow := rowidx - hppLoadBlock shr 1;
    if tillRow < 0 then tillRow := 0;
    tillRowIdx := rowidx;
    repeat
      Dec(tillRowIdx)
    until (tillRowIdx < 0) or (History[tillRowIdx] <> 0);

    if fromRowIdx-rowidx < rowidx-tillRowIdx then begin
      if fromRowIdx > HistoryLength-1 then begin
        fromRowIdx := HistoryLength-1;
        hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDLAST,hContact,0);
        history[fromRowIdx] := hDBEvent;
      end else
        hDBEvent:=history[fromRowIdx];
      for ridx := fromRowIdx-1 downto tillRow do begin
        if history[ridx] <> 0 then break;
        hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDbEvent,0);
        history[ridx] := NotZero(hDbEvent);
      end;
    end else begin
      if tillRowIdx < 0 then begin
        tillRowIdx := 0;
        hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDFIRST,hContact,0);
        history[tillRowIdx] := hDBEvent;
      end else
        hDBEvent:=history[tillRowIdx];
      for ridx := tillRowIdx+1 to fromRow do begin
        if history[ridx] <> 0 then break;
        hDbEvent:=PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDbEvent,0);
        history[ridx] := NotZero(hDbEvent);
      end;
    end;
    {$IFDEF DEBUG}
    OutPutDebugString(PChar('... pending headers from '+intToStr(FromRow)+' to '+intToStr(tillRow)));
    {$ENDIF}
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure THistoryFrm.FormDestroy(Sender: TObject);
begin
  // this is the only event fired when history is open
  // and miranda is closed
  // (added: except now I added ME_SYSTEM_PRESHUTDOWN hook, which should work)
  if Assigned(CustomizeToolbarForm) then
    CustomizeToolbarForm.Release;
  if Assigned(CustomizeFiltersForm) then
    CustomizeFiltersForm.Release;
  if Assigned(EventDetailForm) then
    EventDetailForm.Release;
end;

procedure THistoryFrm.DeleteHistoryItem(ItemIdx: Integer);
//history[itemidx] löschen (also row-1)
//var
//  p: integer;
begin
  //for p:=ItemIdx to HistoryLength-2 do
  //  History[p]:=history[p+1];
  Dec(HistoryLength);
  if ItemIdx <> HistoryLength then begin
    Move(History[ItemIdx+1],History[ItemIdx],(HistoryLength-ItemIdx)*SizeOf(History[0]));
    // reset has_header and linked_to_pervous_messages fields
    hg.ResetItem(HistoryIndexToGrid(ItemIdx));
  end;
  SetLength(history,HistoryLength);
end;

procedure THistoryFrm.AddEventToSessions(hDBEvent: THandle);
var
  ts: DWord;
  dt: TDateTime;
  idx: Integer;
  year,month,day: TTntTreeNode;
  AddNewSession: Boolean;
begin
  ts := GetEventTimestamp(hDBEvent);
  AddNewSession := True;
  if Length(Sessions) > 0 then begin
    idx := High(Sessions);
    if (ts - Sessions[idx].TimestampLast) <= SESSION_TIMEDIFF then begin
      Sessions[idx].hDBEventLast := hDBEvent;
      Sessions[idx].TimestampLast := ts;
      Inc(Sessions[idx].ItemsCount);
      AddNewSession := False;
    end;
  end;
  if AddNewSession then begin
    idx := Length(Sessions);
    SetLength(Sessions,idx+1);
    Sessions[idx].hDBEventFirst := hDBEvent;
    Sessions[idx].TimestampFirst := ts;
    Sessions[idx].hDBEventLast := Sessions[idx].hDBEventFirst;
    Sessions[idx].TimestampLast := Sessions[idx].TimestampFirst;
    Sessions[idx].ItemsCount := 1;
    dt := TimestampToDateTime(ts);
    year := nil;
    if tvSess.Items.GetFirstNode <> nil then begin
      year := tvSess.Items.GetFirstNode;
      while year.getNextSibling <> nil do
        year := year.getNextSibling;
      if Integer(year.Data) <> YearOf(dt) then year := nil;
    end;
    if year = nil then begin
      year := tvSess.Items.AddChild(nil,WideFormatDateTime(HPP_SESS_YEARFORMAT,dt));
      year.Data := Pointer(YearOf(dt));
      year.ImageIndex := 5;
      //year.SelectedIndex := year.ImageIndex;
    end;
    month := nil;
    if year.GetLastChild <> nil then begin
      month := year.GetLastChild;
      if Integer(month.Data) <> MonthOf(dt) then month := nil;
    end;
    if month = nil then begin
      month := tvSess.Items.AddChild(year,WideFormatDateTime(HPP_SESS_MONTHFORMAT,dt));
      month.Data := Pointer(MonthOf(dt));
      case MonthOf(dt) of
        12,1..2: month.ImageIndex := 3;
        3..5: month.ImageIndex := 4;
        6..8: month.ImageIndex := 1;
        9..11: month.ImageIndex := 2;
      end;
      //month.SelectedIndex := month.ImageIndex;
    end;
    day := tvSess.Items.AddChild(month,WideFormatDateTime(HPP_SESS_DAYFORMAT,dt));
    day.Data := Pointer(idx);
    day.ImageIndex := 0;
    //day.SelectedIndex := day.ImageIndex;
  end;
end;

procedure THistoryFrm.AddHistoryItem(hDBEvent:THandle);
//only add single lines, not whole histories, because this routine is pretty
//slow
begin
  Inc(HistoryLength);
  SetLength(History,HistoryLength);
  History[HistoryLength-1] := hDBEvent;
  hg.AddItem;
  if HistoryLength = 1 then
    if GetDBBool(hppDBName,'ShowSessions',False) and not (hpSessions in Panel) then
      Panel := Panel + [hpSessions];
end;

procedure THistoryFrm.hgItemData(Sender: TObject; Index: Integer; var Item: THistoryItem);
var
  PrevTimestamp: DWord;
  PrevMessageType: TMessageTypes;
  HistoryIndex: Integer;
begin
  HistoryIndex := GridIndexToHistory(Index);
  Item := GetItemData(HistoryIndex);
  if hContact = 0 then
    Item.Proto := Item.Module else
    Item.Proto := Protocol;
  Item.Bookmarked := BookmarkServer[hContact].Bookmarked[History[HistoryIndex]];
  if HistoryIndex = 0 then
    Item.HasHeader := IsEventInSession(Item.EventType)
  else begin
    if History[HistoryIndex-1] = 0 then
      LoadPendingHeaders(HistoryIndex-1,HistoryLength);
    PrevTimestamp := GetEventTimestamp(History[HistoryIndex-1]);
    if IsEventInSession(Item.EventType) then
      Item.HasHeader := ((DWord(Item.Time) - PrevTimestamp) > SESSION_TIMEDIFF);
    if not Item.Bookmarked then begin
      PrevMessageType := GetEventMessageType(History[HistoryIndex-1]);
      if Item.MessageType = PrevMessageType then
        Item.LinkedToPrev := ((DWord(Item.Time) - PrevTimestamp) < 60);
    end;
  end;
end;

procedure THistoryFrm.hgTranslateTime(Sender: TObject; Time: Cardinal; var Text: WideString);
begin
  Text := TimestampToString(Time);
end;

procedure THistoryFrm.hgPopup(Sender: TObject);
begin
  SpeakMessage1.Visible := MeSpeakEnabled;
  Delete1.Visible := False;
  SaveSelected1.Visible := False;
  if hContact = 0 then begin
    SendMessage1.Visible := False;
    ReplyQuoted1.Visible := False;
  end;
  if hg.Selected <> -1 then begin
    Delete1.Visible := True;
    if GridOptions.OpenDetailsMode then
      Details1.Caption := TranslateWideW('&Pseudo-edit') else
      Details1.Caption := TranslateWideW('&Open');
    SaveSelected1.Visible := (hg.SelCount > 1);
    FileActions.Visible := isFileEvent(hg.Selected);
    if FileActions.Visible then
      OpenFileFolder.Visible := (SavedFileDir <> '');
    pmGrid.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
  end;
end;

procedure THistoryFrm.hgSearchFinished(Sender: TObject; Text: WideString; Found: Boolean);
var
  t: WideString;
begin
  if LastSearch <> lsHotSearch then
    LastHotIdx := hg.Selected;
  LastSearch := lsHotSearch;
  if Text = '' then begin
    if (LastHotIdx <> -1) and (HotString <> '') then
      hg.Selected := LastHotIdx;
    LastSearch := lsNone;
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
  sb.SimpleText := WideFormat(TranslateWideW('HotSearch: %s (F3 to find next)'),[t]);
  //if Found then HotString := Text;
end;

procedure THistoryFrm.hgBookmarkClick(Sender: TObject; Item: Integer);
var
  val: boolean;
  hDBEvent: THandle;
begin
  hDBEvent := History[GridIndexToHistory(Item)];
  val := not BookmarkServer[hContact].Bookmarked[hDBEvent];
  BookmarkServer[hContact].Bookmarked[hDBEvent] := val;
end;

procedure THistoryFrm.hgChar(Sender: TObject; var Char: WideChar; Shift: TShiftState);
var
  Mes: TWMChar;
begin
  if SearchMode = smNone then SearchMode := smSearch;
  edSearch.SetFocus;
  edSearch.SelStart := Length(edSearch.Text);
  edSearch.SelLength := 0;
  //edSearch.Text := Char;
  ZeroMemory(@Mes,SizeOf(Mes));
  Mes.Msg := WM_CHAR;
  Mes.CharCode := Word(Char);
  Mes.KeyData := ShiftStateToKeyData(Shift);
  edSearch.Perform(WM_CHAR,TMessage(Mes).WParam,TMessage(Mes).LParam);
  Char := #0;
end;

procedure THistoryFrm.hgDblClick(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  if GridOptions.OpenDetailsMode then
    OpenDetails(hg.Selected)
  else
    hg.EditInline(hg.Selected);
end;

procedure THistoryFrm.tbSaveClick(Sender: TObject);
var
  t: String;
  SaveFormat: TSaveFormat;
begin
  if hg.Selected = -1 then exit;
  RecentFormat := TSaveFormat(GetDBInt(hppDBName,'ExportFormat',0));
  SaveFormat := RecentFormat;
  PrepareSaveDialog(SaveDialog,SaveFormat,True);
  t := Translate('Partial History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  //t := t + SaveDialog.DefaultExt;
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
// why SaveDialog.FileName shows '' here???
// who knows? In debugger FFileName shows right file, but
// FileName property returns ''
  for SaveFormat := High(SaveFormats) downto Low(SaveFormats) do
    if SaveDialog.FilterIndex = SaveFormats[SaveFormat].Index then
      break;
  if SaveFormat <> sfAll then RecentFormat := SaveFormat;
  //hg.SaveSelected(SaveDialog.FileName,RecentFormat);
  hg.SaveSelected(SaveDialog.Files[0],RecentFormat);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.sbCloseBookClick(Sender: TObject);
begin
  Panel := Panel - [hpBookmarks]
end;

procedure THistoryFrm.sbCloseSessClick(Sender: TObject);
begin
  Panel := Panel - [hpSessions]
end;

procedure THistoryFrm.sbSearchNextClick(Sender: TObject);
begin
  Search(True,True);
end;

procedure THistoryFrm.sbSearchPrevClick(Sender: TObject);
begin
  Search(False,True);
end;

procedure THistoryFrm.hgItemDelete(Sender: TObject; Index: Integer);
var
  idx: Integer;
  hDBEvent: DWord;
begin
  if Index = -1 then begin // routine is called from DeleteAll
    if FormState = gsDelete then begin // probably unnecessary considering prev check
      hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDFIRST,hContact,0);
      PluginLink.CallService(MS_DB_EVENT_DELETE,hContact,LPARAM(hDBEvent));
    end;
  end
  else begin
    idx := GridIndexToHistory(Index);
    if (FormState = gsDelete) and (History[idx] <> 0) then
      PluginLink.CallService(MS_DB_EVENT_DELETE,hContact,History[idx]);
    DeleteEventFromSessions(idx);
    DeleteHistoryItem(idx);
  end;
  hgState(hg,hg.State);
  Application.ProcessMessages;
end;

procedure THistoryFrm.hgItemFilter(Sender: TObject; Index: Integer; var Show: Boolean);
begin

  // if we have string filter
  if HotFilterString <> '' then begin
    if Pos(WideUpperCase(HotFilterString),WideUpperCase(hg.Items[Index].Text)) = 0 then
      Show := False;
    exit;
  end;

  // if filter by sessions disabled, then exit
  if StartTimestamp <> 0 then begin
    //Show := False;
    if hg.Items[Index].Time >= StartTimestamp then begin
      if EndTimestamp = 0 then exit
      else begin
        if hg.Items[Index].Time < EndTimestamp then exit
        else Show := False;
      end;
    end else Show := False;
  end;
end;

procedure THistoryFrm.tbDeleteClick(Sender: TObject);
begin
  if hg.SelCount = 0 then exit;
  if hg.SelCount > 1 then begin
    if HppMessageBox(Handle,WideFormat(
      TranslateWideW('Do you really want to delete selected items (%.0f)?'),[hg.SelCount/1]),
      TranslateWideW('Delete Selected'),
      MB_YESNOCANCEL or MB_DEFBUTTON1 or MB_ICONQUESTION) <> IDYES then exit;
  end else begin
    if HppMessageBox(Handle,
      TranslateWideW('Do you really want to delete selected item?'),
      TranslateWideW('Delete'),
      MB_YESNOCANCEL or MB_DEFBUTTON1 or MB_ICONQUESTION) <> IDYES then exit;
  end;

  if hg.SelCount = hg.Count then
    EmptyHistory
  else begin
    SetSafetyMode(False);
    try
      FormState := gsDelete;
      hg.DeleteSelected;
    finally
      FormState := gsIdle;
      SetSafetyMode(True);
    end;
  end;
end;

function THistoryFrm.GridIndexToHistory(Index: Integer): Integer;
begin
  Result := HistoryLength-1-Index;
end;

function THistoryFrm.HistoryIndexToGrid(Index: Integer): Integer;
begin
  Result := HistoryLength-1-Index;
end;

procedure THistoryFrm.mmHideMenuClick(Sender: TObject);
begin
  WriteDBBool(hppDBName,'Accessability', False);
  NotifyAllForms(HM_NOTF_ACCCHANGED,DWord(False),0);
end;

procedure THistoryFrm.tbCopyClick(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  CopyToClip(hg.FormatSelected(GridOptions.ClipCopyFormat),Handle,UserCodePage);
end;

procedure THistoryFrm.Details1Click(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  if GridOptions.OpenDetailsMode then
    hg.EditInline(hg.Selected)
  else
    OpenDetails(hg.Selected);
end;

procedure THistoryFrm.OpenDetails(Item: Integer);
begin
  if not Assigned(EventDetailForm) then begin
    EventDetailForm:=TEventDetailsFrm.Create(Self);
    TEventDetailsFrm(EventDetailForm).ParentForm := Self;
    TEventDetailsFrm(EventDetailForm).Item := Item;
    TEventDetailsFrm(EventDetailForm).Show;
  end else begin
    TEventDetailsFrm(EventDetailForm).Item:=Item;
    TEventDetailsFrm(EventDetailForm).Show;
  end;
end;

function THistoryFrm.GetItemData(Index: Integer): THistoryItem;
var
  hDBEvent:DWord;
begin
  hDBEvent := History[Index];
  if hDBEvent=0 then begin
    LoadPendingHeaders(Index,HistoryLength);
    hDBEvent:=history[Index];
    if hDBEvent=0 then
      raise EAbort.Create('can''t load event');
  end;
  Result := ReadEvent(hDBEvent,UserCodepage);
  {$IFDEF DEBUG}
  OutPutDebugString(PChar('Get item data from DB '+intToStr(Index)+' #'+intToStr(hDBEvent)));
  {$ENDIF}
end;

var
  WasReturnPressed: Boolean = False;

procedure THistoryFrm.hgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  pm: TPopupMenu;
begin
  if hg.State = gsInline then
    pm := pmInline else
    pm := pmGrid;

  if IsFormShortCut([pm],Key,Shift) then begin
    Key := 0;
    exit;
  end;

  WasReturnPressed := (Key = VK_RETURN);
end;

procedure THistoryFrm.hgState(Sender: TObject; State: TGridState);
var
  t: WideString;
begin
  if csDestroying in ComponentState then exit;
  case State of
    gsIdle:   t := WideFormat(TranslateWideW('%.0n items in history'),[HistoryLength/1]);
    gsLoad:   t := TranslateWideW('Loading...');
    gsSave:   t := TranslateWideW('Saving...');
    gsSearch: t := TranslateWideW('Searching...');
    gsDelete: t := TranslateWideW('Deleting...');
    gsInline: t := TranslateWideW('Pseudo-edit mode...');
  end;
  if PasswordMode then
    t := '';
  sb.SimpleText := t;
end;

procedure THistoryFrm.DeleteEventFromSessions(ItemIdx: Integer);
var
  ts: DWord;
  dt: TDateTime;
  year,month,day: TTntTreeNode;
  i,idx: Integer;
  hDBEvent: THandle;
begin
  hDBEvent := History[ItemIdx];
  ts := GetEventTimestamp(hDBEvent);

  // find idx in sessions array
  idx := -1;
  for i := Length(Sessions) - 1 downto 0 do
    if (ts >= Sessions[i].TimestampFirst) and (ts <= Sessions[i].TimestampLast) then begin
      idx := i;
      break;
    end;
  if idx = -1 then exit;

  Dec(Sessions[idx].ItemsCount);

  // if the event is not first, we can do it faster
  if Sessions[idx].hDBEventFirst <> hDBEvent then begin
    if Sessions[idx].hDBEventLast = hDBEvent then begin
      hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDPREV,hDBEvent,0);
      if hDBEvent <> 0 then begin
        Sessions[idx].hDBEventLast := hDBEvent;
        Sessions[idx].TimestampLast := GetEventTimestamp(hDBEvent);
      end
      else begin //????
        Sessions[idx].hDBEventLast := Sessions[idx].hDBEventFirst;
        Sessions[idx].TimestampLast := Sessions[idx].TimestampFirst;
      end;
    end;
    exit;
  end;

  // now, the even is the first, probably the last in session
  dt := TimestampToDateTime(ts);
  year := tvSess.Items.GetFirstNode;
  while year <> nil do begin
    if Integer(year.data) = YearOf(dt) then
      break;
    year := year.getNextSibling;
  end;
  if year = nil then exit; // ???
  month := year.getFirstChild;
  while month <> nil do begin
    if Integer(month.data) = MonthOf(dt) then
      break;
    month := month.getNextSibling;
  end;
  if month = nil then exit; // ???
  day := month.getFirstChild;
  while day <> nil do begin
    if Integer(day.data) = idx then
      break;
    day := day.getNextSibling;
  end;
  if day = nil then exit; // ???
  if Sessions[idx].ItemsCount = 0 then begin
    day.Delete;
    if month.Count = 0 then
      month.Delete;
    if year.Count = 0 then
      year.Delete;
    // hmm... should we delete record in sessions array?
    // I'll not do it for the speed, I don't think there would be problems
    Sessions[idx].hDBEventFirst := 0;
    Sessions[idx].TimestampFirst := 0;
    Sessions[idx].hDBEventLast := 0;
    Sessions[idx].TimestampLast := 0;
    exit;
  end;
  hDBEvent := PluginLink.CallService(MS_DB_EVENT_FINDNEXT,hDBEvent,0);
  if hDBEvent <> 0 then begin
    Sessions[idx].hDBEventFirst := hDBEvent;
    Sessions[idx].TimestampFirst := GetEventTimestamp(hDBEvent);
  end
  else begin // ????
    Sessions[idx].hDBEventFirst := Sessions[idx].hDBEventLast;
    Sessions[idx].TimestampFirst := Sessions[idx].TimestampLast;
  end;
  ts := Sessions[idx].TimestampFirst;
  dt := TimestampToDateTime(ts);
  day.Text := WideFormatDateTime(HPP_SESS_DAYFORMAT,dt);
  // next item
  //Inc(ItemIdx);
  //if ItemIdx >= HistoryLength then exit;
  //hg.ResetItem(HistoryIndexToGrid(ItemIdx));
end;

procedure THistoryFrm.SaveasHTML2Click(Sender: TObject);
var
  t: String;
begin
  PrepareSaveDialog(SaveDialog,sfHtml);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  RecentFormat := sfHTML;
  hg.SaveAll(SaveDialog.Files[0],sfHTML);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
begin
  inherited;
  with Message.MinMaxInfo^ do begin
    ptMinTrackSize.x:= 320;
    ptMinTrackSize.y:= 240;
  end
end;

procedure THistoryFrm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
if PasswordMode then exit;
Handled := True;
(* we can get range check error (???) here
it looks that without range check it works ok
so turn it off *)
{$RANGECHECKS OFF}
hg.perform(WM_MOUSEWHEEL,MakeLong(MK_CONTROL,WheelDelta),0);
{$RANGECHECKS ON}
end;

procedure THistoryFrm.hgSelect(Sender: TObject; Item, OldItem: Integer);
begin
  tbCopy.Enabled := (Item <> -1);
  tbDelete.Enabled := (Item <> -1);
  tbSave.Enabled := (hg.SelCount > 1);

  if hg.HotString = '' then begin
    LastHotIdx := -1;
    // redraw status bar
    hgState(hg,gsIdle);
  end;
end;

procedure THistoryFrm.Search(Next, FromNext: Boolean);
var
  Down: Boolean;
  item: Integer;
  ShowEndOfPage: Boolean;
  ShowNotFound: Boolean;
begin
  if edSearch.Text = '' then begin
    paSearchStatus.Visible := False;
    edSearch.Color := clWindow;
    exit;
  end;
  if Next then Down := not hg.Reversed
          else Down := hg.Reversed;
  item := hg.Search(edSearch.Text,False,False,False,FromNext,Down);
  ShowEndOfPage := (item = -1);
  if item = -1 then
    item := hg.Search(edSearch.Text,False,True,False,FromNext,Down);
  if item <> -1 then begin
    hg.Selected := item;
    edSearch.Color := clWindow;
    ShowNotFound := False;
  end else begin
    edSearch.Color := $008080FF;
    ShowEndOfPage := False;
    ShowNotFound := True;
  end;
  if ShowNotFound or ShowEndOfPage then begin
    imSearchNotFound.Visible := ShowNotFound;
    imSearchEndOfPage.Visible := ShowEndOfPage;
    if ShowNotFound then
      laSearchState.Caption := TranslateWideW('Phrase not found')
    else if ShowEndOfPage then begin
      if Down then
        laSearchState.Caption := TranslateWideW('Continued from the top')
      else
        laSearchState.Caption := TranslateWideW('Continued from the bottom');
    end;
    paSearchStatus.Width := 22 + laSearchState.Width + 3;
    paSearchStatus.Left := paSearchButtons.Left - paSearchStatus.Width;
    paSearchStatus.Visible := True;
  end else begin
    paSearchStatus.Visible := False;
    //paSearchStatus.Width := 0;
  end;
  //paSearch2.Width := paSearchButtons.Left + paSearchButtons.Width;
end;

procedure THistoryFrm.SearchNext(Rev: Boolean; Warp: Boolean = True);
//var
  //stext,t,tCap: WideString;
  //res: Integer;
  //mcase,down: Boolean;
  //WndHandle: HWND;
begin
  {if LastSearch = lsNone then exit;
  if LastSearch = lsHotSearch then begin
    stext := HotString;
    mcase := False;
  end else begin
    stext := FindDialog.FindText;
    mcase := (frMatchCase in FindDialog.Options);
  end;
  if stext = '' then exit;
  down := not hg.reversed;
  if Rev then Down := not Down;
  res := hg.Search(stext, mcase, not Warp, False, Warp, Down);
  if res <> -1 then begin
    // found
    hg.Selected := res;
    if LastSearch = lsSearch then
      t := TranslateWideW('Search: %s (F3 to find next)')
    else
      t := TranslateWideW('HotSearch: %s (F3 to find next)');
    sb.SimpleText := WideFormat(t,[stext]);
  end else begin
    if (LastSearch = lsSearch) and (FindDialog.Handle <> 0) then
      WndHandle := FindDialog.Handle
    else
      WndHandle := Handle;
    tCap := TranslateWideW('History++ Search');
    // not found
    if Warp and (down = not hg.Reversed) then begin
      // do warp?
      if HppMessageBox(WndHandle,
         TranslateWideW('You have reached the end of the history.')+#10#13+
         TranslateWideW('Do you want to continue searching at the beginning?'),
      tCap, MB_YESNOCANCEL or MB_DEFBUTTON1 or MB_ICONQUESTION) = ID_YES then
        SearchNext(Rev,False);
    end else begin
      // not warped
      hgState(Self,gsIdle);
      // 25.03.03 OXY: FindDialog looses focus when
      // calling ShowMessage, using MessageBox instead
      t := TranslateWideW('"%s" not found');
      HppMessageBox(WndHandle, WideFormat(t,[stext]),tCap, MB_OK or MB_DEFBUTTON1 or 0);
    end;
  end;}
end;

procedure THistoryFrm.ReplyQuoted(Item: Integer);
begin
  if (hContact = 0) or (hg.SelCount = 0) then exit;
  SendMessageTo(hContact,hg.FormatSelected(GridOptions.ReplyQuotedFormat));
end;

procedure THistoryFrm.SaveasXML2Click(Sender: TObject);
var
  t: String;
begin
  PrepareSaveDialog(SaveDialog,sfXML);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  hg.SaveAll(SaveDialog.Files[0],sfXML);
  RecentFormat := sfXML;
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.SaveasText2Click(Sender: TObject);
var
  t: String;
  SaveFormat: TSaveFormat;
begin
  if hppOSUnicode then SaveFormat := sfUnicode
                  else SaveFormat := sfText;
  PrepareSaveDialog(SaveDialog,SaveFormat);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  case SaveDialog.FilterIndex of
    1: SaveFormat := sfUnicode;
    2: SaveFormat := sfText;
  end;
  RecentFormat := SaveFormat;
  hg.SaveAll(SaveDialog.Files[0],SaveFormat);
  //hg.SaveAll(SaveDialog.FileName,SaveFormat);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.hgXMLData(Sender: TObject; Index: Integer; var Item: TXMLItem);
var
  tmp: string;
  dt: TDateTime;
  er: TEventRecord;
  mes: WideString;
begin
  dt := TimestampToDateTime(hg.Items[Index].Time);
  Item.Time := MakeTextXMLedA(FormatDateTime('hh:mm:ss',dt));
  Item.Date := MakeTextXMLedA(FormatDateTime('yyyy-mm-dd',dt));

  Item.Contact := UTF8Encode(MakeTextXMLedW(hg.ContactName));
  if mtIncoming in hg.Items[Index].MessageType then
    Item.From := Item.Contact
  else
    Item.From := '&ME;';

  Item.EventType := '&'+GetEventRecord(hg.Items[Index]).XML+';';

  mes := hg.Items[Index].Text;
  if GridOptions.RawRTFEnabled and IsRTF(mes) then begin
    hg.ApplyItemToRich(Index);
    mes := GetRichString(hg.RichEdit.Handle,False);
  end;
  if GridOptions.BBCodesEnabled then
    mes := DoStripBBCodes(mes);
  Item.Mes := UTF8Encode(MakeTextXMLedW(mes));

  if mtFile in hg.Items[Index].MessageType then begin
    tmp := hg.Items[Index].Extended;
    if tmp = '' then Item.FileName := '&UNK;'
                else Item.FileName := UTF8Encode(MakeTextXMLedA(tmp));
  end else
  if mtUrl in hg.Items[Index].MessageType then begin
    tmp := hg.Items[Index].Extended;
    if tmp = '' then Item.Url := '&UNK;'
                else Item.Url := UTF8Encode(MakeTextXMLedA(tmp));
  end else
  if mtAvatarChange in hg.Items[Index].MessageType then begin
    tmp := hg.Items[Index].Extended;
    if tmp = '' then Item.FileName := '&UNK;'
                else Item.FileName := UTF8Encode(MakeTextXMLedA(tmp));
  end;

  {2.8.2004 OXY: Change protocol guessing order. Now
  first use protocol name, then, if missing, use module }

  Item.Protocol := hg.Items[Index].Proto;
  if Item.Protocol = '' then
    Item.Protocol := MakeTextXMLedA(hg.Items[Index].Module);
  if Item.Protocol = '' then Item.Protocol := '&UNK;';

  if mtIncoming in hg.Items[Index].MessageType then
    Item.ID := GetContactID(hContact, Protocol, true)
  else
    Item.ID := GetContactID(0, SubProtocol);
  if Item.ID = '' then
    Item.ID := '&UNK;'
  else
    Item.ID := MakeTextXMLedA(Item.ID);
end;

procedure THistoryFrm.OpenLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  OpenUrl(SavedLinkUrl,False);
  SavedLinkUrl := '';
end;

procedure THistoryFrm.OpenLinkNWClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  OpenUrl(SavedLinkUrl,True);
  SavedLinkUrl := '';
end;

procedure THistoryFrm.CopyLinkClick(Sender: TObject);
begin
  if SavedLinkUrl = '' then exit;
  CopyToClip(SavedLinkUrl,Handle,CP_ACP);
  SavedLinkUrl := '';
end;

procedure THistoryFrm.SetPanel(const Value: THistoryPanels);
var
  Lock: Boolean;
begin
  FPanel := Value;
  if (HistoryLength = 0) or ((hContact = 0) and (hpSessions in FPanel)) then
    exclude(FPanel,hpSessions);
  tbSessions.Down := (hpSessions in Panel);
  tbBookmarks.Down := (hpBookmarks in Panel);
  hg.BeginUpdate;
  Lock := Visible;
  if Lock then Lock := LockWindowUpdate(Handle);
  try
    //if (FPanel = hpBookmarks) and paSess.Visible then
    //  paBook.Width := paSess.Width;
    //if (FPanel = hpSessions) and paBook.Visible then
    //  paSess.Width := paBook.Width;

    paSess.Visible := (hpSessions in Panel);
    paBook.Visible := (hpBookmarks in Panel);

    paHolder.Visible := paBook.Visible or paSess.Visible;
    spHolder.Visible := paHolder.Visible;
    spHolder.Left    := paHolder.Left + paHolder.Width + 1;

    spBook.Visible := paBook.Visible and paSess.Visible;
    paHolderResize(Self);
    spBook.Top     := paSess.Top + paSess.Height + 1;

  finally
    if Lock then LockWindowUpdate(0);
    hg.EndUpdate;
  end;
end;

procedure THistoryFrm.SetPasswordMode(const Value: Boolean);
var
  enb: Boolean;
begin
  FPasswordMode := Value;
  enb := not Value;
  hgState(hg,hg.State);
  hg.Enabled := enb;
  hg.Visible := enb;
  paClient.Enabled := enb;
  paClient.Visible := enb;

  if Value then paPassHolder.Align := alClient;
  paPassHolder.Enabled := not enb;
  paPassHolder.Visible := not enb;
  if Value then begin
    paPassword.Left := (paPassHolder.ClientWidth-paPassword.Width) div 2;
    paPassword.Top := (paPassHolder.ClientHeight - paPassword.Height) div 2;
    if Self.Visible then
      edPass.SetFocus else
      Self.ActiveControl := edPass;
  end else begin
    ToggleMainMenu(GetDBBool(hppDBName,'Accessability', False));
    // reset selected
    hg.Selected := hg.Selected;
    if Self.Visible then
      hg.SetFocus else
      Self.ActiveControl := hg;
  end;
end;

procedure THistoryFrm.SetRecentEventsPosition(OnTop: Boolean);
begin
  hg.Reversed := not OnTop;
  LoadButtonIcons;
end;

procedure THistoryFrm.SetSearchMode(const Value: TSearchMode);
var
  SaveStr: WideString;
  NotFound,Lock: Boolean;
begin
  if FSearchMode = Value then exit;

  if Value = smHotSearch then PreHotSearchMode := FSearchMode;
  if FSearchMode = smFilter then EndHotFilterTimer(True);

  FSearchMode := Value;

  Lock := Visible;
  if Lock then Lock := LockWindowUpdate(Handle);
  try
    tbFilter.Down := (FSearchMode = smFilter);
    tbSearch.Down := (FSearchMode = smSearch);
    paSearch.Visible := not (SearchMode = smNone);
    if SearchMode = smNone then begin
      edSearch.Text := '';
      edSearch.Color := clWindow;
      if Self.Visible then
        hg.SetFocus
      else
        Self.ActiveControl := hg;
      exit;
    end;
    SaveStr := edSearch.Text;
    hg.BeginUpdate;
    try
      pbSearch.Visible := (FSearchMode in [smSearch,smHotSearch]);
      pbFilter.Visible := (FSearchMode = smFilter);
      if (FSearchMode = smFilter) then paSearchStatus.Visible := False;
      paSearchButtons.Visible := not (FSearchMode = smFilter);
      NotFound := not (edSearch.Color = clWindow);
      edSearch.Text := '';
      edSearch.Color := clWindow;
    finally
      hg.EndUpdate;
    end;
    // don't search or filter if the string is not found
    if not NotFound then
      edSearch.Text := SaveStr;
  finally
    if Lock then LockWindowUpdate(0);
  end;
end;

procedure THistoryFrm.EventsFilterItemClick(Sender: TObject);
begin
  //tbEventsFilter.Caption := TTntMenuItem(Sender).Caption;
  SetEventFilter(TTntMenuItem(Sender).Tag);
end;

procedure THistoryFrm.ShowAllEvents;
begin
  // TODO
  // we run UpdateFilter two times here, one when set
  // Filter property in SetEventFilter, one when reset hot filter
  // make Begin/EndUpdate support batch UpdateFilter requests
  // so we can make it run only one time on EndUpdate
  hg.BeginUpdate;
  SetEventFilter(GetShowAllEventsIndex);
  edSearch.Text := '';
  EndHotFilterTimer(True);
  hg.EndUpdate;
end;

procedure THistoryFrm.ShowItem(Value: Integer);
begin
  hg.MakeTopmost(Value);
  hg.Selected := Value;
end;

procedure THistoryFrm.bnPassClick(Sender: TObject);
begin
if DigToBase(HashString(edPass.Text)) = GetPassword then
  PasswordMode := False
else
  {DONE: sHure}
  hppMessageBox(Handle, TranslateWideW('You have entered the wrong password'),
  TranslateWideW('History++ Password Protection'), MB_OK or MB_DEFBUTTON1 or MB_ICONSTOP);
end;

procedure THistoryFrm.edPassKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
;
end;

procedure THistoryFrm.edSearchChange(Sender: TObject);
begin
  if SearchMode = smFilter then
    StartHotFilterTimer
  else
    Search(True,False);
end;

procedure THistoryFrm.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if SearchMode = smFilter then begin
    if Key in [VK_UP,VK_DOWN,VK_NEXT,VK_PRIOR,VK_END,VK_HOME] then begin
      SendMessage(hg.Handle,WM_KEYDOWN,Key,0);
      Key := 0;
    end;
  end else begin
    if (Shift = []) and (Key in [VK_UP,VK_DOWN,VK_NEXT,VK_PRIOR,VK_END,VK_HOME]) then begin
      SendMessage(hg.Handle,WM_KEYDOWN,Key,0);
      Key := 0;
      exit;
    end;
    if (Shift = [ssCtrl]) and (Key in [VK_UP,VK_DOWN]) then begin
      if (Key = VK_UP) xor hg.Reversed then
        sbSearchNext.Click else
        sbSearchPrev.Click;
      Key := 0;
      exit;
    end;
  end;
end;

procedure THistoryFrm.edSearchKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // to prevent ** BLING ** when press Enter
  if (Key = VK_RETURN) then begin
    if hg.State in [gsIdle,gsInline] then hg.SetFocus;
    key := 0;
  end;
end;

procedure THistoryFrm.edPassKeyPress(Sender: TObject; var Key: Char);
begin
  // to prevent ** BLING ** when press Enter
  // to prevent ** BLING ** when press Tab
  // to prevent ** BLING ** when press Esc
  if Ord(Key) in [VK_RETURN,VK_TAB,VK_ESCAPE] then
    Key := #0;
end;

procedure THistoryFrm.PostLoadHistory;
var
  tPanel: THistoryPanels;
begin
  LoadPosition;
  ProcessPassword;
  if not PasswordMode then
    ToggleMainMenu(GetDBBool(hppDBName,'Accessability', False));

  //if hContact = 0 then paTop.Visible := False;
  // set reversed here, after Allocate, because of some scrollbar
  // "features", we'll load end of the list if put before Allocate
  SetRecentEventsPosition(GetDBBool(hppDBName,'SortOrder',false));
  // set ShowSessions here because we check for empty history
  paHolder.Width := GetDBInt(hppDBName,'PanelWidth',150);
  spBook.Tag := GetDBByte(hppDBName,'PanelSplit',127);
  if hContact = 0 then begin
    if GetDBBool(hppDBName,'ShowBookmarksSystem',False) then
      Panel := [hpBookmarks];
  end else begin
    if GetDBBool(hppDBName,'ShowSessions',False) then
      include(tPanel,hpSessions);
    if GetDBBool(hppDBName,'ShowBookmarks',False) then
      include(tPanel,hpBookmarks);
    Panel := tPanel;
  end;

  CreateEventsFilterMenu;
  // delay event filter applying till showing form
  if hContact = 0 then
    SetEventFilter(GetShowAllEventsIndex,True) else
    SetEventFilter(0,True);
end;

procedure THistoryFrm.PreLoadHistory;
begin
  //LoadPosition;
  hg.ShowHeaders := (hContact <> 0);
  hg.ExpandHeaders := GetDBBool(hppDBName,'ExpandHeaders',False);
  hg.GroupLinked := GetDBBool(hppDBName,'GroupHistoryItems',False);
  if hContact = 0 then begin
    tbUserDetails.Enabled := False;
    tbUserMenu.Enabled := False;
    //tbEventsFilter.Enabled := False;
    tbSessions.Enabled := False;
    //hg.ShowBookmarks := False;
    Customize2.Enabled := False; // disable toolbar customization
  end;

  if tbSessions.Enabled then begin
    SessThread := TSessionsThread.Create(True);
    SessThread.ParentHandle := Handle;
    SessThread.Contact := hContact;
    SessThread.Priority := tpLower;
    SessThread.Resume;
  end;

end;

procedure THistoryFrm.ProcessPassword;
begin
  if IsPasswordBlank(GetPassword) then exit;
  if IsUserProtected(hContact) or isUserProtected(hSubContact) then
    PasswordMode := True;
end;

procedure THistoryFrm.OpenPassword;
begin
  RunPassForm;
end;

procedure THistoryFrm.FormShow(Sender: TObject);
begin
  // EndUpdate is better here, not in PostHistoryLoad, because it's faster
  // when called from OnShow. Don't know why.
  // Other form-modifying routines are better be kept at PostHistoryLoad for
  // speed too.
  hg.EndUpdate;
  LoadToolbar;
  FillBookmarks;
end;

procedure THistoryFrm.mmToolbarClick(Sender: TObject);
var
  i,n: Integer;
  pm: TTntPopupMenu;
  mi: TTntMenuItem;
  flag: Boolean;
begin
  for i := 0 to mmToolbar.Count - 1 do begin
    if mmToolbar.Items[i].Owner is THppToolButton then begin
      flag := TToolButton(mmToolbar.Items[i].Owner).Enabled
    end else
    if mmToolbar.Items[i].Owner is THppSpeedButton then begin
      TTntMenuItem(mmToolbar.Items[i]).Caption := THppSpeedButton(mmToolbar.Items[i].Owner).Hint;
      flag := THppSpeedButton(mmToolbar.Items[i].Owner).Enabled
    end else
      flag := true;
    mmToolbar.Items[i].Enabled := flag;
    if mmToolbar.Items[i].Tag = 0 then continue;
    pm := TTntPopupMenu(Pointer(mmToolbar.Items[i].Tag));
    for n := pm.Items.Count-1 downto 0 do begin
      mi := TTntMenuItem(pm.Items[n]);
      pm.Items.Remove(mi);
      mmToolbar.Items[i].Insert(0,mi);
    end;
  end;
end;

procedure THistoryFrm.ToolbarDblClick(Sender: TObject);
begin
  CustomizeToolbar;
end;

procedure THistoryFrm.paPassHolderResize(Sender: TObject);
begin
  if PasswordMode then begin
    paPassword.Left := (ClientWidth-paPassword.Width) div 2;
    paPassword.Top := (ClientHeight - paPassword.Height) div 2;
  end;
end;

procedure THistoryFrm.Passwordprotection1Click(Sender: TObject);
begin
  OpenPassword;
end;

procedure THistoryFrm.TranslateForm;
begin
  Caption := TranslateWideW(Caption);

  hg.TxtFullLog := TranslateWideW(hg.txtFullLog);
  hg.TxtGenHist1 := TranslateWideW(hg.txtGenHist1);
  hg.TxtGenHist2 := TranslateWideW(hg.txtGenHist2);
  hg.TxtHistExport := TranslateWideW(hg.TxtHistExport);
  hg.TxtNoItems := TranslateWideW(hg.TxtNoItems);
  hg.TxtNoSuch := TranslateWideW(hg.TxtNoSuch);
  hg.TxtPartLog := TranslateWideW(hg.TxtPartLog);
  hg.TxtStartUp := TranslateWideW(hg.TxtStartUp);
  hg.TxtSessions := TranslateWideW(hg.TxtSessions);

  SearchUpHint := TranslateWideW(SearchUpHint);
  SearchDownHint := TranslateWideW(SearchDownHint);

  sbClearFilter.Hint := TranslateWideW(sbClearFilter.Hint);

  bnPass.Caption := TranslateWideW(bnPass.Caption);
  laPass.Caption := TranslateWideW(laPass.Caption);
  laPass2.Caption := TranslateWideW(laPass2.Caption);
  laSess.Caption := TranslateWideW(laSess.Caption);
  laBook.Caption := TranslateWideW(laBook.Caption);

  SaveDialog.Title := Translate(PAnsiChar(SaveDialog.Title));

  TranslateToolbar(Toolbar);

  TranslateMenu(pmGrid.Items);
  TranslateMenu(pmInline.Items);

  TranslateMenu(pmLink.Items);
  TranslateMenu(pmFile.Items);
  TranslateMenu(pmHistory.Items);
  TranslateMenu(pmEventsFilter.Items);
  TranslateMenu(pmSessions.Items);
  TranslateMenu(pmToolbar.Items);
  TranslateMenu(pmBook.Items);
end;

procedure THistoryFrm.tvSessChange(Sender: TObject; Node: TTreeNode);
var
  Index,i: Integer;
  Event: THandle;
begin
  if IsLoadingSessions then exit;
  if Node = nil then exit;
  if Node.Level <> 2 then begin
    Node := Node.getFirstChild;
    if (Node <> nil) and (Node.Level <> 2) then
      Node := Node.getFirstChild;
    if Node = nil then exit;
  end;

  Event := Sessions[DWord(Node.Data)].hDBEventFirst;
  Index := -1;
  // looks like history starts to load from end?
  // well, of course, we load from the last event!
  for i := HistoryLength - 1 downto 0 do begin
    if History[i] = 0 then
      LoadPendingHeaders(i,HistoryLength);
    if History[i] = Event then begin
      Index := i;
      break;
    end;
  end;
  if Index = -1 then exit;
  if hg.State = gsInline then hg.CancelInline;
  Index := HistoryIndexToGrid(Index);
  ShowItem(Index);

  //exit;
  // OXY: try to make selected item the topmost
  //while hg.GetFirstVisible <> Index do begin
  //  if hg.VertScrollBar.Position = hg.VertScrollBar.Range then break;
  //  hg.VertScrollBar.Position := hg.VertScrollBar.Position + 1;
  //end;

  {if Node = nil then begin
    StartTimestamp := 0;
    EndTimestamp := 0;
    hg.GridUpdate([guFilter]);
    exit;
  end;

  if Node.Level <> 2 then exit;

  StartTimestamp := Sessions[DWord(Node.Data)][1];
  EndTimestamp := 0;
  if DWord(Node.Data) <= Length(Sessions)-2 then begin
    EndTimestamp := Sessions[DWord(Node.Data)+1][1];
  end;
  hg.GridUpdate([guFilter]);}
end;

{procedure THistoryFrm.tvSessClick(Sender: TObject);
var
  Node: TTntTreeNode;
begin
  Node := tvSess.Selected;
  if Node = nil then exit;
  //tvSessChange(Self,Node);
end;}

procedure THistoryFrm.tvSessMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Node: TTntTreeNode;
  count,time: DWord;
  t: WideString;
  dt: TDateTime;
  timestr: WideString;
begin
  Node := tvSess.GetNodeAt(x,y);
  if (Node = nil) or (Node.Level <> 2) then begin
    Application.CancelHint;
    tvSess.ShowHint := False;
    exit;
  end;
  if tvSess.Tag <> Integer(Node.Data)+1 then begin
    Application.CancelHint;
    tvSess.ShowHint := False;
    tvSess.Tag := Integer(Node.Data)+1; // +1 because we have tag = 0 by default, and it will not catch first session then
    end;
  //else
  //  exit; // we are already showing the hint for this node

  time := Sessions[DWord(Node.Data)].TimestampLast - Sessions[DWord(Node.Data)].TimestampFirst;
  count := Sessions[DWord(Node.Data)].ItemsCount;

  dt := TimestampToDateTime(Sessions[DWord(Node.Data)].TimestampFirst);
  t := WideFormatDateTime('[yyyy, mmmm, d]',dt)+#13#10;
  if time/60 > 60 then
    timestr := WideFormat('%0.1n h',[time/(60*60)])
  else
    timestr := WideFormat('%d min',[time div 60]);

  if count = 1 then
    tvSess.Hint := t + WideFormat(
      ''+TranslateWideW('%d event'),[count])
  else
    tvSess.Hint := t + WideFormat(
      ''+TranslateWideW('%0.n events (%s)'),[count/1,timestr]);
  tvSess.ShowHint := True;
end;

procedure THistoryFrm.CopyText1Click(Sender: TObject);
begin
  if hg.Selected = -1 then exit;
  CopyToClip(hg.FormatSelected(GridOptions.ClipCopyTextFormat),Handle,UserCodePage);
  // rtf copy works only if not more then one selected
  //hg.ApplyItemToRich(hg.Selected,hg.RichEdit,False);
  //hg.RichEdit.SelectAll;
  //hg.RichEdit.CopyToClipboard;
end;

procedure THistoryFrm.CreateEventsFilterMenu;
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

procedure THistoryFrm.Customize1Click(Sender: TObject);
begin
  if not Assigned(fmCustomizeFilters)  then begin
    CustomizeFiltersForm := TfmCustomizeFilters.Create(Self);
    CustomizeFiltersForm.Show;
  end
  else begin
    BringFormToFront(fmCustomizeFilters);
  end;
end;

procedure THistoryFrm.Customize2Click(Sender: TObject);
begin
  CustomizeToolbar;
end;

procedure THistoryFrm.CustomizeToolbar;
begin
  if hContact = 0 then exit;

  if not Assigned(fmCustomizeToolbar)  then begin
    CustomizeToolbarForm := TfmCustomizeToolbar.Create(Self);
    CustomizeToolbarForm.Show;
  end
  else begin
    BringFormToFront(fmCustomizeToolbar);
  end;
end;

procedure THistoryFrm.hgUrlClick(Sender: TObject; Item: Integer; URLText: WideString; Button: TMouseButton);
begin
  if URLText = '' then exit;
  if (Button = mbLeft) or (Button = mbMiddle) then
    OpenUrl(URLText,True)
  else begin
    SavedLinkUrl := URLText;
    pmLink.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
  end;
end;

procedure THistoryFrm.hgProcessRichText(Sender: TObject; Handle: Cardinal; Item: Integer);
var
  ItemRenderDetails: TItemRenderDetails;
begin
  if Assigned(EventDetailForm) then
    if Handle = TEventDetailsFrm(EventDetailForm).EText.Handle then begin
      TEventDetailsFrm(EventDetailForm).ProcessRichEdit(Item);
      exit;
    end;
  ZeroMemory(@ItemRenderDetails,SizeOf(ItemRenderDetails));
  ItemRenderDetails.cbSize := SizeOf(ItemRenderDetails);
  // use meta's subcontact info, if available
  //ItemRenderDetails.hContact := hContact;
  ItemRenderDetails.hContact := FhSubContact;
  ItemRenderDetails.hDBEvent := History[GridIndexToHistory(Item)];
  // use meta's subcontact info, if available
  if hContact = 0 then
    ItemRenderDetails.pProto := PChar(hg.Items[Item].Proto) else
    ItemRenderDetails.pProto := PChar(FSubProtocol);
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
  if hContact = 0 then
    ItemRenderDetails.bHistoryWindow := IRDHW_GLOBALHISTORY
  else
    ItemRenderDetails.bHistoryWindow := IRDHW_CONTACTHISTORY;
  PluginLink.NotifyEventHooks(hHppRichEditItemProcess,WPARAM(Handle),LPARAM(@ItemRenderDetails));
end;

procedure THistoryFrm.hgSearchItem(Sender: TObject; Item, ID: Integer; var Found: Boolean);
begin
  Found := (Cardinal(ID) = History[GridIndexToHistory(Item)]);
end;

procedure THistoryFrm.hgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // this workaround was done because when we have password and
  // press enter, if password is ok, we a brought to the
  // history grid, and have VK_RETURN onkeyup event. So we have
  // this var to help us. And no, if move this code to OnKeyDown,
  // we will have problems with inline richedit not appearing
  // on enter
  if not WasReturnPressed then exit;
  WasReturnPressed := False;

  if (Key = VK_RETURN) and (Shift = []) then begin
    hgDblClick(hg);
    Key := 0;
    end;
  if (Key = VK_RETURN) and (Shift = [ssCtrl]) then begin
    Details1.Click;
    Key := 0;
  end;
end;

function THistoryFrm.IsFileEvent(Index: Integer): Boolean;
begin
  Result := (Index <> -1) and (mtFile in hg.Items[Index].MessageType);
  if Result then begin
    // Auto CP_ACP usage
    SavedLinkUrl := ExtractFileName(hg.Items[Index].Extended);
    SavedFileDir := ExtractFileDir(hg.Items[Index].Extended);
  end;
end;

procedure THistoryFrm.LoadInOptions();
var
  i: integer;
begin
  if hContact = 0 then begin
    ContactRTLmode.Visible := False;
    ANSICodepage.Visible := False;
  end else begin
    case hg.RTLMode of
      hppRTLDefault: Self.RTLDefault2.Checked := true;
      hppRTLEnable: Self.RTLEnabled2.Checked := true;
      hppRTLDisable: Self.RTLDisabled2.Checked := true;
    end;
    if UseDefaultCP then
      SystemCodepage.Checked := true
    else
    for i := 1 to ANSICodepage.Count-1 do
      if ANSICodepage.Items[i].Tag = Integer(UserCodepage) then begin
        ANSICodepage.Items[i].Checked := true;
        if i > 1 then break;
      end;
    // no need to make it invisible if it was turned on
    if UnknownCodepage.Checked then
      UnknownCodepage.Visible := true;
  end;
end;

// use that to delay events filtering until window will be visible
procedure THistoryFrm.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Visible and (DelayedFilter <> []) then begin
      hg.ShowBottomAligned := True;
      hg.Filter := DelayedFilter;
      DelayedFilter := [];
  end;
end;

procedure THistoryFrm.SetEventFilter(FilterIndex: Integer = -1; DelayApply: Boolean = false);
var
  i,fi: Integer;
  mi: TTntMenuItem;
begin
  if FilterIndex = -1 then begin
    fi := tbEventsFilter.Tag+1;
    if fi > High(hppEventFilters) then fi := 0;
  end else
    fi := FilterIndex;

  tbEventsFilter.Tag := fi;
  LoadEventFilterButton;
  mi := TTntMenuItem(Customize1.Parent);
  for i := 0 to mi.Count-1 do
    if mi[i].RadioItem then
      mi[i].Checked := (mi[i].Tag = fi);
  hg.ShowHeaders := (tbSessions.Enabled) and (mtMessage in hppEventFilters[fi].Events);

  if DelayApply then
    DelayedFilter := hppEventFilters[fi].Events
  else begin
    DelayedFilter := [];
    hg.Filter := hppEventFilters[fi].Events;
  end;
end;

procedure THistoryFrm.SethContact(const Value: THandle);
begin
  //if FhContact = Value then exit;
  FhContact := Value;
  if FhContact = 0 then begin
    FhSubContact := 0;
    FProtocol := 'ICQ';
    FSubProtocol := FProtocol;
  end else begin
    FProtocol := GetContactProto(hContact,FhSubContact,FSubProtocol);
  end;
end;

// fix for infamous splitter bug!
// thanks to Greg Chapman
// http://groups.google.com/group/borland.public.delphi.objectpascal/browse_thread/thread/218a7511123851c3/5ada76e08038a75b%235ada76e08038a75b?sa=X&oi=groupsr&start=2&num=3
procedure THistoryFrm.AlignControls(Control: TControl; var ARect: TRect);
begin
  inherited;
  if paHolder.Width = 0 then
    paHolder.Left := spHolder.Left;
  if paSess.Height = 0 then
    paSess.Top := spBook.Top;
end;

procedure THistoryFrm.ContactRTLmode1Click(Sender: TObject);
begin
  if RTLDefault2.Checked then
    hg.RTLMode := hppRTLDefault
  else begin
    if RTLEnabled2.Checked then hg.RTLMode := hppRTLEnable
                           else hg.RTLMode := hppRTLDisable;
  end;
  WriteContactRTLMode(hContact,hg.RTLMode,Protocol);
end;

procedure THistoryFrm.SMPrepare(var M: TMessage);
begin
  if tvSess.Visible then tvSess.Enabled := False;
  IsLoadingSessions := True;
end;

procedure THistoryFrm.SMItemsFound(var M: TMessage);
var
  ti: TtntTreeNode;
  i: Integer;
  dt: TDateTime;
  ts: DWord;
  PrevYear: Integer;
  PrevYearNode, PrevMonthNode: TtntTreeNode;
begin
{$RANGECHECKS OFF}
  // wParam - array of hDBEvent, lParam - array size
  PrevYearNode := nil;
  PrevMonthNode := nil;
  Sessions := PSessArray(m.WParam)^;
  FreeMem(PSessArray(m.WParam));
  tvSess.Items.BeginUpdate;
  try
    for i := 0 to Length(Sessions) - 1 do begin
      ts := Sessions[i].TimestampFirst;
      dt := TimestampToDateTime(ts);
      if (PrevYearNode = nil) or (DWord(PrevYearNode.Data) <> YearOf(dt)) then begin
        PrevYearNode := tvSess.Items.AddChild(nil,WideFormatDateTime(HPP_SESS_YEARFORMAT,dt));
        PrevYearNode.Data := Pointer(YearOf(dt));
        PrevYearNode.ImageIndex := 5;
        //PrevYearNode.SelectedIndex := PrevYearNode.ImageIndex;
        PrevMonthNode := nil;
      end;
      if (PrevMonthNode = nil) or (DWord(PrevMonthNode.Data) <> MonthOf(dt)) then begin
        PrevMonthNode := tvSess.Items.AddChild(PrevYearNode,WideFormatDateTime(HPP_SESS_MONTHFORMAT,dt));
        PrevMonthNode.Data := Pointer(MonthOf(dt));
        case MonthOf(dt) of
          12,1..2: PrevMonthNode.ImageIndex := 3;
          3..5: PrevMonthNode.ImageIndex := 4;
          6..8: PrevMonthNode.ImageIndex := 1;
          9..11: PrevMonthNode.ImageIndex := 2;
        end;
        //PrevMonthNode.SelectedIndex := PrevMonthNode.ImageIndex;
      end;
      ti := tvSess.Items.AddChild(PrevMonthNode,WideFormatDateTime(HPP_SESS_DAYFORMAT,dt));
      ti.Data := Pointer(i);
      ti.ImageIndex := 0;
      //ti.SelectedIndex := ti.ImageIndex;
    end;
    if PrevYearNode <> nil then begin
      PrevYearNode.Expand(False);
      PrevMonthNode.Expand(True);
    end;
    if ti <> nil then
      ti.Selected := True;
  finally
    tvSess.Items.EndUpdate;
  end;
{$RANGECHECKS ON}
end;

procedure THistoryFrm.SMFinished(var M: TMessage);
begin
  if not tvSess.Enabled then tvSess.Enabled := True;
  IsLoadingSessions := False;
end;

procedure THistoryFrm.SendMessage1Click(Sender: TObject);
begin
  if hContact <> 0 then SendMessageTo(hContact);
end;

procedure THistoryFrm.ReplyQuoted1Click(Sender: TObject);
begin
  if hContact = 0 then exit;
  if hg.Selected <> -1 then
    ReplyQuoted(hg.Selected);
end;

procedure THistoryFrm.CodepageChangeClick(Sender: TObject);
var
  val: Cardinal;
begin
  val := (Sender as TTntMenuItem).Tag;
  WriteContactCodePage(hContact,val,Protocol);
  //UserCodepage := val;
  UserCodepage := GetContactCodePage(hContact,Protocol,UseDefaultCP);
  hg.Codepage := UserCodepage;
end;

procedure THistoryFrm.sbClearFilterClick(Sender: TObject);
begin
  if SearchMode = smFilter then EndHotFilterTimer;
  edSearch.Text := '';
  edSearch.Color := clWindow;
  if Self.Visible then
    hg.SetFocus
  else
    Self.ActiveControl := hg;
end;

procedure THistoryFrm.pbFilterPaint(Sender: TObject);
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

procedure THistoryFrm.pbSearchPaint(Sender: TObject);
begin
  DrawIconEx(pbSearch.Canvas.Handle,0,0,hppIcons[HPP_ICON_HOTSEARCH].Handle,
    16,16,0,pbSearch.Canvas.Brush.Handle,DI_NORMAL);
end;

procedure THistoryFrm.pbSearchStatePaint(Sender: TObject);
begin
  {case laSearchState.Tag of
    1: DrawIconEx(pbSearchState.Canvas.Handle,0,0,hppIcons[HPP_ICON_HOTSEARCH].Handle,
       16,16,0,pbSearchState.Canvas.Brush.Handle,DI_NORMAL);
    2: DrawIconEx(pbSearchState.Canvas.Handle,0,0,hppIcons[HPP_ICON_HOTSEARCH].Handle,
       16,16,0,pbSearchState.Canvas.Brush.Handle,DI_NORMAL)
  else
    pbSearchState.Canvas.FillRect(pbSearchState.Canvas.ClipRect);
  end;}
end;

procedure THistoryFrm.StartHotFilterTimer;
//var
  //RepaintIcon: Boolean;
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

procedure THistoryFrm.EmptyHistory;
begin
  if Assigned(EventDetailForm) then
    EventDetailForm.Release;

  HistoryLength := 0;
  SetLength(History,HistoryLength);

  SetLength(Sessions,0);
  BookmarkServer.Contacts[hContact].Clear;
  tvSess.Items.Clear;
  lvBook.Items.Clear;

  SetSafetyMode(False);
  try
    FormState := gsDelete;
    hg.DeleteAll;
  finally
    FormState := gsIdle;
    SetSafetyMode(True);
  end;
end;

procedure THistoryFrm.EmptyHistory1Click(Sender: TObject);
begin
  PluginLink.CallService(MS_HPP_EMPTYHISTORY,hContact,0);
end;

procedure THistoryFrm.EndHotFilterTimer(DoClearFilter: Boolean = False);
begin
  tiFilter.Enabled := False;
  if DoClearFilter then
    HotFilterString := '' else
    HotFilterString := edSearch.Text;
  hg.GridUpdate([guFilter]);
  if pbFilter.Tag <> 0 then begin
    pbFilter.Tag := 0;
    pbFilter.Repaint;
  end;
  if (not DoClearFilter) and (hg.Selected = -1) then
    edSearch.Color := $008080FF else
    edSearch.Color := clWindow;
end;

procedure THistoryFrm.tbBookmarksClick(Sender: TObject);
begin
  // when called from menu item handler
  if Sender <> tbBookmarks then
    tbBookmarks.Down := not tbBookmarks.Down;

  if tbBookmarks.Down then
    Panel := Panel + [hpBookmarks]
  else
    Panel := Panel - [hpBookmarks];
end;

procedure THistoryFrm.tbEventsFilterClick(Sender: TObject);
var
  p: TPoint;
begin
  p := tbEventsFilter.ClientOrigin;
  tbEventsFilter.ClientToScreen(p);
  pmEventsFilter.Popup(p.X,p.Y+tbEventsFilter.Height);
end;

procedure THistoryFrm.tbSearchClick(Sender: TObject);
begin
  // when called from menu item handler
  if Sender <> tbSearch then
    tbSearch.Down := not tbSearch.Down;

  if tbSearch.Down then
    SearchMode := smSearch
  else if tbFilter.Down then
    SearchMode := smFilter
  else
    SearchMode := smNone;

  if paSearch.Visible then edSearch.SetFocus;
end;

procedure THistoryFrm.tbFilterClick(Sender: TObject);
begin
  // when called from menu item handler
  if Sender <> tbFilter then
    tbFilter.Down := not tbFilter.Down;

  if tbSearch.Down then
    SearchMode := smSearch
  else if tbFilter.Down then
    SearchMode := smFilter
  else
    SearchMode := smNone;

  if paSearch.Visible then edSearch.SetFocus;
end;

procedure THistoryFrm.tbHistoryClick(Sender: TObject);
begin
  tbHistory.Down := True;
  tbHistory.CheckMenuDropdown;
  tbHistory.Down := False;
  {if hg.SelCount > 1 then begin
    SaveSelected1.Click
    exit;
  end;
  RecentFormat := TSaveFormat(GetDBInt(hppDBName,'ExportFormat',0));
  SaveFormat := RecentFormat;
  PrepareSaveDialog(SaveDialog,SaveFormat,True);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  case SaveDialog.FilterIndex of
    1: SaveFormat := sfHtml;
    2: SaveFormat := sfXml;
    3: SaveFormat := sfRTF;
    4: SaveFormat := sfUnicode;
    5: SaveFormat := sfText;
  end;
  RecentFormat := SaveFormat;
  hg.SaveAll(SaveDialog.Files[0],sfXML);
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));}
end;

procedure THistoryFrm.tbSessionsClick(Sender: TObject);
begin
  // when called from menu item handler
  if Sender <> tbSessions then
    tbSessions.Down := not tbSessions.Down;

  if tbSessions.Down then
    Panel := Panel + [hpSessions]
  else
    Panel := Panel - [hpSessions];

end;

procedure THistoryFrm.tiFilterTimer(Sender: TObject);
begin
  EndHotFilterTimer;
end;

procedure THistoryFrm.SaveasRTF2Click(Sender: TObject);
var
  t: String;
begin
  PrepareSaveDialog(SaveDialog,sfRTF);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  hg.SaveAll(SaveDialog.Files[0],sfRTF);
  RecentFormat := sfRTF;
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.SaveasMContacts2Click(Sender: TObject);
var
  t: String;
begin
  PrepareSaveDialog(SaveDialog,sfMContacts);
  t := Translate('Full History [%s] - [%s]');
  t := Format(t,[WideToAnsiString(hg.ProfileName,CP_ACP),WideToAnsiString(hg.ContactName,CP_ACP)]);
  t := MakeFileName(t);
  SaveDialog.FileName := t;
  if not SaveDialog.Execute then exit;
  hg.SaveAll(SaveDialog.Files[0],sfMContacts);
  RecentFormat := sfMContacts;
  WriteDBInt(hppDBName,'ExportFormat',Integer(RecentFormat));
end;

procedure THistoryFrm.tbHistorySearchClick(Sender: TObject);
begin
  PluginLink.CallService(MS_HPP_SHOWGLOBALSEARCH,0,0);
end;

procedure THistoryFrm.SessSelectClick(Sender: TObject);
var
  Items: Array of integer;

function BuildIndexesFromSession(const Node: TtntTreeNode): boolean;
var
  First,Last: THandle;
  fFirst,fLast: integer;
  a,b,i,cnt: integer;
begin
  Result := false;
  if Node = nil then exit;
  if Node.Level = 2 then begin
    First := Sessions[DWord(Node.Data)].hDBEventFirst;
    Last:= Sessions[DWord(Node.Data)].hDBEventLast;
    fFirst := -1;
    fLast := -1;
    for i := HistoryLength - 1 downto 0 do begin
      if History[i] = 0 then LoadPendingHeaders(i,HistoryLength);
      if History[i] = First then fFirst := i;
      if History[i] = Last then fLast := i;
      if (fLast>=0) and (fFirst>=0) then break;
    end;
    if (fLast>=0) and (fFirst>=0) then begin
      if fFirst > fLast then begin
        a:= fLast; b:= fFirst;
      end else begin
        a:= fFirst; b:= fLast;
      end;
      cnt := Length(Items);
      SetLength(Items,cnt+b-a+1);
      for i := b downto a do Items[cnt+b-i] := HistoryIndexToGrid(i);
      Result := True;
    end;
  end else
    for i := 0 to Node.Count-1 do
      Result := BuildIndexesFromSession(Node.Item[i]) or Result;
end;

begin
  if IsLoadingSessions then Exit;
  BuildIndexesFromSession(tvSess.Selected);
  hg.SelectRange(Items[0],Items[High(Items)]);
  //w := w + hg.Items[i].Text+#13#10+'--------------'+#13#10;
  //CopyToClip(w,Handle,UserCodepage);
  SetLength(Items,0);
  //Index := HistoryIndexToGrid(Index);
  //ShowItem(Index);
  //exit;
  //Events := MakeSessionEvents();
end;

{procedure THistoryFrm.tvSessMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  exit;
  if (Button = mbRight) then begin
    Node := tvSess.GetNodeAt(X,Y);
    if Node <> nil then begin
      if not Node.Selected then
        tvSess.Select(Node);
      tvSessChange(tvSess,Node);
      if not Node.Focused then
        Node.Focused := True;
      tvSess.Invalidate;
    end;
  end;
end;}

procedure THistoryFrm.pmEventsFilterPopup(Sender: TObject);
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
  Application.CancelHint;
end;

procedure THistoryFrm.pmGridPopup(Sender: TObject);
begin
  LoadInOptions();
  if hg.Items[hg.Selected].Bookmarked then
     Bookmark1.Caption := TranslateWideW('Remove &Bookmark')
  else
    Bookmark1.Caption := TranslateWideW('Set &Bookmark');
  AddMenuArray(pmGrid,[ContactRTLmode,ANSICodepage],-1);
end;

procedure THistoryFrm.pmHistoryPopup(Sender: TObject);
var
  pmi,mi: TTntMenuItem;
  i: Integer;
begin
  if SaveSelected2.Parent <> pmHistory.Items then begin
    pmi := TTntMenuItem(SaveSelected2.Parent);
    for i := pmi.Count - 1 downto 0 do begin
      mi := TTntMenuItem(pmi.Items[i]);
      pmi.Remove(mi);
      pmHistory.Items.Insert(0,mi);
    end;
  end;
  LoadInOptions();
  SaveSelected2.Visible := (hg.SelCount > 1);
  AddMenuArray(pmHistory,[ContactRTLmode,ANSICodepage],7);
  Application.CancelHint;
end;

procedure THistoryFrm.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_COMMAND: begin
      if mmAcc.DispatchCommand(Message.WParam) then exit;
      inherited;
      if Message.Result <> 0 then exit;
      Message.Result := PluginLink.CallService(MS_CLIST_MENUPROCESSCOMMAND,
        MAKEWPARAM(Message.WParamLo,MPCF_CONTACTMENU),hContact);
      exit;
    end;
    WM_MEASUREITEM: if Self.UserMenu <> 0 then begin
 	    Message.Result := PluginLink.CallService(MS_CLIST_MENUMEASUREITEM,Message.WParam,Message.LParam);
      if Message.Result <> 0 then exit;
    end;
    WM_DRAWITEM: if Self.UserMenu <> 0 then begin
      Message.Result := PluginLink.CallService(MS_CLIST_MENUDRAWITEM,Message.WParam,Message.LParam);
      if Message.Result <> 0 then exit;
    end;
  end;
  inherited;
end;

procedure THistoryFrm.tbUserMenuClick(Sender: TObject);
var
  p: TPoint;
begin
  UserMenu := PluginLink.CallService(MS_CLIST_MENUBUILDCONTACT,hContact,0);
  if UserMenu <> 0 then begin
    p := tbUserMenu.ClientToScreen(Point(0,tbUserMenu.Height));
    Application.CancelHint;
    TrackPopupMenu(UserMenu,TPM_TOPALIGN or TPM_LEFTALIGN or TPM_LEFTBUTTON,p.x,p.y,0,Handle,nil);
    DestroyMenu(UserMenu);
    UserMenu := 0;
  end;
end;

procedure THistoryFrm.tvSessGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  // and we don't need to set SelectedIndex manually anymore
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure THistoryFrm.tvSessKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if IsFormShortCut([pmBook],Key,Shift) then
    Key := 0;
end;

procedure THistoryFrm.hgRTLEnabled(Sender: TObject; BiDiMode: TBiDiMode);
begin
  edPass.BiDiMode := BiDiMode;
  edSearch.BiDiMode := BiDiMode;
  //tvSess.BiDiMode := BiDiMode;
  if Assigned(EventDetailForm) then
    TEventDetailsFrm(EventDetailForm).ResetItem;
end;

procedure THistoryFrm.Bookmark1Click(Sender: TObject);
var
  val: boolean;
  hDBEvent: THandle;
begin
  hDBEvent := History[GridIndexToHistory(hg.Selected)];
  val := not BookmarkServer[hContact].Bookmarked[hDBEvent];
  BookmarkServer[hContact].Bookmarked[hDBEvent] := val;
end;

procedure THistoryFrm.tbUserDetailsClick(Sender: TObject);
begin
  if hContact = 0 then exit;
  PluginLink.CallService(MS_USERINFO_SHOWDIALOG,hContact,0);
end;

procedure THistoryFrm.lvBookSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  Index,i: Integer;
  Event: THandle;
begin
  if not Selected then exit;
  Event := DWord(Item.Data);
  Index := -1;
  // looks like history starts to load from end?
  // well, of course, we load from the last event!
  for i := HistoryLength - 1 downto 0 do begin
    if History[i] = 0 then
      LoadPendingHeaders(i,HistoryLength);
    if History[i] = Event then begin
      Index := i;
      break;
    end;
  end;
  if Index = -1 then exit;
  if hg.State = gsInline then hg.CancelInline;
  Index := HistoryIndexToGrid(Index);
  hg.BeginUpdate;
  ShowAllEvents;
  ShowItem(Index);
  hg.EndUpdate;
end;

procedure THistoryFrm.SelectAll1Click(Sender: TObject);
begin
  hg.SelectAll;
end;

procedure THistoryFrm.lvBookContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Item: TTntListItem;
begin
  Handled := True;
  Item := TTntListItem(lvBook.GetItemAt(MousePos.X,MousePos.Y));
  if  Item = nil then exit;
  lvBook.Selected := Item;
  if BookmarkServer[hContact].Bookmarked[THandle(Item.Data)] then begin
    MousePos := lvBook.ClientToScreen(MousePos);
    pmBook.Popup(MousePos.X,MousePos.Y);
  end;
end;

procedure THistoryFrm.lvBookEdited(Sender: TObject; Item: TTntListItem;  var S: WideString);
begin
  BookmarkServer[hContact].BookmarkName[THandle(Item.Data)] := S;
end;

procedure THistoryFrm.lvBookKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if IsFormShortCut([pmBook],Key,Shift) then
    Key := 0;  
end;

procedure THistoryFrm.RenameBookmark1Click(Sender: TObject);
begin
  lvBook.Selected.EditCaption;
end;

procedure THistoryFrm.hgProcessInlineChange(Sender: TObject; Enabled: Boolean);
begin
  if Assigned(EventDetailForm) then
    TEventDetailsFrm(EventDetailForm).ResetItem;
end;

procedure THistoryFrm.hgInlinePopup(Sender: TObject);
begin
  InlineCopy.Enabled := hg.InlineRichEdit.SelLength > 0;
  InlineReplyQuoted.Enabled := InlineCopy.Enabled;
  InlineTextFormatting.Checked := GridOptions.TextFormatting;
  InlineSendMessage.Visible := (hContact <> 0);
  InlineReplyQuoted.Visible := (hContact <> 0);
  pmInline.Popup(Mouse.CursorPos.x,Mouse.CursorPos.y);
end;

procedure THistoryFrm.InlineCopyClick(Sender: TObject);
begin
  if hg.InlineRichEdit.SelLength = 0 then exit;
  hg.InlineRichEdit.CopyToClipboard;
end;

procedure THistoryFrm.InlineCopyAllClick(Sender: TObject);
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

procedure THistoryFrm.InlineSelectAllClick(Sender: TObject);
begin
  hg.InlineRichEdit.SelectAll;
end;

procedure THistoryFrm.InlineTextFormattingClick(Sender: TObject);
begin
  GridOptions.TextFormatting := not GridOptions.TextFormatting;
end;

procedure THistoryFrm.InlineReplyQuotedClick(Sender: TObject);
begin
  if (hg.Selected = -1) or (hContact = 0) then exit;
  if hg.InlineRichEdit.SelLength = 0 then exit;
  SendMessageTo(hContact,hg.FormatSelected(GridOptions.ReplyQuotedTextFormat));
end;

procedure THistoryFrm.hgInlineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure THistoryFrm.ToggleMainMenu(Enabled: Boolean);
begin
  if Enabled then begin
    Toolbar.EdgeBorders := [ebTop];
    Menu := mmAcc
  end else begin
    Toolbar.EdgeBorders := [];
    Menu := nil;
  end;
end;

procedure THistoryFrm.WMSysColorChange(var Message: TMessage);
begin
  inherited;
  LoadToolbarIcons;
  LoadButtonIcons;
  LoadSessionIcons;
  LoadBookIcons;
  Repaint;
end;

procedure THistoryFrm.spBookMoved(Sender: TObject);
begin
  spBook.Tag := MulDiv(paSess.Height,255,paHolder.ClientHeight);
end;

procedure THistoryFrm.paHolderResize(Sender: TObject);
begin
  if spBook.Visible then
    paSess.Height := Max(spBook.MinSize,MulDiv(paHolder.ClientHeight,spBook.Tag,255))
  else
  if paSess.Visible then
    paSess.Height := paHolder.ClientHeight;
end;

procedure THistoryFrm.pmToolbarPopup(Sender: TObject);
begin
  Application.CancelHint;
end;

procedure THistoryFrm.hgFilterChange(Sender: TObject);
begin
  if Assigned(EventDetailForm) then
    TEventDetailsFrm(EventDetailForm).ResetItem;
end;

procedure THistoryFrm.OpenFileFolderClick(Sender: TObject);
begin
  if SavedFileDir = '' then exit;
  ShellExecute(0,'open',PChar(SavedFileDir),nil,nil,SW_SHOW);
  SavedFileDir := '';
end;

procedure THistoryFrm.BrowseReceivedFilesClick(Sender: TObject);
var
  Path: Array[0..MAX_PATH] of Char;
begin
  PluginLink.CallService(MS_FILE_GETRECEIVEDFILESFOLDER,hContact,LPARAM(@Path));
  ShellExecute(0,'open',Path,nil,nil,SW_SHOW);
end;

procedure THistoryFrm.SpeakMessage1Click(Sender: TObject);
var
  mesW: WideString;
  mesA: AnsiString;
begin
  if not MeSpeakEnabled then exit;
  if hg.Selected = -1 then exit;
  mesW := hg.Items[hg.Selected].Text;
  if GridOptions.BBCodesEnabled then
      mesW := DoStripBBCodes(mesW);
  if Boolean(PluginLink.ServiceExists(MS_SPEAK_SAY_W)) then
    PluginLink.CallService(MS_SPEAK_SAY_W,hContact,LPARAM(PWideChar(mesW)))
  else begin
    mesA := WideToAnsiString(mesW,UserCodepage);
    PluginLink.CallService(MS_SPEAK_SAY_A,hContact,LPARAM(PChar(mesA)));
  end;
end;

procedure THistoryFrm.hgOptionsChange(Sender: TObject);
begin
  if Assigned(EventDetailForm) then
    TEventDetailsFrm(EventDetailForm).ResetItem;
end;

procedure THistoryFrm.hgMCData(Sender: TObject; Index: Integer; var Item: TMCItem; Stage: TSaveStage);
var
  DBEventInfo: TDBEventInfo;
  hDBEvent:DWord;
  DataOffset: PChar;
begin
  if Stage = ssInit then begin
    Item.Size := 0;
    hDBEvent := History[GridIndexToHistory(Index)];
    if hDBEvent <> 0 then begin
      DBEventInfo := GetEventInfo(hDBEvent);
      DBEventInfo.szModule := nil;
      DBEventInfo.flags := DBEventInfo.flags and not DBEF_FIRST;
      Item.Size := DBEventInfo.cbSize+DBEventInfo.cbBlob;
    end;
    if Item.Size > 0 then begin
      GetMem(Item.Buffer,Item.Size);
      DataOffset := PChar(Item.Buffer) + DBEventInfo.cbSize;
      Move(DBEventInfo,Item.Buffer^,DBEventInfo.cbSize);
      Move(DBEventInfo.pBlob^,DataOffset^,DBEventInfo.cbBlob);
    end;
  end else
  if Stage = ssDone then begin
    if Item.Size > 0 then
      FreeMem(Item.Buffer,Item.Size);
  end;
end;

end.
