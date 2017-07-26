**FREE

/if not defined(STOMP_FRAME_H)
/define STOMP_FRAME_H

///
// STOMP : Frame Module
//
// This module provides procedures for creating and querying a stomp frame.
// <br><br>
// Log entries will be written via the logger <em>rpgnextgen.stomp.frame</em>.
// There is no appender configured for this logger. Feel free to add log appenders
// for this logger.
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

///
// Create stomp frame
//
// Creates a stomp frame and if the parameters are passed also initializes it.
//
// \param Stomp command (optional)
// \param Frame body text (optional)
//
// \info The resources allocated with this frame must be released by the caller
//       with the <em>stomp_frame_finalize</em> procedure.
///
dcl-pr stomp_frame_create pointer extproc('stomp_frame_create');
  command like(stomp_frame_command) const options(*nopass);
  body varchar(65335) const options(*nopass);
end-pr;

///
// Finalize stomp frame
//
// Releases all resources allocated to the frame.
//
// \param Frame
///
dcl-pr stomp_frame_finalize extproc('stomp_frame_finalize');
  frame pointer;
end-pr;

///
// Set stomp frame header value
//
// Sets a header (key and value) on the passed stomp frame.
// <br>
// If this header already exists its value will be replaced with the one passed.
//
// \todo If the header is already present in this frame it will be added after
//       the original header as the stomp protocol supports multiple version of
//       the same header. STOMP Spec 1.1
//
// \param Frame
// \param Stomp frame header (key)
// \param Value
///
dcl-pr stomp_frame_setHeader extproc('stomp_frame_setHeader');
  frame pointer const;
  header like(stomp_frame_header) const;
  value varchar(1024) const;
end-pr;

///
// Get stomp frame header value
//
// Returns the value from the passed header of the stomp frame.
//
// \param Frame
// \param Stomp frame header (key)
//
// \return Value
//
// \throws CPF9898 Header not found in stomp frame
///
dcl-pr stomp_frame_getHeaderValue varchar(1024) extproc('stomp_frame_getHeader');
  frame pointer const;
  header like(stomp_frame_header) const;
end-pr;

///
// List stomp frame headers
//
// Returns a map for stomp frame headers (key/value pairs).
//
// \param Frame
//
// \returns Map with headers
//
// \info The caller of this procedure must make sure to free the
//       allocated resources of the returnen map with
//       <em>tree_rb_string_finalize(map)</em>.
///
dcl-pr stomp_frame_listHeaders pointer extproc('stomp_frame_listHeaders');
  frame pointer const;
end-pr;

///
// Remove stomp frame header
//
// Removes the header from the passed stomp frame.
// <br>
// If the header does not exist this procedure does nothing.
//
// \todo If the header is already present in this frame it will be added after
//       the original header as the stomp protocol supports multiple version of
//       the same header. STOMP Spec 1.1
//
// \param Frame
// \param Stomp frame header (key)
///
dcl-pr stomp_frame_removeHeader extproc('stomp_frame_removeHeader');
  frame pointer const;
  header like(stomp_frame_header) const;
end-pr;

///
// Set command
//
// Sets the command in the stomp frame.
//
// \param Frame
// \param Command
//
// \throws CPF9898 Invalid stomp command
///
dcl-pr stomp_frame_setCommand extproc('stomp_frame_setCommand');
  frame pointer const;
  command like(stomp_frame_command) const;
end-pr;

///
// Get command
//
// Returns the command of this stomp frame.
//
// \param Frame
//
// \return Command (is *blank if not set yet)
///
dcl-pr stomp_frame_getCommand like(stomp_frame_command) extproc('stomp_frame_getCommand');
  frame pointer const;
end-pr;

///
// Set body/content
//
// Sets the body/content of this frame.
// <br>
// If this frame already contains a content the old content will be
// replaced by the new one.
//
// \param Frame
// \param Content (null-terminated)
///
dcl-pr stomp_frame_setBody extproc('stomp_frame_setBody');
  frame pointer const;
  body pointer const options(*string);
end-pr;

///
// Return message body
//
// Returns a pointer to the body text of this frame.
// The string is null-terminated.
//
// \param Frame
//
// \return Pointer to message body (may be null if not set)
///
dcl-pr stomp_frame_getBody pointer extproc('stomp_frame_getBody');
  frame pointer const;
end-pr;

dcl-pr stomp_frame_toString pointer extproc('stomp_frame_toString');
  frame pointer const;
end-pr;

///
// Check if frame contains header
//
// Checks if the frame contains the header.
//
// \param Frame
// \param Header
//
// \return *on = frame contains header otherwise *off
///
dcl-pr stomp_frame_containsHeader ind extproc('stomp_frame_containsHeader');
  frame pointer const;
  header like(stomp_frame_header) const;
end-pr;

///
// String representation of a stomp frame
//
// Returns a string representation of this stomp frame.
// The string is encoded in the CCSID of the current job.
//
// \param Frame
//
// \return Pointer to the string (null-terminated) or null if the pointer to
//         the frame is null.
//
// \info The caller must take of releasing the allocated memory of the returned string.
//
// \throws CPF9898 Stomp frame is not valid
///
dcl-pr stomp_frame_dump extproc('stomp_frame_dump');
  frame pointer const;
end-pr;


//
// Templates
//
dcl-s stomp_frame_header varchar(50) template;
dcl-s stomp_frame_command varchar(20) template;

/endif
