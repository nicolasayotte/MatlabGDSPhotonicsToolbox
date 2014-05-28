/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * Returns the current position of the file pointer
 * 
 * fpos = gds_ftell(gf);
 *
 * Input
 * gf :    a file handle returned by gds_open.
 * fpos :  the file position
 * 
 */

#include <stdio.h>
#include "gdsio.h"
#include "mex.h"
#include "mexfuncs.h"

/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   FILE *fob;         /* file object pointer */
   long int pos;
   double *pd;

   /* 
    * check argument number 
    */
   if (nrhs != 1)
      mexErrMsgTxt("expected 1 input argument.");
   
   /* 
    * get file handle argument 
    */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /*
    * get file position and return it
    */
   plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
   pd = mxGetData(plhs[0]);
   pos = ftell(fob);
   if (pos < 0)
      mexErrMsgTxt("failed to obtain file position with ftell().");
   *pd = pos;
}

/*-----------------------------------------------------------------*/
