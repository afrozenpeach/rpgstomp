      /if not defined(ICONV_H)
      /define ICONV_H

      *---------------------------------------------------------------
      * Data structures
      *---------------------------------------------------------------
     D iconv_t         DS                  qualified template
     D   return_value                10I 0
     D   cd                          10I 0 dim(12)

     D iconv_op_t      DS                  qualified template
     D  ccsid                        10I 0 inz(0)
     D  convAlt                      10I 0 inz(0)
     D  subsAlt                      10I 0 inz(0)
     D  shiftAlt                     10I 0 inz(1)
     D  inpLenOp                     10I 0 inz(0)
     D  errorOpt                     10I 0 inz(1)
     D  reserved                      8A   inz(*ALLx'00')


      *-------------------------------------------------------------------------
      * Procedures
      *-------------------------------------------------------------------------
     D iconv_open      PR                  extproc('QtqIconvOpen')
     D                                     like(iconv_t)
     D    tocode                           like(iconv_op_t) const
     D    fromcode                         like(iconv_op_t) const

     D iconv           PR            10I 0 extproc('iconv')
     D   cd                                like(iconv_t) value
     D   inbuf                         *
     D   inbytesleft                 10U 0
     D   outbuf                        *
     D   outbytesleft                10U 0

     D iconv_close     PR            10I 0 extproc('iconv_close')
     D   cd                                like(iconv_t) value

      /endif

