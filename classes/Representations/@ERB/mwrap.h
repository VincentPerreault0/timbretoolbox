/* 
19 Dec 94 - Sept 95
Alain de Cheveigne, LLF, CNRS/Universite Paris 7.
Modified: Sept 2000

file mwrap.h

To use the malloc wrappers: 
- include this file in all source files that call malloc routines, 
- link with mwrap.o,
- compile all files with -DMWRAP to turn on wrapping and checking. 

*/

#ifndef MWRAP_H
#define MWRAP_H

#include <stdio.h>
#include <stdlib.h>

/* NOTE: (char *) is used for pointer arithmetic.  
   Pointer arguments of all macros are cast to (char *). */

/* node structure for binary splay tree */
typedef struct mwrap_node_struct *mwrap_node ;
struct mwrap_node_struct {
  char *lo;			/* base of block */
  char *hi;			/* one beyond last address in block */
  mwrap_node up;
  mwrap_node left;
  mwrap_node right;
};


/* Abbreviations for macros.  Change in case of conflict.

	Assignment macros:
   GET(x)		equivalent to 'x' on a rhs, but memory address is checked before access
   SET(x)		equivalent to 'x' on a lhs, but memory address is checked before assignment
   CPY(p,q,n)	copy n values starting from p to n values starting from q, after checking both

	Test macros:
   POK(p)      pointer p is within an allocated block.
   BOK(b)      pointer b is the base of an allocated block.
   PQOK(p, q)  pointers p and q are in same allocated block.
   PBOK(p, b)  pointer p is in block of base b. 

   MWRAPOK()    check internal tree for sanity (slow)

	Query macros:
   PBASE(p)    base of block containing p, NULL if there is none.
   PBUMP(p)		one beyond last byte of block.
   PSIZE(p)    size of block containing p, -1 if none.

	Explicit block registering macros. 
   CHECKIN(lo, hi)  register block of bounds lo, hi
   CHECKOUT(lo)     unregister block of base lo
   
*/

#define GET(x) MWRAP_GET(x)
#define SET(x) MWRAP_SET(x)
#define CPY(p,q,n) MWRAP_CPY(p,q,n)
#define POK(p) MWRAP_POK(p)
#define BOK(b) MWRAP_BOK(b)
#define PQOK(p,q) MWRAP_PQOK((p),(q))
#define PBOK(p,b) MWRAP_PBOK((p),(b))
#define MWRAPOK() MWRAP_MWRAPOK()
#define PBASE(p) MWRAP_PBASE(p)
#define PSIZE(p) MWRAP_PSIZE(p)
#define CHECKIN(lo, hi)  MWRAP_CHECKIN((lo), (hi))
#define CHECKOUT(lo)     MWRAP_CHECKOUT(lo)


/* 	Definitions of macros.  
	All are conditional on MWRAP being defined. 
   	For speed, macros check for a "lucky" hit (block already
   	at root) before handing over to functions. */

#ifdef MWRAP	

#define MWRAP_GET(x) \
	( (MWRAP_POK(&x)) ? (x) : (x) )
	
#define MWRAP_SET(x) \
	MWRAP_POK(&x) ; (x)
	
#define MWRAP_CPY(p, q, n) \
	do {int i; \
		MWRAP_PQOK((p),(p)+(n-1)); \
		MWRAP_PQOK((q),(q)+(n-1)); \
		for(i=0;i<n;i++) (q)[i]=(p)[i]; \
	} while(0)

/* #define MWRAP_POK(p) \
	do { if (mwrap_tree \
 		&& (char *) (p) >= mwrap_tree->lo  \
 		&& (char *) (p) < mwrap_tree->hi) break; \
	mwrap_pok((char *) (p), __FILE__, __LINE__); } while (0) */
	
#define MWRAP_POK(p) \
	((mwrap_tree && (char *) (p) >= mwrap_tree->lo && (char *) (p) <mwrap_tree->hi) ? \
		1 : mwrap_pok((char *) (p), __FILE__, __LINE__))
	

