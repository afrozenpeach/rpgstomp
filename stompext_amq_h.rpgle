**FREE

/if not defined (STOMP_EXT_ACTIVEMQ)
/define STOMP_EXT_ACTIVEMQ

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
dcl-pr stomp_ext_activemq_create pointer extproc('stomp_ext_activemq_create');
  userdata pointer const options(*nopass : *string);
end-pr;

dcl-pr stomp_ext_activemq_connect extproc('stomp_ext_activemq_connect');
  extension pointer const;
  client pointer const;
  frame pointer const;
  user varchar(100) const options(*nopass);
  pass varchar(100) const options(*nopass);
end-pr;

dcl-pr stomp_ext_activemq_send extproc('stomp_ext_activemq_send');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
  messageData pointer const options(*string);
end-pr;

dcl-pr stomp_ext_activemq_disconnect extproc('stomp_ext_activemq_disconnect');
  extension pointer const;
  client pointer const;
  frame pointer const;
end-pr;

dcl-pr stomp_ext_activemq_subscribe extproc('stomp_ext_activemq_subscribe');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_ext_activemq_unsubscribe extproc('stomp_ext_activemq_unsubscribe');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_ext_activemq_finalize extproc('stomp_ext_activemq_finalize');
  extension pointer;
end-pr;

/endif

