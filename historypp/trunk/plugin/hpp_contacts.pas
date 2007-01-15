{-----------------------------------------------------------------------------
 hpp_contacts (historypp project)

 Version:   1.0
 Created:   31.03.2003
 Author:    Oxygen

 [ Description ]

 Some helper routines for contacts

 [ History ]
 1.0 (31.03.2003) - Initial version

 [ Modifications ]

 [ Knows Inssues ]
 None

 Copyright (c) Art Fedorov, 2003
-----------------------------------------------------------------------------}


unit hpp_contacts;

interface

uses
  Windows, SysUtils,
  Forms, Classes,
  m_globaldefs, m_api,
  hpp_global, hpp_miranda_mmi,
  hpp_database;

function GetContactDisplayName(hContact: THandle; Proto: String = ''; Contact: boolean = false): WideString;
function GetContactProto(hContact: THandle): String;
function GetContactID(hContact: THandle; Proto: String = ''; Contact: boolean = false): String;
function GetContactCodePage(hContact: THandle; Proto: String = ''): Cardinal; overload;
function GetContactCodePage(hContact: THandle; Proto: String; var UsedDefault: Boolean): Cardinal; overload;
function WriteContactCodePage(hContact: THandle; CodePage: Cardinal; Proto: String = ''): Boolean;
function GetContactRTLMode(hContact: THandle; Proto: String = ''): boolean;
function GetContactRTLModeTRTL(hContact: THandle; Proto: String = ''): TRTLMode;
function WriteContactRTLMode(hContact: THandle; RTLMode: TRTLMode; Proto: String = ''): Boolean;

implementation

uses TntSystem, TntSysUtils;

{$I m_database.inc}
{$I m_clist.inc}
{$I m_contacts.inc}

function GetContactProto(hContact: THandle): String;
begin
  Result := PChar(PluginLink.CallService(MS_PROTO_GETCONTACTBASEPROTO,hContact,0));
end;

function GetContactDisplayName(hContact: THandle; Proto: String = ''; Contact: boolean = false): WideString;
var
  ci: TContactInfo;
  RetPAnsiChar,UA: PAnsiChar;
  RetPWideChar,UW: PWideChar;
begin
  if (hContact = 0) and Contact then
    Result := TranslateWideW('Server')
  else begin
    if Proto = '' then Proto := GetContactProto(hContact);
    if Proto = '' then Result := TranslateWideW('''(Unknown Contact)'''{TRANSLATE-IGNORE})
    else begin
      ci.cbSize := SizeOf(ci);
      ci.hContact := hContact;
      ci.szProto := PChar(Proto);
      if hppCoreUnicode then ci.dwFlag := CNF_DISPLAY + CNF_UNICODE
                        else ci.dwFlag := CNF_DISPLAY;
      if PluginLink.CallService(MS_CONTACT_GETCONTACTINFO,0,Integer(@ci)) = 0 then begin
        if hppCoreUnicode then begin
          RetPWideChar := PWideChar(ci.retval.pszVal);
          UW := TranslateW('''(Unknown Contact)'''{TRANSLATE-IGNORE});
          if WideCompareText(RetPWideChar,UW) = 0 then
            Result := AnsiToWideString(GetContactID(hContact,Proto),CP_ACP)
          else
            Result := RetPWideChar;
          MirandaFree(RetPWideChar);
        end else begin
          RetPAnsiChar := ci.retval.pszVal;
          UA := Translate('''(Unknown Contact)'''{TRANSLATE-IGNORE});
          if AnsiCompareText(RetPAnsiChar,UA) = 0 then
            Result := AnsiToWideString(GetContactID(hContact,Proto),CP_ACP)
          else
            Result := AnsiToWideString(RetPAnsiChar,CP_ACP);
          MirandaFree(RetPAnsiChar);
        end;
      end else
        Result := GetContactID(hContact,Proto);
      if Result = '' then Result := TranslateAnsiW(Proto{TRANSLATE-IGNORE});
    end;
  end;
end;

function GetContactID(hContact: THandle; Proto: String = ''; Contact: boolean = false): String;
var
  uid: PChar;
  dbv: TDBVARIANT;
  cgs: TDBCONTACTGETSETTING;
  tmp: WideString;
