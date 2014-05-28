/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * Returns a string with the element type.
 * 
 * etype = get_etype(internal);
 *
 * Input:
 * internal :  an array containing the internal element data. 
 *
 * Output:
 * etype :  a string with the element type 
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
      mexErrMsgTxt("get_etype :  must have exactly one argument.");

   /* get argument */
   pe = (element_t *)mxGetData(prhs[0]);

   /* create output */
   switch (pe->kind) {
      case GDS_BOUNDARY:
	 plhs[0] = mxCreateString("boundary");
	 break;
      case GDS_PATH:
	 plhs[0] = mxCreateString("path");
	 break;
      case GDS_BOX:
	 plhs[0] = mxCreateString("box");
	 break;
      case GDS_NODE:
	 plhs[0] = mxCreateString("node");
	 break;
      case GDS_TEXT:
	 plhs[0] = mxCreateString("text");
	 break;
      case GDS_SREF:
	 plhs[0] = mxCreateString("sref");
	 break;
      case GDS_AREF:
	 plhs[0] = mxCreateString("aref");
	 break;
      default:
	 mexErrMsgTxt("get_etype :  unknown element type.");
   }  
}

/*-----------------------------------------------------------------*/
