**FREE


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
    logger = Logger_getLogger('rpgnextgen.stomp.frame');
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


dcl-proc stomp_frame_removeHeader export;
  dcl-pi *N;
    frame pointer const;
    key like(stomp_frame_header) const;
  end-pi;

  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  tree_rb_string_remove(header.headers : key);

  Logger_debug(logger : 'removed header: ' + %trimr(key));
end-proc;


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


dcl-proc stomp_frame_containsHeader export;
  dcl-pi *N ind;
    frame pointer const;
    key like(stomp_frame_header) const;
  end-pi;

  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  return tree_rb_string_containsKey(header.headers : key);
end-proc;


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


dcl-proc stomp_frame_getCommand export;
  dcl-pi *N like(stomp_frame_command);
    frame pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  return header.command;
end-proc;


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


dcl-proc stomp_frame_getBody export;
  dcl-pi *N pointer;
    frame pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_frame_header_t) based(frame);

  return header.body;
end-proc;


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