/* #define MWRAP_BOK(b) \
	do { if (mwrap_tree \
 		&& (char *) (b) == mwrap_tree->lo) break; \
 	mwrap_bok((char *) (b), __FILE__, __LINE__);	} while (0) */

#define MWRAP_BOK(b) \
	((mwrap_tree && (char *) (b) == mwrap_tree->lo) ? 1 : mwrap_bok((char *) (b), __FILE__, __LINE__))


/* #define MWRAP_PQOK(p, q) \
	do { if (mwrap_tree \
		&& (char *) (p) >= mwrap_tree->lo \
 		&& (char *) (p) < mwrap_tree->hi \
 		&& (char *) (q) >= mwrap_tree->lo \
 		&& (char *) (q) < mwrap_tree->lo) break; \
 	mwrap_pqok((char *)(p), (char *)(q), __FILE__, __LINE__); } while (0) */

#define MWRAP_PQOK(p,q) \
	((mwrap_tree \
	&& (char *) (p) >= mwrap_tree->lo \
	&& (char *) (p) < mwrap_tree->hi \
	&& (char *) (q) >= mwrap_tree->lo \
	&& (char *) (q) < mwrap_tree->lo ) ? \
	1 : mwrap_pqok((char *)(p), (char *)(q), __FILE__, __LINE__))

/* #define MWRAP_PBOK(p, b) \
	do { if (mwrap_tree \
		&& (char *) (b) == mwrap_tree->lo \
 		&& (char *) (p) >= mwrap_tree->lo \
 		&& (char *) (p) < mwrap_tree->lo) break; \
 	mwrap_pbok((char *)(p), (char *)(b), __FILE__, __LINE__); } while (0) */

#define MWRAP_PBOK(p, b) \
	(( mwrap_tree \
		&& (char *) (b) == mwrap_tree->lo \
 		&& (char *) (p) >= mwrap_tree->lo \
 		&& (char *) (p) < mwrap_tree->lo) ? \
		1 : mwrap_pbok((char *)(p), (char *)(b), __FILE__, __LINE__))

#define MWRAP_MWRAPOK() mwrap_checktree(__FILE__, __LINE__)

#define MWRAP_PBASE(p) mwrap_pbase((char *) p)
#define MWRAP_PBUMP(p) mwrap_pbump((char *) p)
#define MWRAP_PSIZE(p) mwrap_psize((char *) p)
#define MWRAP_CHECKIN(lo, hi) \
        mwrap_checkin((char *) (lo), (char *) (hi), __FILE__, __LINE__)
#define MWRAP_CHECKOUT(lo) \
        mwrap_checkout( (char *) (lo), __FILE__, __LINE__)

#else

#define MWRAP_GET(x) (x)
#define MWRAP_SET(x) (x)
#define MWRAP_CPY(p,q,n) 
#define MWRAP_POK(p) 
#define MWRAP_BOK(p)
#define MWRAP_PBOK(p,b)
#define MWRAP_PQOK(p,q)
#define MWRAP_MWRAPOK() 
#define MWRAP_PBASE(p) (void *) mwrap_squeal(__FILE__, __LINE__)
#define MWRAP_PBUMP(p) (void *) mwrap_squeal(__FILE__, __LINE__)
#define MWRAP_PSIZE(p) (long) mwrap_squeal(__FILE__, __LINE__)
#define MWRAP_CHECKIN(lo, hi)
#define MWRAP_CHECKOUT(lo)
#endif 


/* Wrapping macros.
   
   If MWRAP is defined, all malloc routines are wrapped and the 
   original routines are available as "nowrap_malloc()", etc..

   If MWRAP is not defined, malloc routines are not wrapped
   and "nowrap_malloc()", etc. are #defined to "malloc()", etc. 
*/
   
