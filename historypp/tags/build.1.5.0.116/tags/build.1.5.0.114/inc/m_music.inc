{$IFNDEF M_MUSIC}
{$DEFINE M_MUSIC}

type
  pSongInfoA = ^tSongInfoA;
  tSongInfoA = packed record
    artist  :pChar;
    title   :pChar;
    album   :pChar;
    genre   :pChar;
    comment :pChar;
    year    :pChar;
    mfile   :pChar;     // media file
    kbps    :integer;
    khz     :integer;
    channels:integer;
    track   :integer;
    total   :integer;   // music length
    time    :integer;   // elapsed time
    wndtext :pChar;     // window title
    player  :pChar;     // player name
    plyver  :integer;   // player version
    icon    :thandle;   // player icon
    fsize   :integer;   // media file size
    vbr     :integer;
    status  :integer;   // player status: 0 - stopped; 1 - playing; 2 - paused
    plwnd   :hwnd;      // player window
    // video part
    codec   :integer;
    width   :integer;
    height  :integer;
    fps     :integer;
    date    :int64;
    txtver  :pChar;
    // not implemented
    lyric   :PChar;
    cover   :PChar;
  end;
type
  pSongInfo=^tSongInfo;
  tSongInfo = packed record
    artist  :pWideChar;
    title   :pWideChar;
    album   :pWideChar;
    genre   :pWideChar;
    comment :pWideChar;
    year    :pWideChar;
    mfile   :pWideChar; // media file
    kbps    :integer;
    khz     :integer;
    channels:integer;
    track   :integer;
    total   :integer;   // music length
    time    :integer;   // elapsed time
    wndtext :pWideChar; // window title
    player  :pWideChar; // player name
    plyver  :integer;   // player version
    icon    :thandle;   // player icon
    fsize   :integer;   // media file size
    vbr     :integer;
    status  :integer;   // player status: 0 - stopped; 1 - playing; 2 - paused
    plwnd   :hwnd;      // player window
    // video part
    codec   :integer;
    width   :integer;
    height  :integer;
    fps     :integer;
    date    :int64;
    txtver  :pWideChar;
    // not implemented
    lyric   :pWideChar;
    cover   :pWideChar;  // cover path
  end;

// result for MS_WAT_GETMUSICINFO service
const
  WAT_PLS_NORMAL   = 0;
  WAT_PLS_NOMUSIC  = 1;
  WAT_PLS_NOTFOUND = 2;

const
  WAT_INF_UNICODE = 0;
  WAT_INF_ANSI    = 1;
  WAT_INF_UTF8    = 2;

const
{
  wParam : WAT_INF_* constant
  lParam : pointer to pSongInfo (Unicode) or pSongInfoA (ANSI/UTF8)
  Affects: Fill structure by currently played music info
  returns: WAT_PLS_* constant
  note: pointer will be point to global SongInfo structure of plugin
  warning: Non-Unicode data filled only by request
  if lParam=0 only internal SongInfo structure will be filled
  Example:
    var p:pSongInfo;
    PluginLink^.CallService(MS_WAT_GETMUSICINFO,0,dword(@p));
}
  MS_WAT_GETMUSICINFO = 'WATrack/GetMusicInfo';

{
  wParam: not used
  lParam: not used
  Affects: Show popup or Info window with current music information
  note: Only Info window will be showed if Popup plugin disabled
}
  MS_WAT_SHOWMUSICINFO = 'WATrack/ShowMusicInfo';
{
  wParam: pointer to log file name or NIL
  lParam: pointer to report file name or NIL
  Affects: Create report from log and run it (if option is set)
  returns: 0 if unsuccesful
  note: if wParam or lParam is a NIL then file names from options are used
}
  MS_WAT_MAKEREPORT = 'WATrack/MakeReport';

{
  wParam, lParam - not used
  Affects: pack statistic file
}
  MS_WAT_PACKLOG = 'WATrack/PackLog';

{
  wParam: not used
  lParam: pointer to SongInfo
}
  MS_WAT_ADDTOLOG = 'WATrack/AddToLog';

{
  wParam: 1  - switch off plugin
          0  - switch on plugin
          -1 - switch plugin status
          other - get plugin status
  lParam: 0
  Affects: Switch plugin status to enabled or disabled
  returns: old plugin status, 0, if was enabled
}
  MS_WAT_PLUGINSTATUS = 'WATrack/PluginStatus';

const
  WAT_CTRL_PREV  = 1;
  WAT_CTRL_PLAY  = 2;
  WAT_CTRL_PAUSE = 3;
  WAT_CTRL_STOP  = 4;
  WAT_CTRL_NEXT  = 5;
  WAT_CTRL_VOLDN = 6;
  WAT_CTRL_VOLUP = 7;
  WAT_CTRL_SEEK  = 8; // lParam is new position (sec)
//  WAT_CTRL_OPEN  = 9;

