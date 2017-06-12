**FREE

/if not defined (STOMP_TEMPLATES)
/define STOMP_TEMPLATES

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
// Templates
//
dcl-ds stomp_header_t qualified template align;
   socket int(10);
   host char(255);
   port int(10);
   connected ind;
   options pointer;
   sessionId char(100);
   extension pointer;
   useReceipts ind;
   openReceipts pointer;
   bufferedFrames pointer;
end-ds;

/endif