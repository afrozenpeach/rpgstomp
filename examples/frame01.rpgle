     /**
      * \brief Stomp Frame Example
      *
      *
      * \author Mihael Schmidt
      * \date   15.04.2011
      */


      *-------------------------------------------------------------------------
      * PEP
      *-------------------------------------------------------------------------
     D main            PR                  extpgm('FRAME01')
     D main            PI


      *-------------------------------------------------------------------------
      * Prototypen
      *-------------------------------------------------------------------------
      /include 'stomp/stomp_h.rpgle'


      *-------------------------------------------------------------------------
      * Variablen
      *-------------------------------------------------------------------------
     D frame           S               *
     D ptr             S               *
     D string          S          65535A
     D dsp             S             50A
     D content         S            100A
      /free
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

       *inlr = *on;
       return;
      /end-free
