**FREE

/if not defined(STOMP_FRAME_H)
/define STOMP_FRAME_H

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
dcl-pr stomp_frame_create pointer extproc('stomp_frame_create');
  command like(stomp_frame_command) const options(*nopass);
  body varchar(65335) const options(*nopass);
end-pr;

dcl-pr stomp_frame_finalize extproc('stomp_frame_finalize');
  frame pointer;
end-pr;

dcl-pr stomp_frame_setHeader extproc('stomp_frame_setHeader');
  frame pointer const;
  header like(stomp_frame_header) const;
  value varchar(1024) const;
end-pr;

dcl-pr stomp_frame_getHeaderValue varchar(1024) extproc('stomp_frame_getHeader');
  frame pointer const;
  header like(stomp_frame_header) const;
end-pr;

dcl-pr stomp_frame_listHeaders pointer extproc('stomp_frame_listHeaders');
  frame pointer const;
end-pr;

dcl-pr stomp_frame_removeHeader extproc('stomp_frame_removeHeader');
  frame pointer const;
  header like(stomp_frame_header) const;
end-pr;

dcl-pr stomp_frame_setCommand extproc('stomp_frame_setCommand');
  frame pointer const;
  command like(stomp_frame_command) const;
end-pr;

dcl-pr stomp_frame_getCommand like(stomp_frame_command) extproc('stomp_frame_getCommand');
  frame pointer const;
end-pr;

dcl-pr stomp_frame_setBody extproc('stomp_frame_setBody');
  frame pointer const;
  body pointer const options(*string);
end-pr;

dcl-pr stomp_frame_getBody pointer extproc('stomp_frame_getBody');
  frame pointer const;
end-pr;

dcl-pr stomp_frame_toString pointer extproc('stomp_frame_toString');
  frame pointer const;
end-pr;

dcl-pr stomp_frame_containsHeader ind extproc('stomp_frame_containsHeader');
  frame pointer const;
  header like(stomp_frame_header) const;
end-pr;

dcl-pr stomp_frame_dump extproc('stomp_frame_dump');
  frame pointer const;
end-pr;


//
// Templates
//
dcl-s stomp_frame_header varchar(50) template;
dcl-s stomp_frame_command varchar(20) template;

/endif
