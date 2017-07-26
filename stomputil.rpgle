**FREE

///
// STOMP : Utilities module
//
// \author Mihael Schmidt
// \date   26.07.2017
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

ctl-opt nomain;

//
// Prototypes
//
/include 'iconv_h.rpgle'
/include 'stomputil_h.rpgle'
/include 'message/message_h.rpgle'


//
// Procedures
//

dcl-proc translateToAscii export;
  dcl-pi *N;
    string pointer;
    pLength uns(10) const;
  end-pi;

  dcl-ds iconv_table likeds(iconv_t) static;
  dcl-s isInit ind inz(*off) static;
  dcl-s length uns(10);

  dcl-ds iconv_from qualified;
    ccsid int(10) inz(0);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;
  
  dcl-ds iconv_to qualified;
    ccsid int(10) inz(819);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;
  
  length = pLength;
  
  if (not isInit);
    iconv_table = iconv_open(iconv_to : iconv_from);
    if (iconv_table.return_value = -1);
      message_sendEscapeMessageToCaller('Could not init iconv data structure.');
    endif;
  endif;
  
  if (iconv(iconv_table : string : length : string : length) = -1);
    message_sendEscapeMessageToCaller('Error converting data.');
  endif;
  
  iconv_close(iconv_table);
end-proc;


dcl-proc translateFromAscii export;
  dcl-pi *N;
    string pointer;
    pLength uns(10) const;
  end-pi;
  
  dcl-ds iconv_table likeds(iconv_t) static;
  dcl-s isInit ind inz(*off) static;
  dcl-s length uns(10);

  dcl-ds iconv_from qualified;
    ccsid int(10) inz(819);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  dcl-ds iconv_to qualified;
    ccsid int(10) inz(0);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  length = pLength;
  
  if (not isInit);
    iconv_table = iconv_open(iconv_to : iconv_from);
    if (iconv_table.return_value = -1);
      message_sendEscapeMessageToCaller('Could not init iconv data structure.');
    endif;
  endif;
  
  if (iconv(iconv_table : string : length : string : length) = -1);
    message_sendEscapeMessageToCaller('Error converting data.');
  endif;
  
  iconv_close(iconv_table);
end-proc;


dcl-proc translateToUtf8 export;
  dcl-pi *N;
    string pointer;
    pLength uns(10) const;
  end-pi;

  dcl-ds iconv_table likeds(iconv_t) static;
  dcl-s isInit ind inz(*off) static;
  dcl-s length uns(10);

  dcl-ds iconv_from qualified;
    ccsid int(10) inz(0);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;
  
  dcl-ds iconv_to qualified;
    ccsid int(10) inz(1208);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  dcl-s rc int(20);

 length = pLength;

 if (not isInit);
   iconv_table = iconv_open(iconv_to : iconv_from);
   if (iconv_table.return_value = -1);
     message_sendEscapeMessageToCaller('Could not init iconv data structure.');
   endif;
 endif;

  rc = iconv(iconv_table : string : length : string : length);
  if (rc = -1);
    message_sendEscapeMessageToCaller('Error converting data.');
  endif;
  
  iconv_close(iconv_table);
end-proc;


dcl-proc translateFromUtf8 export;
  dcl-pi *N;
    string pointer;
    pLength uns(10) const;
  end-pi;

  dcl-ds iconv_table likeds(iconv_t) static;
  dcl-s isInit ind inz(*off) static;
  dcl-s length uns(10);

  dcl-ds iconv_from qualified;
    ccsid int(10) inz(1208);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  dcl-ds iconv_to qualified;
    ccsid int(10) inz(0);
    convAlt int(10) inz(0);
    subsAlt int(10) inz(0);
    shiftAlt int(10) inz(1);
    inpLenOp int(10) inz(0);
    errorOpt int(10) inz(1);
    reserved char(8) inz(*ALLx'00');
  end-ds;

  length = pLength;

  if (not isInit); 
    iconv_table = iconv_open(iconv_to : iconv_from);
    if (iconv_table.return_value = -1);
      message_sendEscapeMessageToCaller('Could not init iconv data structure.');
    endif;
  endif;

  if (iconv(iconv_table : string : length : string : length) = -1);
    message_sendEscapeMessageToCaller('Error converting data.');
  endif;

  iconv_close(iconv_table);
end-proc;
 