{
  wParam: button code (WAT_CTRL_* const)
  lParam: 0, or value (see WAT_CTRL_* const comments)
  Affects: emulate player button pressing
  returns: 0 if unsuccesful
}
  MS_WAT_PRESSBUTTON = 'WATrack/PressButton';

  ME_WAT_MODULELOADED = 'WATrack/ModuleLoaded';

const
  WAT_EVENT_PLAYERSTATUS = 1; // 0-normal; 1-no music (possibly stopped); 2-not found
  WAT_EVENT_NEWTRACK     = 2;
  WAT_EVENT_PLUGINSTATUS = 3; // 0-enabled; 1-dis.temporary; 2-dis.permanent

{
  Plugin or player status changed:
  wParam: type of event (see above)
  lParam: value
}
  ME_WAT_NEWSTATUS = 'WATrack/NewStatus';

const
  WAT_ACT_REGISTER   = 1;
  WAT_ACT_UNREGISTER = 2;
  WAT_ACT_DISABLE    = 3;
  WAT_ACT_ENABLE     = 4;
  WAT_ACT_GETSTATUS  = 5; // not found/enabled/disabled
  WAT_ACT_REPLACE    = $10000; // can be combined with WAT_REGISTERFORMAT

  // result codes
  WAT_RES_NOTFOUND = -1;
  WAT_RES_ERROR    = WAT_RES_NOTFOUND;
  WAT_RES_OK       = 0;
  WAT_RES_ENABLED  = WAT_RES_OK;
  WAT_RES_DISABLED = 1;
  // internal
  WAT_RES_NEWFILE  = 3;

  // flags
  WAT_OPT_DISABLED   = $0001; // registered but disabled
  WAT_OPT_ONLYONE    = $0002; // can't be overwriten
  WAT_OPT_PLAYERINFO = $0004; // song info from player
  WAT_OPT_WINAMPAPI  = $0008; // Winamp API support
  WAT_OPT_CHECKTIME  = $0010; // check file time for changes
  WAT_OPT_USEOLE     = $0020; // use COM/OLE interface
  WAT_OPT_LAST       = $0040; // (internal-Winamp Clone) put to the end of queue
  WAT_OPT_IMPLANTANT = $0100; // use process implantation
  // internal using
  WAT_OPT_INTERNAL   = $0080;

type
  tReadFormatProc = function(var Info:tSongInfo):boolean; cdecl;
  pMusicFormat = ^tMusicFormat;
  tMusicFormat = packed record
    proc :tReadFormatProc;
    ext  :array [0..7] of Char;
    flags:integer;
  end;

const
{
  wParam: action
  lParam: pointer to tMusicFormat if wParam = WAT_ACT_REGISTER,
          else - pointer to extension string (ANSI)
  returns: see result codes
}
  MS_WAT_FORMAT = 'WATrack/Format';

{
  wParam: pointer to SongInfo structure (plwind field must be initialized)
  lParam: flags
  Affects: trying to fill SongInfo using Winamp API
}
  MS_WAT_WINAMPINFO = 'WATrack/WinampInfo';

{
  wParam: window
  lParam: LoWord - command; HiWord - value
}
  MS_WAT_WINAMPCOMMAND = 'WATrack/WinampCommand';

type
  tNameProc    = function:pWideChar;cdecl;
  tCheckProc   = function(flags:integer):HWND;cdecl;
  tInfoProc    = function(var SongInfo:tSongInfo;flags:integer):integer;cdecl;
  tCommandProc = function(command:integer;value:integer):integer;cdecl;

  pPlayerCell = ^tPlayerCell;
  tPlayerCell = packed record
    Desc :PChar;
    flags:integer;
    Icon :HICON;          // can be 0. for registration only
    Check  :tCheckProc;   // check player
    GetName:tNameProc;    // can be NIL. get media filename
    GetInfo:tInfoProc;    // can be NIL. get info from player
    Command:tCommandProc; // can be NIL. send command to player
  end;

const
{
  wParam: action
  lParam: pointer to tPlayerCell if wParam = WAT_ACT_REGISTER,
          else - pointer to player description string (ANSI)
  returns: player window handle or value>0 if found
  note: If you use GetName or GetInfo field, please, do not return empty
        filename even when mediafile is remote!
}
  MS_WAT_PLAYER = 'WATrack/Player';

// media file status

const
  WAT_MES_STOPPED = 0;
  WAT_MES_PLAYING = 1;
  WAT_MES_PAUSED  = 2;
  WAT_MES_UNKNOWN = -1;

const
{
  wParam: not used
  lParam: Unicode template
  returns: New Unicode (replaced) string
}
  MS_WAT_REPLACETEXT = 'WATrack/ReplaceText';

  EVENTTYPE_WAT_REQUEST = 9601;
  EVENTTYPE_WAT_ANSWER  = 9602;
  EVENTTYPE_WAT_ERROR   = 9603;

{$ENDIF M_MUSIC}
