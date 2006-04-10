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
function GetContactCodePage(hContact: THandle; Proto: String = ''): Cardinal;
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
    Result := AnsiToWideString(Translate('Server'),hppCodepage)
  else begin
    if Proto = '' then Proto := GetContactProto(hContact);
    if Proto = '' then Result := TranslateWideW('''(Unknown Contact)''')
    else begin
      ci.cbSize := SizeOf(ci);
      ci.hContact := hContact;
      ci.szProto := PChar(Proto);
      if hppCoreUnicode then ci.dwFlag := CNF_DISPLAY + CNF_UNICODE
                        else ci.dwFlag := CNF_DISPLAY;
      if PluginLink.CallService(MS_CONTACT_GETCONTACTINFO,0,Integer(@ci)) = 0 then begin
        if hppCoreUnicode then begin
          RetPWideChar := PWideChar(ci.retval.pszVal);
          UW := TranslateW('''(Unknown Contact)''');
          if WideCompareText(RetPWideChar,UW) = 0 then
            Result := AnsiToWideString(GetContactID(hContact,Proto),CP_ACP)
          else
            Result := RetPWideChar;
          MirandaFree(RetPWideChar);
        end else begin
          RetPAnsiChar := ci.retval.pszVal;
          UA := Translate('''(Unknown Contact)''');
          if AnsiCompareText(RetPAnsiChar,UA) = 0 then
            Result := AnsiToWideString(GetContactID(hContact,Proto),CP_ACP)
          else
            Result := AnsiToWideString(RetPAnsiChar,CP_ACP);
          MirandaFree(RetPAnsiChar);
        end;
      end else
        Result := GetContactID(hContact,Proto);
      if Result = '' then Result := TranslateAnsiW(Proto);
    end;
  end;
end;

function GetContactID(hContact: THandle; Proto: String = ''; Contact: boolean = false): String;
var
  ci: TContactInfo;
begin
  if (hContact = 0) and Contact then
    Result := ''
  else begin
    if Proto = '' then Proto := GetContactProto(hContact);
    ci.cbSize := SizeOf(ci);
    ci.hContact := hContact;
    ci.szProto := PChar(Proto);
    ci.dwFlag := CNF_UNIQUEID;
    if PluginLink.CallService(MS_CONTACT_GETCONTACTINFO,0,Integer(@ci)) = 0 then begin
      case ci.type_ of
        CNFT_BYTE:
          Result := intToStr(ci.retval.bVal);
        CNFT_WORD:
          Result := intToStr(ci.retval.wVal);
        CNFT_DWORD:
          Result := intToStr(ci.retval.dVal);
        CNFT_ASCIIZ:
          Result := ci.retval.pszVal;
      end;
    end else
      //Result := PCharToWideString(PChar(Translate('Unknown id')),CP_ACP);
      Result := '';
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

function GetContactCodePage(hContact: THandle; Proto: String = ''): Cardinal;
begin
  if Proto = '' then Proto := GetContactProto(hContact);
  if Proto = '' then
    Result := hppCodepage
  else begin
    Result := GetDBWord(hContact,Proto,'AnsiCodePage',MaxWord);
    If Result = MaxWord then
      Result := GetDBWord(0,Proto,'AnsiCodePage',CP_ACP);
  end;
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
    Result := Application.UseRightToLeftScrollBar
  else begin
    if hContact = 0 then
    Temp := GetDBByte(hContact,Proto,'RTL',255);
    If Temp = 255 then
      Temp := GetDBByte(0,Proto,'RTL',Byte(Application.UseRightToLeftScrollBar));
    Result := Boolean(Temp);
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
