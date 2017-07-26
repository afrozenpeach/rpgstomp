**FREE

///
// STOMP : Frame Parser
//
// This module parses serialized stomp frames and returns frame <em>objects</em>.
// <br><br>
// This module uses the logger <em>de.rpgng.stomp.parser</em>.
// There is no appender configured for this logger. Feel free to add log appenders
// for this logger.
//
// \author Mihael Schmidt
// \date   26.07.2017
//
///


//                          The MIT License (MIT)
// 
// Copyright (c) 2017 Mihael Schmidt
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.

// TODO check for CR / LF / CRLF


ctl-opt nomain;


//
// Prototypes
//
dcl-pr getNextLineLength int(10) extproc('getNextLineLength');
  ptr pointer const;
end-pr;

dcl-pr addHeader extproc('addHeader');
  frame pointer const;
  data pointer;
  length int(10) const;
end-pr;

/include 'stompframe_h.rpgle'
/include 'stompparser_h.rpgle'
/include QLOG4RPG,PLOG4RPG
/include 'libc_h.rpgle'


//
// Constants
//
dcl-c CRLF x'0d25';
dcl-c CR x'0d';
dcl-c LF x'25';


//
// Global Variables
//
dcl-s logger pointer;


//
// Procedures
//

///
// Parse frame
//
// Parses the content starting from the passed pointer to the first null byte.
//
// \param Data (null-terminated)
//
// \return Pointer to a frame or *null if there was a problem parsing the data
//
// \throws CPF9898 Invalid stomp command
///
dcl-proc stomp_frame_parse export;
  dcl-pi *N pointer;
    pData pointer const;
  end-pi;
  
  dcl-s null char(1) inz(x'00');
  dcl-s tmp pointer;
  dcl-s data pointer;
  dcl-s frame pointer;
  dcl-s length int(10);
  dcl-s command char(100) based(data);

  if (logger = *null);
    logger = Logger_getLogger('com.rpgnextgen.stomp.parser');
  endif;
  
  data = pData;
  frame = stomp_frame_create();
  
  // get command
  length = getNextLineLength(data);
  if (length > 0);
    stomp_frame_setCommand(frame : %subst(command : 1 : length));
    Logger_debug(logger : 'frame command: ' + %subst(command : 1 :length));
  else;
    Logger_error(logger : 'invalid frame: no command => dropping frame');
    stomp_frame_finalize(frame);
    return *null;
  endif;
  
  // get headers
  data += length + 1; // TODO 1 = line separator , might be 1 or 2 characters
  length = getNextLineLength(data);
  dow (length > 0);
    addHeader(frame : data : length);
    data += length + 1; // TODO 1 = line separator , might be 1 or 2 characters
    length = getNextLineLength(data);
  enddo;
  
  // empty line separates headers and message body
  
  // get body
  data += length + 1; // TODO 1 = line separator , might be 1 or 2 characters
  length = getNextLineLength(data);
  
  if (length > 0);
    tmp = %alloc(length);
    memcpy(tmp : data : length + 1);
    memcpy(tmp + length : %addr(null) : 1);
    stomp_frame_setBody(frame : tmp);
    Logger_debug(logger : 'set frame body: ' + %str(data));
    dealloc(n) tmp;
  else;
    Logger_debug(logger : 'frame got no body');
  endif;
  
  return frame;
end-proc;


dcl-proc getNextLineLength;
  dcl-pi *N int(10);
    ptr pointer const;
  end-pi;
  
  dcl-s index int(10);
  dcl-s CR char(1) inz(x'0d');
  dcl-s LF char(1) inz(x'25');
 
  index = strcspn(ptr : %addr(LF));
 
  // TODO check if the next char is CR / LF / CRLF
 
  return index;
end-proc;
 
 
dcl-proc addHeader;
  dcl-pi *N;
    frame pointer const;
    data pointer;
    length int(10) const;
  end-pi;
  
  dcl-s index int(10);
  dcl-s colon char(1) inz(':');
  dcl-s key char(100);
  dcl-s value char(100);

  index = strcspn(data : %addr(colon));
  if (index < length); // index is 0-based
    memcpy(%addr(key) : data : index);
    memcpy(%addr(value) : data + index + 1 : length - index - 1);
    stomp_frame_setHeader(frame : %trimr(key) : %trimr(value));
    Logger_debug(logger : 'added header:' + %trim(key) + ' - ' +
                           %trimr(value));
  else;
    if (length > 0);
      memcpy(%addr(value) : data : length);
    else;
      clear value;
    endif;
 
    Logger_error(logger : 'dropping invalid header: ' + value);
  endif;
end-proc;
