unit hpp_forms;

interface

uses Graphics, Forms, TntStdCtrls, StdCtrls, Controls;

procedure MakeFontsParent(Control: TControl);

implementation

// This procedure scans all control children and if they have
// no ParentFont, sets ParentFont to true but reapplies font styles,
// so even having parent font and size, controls remain bold or italic
//
// Of course it can be done cleaner and for all controls supporting fonts
// property through TPropertyEditor and GetPropInfo, but then it would
// need vcl sources to compile, so not a best alternative for open source plugin
procedure MakeFontsParent(Control: TControl);
var
  i: Integer;
  fs: TFontStyles;
begin
  // Set TLabel & TtntLabel
  if (Control is TLabel) and (not TLabel(Control).ParentFont) then begin
    fs := TLabel(Control).Font.Style;
    TLabel(Control).ParentFont := True;
    TLabel(Control).Font.Style := fs;
  end;
  if (Control is TtntLabel) and (not TtntLabel(Control).ParentFont) then begin
    fs := TtntLabel(Control).Font.Style;
    TtntLabel(Control).ParentFont := True;
    TtntLabel(Control).Font.Style := fs;
  end;
  // Process children
  for i := 0 to Control.ComponentCount - 1 do begin
    if Control.Components[i] is TControl then begin
      MakeFontsParent(TControl(Control.Components[i]));
    end;
  end;
end;

end.
