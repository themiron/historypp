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

function GetDBBlob(const Module,Param: String; var Value: Pointer; var Size: Integer): Boolean; overload;
function GetDBBlob(const hContact: THandle; const Module,Param: String; var Value: Pointer; var Size: Integer): Boolean; overload;
function GetDBStr(const Module,Param: String; Default: String): String; overload;
function GetDBStr(const hContact: THandle; const Module,Param: String; Default: String): String; overload;
function GetDBInt(const Module,Param: String; Default: Integer): Integer; overload;
function GetDBInt(const hContact: THandle; const Module,Param: String; Default: Integer): Integer; overload;
function GetDBWord(const Module,Param: String; Default: Word): Word; overload;
function GetDBWord(const hContact: THandle; const Module,Param: String; Default: Word): Word; overload;
function GetDBDWord(const Module,Param: String; Default: DWord): DWord; overload;
function GetDBDWord(const hContact: THandle; const Module,Param: String; Default: DWord): DWord; overload;
function GetDBByte(const Module,Param: String; Default: Byte): Byte; overload;
function GetDBByte(const hContact: THandle; const Module,Param: String; Default: Byte): Byte; overload;
function GetDBBool(const Module,Param: String; Default: Boolean): Boolean; overload;
function GetDBBool(const hContact: THandle; const Module,Param: String; Default: Boolean): Boolean; overload;

function WriteDBBlob(const Module,Param: String; Value: Pointer; Size: Integer): Integer; overload;
function WriteDBBlob(const hContact: THandle; const Module,Param: String; Value: Pointer; Size: Integer): Integer; overload;
function WriteDBByte(const Module,Param: String; Value: Byte): Integer; overload;
function WriteDBByte(const hContact: THandle; const Module,Param: String; Value: Byte): Integer; overload;
function WriteDBWord(const Module,Param: String; Value: Word): Integer; overload;
function WriteDBWord(const hContact: THandle; const Module,Param: String; Value: Word): Integer; overload;
function WriteDBDWord(const Module,Param: String; Value: DWord): Integer; overload;
function WriteDBDWord(const hContact: THandle; const Module,Param: String; Value: DWord): Integer; overload;
function WriteDBInt(const Module,Param: String; Value: Integer): Integer; overload;
function WriteDBInt(const hContact: THandle; const Module,Param: String; Value: Integer): Integer; overload;
function WriteDBStr(const Module,Param: String; Value: String): Integer; overload;
function WriteDBStr(const hContact: THandle; const Module,Param: String; Value: String): Integer; overload;
function WriteDBBool(const Module,Param: String; Value: Boolean): Integer; overload;
function WriteDBBool(const hContact: THandle; const Module,Param: String; Value: Boolean): Integer; overload;

implementation

procedure SetSafetyMode(Safe: Boolean);
begin
  PluginLink.CallService(MS_DB_SETSAFETYMODE,WPARAM(Safe),0);
end;

function WriteDBBool(const Module,Param: String; Value: Boolean): Integer;
begin
  Result := WriteDBBool(0,Module,Param,Value);
end;

function WriteDBBool(const hContact: THandle; const Module,Param: String; Value: Boolean): Integer;
begin
  Result := WriteDBByte(hContact,Module,Param,Byte(Value));
end;

function WriteDBByte(const Module,Param: String; Value: Byte): Integer;
begin
  Result := WriteDBByte(0,Module,Param,Value);
end;

function WriteDBByte(const hContact: THandle; const Module,Param: String; Value: Byte): Integer;
begin
  Result := DBWriteContactSettingByte(hContact,PChar(Module), PChar(Param), Value);
end;

function WriteDBWord(const Module,Param: String; Value: Word): Integer;
begin
  Result := WriteDBWord(0,Module,Param,Value);
end;

function WriteDBWord(const hContact: THandle; const Module,Param: String; Value: Word): Integer;
begin
  Result := DBWriteContactSettingWord(hContact,PChar(Module),PChar(Param),Value);
end;

function WriteDBDWord(const Module,Param: String; Value: DWord): Integer;
begin
  Result := WriteDBWord(0,Module,Param,Value);
end;

function WriteDBDWord(const hContact: THandle; const Module,Param: String; Value: DWord): Integer;
begin
  Result := DBWriteContactSettingDWord(hContact,PChar(Module),PChar(Param),Value);
end;

function WriteDBInt(const Module,Param: String; Value: Integer): Integer;
begin
  Result := WriteDBInt(0,Module,Param,Value);
end;

function WriteDBInt(const hContact: THandle; const Module,Param: String; Value: Integer): Integer;
var
  cws: TDBCONTACTWRITESETTING;
