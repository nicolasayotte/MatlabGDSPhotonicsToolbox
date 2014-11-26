/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2012- 2013, Ulf Griesmann
 *
 * Description:
 * Reads element data from a GDS II library file.
 *
 * [data] = gds_read_element(gf, rtype, dbu_to_uu);
 *
 * data.internal : matrix that stores C structure with element properties
 * data.xy : a cell array with boundaries, paths, or positions
 * data.prop : structure array with properties
 * data.text : text of a text element
 *
 * Input
 * gf :    a file handle returned by gds_open.
 * rtype : the element type from the element record header
 * uunit : user unit in m
 * dbunit: database unit in m
 *
 * Output: 
 * estr :  a string with element type name
 * data :  a structure with element data
 */

#include <stdio.h>
#include <string.h>
#include "gdsio.h"
#include "mex.h"

#include "gdstypes.h"
#include "eldata.h"
#include "mexfuncs.h"
#include "mxlist.h"  

#define TXTLEN 512
#define MAXVERTEXNUM 8192


/*-- Types --------------------------------------------------------*/

typedef struct {
   double *xy;  /* pointer to vertex array */
   int mxy;     /* number of vertices */
} xy_block;


/*-- Data ---------------------------------------------------------*/

static int32_t xybuf[2*MAXVERTEXNUM];


/*-- Local Functions ----------------------------------------------*/

static void read_boundary(FILE *fob, mxArray **data, double dbu_to_uu); 
static void read_path(FILE *fob, mxArray **data, double dbu_to_uu); 
static void read_sref(FILE *fob, mxArray **data, double dbu_to_uu); 
static void read_aref(FILE *fob, mxArray **data, double dbu_to_uu); 
static void read_text(FILE *fob, mxArray **data, double dbu_to_uu); 
static void read_node(FILE *fob, mxArray **data, double dbu_to_uu); 
static void read_box(FILE *fob, mxArray **data, double dbu_to_uu); 
static uint16_t read_elflags(FILE *fob); 
static int32_t read_plex(FILE *fob);
static uint16_t read_layer(FILE *fob); 
static uint16_t read_type(FILE *fob); 
static mxArray* read_xy(FILE *fob, int rlen, double dbu_to_uu); /* returns a cell */ 
static double* read_xy2(FILE *fob, int m, double dbu_to_uu);    /* returns sref xy */
static int32_t read_extn(FILE *fob);
static int32_t read_width(FILE *fob);
static mxArray* read_propattr(FILE *fob); 
static mxArray* read_propvalue(FILE *fob, int rlen); 
static mxArray* resize_property_structure(mxArray *pprop, int size);
static void read_colrow(FILE *fob, uint16_t *row, uint16_t *col);
static void init_element(element_t *elm, element_kind kind); 


/*-----------------------------------------------------------------*/

void
mexFunction(int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[])
{
   mxArray *data;  /* element data in a structure */
   FILE *fob;
   double *pd;
   double dbu_to_uu;
   int etype;

   /* check argument number */
   if (nrhs != 3) {
      mexErrMsgTxt("3 input arguments expected.");
   }
   if (nlhs != 1) {
      mexErrMsgTxt("one output argument expected.");
   }
   
   /* get file handle argument */
   fob = get_file_ptr((mxArray *)prhs[0]);

   /* get type argument */
   pd = mxGetData(prhs[1]);
   etype = pd[0];

   /* get unit conversion factor: database units --> user units */
   pd = mxGetData(prhs[2]);
   dbu_to_uu = pd[0];

   /* decide what to do */
   switch (etype) {
     
      case BOUNDARY:
	 read_boundary(fob, &data, dbu_to_uu);
	 break;

      case PATH:
	 read_path(fob, &data, dbu_to_uu);
	 break;

      case SREF:
	 read_sref(fob, &data, dbu_to_uu);
	 break;

      case AREF:
	 read_aref(fob, &data, dbu_to_uu);
	 break;

      case TEXT:
	 read_text(fob, &data, dbu_to_uu);
	 break;

      case NODE:
	 read_node(fob, &data, dbu_to_uu);
	 break;

      case BOX:
	 read_box(fob, &data, dbu_to_uu);
	 break;

      default:
         mexErrMsgTxt("gds_read_element :  unknown element type.");
   }

   plhs[0] = data;
}


