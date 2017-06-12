**FREE

///
// Stomp : Utilities module
//
//
// \author Mihael Schmidt
// \date   18.04.2011
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
/include 'iconv_h.rpgle'
/include 'stomputil_h.rpgle'
/include 'filedesc_h.rpgle'
/include 'socket_h.rpgle'
/include 'message/message_h.rpgle'
/include 'libc_h.rpgle'
/include 'errno_h.rpgle'


//
// Procedures
//

dcl-proc translateToAscii export;
  dcl-pi *N;
    string pointer;
    pLength uns(10) const;
  end-pi;

  dcl-ds iconv_table likeds(iconv_t) static;
  dcl-s isInit ind inz(*off) static;
  dcl-s length uns(10);

  dcl-ds iconv_from qualified;
    ccsid int(10) inz(0);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;
  
  dcl-ds iconv_to qualified;
    ccsid int(10) inz(819);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;
  
  length = pLength;
  
  if (not isInit);
    iconv_table = iconv_open(iconv_to : iconv_from);
    if (iconv_table.return_value = -1);
      message_sendEscapeMessageToCaller('Could not init iconv data structure.');
    endif;
  endif;
  
  if (iconv(iconv_table : string : length : string : length) = -1);
    message_sendEscapeMessageToCaller('Error converting data.');
  endif;
  
  iconv_close(iconv_table);
end-proc;


dcl-proc translateFromAscii export;
  dcl-pi *N;
    string pointer;
    pLength uns(10) const;
  end-pi;
  
  dcl-ds iconv_table likeds(iconv_t) static;
  dcl-s isInit ind inz(*off) static;
  dcl-s length uns(10);

  dcl-ds iconv_from qualified;
    ccsid int(10) inz(819);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  dcl-ds iconv_to qualified;
    ccsid int(10) inz(0);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  length = pLength;
  
  if (not isInit);
    iconv_table = iconv_open(iconv_to : iconv_from);
    if (iconv_table.return_value = -1);
      message_sendEscapeMessageToCaller('Could not init iconv data structure.');
    endif;
  endif;
  
  if (iconv(iconv_table : string : length : string : length) = -1);
    message_sendEscapeMessageToCaller('Error converting data.');
  endif;
  
  iconv_close(iconv_table);
end-proc;


dcl-proc translateToUtf8 export;
  dcl-pi *N;
    string pointer;
    pLength uns(10) const;
  end-pi;

  dcl-ds iconv_table likeds(iconv_t) static;
  dcl-s isInit ind inz(*off) static;
  dcl-s length uns(10);

  dcl-ds iconv_from qualified;
    ccsid int(10) inz(0);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;
  
  dcl-ds iconv_to qualified;
    ccsid int(10) inz(1208);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  dcl-s rc int(20);

 length = pLength;

 if (not isInit);
   iconv_table = iconv_open(iconv_to : iconv_from);
   if (iconv_table.return_value = -1);
     message_sendEscapeMessageToCaller('Could not init iconv data structure.');
   endif;
 endif;

  rc = iconv(iconv_table : string : length : string : length);
  if (rc = -1);
    message_sendEscapeMessageToCaller('Error converting data.');
  endif;
  
  iconv_close(iconv_table);
end-proc;


dcl-proc translateFromUtf8 export;
  dcl-pi *N;
    string pointer;
    pLength uns(10) const;
  end-pi;

  dcl-ds iconv_table likeds(iconv_t) static;
  dcl-s isInit ind inz(*off) static;
  dcl-s length uns(10);

  dcl-ds iconv_from qualified;
    ccsid int(10) inz(1208);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  dcl-ds iconv_to qualified;
    ccsid int(10) inz(0);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  length = pLength;

  if (not isInit); 
    iconv_table = iconv_open(iconv_to : iconv_from);
    if (iconv_table.return_value = -1);
      message_sendEscapeMessageToCaller('Could not init iconv data structure.');
    endif;
  endif;

  if (iconv(iconv_table : string : length : string : length) = -1);
    message_sendEscapeMessageToCaller('Error converting data.');
  endif;

  iconv_close(iconv_table);
end-proc;


dcl-proc non_blocking_receive export;
  dcl-pi *N int(10);
    socket int(10);
    buffer pointer;
    size uns(10) const;
    timeout likeds(timeout_t);
  end-pi;
  
  dcl-s readset like(fdset);
  dcl-s rc int(10);
  dcl-s err int(10) based(p_err);

  p_err = c__errno();
 
  rc = recv(socket : buffer: size: 0);
  if (rc <> -1);
    return rc;
  endif;
 
  if (err <> EWOULDBLOCK);
    return rc;
  endif;
 
  // -----------------------------------
  //  Wait until socket is readable
  // -----------------------------------
 
  filedesc_clearInit(readset);
  filedesc_set(socket : readset);
 
  rc = select( socket + 1          // descriptor count    ??? is this correct ???
             : %addr(readset)      // read set
             : *null               // write set
             : *null               // exception set
             : %addr(timeout) );   // timeout
  select;
    when rc = 0;
      err = ETIME;
      return -1;
    when rc = -1;
      return -1;
    when rc > 0;
      return recv(socket : buffer : size : 0);
  endsl;
 
  return -1;
end-proc;


dcl-proc non_blocking_send export;
  dcl-pi *N int(10);
    socket int(10);
    buffer pointer;
    size uns(10) const;
    timeout likeds(timeout_t);
  end-pi;

  dcl-s writeset like(fdset);
  dcl-s rc int(10);
  dcl-s err int(10) based(p_err);

  p_err = c__errno();
  
  rc = recv(socket : buffer: size: 0);
  if (rc <> -1);
    return rc;
  endif;
  
  if (err <> EWOULDBLOCK);
    return rc;
  endif;
  
  // -----------------------------------
  //  Wait until socket is readable
  // -----------------------------------
  
  filedesc_clearInit(writeset);
  filedesc_set(socket : writeset);
  
  rc = select( socket + 1         // descriptor count    ??? is this correct ???
             : *null              // read set
             : %addr(writeset)    // write set
             : *null              // exception set
             : %addr(timeout) );  // timeout
  select;
    when rc = 0;
      err = ETIME;
      return -1;
    when rc = -1;
      return -1;
    when rc > 0;
      return send(socket : buffer : size : 0);
  endsl;
 
  return -1;
end-proc;
 