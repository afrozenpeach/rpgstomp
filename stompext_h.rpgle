**FREE

/if not defined (STOMP_EXT)
/define STOMP_EXT

///
// STOMP : Extension Proxy
//
// TBD
//
// \author Mihael Schmidt
// \date   26.07.2017
// \project STOMP
///

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

//
// Prototypes
//
dcl-pr stomp_ext_create pointer extproc('stomp_ext_create');
  extension char(10) const;
  userdata pointer const options(*nopass : *string);
  procedureName char(256) const options(*nopass);
end-pr;

dcl-pr stomp_ext_getId varchar(50) extproc('stomp_ext_getId');
  extension pointer const;
end-pr;

dcl-pr stomp_ext_connect extproc('stomp_ext_connect');
  extension pointer const;
  client pointer const;
  frame pointer const;
  user varchar(100) const options(*nopass);
  pass varchar(100) const options(*nopass);
end-pr;

dcl-pr stomp_ext_send extproc('stomp_ext_send');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
  messageData pointer const options(*string);
end-pr;

dcl-pr stomp_ext_disconnect extproc('stomp_ext_disconnect');
  extension pointer const;
  client pointer const;
  frame pointer const;
end-pr;

dcl-pr stomp_ext_subscribe extproc('stomp_ext_subscribe');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_ext_unsubscribe extproc('stomp_ext_unsubscribe');
  extension pointer const;
  client pointer const;
  frame pointer const;
  destination varchar(100) const;
end-pr;

dcl-pr stomp_ext_finalize extproc('stomp_ext_finalize');
  extension pointer;
end-pr;

/endif
