/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012- 2013, Ulf Griesmann
 *
 * Description:
 * Writes element data to a GDS II library file.
 *
 * gds_write_element(gf, data, uu_to_dbu, bcompound);
 *
 * Input
 * gf :    a file handle returned by gds_open
 * data :  a structure with element data
 * uu_to_dbu : conversion factor user units --> database units
 * bcompound : controls creation of compound elements.
 */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "mex.h"

#include "gdstypes.h"
#include "gdsio.h"
#include "mexfuncs.h"

#define VLEN         128
#define SLEN         40
#define TXTLEN       512
#define MAXVERTEXNUM 8191

#ifdef __GNUC__
   #define RESTRICT __restrict
   #define INLINE __inline__
#else
   #define RESTRICT
   #define INLINE
#endif


/*-- Data ---------------------------------------------------------*/

static int32_t xybuf[2*(MAXVERTEXNUM+1)];


/*-- Local Functions ----------------------------------------------*/

static void write_boundary(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_compound_boundary(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_path(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_compound_path(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_sref(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_compound_sref(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_aref(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_text(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_node(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_box(FILE *fob, mxArray *data, double uu_to_dbu); 
static void write_property(FILE *fob, mxArray *prop); 
static INLINE void scale_trans(double * RESTRICT data, int32_t * RESTRICT xy, int m, double sfact);


/*-----------------------------------------------------------------*/

void
mexFunction(int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[])
{
   FILE *fob;
   mxArray *internal;
   element_t *pe;
   double *pd;
   int compound;
   double uu_to_dbu;

   /* check argument number */
   if (nrhs != 4) {
      mexErrMsgTxt("gds_write_element :  4 input arguments expected.");
   }
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* get unit conversion factor user units --> database units */
   pd = (double *)mxGetData(prhs[2]);
   uu_to_dbu = pd[0];

   /* decide what to do */
   if ( !get_field_ptr((mxArray *)prhs[1], "internal", &internal) )
      mexErrMsgTxt("gds_write_element :  missing internal data field.");
   pe = (element_t *)mxGetData(internal);

   switch (pe->kind) {
     
      case GDS_BOUNDARY:
	 pd = (double *)mxGetData(prhs[3]); /* compound */
	 compound = (int)pd[0];
	 if ( compound )
	    write_compound_boundary(fob, (mxArray *)prhs[1], uu_to_dbu);
	 else
	    write_boundary(fob, (mxArray *)prhs[1], uu_to_dbu);
	 break;

      case GDS_PATH:
	 pd = (double *)mxGetData(prhs[3]); /* compound */
	 compound = (int)pd[0];
	 if ( compound )
	    write_compound_path(fob, (mxArray *)prhs[1], uu_to_dbu);
	 else
	    write_path(fob, (mxArray *)prhs[1], uu_to_dbu);
	 break;

      case GDS_SREF:
	 pd = (double *)mxGetData(prhs[3]); /* compound */
	 compound = (int)pd[0];
	 if ( compound )
	    write_compound_sref(fob, (mxArray *)prhs[1], uu_to_dbu);
	 else
	    write_sref(fob, (mxArray *)prhs[1], uu_to_dbu);
	 break;

      case GDS_AREF:
	 write_aref(fob, (mxArray *)prhs[1], uu_to_dbu);
	 break;

      case GDS_TEXT:
	 write_text(fob, (mxArray *)prhs[1], uu_to_dbu);
	 break;

      case GDS_NODE:
	 write_node(fob, (mxArray *)prhs[1], uu_to_dbu);
	 break;

      case GDS_BOX:
	 write_box(fob, (mxArray *)prhs[1], uu_to_dbu);
	 break;

      default:
	 mexErrMsgTxt("gds_write_element :  unknown element type.");
   }
}


/*-- Boundary -----------------------------------------------------*/

static void 
write_boundary(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *propfield, *caxy, *pa, *internal;
   double *pd;
   int m,n,nxy=0,kxy;
   element_t bnd;


   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (boundary) :  missing internal data field.");
   memcpy(&bnd, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* number of boundaries contained in compound element */
   if ( get_field_ptr(data, "xy", &caxy) ) {
      nxy = mxGetNumberOfElements(caxy);
   }
   else   
      mexErrMsgTxt("gds_write_element (boundary) :  missing or empty xy field.");

   /* 
    * now write out the individual boundary elements 
    */
   for (kxy=0; kxy<nxy; kxy++) {

      /* BOUNDARY */
      write_record_hdr(fob, BOUNDARY, 0);

      /* ELFLAGS */
      if ( bnd.has & HAS_ELFLAGS ) {
	 write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
	 write_word(fob, bnd.elflags);
      }

      /* PLEX */
      if ( bnd.has & HAS_PLEX ) {
	 write_record_hdr(fob, PLEX, sizeof(int32_t));
	 write_int(fob, bnd.plex);
      }

      /* LAYER */
      write_record_hdr(fob, LAYER, sizeof(uint16_t));
      write_word(fob, bnd.layer);

      /* DATATYPE */
      write_record_hdr(fob, DATATYPE, sizeof(uint16_t));
      write_word(fob, bnd.dtype);
   
      /* XY */
      pa = mxGetCell(caxy, kxy);
      m = mxGetM(pa);
      if (m > 8191)
	 mexErrMsgTxt("more than 8191 vertices in boundary");
      n = mxGetN(pa);
      pd = (double *)mxGetData(pa);
      scale_trans(pd, xybuf, m, uu_to_dbu);
      if ( (xybuf[0]!=xybuf[m*n-2]) || (xybuf[1]!=xybuf[m*n-1]) ) {
	 if (m+1 > 8191)
	    mexErrMsgTxt("more than 8191 vertices in boundary");
 	 xybuf[m*n]   = xybuf[0];  /* close polygon */
	 xybuf[m*n+1] = xybuf[1];
	 m+=1;
      }
      write_record_hdr(fob, XY, m*n*sizeof(int32_t));
      write_int_n(fob, xybuf, m*n);
   
      /* Property */
      if ( get_field_ptr(data, "prop", &propfield) )
	 write_property(fob, propfield);

      /* ENDEL */
      write_record_hdr(fob, ENDEL, 0);
   }
}

/*-- Compound Boundary --------------------------------------------*/

static void 
write_compound_boundary(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *propfield, *caxy, *pa, *internal;
   double *pd;
   int m,n,nxy=0,kxy;
   element_t bnd;


   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (boundary) :  missing internal data field.");
   memcpy(&bnd, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* number of boundaries contained in compound element */
   if ( get_field_ptr(data, "xy", &caxy) ) {
      nxy = mxGetNumberOfElements(caxy);
   }
   else   
      mexErrMsgTxt("gds_write_element (boundary) :  missing or empty xy field.");

   /* 
    * write one compound boundary element with multiple XY records 
    */
   /* BOUNDARY */
   write_record_hdr(fob, BOUNDARY, 0);

   /* ELFLAGS */
   if ( bnd.has & HAS_ELFLAGS ) {
      write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
      write_word(fob, bnd.elflags);
   }

   /* PLEX */
   if ( bnd.has & HAS_PLEX ) {
      write_record_hdr(fob, PLEX, sizeof(int32_t));
      write_int(fob, bnd.plex);
   }

   /* LAYER */
   write_record_hdr(fob, LAYER, sizeof(uint16_t));
   write_word(fob, bnd.layer);

   /* DATATYPE */
   write_record_hdr(fob, DATATYPE, sizeof(uint16_t));
   write_word(fob, bnd.dtype);
   
   /* XY */
   for (kxy=0; kxy<nxy; kxy++) {
      pa = mxGetCell(caxy, kxy);
      m = mxGetM(pa);
      if (m > 8191)
	 mexErrMsgTxt("more than 8191 vertices in boundary");
      n = mxGetN(pa);
      pd = (double *)mxGetData(pa);
      scale_trans(pd, xybuf, m, uu_to_dbu);
      if ( (xybuf[0]!=xybuf[m*n-2]) || (xybuf[1]!=xybuf[m*n-1]) ) {
	 if (m+1 > 8191)
	    mexErrMsgTxt("more than 8191 vertices in boundary");
 	 xybuf[m*n]   = xybuf[0];  /* close polygon */
	 xybuf[m*n+1] = xybuf[1];
	 m+=1;
      }
      write_record_hdr(fob, XY, m*n*sizeof(int32_t));
      write_int_n(fob, xybuf, m*n);
   }
   
   /* Property */
   if ( get_field_ptr(data, "prop", &propfield) )
      write_property(fob, propfield);

   /* ENDEL */
   write_record_hdr(fob, ENDEL, 0);
}


/*-- Path ---------------------------------------------------------*/
 
static void 
write_path(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *propfield, *caxy, *pa, *internal;
   double *pd;
   int m,n,nxy=0,kxy;
   element_t path;


   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (path) :  missing internal data field.");
   memcpy(&path, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* number of paths contained in compound element */
   if ( get_field_ptr(data, "xy", &caxy) ) {
      nxy = mxGetNumberOfElements(caxy);
   }
   else   
      mexErrMsgTxt("gds_write_element (path) :  missing or empty xy field.");

   /* 
    * write out the individual path elements 
    */
   for (kxy=0; kxy<nxy; kxy++) {

      /* PATH */
      write_record_hdr(fob, PATH, 0);

      /* ELFLAGS */
      if ( path.has & HAS_ELFLAGS ) {
	 write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
	 write_word(fob, path.elflags);
      }
      
      /* PLEX */
      if ( path.has & HAS_PLEX ) {
	 write_record_hdr(fob, PLEX, sizeof(int32_t));
	 write_int(fob, path.plex);
      }

      /* LAYER */
      write_record_hdr(fob, LAYER, sizeof(uint16_t));
      write_word(fob, path.layer);

      /* DATATYPE */
      write_record_hdr(fob, DATATYPE, sizeof(uint16_t));
      write_word(fob, path.dtype);
   
      /* PATHTYPE */
      if ( path.has & HAS_PTYPE ) {
	 write_record_hdr(fob, PATHTYPE, sizeof(uint16_t));
	 write_word(fob, path.ptype);
      }
   
      /* WIDTH */
      if ( path.has & HAS_WIDTH ) {
	 write_record_hdr(fob, WIDTH, sizeof(int32_t));
	 write_int(fob, (int32_t)floor(path.width * uu_to_dbu + 0.5));
      }
      
      /* Path extensions */
      if (path.has & HAS_PTYPE && path.ptype == 4) {
	 if ( path.has & HAS_BGNEXTN ) {
	    write_record_hdr(fob, BGNEXTN, sizeof(int32_t));
	    write_int(fob, (int32_t)floor(path.bgnextn * uu_to_dbu + 0.5));
	 }
	 if ( path.has & HAS_ENDEXTN ) {
	    write_record_hdr(fob, ENDEXTN, sizeof(int32_t));
	    write_int(fob, (int32_t)floor(path.endextn * uu_to_dbu + 0.5));
	 }
      }
   
      /* XY */
      pa = mxGetCell(caxy, kxy);
      m = mxGetM(pa);
      if (m > 8192)
	 mexErrMsgTxt("more than 8192 vertices in path");
      n = mxGetN(pa);
      pd = (double *)mxGetData(pa);
      scale_trans(pd, xybuf, m, uu_to_dbu);
      write_record_hdr(fob, XY, n*m*sizeof(int32_t));
      write_int_n(fob, xybuf, n*m);
   
      /* Property */
      if ( get_field_ptr(data, "prop", &propfield) )
	 write_property(fob, propfield);

      /* ENDEL */
      write_record_hdr(fob, ENDEL, 0);
   }
}

/*-- Compound Path-------------------------------------------------*/
 
static void 
write_compound_path(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *propfield, *caxy, *pa, *internal;
   double *pd;
   int m,n,nxy=0,kxy;
   element_t path;


   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (path) :  missing internal data field.");
   memcpy(&path, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* number of paths contained in compound element */
   if ( get_field_ptr(data, "xy", &caxy) ) {
      nxy = mxGetNumberOfElements(caxy);
   }
   else   
      mexErrMsgTxt("gds_write_element (path) :  missing or empty xy field.");

   /* 
    * write out one path element with multiple XY records 
    */
   /* PATH */
   write_record_hdr(fob, PATH, 0);

   /* ELFLAGS */
   if ( path.has & HAS_ELFLAGS ) {
      write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
      write_word(fob, path.elflags);
   }
      
   /* PLEX */
   if ( path.has & HAS_PLEX ) {
      write_record_hdr(fob, PLEX, sizeof(int32_t));
      write_int(fob, path.plex);
   }

   /* LAYER */
   write_record_hdr(fob, LAYER, sizeof(uint16_t));
   write_word(fob, path.layer);

   /* DATATYPE */
   write_record_hdr(fob, DATATYPE, sizeof(uint16_t));
   write_word(fob, path.dtype);
   
   /* PATHTYPE */
   if ( path.has & HAS_PTYPE ) {
      write_record_hdr(fob, PATHTYPE, sizeof(uint16_t));
      write_word(fob, path.ptype);
   }
   
   /* WIDTH */
   if ( path.has & HAS_WIDTH ) {
      write_record_hdr(fob, WIDTH, sizeof(int32_t));
      write_int(fob, (int32_t)floor(path.width * uu_to_dbu + 0.5));
   }
      
      /* Path extensions */
   if (path.has & HAS_PTYPE && path.ptype == 4) {
      if ( path.has & HAS_BGNEXTN ) {
	 write_record_hdr(fob, BGNEXTN, sizeof(int32_t));
	 write_int(fob, (int32_t)floor(path.bgnextn * uu_to_dbu + 0.5));
      }
      if ( path.has & HAS_ENDEXTN ) {
	 write_record_hdr(fob, ENDEXTN, sizeof(int32_t));
	 write_int(fob, (int32_t)floor(path.endextn * uu_to_dbu + 0.5));
      }
   }
   
   /* XY */
   for (kxy=0; kxy<nxy; kxy++) {
      pa = mxGetCell(caxy, kxy);
      m = mxGetM(pa);
      if (m > 8192)
	 mexErrMsgTxt("more than 8192 vertices in path");
      n = mxGetN(pa);
      pd = (double *)mxGetData(pa);
      scale_trans(pd, xybuf, m, uu_to_dbu);
      write_record_hdr(fob, XY, n*m*sizeof(int32_t));
      write_int_n(fob, xybuf, n*m);
   }

   /* Property */
   if ( get_field_ptr(data, "prop", &propfield) )
      write_property(fob, propfield);

   /* ENDEL */
   write_record_hdr(fob, ENDEL, 0);
}


/*-- Sref ---------------------------------------------------------*/

static void 
write_sref(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *internal, *propfield, *pxy;
   double *pdxy=NULL;
   int32_t xy[2];
   int mxy=0;
   int k,nlen;
   element_t sref;


   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (sref) :  missing internal data field.");
   memcpy(&sref, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* number of sref locations contained in compound element */
   if ( get_field_ptr(data, "xy", &pxy) ) {
      mxy = mxGetM(pxy);
      pdxy = (double *)mxGetData(pxy);
   }
   else   
      mexErrMsgTxt("gds_write_element (sref) :  missing or empty xy field.");

   /* 
    * write out the individual sref elements 
    */
   for (k=0; k<mxy; k++) {

      /* SREF */
      write_record_hdr(fob, SREF, 0);

      /* ELFLAGS */
      if ( sref.has & HAS_ELFLAGS ) {
	 write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
	 write_word(fob, sref.elflags);
      }

      /* PLEX */
      if ( sref.has & HAS_PLEX ) {
	 write_record_hdr(fob, PLEX, sizeof(int32_t));
	 write_int(fob, sref.plex);
      }

      /* SNAME */
      nlen = strlen(sref.sname);
      if ( !nlen )
	 mexErrMsgTxt("gds_write_element (sref) :  name of referenced structure missing.");
      if (nlen % 2)
	 nlen += 1;
      if (nlen > 32)
	 mexErrMsgTxt("gds_write_element (sref) :  structure name must have <= 32 chars.");
      write_record_hdr(fob, SNAME, nlen);
      write_string(fob, sref.sname, nlen);

      /* STRANS */
      if ( sref.has & HAS_STRANS ) {
	 write_record_hdr(fob, STRANS, sizeof(uint16_t));
	 write_word(fob, sref.strans.flags);
	 if ( sref.has & HAS_MAG && sref.strans.mag != 1.0) {
	    write_record_hdr(fob, MAG, 8);
	    write_real8(fob, sref.strans.mag);
	 }
	 if ( sref.has & HAS_ANGLE && sref.strans.angle != 0.0) {
	    write_record_hdr(fob, ANGLE, 8);
	    write_real8(fob, sref.strans.angle);
	 }
      }

      /* XY */
      xy[0] = floor(0.5 + pdxy[k]     * uu_to_dbu);
      xy[1] = floor(0.5 + pdxy[k+mxy] * uu_to_dbu);
      write_record_hdr(fob, XY, 2*sizeof(int32_t));
      write_int_n(fob, xy, 2);
   
      /* Property */
      if ( get_field_ptr(data, "prop", &propfield) )
	 write_property(fob, propfield);

      /* ENDEL */
      write_record_hdr(fob, ENDEL, 0);
   }
} 


/*-- Compound Sref ------------------------------------------------*/

static void 
write_compound_sref(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *internal, *propfield, *pxy;
   double *pdxy=NULL;
   int ncxy;      /* number of compound xy records */
   int mrem;      /* remainder in last record */
   int mxy=0;
   int k,nlen;
   element_t sref;


   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (sref) :  missing internal data field.");
   memcpy(&sref, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* number of sref locations contained in compound element */
   if ( get_field_ptr(data, "xy", &pxy) ) {
      mxy = mxGetM(pxy);
      pdxy = (double *)mxGetData(pxy);
   }
   else   
      mexErrMsgTxt("gds_write_element (sref) :  missing or empty xy field.");

   /* 
    * write sref elements as non-standard compound element
    */
   /* SREF */
   write_record_hdr(fob, SREF, 0);

   /* ELFLAGS */
   if ( sref.has & HAS_ELFLAGS ) {
      write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
      write_word(fob, sref.elflags);
   }

   /* PLEX */
   if ( sref.has & HAS_PLEX ) {
      write_record_hdr(fob, PLEX, sizeof(int32_t));
      write_int(fob, sref.plex);
   }

   /* SNAME */
   nlen = strlen(sref.sname);
   if ( !nlen )
      mexErrMsgTxt("gds_write_element (sref) :  name of referenced structure missing.");
   if (nlen % 2)
      nlen += 1;
   if (nlen > 32)
      mexErrMsgTxt("gds_write_element (sref) :  structure name must have <= 32 chars.");
   write_record_hdr(fob, SNAME, nlen);
   write_string(fob, sref.sname, nlen);

   /* STRANS */
   if ( sref.has & HAS_STRANS ) {
      write_record_hdr(fob, STRANS, sizeof(uint16_t));
      write_word(fob, sref.strans.flags);
      if ( sref.has & HAS_MAG && sref.strans.mag != 1.0) {
	 write_record_hdr(fob, MAG, 8);
	 write_real8(fob, sref.strans.mag);
      }
      if ( sref.has & HAS_ANGLE && sref.strans.angle != 0.0) {
	 write_record_hdr(fob, ANGLE, 8);
	 write_real8(fob, sref.strans.angle);
      }
   }

   /* multiple large XY records */
   ncxy = mxy / MAXVERTEXNUM;
   mrem = mxy % MAXVERTEXNUM;
   for (k=0; k<ncxy; k++) {
      scale_trans(pdxy+2*k*MAXVERTEXNUM, xybuf, MAXVERTEXNUM, uu_to_dbu);
      write_record_hdr(fob, XY, (uint16_t)(MAXVERTEXNUM*2*sizeof(int32_t)));
      write_int_n(fob, xybuf, 2*MAXVERTEXNUM);
   }
   if (mrem) {
      scale_trans(pdxy+2*ncxy*MAXVERTEXNUM, xybuf, mrem, uu_to_dbu);
      write_record_hdr(fob, XY, 2*mrem*sizeof(int32_t));
      write_int_n(fob, xybuf, 2*mrem);
   }

   /* Property */
   if ( get_field_ptr(data, "prop", &propfield) )
      write_property(fob, propfield);

   /* ENDEL */
   write_record_hdr(fob, ENDEL, 0);
} 


/*-- Aref ---------------------------------------------------------*/

static void 
write_aref(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *field, *propfield, *internal;
   double *pd;
   int32_t xy[6];
   int mxy,nxy=0,nlen;
   element_t aref;


   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (aref) :  missing internal data field.");
   memcpy(&aref, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* AREF */
   write_record_hdr(fob, AREF, 0);

   /* ELFLAGS */
   if ( aref.has & HAS_ELFLAGS ) {
      write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
      write_word(fob, aref.elflags);
   }

   /* PLEX */
   if ( aref.has & HAS_PLEX ) {
      write_record_hdr(fob, PLEX, sizeof(int32_t));
      write_int(fob, aref.plex);
   }

   /* SNAME */   
   nlen = strlen(aref.sname);
   if ( !nlen )
      mexErrMsgTxt("gds_write_element (aref) :  name of referenced structure missing.");
   if (nlen % 2)
      nlen += 1;
   if (nlen > 32)
      mexErrMsgTxt("gds_write_element (aref) :  structure name must have <= 32 chars.");
   write_record_hdr(fob, SNAME, nlen);
   write_string(fob, aref.sname, nlen);

   /* STRANS */
   if ( aref.has & HAS_STRANS ) {
      write_record_hdr(fob, STRANS, sizeof(uint16_t));
      write_word(fob, aref.strans.flags);
      if ( aref.has & HAS_MAG && aref.strans.mag != 1.0) {
	 write_record_hdr(fob, MAG, 8);
	 write_real8(fob, aref.strans.mag);
      }
      if ( aref.has & HAS_ANGLE && aref.strans.angle != 0.0) {
	 write_record_hdr(fob, ANGLE, 8);
	 write_real8(fob, aref.strans.angle);
      }
   }

   /* COLROW */
   if ( !aref.nrow )
      mexErrMsgTxt("gds_write_element (aref) :  number of rows is 0; must be > 0.");
   if ( !aref.ncol )
      mexErrMsgTxt("gds_write_element (aref) :  number of columns is 0; must be > 0.");
   write_record_hdr(fob, COLROW, 2*sizeof(uint16_t));
   write_word(fob, aref.ncol);
   write_word(fob, aref.nrow);
   
   /* XY */
   if ( get_field_ptr(data, "xy", &field) ) {
      pd = (double *)mxGetData(field);
      mxy = mxGetM(field);
      nxy = mxGetN(field);
      if ( (mxy != 3) || (nxy != 2) )
	 mexErrMsgTxt("gds_write_element (aref) :  xy must be 3x2 matrix.");
      scale_trans(pd, xy, mxy, uu_to_dbu);
      write_record_hdr(fob, XY, mxy*nxy*sizeof(int32_t));
      write_int_n(fob, xy, 6);
   }
   else   
      mexErrMsgTxt("gds_write_element (aref) :  missing or empty xy field.");

   /* Property */
   if ( get_field_ptr(data, "prop", &propfield) )
      write_property(fob, propfield);

   /* ENDEL */
   write_record_hdr(fob, ENDEL, 0);
} 


/*-- Text ---------------------------------------------------------*/

static void 
write_text(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *field, *propfield, *internal;
   double *pd;
   int32_t xy[2];
   int tlen;
   char txt[TXTLEN];
   element_t text;


   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (text) :  missing internal data field.");
   memcpy(&text, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* TEXT */
   write_record_hdr(fob, TEXT, 0);

   /* ELFLAGS */
   if ( text.has & HAS_ELFLAGS ) {
      write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
      write_word(fob, text.elflags);
   }

   /* PLEX */
   if ( text.has & HAS_PLEX ) {
      write_record_hdr(fob, PLEX, sizeof(int32_t));
      write_int(fob, text.plex);
   }

   /* LAYER */
   write_record_hdr(fob, LAYER, sizeof(uint16_t));
   write_word(fob, text.layer);

   /* TEXTTYPE */
   write_record_hdr(fob, TEXTTYPE, sizeof(uint16_t));
   write_word(fob, text.dtype);

   /* PRESENTATION */
   if ( text.has & HAS_PRESTN ) {
      write_record_hdr(fob, PRESENTATION, sizeof(uint16_t));
      write_word(fob, text.present);
   }	

   /* PATHTYPE */
   if ( text.has & HAS_PTYPE ) {
      write_record_hdr(fob, PATHTYPE, sizeof(uint16_t));
      write_word(fob, text.ptype);
   }
   
   /* WIDTH */
   if ( text.has & HAS_WIDTH ) {
      write_record_hdr(fob, WIDTH, sizeof(int32_t));
      write_int(fob, text.width);
   }

   /* STRANS */
   if ( text.has & HAS_STRANS ) {
      write_record_hdr(fob, STRANS, sizeof(uint16_t));
      write_word(fob, text.strans.flags);
      if ( text.has & HAS_MAG && text.strans.mag != 1.0) {
	 write_record_hdr(fob, MAG, 8);
	 write_real8(fob, text.strans.mag);
      }
      if ( text.has & HAS_ANGLE && text.strans.angle != 0.0) {
	 write_record_hdr(fob, ANGLE, 8);
	 write_real8(fob, text.strans.angle);
      }
   }

   /* XY */
   if ( get_field_ptr(data, "xy", &field) ) {
      pd = (double *)mxGetData(field);
      scale_trans(pd, xy, 1, uu_to_dbu);
      write_record_hdr(fob, XY, 2*sizeof(int32_t));
      write_int_n(fob, xy, 2);
   }
   else   
      mexErrMsgTxt("gds_write_element (text) :  missing or empty xy field.");

   /* STRING */   
   if ( get_field_ptr(data, "text", &field) ) {
      mxGetString(field, txt, TXTLEN);
      tlen = strlen(txt);
      if (tlen % 2)
	 tlen += 1;
      if (tlen > 512)
	 mexErrMsgTxt("gds_write_element (text) :  text must have <= 512 chars.");
      write_record_hdr(fob, STRING, tlen);
      write_string(fob, txt, tlen);
   }
   else   
      mexErrMsgTxt("gds_write_element (text) :  missing text field.");

   /* Property */
   if ( get_field_ptr(data, "prop", &propfield) )
      write_property(fob, propfield);

   /* ENDEL */
   write_record_hdr(fob, ENDEL, 0);
}


/*-- Node ---------------------------------------------------------*/

static void 
write_node(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *field, *propfield, *internal;
   double *pd;
   int m,n;
   element_t node;

   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (node) :  missing internal data field.");
   memcpy(&node, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* NODE */
   write_record_hdr(fob, NODE, 0);

   /* ELFLAGS */
   if ( node.has & HAS_ELFLAGS ) {
      write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
      write_word(fob, node.elflags);
   }

   /* PLEX */
   if ( node.has & HAS_PLEX ) {
      write_record_hdr(fob, ELFLAGS, sizeof(int32_t));
      write_int(fob, node.plex);
   }

   /* LAYER */
   write_record_hdr(fob, LAYER, sizeof(uint16_t));
   write_word(fob, node.layer);

   /* NODETYPE */
   write_record_hdr(fob, NODETYPE, sizeof(uint16_t));
   write_word(fob, node.dtype);
   
   /* XY */
   if ( get_field_ptr(data, "xy", &field) ) {
      pd = (double *)mxGetData(field);
      m = mxGetM(field);
      if (m > 1024)
	 mexErrMsgTxt("more than 1024 vertices in node");
      n = mxGetN(field);
      scale_trans(pd, xybuf, m, uu_to_dbu);
      write_record_hdr(fob, XY, m*n*sizeof(int32_t));
      write_int_n(fob, xybuf, m*n);
   }
   else   
      mexErrMsgTxt("gds_write_element (node) :  missing xy field.");
   
   /* Property */
   if ( get_field_ptr(data, "prop", &propfield) )
      write_property(fob, propfield);

   /* ENDEL */
   write_record_hdr(fob, ENDEL, 0);
}


/*-- Box ----------------------------------------------------------*/ 

static void 
write_box(FILE *fob, mxArray *data, double uu_to_dbu)
{
   mxArray *field, *propfield, *internal;
   double *pd;
   int32_t xy[10];
   int m;
   element_t box;

   /* internal structure */
   if ( !get_field_ptr(data, "internal", &internal) )
      mexErrMsgTxt("gds_write_element (box) :  missing internal data field.");
   memcpy(&box, (int32_t *)mxGetData(internal), sizeof(element_t));

   /* BOX */
   write_record_hdr(fob, BOX, 0);

   /* ELFLAGS */
   if ( box.has & HAS_ELFLAGS ) {
      write_record_hdr(fob, ELFLAGS, sizeof(uint16_t));
      write_word(fob, box.elflags);
   }

   /* PLEX */
   if ( box.has & HAS_PLEX ) {
      write_record_hdr(fob, PLEX, sizeof(int32_t));
      write_int(fob, box.plex);
   }

   /* LAYER */
   write_record_hdr(fob, LAYER, sizeof(uint16_t));
   write_word(fob, box.layer);
 
   /* BOXTYPE */
   write_record_hdr(fob, BOXTYPE, sizeof(uint16_t));
   write_word(fob, box.dtype);
   
   /* XY */
   if ( get_field_ptr(data, "xy", &field) ) {
      pd = (double *)mxGetData(field);
      m = mxGetM(field); 
      if (m < 4 || m > 5)
	 mexErrMsgTxt("gds_write_element (box) :  must supply 4 or 5 vertices.");
      scale_trans(pd, xy, m, uu_to_dbu);
      if (m == 4) { /* polygon is not closed */
	 xy[8] = xy[0]; xy[9] = xy[1];
      }
      write_record_hdr(fob, XY, 10*sizeof(int32_t));
      write_int_n(fob, xy, 10);
   }
   else   
      mexErrMsgTxt("gds_write_element (box) :  missing or empty xy field.");
   
   /* Property */
   if ( get_field_ptr(data, "prop", &propfield) )
      write_property(fob, propfield);

   /* ENDEL */
   write_record_hdr(fob, ENDEL, 0);
}


/*-- Common -------------------------------------------------------*/

static void 
write_property(FILE *fob, mxArray *prop)
{
   mxArray *pa;
   double *pd;
   int k,len,np;
   int16_t attr;
   char value[VLEN];


   /* get number of attribute / value pairs */
   np = mxGetM(prop) * mxGetN(prop);

   for (k=0; k<np; k++) {
      pa = mxGetField(prop, k, "attr");
      pd = (double *)mxGetData(pa);
      attr = (int16_t)pd[0];
      write_record_hdr(fob, PROPATTR, sizeof(int16_t));
      write_word(fob, attr);

      pa = mxGetField(prop, k, "name");
      mxGetString(pa, value, VLEN);
      len = strlen(value);
      if (len%2)
	 len += 1;
      write_record_hdr(fob, PROPVALUE, len);
      write_string(fob, value, len);
   }
}
 

/*-----------------------------------------------------------------*/

/* transpose polygon data and scale to database units */
static INLINE void 
scale_trans(double * RESTRICT data, int32_t * RESTRICT xy, int m, double sfact)
{
   int i, k;

   for (k=i=0; k<m; k++,i+=2) {
      xy[i]   = floor(0.5 + data[k]   * sfact);
      xy[i+1] = floor(0.5 + data[k+m] * sfact);
   }
}

/*-----------------------------------------------------------------*/
