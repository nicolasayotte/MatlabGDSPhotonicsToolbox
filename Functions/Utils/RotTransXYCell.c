
/*_________________________________________________________________________
 *
 * MEX Script
 * File Creation : Nicolas Ayotte, May 2014
 * CornersToRects.cpp
 * _________________________________________________________________________*/


#include "mex.h"
#include <math.h>

#define M_PI 3.14159265358979323846

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// Declare variables
	size_t cellSize, matSize;
	mwIndex cellIndex, matIndex;
	mxArray *mat, *opos;
	double *pr, *pos, *ori, *po;
    double c, s;

	// Get the number of elements in the input argument
	cellSize = mxGetNumberOfElements(prhs[0]);

	// Get the input pointer
	pos = (double *)mxGetData(prhs[1]);
	ori = (double *)mxGetData(prhs[2]);
	ori[0] = ori[0] * M_PI / 180;
    c = cos(ori[0]);
    s = sin(ori[0]);

	// Get output pointer
	plhs[0] = mxCreateCellMatrix(1, (int) cellSize);

	// Initialize output
	for (cellIndex = 0; cellIndex < cellSize; cellIndex++)
	{
		mat = mxGetCell(prhs[0], cellIndex);
		pr = (double *)mxGetData(mat);

		matSize = mxGetM(mat);
		opos = mxCreateDoubleMatrix(matSize, 2, mxREAL);
		po = (double *)mxGetData(opos);

		for (matIndex = 0; matIndex < matSize; matIndex++)
		{
			po[matIndex] = pr[matIndex] * c - pr[matIndex + matSize] * s + pos[0];
			po[matIndex + matSize] = pr[matIndex] * s + pr[matIndex + matSize] * c + pos[1];
		}
		mxSetCell(plhs[0], cellIndex, mxDuplicateArray(opos));
	}

	return;
}

