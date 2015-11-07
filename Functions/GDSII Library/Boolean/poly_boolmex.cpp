// A mex interface to the Clipper library
// for the GDS II toolbox
// 
// [pc, hf] =  = poly_boolmex(pa, pb, op, ud);
//
// pa :  cell array with polygons (nx2 matrices)
// pb :  polygon b, an nx2 matrix
// op :  polygon operation
// ud :  conversion factor for conversion from user
//       coordinates to database coordinates
// pc :  a cell array containing one or more polygons that result
//       from applying the polygon operation to each (pair pa{k}, pb).
// hf :  hole flag array; when hf(k)==1, pc{k} is the interior boundary
//       of a hole.
//
// polygon operations are:
//   'and' :  polygon intersection
//   'or' :   polygon union
//   'notb' : polygon difference
//   'xor' :  polygon union minus polygon difference
//
// Ulf Griesmann, NIST, November 2012

// NOTE:
// C++ memory management in mex functions is a nightmare. In C,
// calls to malloc can simply be redirected to mxMalloc etc., but in C++, 
// memory management is baked into the language. I am not sure that 
// all memory allocated by the Clipper library is freed, and memory 
// leaks are possible. Need to keep an eye on this ... 

#include <math.h>
#include "mex.h"
#include "clipper.hpp"

#define STR_LEN    8


//-----------------------------------------------------------------

using namespace ClipperLib;

// declare static to avoid memory leaks when the mex function exits
static Paths pa, pb, pc;
static Clipper C;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mxArray *par;         // ptr to mxArray structure 
	double *pda;          // ptr to polynomial data
	double *pud;          // pointer to unit conversion factor
	mxLogical *ph;        // pointer to hole flags
	double ud, iud;
	unsigned int Na, Nb, vnu;
	unsigned int k, m;
	ClipType pop;
	char ostr[STR_LEN];   //string with polygon operation
	unsigned int maxVerticles = 8000;

	C.StrictlySimple(true);

	//////////////////
	// check arguments
	//

	// argument number
	if (nrhs != 4) {
		mexErrMsgTxt("polyboolmex :  expected 4 input arguments.");
	}

	// argument pa
	if (!mxIsCell(prhs[0])) {
		mexErrMsgTxt("polyboolmex :  argument pa must be a cell array.");
	}
	Na = mxGetM(prhs[0])*mxGetN(prhs[0]);
	if (!Na) {
		mexErrMsgTxt("polyboolmex :  no input polygons pa.");
	}

	// argument pb
	if (!mxIsCell(prhs[1])) {
		mexErrMsgTxt("polyboolmex :  argument pb must be a cell array.");
	}
	Nb = mxGetM(prhs[1])*mxGetN(prhs[1]);
	if (!Nb) {
		mexErrMsgTxt("polyboolmex :  no input polygons pb.");
	}

	// get operation argument
	mxGetString(prhs[2], ostr, STR_LEN);
	if (!strncmp(ostr, "or", 2))
		pop = ctUnion;
	else if (!strncmp(ostr, "and", 3))
		pop = ctIntersection;
	else if (!strncmp(ostr, "notb", 4))
		pop = ctDifference;
	else if (!strncmp(ostr, "xor", 3))
		pop = ctXor;
	else {
		mexErrMsgTxt("polyboolmex :  unknown boolean set algebra operation.");
	}

	// conversion factor argument
	pud = (double*)mxGetData(prhs[3]);
	ud = *pud;
	iud = 1.0 / ud;


	////////////////////////
	// copy and prepare data
	//

	// pa
	pa.resize(Na);
	for (k = 0; k < Na; k++) {

		// get the next polygon from the cell array 
		par = mxGetCell(prhs[0], k);   // ptr to mxArray
		if (mxIsEmpty(par)) {
			mexErrMsgTxt("poly_boolmex :  empty polygon in pa.");
		}
		pda = (double*)mxGetData(par); // ptr to a data     
		vnu = mxGetM(par);             // rows = vertex number

		// copy polygon and transpose, scale
		pa[k].resize(vnu);
		for (m = 0; m < vnu; m++) {
			pa[k][m].X = (cInt)floor(ud * pda[m] + 0.5);
			pa[k][m].Y = (cInt)floor(ud * pda[m + vnu] + 0.5);
		}

		// make sure polygons have positive orientation
		if (!Orientation(pa[k]))
			ReversePath(pa[k]);
	}

	// pb
	pb.resize(Nb);
	for (k = 0; k < Nb; k++) {

		// get the next polygon 
		par = mxGetCell(prhs[1], k);   // ptr to mxArray
		if (mxIsEmpty(par)) {
			mexErrMsgTxt("poly_boolmex :  empty polygon in pb.");
		}
		pda = (double*)mxGetData(par); // ptr to a data     
		vnu = mxGetM(par);             // rows = vertex number

		// copy polygon and transpose, scale
		pb[k].resize(vnu);
		for (m = 0; m < vnu; m++) {
			pb[k][m].X = (cInt)floor(ud * pda[m] + 0.5);
			pb[k][m].Y = (cInt)floor(ud * pda[m + vnu] + 0.5);
		}

		// make sure polygons have positive orientation
		if (!Orientation(pb[k]))
			ReversePath(pb[k]);
	}


	////////////////////
	// clip the polygons
	//
	C.AddPaths(pa, ptSubject, true);
	C.AddPaths(pb, ptClip, true);

	if (!C.Execute(pop, pc, pftNonZero, pftNonZero))
		mexErrMsgTxt("polyboolmex :  Clipper library error.");

	//////////////////////////////////////////
	// create a cell array for output argument
	//
	plhs[0] = mxCreateCellMatrix(1, pc.size());

	//////////////////////////
	// return clipping results
	//
	for (k = 0; k < pc.size(); k++) {

		// allocate matrix for boundary
		vnu = pc[k].size();
		par = mxCreateDoubleMatrix(vnu, 2, mxREAL);
		pda = (double*)mxGetData(par);

		// copy vertex array, transpose, and scale back to user units
		for (m = 0; m < vnu; m++) {
			pda[m] = iud * pc[k][m].X;
			pda[vnu + m] = iud * pc[k][m].Y;
		}

		// store in cell array
		mxSetCell(plhs[0], k, par);
	}

	///////////////////
	// return hole flags
	//
	plhs[1] = mxCreateLogicalMatrix(1, pc.size());
	ph = (mxLogical*)mxGetData(plhs[1]);
	for (k = 0; k < pc.size(); k++)
		ph[k] = !Orientation(pc[k]); // same as input == no hole

	 ///////////////////
	 // clean up
	 //
	C.Clear();
	pa.resize(0);
	pb.resize(0);
	pc.resize(0);
}

