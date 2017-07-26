**FREE

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

ctl-opt nomain;

//
// Prototypes
//
/include QLOG4RPG,PLOG4RPG
/include 'stomp_h.rpgle'
/include 'stompext_amq_h.rpgle'


//
// STOMP ActiveMQ Extension Id
//
dcl-c ID 'STOMP_EXT_ACTIVEMQ';


//
// Templates
//
/include 'stompext_t.rpgle'


//
// Global Variables
//
dcl-s logger pointer;


//
// Procedures
//

dcl-proc stomp_ext_activemq_create export;
  dcl-pi *N pointer;
    userdata pointer const options(*nopass : *string);
  end-pi;
  
  dcl-ds header likeds(stomp_ext_t) based(extension);
  
  extension = %alloc(%size(header));
  
  header.id = ID;
  header.userdata = *null;
  header.proc_connect = %paddr('stomp_ext_activemq_connect');
  header.proc_disconnect = %paddr('stomp_ext_activemq_disconnect');
  header.proc_send = %paddr('stomp_ext_activemq_send');
  header.proc_subscribe = %paddr('stomp_ext_activemq_subscribe');
  header.proc_unsubscribe = %paddr('stomp_ext_activemq_unsubscribe');
  header.proc_finalize = %paddr('stomp_ext_activemq_finalize');
  
  if (logger = *null);
    logger = Logger_getLogger('rpgnextgen.stomp.ext.activemq');
  endif;
  
  Logger_info(logger : 'created stomp extension ' + ID);
  
  return extension;
end-proc;


dcl-proc stomp_ext_activemq_connect export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
    user varchar(100) const options(*nopass);
    pass varchar(100) const options(*nopass);
  end-pi;

  // do nothing
end-proc;


dcl-proc stomp_ext_activemq_send export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
    messageData pointer const options(*string);
  end-pi;

  // do nothing
end-proc;


dcl-proc stomp_ext_activemq_disconnect export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
  end-pi;

  // do nothing
end-proc;


dcl-proc stomp_ext_activemq_subscribe export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
  end-pi;
  
  dcl-s optionPtr pointer;

  if (stomp_hasOption(client : STOMP_OPTION_DURABLE_SUBSCRIBER));
    optionPtr = stomp_getOptionValue(client : STOMP_OPTION_DURABLE_SUBSCRIBER);
    stomp_frame_setHeader(frame : 'activemq.subscriptionName' : %str(optionPtr));

    Logger_info(logger:'added activemq.subscriptionName header to frame');
  endif;
end-proc;


dcl-proc stomp_ext_activemq_unsubscribe export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
  end-pi;

  // do nothing
end-proc;


dcl-proc stomp_ext_activemq_finalize export;
  dcl-pi *N;
    extension pointer;
  end-pi;
  
  if (extension <> *null);
    dealloc(n) extension;
  endif;

  Logger_info(logger : 'stomp extension disposed');
end-proc;
