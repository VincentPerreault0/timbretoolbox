/* 
* rsmooth.c
* smooth columnwise by convolution by a running square window
* multiple passes allowed (--> triangular, gaussian, etc.)
* 
* Alain de Cheveigné, CNRS Ircam, Dec 2001.
* (c) CNRS 2001.
*/

#include <math.h>
#include "mex.h"

/* #define MWRAP */
#include "mwrap_check.h"

/* Input Arguments */

#define X_IN	prhs[0]
#define SMOOTH_IN prhs[1]
#define NPASSES_IN	prhs[2]
#define CLIP_IN prhs[3]

/* Output Arguments */

#define Y_OUT plhs[0]

static void runsmooth(
						double *xp,
						int smooth,
						int npasses,
						double *yp,
						int m,
						int n,
						int clip
						)
{
	int h,i,j,k,mm;
	double *work1, *work2, *a, *b, *tmp, sum;
		
	mm = m + smooth + npasses*(smooth-1);		/* nrows of work buffer */
	work1 = (double *) mxCalloc(mm*n,sizeof(double));
	work2 = (double *) mxCalloc(mm*n,sizeof(double));
	
	CHECKIN(work1, (char *) work1 + sizeof(double)*mm*n);
	CHECKIN(work2, (char *) work2 + sizeof(double)*mm*n);
		
	a = work1;
	b = work2;
		
	/* transfer data to buffer, preceded with leading zeros */	 
	for (k=0; k<n; k++) {
		for (j=0;j<m;j++) {
			SET(a[ j+smooth+mm*k ]) = GET(xp[ j+m*k ]);
		}
	}
		
	/* smooth repeatedly */
	for (h=0;h<npasses;h++) {
	  for (k=0; k<n; k++) {	/* for each column */
			sum=0;
			for (j=smooth;j<mm;j++) {	/* for each row (inner loop) */
				sum += - GET(a[j-smooth+mm*k]) + GET(a[j+mm*k]);
				SET(b[j+mm*k]) = sum/smooth;
			}
		}
		tmp=a; a=b; b=tmp;	/* swap for next round */
	}
				
	/* transfer to output matrix */
	if (clip) {
		for (j=0;j<m;j++) {
			for (k=0; k<n; k++) {
				 SET(yp[j+m*k]) = GET(a[ j+(int)(npasses*(smooth-1)/2)+smooth + mm*k]);			 
			}
		}
	} else {
		for (j=0;j<m+npasses*(smooth-1);j++) {
			for (k=0; k<n; k++) {
				 SET(yp[j+(m+npasses*(smooth-1))*k]) = GET(a[j + smooth + mm*k]);			 
			}
		}
	}
	CHECKOUT(work1);
	CHECKOUT(work2);
	
}

void mexFunction(
				int nlhs, mxArray *plhs[],
				int nrhs, const mxArray *prhs[]
							)
{
	double	*xp, *yp;
	int m,n,npasses,smooth,clip;
	
	/* Check for proper number of arguments */
	if (nrhs > 4 || nrhs < 2) {
		mexErrMsgTxt("RSMOOTH takes at least 2 and most 4 input arguments");
	} else if (nlhs > 1) {
		mexErrMsgTxt("RSMOOTH allows at most 1 output argument");
	}
	
	/* Check type of input */
	m = mxGetM(X_IN); /* rows */
	n = mxGetN(X_IN); /* columns */ 
	if (!mxIsNumeric(X_IN) || mxIsComplex(X_IN) || 
			mxIsSparse(X_IN) || !mxIsDouble(X_IN) || m<=1) {
		mexErrMsgTxt("RSMOOTH: X should be a column vector or matrix of doubles");
	}
 
	if (mxGetM(SMOOTH_IN)*mxGetN(SMOOTH_IN) > 1 || mxGetPr(SMOOTH_IN)[0] <1) {
		mexErrMsgTxt("RSMOOTH: SMOOTH should be a positive scalar");
	}	 
	smooth = mxGetPr(SMOOTH_IN)[0];
	
	if (nrhs > 2) {
		npasses = mxGetPr(NPASSES_IN)[0];
		if (mxGetM(NPASSES_IN)*mxGetN(NPASSES_IN) > 1 || npasses <1) {
			mexErrMsgTxt("RSMOOTH: NPASSES should be a positive scalar");
		} 
	} else {
		npasses=1;
	}
	
	if (nrhs > 3) {
		clip=1; 
	} else {
		clip=0;
	}
	
	/* Create matrix to return */
	if (clip) {
		Y_OUT = mxCreateDoubleMatrix(m, n, mxREAL); 
	} else {
		Y_OUT = mxCreateDoubleMatrix(m+npasses*(smooth-1), n, mxREAL); 
	}
		
	/* Assign pointers to the various parameters */
	xp = mxGetPr(X_IN);
	yp = mxGetPr(Y_OUT);
	
	checkin_matrix((mxArray *) X_IN);
	checkin_matrix(Y_OUT);
	
	/* Do the actual computations in a subroutine */
	runsmooth(xp,smooth,npasses,yp, m,n,clip);
 
	checkout_matrix((mxArray *) X_IN);
	checkout_matrix(Y_OUT);
	return;
}


