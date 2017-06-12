**FREE

/if not defined(STOMP_H)
/define STOMP_H

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

dcl-pr stomp_create pointer extproc('stomp_create');
  host varchar(255) const;
  port int(10) const;
end-pr;

dcl-pr stomp_open extproc('stomp_open');
  conn pointer const;
end-pr;

dcl-pr stomp_close extproc('stomp_close');
  conn pointer const;
end-pr;

dcl-pr stomp_finalize extproc('stomp_finalize');
  conn pointer;
end-pr;

dcl-pr stomp_sendFrame extproc('stomp_sendFrame');
  conn pointer const;
  frame pointer const;
end-pr;

dcl-pr stomp_receiveFrame pointer extproc('stomp_receiveFrame');
  conn pointer const;
end-pr;

dcl-pr stomp_setTimeout extproc('stomp_setTimeout');
  conn pointer const;
  mseconds int(10) const;
end-pr;

dcl-pr stomp_setClientId extproc('stomp_setClientId');
  conn pointer const;
  clientId varchar(100) const;
end-pr;

dcl-pr stomp_setAckMode extproc('stomp_setAckMode');
  conn pointer const;
  mode char(10) const;
end-pr;

dcl-pr stomp_getSessionId like(stomp_sessionid_t) extproc('stomp_getSessionId');
  conn pointer const;
end-pr;

dcl-pr stomp_setDurableSubscriberName extproc('stomp_setDurableSubscriberName');
  conn pointer const;
  name varchar(100) const;
end-pr;

dcl-pr stomp_setPersistMessages extproc('stomp_setPersistMessages');
  conn pointer const;
  value ind const;
end-pr;

dcl-pr stomp_getExtension pointer extproc('stomp_getExtension');
  conn pointer const;
end-pr;

dcl-pr stomp_setExtension extproc('stomp_setExtension');
  conn pointer const;
  extension pointer const;
end-pr;

dcl-pr stomp_setExtensionByName extproc('stomp_setExtensionByName');
  conn pointer const;
  extensionName char(10) const;
  userdata pointer const options(*nopass : *string);
  procedureName char(256) const options(*nopass);
end-pr;

dcl-pr stomp_useReceipts extproc('stomp_useReceipts');
  conn pointer const;
  value ind const;
end-pr;

dcl-pr stomp_isUsingReceipts ind extproc('stomp_isUsingReceipts');
  const pointer const;
end-pr;

dcl-pr stomp_getOptionValue pointer extproc('stomp_getOptionValue');
  conn pointer const;
  option int(10) const;
end-pr;

dcl-pr stomp_hasOption ind extproc('stomp_hasOption');
  conn pointer const;
  option int(10) const;
end-pr;

dcl-pr stomp_setSessionId extproc('stomp_setSessionId');
  conn pointer const;
  session like(stomp_sessionid_t) const;
end-pr;

dcl-pr stomp_addOpenReceipt extproc('stomp_addOpenReceipt');
  conn pointer const;
  receipt like(stomp_receiptid_t) const;
end-pr;

dcl-pr stomp_getNumberOfOpenReceipts int(10) extproc('stomp_getNumberOfOpenReceipts');
  conn pointer const;
end-pr;


//
// Templates
//
dcl-s stomp_sessionid_t char(100) template;
dcl-s stomp_receiptid_t varchar(50) template;


//
// Constants
//
dcl-c STOMP_ACK_MODE_AUTO 'auto';
dcl-c STOMP_ACK_MODE_CLIENT 'client';
dcl-c STOMP_OPTION_TIMEOUT 1;
dcl-c STOMP_OPTION_CLIENT_ID 2;
dcl-c STOMP_OPTION_ACK 3;
dcl-c STOMP_OPTION_PERSISTENT 4;
dcl-c STOMP_OPTION_DURABLE_SUBSCRIBER 5;
dcl-c STOMP_OPTION_CONTENT_TYPE 6;
dcl-c STOMP_OPTION_CHARSET 7;


/include 'stompframe_h.rpgle'
/include 'stompcmd_h.rpgle'
/include 'stompext_h.rpgle'
/include 'stompext_amq_h.rpgle'

/endif
