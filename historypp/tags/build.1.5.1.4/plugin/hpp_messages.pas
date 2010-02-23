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

 Contributors: theMIROn, Art Fedorov, Christian Kastner
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
