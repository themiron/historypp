{$IFNDEF M_SMILEYADD}
{$DEFINE M_SMILEYADD}

const
  MS_SMILEYADD_REPLACESMILEYS = 'SmileyAdd/ReplaceSmileys';
  // insert smiley as EMF into RichEdit, otherwise bitmap inserted
  // this flag allows "true" transparency
  SAFLRE_INSERTEMF = 2;

type
  TSmAddRichEdit = record
    cbSize: Integer;
    hwndRichEditControl: HWND;
    rangeToReplace: ^CharRange;
    ProtocolName: PChar;
    end;

  TSmAddRichEdit2 = record
    cbSize: Integer;
    hwndRichEditControl: HWND;
    rangeToReplace: ^CharRange;
    ProtocolName: PChar;
    useSounds: Boolean;
    disableRedraw: Boolean;
    end;

  TSmAddRichEdit3 = record
    cbSize: Integer;
    hwndRichEditControl: HWND;
    rangeToReplace: ^CharRange;
    ProtocolName: PChar;
    flags: integer;
    disableRedraw: Boolean;
    hContact: THandle;
    end;

const

  // Event notifies that SmileyAdd options have changed 
  // Message dialogs usually need to redraw it's content on reception of this event
  //wParam = Contact handle which options have changed, NULL if global options changed
  //lParam = (LPARAM) 0; not used
  ME_SMILEYADD_OPTIONSCHANGED = 'SmileyAdd/OptionsChanged';


{$ENDIF}