/*-- Boundary -----------------------------------------------------*/

static void 
read_boundary(FILE *fob, mxArray **data, double dbu_to_uu)
{
   mxArray *pstruct;
   mxArray *pprop = NULL;
   mxArray *pc;
   tList xylist;
   uint16_t rtype, rlen;
   int nprop = 0;
   int nle, k;
   element_t bnd;  /* structure with element data */
   const char *fields[] = {"internal", "xy", "prop"};


   /* initialize element */
   init_element(&bnd, GDS_BOUNDARY);

   /* output data structure */
   pstruct = mxCreateStructMatrix(1,1, 3, fields);

   /* create a list for the XY data record(s) */
   if ( create_list(&xylist) == -1 )
      mexErrMsgTxt("gds_read_element (boundary) :  could not create list for XY records.");

   /* read element properties */
   while (1) {

      if ( read_record_hdr(fob, &rtype, &rlen) )
	 mexErrMsgTxt("gds_read_element (boundary) :  could not read record header.");

      if (rtype == ENDEL)
	 break;

      switch (rtype) {

         case XY:
	    if ( list_insert(xylist, read_xy(fob, rlen, dbu_to_uu), AFTER) == -1)
	       mexErrMsgTxt("gds_read_element (boundary) :  list insertion failed.");
	    break;

         case LAYER:
	    bnd.layer = read_layer(fob);
	    break;

         case DATATYPE:
	    bnd.dtype = read_type(fob);
	    break;

         case ELFLAGS:
	    bnd.elflags = read_elflags(fob);
	    bnd.has |= HAS_ELFLAGS;
	    break;

         case PLEX:
	    bnd.plex = read_plex(fob);
	    bnd.has |= HAS_PLEX;
	    break;

         case PROPATTR:
	    pprop = resize_property_structure(pprop, nprop+1);
	    mxSetFieldByNumber(pprop, nprop, 0, read_propattr(fob));
	    break;

         case PROPVALUE:
 	    mxSetFieldByNumber(pprop, nprop, 1, read_propvalue(fob,rlen));
	    nprop += 1;
	    break;

         default:
	    mexPrintf("Unknown record id: 0x%x\n", rtype);
	    mexErrMsgTxt("BOUNDARY :  found unknown element property.");
      }
   }

   /* cell array with XY records */
   nle = list_entries(xylist);
   if ( !nle )
      mexErrMsgTxt("gds_read_element (boundary) :  element has no XY record.");
   pc = mxCreateCellMatrix(1, nle);
   list_head(xylist);
   for (k=0; k<nle; k++)
      mxSetCell(pc, k, (mxArray *)get_current_entry(xylist, NULL));
   mxSetFieldByNumber(pstruct, 0, 1, pc);

   /* set prop field */
   if ( nprop ) {
      mxSetFieldByNumber(pstruct, 0, 2, pprop);
   }
   else {
      mxSetFieldByNumber(pstruct, 0, 2, empty_matrix());
   }

   /* store structure with internal element data */
   mxSetFieldByNumber(pstruct, 0, 0, copy_element_to_array(&bnd));

   /* return data */
   *data = pstruct;
}


/*-- Path ---------------------------------------------------------*/
 
