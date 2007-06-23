{-----------------------------------------------------------------------------
 hpp_database (historypp project)

 Version:   1.0
 Created:   31.03.2003
 Author:    Oxygen

 [ Description ]

 Helper routines for database use

 [ History ]
 1.0 (31.03.2003) - Initial version

 [ Modifications ]

 [ Knows Inssues ]
 None

 Copyright (c) Art Fedorov, 2003
-----------------------------------------------------------------------------}


unit hpp_database;

interface

uses m_globaldefs, m_api, windows;

procedure SetSafetyMode(Safe: Boolean);

function DBGetContactSettingString(hContact: THandle; const szModule: PChar; const szSetting: PChar; ErrorValue: PChar): PChar;

function GetDBStr(const Module,Param: String; Default: String): String;
function GetDBInt(const Module,Param: String; Default: Integer): Integer;
function GetDBWord(const Module,Param: String; Default: Word): Word;
function GetDBDWord(const Module,Param: String; Default: DWord): DWord;
function GetDBByte(const Module,Param: String; Default: Byte): Byte;
function GetDBBool(const Module,Param: String; Default: Boolean): Boolean;

function WriteDBByte(const Module,Param: String; Value: Byte): Integer;
function WriteDBWord(const Module,Param: String; Value: Word): Integer;
function WriteDBDWord(const Module,Param: String; Value: DWord): Integer;
function WriteDBInt(const Module,Param: String; Value: Integer): Integer;
function WriteDBStr(const Module,Param: String; Value: String): Integer;
function WriteDBBool(const Module,Param: String; Value: Boolean): Integer;

implementation

{$I m_database.inc}

procedure SetSafetyMode(Safe: Boolean);
begin
  PluginLink.CallService(MS_DB_SETSAFETYMODE,WPARAM(Safe),0);
end;

function WriteDBBool(const Module,Param: String; Value: Boolean): Integer;
begin
  Result := WriteDBByte(Module,Param,Byte(Value));
end;

function WriteDBByte(const Module,Param: String; Value: Byte): Integer;
begin
  Result := DBWriteContactSettingByte(0,PChar(Module),PChar(Param),Value);
end;

function WriteDBWord(const Module,Param: String; Value: Word): Integer;
begin
  Result := DBWriteContactSettingWord(0,PChar(Module),PChar(Param),Value);
end;

function WriteDBDWord(const Module,Param: String; Value: DWord): Integer;
begin
  Result := DBWriteContactSettingDWord(0,PChar(Module),PChar(Param),Value);
end;

function WriteDBInt(const Module,Param: String; Value: Integer): Integer;
var
  cws: TDBCONTACTWRITESETTING;
begin
  cws.szModule := PChar(Module);
  cws.szSetting := PChar(Param);
  cws.value.type_ := DBVT_DWORD;
  cws.value.dVal := Value;
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING, 0, lParam(@cws));
end;

function WriteDBStr(const Module,Param: String; Value: String): Integer;
begin
  Result := DBWriteContactSettingString(0,PChar(Module),PChar(Param),PChar(Value));
end;

function GetDBBool(const Module,Param: String; Default: Boolean): Boolean;
begin
  Result := Boolean(GetDBByte(Module,Param,Byte(Default)));
end;

function GetDBByte(const Module,Param: String; Default: Byte): Byte;
begin
  Result := DBGetContactSettingByte(0,PChar(Module),PChar(Param),Default);
end;

function GetDBWord(const Module,Param: String; Default: Word): Word;
begin
  Result := DBGetContactSettingWord(0,PChar(Module),PChar(Param),Default);
end;

function GetDBDWord(const Module,Param: String; Default: DWord): DWord;
begin
  Result := DBGetContactSettingDWord(0,PChar(Module),PChar(Param),Default);
end;

function GetDBInt(const Module,Param: String; Default: Integer): Integer;
var
  cws:TDBCONTACTGETSETTING;
  dbv:TDBVariant;
begin
  dbv.type_ := DBVT_DWORD;
  dbv.dVal:=Default;
  cws.szModule:=PChar(Module);
  cws.szSetting:=PChar(Param);
  cws.pValue:=@dbv;
  if PluginLink.CallService(MS_DB_CONTACT_GETSETTING,0,DWord(@cws))<>0 then
    Result:=default
  else
    Result:=dbv.dval;
end;

function GetDBStr(const Module,Param: String; Default: String): String;
begin
  Result := DBGetContactSettingString(0,PChar(Module),PChar(Param),PChar(Default));
end;

function DBGetContactSettingString(hContact: THandle; const szModule: PChar; const szSetting: PChar; ErrorValue: PChar): PChar;
var
  dbv: TDBVARIANT;
  cgs: TDBCONTACTGETSETTING;
begin
  cgs.szModule := szModule;
  cgs.szSetting := szSetting;
  cgs.pValue := @dbv;
  if PluginLink^.CallService(MS_DB_CONTACT_GETSETTING, hContact, lParam(@cgs)) <> 0 then
    Result := ErrorValue
  else
    Result := dbv.pszVal;
end;

end.
