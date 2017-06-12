**FREE

///
// Stomp : Frame Module
//
// This module provides procedures for creating and querying a stomp frame.
// <br><br>
// Log entries will be written via the logger <em>de.rpgng.stomp.frame</em>.
// There is no appender configured for this logger. Feel free to add log appenders
// for this logger.
//
// \author Mihael Schmidt
// \date   15.04.2011
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
// Prototypen
//
dcl-pr isValidFrame ind;
  frame pointer const;
end-pr;

/include 'stompframe_h.rpgle'
/include QLOG4RPG,PLOG4RPG
/include 'unicode_h.rpgle'
/include 'libc_h.rpgle'
/include 'libtree/libtree_h.rpgle'
/include 'message/message_h.rpgle'


//
// Global variables
//
dcl-ds commands_ds;
  command1 char(20) inz('CONNECT');
  command2 char(20) inz('SEND');
  command3 char(20) inz('SUBSCRIBE');
  command4 char(20) inz('UNSUBSCRIBE');
  command5 char(20) inz('BEGIN');
  command6 char(20) inz('COMMIT');
  command7 char(20) inz('ABORT');
  command8 char(20) inz('ACK');
  command9 char(20) inz('DISCONNECT');
  command10 char(20) inz('CONNECTED');
  command11 char(20) inz('MESSAGE');
  command12 char(20) inz('RECEIPT');
  command13 char(20) inz('ERROR');
  commands char(20) dim(13) pos(1);
end-ds;

dcl-s logger pointer;


//
// Templates
//
dcl-ds stomp_frame_header_t qualified template align;
  command like(stomp_frame_command);
  headers pointer;
  body pointer;
end-ds;


//
// Procedures
//

///
// Create stomp frame
//
// Creates a stomp frame and if the parameters are passed also initializes it.
//
// \param Stomp command (optional)
// \param Frame body text (optional)
//
// \info The resources allocated with this frame must be released by the caller
//       with the <em>stomp_frame_finalize</em> procedure.
///
dcl-proc stomp_frame_create export;
  dcl-pi *N pointer;
    command like(stomp_frame_command) const options(*nopass);
    pContent varchar(65335) const options(*nopass);
  end-pi;
  
  dcl-s frame pointer;
  dcl-ds header likeds(stomp_frame_header_t) based(frame);
  dcl-s null char(1) inz(x'00');
  dcl-s contentLength int(10);
  dcl-s content varchar(65535);
  
  if (logger = *null);
    logger = Logger_getLogger('com.rpgnextgen.stomp.frame');
  endif;
  
  frame = %alloc(%size(stomp_frame_header_t));
  
  header.command = *blank;
  header.headers = tree_rb_create(%paddr('tree_rb_string_compare'));
  header.body = *null;
  
  if (%parms() >= 1); // set command
    stomp_frame_setCommand(frame : command);
  endif;
  
  if (%parms() = 2);
    // content will be stored null-terminated
    content = pContent;
    contentLength = %len(content) + 1;
    header.body = %alloc(contentLength);
    memcpy(header.body : %addr(content : *DATA) : contentLength);
  endif;
  
  Logger_debug(logger : 'create frame');
  
  return frame;
end-proc;
  
  
///
// Finalize stomp frame
//
// Releases all resources allocated to the frame.
//
// \param Frame
///
dcl-proc stomp_frame_finalize export;
  dcl-pi *N;
    frame pointer;
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  if (frame = *null);
    return;
  endif;

  if (header.body <> *null);
    dealloc(n) header.body;
  endif;

  if (header.headers <> *null);
    tree_rb_string_finalize(header.headers);
  endif;

  Logger_debug(logger : 'frame disposed');
 
  dealloc(n) frame;
end-proc;


///
// Set stomp frame header value
//
// Sets a header (key and value) on the passed stomp frame.
// <br>
// If this header already exists its value will be replaced with the one passed.
//
// \todo If the header is already present in this frame it will be added after
//       the original header as the stomp protocol supports multiple version of
//       the same header. STOMP Spec 1.1
//
// \param Frame
// \param Stomp frame header (key)
// \param Value
///
dcl-proc stomp_frame_setHeader export;
  dcl-pi *N;
    frame pointer const;
    key like(stomp_frame_header) const;
    pValue varchar(1024) const;
  end-pi;
  
  dcl-s value varchar(1024);
  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  value = pValue;

  tree_rb_string_put(header.headers : key : %addr(value : *DATA) : %len(value));

  Logger_debug(logger : 'set header: ' + %trimr(key) + ' - ' + value);
