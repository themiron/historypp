(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.
    History+ parts (C) 2001 Christian Kastner

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

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
