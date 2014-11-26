/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * Copy internal element data to and from mxArray objects
 */

#ifndef _ELDATA
#define _ELDATA

#include "mex.h"
#include "gdstypes.h"

#ifdef __GNUC__
   #define INLINE __inline__
#else
   #define INLINE
#endif


/*-----------------------------------------------------------------*/

static INLINE mxArray* 
copy_element_to_array(element_t *element)
{
   mxArray *pa;
   uint8_t *pd;

   pa = mxCreateNumericMatrix(1,sizeof(element_t), mxUINT8_CLASS, mxREAL);
   pd = (uint8_t *)mxGetData(pa);
   memcpy(pd, element, sizeof(element_t));

   return pa;
}

/*-----------------------------------------------------------------*/

#endif /* _ELDATA */