static void 
read_path(FILE *fob, mxArray **data, double dbu_to_uu) 
{
   mxArray *pstruct;
   mxArray *pprop = NULL;
   mxArray *pc;
   tList xylist;
   uint16_t rtype, rlen;
   int nprop = 0;
   int nle, k;
   element_t path;
   const char *fields[] = {"internal", "xy", "prop"};


   /* initialize element */
   init_element(&path, GDS_PATH);

   /* output data structure */
   pstruct = mxCreateStructMatrix(1,1, 3, fields);

   /* create a list for the XY data record(s) */
   if ( create_list(&xylist) == -1 )
      mexErrMsgTxt("gds_read_element (path) :  could not create list for XY records.");

   /* read element properties */
   while (1) {
      
      if ( read_record_hdr(fob, &rtype, &rlen) )
	 mexErrMsgTxt("gds_read_element (path) :  could not read record header.");

      if (rtype == ENDEL)
	 break;

      switch (rtype) {

         case XY:
	    if ( list_insert(xylist, read_xy(fob, rlen, dbu_to_uu), AFTER) == -1)
	       mexErrMsgTxt("gds_read_element (path) :  list insertion failed.");
	    break;

         case LAYER:
	    path.layer = read_layer(fob);
	    break;

         case PATHTYPE:
	    path.ptype = read_type(fob);
	    path.has |= HAS_PTYPE;
	    break;

         case WIDTH:
	    path.width = dbu_to_uu * (double)read_width(fob);
	    path.has |= HAS_WIDTH;
	    break;

         case BGNEXTN:
	    path.bgnextn = dbu_to_uu * read_extn(fob);
	    path.has |= HAS_BGNEXTN;
	    break;

         case ENDEXTN:
	    path.endextn = dbu_to_uu * read_extn(fob);
	    path.has |= HAS_ENDEXTN;
	    break;

         case DATATYPE:
	    path.dtype = read_type(fob);
	    break;

         case ELFLAGS:
	    path.elflags = read_elflags(fob);
	    path.has |= HAS_ELFLAGS;
	    break;

         case PLEX:
	    path.plex = read_plex(fob);
	    path.has |= HAS_PLEX;
	    break;

         case PROPATTR:
	    pprop = resize_property_structure(pprop, nprop+1);
	    mxSetFieldByNumber(pprop, nprop, 0, read_propattr(fob));
	    break;

         case PROPVALUE:
 	    mxSetFieldByNumber(pprop, nprop, 1, read_propvalue(fob,rlen));
	    nprop += 1;
	    break;

         default:
	    mexPrintf("Unknown record id: 0x%x\n", rtype);
	    mexErrMsgTxt("PATH :  found unknown element property.");
      }
   }

   /* cell array with XY records */
   nle = list_entries(xylist);
   if ( !nle )
      mexErrMsgTxt("gds_read_element (path) :  element has no XY record.");
   pc = mxCreateCellMatrix(1, nle);
   list_head(xylist);
   for (k=0; k<nle; k++)
      mxSetCell(pc, k, (mxArray *)get_current_entry(xylist, NULL));
   mxSetFieldByNumber(pstruct, 0, 1, pc);

   /* set prop field */
   if ( nprop ) {
      mxSetFieldByNumber(pstruct, 0, 2, pprop);
   }
   else {
      mxSetFieldByNumber(pstruct, 0, 2, empty_matrix());
   }

   /* store structure with element data */
   mxSetFieldByNumber(pstruct, 0, 0, copy_element_to_array(&path));

   /* return data */
   *data = pstruct;
}


/*-- Sref ---------------------------------------------------------*/

