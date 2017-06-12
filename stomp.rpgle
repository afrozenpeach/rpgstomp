**FREE

///
// Stomp : Main Module
//
// STOMP is a simple text protocol for transporting messages. It can be
// used to talk to a JMS messaging system like ActiveMQ or Apollo. For
// further details on STOMP see http://stomp.codehaus.org.
// <br><br>
// The networking is done via plain socket programming. The sockets will
// act in non-blocking mode.
// <br><br>
// A typical workflow of a stomp session sending a message could be:
// <ol>
//   <li>create stomp client instance (stomp_create)</li>
//   <li>open socket connection (stomp_open)</li>
//   <li>connect to/register at messaging system (stomp_command_connect)</li>
//   <li>send message (stomp_command_send)</li>
//   <li>disconnect from messaging system (stomp_command_disconnect)</li>
//   <li>close socket connection (stomp_close)</li>
//   <li>clean up (stomp_finalize)</li>
// </ol>
// <br><br>
// Any data will be sent in ASCII (codepage 819).
// <br><br>
// This module uses the logger <em>de.rpgng.stomp</em>. There is no
// appender configured for this logger. Feel free to add log appenders
// for this logger.
//
// \author Mihael Schmidt
// \date   27.01.2011
//
// \todo support for more than CCSID 819 (f. e. utf8) (umlaute?!)
// \todo support for optional charset
// \todo support for stomp spec 1.1
// \todo support for stomp spec 1.2
// \todo max receiving frame size is 65535
//
// \link http://github.com/stomp
// \link https://bitbucket.org/m1hael/stomp STOMP RPG client
// \link http://www.tools400.de Log4RPG at Tools400.de
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
dcl-pr waitForReceipts extproc('waitForReceipts');
  conn pointer const;
end-pr;

dcl-pr ackMessage;
  conn pointer const;
  frame pointer const;
end-pr;

/include 'stomp_h.rpgle'
/include 'stompframe_h.rpgle'
/include 'stomputil_h.rpgle'
/include 'stompparser_h.rpgle'
/include 'stompext_h.rpgle'
/include 'filedesc_h.rpgle'
/include QLOG4RPG,PLOG4RPG
/include 'net_h.rpgle'
/include 'socket_h.rpgle'
/include 'message/message_h.rpgle'
/include 'libc_h.rpgle'
/include 'errno_h.rpgle'
/include 'libtree/libtree_h.rpgle'
/include 'llist_h.rpgle'


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

///
// Create stomp client instance
//
// Creates a stomp client instance.
// <br><br>
// The default socket timeout is set to 500ms.
//
// \param Hostname (messaging system)
// \param Port
//
// \return Pointer to client
//
// \info The caller must make sure to free all allocated resource
//       of the client with the procedure <em>stomp_finalize()</em>.
///
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
 
  stomp_setTimeout(ptr : 500); // as a default
 
  header.socket = socket(AF_INET : SOCK_STREAM : PROTOCOL_DEFAULT);
  if (header.socket = -1);
    errPtr = errno();
    message_sendEscapeMessageToCaller(
    	'Could not create socket. ' + %char(c_err) + ': ' + %str(strerror(c_err)));
  endif;
 
  // change to non-blocking socket
  flags = fcntl(header.socket : F_GETFL);
  flags = %bitor(flags : O_NONBLOCK);
  fcntl(header.socket : F_SETFL : flags);
 
  if (logger = *null);
    logger = Logger_getLogger('de.rpgng.stomp');
  endif;
 
  Logger_info(logger : 'stomp client created');
 
  return ptr;
end-proc;


///
// Open socket connection
//
// This procedure just opens a socket connection to the server. It
// does not communicate with the message queuing system
// (means it does not send any Stomp frames).
//
// \param Client
///
dcl-proc stomp_open export;
  dcl-pi *N;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-ds socket_address_inet likeds(socket_address_inet_t);
  dcl-s c_err int(10) based(errPtr);

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
  
  header.connected = *on;
  
  Logger_info(logger : 'socket connection established to ' +
                        %trimr(header.host) + ':' + %char(header.port));
end-proc;


///
// Close socket connection
//
// Closes the network socket. This procedure does not
// send a disconnect frame to the message queuing system.
//
// \param Client
///
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


///
// Dispose client
//
// Frees all allocated resources. Any open socket will be closed.
// Any allocated resource from a set extension will also be freed.
//
// \param Client
///
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


