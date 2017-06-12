**FREE

/if not defined(STOMP_COMMAND_H)
/define STOMP_COMMAND_H

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
dcl-pr stomp_command_connect ind extproc('stomp_command_connect');
  conn pointer const;
  user varchar(100) const options(*nopass);
  pass varchar(100) const options(*nopass);
end-pr;

dcl-pr stomp_command_disconnect extproc('stomp_command_disconnect');
  conn pointer const;
end-pr;

dcl-pr stomp_command_send extproc('stomp_command_send');
  conn pointer const;
  destination varchar(100) const;
  messageData pointer const options(*string);
end-pr;

dcl-pr stomp_command_subscribe extproc('stomp_command_subscribe');
  conn pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_command_unsubscribe extproc('stomp_command_unsubscribe');
  conn pointer const;
  destination varchar(100) const;
end-pr;

/endif

