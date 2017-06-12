**FREE

///
// File descriptor utility procedures
//
// \author Mihael Schmidt
// \date   14.04.2011
//
// \info Original author is Scott Klement (http://www.scottklement.com)
///

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

ctl-opt nomain;

//
// Prototypes
//
/include 'filedesc_h.rpgle'


//
// Procedures
//

///
// Set file descriptor on
//
// Set a File Descriptor in a set ON...  for use w/Select()
//
// \param fd = descriptor to set on
// \param set = descriptor set
///
dcl-proc filedesc_set export;
  dcl-pi *N;
    fd int(10);
    set like(fdset);
  end-pi;

  dcl-s s uns(10);
  dcl-s c uns(10) based(p);

  p = %addr(set) + (%div(fd:32) * %size(c));
  s = 2 ** %rem(fd:32);
  c = %bitor(c:s);
end-proc;        


///
// Set file descriptor off
//
// Set a File Descriptor in a set OFF...  for use w/Select()
//
// \param fd = descriptor to set off
// \param  set = descriptor set
///
dcl-proc filedesc_clear export;
  dcl-pi *N;
    fd int(10);
    set like(fdset);
  end-pi;
  
  dcl-s s uns(10);
  dcl-s c uns(10) based(p);

  p = %addr(set) + (%div(fd:32) * %size(c));
  s = 2 ** %rem(fd:32);
  c = %bitand(c:%bitnot(s));
end-proc;


///
// Get file descriptor state
//
// Determine if a file desriptor is on or off.
//
// \param fd = descriptor to check
// \param set = descriptor set
//
// \return Returns *ON if its on, or *OFF if its off.
///
dcl-proc filedesc_isSet export;
  dcl-pi *N ind;
    fd int(10);
    set like(fdset);
  end-pi;
  
  dcl-s s uns(10);
  dcl-s c uns(10) based(p);
  dcl-s r uns(10);

  p = %addr(set) + (%div(fd:32) * %size(c));
  s = 2 ** %rem(fd:32);
  r = %bitand(c:s);
  return (r = s);
end-proc;


///
// Clear and initialize all descriptors
//
// Clear All descriptors in a set.  (also initializes at start)
//
// \param set = descriptor set
// \param size
///
dcl-proc filedesc_clearInit export;
  dcl-pi *N;
    set char(32767) options(*varsize);
    setsize int(10) value options(*nopass);
  end-pi;

  dcl-s size int(10) inz(%size(fdset));

  if %parms>=2;
    size = setsize;
  endif;

  %subst(set:1:size) = *ALLx'00';
end-proc;
