
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

(*
	NM_FIREVIEWCHANGE is WM_NOTIFY Message for notify parent of host window about smiley are going to be repaint

	The proposed action is next: Owner of RichEdit windows received NM_FIREVIEWCHANGE through WM_NOTIFY
	twice first time before painting|invalidating (FVCN_PREFIRE) and second time - after (FVCN_POSTFIRE).
	The Owner window may change any values of received FVCNDATA_NMHDR structure in order to raise needed action.
	For example it may substitute FVCA_INVALIDATE to FVCA_CUSTOMDRAW event to force painting on self offscreen context.
	
	It can be:
	FVCA_CUSTOMDRAW - in this case you need to provide valid HDC to draw on and valid RECT of smiley
	FVCA_INVALIDATE - to invalidate specified rect of window 
	FVCA_NONE		- skip any action. But be aware - animation will be stopped till next repainting of smiley.
	FVCA_SENDVIEWCHANGE - to notify richedit ole about object changed. Be aware Richedit will fully reconstruct itself

	Another point is moment of received smiley rect - it is only valid if FVCA_DRAW is initially set, 
	and it is PROBABLY valid if FVCA_INVALIDATE is set. And it most probably invalid in case of FVCA_SENDVIEWCHANGE.
	The smiley position is relative last full paint HDC. Usually it is relative to top-left corner of host 
	richedit (NOT it client area) in windows coordinates. 

*)

const
    // Type of Event one of
    FVCN_PREFIRE  = 1;
    FVCN_POSTFIRE = 2;

    // Action of event are going to be done
    FVCA_NONE           = 0;
    FVCA_DRAW           = 1;   // do not modify hdc in case of _DRAW, Use _CUSTOMDRAW
    FVCA_CUSTOMDRAW     = 2;
    FVCA_INVALIDATE     = 3;
    FVCA_SENDVIEWCHANGE = 4;
    FVCA_SKIPDRAW       = 5;

type
    // Extended NMHDR structure for WM_NOTIFY
    PNMFireViewChange = ^TNMFireViewChange;
    TNMFireViewChange = record
        nmhdr: TNMHdr;
        cbSize: Integer;
        bEvent: Byte;
        bAction: Byte;
        hDC: HDC;
        rcRect: TRect;
        clrBackground: COLORREF;
        fTransparent: BOOL;
        lParam: LPARAM;
    end;

const
    // Code of WM_NOTIFY message (code)
    NM_FIRST = 0;
    NM_FIREVIEWCHANGE = NM_FIRST+1;

{$ENDIF}