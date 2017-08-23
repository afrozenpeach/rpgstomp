**FREE

/if not defined(STOMP_COMMAND_H)
/define STOMP_COMMAND_H

///
// STOMP : Commands
//
// This module contains procedures for the various STOMP commands.
// <br><br>
// Log entries will be written via the logger <em>rpgnextgen.stomp.command</em>.
// There is no appender configured for this logger. Feel free to add log appenders
// for this logger.
//
// \author Mihael Schmidt
// \date   26.07.2017
// \project STOMP
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
// Connect to messaging system
//
// Connects this client to the configured messaging system with a CONNECT
// frame. One client can connect to exactly one system at the same time.
// <br><br>
// The returned session id will be stored in the client and can be
// queried with <em>stomp_getSessionId()</em>.
// <br><br>
// Any registered extension will be called on frame creation.
// <br><br>
// If the client cannot connect an escape message will be sent.
//
// \param Client
// \param Username
// \param Password
//
///
dcl-pr stomp_command_connect extproc('stomp_command_connect');
  conn pointer const;
  user varchar(100) const options(*nopass);
  pass varchar(100) const options(*nopass);
end-pr;

///
// Disconnect from server
//
// Sends a DISCONNECT frame to the server.
// <br><br>
// Any registered extension will be called on frame creation.
//
// \param Client
///
dcl-pr stomp_command_disconnect extproc('stomp_command_disconnect');
  conn pointer const;
end-pr;

///
// Sends message
//
// Sends a SEND frame to the server with the passed message to the
// passed destination (queue or topic).
// <br><br>
// The header <em>content-length</em> will always be added to the
// frame.
// <br><br>
// Any registered extension will be called on frame creation.
//
// \param Client
// \param Destination (queue or topic)
// \param Message (null-terminated)
///
dcl-pr stomp_command_send extproc('stomp_command_send');
  conn pointer const;
  destination varchar(100) const;
  messageData pointer const options(*string);
end-pr;

///
// Subscribe to queue or topic
//
// Subscribes this client to the passed destination (queue or topic).
// <br> <br>
// Any registered extension will be called on frame creation.
//
// \param Client
// \param Destination (queue or topic)
///
dcl-pr stomp_command_subscribe extproc('stomp_command_subscribe');
  conn pointer const;
  destination varchar(100) const;
end-pr;

///
// Unsubscribes from a queue or topic
//
// Sends an UNSUBSCRIBE frame to the server.
// <br><br>
// Any registered extension will be called on frame creation.
//
// \param Client
// \param Destination (queue or topic)
///
dcl-pr stomp_command_unsubscribe extproc('stomp_command_unsubscribe');
  conn pointer const;
  destination varchar(100) const;
end-pr;

/endif

