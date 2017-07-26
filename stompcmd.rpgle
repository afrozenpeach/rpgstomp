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
// Prototypes
//
/include 'stomp_h.rpgle'
/include 'stompext_h.rpgle'
/include 'stomputil_h.rpgle'
/include 'stompcmd_h.rpgle'
/include 'stompframe_h.rpgle'
/include 'socket_h.rpgle'
/include QLOG4RPG,PLOG4RPG
/include 'libc_h.rpgle'


//
// Global Variables
//
dcl-s logger pointer;


//
// Constants
//
dcl-c NULL x'00';
dcl-c CRLF x'0d25';


//
// Procedures
//

dcl-proc stomp_command_connect export;
  dcl-pi *N ind;
    conn pointer const;
    user varchar(100) const options(*nopass);
    pass varchar(100) const options(*nopass);
  end-pi;
  
  dcl-s frame pointer;
  dcl-s returnFrame pointer;
  dcl-s retVal ind;
  dcl-s alreadyConnected char(20);
  dcl-s alreadyConnPtr pointer;
  dcl-s rc int(10);
  dcl-s optionPtr pointer;

  if (logger = *null);
    logger = Logger_getLogger('rpgnextgen.stomp.command');
  endif;

  frame = stomp_frame_create('CONNECT');
  if (%parms() >= 2);
    stomp_frame_setHeader(frame : 'login' : user);
  endif;
  if (%parms() = 3);
    stomp_frame_setHeader(frame : 'passcode' : pass);
  endif;
  
  if (stomp_hasOption(conn : STOMP_OPTION_CLIENT_ID));
    optionPtr = stomp_getOptionValue(conn : STOMP_OPTION_CLIENT_ID);
    stomp_frame_setHeader(frame : 'client-id' :  %str(optionPtr));
  endif;
  
  if (stomp_getExtension(conn) <> *null);
    stomp_ext_connect(stomp_getExtension(conn) : conn : frame : user:pass);
  endif;
  
  stomp_sendFrame(conn : frame);
  stomp_frame_finalize(frame);
  
  returnFrame = stomp_receiveFrame(conn);
  if (returnFrame = *null);
    retVal = *off;
  else;
  
    if (stomp_frame_getCommand(returnFrame) = 'CONNECTED');
      retVal = *on;
      if (stomp_frame_containsHeader(returnFrame : 'session'));
        stomp_setSessionId(conn :
            stomp_frame_getHeaderValue(returnFrame : 'session'));
      endif;
  
    // TODO replace this hack (CONNECT on already connected session)
    elseif (stomp_frame_getCommand(returnFrame) = 'ERROR');
      alreadyConnected = 'already connected' + x'00';
      alreadyConnPtr = strstr(stomp_frame_getBody(returnFrame) :
                  %addr(alreadyConnected));
      if (alreadyConnPtr <> *null);
        retVal = *on;
      endif;
  
    endif;
  
    stomp_frame_finalize(returnFrame);
  endif;
  
  Logger_info(logger : 'connected to messaging system');
  
  return retVal;
end-proc;


dcl-proc stomp_command_disconnect export;
  dcl-pi *N;
    conn pointer const;
  end-pi;
  
  dcl-s frame pointer;

  // create frame/message
  frame = stomp_frame_create('DISCONNECT');

  if (stomp_getExtension(conn) <> *null);
    stomp_ext_disconnect(stomp_getExtension(conn) : conn : frame);
  endif;

  stomp_sendFrame(conn : frame);
  stomp_frame_finalize(frame);

  stomp_setSessionId(conn : *blank);

  Logger_info(logger : 'disconnected');
end-proc;


dcl-proc stomp_command_send export;
  dcl-pi *N;
    conn pointer const;
    queue varchar(100) const;
    message pointer const options(*string);
  end-pi;
  
  dcl-s frame pointer;
  dcl-s optionPtr pointer;

  frame = stomp_frame_create('SEND');
  stomp_frame_setBody(frame : message);
  stomp_frame_setHeader(frame : 'destination' : queue);
  stomp_frame_setHeader(frame : 'content-length' : %char(strlen(message)));
 
  if (stomp_hasOption(conn : STOMP_OPTION_PERSISTENT));
    optionPtr = stomp_getOptionValue(conn : STOMP_OPTION_PERSISTENT);
    stomp_frame_setHeader(frame : 'persistent' :  %str(optionPtr));
  endif;
 
  if (stomp_hasOption(conn : STOMP_OPTION_CONTENT_TYPE));
    optionPtr = stomp_getOptionValue(conn : STOMP_OPTION_CONTENT_TYPE);
    stomp_frame_setHeader(frame : 'content-type' : %str(optionPtr));
  endif;
 
  // TODO support charset 'application/json; charset=ASCII');
 
  if (stomp_getExtension(conn) <> *null);
    stomp_ext_send(stomp_getExtension(conn) : conn : frame:queue:message);
  endif;
 
  stomp_sendFrame(conn : frame);
 
  stomp_frame_finalize(frame);
 
  Logger_debug(logger : 'sent frame SEND');
end-proc;


dcl-proc stomp_command_subscribe export;
  dcl-pi *N;
    conn pointer const;
    queue varchar(100) const;
  end-pi;
  
  dcl-s frame pointer;
  dcl-s optionPtr pointer;

  frame = stomp_frame_create('SUBSCRIBE');
  stomp_frame_setHeader(frame : 'destination' : queue);

  if (stomp_hasOption(conn : STOMP_OPTION_DURABLE_SUBSCRIBER));
    optionPtr = stomp_getOptionValue(conn:STOMP_OPTION_DURABLE_SUBSCRIBER);
    stomp_frame_setHeader(frame : 'durable-subscriber-name' : %str(optionPtr));
  endif;
 
  if (stomp_hasOption(conn : STOMP_OPTION_ACK));
    optionPtr = stomp_getOptionValue(conn : STOMP_OPTION_ACK);
    stomp_frame_setHeader(frame : 'ack' : %str(optionPtr));
  endif;
 
  if (stomp_getExtension(conn) <> *null);
    stomp_ext_subscribe(stomp_getExtension(conn) : conn : frame : queue);
  endif;
 
  stomp_sendFrame(conn : frame);
 
  stomp_frame_finalize(frame);
 
  Logger_info(logger : 'subscribed to ' + queue);
end-proc;


dcl-proc stomp_command_unsubscribe export;
  dcl-pi *N;
    conn pointer const;
    queue varchar(100) const;
  end-pi;
  
  dcl-s frame pointer;

  frame = stomp_frame_create('UNSUBSCRIBE');
  stomp_frame_setHeader(frame : 'destination' : queue);
  
  if (stomp_getExtension(conn) <> *null);
    stomp_ext_unsubscribe(stomp_getExtension(conn) : conn : frame : queue);
  endif;
  
  stomp_sendFrame(conn : frame);
  
  stomp_frame_finalize(frame);
  
  Logger_info(logger : 'unsubscribed from ' + queue);
end-proc;
