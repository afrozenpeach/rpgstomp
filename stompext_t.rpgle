**FREE

/if not defined (STOMP_EXT_TEMPLATE)
/define STOMP_EXT_TEMPLATE

//---------------------------------------------------------------------------------------------
//
// (C) Copyleft 2011 Mihael Schmidt
//
// This file is part of STOMP project and service program.
//
// STOMP is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// STOMP is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with STOMP.  If not, see <http://www.gnu.org/licenses/>.
//
//---------------------------------------------------------------------------------------------

//
// Interface Template
//
dcl-ds stomp_ext_t qualified template align;
  id char(50);
  userdata pointer;
  proc_connect pointer(*proc);
  proc_disconnect pointer(*proc);
  proc_send pointer(*proc);
  proc_subscribe pointer(*proc);
  proc_unsubscribe pointer(*proc);
  proc_finalize pointer(*proc);
end-ds;

/endif
