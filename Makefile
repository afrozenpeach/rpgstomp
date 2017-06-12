#
# Build script for stomp
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

# LFLAGS = binding parameter
LFLAGS=BNDDIR(QC2LE) BNDSRVPGM(LIBTREE LLIST LOG4RPG MESSAGE REFLECTION) OPTION(*DUPPROC)

FROM_CCSID=37

#
# User-defined part end
#-----------------------------------------------------------


MODULES=STOMP STOMPCMD STOMPFRAME STOMPPARSE STOMPUTIL STOMPEXT STOMPEXTAQ FILEDESC
BINDER=stomp.bnd 

.SUFFIXES: .rpgle .c .cpp

# suffix rules
.rpgle:
	system -kpieb "CRTRPGMOD $(BIN_LIB)/$@ SRCSTMF('$<') $(RCFLAGS)"
	
.c:
	system "CRTCMOD $(BIN_LIB)/$@ SRCSTMF('$<') $(CCFLAGS)"
	
.cpp:
	system "CRTCPPMOD $(BIN_LIB)/$@ SRCSTMF('$<')"

all: compile bind install

.PHONY:	
        
compile: $(MODULES)

stomp.bnd: .PHONY
	-system "CRTSRCPF $(BIN_LIB)/STOMPSRV RCDLEN(112)"
	-system "CPYFRMIMPF FROMSTMF('$@') TOFILE($(BIN_LIB)/STOMPSRV STOMP) RCDDLM(*ALL) STRDLM(*NONE) RPLNULLVAL(*FLDDFT) FLDDLM(';')"

bind: $(BINDER) .PHONY
	system -kpieb "CRTSRVPGM $(BIN_LIB)/STOMP MODULE($(MODULES)) EXPORT(*SRCFILE) SRCFILE($(BIN_LIB)/STOMPSRV) TEXT('stomp client library') $(LFLAGS)"

install: .PHONY
	-mkdir $(INCLUDE)/stomp
	-setccsid $(FROM_CCSID) $(INCLUDE)/stomp
	cp stomp_h.rpgle $(INCLUDE)/stomp/
	cp stompcmd_h.rpgle $(INCLUDE)/stomp/
	cp stompframe_h.rpgle $(INCLUDE)/stomp/
	cp stompext_h.rpgle $(INCLUDE)/stomp/
	cp stompext_amq_h.rpgle $(INCLUDE)/stomp/
	setccsid $(FROM_CCSID) $(INCLUDE)/stomp/*
	
clean:
	-system "DLTMOD $(BIN_LIB)/STOMP"
	-system "DLTMOD $(BIN_LIB)/STOMPCMD"
	-system "DLTMOD $(BIN_LIB)/STOMPFRAME"
	-system "DLTMOD $(BIN_LIB)/STOMPPARSE"
	-system "DLTMOD $(BIN_LIB)/STOMPEXT"
	-system "DLTMOD $(BIN_LIB)/STOMPEXTAQ"
	-system "DLTMOD $(BIN_LIB)/STOMPUTIL"
	-system "DLTMOD $(BIN_LIB)/FILEDESC"
	-system "DLTF $(BIN_LIB)/STOMPSRV"
	
dist-clean: clean
	-system "DLTSRVPGM $(BIN_LIB)/STOMP"