static void 
read_sref(FILE *fob, mxArray **data, double dbu_to_uu)
{
   mxArray *pstruct;
   mxArray *pprop = NULL;
   mxArray *pa;
   double *pd;
   tList xylist;
   uint16_t rtype, rlen;
   int nprop = 0;
   int mtotal = 0;
   int k, m, nle;
   element_t sref;
   const char *fields[] = {"internal", "xy", "prop"};
   xy_block vertex;


   /* initialize element */
   init_element(&sref, GDS_SREF);

   /* output data structure */
   pstruct = mxCreateStructMatrix(1,1, 3, fields);

   /* create a list for the XY data record(s) */
   if ( create_list(&xylist) == -1 )
      mexErrMsgTxt("gds_read_element (sref) :  could not create list for XY records.");

   /* read element properties */
   while (1) {
      
      if ( read_record_hdr(fob, &rtype, &rlen) )
	 mexErrMsgTxt("gds_read_element (sref) :  could not read record header.");

      if (rtype == ENDEL)
	 break;

      switch (rtype) {

         case XY:
	    m = rlen / (2*sizeof(int32_t));
	    vertex.mxy = m;
	    vertex.xy = read_xy2(fob, m, dbu_to_uu);
	    list_insert_object(xylist, &vertex, sizeof(xy_block), AFTER);
	    mtotal += m;
	    break;

         case SNAME:
	    if ( read_string(fob, sref.sname, rlen) )
	       mexErrMsgTxt("gds_read_element (sref) :  could not read structure name.");
	    break;

         case STRANS:
	    if ( read_word(fob, &sref.strans.flags) )
	       mexErrMsgTxt("gds_read_element (sref) :  could not read strans data.");
	    sref.has |= HAS_STRANS;
	    break;

         case MAG:
	    if ( read_real8(fob, &sref.strans.mag) )
	       mexErrMsgTxt("gds_read_element (sref) :  could not read magnification.");
	    sref.has |= HAS_MAG;
	    break;

         case ANGLE:
	    if ( read_real8(fob, &sref.strans.angle) )
	       mexErrMsgTxt("gds_read_element (sref) :  could not read angle.");
	    sref.has |= HAS_ANGLE;
	    break;

         case ELFLAGS:
	    sref.elflags = read_elflags(fob);
	    sref.has |= HAS_ELFLAGS;
	    break;

         case PLEX:
	    sref.plex = read_plex(fob);
	    sref.has |= HAS_PLEX;
	    break;

         case PROPATTR:
	    pprop = resize_property_structure(pprop, nprop+1);
	    mxSetFieldByNumber(pprop, nprop, 0, read_propattr(fob));
	    break;

         case PROPVALUE:
 	    mxSetFieldByNumber(pprop, nprop, 1, read_propvalue(fob,rlen));
	    nprop += 1;
	    break;

         default:
	    mexPrintf("Unknown record id: 0x%x\n", rtype);
	    mexErrMsgTxt("SREF :  found unknown element property.");
      }
   }

   /* catenate XY records */
   nle = list_entries(xylist);
   if ( !nle )
      mexErrMsgTxt("gds_read_element (sref) :  element has no XY record.");
   pa = mxCreateDoubleMatrix(mtotal,2, mxREAL);
   pd = mxGetData(pa);
   list_head(xylist);
   for (k=0; k<nle; k++) {
      get_current_object(xylist, &vertex, sizeof(xy_block));
      memcpy(pd, vertex.xy, 2*vertex.mxy*sizeof(double));
      pd += 2*vertex.mxy;
      mxFree(vertex.xy);
   }
   mxSetFieldByNumber(pstruct, 0, 1, pa);
   erase_list_entries(xylist);
   delete_list(&xylist);

   /* set prop field */
   if ( nprop ) {
      mxSetFieldByNumber(pstruct, 0, 2, pprop);
   }
   else {
      mxSetFieldByNumber(pstruct, 0, 2, empty_matrix());
   }

   /* store structure with element data */
   mxSetFieldByNumber(pstruct, 0, 0, copy_element_to_array(&sref));

   /* return data */
   *data = pstruct;
} 


/*-- Aref ---------------------------------------------------------*/

