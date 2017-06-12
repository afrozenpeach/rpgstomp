#
# Build script for stomp examples
#

#-----------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# the rpg modules and the binder source file are also created in BIN_LIB.
# binder source file and rpg module can be remove with the clean step (make clean)
BIN_LIB=QGPL

# to this library the prototype source file (copy book) is copied in the install step
INCLUDE=/usr/local/include

# CFLAGS = RPG compile parameter
RCFLAGS=DBGVIEW(*LIST) INCDIR('$(INCLUDE)')

# CCFLAGS = C compiler parameter
CCFLAGS=OPTIMIZE(30) DBGVIEW(*LIST)

# LFLAGS = binding parameter
LFLAGS=BNDSRVPGM(STOMP MESSAGE LOG4RPG)

FROM_CCSID=37

#
# User-defined part end
#-----------------------------------------------------------

MODULES=frame01 framelog01 stomp01 stomprecv1

.SUFFIXES: .rpgle .c .cpp

# suffix rules
.rpgle:
	system "CRTRPGMOD $(BIN_LIB)/$@ SRCSTMF('$<') $(RCFLAGS)"
	
.c:
	system "CRTCMOD $(BIN_LIB)/$@ SRCSTMF('$<') $(CCFLAGS)"
	
.cpp:
	system "CRTCPPMOD $(BIN_LIB)/$@ SRCSTMF('$<')"

all: examples

.PHONY:	
        
compile: $(MODULES)

clean:
	-system "DLTMOD $(BIN_LIB)/FRAME01"
	-system "DLTPGM $(BIN_LIB)/FRAME01"
	-system "DLTMOD $(BIN_LIB)/FRAMELOG01"
	-system "DLTPGM $(BIN_LIB)/FRAMELOG01"
	-system "DLTMOD $(BIN_LIB)/STOMP01"
	-system "DLTPGM $(BIN_LIB)/STOMP01"
	-system "DLTMOD $(BIN_LIB)/STOMPRECV1"
	-system "DLTPGM $(BIN_LIB)/STOMPRECV1"
	
examples: $(MODULES) .PHONY
	system "CRTPGM $(BIN_LIB)/FRAME01 $(LFLAGS)"
	system "CRTPGM $(BIN_LIB)/FRAMELOG01 $(LFLAGS)"
	system "CRTPGM $(BIN_LIB)/STOMP01 $(LFLAGS)"
	system "CRTPGM $(BIN_LIB)/STOMPRECV1 $(LFLAGS)"
 
