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


// TODO support for more than CCSID 819 (f. e. utf8) (umlaute?!)
// TODO support for optional charset
// TODO support for stomp spec 1.1
// TODO support for stomp spec 1.2
// TODO max receiving frame size is 65535
// TODO use set timeout for net communications (send/recv)


ctl-opt nomain;


//
// Prototypes
//
dcl-pr waitForReceipts extproc('waitForReceipts');
  conn pointer const;
end-pr;

dcl-pr ackMessage;
  conn pointer const;
  frame pointer const;
end-pr;

/define SOCKET_UNIX98

/include 'stomp_h.rpgle'
/include 'stompframe_h.rpgle'
/include 'stomputil_h.rpgle'
/include 'stompparser_h.rpgle'
/include 'stompext_h.rpgle'
/include QLOG4RPG,PLOG4RPG
/include 'net_h.rpgle'
/include 'socket_h.rpgle'
/include 'message/message_h.rpgle'
/include 'libc_h.rpgle'
/include 'errno_h.rpgle'
/include 'libtree/libtree_h.rpgle'
/include 'llist/llist_h.rpgle'


//
// Templates
//
/include 'stomp_t.rpgle'


//
// Global Variables
//
dcl-s logger pointer;


//
// Procedures
//

dcl-proc stomp_create export;
  dcl-pi *N pointer;
    host varchar(255) const;
    port int(10) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(ptr);
  dcl-s flags int(10);
  dcl-s c_err int(10) based(errPtr);

  ptr = %alloc(%size(stomp_header_t));
 
  clear header;
  header.host = host;
  header.port = port;
  header.connected = *off;
  header.extension = *null;
  header.useReceipts = *off;
  header.options = tree_rb_create(%paddr('tree_rb_int_compare'));
  header.openReceipts = list_create();
  header.bufferedFrames = list_create();
 
  header.socket = socket(AF_INET : SOCK_STREAM : PROTOCOL_DEFAULT);
  if (header.socket = -1);
    errPtr = errno();
    message_sendEscapeMessageToCaller(
    	'Could not create socket. ' + %char(c_err) + ': ' + %str(strerror(c_err)));
  endif;
 
  if (logger = *null);
    logger = Logger_getLogger('rpgnextgen.stomp');
  endif;
 
  Logger_info(logger : 'stomp client created');
 
  return ptr;
end-proc;


dcl-proc stomp_open export;
  dcl-pi *N;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-ds socket_address_inet likeds(socket_address_inet_t);
  dcl-s c_err int(10) based(errPtr);
  dcl-ds node likeds(tree_node_int_t) based(nodePtr);
  dcl-ds timeout likeds(timeout_t) based(node.value);
     
  clear socket_address_inet;
  socket_address_inet.family = AF_INET;
  socket_address_inet.addr = inet_addr(%trim(header.host));
  socket_address_inet.port = header.port;
  socket_address_inet.zero = *allx'00';
  
  if (connect(header.socket : %addr(socket_address_inet) :
              %size(socket_address_inet)) = -1);
    errPtr = errno();
    message_sendEscapeMessageToCaller(
        'Could not open socket connection. ' + %char(c_err) + ': ' + %str(strerror(c_err)));
  endif;
  
  // set timeout
  if (tree_rb_int_containsKey(header.options : STOMP_OPTION_TIMEOUT));
    nodePtr = tree_rb_int_get(header.options : STOMP_OPTION_TIMEOUT);
    
    if (setsockopt(header.socket : SOL_SOCKET: SO_RCVTIMEO : %addr(timeout) : %size(timeout)) = -1);
      errPtr = errno();
      message_sendEscapeMessageToCaller(
        'Could not set socket timeout. ' + %char(c_err) + ': ' + %str(strerror(c_err)));
    endif;
  endif;
       
  header.connected = *on;
  
  Logger_info(logger : 'socket connection established to ' +
                        %trimr(header.host) + ':' + %char(header.port));
end-proc;


dcl-proc stomp_close export;
  dcl-pi *N;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  if (header.connected);
    callp close(header.socket);
    header.connected = *off;
  endif;

  Logger_info(logger : 'socket connection closed');
