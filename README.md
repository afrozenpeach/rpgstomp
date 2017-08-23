# STOMP Client for RPG

## About
From the former STOMP web site (at codehaus.org):

> The STOMP project is the Streaming Text Orientated Messaging Protocol site (or
> the Protocol Briefly Known as TTMP and Represented by the symbol :ttmp).
> STOMP provides an interoperable wire format so that any of the available Stomp
> Clients can communicate with any STOMP Message Broker to provide easy and 
> widespread messaging interop among languages, platforms and brokers.

The RPG client makes it possible to speak to messaging systems like ActiveMQ, 
RabbitMQ, Apollo, Artemis ... **natively**.

## Protocol

The protocol is listed at [github](https://github.com/stomp/stomp-spec).

> STOMP is a frame based protocol, with frames modelled on HTTP. A frame consists
> of a command, a set of optional headers and an optional body. STOMP is text 
> based but also allows for the transmission of binary messages.

A frame contains data for the Message Queuing Server (command and headers) but 
also the data for the receiver of the message (body).

## Client API

The client API is divided into many smaller modules:

- STOMP (stomp) - main client module
- STOMPFRAME (stomp_frame) - building and working with frames
- STOMPPARSE (stomp_frame) - buiding a frame from its serialized state
- STOMPCMD (stomp_command) - executing Stomp commands
- STOMPEXT (stomp_ext) - proxy/interface for RPG Stomp extension modules
- STOMPEXTAQ (stomp_ext_activemq) - RPG Stomp extension module for ActiveMQ
- STOMPUTIL (stomp_util) - utility procedures

Using this Stomp client starts with the main module. A client has to be created 
with the stomp_create procedure which returns a handle which is used on every 
later call.

    client = stomp_create('localhost' : 61216);

The socket to the client must be explicitly opened for communicating with the 
server.

    stomp_open(client);

The client not only needs a connection to the server on a network level but also 
on an application level. The server expects a CONNECT Stomp frame.

    stomp_command_connect(client);

After successfully connecting to the server it accepts messages from this client.

    stomp_command_send(client : '/topic/retailprice' : '{ "id":5500 , "oldprice":1.23 , "newprice":1.59 }');

If no more messages are sent or received the client needs to disconnect from the 
server.

    stomp_command_disconnect(client);

The allocated resources must be freed after finishing the communication with the 
server.

    stomp_finalize(client);

## Logging

This client uses [Log4RPG](http://www.tools400.de/English/Freeware/Service_Programs/Log4rpg/log4rpg.html) as a logging facility. The program using the client API just needs to load a logging configuration and the log messages will be handled according to the logging configuration.

    Configurator_loadPropertiesConfiguration('mbr:*LIBL/LOGGING.LOGSTOMP');

The following modules define these named loggers:

- STOMP - rpgnextgen.stomp
- STOMPFRAME - rpgnextgen.stomp.frame
- STOMPPARSE - rpgnextgen.stomp.parser
- STOMPCMD - rpgnextgen.stomp.command
- STOMPEXTAQ - rpgnextgen.stomp.ext.activemq

The logging is just optional. If no logging is configured the client will run 
just fine.

### Logging Configuration Example

```
  log4rpg=on
  log4rpg.debug=off, printer
  log4rpg.rootLogger=ERROR, file
 
  log4rpg.logger.rpgnextgen.stomp=INFO, file
  log4rpg.logger.rpgnextgen.stomp.parser=ERROR, file
  log4rpg.logger.rpgnextgen.stomp.frame=WARN, file
 
  log4rpg.appender.file=*LIBL/LOG4RPG(DailyRollingFileAppender)
  log4rpg.appender.file.path=/var/log/stomp/stomp-example.log
  log4rpg.appender.file.datePattern=yyyy-MM-dd
  log4rpg.appender.file.layout=PatternLayout
  log4rpg.appender.file.layout.conversionPattern=%z [%-5p] %L/%P(%M).%F (%S) %m%n
```

## Extensions

Some message queuing systems implement the Stomp protocol differently or extending 
the function set by adding new headers to the frames. There is an extension 
mechanism for tweaking the Stomp frames for these systems (STOMPEXT). The 
extension module must implement the stomp_ext interface. For each call on a 
procedure in the *COMMAND* module the corresponding procedure in the extension 
module will be called.

For telling the client which extension to use the procedure *stomp_setExtension* 
or *stomp_setExtensionByName* must be called.

    stomp_setExtension(client : stomp_ext_activemq_create());

or

    stomp_setExtensionByName(client : 'STOMPEXTAQ' : *null : 'stomp_ext_activemq_create');
   
## Requirements

This software package has the following dependencies:

- [Message](https://bitbucket.org/m1hael/message)
- [Linked List](https://bitbucket.org/m1hael/llist)
- [libtree](https://bitbucket.org/m1hael/libtree)
- [Reflection](https://bitbucket.org/m1hael/reflection)
- [Log4RPG](http://tools400.de/Deutsch/Freeware/Service-Pgme/Log4rpg/log4rpg.html)

## Installation

For standard installation the setup script can be executed as is. This will 
build the service program in the library *OSSILE*. If you want to build the
service program in any other library export the library name in the variable
`TARGET_LIB` like this

    export TARGET_LIB=MIHAEL

*before* executing the *setup* script.

As this service program relies on other libraries the place for the copybook
needs to be stated. This is also be the place where the copybooks of the
STOMP serviceprogram will be copied to.

    export INCDIR=/usr/local/include/

## Documentation

The API documentation is be available at [ILEDocs](http://iledocs.rpgnextgen.com) 
hosted at rpgnextgen.com.

## Links

- [ActiveMQ](https://activemq.apache.org)
- [STOMP](https://github.com/stomp/stomp-spec)
