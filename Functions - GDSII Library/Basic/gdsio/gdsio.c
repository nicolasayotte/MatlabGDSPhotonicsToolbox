/* Fast GDS II low-level IO library
 * Copyright (C) 2012 Ulf Griesmann
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "gdsio.h"

/* GNU C has inline */
#if defined __GNUC__
   #define INLINE __inline__
#else
   #define INLINE
#endif


/*-- Utility functions --------------------------------------------*/

#include "byteswap.h"
#if defined __GNUC__
#include "convert_float_gcc.h"
#else
#include "convert_float_generic.h"
#endif


/*-----------------------------------------------------------------*/

void 
now(date_t dv)
{
   time_t cut;      /* current time */
   struct tm *pts;  /* time structure */


   /* get time and convert */   
   cut = time(NULL);
   pts = localtime(&cut);

   /* fill date vector */
   if (pts == NULL) {
      memset(dv, '\0', sizeof(dv));
   }
   else {
      dv[0] = pts->tm_year + 1900;
      dv[1] = pts->tm_mon + 1;
      dv[2] = pts->tm_mday;
      dv[3] = pts->tm_hour;
      dv[4] = pts->tm_min;
      dv[5] = pts->tm_sec;
   }
}


/*--------------------------------------------------------------
 * Read a record header consisting of record length and record
 * type. The number of data bytes remaining in the record is returned.
 */
err_id
read_record_hdr(FILE* fob, uint16_t *rtype, uint16_t *rlen) 
{
   uint16_t hdr[2];
   int nr;

   nr = fread(hdr, sizeof(uint16_t), 2, fob);
   if (nr != 2) return READ_REC_HEADER;
   byte_reverse_n(hdr, 2);

   *rtype = hdr[1];
   *rlen  = hdr[0] - 2*sizeof(uint16_t);

   return A_OK;
}

/*--------------------------------------------------------------*/


/*
 * write a GDS II record header
 */
err_id 
write_record_hdr(FILE* fob, uint16_t rtype, uint16_t rlen)
{
   uint16_t hdr[2];
   int nw;

   hdr[0] = rlen + 2*sizeof(uint16_t);
   hdr[1] = rtype;
   byte_reverse_n(hdr, 2);

   nw = fwrite(hdr, sizeof(uint16_t), 2, fob);
   if (nw != 2) return WRITE_REC_HEADER;

   return A_OK;
}

/*-----------------------------------------------------------------*/
 
err_id 
read_word_n(FILE *fob, uint16_t *data, int n)
{
   int nr;

   nr = fread(data, sizeof(uint16_t), n, fob);
   if (nr != n)
      return READ_WORD;

   byte_reverse_n(data, n);

   return A_OK;
}


/*-----------------------------------------------------------------*/
 
err_id 
write_word_n(FILE *fob, uint16_t *data, int n)
{
   int nw;

   byte_reverse_n(data, n);
   nw = fwrite(data, sizeof(uint16_t), n, fob);
   if (nw != n)
      return WRITE_WORD;

   return A_OK;
} 


/*-----------------------------------------------------------------*/


err_id 
read_word(FILE *fob, uint16_t *data)
{
   int nr;

   nr = fread(data, sizeof(uint16_t), 1, fob);
   if (nr != 1)
      return READ_WORD;

   byte_reverse(data);

   return A_OK;
}


/*-----------------------------------------------------------------*/

err_id 
write_word(FILE *fob, uint16_t data)
{
   int nw;

   byte_reverse(&data);
   nw = fwrite(&data, sizeof(uint16_t), 1, fob);
   if (nw != 1)
      return WRITE_WORD;

   return A_OK;
} 


/*-----------------------------------------------------------------*/

err_id 
read_int(FILE *fob, int32_t *data)
{
   int nr;

   nr = fread(data, sizeof(int32_t), 1, fob);
   if (nr != 1)
      return READ_INT;

   byte_reverse32(data);

   return A_OK;
}


/*-----------------------------------------------------------------*/
 
err_id 
write_int(FILE *fob, int32_t data)
{
   int nw;

   byte_reverse32(&data);
   nw = fwrite(&data, sizeof(int32_t), 1, fob);
   if (nw != 1)
      return WRITE_INT;

   return A_OK;
} 


/*-----------------------------------------------------------------*/

err_id 
read_int_n(FILE *fob, int32_t *data, int n)
{
   int nr;

   nr = fread(data, sizeof(int32_t), n, fob);
   if (nr != n)
      return READ_INT;

   byte_reverse32_n(data, n);

   return A_OK;
}


/*-----------------------------------------------------------------*/

err_id 
write_int_n(FILE *fob, int32_t *data, int n)
{
   int nw;

   byte_reverse32_n(data, n);
   nw = fwrite(data, sizeof(int32_t), n, fob);
   if (nw != n)
      return WRITE_INT;

   return A_OK;
} 
 

/*-----------------------------------------------------------------*/

err_id 
read_string(FILE *fob, char *str, int nchar)
{
   int nr;

   nr = fread(str, sizeof(char), nchar, fob);
   if (nr != nchar)
      return READ_CHAR;
   
   if (str[nchar] != '\0')
      str[nchar] = '\0';

   return A_OK;
}


/*-----------------------------------------------------------------*/
 
err_id 
write_string(FILE *fob, char *str, int nchar)
{
   int nw;

   nw = fwrite(str, sizeof(char), nchar, fob);
   if (nw != nchar)
      return WRITE_CHAR;

   return A_OK;
} 


/*--------------------------------------------------------------*/

err_id
read_ignore(FILE *fob, int numb)
{
   char *p;
   int nr;

   p = malloc(numb);
   nr = fread(p, sizeof(uint8_t), numb, fob);
   free(p);

   if (nr != numb)
      return READ_CHAR; 
   else
      return A_OK;
}


/*-----------------------------------------------------------------*/

err_id
read_real8(FILE *fob, double *rnum) 
{
   int nr;
   uint64_t e64num;

   /* read bytes */
   nr = fread(&e64num, sizeof(uint64_t), 1, fob);
   if (nr != 1)
      return READ_FLOAT;

   *rnum = excess64_to_ieee754(&e64num);

   return A_OK;
}


/*--------------------------------------------------------------*/

err_id
write_real8(FILE *fob, double rnum) 
{
   int nw;
   uint64_t e64num;

   ieee754_to_excess64(rnum, &e64num);
   nw = fwrite(&e64num, sizeof(uint64_t), 1, fob);
   if (nw != 1)
      return WRITE_FLOAT;

   return A_OK;
}

/*-----------------------------------------------------------------*/

