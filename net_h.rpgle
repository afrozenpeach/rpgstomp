      /if not defined(NET_H)
      /define NET_H

     D inet_addr       PR            10U 0 extproc('inet_addr')
     D  address_str                    *   value options(*string)

     D inet_ntoa       PR              *   extproc('inet_ntoa')
     D  internet_addr                10U 0 value

     D gethostbyname   PR              *   extproc('gethostbyname')
     D   host_name                     *   value options(*string)

      /endif

