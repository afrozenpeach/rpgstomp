**FREE

///
// \brief Stomp : Extension ActiveMQ
//
// This module changes the frames so that they are compatible with ActiveMQ.
// ActiveMQ expects certain headers for durable topic subscriptions.
// <br><br>
// Log entries will be written via the logger <em>de.rpgng.stomp.ext.activemq</em>.
// There is no appender configured for this logger. Feel free to add log appenders
// for this logger.
//
// \author Mihael Schmidt
// \date   01.06.2011
//
// \link http://activemq.apache.org/stomp.html ActiveMQ Stomp
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
/include QLOG4RPG,PLOG4RPG
/include 'stomp_h.rpgle'
/include 'stompext_amq_h.rpgle'


//
// Constants
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
    logger = Logger_getLogger('com.rpgnextgen.stomp.ext.activemq');
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