begin
  cws.szModule := PChar(Module);
  cws.szSetting := PChar(Param);
  cws.value.type_ := DBVT_DWORD;
  cws.value.dVal := Value;
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING, hContact, lParam(@cws));
end;

function WriteDBStr(const Module,Param: String; Value: String): Integer;
begin
  Result := WriteDBStr(0,Module,Param,Value);
end;

function WriteDBStr(const hContact: THandle; const Module,Param: String; Value: String): Integer;
begin
  Result := DBWriteContactSettingString(hContact,PChar(Module),PChar(Param),PChar(Value));
end;

function WriteDBBlob(const Module,Param: String; Value: Pointer; Size: Integer): Integer;
begin
  Result := WriteDBBlob(0,Module,Param,Value,Size);
end;

function WriteDBBlob(const hContact: THandle; const Module,Param: String; Value: Pointer; Size: Integer): Integer;
var
  cws: TDBContactWriteSetting;
begin
  ZeroMemory(@cws,SizeOf(cws));
  cws.szModule := @Module[1];
  cws.szSetting := @Param[1];
  cws.value.pbVal := Value;
  cws.value.cpbVal := Word(Size);
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING,hContact,lParam(@cws));
end;

function GetDBBlob(const Module,Param: String; var Value: Pointer; var Size: Integer): Boolean;
begin
  Result := GetDBBlob(0,Module,Param,Value,Size);
end;

function GetDBBlob(const hContact: THandle; const Module,Param: String; var Value: Pointer; var Size: Integer): Boolean;
var
  cgs: TDBContactGetSetting;
  dbv: TDBVARIANT;
begin
  Result := False;
  ZeroMemory(@cgs,SizeOf(cgs));
  cgs.szModule := @Module[1];
  cgs.szSetting := @Param[1];
  cgs.pValue := @dbv;
  if PluginLink^.CallService(MS_DB_CONTACT_GETSETTING, hContact, lParam(@cgs)) <> 0 then exit;
  if dbv.cpbVal = 0 then exit;
  GetMem(Value,dbv.cpbVal);
  Move(dbv.pbVal^,PByte(Value)^,dbv.cpbVal);
  Result := True;
end;

function GetDBBool(const Module,Param: String; Default: Boolean): Boolean;
begin
  Result := GetDBBool(0,Module,Param,Default);
end;

function GetDBBool(const hContact: THandle; const Module,Param: String; Default: Boolean): Boolean;
begin
  Result := Boolean(GetDBByte(hContact,Module,Param,Byte(Default)));
end;

function GetDBByte(const Module,Param: String; Default: Byte): Byte;
begin
  Result := GetDBByte(0,Module,Param,Default);
end;

function GetDBByte(const hContact: THandle; const Module,Param: String; Default: Byte): Byte;
begin
  Result := DBGetContactSettingByte(hContact,PChar(Module),PChar(Param),Default);
end;

function GetDBWord(const Module,Param: String; Default: Word): Word;
begin
  Result := GetDBWord(0,Module,Param,Default);
end;

function GetDBWord(const hContact: THandle; const Module,Param: String; Default: Word): Word;
begin
  Result := DBGetContactSettingWord(hContact,PChar(Module),PChar(Param),Default);
end;

function GetDBDWord(const Module,Param: String; Default: DWord): DWord;
begin
  Result := GetDBDWord(0,Module,Param,Default);
end;

function GetDBDWord(const hContact: THandle; const Module,Param: String; Default: DWord): DWord;
begin
  Result := DBGetContactSettingDWord(hContact,PChar(Module),PChar(Param),Default);
end;

function GetDBInt(const Module,Param: String; Default: Integer): Integer;
begin
  Result := GetDBInt(0,Module,Param,Default);
end;

function GetDBInt(const hContact: THandle; const Module,Param: String; Default: Integer): Integer;
var
  cws:TDBCONTACTGETSETTING;
  dbv:TDBVariant;
begin
  dbv.type_ := DBVT_DWORD;
  dbv.dVal:=Default;
  cws.szModule:=PChar(Module);
  cws.szSetting:=PChar(Param);
  cws.pValue:=@dbv;
  if PluginLink.CallService(MS_DB_CONTACT_GETSETTING,hContact,DWord(@cws))<>0 then
    Result:=default
  else
    Result:=dbv.dval;
end;

function GetDBStr(const Module,Param: String; Default: String): String;
begin
  Result := GetDBStr(0,Module,Param,Default);
end;

function GetDBStr(const hContact: THandle; const Module,Param: String; Default: String): String;
begin
  Result := DBGetContactSettingString(hContact,PChar(Module),PChar(Param),PChar(Default));
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
