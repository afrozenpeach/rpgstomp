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
dcl-pr stomp_ext_check;
  extension pointer const;
end-pr;

/include 'stompext_h.rpgle'
/include 'message/message_h.rpgle'
/include 'reflection_h.rpgle'


//
// Templates
//
/include 'stompext_t.rpgle'


//
// Procedures
//

dcl-proc stomp_ext_create export;
  dcl-pi *N pointer;
    extensionName char(10) const;
    userdata pointer const options(*nopass : *string);
    procedureName char(256) const options(*nopass);
  end-pi;
  
  dcl-s createProcedureName char(256);
  dcl-s procedurePointer pointer(*proc);
  dcl-pr create pointer extproc(procedurePointer);
    userdata pointer const options(*nopass : *string);
  end-pr;
  dcl-s extension pointer;
  dcl-ds header likeds(stomp_ext_t) based(extension);

  if (%parms() = 3);
    createProcedureName = procedureName;
  else;
    createProcedureName = 'stomp_ext_create';
  endif;
  
  procedurePointer = reflection_getProcedurePointer(
                             extensionName :
                             %trimr(createProcedureName));
  
  if (procedurePointer <> *null);
    if (%parms() = 1);
      extension = create();
    else;
      extension = create(userData);
    endif;
  
    stomp_ext_check(extension);
  endif;
  
  return extension;
end-proc;


dcl-proc stomp_ext_getId export;
  dcl-pi *N varchar(50);
    extension pointer const;
  end-pi;
  
  dcl-ds header likeds(stomp_ext_t) based(extension);
 
  return %trimr(header.id);
end-proc;


dcl-proc stomp_ext_connect export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
    user varchar(100) const options(*nopass);
    pass varchar(100) const options(*nopass);
  end-pi;
  
  dcl-ds header likeds(stomp_ext_t) based(extension);
  dcl-s connPointer pointer(*proc);
  dcl-pr connect extproc(connPointer);
    extension pointer const;
    client pointer const;
    frame pointer const;
    user varchar(100) const options(*nopass);
    pass varchar(100) const options(*nopass);
  end-pr;
  
  stomp_ext_check(extension);

  connPointer = header.proc_connect;

  if (%parms() = 3);
    connect(extension : client : frame);
  elseif (%parms() = 4);
    connect(extension : client : frame : user);
  elseif (%parms() = 5);
    connect(extension : client : frame : user : pass);
  endif;
end-proc;


dcl-proc stomp_ext_send export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
    messageData pointer const options(*string);
  end-pi;
  
  dcl-ds header likeds(stomp_ext_t) based(extension);
  dcl-s sendPointer pointer(*proc);
  dcl-pr send extproc(sendPointer);
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
    messageData pointer const options(*string);
  end-pr;

  stomp_ext_check(extension);

  sendPointer = header.proc_send;

  send(extension : client : frame : destination : messageData);
end-proc;


dcl-proc stomp_ext_disconnect export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
  end-pi;

  dcl-ds header likeds(stomp_ext_t) based(extension);
  dcl-s disconnectPointer pointer(*proc);
  dcl-pr disconnect extproc(disconnectPointer);
    extension pointer const;
    client pointer const;
    frame pointer const;
  end-pr;

  stomp_ext_check(extension);

  disconnectPointer = header.proc_disconnect;

  disconnect(extension : client : frame);
end-proc;


dcl-proc stomp_ext_subscribe export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
  end-pi;
  
  dcl-ds header likeds(stomp_ext_t) based(extension);
  dcl-s subscribePointer pointer(*proc);
  dcl-pr subscribe extproc(subscribePointer);
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
  end-pr;
  
  stomp_ext_check(extension);

  subscribePointer = header.proc_subscribe;

  subscribe(extension : client : frame : destination);
end-proc;


dcl-proc stomp_ext_unsubscribe export;
  dcl-pi *N;
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
  end-pi;
  
  dcl-ds header likeds(stomp_ext_t) based(extension);
  dcl-s unsubscribePointer pointer(*proc);
  dcl-pr unsubscribe extproc(unsubscribePointer);
    extension pointer const;
    client pointer const;
    frame pointer const;
    destination varchar(100) const;
  end-pr;
  
  stomp_ext_check(extension);

  unsubscribePointer = header.proc_unsubscribe;

  unsubscribe(extension : client : frame : destination);
end-proc;


dcl-proc stomp_ext_finalize export;
  dcl-pi *N;
   extension pointer;
  end-pi;
  
  dcl-ds header likeds(stomp_ext_t) based(extension);
  dcl-s finalizePointer pointer(*proc);
  dcl-pr finalize extproc(finalizePointer);
    extension pointer;
  end-pr;
  
  stomp_ext_check(extension);

  finalizePointer = header.proc_finalize;

  finalize(extension);

  if (extension <> *null);
    monitor;
      dealloc(n) extension;
      on-error;
        // nothing
    endmon;
  endif;
end-proc;


dcl-proc stomp_ext_check;
  dcl-pi *N;
    extension pointer const;
  end-pi;

  dcl-ds header likeds(stomp_ext_t) based(extension);
  dcl-s cachedExtensionId like(stomp_ext_t.id) static;
  dcl-s extensionChecked ind inz(*off) static;

  if (header.id = cachedExtensionId and extensionChecked);
    return;
  endif;

  extensionChecked = *off;

  if (header.proc_connect = *null);
    message_sendEscapeMessageToCaller(
        'STOMP Extension Interface: Incomplete Implementation (connect) ' + %trimr(header.id) + '.');
  elseif (header.proc_finalize = *null);
    message_sendEscapeMessageToCaller(
        'STOMP Extension Interface: Incomplete Implementation (finalize) ' + %trimr(header.id) + '.');
  elseif (header.proc_disconnect = *null);
    message_sendEscapeMessageToCaller(
        'STOMP Extension Interface: Incomplete Implementation (disconnect) ' + %trimr(header.id) +  '.');
  elseif (header.proc_send = *null);
    message_sendEscapeMessageToCaller(
        'STOMP Extension Interface: Incomplete Implementation (send) ' + %trimr(header.id) + '.');
  elseif (header.proc_subscribe = *null);
    message_sendEscapeMessageToCaller(
        'STOMP Extension Interface: Incomplete Implementation (subscribe) ' + %trimr(header.id) +  '.');
  elseif (header.proc_unsubscribe = *null);
    message_sendEscapeMessageToCaller(
        'STOMP Extension Interface: Incomplete Implementation (unsubscribe) ' + %trimr(header.id) +  '.');
  endif;
  
  cachedExtensionId = header.id;
  
  extensionChecked = *on;
end-proc;
