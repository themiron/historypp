unit PasswordEditControl;

interface

uses
  Windows, Messages, Classes, Controls, Forms, StdCtrls,
  TntSysUtils, TntControls, TntStdCtrls;

type
  TPasswordEdit = class(TEdit)
  private
    FDummyPasswordChar: Char;
    function GetPasswordChar: Char;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  published
    property PasswordChar: Char read GetPasswordChar write FDummyPasswordChar default #0;
  end;

  THppEdit = class(TTntEdit)
  private
    procedure WMChar(var Message: TWMKey); message WM_CHAR;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Custom', [TPasswordEdit]);
  RegisterComponents('Custom', [THppEdit]);
end;

procedure TPasswordEdit.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or ES_PASSWORD;
end;

function TPasswordEdit.GetPasswordChar: Char;
begin
  Result := #0;
end;

{ THppEdit }

procedure THppEdit.WMChar(var Message: TWMKey);
var
  ss,sl: integer;
  txt: WideString;
  lastWS: Boolean;
  currentWS: Boolean;

  function IsWordSeparator(WC: WideChar): Boolean;
  begin
    Result := (WC = WideChar(#0)) or IsWideCharSpace(WC) or IsWideCharPunct(WC);
  end;

begin
  // Ctrl+Backspace workaround
  if (Message.CharCode = 127) and (KeyDataToShiftState(Message.KeyData) = [ssCtrl]) then begin
    Message.Result := 0;
    Perform(EM_GETSEL,wParam(@ss),lParam(@sl));
    if (ss = 0) or (ss <> sl) then exit;
    sl := 0;
    txt := Text;
    lastWS := IsWordSeparator(txt[ss]);
    while ss > 0 do begin
      currentWS := IsWordSeparator(txt[ss]);
      if not lastWS and currentWS then break;
      lastWS := currentWS;
      dec(ss);
      inc(sl);
    end;
    Delete(txt,ss+1,sl);
    Text := txt;
    Perform(EM_SETSEL,wParam(@ss),lParam(@ss));
  end else
    inherited;
end;

end.