end-proc;


dcl-proc stomp_finalize export;
  dcl-pi *N;
    conn pointer;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  if (header.connected);
    // close socket
    stomp_close(conn);
  endif;

  tree_rb_int_finalize(header.options); 

  if (header.extension <> *null);
    stomp_ext_finalize(header.extension);
  endif;

  list_dispose(header.openReceipts);
  list_dispose(header.bufferedFrames);

  Logger_info(logger : 'stomp client disposed');

  dealloc(n) conn;
end-proc;


dcl-proc stomp_setTimeout export;
  dcl-pi *N;
    conn pointer const;
    mseconds int(10) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-ds timeout likeds(timeout_t);

  timeout.seconds = mseconds / 1000;
  timeout.useconds = %rem(mseconds : 1000) * 1000;
  tree_rb_int_put(header.options : STOMP_OPTION_TIMEOUT :
                  %addr(timeout) : %size(timeout));
  Logger_debug(logger : 'set timeout: ' + %char(mseconds) + 'ms');
end-proc;


dcl-proc stomp_setVirtualHost export;
  dcl-pi *N;
    conn pointer const;
    pVirtualHost varchar(100) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s virtualHost varchar(100);

  virtualHost = pVirtualHost;
  tree_rb_int_put(header.options : STOMP_OPTION_VIRTUAL_HOST :
                  %addr(virtualHost : *DATA) : %len(virtualHost));
  Logger_debug(logger : 'set virtual host: ' + pVirtualHost);
end-proc;


dcl-proc stomp_setClientId export;
  dcl-pi *N;
    conn pointer const;
    pClientId varchar(100) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s clientId varchar(100);

  clientId = pClientId;
  tree_rb_int_put(header.options : STOMP_OPTION_CLIENT_ID :
                  %addr(clientId : *DATA) : %len(clientId));
  Logger_debug(logger : 'set client id: ' + pClientId);
end-proc;


dcl-proc stomp_setAckMode export;
  dcl-pi *N;
    conn pointer const;
    pMode char(10) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s mode char(10);

  mode = pMode;
  tree_rb_int_put(header.options : STOMP_OPTION_ACK :
                  %addr(mode) : %len(%trimr(mode)));
  Logger_debug(logger : 'set ack mode: ' + pMode);
end-proc;


dcl-proc stomp_setDurableSubscriberName export;
  dcl-pi *N;
    conn pointer const;
    pName varchar(100) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s name varchar(100);

  name = pName;
  tree_rb_int_put(header.options : STOMP_OPTION_DURABLE_SUBSCRIBER :
                  %addr(name : *DATA) : %len(name));
  Logger_debug(logger : 'set durable subscriber: ' + pName);
end-proc;


dcl-proc stomp_getSessionId export;
  dcl-pi *N like(stomp_sessionid_t);
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  return header.sessionId;
end-proc;


dcl-proc stomp_setPersistMessages export;
  dcl-pi *N;
    conn pointer const;
    persistent ind const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s value varchar(6);

  if (persistent);
    value = 'true';
  else;
    value = 'false';
  endif;

  tree_rb_int_put(header.options : STOMP_OPTION_PERSISTENT :
                  %addr(value : *DATA) : %len(value));
  Logger_debug(logger : 'set persist messages: ' + value);
end-proc;

dcl-proc stomp_sendFrame export;
  dcl-pi *N;
    conn pointer const;
    frame pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s length int(10);
  dcl-s ptr pointer;
  dcl-s backupPtr pointer;
  dcl-s rc int(10);
  dcl-s receiptid like(stomp_receiptid_t);

  Logger_info(logger : 'sending ' + stomp_frame_getCommand(frame) + ' frame');
  
  // all frame (except the CONNECT frame) might get a receipt header
  if (stomp_frame_getCommand(frame) <> 'CONNECT' and
      stomp_isUsingReceipts(conn));
    receiptid = %char(%timestamp() : *ISO);
    stomp_frame_setHeader(frame : 'receipt' : receiptid);
    stomp_addOpenReceipt(conn : receiptid);
  endif;
  
  ptr = stomp_frame_toString(frame);
  backupPtr = ptr;
  
  length = strlen(ptr);
  translateToAscii(ptr : length);
  ptr = backupPtr;
  rc = send(header.socket : ptr : length + 1 : 0);
  
  Logger_debug(logger : 'sent ' + %char(rc) + ' bytes');
  
  if (stomp_isUsingReceipts(conn));
    waitForReceipts(conn);
  endif;
  
  dealloc(n) ptr;
