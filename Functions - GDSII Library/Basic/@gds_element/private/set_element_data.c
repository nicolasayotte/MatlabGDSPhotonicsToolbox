/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * stores element properties in the internal data structure
 * 
 * internal = set_element_data(internal, varargin);
 *
 * Input:
 * internal :  an array containing the internal element data. 
 * varargin :  a cell array of property/value pairs
 * 
 * Output:
 * internal :  the modified internal data structure 
 *
 * NOTE: when an optional property is set to its default value,
 * the HAS_PROPERTY flag is cleared.
 */

#include <stdio.h>
#include <string.h>
#include "mex.h"

#include "mexfuncs.h"
#include "gdstypes.h"
#include "eldata.h"

#define PS_LEN  16
#define ERR_LEN 64
#define SN_LEN  34


/*- local function prototypes -------------------------------------*/

static void set_elflags(element_t *pe, mxArray *val);
static void set_plex(element_t *pe, mxArray *val);
static void set_layer(element_t *pe, mxArray *val);
static void set_dtype(element_t *pe, mxArray *val);
static void set_ttype(element_t *pe, mxArray *val);
static void set_ntype(element_t *pe, mxArray *val);
static void set_btype(element_t *pe, mxArray *val);
static void set_ptype(element_t *pe, mxArray *val);
static void set_width(element_t *pe, mxArray *val);
static void set_ext(element_t *pe, mxArray *val);
static void set_font(element_t *pe, mxArray *val);
static void set_verj(element_t *pe, mxArray *val);
static void set_horj(element_t *pe, mxArray *val);
static void set_strans(element_t *pe, mxArray *val);
static void set_sname(element_t *pe, mxArray *val);
static void set_adim(element_t *pe, mxArray *val);

/* include hash function */
#include "set_prop_hash.h"

/*-----------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   struct keyword *pk;   /* pointer to keyword structure */
   mxArray *pp, *pv;     /* pointer to property and value */
   element_t *pe;        /* pointer to element */
   element_t el;
   int nc, idx;
   char pstr[PS_LEN];    /* property name string */
   char errmsg[ERR_LEN];


   if (nrhs != 2)
      mexErrMsgTxt("set_element_data :  must have exactly two arguments.");

   /* get pointer to input element and make local copy */
   pe = (element_t *)mxGetData(prhs[0]);
   memcpy(&el, pe, sizeof(element_t));

   /* check 2nd argument */
   if ( !mxIsCell(prhs[1]) )
      mexErrMsgTxt("set_element_data :  2nd argument must be cell array.");

   /* get number of cells */
   nc = mxGetNumberOfElements(prhs[1]);
   if (nc % 2)
      mexErrMsgTxt("set_element_data :  2nd argument must consist of propery/value pairs.");

   /* store property/value pairs one-by-one */
   for (idx = 0; idx<nc; idx+=2) {
     
      /* get next property value pair */
      pp = mxGetCell(prhs[1], idx);
      pv = mxGetCell(prhs[1], idx+1);

      /* decode property argument using the hash function in prop_hash.h */
      if ( !mxIsChar(pp) )
	 mexErrMsgTxt("set_element_data :  properties must be character strings.");
      mxGetString(pp, pstr, PS_LEN);
      pk = (struct keyword *)in_word_set(pstr, strlen(pstr));
      if (pk == NULL) {
	 sprintf(errmsg, "set_element_data :  unknown element property -> %s", pstr); 
	 mexErrMsgTxt(errmsg);      
      }

      /* store the property value in internal structure */
      if ( !mxIsEmpty(pv) )
	 (*pk->set_prop_func)(&el, pv);
   }

   /* return element to caller */
   plhs[0] = copy_element_to_array(&el);
}

/*=================================================================*/


static void 
set_elflags(element_t *pe, mxArray *val)
{
   int k = 0;
   char efstr[3];

   mxGetString(val, efstr, 3);
   while (efstr[k]!='\0' && k<3) {
      if (efstr[k] == 'T') {
	 pe->elflags |= (1<<15);
	 pe->has |= HAS_ELFLAGS;
      }
      if (efstr[k] == 'E') {
	 pe->elflags |= (1<<14);
	 pe->has |= HAS_ELFLAGS;
      }
      else
	 mexErrMsgTxt("set_element_data :  elflags must be T or E.");
         k++;
      }
      if (!k)
	 pe->has &= ~HAS_ELFLAGS;
}


/*-----------------------------------------------------------------*/

static void 
set_plex(element_t *pe, mxArray *val)
{
   int32_t plex;
   double *pd;     /* pointer to data */

   pd = (double *)mxGetData(val);
   plex = (int32_t)pd[0];
   if (plex > 16777216 || plex < -16777216)
      mexErrMsgTxt("set_element_data :  plex must be < 2^24.");
   if (plex < 0) {
      plex = -plex;
      plex |= (1<<23);
   }
   pe->plex = plex;
   if (!plex)
      pe->has |= HAS_PLEX;
   else
      pe->has &= ~HAS_PLEX; 
}


