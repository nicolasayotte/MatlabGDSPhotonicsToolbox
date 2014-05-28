/*
 * A mex function to compute the orientation of polygons
 * for the GDS II toolbox
 * 
 * [cw] = poly_iscw(pa);
 *
 * pa :  cell array of polygons (nx2 matrices)
 * cw :  1xn logical vector of orientations
 *
 * Ulf Griesmann, NIST, November 2012
 */

#include <math.h>
#include <string.h>
#include "mex.h"


/*-- local prototypes -----------------------------------------*/

static int
clock_wise(double *p, int N);


/*-------------------------------------------------------------*/

void 
mexFunction(int nlhs, mxArray *plhs[], 
	    int nrhs, const mxArray *prhs[])
{
   mxArray *par;               /* pointer to array structure */
   double *pda;                /* polynom data */
   mxLogical *pout;            /* pointer to output data */
   int ma;
   int k, Na;

   /* check argument pa */
   if ( !mxIsCell(prhs[0]) ) {
      mexErrMsgTxt("poly_iscwmex :  argument must be a cell array.");
   }
   Na = mxGetNumberOfElements(prhs[0]);
   if (!Na) {
      mexErrMsgTxt("poly_iscwmex :  no input polygons pa.");
   }

   /* create output array */
   plhs[0] = mxCreateLogicalMatrix(1, Na);
   pout = (mxLogical *)mxGetData(plhs[0]);

   /*
    * copy and prepare data
    */

   /* pa */
   for (k=0; k<Na; k++) {

      /* get the next polygon from the cell array */ 
      par = mxGetCell(prhs[0], k); /* ptr to mxArray */
      pda = mxGetData(par);        /* ptr to a data */     
      ma  = mxGetM(par);           /* rows = vertex number */

      /* calculate orientation */
      pout[k] = (mxLogical)clock_wise(pda, ma);
   }
}


/* Return the clockwise status of a curve, clockwise or counterclockwise
 * N vertices making up curve p.
 * It is assumed that
 * - the polygon is closed
 * - the last point is not repeated.
 * - the polygon is simple (does not intersect itself or have holes)
 *
 * Algorithm from Paul Bourke, http://paulbourke.net/geometry/polygonmesh/
 */
int 
clock_wise(double *p, int N)
{
   int i,j,k,n;
   int count = 0;
   double z;

   /* check if too few vertices */
   if (N < 3)
      mexErrMsgTxt("poly_iscwmex :  polygons must have at lest 3 vertices.");

   /* check if the last vertex repeats the first */
   n = N;
   if ((p[0] == p[N-1]) && (p[N] == p[2*N-1]))
      n = N-1;

   /* calculate cross products */
   for (i=0;i<n;i++) {
      j = (i + 1) % n;
      k = (i + 2) % n;
      z  = (p[j] - p[i]) * (p[N+k] - p[N+j]) -
           (p[k] - p[j]) * (p[N+j] - p[N+i]);
      if (z < 0)
         count--;
      else if (z > 0)
         count++;
   }
   if (count > 0)
      return 1;
   else
      return 0;
}