#ifdef MWRAP

#ifndef MWRAP_C			
#define malloc(size)     mwrap_malloc((size), __FILE__, __LINE__)
#define free(p)          mwrap_free((p), __FILE__, __LINE__)
#define realloc(p, size) mwrap_realloc((p), (size), __FILE__, __LINE__)
#define calloc(n, size)  mwrap_calloc((n), (size), __FILE__, __LINE__)
#define cfree(p)         mwrap_cfree((p), __FILE__, __LINE__)
#define valloc(size)     mwrap_valloc((size), __FILE__, __LINE__)
#define vfree(p)         mwrap_vfree((p), __FILE__, __LINE__)
#define memalign(a, p)   mwrap_memalign((a), (p), __FILE__, __LINE__)
#endif /* MWRAP_C */

#else

#ifndef MWRAP_C
#define nowrap_malloc(size)     malloc(size)
#define nowrap_free(p)          free(p)
#define nowrap_realloc(p, size) realloc(p)
#define nowrap_calloc(n, size)  calloc((n), (size))
#define nowrap_cfree(p)         cfree(p)
#define nowrap_valloc(size)     valloc(size)
#define nowrap_vfree(p)         vfree(p)
#define nowrap_memalign(a, p)   memalign((a), (p))
#endif /* MWRAP_C */

#endif /* MWRAP */


/* three global variables */

#ifndef MWRAP_C				  
extern mwrap_node mwrap_tree;	/* the tree */
extern char *mwrap_file;		/* caller source file */
extern long mwrap_line;		/* line in caller source file */
#endif				


/* Data types used by malloc library. Modify if necessary */
typedef void DATATYPE;		/* returned by malloc(), etc. */
typedef size_t SIZETYPE;	/* fed to malloc(), etc. */
typedef void VOIDTYPE;		/* returned by free(), etc. */


/* prototypes of routines made public */

/* malloc wrappers */
DATATYPE *mwrap_malloc(SIZETYPE size, char *file, long line);
VOIDTYPE mwrap_free(DATATYPE *p, char *file, long line);
DATATYPE *mwrap_realloc(DATATYPE *p, SIZETYPE size, char *file, long line);
DATATYPE *mwrap_calloc(SIZETYPE n, SIZETYPE size, char *file, long line);
VOIDTYPE mwrap_cfree(DATATYPE *p, char *file, long line);
DATATYPE *mwrap_valloc(SIZETYPE size, char *file, long line);
VOIDTYPE mwrap_vfree(DATATYPE *p, char *file, long line);
DATATYPE *mwrap_memalign(SIZETYPE alignment, SIZETYPE size, char *file, long line);

/* unwrapped versions */
#ifdef MWRAP
DATATYPE *nowrap_malloc(SIZETYPE size);
VOIDTYPE nowrap_free(DATATYPE *p);
DATATYPE *nowrap_realloc(DATATYPE *p, SIZETYPE size);
DATATYPE *nowrap_calloc(SIZETYPE n, SIZETYPE size);
VOIDTYPE nowrap_cfree(DATATYPE *p);
DATATYPE *nowrap_valloc(SIZETYPE size);
VOIDTYPE nowrap_vfree(DATATYPE *p);
DATATYPE *nowrap_memalign(SIZETYPE alignment, SIZETYPE size);
#endif

/* explicit block registering */
void mwrap_checkin(char *lo, char *hi, char *file, long line);
void mwrap_checkout(char *lo, char *file, long line);

/* tests & queries */
int mwrap_pok(char *p, char *file, long line);
int mwrap_bok(char *b, char *file, long line);
int mwrap_pqok(char *p, char *q, char *file, long line);
int mwrap_pbok(char *p, char *b, char *file, long line);
char *mwrap_pbase(char *p);
char *mwrap_pbump(char *p);
long mwrap_psize(char *p);
long mwrap_squeal(char *file, long line);

#endif
