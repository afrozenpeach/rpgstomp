**FREE

/if not defined (STOMP_EXT_ACTIVEMQ)
/define STOMP_EXT_ACTIVEMQ

///
// \brief Stomp : Extension ActiveMQ
//
// This module changes the frames so that they are compatible with ActiveMQ.
// ActiveMQ expects certain headers for durable topic subscriptions.
// <br><br>
// Log entries will be written via the logger <em>rpgnextgen.stomp.ext.activemq</em>.
// There is no preconfigured appender for this logger. Feel free to add log 
// appenders for this logger.
//
// \author Mihael Schmidt
// \date   26.07.2017
// \project STOMP
// \link http://activemq.apache.org/stomp.html ActiveMQ Stomp
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

//
// Prototypes
//

///
// Create STOMP Client ActiveMQ Extension
// 
// Creates an extension for connecting to an ActiveMQ instance. This extension
// doesn't need any userdata and thus no parameter need to be passed to this
// procedure.
// 
// \param Pointer to user data
// \return Pointer to the extension instance
///
dcl-pr stomp_ext_activemq_create pointer extproc('stomp_ext_activemq_create');
  userdata pointer const options(*nopass : *string);
end-pr;

dcl-pr stomp_ext_activemq_connect extproc('stomp_ext_activemq_connect');
  extension pointer const;
  client pointer const;
  frame pointer const;
  user varchar(100) const options(*nopass);
  pass varchar(100) const options(*nopass);
end-pr;

dcl-pr stomp_ext_activemq_send extproc('stomp_ext_activemq_send');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
  messageData pointer const options(*string);
end-pr;

dcl-pr stomp_ext_activemq_disconnect extproc('stomp_ext_activemq_disconnect');
  extension pointer const;
  client pointer const;
  frame pointer const;
end-pr;

dcl-pr stomp_ext_activemq_subscribe extproc('stomp_ext_activemq_subscribe');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_ext_activemq_unsubscribe extproc('stomp_ext_activemq_unsubscribe');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_ext_activemq_finalize extproc('stomp_ext_activemq_finalize');
  extension pointer;
end-pr;

/endif

