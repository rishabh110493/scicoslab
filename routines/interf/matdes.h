#ifndef MATDES_SCI 
#define MATDES_SCI 

#ifdef WITH_MALLOC_FPTR 
#if WIN32
#if _MSC_VER <=1200
#define hstk(x) (*((double **) &C2F(stack).stkptr))) + x-1 )
#else
#define hstk(x) (((long long *) (*((double **) &C2F(stack).stkptr))) + x-1 )
#endif
#else
#define hstk(x) (((long long *) (*((double **) &C2F(stack).stkptr))) + x-1 )
#endif
#else /* MALLOC_FPTR */
#if WIN32
#if _MSC_VER <=1200
#define hstk(x) ((C2F(stack).Stk) + x-1 )
#else
#define hstk(x) (((long long *)C2F(stack).Stk) + x-1 )
#endif
#else
#define hstk(x) (((long long *)C2F(stack).Stk) + x-1 )
#endif
#endif /* MALLOC_FPTR */
#endif /* MATDES_SCI */

