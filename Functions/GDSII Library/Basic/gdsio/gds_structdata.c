/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Reads structure header data from a GDS II library file.
 * 
 * [sname, cdate, mdate] = gds_structdata(gf);
 *
 * Input
 * gf :     a file handle returned by gds_open.
 *
 * Output:
 * sname :  a string with the structure name
 * cdate :  creation data of the structure
 * mdate :  creation data of the structure
 * 
 */

#include "gdsio.h"
#include "mex.h"
#include "mexfuncs.h"

#define NLEN   48


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   FILE *fob;          /* file object pointer */
   double *pd;         /* pointer to data */
   date_t cdate;       /* creation date */
   date_t mdate;       /* modification date */
   char sname[NLEN];   /* structure name */
   uint16_t rtype, rlen;
   int k;

   /* check argument number */
   if (nrhs != 1) {
      mexErrMsgTxt("gds_structdata :  1 input arguments expected.");
   }
   if (nlhs != 3) {
      mexErrMsgTxt("gds_structdata :  3 output arguments expected.");
   }     
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* read dates */
   if ( read_word_n(fob, cdate, 6) )
      mexErrMsgTxt("gds_structdata :  failed to read structure cdate.");
   if ( read_word_n(fob, mdate, 6) )
      mexErrMsgTxt("gds_structdata :  failed to read structure mdate.");

   /* STRNAME record */
   if ( read_record_hdr(fob, &rtype, &rlen) )
      mexErrMsgTxt("gds_structdata :  failed to read STRNAME record.");
   if (rtype != STRNAME)   
      mexErrMsgTxt("gds_structdata :  invalid STRNAME record.");
   if ( read_string(fob, sname, rlen) )
      mexErrMsgTxt("gds_structdata :  failed to read structure name.");
     
   /* return structure name */
   plhs[0] = mxCreateString(sname);

   /* return creation date */
   plhs[1] = mxCreateDoubleMatrix(1, 6, mxREAL);
   pd = mxGetData(plhs[1]);
   for (k=0; k<6; k++) {
      pd[k] = (double)cdate[k];
   }

   /* return modification date */
   plhs[2] = mxCreateDoubleMatrix(1, 6, mxREAL);
   pd = mxGetData(plhs[2]);
   for (k=0; k<6; k++) {
      pd[k] = (double)mdate[k];
   }
}

/*-----------------------------------------------------------------*/