end-proc;


dcl-proc stomp_receiveFrame export;
  dcl-pi *N pointer;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s length int(10);
  dcl-s ptr pointer;
  dcl-s backupPtr pointer;
  dcl-s rc int(10);
  dcl-s returnFrame pointer;
  dcl-s receipt char(50);
  dcl-s bufferedFrame pointer based(tmpPtr);

  Logger_debug(logger : 'receiving frames ...');
  
  // return next buffered frames
  if (not list_isEmpty(header.bufferedFrames));
    tmpPtr =list_getFirst(header.bufferedFrames);
    list_removeFirst(header.bufferedFrames);
    Logger_debug(logger : 'return buffered frame ' + stomp_frame_getCommand(bufferedFrame));
    ackMessage(conn : bufferedFrame);
    return bufferedFrame;
  endif;
  
  ptr = %alloc(65535);
  length = 65535;
  
  rc = recv(header.socket : ptr : length : 0);
  if (rc = -1);
    Logger_debug(logger : 'no data received from connection');
  else;
    backupPtr = ptr;
    length = rc;
    translateFromAscii(ptr : length);
    ptr = backupPtr;
    returnFrame = stomp_frame_parse(ptr);
    
    Logger_debug(logger : 'received ' + stomp_frame_getCommand(returnFrame) + ' frame');
  
    ackMessage(conn : returnFrame);
  endif;
  
  dealloc(n) backupPtr;

  return returnFrame;
end-proc;


dcl-proc stomp_setExtension export;
  dcl-pi *N;
    conn pointer const;
    extension pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  if (header.extension <> *null);
    Logger_debug(logger : 'replace extension: ' +
                          stomp_ext_getId(header.extension));
    stomp_ext_finalize(header.extension);
  endif;

  header.extension = extension;

  Logger_debug(logger : 'set extension: ' + stomp_ext_getId(extension));
end-proc;


dcl-proc stomp_setExtensionByName export;
  dcl-pi *N;
    conn pointer const;
    extensionName char(10) const;
    userdata pointer const options(*nopass : *string);
    procedureName char(256) const options(*nopass);
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s extension pointer;

  if (%parms() = 2);
    extension = stomp_ext_create(extensionName);
  elseif (%parms() = 3);
    extension = stomp_ext_create(extensionName : userdata);
  elseif (%parms() = 4);
    extension = stomp_ext_create(extensionName : userdata : procedureName);
  endif;

  stomp_setExtension(conn : extension);
end-proc;


dcl-proc stomp_getExtension export;
  dcl-pi *N pointer;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  return header.extension;
end-proc;


dcl-proc stomp_useReceipts export;
  dcl-pi *N;
    conn pointer const;
    value ind const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  header.useReceipts = value;

  Logger_debug(logger : 'set using receipts: ' + value);
end-proc;


dcl-proc stomp_isUsingReceipts export;
  dcl-pi *N ind;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
 
  return header.useReceipts;
end-proc;


dcl-proc stomp_hasOption export;
  dcl-pi *N ind;
    conn pointer const;
    option int(10) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-ds node likeds(tree_node_int_t) based(nodePtr);

  return tree_rb_int_containsKey(header.options : option);
end-proc;


dcl-proc stomp_getOptionValue export;
  dcl-pi *N pointer;
    conn pointer const;
    option int(10) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-ds node likeds(tree_node_int_t) based(nodePtr);

  nodePtr = tree_rb_int_get(header.options : option);
  return node.value;
end-proc;


dcl-proc stomp_setSessionId export;
  dcl-pi *N;
    conn pointer const;
    session like(stomp_header_t.sessionId) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  header.sessionId = session;

  Logger_debug(logger : 'set session id: ' + session);
