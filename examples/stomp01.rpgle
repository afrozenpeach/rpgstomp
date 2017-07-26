     /**
      * \brief Stomp client
      *
      * This client tries to connect to an ActiveMQ instance on localhost and
      * sends one message to the topic "retailprice".
      *
      * \author Mihael Schmidt
      * \date   26.07.2017
      */



      *-------------------------------------------------------------------------
      * PEP
      *-------------------------------------------------------------------------
     D main            PR                  extpgm('STOMP01')
     D main            PI


      *-------------------------------------------------------------------------
      * Prototypen
      *-------------------------------------------------------------------------
      /include 'stomp/stomp_h.rpgle'


      *-------------------------------------------------------------------------
      * Variablen
      *-------------------------------------------------------------------------
     D dsp             S             50A
     D NULL            C                   x'00'
     D ptr             S               *
     D client          S               *
     D extension       S               *
      /free
       monitor;

         client = stomp_create('127.0.0.1' : 61612);
         stomp_setClientId(client : 'stomp01@localhost.com');
         stomp_setPersistMessages(client : *on);
         stomp_useReceipts(client : *on);

         extension = stomp_ext_activemq_create();
         stomp_setExtension(client : extension);

         stomp_open(client);

         dsply 'network connection established';

         if (stomp_command_connect(client : 'guest' : 'password'));

           dsp = 'Session: ' + stomp_getSessionId(client);
           dsply dsp;

           stomp_command_send(client :
                      '/topic/retailprice' :
                      '{ "id" : 5500 , ' +
                      '"price" : 1.23 , ' +
                      '"time" : ' + %char(%timestamp : *ISO0) + ' }');

           stomp_command_disconnect(client);
         else;
           dsply 'could not connect with the CONNECT command';
         endif;

         dsply %trimr('Number of open receipts: ' +
                      %char(stomp_getNumberOfOpenReceipts(client)));

         stomp_close(client);
         stomp_finalize(client);

         dsply 'connection closed';

         on-error;
           dsply 'error occured';
           stomp_finalize(client);
           dsply 'connection closed';
       endmon;

       *inlr = *on;
       return;
      /end-free

