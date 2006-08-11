unit m_MathModule;

interface

uses
  Windows;

const
  // replace all formulas in a RichEdit with bitmaps.
  // wParam = 0
  // lParam = *TMathRichedit Info
  // return: TRUE if replacement succeeded, FALSE if not (disable by user?).
  MATH_RTF_REPLACE_FORMULAE  = 'Math/RtfReplaceFormulae';

type
  TMathRicheditInfo = record
    hwndRichEditControl: THandle;
    sel: Pointer; // NULL: replace all.
    disableredraw: Integer;
  end;

  // WARNING:   !!!
// Strange things happen if you use this function twice on the same CHARRANGE:
// if Math-startDelimiter == Math-endDelimiter, there is the following problem:
// it might be that someone forgot an endDelimiter, this results in a lonesome startdelimiter.
// if you try to MATH_REPLACE_FORMULAE the second time, startDelimiters and endDelimiters are mixed up.
// The same problem occours if we have empty formulae, because two succeding delimiters are
// replaced with a single delimiter.


implementation

end.