///
// Set timeout
//
// Sets the timeout for the socket operations.
//
// \param Client
// \param Timeout (in ms)
///
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


///
// Set client id
//
// Sets the client id. This value is needed for a durable topic subscription.
// This id must be unique with the whole system.
//
// \param Client
// \param Client id
///
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


///
// Set ack mode
//
// The successful receiving of a message from the messaging system can
// either be automatically acknowledged or manually. If the client is
// configured for ack mode <em>auto</em> then the server assumes that
// every sent message from the server is also received by the client.
// The client does not need to do anything. If the client is configured
// for ack mode <em>client</em> then every received message must be
// acknowledged by the client by sending in ACK frame. In ack mode
// <em>client</em> every not acknowledged frame will be sent again.
// <br><br>
// Default is ack mode <em>auto</em>.
//
// \param Client
// \param Ack mode (STOMP_ACK_MODE_AUTO, STOMP_ACK_MODE_CLIENT)
///
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


///
// \brief Set durable subscriber name
//
// This value is needed for a durable topic subscription at the messaging system.
//
// \param Client
// \param Durable subscriber name
///
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


///
// Get session id
//
// Returns the session id.
//
// \param Client
//
// \return Session or *blank if no session id has been set
///
dcl-proc stomp_getSessionId export;
  dcl-pi *N like(stomp_sessionid_t);
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  return header.sessionId;
end-proc;


///
// Set messages persistent
//
// Configures the client to send persistent messages. Only messages with
// the header <em>persistent</em> will be sent to all durable topic subscribers.
//
// \param Client
// \param Persistent messages
///
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


///
// Send frame
//
// Sends the passed frame to the connected system. The socket connection
// must have been established (stomp_open) before sending any frames.
// <br><br>
// If the client is configured for receipts (stomp_useReceipts) then every
// frame (except the CONNECT frame) will get a <em>receipt</em> header with
// the timestamp as a value. This procedure will wait until the correct
// receipt has been received. Any frames in between will be buffered and
// returned in the correct order by the next call to <em>stomp_receiveFrame()</em>.
//
// \param Client
// \param Frame
///
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
  dcl-ds node likeds(tree_node_int_t) based(nodePtr);
  dcl-ds timeout likeds(timeout_t) inz;
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
  
  // set timeout
  if (tree_rb_int_containsKey(header.options : STOMP_OPTION_TIMEOUT));
    nodePtr = tree_rb_int_get(header.options : STOMP_OPTION_TIMEOUT);
    memcpy(%addr(timeout) : node.value : %size(timeout));
  endif;
  
  length = strlen(ptr);
  translateToAscii(ptr : length);
  ptr = backupPtr;
  rc = non_blocking_send(header.socket : ptr : length + 1 : timeout);
  
  Logger_debug(logger : 'sent ' + %char(rc) + ' bytes');
  
  if (stomp_isUsingReceipts(conn));
    waitForReceipts(conn);
  endif;
  
  dealloc(n) ptr;
end-proc;


///
// Receive frame
//
// Receive a frame from the message system. The next incoming socket data
// will be passed to the frame parser and the resulting frame is returned
// to the caller. The socket connection must have been established
// (stomp_open) before receiving any frames.
// If no frame is received over the socket connection in the timeout time
// then *null will be returned.
// <br><br>
// If the received frame is a MESSAGE frame and the ack mode is <em>client</em>
// then an ACK frame will be sent automatically before returning to the caller.
// <br><br>
// Any buffered frame will be returned by this procedure before trying to
// receive a frame over the socket connection.
//
// \param Client
//
// \return Pointer to frame or *null if no frame could be received in time
//
// \info The call must make sure to free any resources allocated by the frame
//       with <em>stomp_frame_finalize()</em>.
///
dcl-proc stomp_receiveFrame export;
  dcl-pi *N pointer;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-s length int(10);
  dcl-s ptr pointer;
  dcl-s backupPtr pointer;
  dcl-s rc int(10);
  dcl-ds node likeds(tree_node_int_t) based(nodePtr);
  dcl-ds timeout likeds(timeout_t) inz;
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
  
  // set timeout
  if (tree_rb_int_containsKey(header.options : STOMP_OPTION_TIMEOUT));
    nodePtr = tree_rb_int_get(header.options : STOMP_OPTION_TIMEOUT);
    memcpy(%addr(timeout) : node.value : %size(timeout));
  endif;
  
  rc = non_blocking_receive(header.socket : ptr : length : timeout);
  if (rc = -1);
    Logger_debug(logger : 'no data received from connection');
  else;
    backupPtr = ptr;
    length = rc;
    translateFromAscii(ptr : length);
    ptr = backupPtr;
    returnFrame = stomp_frame_parse(ptr);
  endif;
  
  Logger_debug(logger : 'received ' + stomp_frame_getCommand(returnFrame) + ' frame');
  
  ackMessage(conn : returnFrame);
  
  dealloc(n) backupPtr;

  return returnFrame;