/*-----------------------------------------------------------------*/

static void 
set_layer(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */

   if ( (pe->kind == GDS_SREF) || (pe->kind == GDS_AREF) )
      mexErrMsgTxt("set_element_data :  reference element has no layer property.");
   pd = (double *)mxGetData(val);
   pe->layer = (uint16_t)pd[0];
}


/*-----------------------------------------------------------------*/

static void 
set_dtype(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */

   if ( (pe->kind != GDS_BOUNDARY) && (pe->kind != GDS_PATH) )
      mexErrMsgTxt("set_element_data :  element has no dtype property.");
   pd = (double *)mxGetData(val);
   pe->dtype = (uint16_t)pd[0];
}


/*-----------------------------------------------------------------*/

static void 
set_ttype(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */

   if ( pe->kind != GDS_TEXT )
      mexErrMsgTxt("set_element_data :  element has no ttype property.");
   pd = (double *)mxGetData(val);
   pe->dtype = (uint16_t)pd[0];
}


/*-----------------------------------------------------------------*/

static void 
set_ntype(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */

   if ( pe->kind != GDS_NODE )
      mexErrMsgTxt("set_element_data :  element has no ntype property.");
   pd = (double *)mxGetData(val);
   pe->dtype = (uint16_t)pd[0];
}


/*-----------------------------------------------------------------*/

static void 
set_btype(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */

   if ( pe->kind != GDS_BOX )
      mexErrMsgTxt("set_element_data :  element has no btype property.");
   pd = (double *)mxGetData(val);
   pe->dtype = (uint16_t)pd[0];
}


/*-----------------------------------------------------------------*/

static void 
set_ptype(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */

   if ( (pe->kind != GDS_PATH) && (pe->kind != GDS_TEXT) )
      mexErrMsgTxt("set_element_data :  element has no ptype property.");
   pd = (double *)mxGetData(val);
   pe->ptype = (int16_t)pd[0];
   if (pe->ptype)
      pe->has |= HAS_PTYPE;
   else
      pe->has &= ~HAS_PTYPE;
}


/*-----------------------------------------------------------------*/

static void 
set_width(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */

   if ( (pe->kind != GDS_PATH) && (pe->kind != GDS_TEXT) )
      mexErrMsgTxt("set_element_data :  element has no width property.");
   pd = (double *)mxGetData(val);
   pe->width = (float)pd[0];
   if ((int)pe->width)
      pe->has |= HAS_WIDTH;
   else
      pe->has &= ~HAS_WIDTH;
}


/*-----------------------------------------------------------------*/

static void 
set_ext(element_t *pe, mxArray *val)
{
   mxArray *pa;    /* pointer to array */
   double *pd;     /* pointer to data */

   if ( pe->kind != GDS_PATH )
      mexErrMsgTxt("set_element_data :  element has no path extension properties.");
   if ( get_field_ptr(val, "beg", &pa) ) {
      pd = (double *)mxGetData(pa);
      pe->bgnextn = (float)pd[0];
      if ( (int)pe->bgnextn )
	 pe->has |= HAS_BGNEXTN;
      else
	 pe->has &= ~HAS_BGNEXTN;
   }
   else
      mexErrMsgTxt("set_element_data :  beg field missing in ext structure.");
   if ( get_field_ptr(val, "end", &pa) ) {
      pd = (double *)mxGetData(pa);
      pe->endextn = (float)pd[0];
      if ( (int)pe->endextn )
	 pe->has |= HAS_ENDEXTN;
      else
	 pe->has &= ~HAS_ENDEXTN;
   }
   else
      mexErrMsgTxt("set_element_data :  end field missing in ext structure.");
}


/*-----------------------------------------------------------------*/

static void 
set_font(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */
   uint16_t pval;

   if ( pe->kind != GDS_TEXT )
      mexErrMsgTxt("set_element_data :  element has no presentation (font) property.");
   pd = (double *)mxGetData(val);
   pval = (uint16_t)pd[0];
   pe->present |= pval << 4;
   if (pe->present)
      pe->has |= HAS_PRESTN;
   else
      pe->has &= ~HAS_PRESTN;
}


/*-----------------------------------------------------------------*/

static void 
set_verj(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */
   uint16_t pval;

   if ( pe->kind != GDS_TEXT )
      mexErrMsgTxt("set_element_data :  element has no presentation (verj) property.");
   pd = (double *)mxGetData(val);
   pval = (uint16_t)pd[0];
   pe->present |= pval << 2;
   if (pe->present)
      pe->has |= HAS_PRESTN;
   else
      pe->has &= ~HAS_PRESTN;
}


/*-----------------------------------------------------------------*/

