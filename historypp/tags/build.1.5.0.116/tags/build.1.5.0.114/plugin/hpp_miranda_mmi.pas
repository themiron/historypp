unit hpp_miranda_mmi;

interface

uses
  m_globaldefs, m_api;

{$I m_system.inc}

procedure InitMMI;
procedure MirandaFree(pb: Pointer);

var
  mmi: TMM_INTERFACE;

implementation

procedure InitMMI;
begin
  mmi.cbSize := SizeOf(mmi);
  PluginLink.CallService(MS_SYSTEM_GET_MMI,0,LPARAM(@mmi));
end;

procedure MirandaFree(pb: Pointer);
begin
  mmi._free(pb);
end;

end.