static void 
read_aref(FILE *fob, mxArray **data, double dbu_to_uu)
{
   mxArray *pstruct;
   mxArray *pprop = NULL;
   uint16_t rtype, rlen;
   int nprop = 0;
   element_t aref;
   const char *fields[] = {"internal", "xy", "prop"};


   /* initialize element */
   init_element(&aref, GDS_AREF);

   /* output data structure */
   pstruct = mxCreateStructMatrix(1,1, 3, fields);

   /* read element properties */
   while (1) {
      
      if ( read_record_hdr(fob, &rtype, &rlen) )
	 mexErrMsgTxt("gds_read_element (aref) :  could not read record header.");

      if (rtype == ENDEL)
	 break;

      switch (rtype) {

         case XY:
            mxSetFieldByNumber(pstruct, 0, 1, read_xy(fob, rlen, dbu_to_uu));
 	    break;

         case SNAME:
	    if ( read_string(fob, aref.sname, rlen) )
	       mexErrMsgTxt("gds_read_element (sref) :  could not read structure name.");
	    break;

         case COLROW:
	    read_colrow(fob, &aref.nrow, &aref.ncol);
	    break;
	    
         case STRANS:
	    if ( read_word(fob, &aref.strans.flags) )
	       mexErrMsgTxt("gds_read_element (aref) :  could not read strans data.");
	    aref.has |= HAS_STRANS;
	    break;

         case MAG:
	    if ( read_real8(fob, &aref.strans.mag) )
	       mexErrMsgTxt("gds_read_element (aref) :  could not read magnification.");
	    aref.has |= HAS_MAG;
	    break;

         case ANGLE:
	    if ( read_real8(fob, &aref.strans.angle) )
	       mexErrMsgTxt("gds_read_element (aref) :  could not read angle.");
	    aref.has |= HAS_ANGLE;
	    break;

         case ELFLAGS:
	    aref.elflags = read_elflags(fob);
	    aref.has |= HAS_ELFLAGS;
	    break;

         case PLEX:
	    aref.plex = read_plex(fob);
	    aref.has |= HAS_PLEX;
	    break;

         case PROPATTR:
	    pprop = resize_property_structure(pprop, nprop+1);
	    mxSetFieldByNumber(pprop, nprop, 0, read_propattr(fob));
	    break;

         case PROPVALUE:
 	    mxSetFieldByNumber(pprop, nprop, 1, read_propvalue(fob,rlen));
	    nprop += 1;
	    break;

         default:
	    mexPrintf("Unknown record id: 0x%x\n", rtype);
	    mexErrMsgTxt("AREF :  found unknown element property.");
      }
   }

   /* set prop field */
   if ( nprop ) {
      mxSetFieldByNumber(pstruct, 0, 2, pprop);
   }
   else {
      mxSetFieldByNumber(pstruct, 0, 2, empty_matrix());
   }

   /* store structure with element data */
   mxSetFieldByNumber(pstruct, 0, 0, copy_element_to_array(&aref));

   /* return data */
   *data = pstruct;
} 


/*-- Text ---------------------------------------------------------*/