end-proc;


///
// Set extension
//
// Sets the extension to be used by the client. Any previously set extension
// will be removed and the allocated resources freed.
//
// \param Client
// \param Extension
///
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


///
// Set extension by name
//
// Creates an instance of the STOMP extension and adds
// that to the client configuration. Only one extension
// may be used at any time. Any previsously set extension
// will be replaced and disposed.
//
// \param Client
// \param Extension name (service program name)
// \param Userdata
// \param Procedure name
///
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


///
// Get extension
//
// Returns previously set extension.
//
// \param Client
//
// \return Extension or *null if no extension has been set
///
dcl-proc stomp_getExtension export;
  dcl-pi *N pointer;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  return header.extension;
end-proc;


///
// Set usage of receipts
//
// Configures if the client as for server receipts for every
// sent frame (except CONNECT).
//
// \param Client
// \param Value *on/*off
///
dcl-proc stomp_useReceipts export;
  dcl-pi *N;
    conn pointer const;
    value ind const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  header.useReceipts = value;

  Logger_debug(logger : 'set using receipts: ' + value);
end-proc;


///
// Receipt usage
//
// Returns if the client ask for server receipts for
// sent frames.
//
// \param Client
//
// \return *on = ask server for receipts <br>
//         *off = don't ask server for receipts
///
dcl-proc stomp_isUsingReceipts export;
  dcl-pi *N ind;
    conn pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
 
  return header.useReceipts;
end-proc;


///
// Check client configuration option
//
// Checks if the client is configured for the passed option.
//
// \param Client
// \param Option
//
// \return *on = client is configured for passed option <br>
//         *off = client has no configuration for passed option
///
dcl-proc stomp_hasOption export;
  dcl-pi *N ind;
    conn pointer const;
    option int(10) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);
  dcl-ds node likeds(tree_node_int_t) based(nodePtr);

  return tree_rb_int_containsKey(header.options : option);
end-proc;


///
// Get option value
//
// Returns the option value for the passed configuration option.
//
// \param Client
// \param Configuration option
//
// \return Pointer to value or *null if the client doesn't have this option
///
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


///
// Set session id
//
// Sets the session id.
//
// \param Client
// \param Session id
///
dcl-proc stomp_setSessionId export;
  dcl-pi *N;
    conn pointer const;
    session like(stomp_header_t.sessionId) const;
  end-pi;
  
  dcl-ds header likeds(stomp_header_t) based(conn);

  header.sessionId = session;

  Logger_debug(logger : 'set session id: ' + session);
end-proc;


///
// Add open receipt
//
// Adds a receipt to the list of open receipts.
//
// \param Client
// \param Receipt id
///
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


///
// Get number of open receipts
//
// Returns the number of open receipts.
//
// \param Client
//
// \return Number of open receipts
///
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
// The procedures receives frames over the socket of the client and waits
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
  dcl-ds timeout likeds(timeout_t) inz;
  dcl-ds node likeds(tree_node_int_t) based(nodePtr);
  dcl-s receiptId like(stomp_receiptid_t);
  dcl-s x int(10);

  Logger_debug(logger : 'waiting for receipts ...');
  
  // set timeout
  if (tree_rb_int_containsKey(header.options : STOMP_OPTION_TIMEOUT));
    nodePtr = tree_rb_int_get(header.options : STOMP_OPTION_TIMEOUT);
    memcpy(%addr(timeout) : node.value : %size(timeout));
  endif;
  
  length = 65535;
  ptr = %alloc(length);
  
  dow (not list_isEmpty(header.openReceipts));
  
    rc = non_blocking_receive(header.socket : ptr : length : timeout);
  
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
