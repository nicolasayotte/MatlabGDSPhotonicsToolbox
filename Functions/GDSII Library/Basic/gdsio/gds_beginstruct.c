/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Writes a structure header to a GDS II library file.
 * 
 * gds_beginstruct(gf, sname, cdate);
 *
 * Input
 * gf :     a file handle returned by gds_open.
 * sname :  a string with the structure name
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
   date_t cdate;       /* creation date */
   date_t mdate;       /* modification date */
   char sname[NLEN];   /* structure name */
   int slen;           /* string length */

   /* check argument number */
   if (nrhs != 3) {
      mexErrMsgTxt("3 input arguments expected.");
   }
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* BGNSTR record */
   if ( write_record_hdr(fob, BGNSTR, 2*sizeof(date_t)) )
      mexErrMsgTxt("failed to write BGNSTR record.");

   /* BGNSTR creation date */
   now(cdate);
   if ( write_word_n(fob, cdate, 6) ) /* NOTE: changes byte order in cdate */
      mexErrMsgTxt("failed to write BGNSTR record (cdate).");

   /* BGNSTR modification date */
   now(mdate);
   if ( write_word_n(fob, mdate, 6) ) /* same as cdate */
      mexErrMsgTxt("failed to write BGNSTR record (mdate).");
   
   /* STRNAME record */
   mxGetString(prhs[1], sname, NLEN-2);
   slen = mxGetN(prhs[1]);  /* string length */
   if (slen > 32) {
      mexPrintf("\nStructure name %s exceeds 32 characters\n\n", sname);
      mexErrMsgTxt("structure name too long.");     
   }
   if (slen % 2)          /* string length is odd */
      slen += 1;
   if ( write_record_hdr(fob, STRNAME, slen) )
      mexErrMsgTxt("failed to write STRNAME record.");
   if ( write_string(fob, sname, slen) )
      mexErrMsgTxt("failed to write STRNAME record (sname).");
}

/*-----------------------------------------------------------------*/
