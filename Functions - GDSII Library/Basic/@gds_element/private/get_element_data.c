/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * retrieves element properties from the internal data structure
 * 
 * value = get_element_data(internal, property);
 *
 * Input:
 * internal :  an array containing the internal element data. 
 * property :  a string with a property name
 * 
 * Output:
 * value :  the value of the property 
 */

#include <stdio.h>
#include <string.h>
#include "mex.h"

#include "mexfuncs.h"
#include "gdstypes.h"

#define PS_LEN  16
#define ERR_LEN 64


/*-- local function prototypes ------------------------------------*/

static mxArray* get_elflags(element_t *pe);
static mxArray* get_plex(element_t *pe);
static mxArray* get_layer(element_t *pe);
static mxArray* get_dtype(element_t *pe);
static mxArray* get_ptype(element_t *pe);
static mxArray* get_width(element_t *pe);
static mxArray* get_ext(element_t *pe);
static mxArray* get_font(element_t *pe);
static mxArray* get_verj(element_t *pe);
static mxArray* get_horj(element_t *pe);
static mxArray* get_strans(element_t *pe);
static mxArray* get_sname(element_t *pe);
static mxArray* get_adim(element_t *pe);

/* include hash function */
#include "get_prop_hash.h"

/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   struct keyword *pk;   /* pointer to keyword structure */
   element_t *pe;        /* pointer to element */
   char pstr[PS_LEN];    /* property name string */
   char errmsg[ERR_LEN];


   if (nrhs != 2)
      mexErrMsgTxt("get_element_data :  must have exactly two arguments.");

   /* get pointer to element */
   pe = (element_t *)mxGetData(prhs[0]);

   /* get property string */
   mxGetString(prhs[1], pstr, PS_LEN);

   /* decode property argument using the hash function in prop_hash.h */
   pk = (struct keyword *)in_word_set(pstr, strlen(pstr));
   if (pk == NULL) {
      sprintf(errmsg, "get_element_data :  unknown element property -> %s", pstr); 
      mexErrMsgTxt(errmsg);
   }

   plhs[0] = (*pk->get_prop_func)(pe); 
}


/*=================================================================*/

static mxArray* 
get_elflags(element_t *pe)
{
   int i;
   char efstr[3];

   if (pe->has & HAS_ELFLAGS) {
      i=0;
      if (pe->elflags & (1<<14)) {
	 efstr[i] = 'E';
	 i++;
      }
      if (pe->elflags & (1<<15)) {
	 efstr[i] = 'T';
	 i++;
      }
      efstr[i] = '\0';
      return mxCreateString(efstr);
   }
   else
      return empty_matrix();
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_plex(element_t *pe)
{
   int32_t plex;

   if (pe->has & HAS_PLEX) {
      plex = pe->plex;
      if ( plex & (1<<23) ) {
         plex = plex & ~(1<<23);
	 plex = -plex;
      }
      return mxCreateDoubleScalar((double)plex);
   }	 
   else
      return empty_matrix();
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_layer(element_t *pe)
{
   if (pe->kind == GDS_SREF || pe->kind == GDS_AREF)
      mexErrMsgTxt("get_element_data :  element as no layer property");
   else
      return mxCreateDoubleScalar((double)pe->layer);

   return NULL; /* make compiler happy */
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_dtype(element_t *pe)
{
   if (pe->kind == GDS_SREF || pe->kind == GDS_AREF)
      mexErrMsgTxt("get_element_data :  element as no [data|text|box|node] type property");
   else
      return mxCreateDoubleScalar((double)pe->dtype);

   return NULL; /* make compiler happy */
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_ptype(element_t *pe)
{
   if (pe->has & HAS_PTYPE)
      return mxCreateDoubleScalar((double)pe->ptype);
   else
      return empty_matrix();
}


/*-----------------------------------------------------------------*/


static mxArray* 
get_width(element_t *pe)
{
   if (pe->has & HAS_WIDTH)
      return mxCreateDoubleScalar((double)pe->width);
   else
      return empty_matrix();
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_ext(element_t *pe)
{
   mxArray *pext;                            /* pointer to path extensions */
   const char *extfields[] = {"beg", "end"}; /* for path extensions */

   pext = mxCreateStructMatrix(1,1, 2, extfields);
   if ( pe->has & HAS_BGNEXTN )
      mxSetFieldByNumber(pext, 0, 0, mxCreateDoubleScalar((double)pe->bgnextn));
   else
      mxSetFieldByNumber(pext, 0, 0, empty_matrix());
   if ( pe->has & HAS_ENDEXTN )
      mxSetFieldByNumber(pext, 0, 1, mxCreateDoubleScalar((double)pe->endextn));
   else
      mxSetFieldByNumber(pext, 0, 1, empty_matrix());
   return pext;
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_font(element_t *pe)
{
   if (pe->has & HAS_PRESTN)
      return mxCreateDoubleScalar((double)((pe->present & (3<<4)) >> 4));
   else
      return empty_matrix();
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_verj(element_t *pe)
{
   if (pe->has & HAS_PRESTN)
      return mxCreateDoubleScalar((double)((pe->present & (3<<2)) >> 2));
   else
      return empty_matrix();
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_horj(element_t *pe)
{
   if (pe->has & HAS_PRESTN)
      return mxCreateDoubleScalar((double)(pe->present & 3));
   else
      return empty_matrix();
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_strans(element_t *pe)
{
   mxArray *str;         /* pointer to strans */
   const char *stfields[] = {"reflect","absmag","absang","mag","angle"};

   if (pe->has & HAS_STRANS ) {
      str = mxCreateStructMatrix(1,1, 5, stfields);
      struct_set_bool(str, 0, pe->strans.flags & (1 << 15));
      struct_set_bool(str, 1, pe->strans.flags & (1 << 2));
      struct_set_bool(str, 2, pe->strans.flags & (1 << 1));
      if ( pe->has & HAS_MAG )
	 struct_set_float(str, 3, pe->strans.mag);
      if ( pe->has & HAS_ANGLE )
	 struct_set_float(str, 4, pe->strans.angle);
   }
   else
      str = empty_matrix();

   return str;
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_sname(element_t *pe)
{
   if (pe->kind == GDS_SREF || pe->kind == GDS_AREF)
      return mxCreateString(pe->sname);
   else
      mexErrMsgTxt("get_element_data :  element as no sname property");

   return NULL; /* make compiler happy */
}


/*-----------------------------------------------------------------*/

static mxArray* 
get_adim(element_t *pe)
{
   mxArray *padim;                           /* pointer to adim struct array */
   const char *crfields[] = {"row", "col"};  /* for adim */

   padim = mxCreateStructMatrix(1,1, 2, crfields);
   struct_set_word(padim, 0, &pe->nrow, 1);
   struct_set_word(padim, 1, &pe->ncol, 1);

   return padim;
}

/*-----------------------------------------------------------------*/

