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
  m_globaldefs, hpp_global;

//function QuoteText(Text: WideString): WideString;
function SendMessageTo(hContact: Integer; Text: WideString = ''): Boolean;
//function ForwardMessage(Text: String): Boolean;

implementation

{$I m_message.inc}

function SendMessageTo(hContact: Integer; Text: WideString): Boolean;
var
  buff: string;
  res_new, res_old: boolean;
begin
  if boolean(PluginLink.ServiceExists(MS_MSG_SENDMESSAGE+'W')) then
    Result := (PluginLink.CallService(MS_MSG_SENDMESSAGE+'W',hContact,integer(PWideChar(Text))) = 0)
  else begin
    buff := WideToAnsiString(Text,CP_ACP);
    res_new := (PluginLink.CallService(MS_MSG_SENDMESSAGE,hContact,integer(PAnsiChar(buff))) = 0);
    res_old := (PluginLink.CallService(MS_MSG_SENDMESSAGE_OLD,hContact,integer(PAnsiChar(buff))) = 0);
    Result := res_new or res_old;
  end;
end;

{function ForwardMessage(Text: String): Boolean;
begin
  Result := (PluginLink.CallService(MS_MSG_FORWARDMESSAGE,0,Integer(PChar(Text)))=0);
end;}

end.
