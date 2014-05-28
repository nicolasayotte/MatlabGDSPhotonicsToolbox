/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Opens a GDS II library file for reading or writing.
 * 
 * [gf,size] = gds_open(name, mode);
 *
 * Input:
 * name :  string with file name.
 * mode :  string specifying the open mode, either 'rb' or 'wb'. 
 *
 * Output:
 * gf :    a file handle (actually a FILE *, stored in a 4 byte 
 *         or 8 byte integer variable, depending on architecture).
 * size :  the file size in bytes; it is returned only when a file
 *         is opened for reading.
 * 
 * NOTE:
 * This function bypasses the Octave (MATLAB) file i/o functions. It is
 * directly based on the fread/fwrite function of the C standard library.
 */

#include <stdio.h>
#include "gdsio.h"
#include "mex.h"

#define FNAME_LEN   256
#define MODE_LEN    4


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   FILE *fob;                  /* file object pointer */
   FILE **pfob;                /* pointer to fob */
   double *pd;
   long int fsize;
   char fname[FNAME_LEN];      /* file name */
   char mode[MODE_LEN];        /* string with polygon operation */


   /* 
    * check argument number 
    */
   if (nrhs != 2)
      mexErrMsgTxt("expected 2 input arguments.");
   
   /* 
    * get file name argument 
    */
   if ( mxGetString(prhs[0], fname, FNAME_LEN) )
      mexErrMsgTxt("failed to access file name argument.");

   /* 
    * get mode argument 
    */
   if ( mxGetString(prhs[1], mode, MODE_LEN) )
      mexErrMsgTxt("failed to access mode argument.");
   if ( (mode[0] != 'r') && (mode[0] != 'w') )
      mexErrMsgTxt("mode must be either r or w.");

   /* 
    * open the file 
    */
   fob = fopen(fname, mode);
   if (fob == NULL) {
      mexPrintf("gds_open: file >> %s <<\n", fname);
      mexErrMsgTxt("could not open file.");
   }

   /* 
    * return the file pointer 
    */
   if ( sizeof(FILE *) == 4 ) { 
      plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
   }
   else if ( sizeof(FILE *) == 8 ) {
      plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
   }
   else
      mexErrMsgTxt("pointer size is neither 4 nor 8 bytes.");

   pfob  = (FILE **)mxGetData(plhs[0]);
   *pfob = fob;

   /* 
    * also return file size if opened for reading 
    */
   if (mode[0] == 'r') {
      if (fseek(fob, 0L, SEEK_END) < 0)
	 mexErrMsgTxt("fseek to end of file failed.");
      fsize = ftell(fob);
      if (fsize < 0)
	 mexErrMsgTxt("failed to obtain file position with ftell().");
      if (fseek(fob, 0L, SEEK_SET) < 0)
	 mexErrMsgTxt("fseek to beginning of file failed.");
      plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL);
      pd = mxGetData(plhs[1]);
      *pd = fsize;
   }
}

/*-----------------------------------------------------------------*/