end-proc;


///
// Remove stomp frame header
//
// Removes the header from the passed stomp frame.
// <br>
// If the header does not exist this procedure does nothing.
//
// \todo If the header is already present in this frame it will be added after
//       the original header as the stomp protocol supports multiple version of
//       the same header. STOMP Spec 1.1
//
// \param Frame
// \param Stomp frame header (key)
///
dcl-proc stomp_frame_removeHeader export;
  dcl-pi *N;
    frame pointer const;
    key like(stomp_frame_header) const;
  end-pi;

  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  tree_rb_string_remove(header.headers : key);

  Logger_debug(logger : 'removed header: ' + %trimr(key));
end-proc;


///
// Get stomp frame header value
//
// Returns the value from the passed header of the stomp frame.
//
// \param Frame
// \param Stomp frame header (key)
//
// \return Value
//
// \throws CPF9898 Header not found in stomp frame
///
dcl-proc stomp_frame_getHeaderValue export;
  dcl-pi *N varchar(1024);
    frame pointer const;
    key like(stomp_frame_header) const;
  end-pi;

  dcl-ds header likeds(stomp_frame_header_t) based(frame);
  dcl-ds node likeds(tree_node_string_t) based(nodePtr);
  dcl-s value varchar(1024);

  nodePtr = tree_rb_string_get(header.headers : key);
  if (nodePtr = *null);
      message_sendEscapeMessageToCaller('Header ' + key + ' not found in frame.');
  endif;

  value = %str(node.value);

  return value;
end-proc;


///
// Check if frame contains header
//
// Checks if the frame contains the header.
//
// \param Frame
// \param Header
//
// \return *on = frame contains header otherwise *off
///
dcl-proc stomp_frame_containsHeader export;
  dcl-pi *N ind;
    frame pointer const;
    key like(stomp_frame_header) const;
  end-pi;

  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  return tree_rb_string_containsKey(header.headers : key);
end-proc;


///
// List stomp frame headers
//
// Returns a map for stomp frame headers (key/value pairs).
//
// \param Frame
//
// \returns Map with headers
//
// \info The caller of this procedure must make sure to free the
//       allocated resources of the returnen map with
//       <em>tree_rb_string_finalize(map)</em>.
///
dcl-proc stomp_frame_listHeaders export;
  dcl-pi *N pointer;
    frame pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);
 
  dcl-s headers pointer;
  dcl-ds node likeds(tree_node_string_t) based(nodePtr);
  dcl-s key char(65535);

  headers = tree_rb_create(%paddr('tree_rb_string_compare'));

  nodePtr = tree_rb_string_first(header.headers);
  dow (nodePtr <> *null);
    memcpy(%addr(key) : node.key : node.keyLength);
    tree_rb_string_put(headers : %subst(key : 1 : node.keyLength) : node.value);
    nodePtr = tree_rb_string_next(nodePtr);
  enddo;

  return headers;
end-proc;


///
// Set command
//
// Sets the command in the stomp frame.
//
// \param Frame
// \param Command
//
// \throws CPF9898 Invalid stomp command
///
dcl-proc stomp_frame_setCommand export;
  dcl-pi *N;
     frame pointer const;
     command like(stomp_frame_command) const;
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);
 
  if (%lookup(command : commands) = 0);
    Logger_error(logger : 'invalid command: ' + command);
    message_sendEscapeMessageToCaller('Invalid stomp command');
  endif;

  header.command = command;
end-proc;


///
// Get command
//
// Returns the command of this stomp frame.
//
// \param Frame
//
// \return Command (is *blank if not set yet)
///
dcl-proc stomp_frame_getCommand export;
  dcl-pi *N like(stomp_frame_command);
    frame pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  return header.command;
end-proc;


