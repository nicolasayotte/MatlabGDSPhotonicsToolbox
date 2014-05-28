/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Reads and returns a GDS II record header.
 * 
 * [rtype, rlen] = gds_record_info(gf);
 *
 * Input
 * gf :     a file handle returned by gds_open.
 * rtype :  the record type 
 * rlen :   (Optional) remaining number of bytes in the record 
 */

#include "gdsio.h"
#include "mex.h"
#include "mexfuncs.h"


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   double *pda;              /* pointer to data*/
   FILE *fob;                /* file object pointer */
   uint16_t rtype, rlen;


   /* check argument number */
   if (nrhs != 1) {
      mexErrMsgTxt("gds_record_info :  expected 1 input argument.");
   }
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* read record header */
   if ( read_record_hdr(fob, &rtype, &rlen) )
      mexErrMsgTxt("gds_record_info :  failed to read record header.");

   /* return record type information to the caller */
   plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
   pda = mxGetData(plhs[0]);
   *pda = (double)rtype;
   
   /* optionally return record length */
   if (nlhs > 1) {
      plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
      pda = mxGetData(plhs[1]);
      *pda = (double)rlen;
   }
}

/*-----------------------------------------------------------------*/