static void 
read_text(FILE *fob, mxArray **data, double dbu_to_uu)
{
   mxArray *pstruct;
   mxArray *pprop = NULL;
   uint16_t rtype, rlen;
   int nprop = 0;
   char tstr[TXTLEN+4];
   element_t text;
   const char *fields[] = {"internal", "xy", "prop", "text"};


   /* initialize element */
   init_element(&text, GDS_TEXT);

   /* output data structure */
   pstruct = mxCreateStructMatrix(1,1, 4, fields);

   /* read element properties */
   while (1) {
      
      if ( read_record_hdr(fob, &rtype, &rlen) )
	 mexErrMsgTxt("gds_read_element (text) :  could not read record header.");

      if (rtype == ENDEL)
	 break;

      switch (rtype) {

         case STRING:
	    if ( read_string(fob, tstr, rlen) )
	       mexErrMsgTxt("gds_read_element (text) :  could not read string.");
	    struct_set_string(pstruct, 3, tstr);
	    break;

         case TEXTTYPE:
	    text.dtype = read_type(fob);
	    break;

         case XY:
	    mxSetFieldByNumber(pstruct, 0, 1, read_xy(fob, rlen, dbu_to_uu));
	    break;

         case LAYER:
	    text.layer = read_layer(fob);
	    break;

         case PATHTYPE:
	    text.ptype = read_type(fob);
	    text.has |= HAS_PTYPE;
	    break;

         case WIDTH:
	    text.width = dbu_to_uu * read_width(fob);
	    text.has |= HAS_WIDTH;
	    break;

         case PRESENTATION:
	    if ( read_word(fob, &text.present) )
	       mexErrMsgTxt("gds_read_element (text) :  could not read presentation data.");
	    text.has |= HAS_PRESTN;
	    break;

         case STRANS:
	    if ( read_word(fob, &text.strans.flags) )
	       mexErrMsgTxt("gds_read_element (text) :  could not read strans data.");
	    text.has |= HAS_STRANS;
	    break;

         case MAG:
	    if ( read_real8(fob, &text.strans.mag) )
	       mexErrMsgTxt("gds_read_element (text) :  could not read magnification.");
	    text.has |= HAS_MAG;
	    break;

         case ANGLE:
	    if ( read_real8(fob, &text.strans.angle) )
	       mexErrMsgTxt("gds_read_element (text) :  could not read angle.");
	    text.has |= HAS_ANGLE;
	    break;

         case ELFLAGS:
	    text.elflags = read_elflags(fob);
	    text.has |= HAS_ELFLAGS;
	    break;

         case PLEX:
	    text.plex = read_plex(fob);
	    text.has |= HAS_PLEX;
	    break;

         case PROPATTR:
	    pprop = resize_property_structure(pprop, nprop+1);
	    mxSetFieldByNumber(pprop, nprop, 0, read_propattr(fob));
	    break;

         case PROPVALUE:
 	    mxSetFieldByNumber(pprop, nprop, 1, read_propvalue(fob,rlen));
	    nprop += 1;
	    break;

         default:
	    mexPrintf("Unknown record id: 0x%x\n", rtype);
	    mexErrMsgTxt("TEXT :  found unknown element property.");
      }
   }

   /* set prop field */
   if ( nprop ) {
      mxSetFieldByNumber(pstruct, 0, 2, pprop);
   }
   else {
      mxSetFieldByNumber(pstruct, 0, 2, empty_matrix());
   }

   /* store structure with element data */
   mxSetFieldByNumber(pstruct, 0, 0, copy_element_to_array(&text));

   /* return data */
   *data = pstruct;
}


/*-- Node ---------------------------------------------------------*/

static void 
read_node(FILE *fob, mxArray **data, double dbu_to_uu)
{
   mxArray *pstruct;
   mxArray *pprop = NULL;
   uint16_t rtype, rlen;
   int nprop = 0;
   element_t node;
   const char *fields[] = {"internal", "xy", "prop"};


   /* initialize element */
   init_element(&node, GDS_NODE);

   /* output data structure */
   pstruct = mxCreateStructMatrix(1,1, 3, fields);

   /* read element properties */
   while (1) {
      
      if ( read_record_hdr(fob, &rtype, &rlen) )
	 mexErrMsgTxt("gds_read_element (node) :  could not read record header.");

      if (rtype == ENDEL)
	 break;

      switch (rtype) {

         case XY:
	    mxSetFieldByNumber(pstruct, 0, 1, read_xy(fob, rlen, dbu_to_uu));
	    break;

         case LAYER:
	    node.layer = read_layer(fob);
	    break;

         case NODETYPE:
	    node.dtype = read_type(fob);
	    break;

         case ELFLAGS:
	    node.elflags = read_elflags(fob);
	    node.has |= HAS_ELFLAGS;
	    break;

         case PLEX:
	    node.plex = read_plex(fob);		
	    node.has |= HAS_PLEX;
	    break;

         case PROPATTR:
	    pprop = resize_property_structure(pprop, nprop+1);
	    mxSetFieldByNumber(pprop, nprop, 0, read_propattr(fob));
	    break;

         case PROPVALUE:
 	    mxSetFieldByNumber(pprop, nprop, 1, read_propvalue(fob,rlen));
	    nprop += 1;
	    break;

         default:
	    mexPrintf("Unknown record id: 0x%x\n", rtype);
	    mexErrMsgTxt("NODE :  found unknown element property.");
      }
   }

   /* set prop field */
   if ( nprop ) {
      mxSetFieldByNumber(pstruct, 0, 2, pprop);
   }
   else {
      mxSetFieldByNumber(pstruct, 0, 2, empty_matrix());
   }

   /* store structure with element data */
   mxSetFieldByNumber(pstruct, 0, 0, copy_element_to_array(&node));

   /* return data */
   *data = pstruct;
}


