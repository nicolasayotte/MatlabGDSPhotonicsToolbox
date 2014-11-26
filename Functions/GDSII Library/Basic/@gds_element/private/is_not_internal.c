/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * Checks if a property string belongs to those that are
 * not stored in the internal data structure (xy, text, prop).
 * 
 * is = is_not_internal(property);
 *
 * Input:
 * property :  a string with a property name 
 *
 * Output:
 * is :  an mxLogical returning either true or false 
 */

#include <string.h>
#include "mex.h"

#include "notint_hash.h"

#define PS_LEN  32


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   char pstr[PS_LEN];

   /* check argument number */
   if (nrhs != 1)
      mexErrMsgTxt("is_not_internal :  must have exactly one argument.");

   /* get string argument */
   mxGetString(prhs[0], pstr, PS_LEN);

   /* check the string */
   if ( in_word_set(pstr, strlen(pstr)) )
      plhs[0] = mxCreateLogicalScalar(1);
   else
      plhs[0] = mxCreateLogicalScalar(0);
}

/*-----------------------------------------------------------------*/
