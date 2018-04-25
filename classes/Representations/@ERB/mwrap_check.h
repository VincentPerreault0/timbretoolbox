/* 
* stuff to allow checking with mwrap
* 
*/

#include "mwrap.h"

void checkin_matrix(mxArray *m);
void checkout_matrix(mxArray *m);

/* check matrix into mwrap's tree */
void checkin_matrix(mxArray *m) 
{
	char *base, *top;
	
	base = (char *) mxGetPr(m);
	top = base + mxGetN(m) * mxGetM(m) * sizeof(double);
	/* mexPrintf("%d %d\n", base, top); */
	CHECKIN(base, top); 
}

/* check matrix out of mwrap's tree */
void checkout_matrix(mxArray *m) 
{
	char *base;
	
	base = (char *) mxGetPr(m);
	CHECKOUT(base); 
}
