{$IFNDEF M_MATHMODULE}
{$DEFINE M_MATHMODULE}

const
  MATH_GET_STARTDELIMITER = 'Math/GetStartDelimiter';
// returns the delimiter that marks the beginning of a formula
// wparam=0
// lparam=0
// result=*char Delimiter
// !!! the result-buffer must be deleted with MTH_FREE_MATH_BUFFER

  MATH_GETENDDELIMITER = 'Math/GetEndDelimiter';
// returns the delimiter that marks the end of a formula
// wparam=0
// lparam=0
// result=*char Delimiter
// !!! the result-buffer must be deleted with MTH_FREE_MATH_BUFFER

  MTH_FREE_MATH_BUFFER = 'Math/FreeRTFBitmapText';
// deletes any buffer that MathModule has created.
// wparam=0
// lparam=(*char) buffer
// result=0

  MATH_SETBKGCOLOR = 'Math/SetBackGroundColor';
// changes the background color of the next formula to be rendered.
// wparam=0
// lparam=(COLORREF) color
// result=0

  MTH_GETBITMAP = 'Math/GetBitmap';
//returns Bitmap that represents the formula given in lparam (string-pointer)
//this formula has NO Delimiters.
//wparam=0
//lparam=(*char)Formula
//result=(HBITMAP) bitmap
//!!! the bitmap must be deleted with DeleteObject(hobject)

//example:
//HBITMAP Bmp=(HBITMAP)CallService(MTH_GETBITMAP,0, (LPARAM)formula);

  MTH_GET_RTF_BITMAPTEXT = 'Math/GetRTFBitmapText';
// returns rich-text stream that includes bitmaps from text given in lparam
// text included between MATH_GET_STARTDELIMITER and MATH_GETENDDELIMITER
// hereby is replaced with a rtf-bitmap-stream that represents the corresponding formula
// wparam=0
// lparam=*char text
// result=*char rtfstream
// !!! the result-buffer must be deleted with MTH_FREE_RTF_BITMAPTEXT

  MTH_FREE_RTF_BITMAPTEXT = 'Math/FreeRTFBitmapText';
// deletes the buffer that MTH_GET_RTF_BITMAPTEXT has created.
// wparam=0
// lparam=(*char) buffer
// result=0

{$ENDIF}