      /if not defined(SOCKET_H)
      /define SOCKET_H

      /if defined(SOCKET_UNIX98)
     D socket          PR            10I 0 extproc('qso_socket98')
      /else
     D socket          PR            10I 0 extproc('socket')
      /endif
     D  addr_family                  10I 0 value
     D  type                         10I 0 value
     D  protocol                     10I 0 value

      /if defined(SOCKET_UNIX98)
     D connect         PR            10I 0 extproc('qso_connect98')
      /else
     D connect         PR            10I 0 extproc('connect')
      /endif
     D  sock_desc                    10I 0 value
     D  dest_addr                      *   value
     D  addr_len                     10I 0 value

      /if defined(SOCKET_UNIX98)
     D send            PR            10I 0 extproc('qso_send98')
      /else
     D send            PR            10I 0 extproc('send')
      /endif
     D   sock_desc                   10I 0 value
     D   buffer                        *   value
     D   buffer_len                  10I 0 value
     D   flags                       10I 0 value

      /if defined(SOCKET_UNIX98)
     D recv            PR            10I 0 extProc('qso_recv98')
      /else
     D recv            PR            10I 0 extProc('recv')
      /endif
     D   sock_desc                   10I 0 value
     D   buffer                        *   value
     D   buffer_len                  10I 0 value
     D   flags                       10I 0 value

      /if defined(SOCKET_UNIX98)
     D setsockopt      PR            10I 0 extproc('qso_setsockopt98')
      /else
     D setsockopt      PR            10I 0 extproc('setsockopt')  
      /endif
     D   socket_desc                 10I 0 value                  
     D   level                       10I 0 value                  
     D   option_name                 10I 0 value                  
     D   option_value                  *   value                  
     D   option_length...
     D                               10I 0 value
         
     D close           PR            10I 0 extproc('close')
     D  sock_desc                    10I 0 value

     D select          PR            10I 0 extproc('select')
     D   max_desc                    10I 0 value
     D   read_set                      *   value
     D   write_set                     *   value
     D   except_set                    *   value
     D   wait_Time                     *   value



      *
      * address families
      *
     D AF_UNSPEC       C                   0                                    Unspecified
     D AF_UNIX         C                   1                                    UNIX (local) domain
     D AF_INET         C                   2                                    Internet domain
     D AF_NS           C                   6                                    Network Services
     D AF_INET6        C                   24                                   IPv6
     D AF_UNIX_CCSID   C                   98                                   UNIX with CCSID supp
     D AF_TELEPHONY    C                   99                                   Telephony domain
      *
      * socket types
      *
     D SOCK_STREAM     C                   1
     D SOCK_DGRAM      C                   2
     D SOCK_RAW        C                   3
     D SOCK_SEQPACKET  C                   5
      *
      * protocol
      *
     D PROTOCOL_DEFAULT...
     D                 C                   0
     D IPPROTO_IP      C                   0
     D
     D INADDR_NONE     C                   CONST(4294967295)

     D socket_address_t...
     D                 DS                  qualified template
     D   sa_family                    5I 0
     D   sa_data                     14A

     D socket_address_inet_t...
     D                 DS                  qualified template
      /if defined(SOCKET_UNIX98)
     D   sa_len                       3U 0
     D   family                       3U 0
      /else
     D   family                       5I 0
      /endif
     D   port                         5U 0
     D   addr                        10U 0
     D   zero                         8A
     
     D servent_t       DS                  qualified template
     D   s_name                        *
     D   s_aliases                     *
     D   s_port                      10I 0
     D   s_proto                       *


     D timeout_t       DS                  qualified template
     D   seconds                     10I 0
     D   useconds                    10I 0
     
     D*                                          allow broadcast msgs   
     D SO_BROADCAST    C                   5                            
     D*                                          record debug informatio
     D SO_DEBUG        C                   10                           
     D*                                          just use interfaces,   
     D*                                          bypass routing         
     D SO_DONTROUTE    C                   15                           
     D*                                          error status           
     D SO_ERROR        C                   20                           
     D*                                          keep connections alive 
     D SO_KEEPALIVE    C                   25                           
     D*                                          linger upon close      
     D SO_LINGER       C                   30                           
     D*                                          out-of-band data inline
     D SO_OOBINLINE    C                   35                           
     D*                                          receive buffer size    
     D SO_RCVBUF       C                   40                           
     D*                                          receive low water mark 
     D SO_RCVLOWAT     C                   45                           
     D*                                          receive timeout value   
     D SO_RCVTIMEO     C                   50                            
     D*                                          re-use local address    
     D SO_REUSEADDR    C                   55                            
     D*                                          send buffer size        
     D SO_SNDBUF       C                   60                            
     D*                                          send low water mark     
     D SO_SNDLOWAT     C                   65                            
     D*                                          send timeout value      
     D SO_SNDTIMEO     C                   70                            
     D*                                          socket type             
     D SO_TYPE         C                   75                            
     D*                                          send loopback           
     D SO_USELOOPBACK  C                   80                         
      *
     D SOL_SOCKET      C                   -1
      /endif

