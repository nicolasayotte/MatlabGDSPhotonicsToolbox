/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012, Ulf Griesmann
 *
 * Description:
 * Auxiliary functions to simplify using the MEX interface.
 */

#ifndef _MEXFUNCS_H
#define _MEXFUNCS_H

#include <stdint.h>
#include <stdio.h>
#include "mex.h"


/*-----------------------------------------------------------------*/

/*
 * retrieves the pointer to a structure field. Returns 1 on success or
 * 0 when the field does not exist or is empty.
 */
int
get_field_ptr(mxArray *structure, char *fieldname, mxArray **pfieldp);


/*
 * retrieve a FILE * stored in an mxArray object
 */
FILE *
get_file_ptr(mxArray *fptr);


/*
 * copy a word variable or word array to a structure array
 * saptr :     pointer to structure array
 * fieldnum :  field number
 * word :      array of words to be stored
 * n :         number of words
 */
void
struct_set_word(mxArray *saptr, int fieldnum, uint16_t *word, int n);


/*
 * copy a string variable to a structure array
 * saptr :     pointer to structure array
 * fieldnum :  field number
 * str :       character string
 */
void
struct_set_string(mxArray *saptr, int fieldnum, char *str);


/*
 * copy a float variable to a structure array
 * saptr :     pointer to structure array
 * fieldnum :  field number
 * fnum :      double number
 */
void
struct_set_float(mxArray *saptr, int fieldnum, double fnum);


/* 
 * set a logical structure variable
 */
void
struct_set_bool(mxArray *saptr, int fieldnum, int lval);


/*
 * return an empty matrix
 */
mxArray *
empty_matrix(void);

#endif /* _MEXFUNCS_H */
