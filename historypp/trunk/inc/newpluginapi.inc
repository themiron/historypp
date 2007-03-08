(*

Miranda IM: the free IM client for Microsoft* Windows*

Copyright 2000-2007 Miranda ICQ/IM project, 
all portions of this codebase are copyrighted to the people 
listed in contributors.txt.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*)

{$IFNDEF M_NEWPLUGINAPI}
{$DEFINE M_NEWPLUGINAPI}

const
  MAXMODULELABELLENGTH  = 64;
  UNICODE_AWARE = 1;

type
  PPLUGININFO = ^TPLUGININFO;
  TPLUGININFO = record
    cbSize: Integer;
    shortName: PChar;
    version: DWORD;
    description: PChar;
    author: PChar;
    authorEmail: PChar;
    copyright: PChar;
    homepage: PChar;
    flags: Byte;      // right now the only flag, UNICODE_AWARE, is recognized here
    replacesDefaultModule: Integer; //one of the DEFMOD_ constants in m_plugins.inc or zero
                      //if non-zero, this will supress the loading of the specified built-in module
                      //with the implication that this plugin provides back-end-compatible features
  end;

{ 0.7+ 
    New plugin loader implementation
}

{ The UUID structure below is used to for plugin UUID's and module type definitions }
type
  PMUUID = ^TMUUID;
  TMUUID = packed record
    case boolean of
    true: (guid: TGUID);
    false: (
      a: LongWord;
      b: Word;
      c: Word;
      d: array[0..7] of Byte;)
  end;

{ Used to define the end of the MirandaPluginInterface list }
const
  MIID_LAST: TMUUID = (a:0; b:0; c:0; d:(0,0,0,0,0,0,0,0));

{ TODO: Add replaceable module interface ids }
{ TODO: Add common external plugin interfaces }

  MIID_DATABASE: TMUUID    = (a:$ae77fd33; b:$e484; c:$4dc7; d:($8c,$bc,$09,$9f,$ed,$cc,$cf,$dd));
  MIID_CLIST: TMUUID       = (a:$9d8da8bf; b:$665b; c:$4908; d:($9e,$61,$9f,$75,$98,$ae,$33,$0e));
  MIID_CHAT: TMUUID        = (a:$23576a43; b:$3a26; c:$4357; d:($9b,$1b,$4a,$71,$9e,$42,$5d,$48));
  MIID_SRMM: TMUUID        = (a:$58c7eea6; b:$f9db; c:$4dd9; d:($80,$36,$ae,$80,$2b,$c0,$41,$4c));
  MIID_IMPORT: TMUUID      = (a:$5f3bcad4; b:$75f8; c:$476e; d:($b3,$6b,$2b,$30,$70,$32,$49,$0c));
  MIID_IMGSERVICES: TMUUID = (a:$f3974915; b:$c9d5; c:$4c87; d:($85,$64,$a0,$eb,$f9,$d2,$5a,$a0));
  MIID_TEST: TMUUID        = (a:$53b974f4; b:$3c74; c:$4dba; d:($8f,$c2,$6f,$92,$fe,$01,$3b,$8c));

{ Special exception interface for protocols.
   This interface allows more than one plugin to implement it at the same time
}
  MIID_PROTOCOL: TMUUID    = (a:$2a3c815e; b:$a7d9; c:$424b; d:($ba,$30,$02,$d0,$83,$22,$90,$85));

type
  PPLUGININFOEX = ^TPLUGININFOEX;
  TPLUGININFOEX = record
    cbSize: Integer;
    shortName: PChar;
    version: DWORD;
    description: PChar;
    author: PChar;
    authorEmail: PChar;
    copyright: PChar;
    homepage: PChar;
    flags: Byte;      // right now the only flag, UNICODE_AWARE, is recognized here
    replacesDefaultModule: Integer; //one of the DEFMOD_ constants in m_plugins.inc or zero
                      //if non-zero, this will supress the loading of the specified built-in module
                      //with the implication that this plugin provides back-end-compatible features
                      //***********  WILL BE DEPRECATED in 0.8 * *************//
    uuid: TMUUID;     // Not required until 0.8.
  end;

  { modules.h is never defined -- no check needed }

  TMIRANDAHOOK = function(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
  TMIRANDASERVICE = function(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;

const
  CALLSERVICE_NOTFOUND = $80000000;

//see modules.h for what all this stuff is

type
  Pm_FunctionAsync = ^Tm_FunctionAsync;
  Tm_FunctionAsync = function (p: Pointer): Pointer;

  PPLUGINLINK = ^TPLUGINLINK;
  TPLUGINLINK = record
    CreateHookableEvent: function(const char: PChar): THandle; cdecl;
    DestroyHookableEvent: function(Handle: THandle): Integer; cdecl;
    NotifyEventHooks: function(Handle: THandle; wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
    HookEvent: function(const char: PChar; MIRANDAHOOK: TMIRANDAHOOK): THandle; cdecl;
    HookEventMessage: function(const char: PChar; Wnd: THandle; wMsg: Integer): THandle; cdecl;
    UnhookEvent: function(Handle: THandle): Integer; cdecl;
    CreateServiceFunction: function(const char: PChar; MIRANDASERVICE: TMIRANDASERVICE): THandle; cdecl;
    CreateTransientServiceFunction: function(const char: PChar; MIRANDASERVICE: TMIRANDASERVICE): THandle; cdecl;
    DestroyServiceFunction: function(Handle: THandle): Integer; cdecl;
    CallService: function(const char: PChar; wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
    ServiceExists: function(const char: PChar): Integer; cdecl; // v0.1.0.1+
    CallServiceSync: function(const char: PChar; wParam: WPARAM; lParam: LPARAM): Integer; cdecl; //v0.3.3+
    CallFunctionAsync: function(func: Pm_FunctionAsync; p: Pointer): Integer; cdecl; //v0.3.4+
    SetHookDefaultForHookableEvent: function(Handle: THandle; MIRANDAHOOK: TMIRANDAHOOK): Integer; cdecl; // v0.3.4 (2004/09/15)
  end;

{
 Database plugin stuff
}

const
  // grokHeader() error codes
  EGROKPRF_NOERROR   = 0;
  EGROKPRF_CANTREAD  = 1;   // can't open the profile for reading
  EGROKPRF_UNKHEADER = 2;   // header not supported, not a supported profile
  EGROKPRF_VERNEWER  = 3;   // header correct, version in profile newer than reader/writer
  EGROKPRF_DAMAGED   = 4;   // header/version fine, other internal data missing, damaged.

  // makeDatabase() error codes
  EMKPRF_CREATEFAILED = 1;  // for some reason CreateFile() didnt like something

type
  PDATABASELINK = ^TDATABASELINK;
  TDATABASELINK = record
    cbSize: Integer;
    {
      returns what the driver can do given the flag
    }
    getCapability: function(flag: Integer): Integer; cdecl;

    {
      buf: pointer to a string buffer
      cch: length of buffer
      shortName: if true, the driver should return a short but descriptive name, e.g. "3.xx profile"
      Affect: The database plugin must return a "friendly name" into buf and not exceed cch bytes,
        e.g. "Database driver for 3.xx profiles"
      Returns: 0 on success, non zero on failure
    }
    getFriendlyName: function(const buff: PChar; cch: Integer; shortName: Integer): Integer; cdecl;

    {
      profile: pointer to a string which contains full path + name
      Affect: The database plugin should create the profile, the filepath will not exist at
        the time of this call, profile will be C:\..\<name>.dat
      Note: Do not prompt the user in anyway about this operation.
      Note: Do not initialise internal data structures at this point!
      Returns: 0 on success, non zero on failure - error contains extended error information, see EMKPRF_*
    }
    makeDatabase: function(const profile: PChar; error: PInteger): Integer; cdecl;

    {
      profile: [in] a null terminated string to file path of selected profile
      error: [in/out] pointer to an int to set with error if any
      Affect: Ask the database plugin if it supports the given profile, if it does it will
          return 0, if it doesnt return 1, with the error set in error -- EGROKPRF_* can be valid error
          condition, most common error would be [EGROKPRF_UNKHEADER]
      Note: Just because 1 is returned, doesnt mean the profile is not supported, the profile might be damaged
          etc.
      Returns: 0 on success, non zero on failure
    }
    grokHeader: function(const profile: PChar; error: PInteger): Integer; cdecl;

    {
      Affect: Tell the database to create all services/hooks that a 3.xx legecy database might support into link,
        which is a PLUGINLINK structure
      Returns: 0 on success, nonzero on failure
    }
    Load: function(const profile: PChar; link: PPLUGINLINK): Integer; cdecl;

    {
      Affect: The database plugin should shutdown, unloading things from the core and freeing internal structures
      Returns: 0 on success, nonzero on failure
      Note: Unload() might be called even if Load() was never called, wasLoaded is set to 1 if Load() was ever called.
    }
    Unload: function(wasLoaded: Integer): Integer; cdecl;
  end;

{$ENDIF}
