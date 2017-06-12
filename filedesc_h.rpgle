**FREE

/if not defined(STOMP_FILEDESC_H)
/define STOMP_FILEDESC_H

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

//-------------------------------------------------------------------------
// fdset = definition of a set of file descriptors
//         (or socket descriptors)
//
//  By default, an fdset is 28 bytes long.  Each bit supports
//  one descriptor, so by default you can have up to 224
//  descriptors in a set.
//
//  If needed, you can increase the size of a descriptor set
//  by defining your own.  If you do that, you need to follow
//  these rules:
//       a) The descriptor set has to be an even multiple of
//            4 bytes long.
//       b) Never make your set less than 28 bytes.
//       c) When you call FD_ZERO, you must use the 2nd parm
//            to tell it how many bytes long your set is.
//       d) You must redefine it before you /copy or /include
//            this member.
//
//  For example:
//
//         /define USER_FDSET_SIZE
//        D fdset           s             64A
//         /copy SOCKUTIL_H
//
//  The preceding code snippet would allow up to 512 descriptors.
//  When I want to zero the set, I'd code:
//
//       callp FD_ZERO(fdset: %size(fdset))
//
//  You only need to redefine fdset if you need more than 224
//  descriptors.  Otherwise, the definition below will suffice.
//-------------------------------------------------------------------------
/if not defined(USER_FDSET_SIZE)
dcl-s fdset char(28);
/endif

//-------------------------------------------------------------------------
// Set a File Descriptor in a set ON...  for use w/Select()
//
//      fd = descriptor to set on
//      set = descriptor set
//-------------------------------------------------------------------------
dcl-pr filedesc_set extproc('filedesc_set');
  fd int(10);
  set like(fdset);
end-pr;


//-------------------------------------------------------------------------
// Set a File Descriptor in a set OFF...  for use w/Select()
//
//      fd = descriptor to set off
//      set = descriptor set
//-------------------------------------------------------------------------
dcl-pr filedesc_clear extproc('filedesc_clear');
  fd int(10);
  set like(fdset);
end-pr;


//-------------------------------------------------------------------------
// Determine if a file desriptor is on or off...
//
//      fd = descriptor to set off
//      set = descriptor set
//
//   Returns *ON if its on, or *OFF if its off.
//-------------------------------------------------------------------------
dcl-pr filedesc_isSet ind extproc('filedesc_isSet');
  fd int(10);
  set like(fdset);
end-pr;

//-------------------------------------------------------------------------
// Clear All descriptors in a set.  (also initializes at start)
//
//      set = descriptor set
//  setsize = size of descriptor set (in bytes)
//-------------------------------------------------------------------------
dcl-pr filedesc_clearInit extproc('filedesc_clearInit');
  set char(32767) options(*varsize);
/if defined(USER_FDSET_SIZE)
  setsize int(10) value;
/else
  setsize int(10) value options(*nopass);
/endif
end-pr;

/endif

