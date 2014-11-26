/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Closes a GDS II library file.
 * 
 * gds_close(gf);
 *
 * Input
 * gf :    a file handle returned by gds_open. 
 * 
 */

#include "gdsio.h"
#include "mex.h"
#include "mexfuncs.h"

/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   FILE *fob;                  /* file object pointer */

   /* check argument number */
   if (nrhs != 1) {
      mexErrMsgTxt("gds_close :  expected 1 input argument.");
   }
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* close file */
   if ( fclose(fob) )
      mexErrMsgTxt("gds_close :  failed to close file.");
}

/*-----------------------------------------------------------------*/
