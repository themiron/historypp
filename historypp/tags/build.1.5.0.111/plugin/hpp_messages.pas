{-----------------------------------------------------------------------------
 hpp_messages (historypp project)

 Version:   1.0
 Created:   31.03.2003
 Author:    Oxygen

 [ Description ]

 Some helper utilities to process messages

 [ History ]
 1.0 (31.03.2003) - Initial version

 [ Modifications ]

 [ Knows Inssues ]
 None

 Copyright (c) Art Fedorov, 2003
 Copyright (c) Christian Kastner,
-----------------------------------------------------------------------------}


unit hpp_messages;

interface

uses
  Windows, SysUtils, TntSysUtils,
  m_globaldefs, m_api, hpp_global;

function SendMessageTo(hContact: Integer; Text: WideString = ''): Boolean;
//function ForwardMessage(Text: String): Boolean;

implementation

function SendMessageTo(hContact: Integer; Text: WideString): Boolean;
var
  buff: string;
begin
  if boolean(PluginLink.ServiceExists(MS_MSG_SENDMESSAGE+'W')) then
    Result := (PluginLink.CallService(MS_MSG_SENDMESSAGE+'W',WPARAM(hContact),LPARAM(PWideChar(Text))) = 0)
  else begin
    buff := WideToAnsiString(Text,CP_ACP);
    Result := (PluginLink.CallService(MS_MSG_SENDMESSAGE,WPARAM(hContact),LPARAM(PAnsiChar(buff))) = 0);
    if not Result then
      Result := (PluginLink.CallService(MS_MSG_SENDMESSAGE_OLD,WPARAM(hContact),LPARAM(PAnsiChar(buff))) = 0);
  end;
end;

{function ForwardMessage(Text: String): Boolean;
begin
  Result := (PluginLink.CallService(MS_MSG_FORWARDMESSAGE,0,Integer(PChar(Text)))=0);
end;}

end.
