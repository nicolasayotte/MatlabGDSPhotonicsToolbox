/* 
 * Low-level IO functions that support the MEX interface
 * for reading and writing GDS II libraries.
 *
 * Copyright (C) 2012, 2013 Ulf Griesmann
 *
 *
 * Ulf Griesmann, December 2012
 */

#ifndef _GDSIO
#define _GDSIO

#include <stdio.h>
#include <stdint.h>
#include "gdstypes.h"


/* error codes */
typedef enum {A_OK = 0,
	      READ_OPEN_CLOSE, READ_REC_HEADER, READ_REC_TYPE,
	      READ_REC_DATA, READ_NO_UNITS, READ_FLOAT, READ_INT, 
	      READ_WORD, READ_CHAR,
	      WRITE_OPEN_CLOSE, WRITE_REC_HEADER, WRITE_FLOAT, 
	      WRITE_INT, WRITE_WORD, WRITE_CHAR} err_id;


/* ------------------------------------------------------------------
 *  Function prototypes
 */

/*
 * return the current date and time
 */
void now(date_t dv);

/* 
 * read a GDS II record header. The function returns the number
 * of data bytes in the record that remain to be read. 
 */
err_id read_record_hdr(FILE *fob, uint16_t *rtype, uint16_t *rlen); 

/* 
 * write a GDS II record header. The number of data bytes in the record
 * must be in rh.rlen (not including the record header). 
 */
err_id write_record_hdr(FILE *fob, uint16_t rtype, uint16_t rlen); 

/*
 * read n 16-bit words from a GDS II file
 */
err_id read_word_n(FILE *fob, uint16_t *data, int n); 

/*
 * write n 16-bit words to a GDS II file
 * NOTE: the byte order in data is not preserved !
 */
err_id write_word_n(FILE *fob, uint16_t *data, int n); 

/*
 * read a 16-bit word from a GDS II file
 */
err_id read_word(FILE *fob, uint16_t *data); 

/*
 * write a 16-bit word to a GDS II file
 * NOTE: the byte order in data is not preserved !
 */
err_id write_word(FILE *fob, uint16_t data); 

/*
 * read a 32-bit integer from a GDS II file
 */
err_id read_int(FILE *fob, int32_t *data); 

/*
 * write a 32-bit integer to a GDS II file
 * NOTE: the byte order in data is not preserved !
 */
err_id write_int(FILE *fob, int32_t data); 

/*
 * read n 32-bit integers from a GDS II file
 */
err_id read_int_n(FILE *fob, int32_t *data, int n); 

/*
 * write n 32-bit integers to a GDS II file
 * NOTE: the byte order in data is not preserved !
 */
err_id write_int_n(FILE *fob, int32_t *data, int n); 

/*
 * read a character string from a GDS II file
 */
err_id read_string(FILE *fob, char *str, int nchar); 

/*
 * write a character string to a GDS II file
 */
err_id write_string(FILE *fob, char *str, int nchar); 

/* 
 * read an excess-64 encoded 8-byte floating point number 
 */
err_id read_real8(FILE *fob, double *rnum); 

/* 
 * write an excess-64 encoded 8-byte floating point number 
 */
err_id write_real8(FILE *fob, double rnum); 

/*
 * read and discard a specified number of bytes
 */
err_id read_ignore(FILE *fob, int numb);

/*-----------------------------------------------------------------*/

#endif /* _GDSIO */

