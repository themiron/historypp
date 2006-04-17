{-----------------------------------------------------------------------------
 hpp_strparser.pas (historypp project)

 Version:   1.5
 Created:   18.04.2006
 Author:    Oxygen

 [ Description ]

 This unit provides string parsing routines. Mainly it was added to
 parse tokens from the string. See TokenizeString for description.

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Contributors:
  * Oxygen
-----------------------------------------------------------------------------}

unit hpp_strparser;

interface

uses
  SysUtils, TntSysUtils, hpp_global;

procedure TokenizeString(Template: WideString; var Tokens: TWideStrArray; var SpecialTokens: TIntArray);

implementation

{
  This procedure splits string into array.

  The split is based on three token types:
  1) general text
  2) chars prefixed with '\', like '\n'
  3) string surrounded by %'s, like '%mymom%'

  You input the string in Template variable and it outputs
  * Tokens: array of all tokens
  * SpecialTokens: array of token indexes from the Tokens array,
    where indexes are of 2nd and 3rd type tokens

  You can get the orginial template string if you combine all strings
  from tokens array. It means that Template = Tokens[0]+Tokens[1]+...+Tokens[n]

  The idea is that after recieving special tokens array, you can scan through
  them and change all the special tokens you want in the tokens array and then
  combine tokens array to get template with the needed tokens substituted

  *** Examples (special tokens in double quotes here):
     'My %mom% is good\not bad' -> 'My '+"%mom%"+' is good'+"\n"+'ot bad'
     '%My mom% is good' -> "%My mom%"+' is good'
  *** Placing \'s inside %'s would give you type 2 token, not type 3:
     '%My \mom% is good' -> '%My '+"\m"+'om% is good'
  *** \'s and %'s at the end of the line don't get counted:
     'My mom\' -> 'My mom\'
     'My mom%' -> 'My mom%'
     'My mom is %good' -> 'My mom is %good'
  *** But
     'My mom is %good%' -> 'My mom is '+"%good%"
  *** Double %'s is also counted as token:
     'My %% mom' -> 'My '+"%%"+' mom'

  So, feeding it 'My %mom% is good\nNot bad' would output:
  Tokens =>
    [0] -> 'My '
    [1] -> '%mom%'
    [2] -> ' is good'
    [3] -> '\n'
    [4] -> 'Not bad'
  SpecialTokens =>
    [0] -> 1
    [1] -> 3
}
procedure TokenizeString(Template: WideString; var Tokens: TWideStrArray; var SpecialTokens: TIntArray);
var
  i,len: Integer;
  token_s: Integer;
  in_token: Boolean;

  procedure PushToken(StartIdx,EndIdx: Integer; Special: Boolean = False);
  begin
    if EndIdx < StartIdx then exit;
    if not Special then begin // if not special, try to append current token to previous
      if Length(Tokens) > 0 then begin
        if not ((Length(SpecialTokens) > 0) and
        (SpecialTokens[High(SpecialTokens)] = High(Tokens))) then begin  // previous was not special
          Tokens[High(Tokens)] := Tokens[High(Tokens)] + Copy(Template,StartIdx,EndIdx-StartIdx+1);
          exit;
        end;
      end;
    end;
    SetLength(Tokens,Length(Tokens)+1);
    Tokens[High(Tokens)] := Copy(Template,StartIdx,EndIdx-StartIdx+1);
    if Special then begin
      SetLength(SpecialTokens,Length(SpecialTokens)+1);
      SpecialTokens[High(SpecialTokens)] := High(Tokens);
    end;
  end;
begin
  len := Length(Template);
  SetLength(Tokens,0);
  SetLength(SpecialTokens,0);

  token_s := 1;
  in_token := False;
  i := 1;
  while i <= len do begin
    if Template[i] in ['\','%'] then begin
      if Template[i] = '\' then begin
        if i = len then break;
        PushToken(token_s,i-1);
        token_s := i;
        PushToken(token_s,token_s+1,True);
        token_s := i+2;
        i := token_s;
        in_token := False;
        continue;
      end
      else begin
        if in_token then begin
          PushToken(token_s,i,True);
          token_s := i + 1;
          in_token := False;
        end
        else begin
          PushToken(token_s,i-1);
          token_s := i;
          in_token := True;
        end;
      end;
    end;
    Inc(i);
  end;

  PushToken(token_s,len);
end;

end.