end-proc;


dcl-proc stomp_addOpenReceipt export;
  dcl-pi *N;
    conn pointer const;
    pReceipt like(stomp_receiptid_t) const;
  end-pi;
  
  dcl-s receipt like(stomp_receiptid_t);
  dcl-ds header likeds(stomp_header_t) based(conn);

  receipt = pReceipt;
  list_addString(header.openReceipts : receipt);

  Logger_debug(logger : 'added open receipt: ' + receipt);
end-proc;


dcl-proc stomp_getNumberOfOpenReceipts export;
  dcl-pi *N int(10);
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  return list_size(header.openReceipts);
end-proc;


///
// Wait for receipts
//
// The procedure receives frames over the socket of the client and waits
// until all open receipts has been received. <br/>
//
// Because receipts may not be sent directly after the frame with the receipt header
// all non RECEIPT frames will be buffered and returned by calling the
// <em>stomp_receiveFrame</em> procedure.
//
// \param Pointer to client
///
dcl-proc waitForReceipts;
  dcl-pi *N;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s rc int(10);
  dcl-s ptr pointer;
  dcl-s backupPtr pointer;
  dcl-s length int(10);
  dcl-s frame pointer;
  dcl-s receiptId like(stomp_receiptid_t);
  dcl-s x int(10);

  Logger_debug(logger : 'waiting for receipts ...');
  
  length = 65535;
  ptr = %alloc(length);
  
  dow (not list_isEmpty(header.openReceipts));
  
    rc = recv(header.socket : ptr : length : 0);
  
    if (rc = -1);
      Logger_debug(logger : 'no data received from connection');
    else;
      backupPtr = ptr;
      length = rc;
      translateFromAscii(ptr : length);
      ptr = backupPtr;
  
      frame = stomp_frame_parse(ptr);
  
      Logger_debug(logger : 'received ' + stomp_frame_getCommand(frame) + ' frame');
  
      if (stomp_frame_getCommand(frame) = 'RECEIPT');
        receiptId = stomp_frame_getHeaderValue(frame : 'receipt-id');
  
        Logger_debug(logger : 'received receipt with id: ' + receiptId);
  
        x = list_indexOf(header.openReceipts : %addr(receiptId : *DATA) :
                         %len(receiptId));
        if (x >=0); // open receipt found
          list_remove(header.openReceipts : x);
          Logger_debug(logger : 'removed receipt ' + receiptId +
                                ' from open receipt list (position ' +
                                %char(x) + ')');
        else;
          Logger_warn(logger : 'receipt ' + receiptId + ' is not in the ' +
                               'list of open receipts');
        endif;
  
      else;
        // no receipt => add frame to buffered frames
        list_add(header.bufferedFrames : %addr(frame) : %size(frame));
        Logger_debug(logger : 'buffered frame ' + stomp_frame_getCommand(frame) +
                              '. waiting for receipt ...');
      endif;
    endif;
  
  enddo;
  
  dealloc ptr;
end-proc;


///
// Ack Message Frame
//
// If the frame is a MESSAGE frame and the ack mode is "client"
// then an ACK frame must be send with the message id from the
// original frame.
//
// \param Connection
// \param Frame
///
dcl-proc ackMessage;
  dcl-pi *N;
    conn pointer const;
    frame pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s ackFrame pointer;
  dcl-ds node likeds(tree_node_int_t) based(nodePtr);

  if (frame <> *null and stomp_frame_getCommand(frame) = 'MESSAGE');
 
    if (tree_rb_int_containsKey(header.options : STOMP_OPTION_ACK));
      nodePtr = tree_rb_int_get(header.options : STOMP_OPTION_ACK);
 
      if (%str(node.value) = STOMP_ACK_MODE_CLIENT);
        ackFrame = stomp_frame_create('ACK');
        stomp_frame_setHeader(ackFrame : 'message-id' :
            stomp_frame_getHeaderValue(frame : 'message-id'));
        stomp_sendFrame(conn : ackFrame);
        stomp_frame_finalize(ackFrame);
      endif;
 
    endif;
 
  endif;
end-proc;
