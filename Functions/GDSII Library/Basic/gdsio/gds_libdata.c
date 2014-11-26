/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Reads library header data from a GDS II library file.
 * 
 * [ldata] = gds_libdata(gf);
 *
 * Input
 * gf :     a file handle returned by gds_open.
 *
 * Output:
 * data :   a structure with element data
 *           ldata.lname       : library name
 *           ldata.libver      : library version
 *           ldata.cdate       : creation date 
 *           ldata.mdate       : modification date
 *           ldata.uunit       : user unit in m
 *           ldata.dbunit      : database unit in m
 *           ldata.reflibs     : cell array of reference libraries
 *           ldata.fonts       : cell array of font names
 *           ldata.generations : generations to back up (unused)
 */

#include "gdsio.h"
#include "mex.h"
#include "mexfuncs.h"

#define NLEN   256
#define TLEN   46


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   mxArray *ca;           /* pointer to cell array */
   FILE *fob;             /* file object pointer */
   date_t cdate;          /* creation date */
   date_t mdate;          /* modification date */
   double uunit, dbunit;
   char lname[NLEN];      /* library name */
   char name[TLEN];       /* various file names */
   int recn = 0;          /* record number */
   int nrl, nfont;
   uint16_t rtype, rlen;  /* record type and length */
   uint16_t word;
   int k;
   const char *fields[] = {"lname", "libver", "cdate", "mdate",
			   "uunit", "dbunit", "reflibs", "fonts", "generations"};

   /* check argument number */
   if (nrhs != 1)
      mexErrMsgTxt("gds_libdata :  1 input argument expected.");
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* create structure for output */
   plhs[0] = mxCreateStructMatrix(1, 1, 9, fields); 

   /* HEADER record, library version */
   if ( read_record_hdr(fob, &rtype, &rlen) ) {
      mexPrintf("rtype = 0x%x       rlen = %d\n", rtype, rlen);
      mexErrMsgTxt("gds_libdata :  failed to read HEADER record.");
   }
   if (rtype != HEADER)   
      mexErrMsgTxt("gds_libdata :  invalid HEADER record.");
   if ( read_word(fob, &word) )
      mexErrMsgTxt("gds_libdata :  failed to read library version.");
   struct_set_word(plhs[0], 1, &word, 1);

   /* BGNLIB record and dates */
   if ( read_record_hdr(fob, &rtype, &rlen) )
      mexErrMsgTxt("gds_libdata :  failed to read BGNLIB record.");
   if (rtype != BGNLIB)   
      mexErrMsgTxt("gds_libdata :  invalid BGNLIB record.");
   if ( read_word_n(fob, cdate, 6) )
      mexErrMsgTxt("gds_libdata :  failed to read library cdate.");
   struct_set_word(plhs[0], 2, cdate, 6);
   if ( read_word_n(fob, mdate, 6) )
      mexErrMsgTxt("gds_libdata :  failed to read library mdate.");
   struct_set_word(plhs[0], 3, mdate, 6);

   /* LIBNAME record */
   if ( read_record_hdr(fob, &rtype, &rlen) )
      mexErrMsgTxt("gds_libdata :  failed to read LIBNAME record.");
   if (rtype != LIBNAME)   
      mexErrMsgTxt("gds_libdata :  invalid LIBNAME record.");
   if ( read_string(fob, lname, rlen) )
      mexErrMsgTxt("gds_libdata :  failed to read library name.");
   struct_set_string(plhs[0], 0, lname);

   /* Process optional records and UNITS record */
   while (recn < 16) {
      
      if ( read_record_hdr(fob, &rtype, &rlen) )
	 mexErrMsgTxt("gds_libdata :  failed to read record header.");
      
      switch(rtype) {
	
         case UNITS:
	    if ( read_real8(fob, &uunit) )
	       mexErrMsgTxt("gds_libdata :  failed to read UUNIT.");
	    if ( read_real8(fob, &dbunit) )
	       mexErrMsgTxt("gds_libdata :  failed to read DBUNIT.");
	    struct_set_float(plhs[0], 4, dbunit / uunit); /* actual user unit */
	    struct_set_float(plhs[0], 5, dbunit);
	    return;  /* last record in header */

         case REFLIBS:
	    nrl = rlen / 44;
	    ca = mxCreateCellMatrix(1,nrl);
	    for (k=0; k<nrl; k++) {
	       if ( read_string(fob, name, 44) )
		  mexErrMsgTxt("gds_libdata :  failed to read reference library name.");
	       mxSetCell(ca, k, mxCreateString(name));
	    }
	    mxSetFieldByNumber(plhs[0], 0, 6, ca);
	    break;

         case FONTS:
	    nfont = rlen / 44;
	    ca = mxCreateCellMatrix(1,nfont);
	    for (k=0; k<nfont; k++) {
	       if ( read_string(fob, name, 44) )
		  mexErrMsgTxt("gds_libdata :  failed to read font name.");
	       mxSetCell(ca, k, mxCreateString(name));
	    }
	    mxSetFieldByNumber(plhs[0], 0, 7, ca);
	    break;

         case ATTRTABLE:
 	    mexPrintf("\n>>> Ignoring ATTRTABLE record (%d data bytes)\n", rlen);
	    read_ignore(fob, rlen);
	    break;

         case GENERATIONS:
	    if ( read_word(fob, &word) )
	       mexErrMsgTxt("gds_libdata :  failed to read GENERATIONS.");
	    struct_set_word(plhs[0], 8, &word, 1);
	    break;

         case FORMAT:
 	    mexPrintf("\n>>> Ignoring FORMAT record (%d data bytes)\n", rlen);
	    read_ignore(fob, rlen);
	    break;

         case MASK:
 	    mexPrintf("\n>>> Ignoring MASK record (%d data bytes)\n", rlen);
	    read_ignore(fob, rlen);
	    break;

         case ENDMASKS:
 	    mexPrintf("\n>>> Ignoring ENDMASKS record (%d data bytes)\n", rlen);
	    read_ignore(fob, rlen);
	    break;

         default:
 	    mexPrintf("\n>>> Ignoring record type 0x%x in header (%d data bytes)\n", 
		      rtype, rlen);
	    read_ignore(fob, rlen);
      }

      recn += 1;
   }
   
   mexErrMsgTxt("gds_libdata :  fatal error - could not find UNITS record.");
}

/*-----------------------------------------------------------------*/