static void 
set_horj(element_t *pe, mxArray *val)
{
   double *pd;     /* pointer to data */
   uint16_t pval;

   if ( pe->kind != GDS_TEXT )
      mexErrMsgTxt("set_element_data :  element has no presentation (horj) property.");
   pd = (double *)mxGetData(val);
   pval = (uint16_t)pd[0];
   pe->present |= pval;
   if (pe->present)
      pe->has |= HAS_PRESTN;
   else
      pe->has &= ~HAS_PRESTN;
}


/*-----------------------------------------------------------------*/

static void 
set_strans(element_t *pe, mxArray *val)
{
   mxArray *pa;    /* pointer to array */
   double *pd;     /* pointer to data */

   if (pe->kind != GDS_SREF && pe->kind != GDS_AREF && pe->kind != GDS_TEXT)
      mexErrMsgTxt("set_element_data :  element has no strans property.");

   if ( get_field_ptr(val, "reflect", &pa) ) {
      pd = (double *)mxGetData(pa);
      if ( (mxLogical)pd[0] ) {
	 pe->strans.flags |= 1 << 15;
	 pe->has |= HAS_STRANS;
      }
      else {
	 pe->strans.flags &= ~(1 << 15);
	 if ( !pe->strans.flags && !(pe->has & HAS_MAG) && !(pe->has & HAS_ANGLE))
	    pe->has &= ~HAS_STRANS;
      }
   }

   if ( get_field_ptr(val, "absmag", &pa) ) {
      pd = (double *)mxGetData(pa);
      if ( (mxLogical)pd[0] ) {
	 pe->strans.flags |= 1 << 2;
	 pe->has |= HAS_STRANS;
      }
      else {
	 pe->strans.flags &= ~(1 << 2);
	 if ( !pe->strans.flags && !(pe->has & HAS_MAG) && !(pe->has & HAS_ANGLE))
	    pe->has &= ~HAS_STRANS;
      }
   }

   if ( get_field_ptr(val, "absang", &pa) ) {
      pd = (double *)mxGetData(pa);
      if ( (mxLogical)pd[0] ) {
	 pe->strans.flags |= 1 << 1;
	 pe->has |= HAS_STRANS;
      }
      else {
	 pe->strans.flags &= ~(1 << 1);
	 if ( !pe->strans.flags && !(pe->has & HAS_MAG) && !(pe->has & HAS_ANGLE))
	    pe->has &= ~HAS_STRANS;
      }
   }

   if ( get_field_ptr(val, "mag", &pa) ) {
      pd = (double *)mxGetData(pa);
      pe->strans.mag = pd[0];
      if (pe->strans.mag != 1.0) {
	 pe->has |= HAS_MAG;
	 pe->has |= HAS_STRANS;
      }
      else {
	 pe->has &= ~HAS_MAG;
	 if ( !pe->strans.flags && !(pe->has & HAS_MAG) && !(pe->has & HAS_ANGLE))
	    pe->has &= ~HAS_STRANS;
      }
   }

   if ( get_field_ptr(val, "angle", &pa) ) {
      pd = (double *)mxGetData(pa);
      pe->strans.angle = pd[0];
      if (pe->strans.angle != 0.0) {
	 pe->has |= HAS_ANGLE;
	 pe->has |= HAS_STRANS;
      }
      else {
	 pe->has &= ~HAS_ANGLE;
	 if ( !pe->strans.flags && !(pe->has & HAS_MAG) && !(pe->has & HAS_ANGLE))
	    pe->has &= ~HAS_STRANS;
      }
   }

      /* check if HAS_STRANS can be cleared */
   if ( !pe->strans.flags && !(pe->has & HAS_MAG) && !(pe->has & HAS_ANGLE) )
      pe->has &= ~HAS_STRANS;
}


/*-----------------------------------------------------------------*/

static void 
set_sname(element_t *pe, mxArray *val)
{
   if (pe->kind != GDS_SREF && pe->kind != GDS_AREF)
      mexErrMsgTxt("set_element_data :  element has no sname property.");
   mxGetString(val, pe->sname, SN_LEN);
}


/*-----------------------------------------------------------------*/

static void 
set_adim(element_t *pe, mxArray *val)
{
   mxArray *pa;    /* pointer to array */
   double *pd;     /* pointer to data */
   
   if ( pe->kind != GDS_AREF )
      mexErrMsgTxt("set_element_data :  element has no adim property.");
   if ( get_field_ptr(val, "col", &pa) ) {
      pd = (double *)mxGetData(pa);
      pe->ncol = (uint16_t)pd[0];
   }
   else
      mexErrMsgTxt("set_element_data :  col field missing in adim structure.");
   
   if ( get_field_ptr(val, "row", &pa) ) {
      pd = (double *)mxGetData(pa);
      pe->nrow = (uint16_t)pd[0];
   }
   else
      mexErrMsgTxt("set_element_data :  row field missing in adim structure.");
}


/*-----------------------------------------------------------------*/
