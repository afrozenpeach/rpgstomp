     /**
      * \brief STOMP Client : Durable subscriber
      *
      * This example program connects to an ActiveMQ instance on localhost and
      * listens for every message on the topic "retailprice". If three messages
      * are received this program will end. This program uses the client id
      * stomprecv1@localhost.com.
      *
      * \author Mihael Schmidt
      * \date   26.07.2017
      */
     

      *-------------------------------------------------------------------------
      * PEP
      *-------------------------------------------------------------------------
     D main            PR                  extpgm('STOMPRECV1')
     D main            PI


      *-------------------------------------------------------------------------
      * Prototypen
      *-------------------------------------------------------------------------
      /include QLOG4RPG,PLOG4RPG
      /include 'stomp/stomp_h.rpgle'


      *-------------------------------------------------------------------------
      * Variablen
      *-------------------------------------------------------------------------
     D frame           S               *
     D client          S               *
     D extension       S               *
     D running         S               N   inz(*on)
     D count           S             10I 0
     D string          S          10000A
     D ptr             S               *
      /free
       monitor;

         // set up logging - you need to specify your own logging configuration here
         //Configurator_loadPropertiesConfiguration(
         //     'mbr:*LIBL/LOGGING.LOGSTOMPRC');

         // set up stomp client
         client = stomp_create('server.com' : 61613);
         stomp_setClientId(client : 'stomprecv1@localhost.com');
         stomp_setDurableSubscriberName(client : 'stomprecv1@localhost.com');
         stomp_setTimeout(client : 3600000);

         stomp_setAckMode(client : STOMP_ACK_MODE_CLIENT);

         stomp_useReceipts(client : *on);

         stomp_open(client);


         dsply 'network connection established';

         if (stomp_command_connect(client : 'user' : 'pass'));

           stomp_command_subscribe(client : '/queue/retailprice');

           dow (running);

             frame = stomp_receiveFrame(client);

             // check if a frame was received
             if (frame <> *null);
               ptr = stomp_frame_toString(frame);
               string = %str(ptr);
               stomp_frame_finalize(frame);
               msg_sendProgramMessage(string);
             endif;

             count += 1;
             if (count = 3);
               running = *off;
             endif;
           enddo;

           stomp_command_disconnect(client);
         else;
           dsply 'could not connect with the CONNECT command';
         endif;

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

