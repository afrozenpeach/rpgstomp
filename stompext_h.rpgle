**FREE

/if not defined (STOMP_EXT)
/define STOMP_EXT

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
// Prototypes
//
dcl-pr stomp_ext_create pointer extproc('stomp_ext_create');
  extension char(10) const;
  userdata pointer const options(*nopass : *string);
  procedureName char(256) const options(*nopass);
end-pr;

dcl-pr stomp_ext_getId varchar(50) extproc('stomp_ext_getId');
  extension pointer const;
end-pr;

dcl-pr stomp_ext_connect extproc('stomp_ext_connect');
  extension pointer const;
  client pointer const;
  frame pointer const;
  user varchar(100) const options(*nopass);
  pass varchar(100) const options(*nopass);
end-pr;

dcl-pr stomp_ext_send extproc('stomp_ext_send');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
  messageData pointer const options(*string);
end-pr;

dcl-pr stomp_ext_disconnect extproc('stomp_ext_disconnect');
  extension pointer const;
  client pointer const;
  frame pointer const;
end-pr;

dcl-pr stomp_ext_subscribe extproc('stomp_ext_subscribe');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_ext_unsubscribe extproc('stomp_ext_unsubscribe');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_ext_finalize extproc('stomp_ext_finalize');
  extension pointer;
end-pr;

/endif
