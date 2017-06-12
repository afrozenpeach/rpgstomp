**FREE

/if not defined (STOMP_UTIL_H)
/define STOMP_UTIL_H

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
dcl-pr translateToAscii;
  string pointer;
  length uns(10) const;
end-pr;

dcl-pr translateFromAscii;
  string pointer;
  length uns(10) const;
end-pr;

dcl-pr translateToUtf8;
  string pointer;
  length uns(10) const;
end-pr;

dcl-pr translateFromUtf8;
  string pointer;
  length uns(10) const;
end-pr;

dcl-pr non_blocking_receive int(10);
  socket int(10);
  buffer pointer;
  size uns(10) const;
  timeout likeds(timeout_t);
end-pr;

dcl-pr non_blocking_send int(10);
  socket int(10);
  buffer pointer;
  size uns(10) const;
  timeout likeds(timeout_t);
end-pr;

/endif

