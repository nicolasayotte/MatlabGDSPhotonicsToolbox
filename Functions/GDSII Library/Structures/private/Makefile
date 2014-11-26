#
# makefile for the DataMatrix MEX function
#

MXCOMP = mkoctfile

# these flags are normally used
MFLAGS = --mex -s

# the following is for debugging
#MFLAGS = --mex -g -Wall

# primary target
all: mex clean

mex: datamatrixmex.mex 

datamatrixmex.mex : datamatrixmex.c
	$(MXCOMP) $(MFLAGS) datamatrixmex.c 

# cleanup
clean:
	rm -f *.o

cleanall:
	rm -f *.o *.mex