/*-- Box ----------------------------------------------------------*/ 

static void 
read_box(FILE *fob, mxArray **data, double dbu_to_uu)
{
   mxArray *pstruct;
   mxArray *pprop = NULL;
   uint16_t rtype, rlen;
   int nprop = 0;
   element_t box;
   const char *fields[] = {"internal", "xy", "prop"};


   /* initialize element */
   init_element(&box, GDS_BOX);

   /* output data structure */
   pstruct = mxCreateStructMatrix(1,1, 3, fields);

   /* read element properties */
   while (1) {
      
      if ( read_record_hdr(fob, &rtype, &rlen) )
	 mexErrMsgTxt("gds_read_element (box) :  could not read record header.");

      if (rtype == ENDEL)
	 break;

      switch (rtype) {

         case XY:
	    mxSetFieldByNumber(pstruct, 0, 1, read_xy(fob, rlen, dbu_to_uu));
	    break;

         case LAYER:
	    box.layer = read_layer(fob);
	    break;

         case BOXTYPE:
	    box.dtype = read_type(fob);
	    break;

         case ELFLAGS:
	    box.elflags = read_elflags(fob);
	    box.has |= HAS_ELFLAGS;
	    break;

         case PLEX:
	    box.plex = read_plex(fob);
	    box.has |= HAS_PLEX;
	    break;

         case PROPATTR:
	    pprop = resize_property_structure(pprop, nprop+1);
	    mxSetFieldByNumber(pprop, nprop, 0, read_propattr(fob));
	    break;

         case PROPVALUE:
 	    mxSetFieldByNumber(pprop, nprop, 1, read_propvalue(fob,rlen));
	    nprop += 1;
	    break;

         default:
	    mexPrintf("Unknown record id: 0x%x\n", rtype);
	    mexErrMsgTxt("BOX :  found unknown element property.");
      }
   }

   /* set prop field */
   if ( nprop ) {
      mxSetFieldByNumber(pstruct, 0, 2, pprop);
   }
   else {
      mxSetFieldByNumber(pstruct, 0, 2, empty_matrix());
   }

   /* store structure with element data */
   mxSetFieldByNumber(pstruct, 0, 0, copy_element_to_array(&box));

   /* return data */
   *data = pstruct;
}


/*=================================================================*/

static uint16_t 
read_elflags(FILE *fob)
{
   uint16_t elflags;

   if ( read_word(fob, &elflags) )
      mexErrMsgTxt("read_elflags :  read failed.");

   return elflags;
}


/*-----------------------------------------------------------------*/
 
static int32_t 
read_plex(FILE *fob)
{
   int32_t plex;

   if ( read_int(fob, &plex) )
      mexErrMsgTxt("read_plex :  read failed.");

   if ( plex & (1<<23) ) {
      plex = plex & ~(1<<23);
      plex = -plex;
   }

   return plex;
}


/*-----------------------------------------------------------------*/

static uint16_t 
read_layer(FILE *fob)
{
   uint16_t layer;

   if ( read_word(fob, &layer) )
      mexErrMsgTxt("read_layer :  failed to read layer info.");

   return layer;
}


/*-----------------------------------------------------------------*/
 
static uint16_t 
read_type(FILE *fob)
{
   uint16_t type;

   if ( read_word(fob, &type) )
      mexErrMsgTxt("read_type :  failed to read type info.");

   return type;
}


/*-----------------------------------------------------------------*/
 
