#
# makefile for the Clipper Library MEX function
#

CC = g++
CXXFLAGS = -O3 -fPIC

MXCOMP = mkoctfile

# these flags are normally used
MFLAGS = --mex -s

# the following is for debugging
#MFLAGS = --mex -g -Wall

# primary target
all: mex clean

mex: poly_boolmex.mex 

poly_boolmex.mex : poly_boolmex.cpp clipper.o
	$(MXCOMP) $(MFLAGS) poly_boolmex.cpp clipper.o

clipper.o : clipper.cpp
	$(CC) -c $(CXXFLAGS) clipper.cpp

# cleanup
clean:
	rm -f *.o

cleanall:
	rm -f *.o *.mex
