{$IFNDEF M_SMILEYADD}
{$DEFINE M_SMILEYADD}

const
  MS_SMILEYADD_REPLACESMILEYS = 'SmileyAdd/ReplaceSmileys';

type
  _charrange = record
    cpMin: Longint;
    cpMax: LongInt;
  end;
  {$EXTERNALSYM _charrange}
  TCharRange = _charrange;
  CHARRANGE = _charrange;
  {$EXTERNALSYM CHARRANGE}

  TEXTRANGEA = record
    chrg: TCharRange;
    lpstrText: PAnsiChar;
  end;
  {$EXTERNALSYM TEXTRANGEA}
  TTextRangeA = TEXTRANGEA;
  TEXTRANGEW = record
    chrg: TCharRange;
    lpstrText: PWideChar;
  end;
  {$EXTERNALSYM TEXTRANGEW}
  TTextRangeW = TEXTRANGEW;
  TEXTRANGE = TEXTRANGEA;

  PCharRange = ^TCharRange;

  TSmAddRichEdit = record
    cbSize: Integer;
    hwndRichEditControl: HWND;
    rangeToReplace: PCharRange;
    ProtocolName: PChar;
    end;

  TSmAddRichEdit2 = record
    cbSize: Integer;
    hwndRichEditControl: HWND;
    rangeToReplace: PCharRange;
    ProtocolName: PChar;
    useSounds: Boolean;
    disableRedraw: Boolean;
    end;

{$ENDIF}