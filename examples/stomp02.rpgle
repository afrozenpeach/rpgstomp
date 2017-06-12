**FREE

///
// Stomp client
//
// This client tries to connect to an RabbitMQ instance on a remote server and
// sends one message to the topic "retailprice".
//
// \author Mihael Schmidt
// \date 11.06.2017
///


ctl-opt dftactgrp(*no) actgrp(*caller) main(main);


//
// Prototypes
//
dcl-pr main extpgm('STOMP02') end-pr;

/include 'stomp/stomp_h.rpgle'


//
// PEP
//
dcl-proc main;
  dcl-s dsp char(50);
  dcl-c NULL x'00';
  dcl-s ptr pointer;
  dcl-s client pointer;
  dcl-s extension pointer;
  
  monitor;
    client = stomp_create('mqserver' : 61612);
    stomp_setClientId(client : 'stomp02@pub400.com');
    stomp_setPersistMessages(client : *on);
    stomp_useReceipts(client : *on);
  
    extension = stomp_ext_activemq_create();
    stomp_setExtension(client : extension);
  
    stomp_open(client);
  
    dsply 'network connection established';
  
    if (stomp_command_connect(client : 'mihael' : 'xxyyzz'));
  
      dsp = 'Session: ' + stomp_getSessionId(client);
      dsply dsp;
  
      stomp_command_send(
                  client :
                  '/topic/retailprice' :
                  '{ "id" : 5500 , ' +
                  '"price" : 1.23 , ' +
                  '"time" : ' + %char(%timestamp : *ISO0) + ' }');
  
      stomp_command_disconnect(client);
    else;
      dsply 'could not connect with the CONNECT command';
    endif;
  
    dsply %trimr('Number of open receipts: ' + %char(stomp_getNumberOfOpenReceipts(client)));
  
    stomp_close(client);
    stomp_finalize(client);
  
    dsply 'connection closed';
  
    on-error;
      dsply 'error occured';
      stomp_finalize(client);
      dsply 'connection closed';
  endmon;
end-proc;
