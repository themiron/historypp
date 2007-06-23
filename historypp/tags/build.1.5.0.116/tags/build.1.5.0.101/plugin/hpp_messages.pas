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

function QuoteText(Text: WideString): WideString;
function SendMessageTo(hContact: Integer; Text: WideString = ''): Boolean;
//function ForwardMessage(Text: String): Boolean;

implementation

{$I m_message.inc}

(* quotes text from this
text here 1
text here 2
to
> text here 1
> text here 2 *)
function QuoteText(Text: WideString): WideString;
begin
  Text := TrimRight(Text);
  Result := Tnt_WideStringReplace('> '+Text,#13#10,#13#10'> ',[rfReplaceAll]);
  Result := Result + #13#10; // to move caret to next line
end;

function SendMessageTo(hContact: Integer; Text: WideString): Boolean;
var
  i: integer;
  t: string;
begin
  if Text = '' then i := 0
  else begin
    t := WideToAnsiString(Text,CP_ACP);
    i := integer(@t[1]);
  end;
  Result := (PluginLink.CallService(MS_MSG_SENDMESSAGE,hContact,i) = 0);
end;

{function ForwardMessage(Text: String): Boolean;
begin
  Result := (PluginLink.CallService(MS_MSG_FORWARDMESSAGE,0,Integer(PChar(Text)))=0);
end;}

end.
