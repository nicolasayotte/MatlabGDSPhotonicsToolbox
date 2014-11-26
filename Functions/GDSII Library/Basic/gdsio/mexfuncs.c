/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Auxiliary functions to simplify using the MEX interface.
 */

#include <stdio.h>
#include <stdint.h>
#include "mexfuncs.h"


/*-----------------------------------------------------------------*/

/*
 * retrieves the pointer to a structure field. Returns 1 on success or
 * 0 when the field does not exist or is empty.
 */
int
get_field_ptr(mxArray *structure, char *fieldname, mxArray **pfieldp)
{
   mxArray *field;

   field = mxGetField(structure, 0, fieldname);
   *pfieldp = field;

   if (field == NULL)
      return 0;

   if ( mxIsEmpty(field) )
      return 0;

   return 1;
}

/*-----------------------------------------------------------------*/

/*
 * retrieve a FILE * stored in an mxArray object
 */
FILE *
get_file_ptr(mxArray *fptr)
{
   FILE **pfp;
   
   pfp = (FILE **)mxGetData(fptr);
   return *pfp;
}


/*-----------------------------------------------------------------*/

/*
 * copy a word variable or word array to a structure array
 * saptr :     pointer to structure array
 * fieldnum :  field number
 * word :      array of words to be stored
 * n :         number of words
 */
void
struct_set_word(mxArray *saptr, int fieldnum, uint16_t *word, int n)
{
   mxArray *mptr;  /* pointer to matrix object */
   double *dptr;   /* pointer to matrix data */
   int k;

   mptr = mxCreateDoubleMatrix(1, n, mxREAL);
   dptr  = mxGetData(mptr);
   for (k=0; k<n; k++)
      dptr[k] = (double)word[k];
   mxSetFieldByNumber(saptr, 0, fieldnum, mptr);
}


/*-----------------------------------------------------------------*/

/*
 * copy a string variable to a structure array
 * saptr :     pointer to structure array
 * fieldnum :  field number
 * str :       character string
 */
void
struct_set_string(mxArray *saptr, int fieldnum, char *str)
{
   mxSetFieldByNumber(saptr, 0, fieldnum, mxCreateString(str));
}


/*-----------------------------------------------------------------*/

/*
 * copy a float variable to a structure array
 * saptr :     pointer to structure array
 * fieldnum :  field number
 * fnum :      double number
 */
void
struct_set_float(mxArray *saptr, int fieldnum, double fnum)
{
   mxArray *mptr;  /* pointer to matrix object */
   double *dptr;   /* pointer to matrix data */

   mptr = mxCreateDoubleMatrix(1, 1, mxREAL);
   dptr  = mxGetData(mptr);
   *dptr = fnum;
   mxSetFieldByNumber(saptr, 0, fieldnum, mptr);
}


/*-----------------------------------------------------------------*/

/* 
 * set a logical structure variable
 */
void
struct_set_bool(mxArray *saptr, int fieldnum, int lval)
{
   mxArray *mptr;  /* pointer to matrix object */

   if (lval)
      mptr = mxCreateLogicalScalar(1);
   else
      mptr = mxCreateLogicalScalar(0);      
   mxSetFieldByNumber(saptr, 0, fieldnum, mptr);
}


/*-----------------------------------------------------------------*/
      
mxArray *
empty_matrix(void)
{
   mxArray *pa;
   
   pa = mxCreateDoubleMatrix(0,0,mxREAL);
   mxSetData(pa, NULL);
   
   return pa;
}

/*-----------------------------------------------------------------*/


   