begin
  Result := '';
  if not ((hContact = 0) and Contact) then begin
    if Proto = '' then Proto := GetContactProto(hContact);
    uid := PChar(CallProtoService(PChar(Proto),PS_GETCAPS,PFLAG_UNIQUEIDSETTING,0));
    if (cardinal(uid) <> CALLSERVICE_NOTFOUND) and (uid <> nil) then begin
      cgs.szModule := PChar(Proto);
      cgs.szSetting := uid;
      cgs.pValue := @dbv;
      if PluginLink^.CallService(MS_DB_CONTACT_GETSETTING, hContact, lParam(@cgs)) = 0 then begin
        case dbv.type_ of
          DBVT_BYTE:
            Result := intToStr(dbv.bVal);
          DBVT_WORD:
            Result := intToStr(dbv.wVal);
          DBVT_DWORD:
            Result := intToStr(dbv.dVal);
          DBVT_ASCIIZ:
            Result := AnsiString(dbv.pszVal);
          DBVT_UTF8: begin
            tmp := AnsiToWideString(dbv.pszVal,CP_UTF8);
	          Result := WideToAnsiString(tmp,hppCodepage);
            end;
          DBVT_WCHAR:
            Result := WideToAnsiString(dbv.pwszVal,hppCodepage);
        end;
        // free variant
        DBFreeVariant(@dbv);
      // since 08.08.2006 ghazan fixed it in jabber proto, hack should be removed
      //end else begin
      //  if not Contact and (uid = 'jid') then begin
      //    Result := GetDBStr(Proto,'LoginName','');
      //    if Result <> '' then
      //      Result := Result+'@'+GetDBStr(Proto,'LoginServer','')
      //  end;
      end;
    end;
    //Result := PCharToWideString(PChar(Translate('Unknown id')),CP_ACP);
  end;
end;

function WriteContactCodePage(hContact: THandle; CodePage: Cardinal; Proto: String = ''): Boolean;
begin
  Result := False;
  if Proto = '' then Proto := GetContactProto(hContact);
  if Proto = '' then exit;
  if CodePage = 0 then
    DBDeleteContactSetting(hContact,PChar(Proto),'AnsiCodePage')
  else
    WriteDBWord(hContact,Proto,'AnsiCodePage',Codepage);
  Result := True;
end;

function _GetContactCodePage(hContact: THandle; Proto: String; var UsedDefault: Boolean): Cardinal;
begin
  if Proto = '' then Proto := GetContactProto(hContact);
  if Proto = '' then
    Result := hppCodepage
  else begin
    Result := GetDBWord(hContact,Proto,'AnsiCodePage',CP_ACP);
    UsedDefault := (Result = CP_ACP);
    If UsedDefault and (hContact <> 0) then
      Result := GetDBWord(0,Proto,'AnsiCodePage',CP_ACP);
    if Result = CP_ACP then Result := GetACP();
  end;
end;

function GetContactCodePage(hContact: THandle; Proto: String = ''): Cardinal;
var
  def: boolean;
begin
  Result := _GetContactCodePage(hContact,Proto,def);
end;

function GetContactCodePage(hContact: THandle; Proto: String; var UsedDefault: Boolean): Cardinal; overload;
begin
  Result := _GetContactCodePage(hContact,Proto,UsedDefault);
end;


// OXY: 2006-03-30
// Changed default RTL mode from SysLocale.MiddleEast to
// Application.UseRightToLeftScrollBar because it's more correct and
// doesn't bug on MY SYSTEM!
function GetContactRTLMode(hContact: THandle; Proto: String = ''): boolean;
var
  Temp: Byte;
begin
  if Proto = '' then Proto := GetContactProto(hContact);
  if Proto = '' then
    Result := GetDBBool(hppDBName,'RTL',Application.UseRightToLeftScrollBar)
  else begin
    Temp := GetDBByte(hContact,Proto,'RTL',255);
    // we have no per-proto rtl setup ui, use global instead
    //if Temp = 255 then
    //  Temp := GetDBByte(0,Proto,'RTL',255);
    if Temp = 255 then
      Temp := GetDBByte(hppDBName,'RTL',Byte(Application.UseRightToLeftScrollBar));
    Result := boolean(Temp);
  end;
end;

function WriteContactRTLMode(hContact: THandle; RTLMode: TRTLMode; Proto: String = ''): Boolean;
begin
  Result := False;
  if Proto = '' then Proto := GetContactProto(hContact);
  if Proto = '' then exit;
  case RTLMode of
    hppRTLDefault: DBDeleteContactSetting(hContact,PChar(Proto),'RTL');
    hppRTLEnable: WriteDBByte(hContact,Proto,'RTL',Byte(True));
    hppRTLDisable: WriteDBByte(hContact,Proto,'RTL',Byte(False));
  end;
  Result := True;
end;

function GetContactRTLModeTRTL(hContact: THandle; Proto: String = ''): TRTLMode;
var
  Temp: Byte;
begin
  if Proto = '' then Proto := GetContactProto(hContact);
  if Proto = '' then
    Result := hppRTLDefault
  else begin
    Temp := GetDBByte(hContact,Proto,'RTL',255);
    case Temp of
      0: Result := hppRTLDisable;
      1: Result := hppRTLEnable;
    else
       Result := hppRTLDefault;
    end;
  end;
end;

end.
