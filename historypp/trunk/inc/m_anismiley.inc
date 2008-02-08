
{$IFNDEF M_ANISMILEY}
{$DEFINE M_ANISMILEY}

const
    IASF_UNICODE = 1;

type
    INSERTANISMILEY = record
        cbSize: Integer;
        hWnd: HWND;
        filename: TChar;
        dwBackColor: COLORREF;
        nHeight: Integer;
        dwFlags: DWORD;
        text: TChar;
    end;

const
    MS_INSERTANISMILEY = 'mAnimator/InsertSmiley';

{$ENDIF}