/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * Checks if an element is a reference element.
 * 
 * is = isref(internal);
 *
 * Input:
 * internal :  an array containing the internal element data. 
 *
 * Output:
 * is :  an mxLogical returning either true or false 
 */

#include <stdio.h>
#include "mex.h"

#include "gdstypes.h"


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   element_t *pe;         /* pointer to element data */

   /* check argument number */
   if (nrhs != 1)
      mexErrMsgTxt("isref :  must have exactly one argument.");

   /* get argument */
   pe = (element_t *)mxGetData(prhs[0]);

   /* create output */
   if (pe->kind == GDS_SREF || pe->kind == GDS_AREF)
      plhs[0] = mxCreateLogicalScalar(1);
   else
      plhs[0] = mxCreateLogicalScalar(0);
}

/*-----------------------------------------------------------------*/