///
// Set body/content
//
// Sets the body/content of this frame.
// <br>
// If this frame already contains a content the old content will be
// replaced by the new one.
//
// \param Frame
// \param Content (null-terminated)
///
dcl-proc stomp_frame_setBody export;
  dcl-pi *N;
    frame pointer const;
    body pointer const options(*string);
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);
  dcl-s contentLength int(10);

  // +1 to also store the terminating null value
  contentLength = strlen(body) + 1;

  if (header.body = *null);
    header.body = %alloc(contentLength);
  else;
    header.body = %realloc(header.body : contentLength);
  endif;

  memcpy(header.body : body : contentLength);

  Logger_debug(logger : 'set body: ' + %str(body));
end-proc;


///
// Return message body
//
// Returns a pointer to the body text of this frame.
// The string is null-terminated.
//
// \param Frame
//
// \return Pointer to message body (may be null if not set)
///
dcl-proc stomp_frame_getBody export;
  dcl-pi *N pointer;
    frame pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  return header.body;
end-proc;


///
// String representation of a stomp frame
//
// Returns a string representation of this stomp frame.
// The string is encoded in the CCSID of the current job.
//
// \param Frame
//
// \return Pointer to the string (null-terminated) or null if the pointer to
//         the frame is null.
//
// \info The caller must take of releasing the allocated memory of the returned string.
//
// \throws CPF9898 Stomp frame is not valid
///
dcl-proc stomp_frame_toString export;
  dcl-pi *N pointer;
    frame pointer const;
  end-pi;

  dcl-ds header likeds(stomp_frame_header_t) based(frame);
  dcl-s length int(10);
  dcl-s index int(10);
  dcl-s string pointer;
  dcl-s null char(1) inz(x'00');
  dcl-s crlf char(2) inz(x'0d25');
  dcl-ds node likeds(tree_node_string_t) based(nodePtr);
  dcl-s colon char(1);
  
  colon = UNICODE_COLON;
  
  if (not isValidFrame(frame));
    message_sendEscapeMessageToCaller('Stomp frame is not valid');
  endif;
  
  length = %len(header.command) + 2; // +2 => CRLF
  
  // calculate length for headers
  nodePtr = tree_rb_string_first(header.headers);
  dow (nodePtr <> *null);
    length += node.keyLength + 1 + node.length + 2; // key:value + CRLF
    nodePtr = tree_rb_string_next(nodePtr);
  enddo;
  
  length += 2; // +2 => CRLF => seperator between header and body
  
  if (header.body <> *null);
    length += strlen(header.body) + 1; // + 1 => frame ending null character
  endif;
  
  string = %alloc(length);
  
  // add command
  memcpy(string + index : %addr(header.command : *DATA) : %len(header.command));
  index += %len(header.command);
  memcpy(string + index : %addr(crlf) : 2);
  index += 2;
  
  // add headers
  nodePtr = tree_rb_string_first(header.headers);
  dow (nodePtr <> *null);
    memcpy(string + index : node.key : node.keyLength);
    index += node.keyLength;
    memcpy(string + index : %addr(colon) : 1);
    index += 1;
    memcpy(string + index : node.value : node.length);
    index += node.length;
    memcpy(string + index : %addr(crlf) : 2);
    index += 2;
    nodePtr = tree_rb_string_next(nodePtr);
  enddo;
  
  // add a new line
  memcpy(string + index : %addr(crlf) : 2);
  index += 2;
  
  // add content/body
  if (header.body <> *null);
    memcpy(string + index : header.body : strlen(header.body));
    index += strlen(header.body);
  endif;
  
  // add terminating null
  memcpy(string + index : %addr(null) : 1);
  
  return string;
end-proc;


///
// Dump frame to job log
//
// Outputs the passed frame as an INFO message to the job log.
//
// \param Frame
///
dcl-proc stomp_frame_dump export;
  dcl-pi *N;
    frame pointer const;
  end-pi;
  
  dcl-s ptr pointer;

  ptr = stomp_frame_toString(frame);

  message_sendInfoMessage('FRAMEDUMP: ' + %str(ptr));

  dealloc ptr;
end-proc;


///
// Validate frame
//
// Checks if this frame is a valid stomp frame.
//
// \param Frame
//
// \return *on = valid stomp frame <br>
//         *off = invalid stomp frame
///
dcl-proc isValidFrame;
  dcl-pi *N ind;
    frame pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  if (header.command = *blank);
    return *off;
  endif;

  // check if it is a valid command
  if (%lookup(header.command : commands) = 0); // 0 = not found
    return *off;
  endif;

  return *on;
end-proc;
