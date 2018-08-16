**FREE

/if not defined(STOMP_H)
/define STOMP_H

///
// STOMP Client : Main Module
//
// STOMP is a simple text protocol for transporting messages. It can be
// used to talk to a JMS messaging system like ActiveMQ or RabbitMQ. For
// further details on STOMP see https://stomp.github.io.
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
// This module uses the logger <em>rpgnextgen.stomp</em>. There is no
// appender configured for this logger. Feel free to add log appenders
// for this logger.
//
// \author Mihael Schmidt
// \date   27.01.2011
// \project STOMP
//
// \link https://stomp.github.io
// \link https://bitbucket.org/m1hael/stomp STOMP RPG client
// \link http://www.tools400.de Log4RPG at Tools400.de
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
dcl-pr stomp_create pointer extproc('stomp_create');
  host varchar(255) const;
  port int(10) const;
end-pr;

///
// Open socket connection
//
// This procedure just opens a socket connection to the server. It
// does not communicate with the message queuing system
// (means it does not send any Stomp frames).
//
// \param Client
///
dcl-pr stomp_open extproc('stomp_open');
  conn pointer const;
end-pr;

///
// Close socket connection
//
// Closes the network socket. This procedure does not
// send a disconnect frame to the message queuing system.
//
// \param Client
///
dcl-pr stomp_close extproc('stomp_close');
  conn pointer const;
end-pr;

///
// Dispose client
//
// Frees all allocated resources. Any open socket will be closed.
// Any allocated resource from a set extension will also be freed.
//
// \param Client
///
dcl-pr stomp_finalize extproc('stomp_finalize');
  conn pointer;
end-pr;

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
dcl-pr stomp_sendFrame extproc('stomp_sendFrame');
  conn pointer const;
  frame pointer const;
end-pr;

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
dcl-pr stomp_receiveFrame pointer extproc('stomp_receiveFrame');
  conn pointer const;
end-pr;

///
// Set timeout
//
// Sets the timeout for the socket operations (receive).
//
// \param Client
// \param Timeout (in ms)
///
dcl-pr stomp_setTimeout extproc('stomp_setTimeout');
  conn pointer const;
  mseconds int(10) const;
end-pr;

///
// Set virtual host
//
// Sets the virtual host. This is an optional connect header.
//
// \param Client
// \param Virtual Host
///
dcl-pr stomp_setVirtualHost extproc('stomp_setVirtualHost');
  conn pointer const;
  virtualHost varchar(100) const;
end-pr;

///
// Set client id
//
// Sets the client id. This value is needed for a durable topic subscription.
// This id must be unique with the whole system.
//
// \param Client
// \param Client id
///
dcl-pr stomp_setClientId extproc('stomp_setClientId');
  conn pointer const;
  clientId varchar(100) const;
end-pr;

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
dcl-pr stomp_setAckMode extproc('stomp_setAckMode');
  conn pointer const;
  mode char(10) const;
end-pr;

///
// Get session id
//
// Returns the session id.
//
// \param Client
//
// \return Session or *blank if no session id has been set
///
dcl-pr stomp_getSessionId like(stomp_sessionid_t) extproc('stomp_getSessionId');
  conn pointer const;
end-pr;

///
// \brief Set durable subscriber name
//
// This value is needed for a durable topic subscription at the messaging system.
//
// \param Client
// \param Durable subscriber name
///
dcl-pr stomp_setDurableSubscriberName extproc('stomp_setDurableSubscriberName');
  conn pointer const;
  name varchar(100) const;
end-pr;

///
// Set messages persistent
//
// Configures the client to send persistent messages. Only messages with
// the header <em>persistent</em> will be sent to all durable topic subscribers.
//
// \param Client
// \param Persistent messages
///
dcl-pr stomp_setPersistMessages extproc('stomp_setPersistMessages');
  conn pointer const;
  value ind const;
end-pr;

///
// Get extension
//
// Returns previously set extension.
//
// \param Client
//
// \return Extension or *null if no extension has been set
///
dcl-pr stomp_getExtension pointer extproc('stomp_getExtension');
  conn pointer const;
end-pr;

///
// Set extension
//
// Sets the extension to be used by the client. Any previously set extension
// will be removed and the allocated resources freed.
//
// \param Client
// \param Extension
///
dcl-pr stomp_setExtension extproc('stomp_setExtension');
  conn pointer const;
  extension pointer const;
end-pr;

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
dcl-pr stomp_setExtensionByName extproc('stomp_setExtensionByName');
  conn pointer const;
  extensionName char(10) const;
  userdata pointer const options(*nopass : *string);
  procedureName char(256) const options(*nopass);
end-pr;

///
// Set usage of receipts
//
// Configures if the client as for server receipts for every
// sent frame (except CONNECT).
//
// \param Client
// \param Value *on/*off
///
dcl-pr stomp_useReceipts extproc('stomp_useReceipts');
  conn pointer const;
  value ind const;
end-pr;

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
dcl-pr stomp_isUsingReceipts ind extproc('stomp_isUsingReceipts');
  const pointer const;
end-pr;

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
dcl-pr stomp_getOptionValue pointer extproc('stomp_getOptionValue');
  conn pointer const;
  option int(10) const;
end-pr;

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
dcl-pr stomp_hasOption ind extproc('stomp_hasOption');
  conn pointer const;
  option int(10) const;
end-pr;

///
// Set session id
//
// Sets the session id.
//
// \param Client
// \param Session id
///
dcl-pr stomp_setSessionId extproc('stomp_setSessionId');
  conn pointer const;
  session like(stomp_sessionid_t) const;
end-pr;

///
// Add open receipt
//
// Adds a receipt to the list of open receipts.
//
// \param Client
// \param Receipt id
///
dcl-pr stomp_addOpenReceipt extproc('stomp_addOpenReceipt');
  conn pointer const;
  receipt like(stomp_receiptid_t) const;
end-pr;

///
// Get number of open receipts
//
// Returns the number of open receipts.
//
// \param Client
//
// \return Number of open receipts
///
dcl-pr stomp_getNumberOfOpenReceipts int(10) extproc('stomp_getNumberOfOpenReceipts');
  conn pointer const;
end-pr;


//
// Templates
//
dcl-s stomp_sessionid_t char(100) template;
dcl-s stomp_receiptid_t varchar(50) template;


//
// Constants
//
dcl-c STOMP_ACK_MODE_AUTO 'auto';
dcl-c STOMP_ACK_MODE_CLIENT 'client';
dcl-c STOMP_OPTION_TIMEOUT 1;
dcl-c STOMP_OPTION_VIRTUAL_HOST 'host';
dcl-c STOMP_OPTION_CLIENT_ID 2;
dcl-c STOMP_OPTION_ACK 3;
dcl-c STOMP_OPTION_PERSISTENT 4;
dcl-c STOMP_OPTION_DURABLE_SUBSCRIBER 5;
dcl-c STOMP_OPTION_CONTENT_TYPE 6;
dcl-c STOMP_OPTION_CHARSET 7;


/include 'stompframe_h.rpgle'
/include 'stompcmd_h.rpgle'
/include 'stompext_h.rpgle'
/include 'stompext_amq_h.rpgle'

/endif
