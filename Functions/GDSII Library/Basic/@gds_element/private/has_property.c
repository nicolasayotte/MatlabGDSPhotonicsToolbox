/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * returns logical 1 if the element has a specified optional property
 * 
 * value = has_property(internal, property);
 *
 * Input:
 * internal :  an array containing the internal element data. 
 * property :  a string with a property name
 * 
 * Output:
 * value :  true if the element has the property, 0 otherwise
 */

#include <stdio.h>
#include <string.h>
#include "mex.h"

#include "gdstypes.h"
#include "has_hash.h"

#define PS_LEN   16
#define ERR_LEN  64


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   struct keyword *pk;   /* pointer to keyword structure */
   element_t *pe;        /* pointer to element */
   char pstr[PS_LEN];
   char errmsg[ERR_LEN];

   if (nrhs != 2)
      mexErrMsgTxt("has_property :  must have two arguments.");

   /* get pointer to element */
   pe = (element_t *)mxGetData(prhs[0]);

   /* get property string */
   mxGetString(prhs[1], pstr, PS_LEN);

   /* decode property argument using the hash function in prop_hash.h */
   pk = (struct keyword *)in_word_set(pstr, strlen(pstr));
   if (pk == NULL) {
      sprintf(errmsg, "has_property :  not a known optional property: %s.", pstr);
      mexErrMsgTxt(errmsg);
   }

   if (pe->has & pk->flag_bit)
      plhs[0] = mxCreateLogicalScalar(1);
   else
      plhs[0] = mxCreateLogicalScalar(0);
}

/*-----------------------------------------------------------------*/
