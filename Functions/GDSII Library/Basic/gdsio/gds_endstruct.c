/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Writes an ENDSTR record to a GDS II library file.
 * 
 * gds_endstruct(gf);
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
      mexErrMsgTxt("gds_endstruct :  expected 1 input argument.");
   }
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* write record header */
   if ( write_record_hdr(fob, ENDSTR, 0) )
      mexErrMsgTxt("gds_endstruct :  failed to write ENDSTR record.");
}

/*-----------------------------------------------------------------*/
