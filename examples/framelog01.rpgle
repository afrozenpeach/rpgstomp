     /**
      * \brief Stomp Frame Example
      *
      * This example has a 
      * 
      * \author Mihael Schmidt
      * \date   15.04.2011
      */


      *-------------------------------------------------------------------------
      * PEP
      *-------------------------------------------------------------------------
     D main            PR                  extpgm('FRAMELOG01')
     D main            PI


      *-------------------------------------------------------------------------
      * Prototypen
      *-------------------------------------------------------------------------
      /include 'stomp/stomp_h.rpgle'
      /include QLOG4RPG,PLOG4RPG


      *-------------------------------------------------------------------------
      * Variablen
      *-------------------------------------------------------------------------
     D frame           S               *
     D ptr             S               *
     D string          S          65535A
     D dsp             S             50A
     D content         S            100A
      *
     D hLogger         S                   like(LOG4RPG_hLogger_t   ) inz
     D hLayout         S                   like(LOG4RPG_pLayout_t   ) inz
     D hAppender       S                   like(LOG4RPG_pAppender_t ) inz

      /free
       //
       // configure logging
       //
       // this is done as an example only
       // in real life the configuration would be loaded from a properties file
       //
       Configurator_clearConfiguration();
       hLayout = Layout_new('*LIBL/LOG4RPG(SimpleLayout)');
       hAppender = Appender_new('appender'
                                : '*LIBL/LOG4RPG(DailyRollingFileAppender)'
                                : 'path=/tmp/stomp.log;' +
                                  'datePattern=yyyy-MM-dd;');
       Appender_setLayout(hAppender: hLayout);
       
       // configure main logger
       hLogger = Logger_getLogger('de.rpgng.stomp');
       Logger_setLevel(hLogger: cLOG4RPG_LEVEL_DEBUG);
       Logger_addAppender(hLogger: hAppender);
       
       // use own logger for this program
       // (falls back to de.rpgng.stomp as this one is not configured)
       hLogger = Logger_getLogger('de.rpgng.stomp.framelog');
       Logger_info( hLogger : 'Starting example FRAMELOG01 ...');


       frame = stomp_frame_create();

       stomp_frame_setCommand(frame : 'SEND');

       content = '{ "id" : 358 }' + x'00';
       stomp_frame_setBody(frame : %addr(content));

       stomp_frame_setHeader(frame : 'persistent' : 'true');

       ptr = stomp_frame_toString(frame);
       if (ptr <> *null);
         string = %str(ptr);
         dsp = string;
         dsply dsp;
         dealloc ptr;
       else;
         dsply 'toString: nothing';
       endif;

       stomp_frame_finalize(frame);

       Logger_info( hLogger : 'Ending example FRAMELOG01 ...');

       *inlr = *on;
       return;
      /end-free
