**FREE

///
// Stomp Client Example in fully free RPG
//
// This client tries to connect to an RabbitMQ instance and
// sends one message to the topic "retailprice".
//
// \author Mihael Schmidt
// \date   27.07.2017
///


ctl-opt main(main);


/include 'stomp/stomp_h.rpgle'


dcl-proc main;

  dcl-s dsp char(50);
  dcl-s ptr pointer;
  dcl-s client pointer;
  
  monitor;
    client = stomp_create('server.com' : 61613);
    stomp_setClientId(client : 'stomp03@localhost.com');

    stomp_open(client);

    dsply 'network connection established';

    stomp_command_connect(client : 'user' : 'pass');
    
    dsp = 'Session: ' + stomp_getSessionId(client);
    dsply dsp;
    
    stomp_command_send(client :
                  '/queue/retailprice' :
                  '{ "id" : 5500 , ' +
                  '"price" : 1.23 , ' +
                  '"time" : ' + %char(%timestamp : *ISO0) + ' }');
    stomp_command_disconnect(client);

    stomp_close(client);
    stomp_finalize(client);
     
    dsply 'connection closed';
     
    on-error;
      dsply 'error occured';
      stomp_finalize(client);
      dsply 'connection closed';
  endmon;
end-proc;
