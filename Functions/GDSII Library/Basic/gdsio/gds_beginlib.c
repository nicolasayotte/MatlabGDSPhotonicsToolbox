/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Writes a library header to a GDS II library file.
 * 
 * gds_beginlib(gf, uunit, dbunit, lname, reflibs, fonts);
 *
 * Input
 * gf :     a file handle returned by gds_open.
 * uunit :  user unit in m
 * dbunit:  database unit in m
 * lname :  string with the library name
 * reflibs : cell array with names of referenced libraries
 * fonts : cell array with font names
 */

#include <string.h>
#include "gdsio.h"
#include "mex.h"
#include "mexfuncs.h"

#define NLEN   256

#define UUNIT_ARG    1
#define DBUNIT_ARG   2
#define LNAME_ARG    3
#define REFLIBS_ARG  4
#define FONTS_ARG    5


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   mxArray *pd;           /* pointers to matrix objects*/
   FILE *fob;             /* file object pointer */
   date_t cdate, mdate;   /* dates */
   double *uunit, *dbunit;
   char name[NLEN];      /* library name */
   int len, k, nrl, nfn;


   /* check argument number */
   if (nrhs != 6)
      mexErrMsgTxt("6 input arguments expected.");
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* write HEADER record (file version 7) */
   if ( write_record_hdr(fob, HEADER, sizeof(uint16_t)) )
      mexErrMsgTxt("failed to write HEADER record.");
   if ( write_word(fob, 7) )
      mexErrMsgTxt("failed to write library version.");

   /* write BGNLIB record and dates */
   now(cdate);
   if ( write_record_hdr(fob, BGNLIB, 2*sizeof(date_t)) )
      mexErrMsgTxt("failed to write BGNLIB record.");
   now(cdate);
   if ( write_word_n(fob, cdate, 6) )
      mexErrMsgTxt("failed to write cdate.");
   now(mdate);
   if ( write_word_n(fob, mdate, 6) )
      mexErrMsgTxt("failed to write mdate.");
   
   /* write LIBNAME record */	
   if ( mxGetString(prhs[LNAME_ARG], name, NLEN) )
      mexErrMsgTxt("failed to access library name argument.");
   len = strlen(name);
   if (len % 2)
      len += 1;
   if ( write_record_hdr(fob, LIBNAME, len) )
      mexErrMsgTxt("failed to write LIBNAME record.");
   if ( write_string(fob, name, len) )
      mexErrMsgTxt("failed to write LIBNAME string.");
   
   /* REFLIBS record */
   if ( !mxIsEmpty(prhs[REFLIBS_ARG]) ) {

      if ( !mxIsCell(prhs[REFLIBS_ARG]) )
         mexErrMsgTxt("reflibs must be in a cell array.");

      nrl = mxGetM(prhs[REFLIBS_ARG]) * mxGetN(prhs[REFLIBS_ARG]);  /* number of strings */
      if (nrl > 15)
         mexErrMsgTxt("max 15 reflibs allowed.");

      if ( write_record_hdr(fob, REFLIBS, nrl*44) )
	 mexErrMsgTxt("failed to write REFLIBS record.");
      for (k=0; k<nrl; k++) {
	 memset(name, '\0', NLEN);   /* fill string with 0 */
	 pd = mxGetCell(prhs[REFLIBS_ARG], k);
	 mxGetString(pd, name, NLEN);
	 if (strlen(name) > 44)
	    mexErrMsgTxt("reflib names must have <= 44 chars.");
	 if ( write_string(fob, name, 44) )
	    mexErrMsgTxt("failed to write a reflib name.");
      }
   }

   /* FONTS record */
   if ( !mxIsEmpty(prhs[FONTS_ARG]) ) {

      if ( !mxIsCell(prhs[FONTS_ARG]) )
         mexErrMsgTxt("fonts must be in a cell array.");

      nfn = mxGetM(prhs[FONTS_ARG]) * mxGetN(prhs[FONTS_ARG]);  /* number of strings */
      if (nfn > 4)
         mexErrMsgTxt("max 4 fonts allowed.");

      if ( write_record_hdr(fob, FONTS, nfn*44) )
	 mexErrMsgTxt("failed to write FONTS record.");
      for (k=0; k<nfn; k++) {
	 memset(name, '\0', NLEN);   /* fill string with 0 */
	 pd = mxGetCell(prhs[FONTS_ARG], k);
	 mxGetString(pd, name, NLEN);
	 if (strlen(name) > 44)
	    mexErrMsgTxt("font names must have <= 44 chars.");
	 if ( write_string(fob, name, 44) )
	    mexErrMsgTxt("failed to write a font name.");
      }
   }

   /* UNITS record */
   if ( write_record_hdr(fob, UNITS, 2*8) )
      mexErrMsgTxt("failed to write UNITS record.");
   uunit  = mxGetData(prhs[UUNIT_ARG]);
   dbunit = mxGetData(prhs[DBUNIT_ARG]);
   if ( write_real8(fob, dbunit[0]/uunit[0]) )
      mexErrMsgTxt("failed to write dbunit/uunit.");
   if ( write_real8(fob, dbunit[0]) )
      mexErrMsgTxt("failed to write dbunit.");
}

/*-----------------------------------------------------------------*/
