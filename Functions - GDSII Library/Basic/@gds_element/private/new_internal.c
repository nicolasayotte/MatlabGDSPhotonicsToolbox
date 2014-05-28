/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * Create a new internal element data structure.
 * 
 * internal = new_internal(etype);
 *
 * Input:
 * internal :  an array containing the internal element data. 
 * etype :  a string with the element type 
 */

#include <stdio.h>
#include <string.h>
#include "mex.h"

#include "gdstypes.h"
#include "eldata.h"
#include "el_hash.h"

#define ET_LEN  16
#define ERR_LEN 64


/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   struct keyword *pk; /* pointer to keyword structure */
   element_t el;       /* a new element */
   char str[ET_LEN];   /* element type string */
   char errmsg[ERR_LEN];

   /* check argument number */
   if (nrhs != 1)
      mexErrMsgTxt("new_internal :  must have exactly one argument.");

   /* initialize element */
   memset(&el, 0, sizeof(element_t));

   /* get type string */
   mxGetString(prhs[0], str, ET_LEN);

   /* decode type argument using the hash function in el_hash.h */
   pk = (struct keyword *)in_word_set(str, strlen(str));
   if (pk == NULL) {
      sprintf(errmsg, "new_internal :  unknown element type -> %s", str); 
      mexErrMsgTxt(errmsg);
   }

   el.kind = pk->kind; /* set element kind */
   el.layer = 1;       /* default layer; not used in sref and aref */
   
   /*
    * store element in array
    */
   plhs[0] = copy_element_to_array(&el);
}

/*-----------------------------------------------------------------*/