static mxArray* 
read_xy(FILE *fob, int rlen, double dbu_to_uu)
{
   mxArray *pa;
   double *pd;
   int i,k,n,m;

   n = rlen / sizeof(int32_t); 
   m = n / 2;
   read_int_n(fob, xybuf, n);
   pa = mxCreateDoubleMatrix(m,2, mxREAL);
   pd = mxGetData(pa);
   for (i=k=0; k<m; k++,i+=2) {
      pd[k]   = (double)xybuf[i]   * dbu_to_uu;
      pd[k+m] = (double)xybuf[i+1] * dbu_to_uu;
   }

   return pa;
}


/*-----------------------------------------------------------------*/
 
static double* 
read_xy2(FILE *fob, int m, double dbu_to_uu)
{
   double *pd;
   int i,k;

   read_int_n(fob, xybuf, 2*m);
   pd = mxMalloc(2*m*sizeof(double));
   for (i=k=0; k<m; k++,i+=2) {
      pd[k]   = (double)xybuf[i]   * dbu_to_uu;
      pd[k+m] = (double)xybuf[i+1] * dbu_to_uu;
   }
   
   return pd;
}


/*-----------------------------------------------------------------*/

static int32_t 
read_extn(FILE *fob)
{
   int32_t ext;

   if ( read_int(fob, &ext) )
      mexErrMsgTxt("read_ext :  read failed.");

   return ext;
}


/*-----------------------------------------------------------------*/

static int32_t
read_width(FILE *fob)
{
   int32_t width;

   if ( read_int(fob, &width) )
      mexErrMsgTxt("read_width :  read failed.");

   return width;
}


/*-----------------------------------------------------------------*/

 
static mxArray* 
read_propattr(FILE *fob)
{
   mxArray *pa;
   double *pd;
   int16_t attr;

   if ( read_word(fob, (uint16_t *)&attr) )
      mexErrMsgTxt("read_propattr :  read failed.");

   pa = mxCreateDoubleMatrix(1,1,mxREAL);
   pd = (double *)mxGetData(pa);
   *pd = attr;

   return pa;
}


/*-----------------------------------------------------------------*/
 
static mxArray* 
read_propvalue(FILE *fob, int rlen)
{
   char propname[256];

   if ( read_string(fob, propname, rlen) )
      mexErrMsgTxt("read_propvalue :  read failed.");

   return mxCreateString(propname);
}


/*-----------------------------------------------------------------*/

static mxArray* 
resize_property_structure(mxArray *pprop, int size)
{
   mxArray *newpprop;
   mxArray *pattr, *pvalue;
   int nump, k;
   const char *fields[] = {"attr","name"};

   /* new structure array */
   newpprop = mxCreateStructMatrix(1,size, 2, fields);

   /* copy over the old structure array */
   if (pprop == NULL)
      nump = 0; /* first one */
   else
      nump = mxGetM(pprop) * mxGetN(pprop);
   for (k=0; k<nump; k++) {
      pattr  = mxGetFieldByNumber(pprop, k, 0);
      pvalue = mxGetFieldByNumber(pprop, k, 1);
      mxSetFieldByNumber(newpprop, k, 0, pattr);
      mxSetFieldByNumber(newpprop, k, 1, pvalue);
   }

   /* destroy the old structure array */
   if (pprop != NULL)
      mxDestroyArray(pprop);

   return newpprop;
}


/*-----------------------------------------------------------------*/

static void 
read_colrow(FILE *fob, uint16_t *row, uint16_t *col)
{
    uint16_t colrow[2];

    if ( read_word_n(fob, colrow, 2) )
       mexErrMsgTxt("read_colrow :  read failed.");

    *row = colrow[1];
    *col = colrow[0];
}


/*-----------------------------------------------------------------*/

static void 
init_element(element_t *elm, element_kind kind)
{
   memset(elm, '\0', sizeof(element_t)); 
   elm->kind = kind;  
}

/*-----------------------------------------------------------------*/
 
