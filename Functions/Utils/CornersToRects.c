
/*_________________________________________________________________________
 *
 * MEX Script
 * File Creation : Nicolas Ayotte, May 2014
 * CornersToRects.c
 * _________________________________________________________________________*/


#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
  // Declare variables
  int nz, j;
  double *x1, *x2, *y1, *y2;
  mxArray *mat, *p;
  double *pr, *pd;
  
  // Get the number of elements in the input argument
  nz = mxGetNumberOfElements(prhs[0]);
  
  // Get input pointer
  x1 = (double *)mxGetData(prhs[0]);
  x2 = (double *)mxGetData(prhs[1]);
  y1 = (double *)mxGetData(prhs[2]);
  y2 = (double *)mxGetData(prhs[3]);
  
  // Get output pointer
  plhs[0] = mxCreateCellMatrix(1, (mwSize)nz);
  
  // Initialize output
  mat = mxCreateDoubleMatrix(5, 2, mxREAL);
  pr = (double *)mxGetData(mat);
   
  for (j=0; j<nz; j++)
  {

     pr[0] = (double)x1[j];
     pr[3] = (double)x1[j];
     pr[4] = (double)x1[j];
     
     pr[1] = (double)x2[j];
     pr[2] = (double)x2[j];
     
     pr[5] = (double)y1[j];
     pr[6] = (double)y1[j];
     pr[9] = (double)y1[j];

     pr[7] = (double)y2[j];
     pr[8] = (double)y2[j];
     
     mxSetCell(plhs[0], j, mxDuplicateArray(mat));
  }
  return;
}

