#ifdef __cplusplus
extern "C" {
#endif

#ifndef SCI_MEX 
#define SCI_MEX 

#ifdef WIN32
	#include <stddef.h> /*for LCC */
#endif

#include "stack-c.h"

typedef int Matrix;
typedef unsigned long int vraiptrst;
typedef int mxArray;

typedef int (*GatefuncH) (int nlhs,mxArray *plhs[],int nrhs,
				   mxArray *prhs[]);

typedef int (*FGatefuncH) (int *nlhs,mxArray *plhs[],int *nrhs,
				    mxArray *prhs[]);

typedef int Gatefunc (int nlhs,mxArray *plhs[],int nrhs,
			       mxArray *prhs[]);
  typedef int (*GatefuncS) (char *fname, int l);
  typedef int (*Myinterfun) (char *, GatefuncH F);

typedef int (*GT) ();

typedef struct table_struct {
  Myinterfun f;    /** interface **/
  GT F;     /** function **/
  char *name;      /** its name **/
} GenericTable;

#define mxLOGICAL int
#define mxLogical int

#define REAL 0
#define COMPLEX 1

#ifndef NULL
#define NULL 0
#endif

#define mxCreateFull mxCreateDoubleMatrix
#define mxCreateScalarDouble mxCreateDoubleScalar

#ifndef bool
#define bool int
#endif 

#define mexGetMatrixPtr(name) mexGetArrayPtr(name, "caller")
#define mexGetArrayPtr(name,type) mexGetArray(name,type) 
#define mexMakeArrayPersistent(x) (x=mexMakeArrayPersist(x))

#ifdef __STDC__ 
void mexPrintf (const char *fmt,...);
#else 
void  mexPrintf (); 
#endif

/* Put a matrix in Scilab Workspace */ 

#define mexPutFull(name,m,n,ptrM,tag)					\
  if ( ! C2F(cwritemat)(name,(c_local=m,&c_local),(c1_local=n,&c1_local),ptrM,strlen(name))) \
    {									\
      mexErrMsgTxt("mexPutFull failed\r\n");return;			\
    }
  
/* prototypes */

void mexInfo (char *); 
int mexCheck (char *,int ); 
mxArray *mxCreateCharMatrixFromStrings (int m, const char **str);
mxArray *mxCreateString (const char *string);
mxArray *C2F(mxcreatestring)  (char *string, long int l);
mxArray *C2F(mxcreatefull)  (int *m, int *n, int *it);
/* mxArray *mxCreateFull (int m, int n, int it); */
mxArray *mxCreateCharArray (int ND, const int *size);

mxArray *mxCreateCellArray (int ND, const int *size);
mxArray *mxCreateCellMatrix (int m, int n);

mxArray *mxCreateStructArray (int ndim, const int *dims, int nfields, const char **field_names);
mxArray *mxCreateStructMatrix (int m, int n, int nfields, const char **field_names);


mxArray *mxGetCell (const mxArray *ptr, int index);

extern double C2F(mxgetscalar)  (mxArray *ptr);
extern double * C2F(mxgetpi)  (mxArray *ptr);
extern double * C2F(mxgetpr)  (mxArray *ptr);
extern double *mxGetPi (const mxArray *ptr);
extern double *mxGetPr (const mxArray *ptr);
extern double mxGetScalar (const mxArray *ptr);
extern double mxGetInf (void);
extern double mxGetNaN (void);
extern double mxGetEps (void);
extern bool mxIsNaN (double x);
extern bool mxIsInf (double x);
extern bool mxIsFinite (double x);
extern int *mxGetDimensions (const mxArray *ptr);
extern int mxCalcSingleSubscript (const mxArray *ptr, int nsubs, const int *subs);
extern int mxGetNumberOfElements (const mxArray *ptr);
extern int mxGetNumberOfDimensions (const mxArray *ptr);
extern int mxGetNumberOfFields (const mxArray *ptr);
extern void *mxGetData (const mxArray *ptr);
extern void *mxGetImagData (const mxArray *ptr);
extern void diary_nnl (char *str,int *n);
extern int getdiary ();

extern int C2F(createptr) (char *type,integer * m,integer * n, integer *it,integer * lr,
			   integer *ptr, long int type_len);
extern int C2F(createstkptr) (integer *m, vraiptrst *ptr);
extern int C2F(endmex)  (integer *nlhs,mxArray *plhs[],integer *nrhs,mxArray *prhs[]);

extern void clear_mex(integer nlhs, mxArray **plhs, integer nrhs, mxArray **prhs);

extern int C2F(getrhsvar) (integer *, char *, integer *, integer *, integer *, long unsigned int);
extern int C2F(initmex) (integer *nlhs,mxArray *plhs[],integer *nrhs,mxArray *prhs[]);
extern int C2F(putlhsvar) (void);
extern void errjump (void);
extern void sciprint (char *fmt,...);
extern vraiptrst C2F(locptr) ( void *x);
extern  int  C2F(mxgetm)  (mxArray *ptr);
extern  int  C2F(mxgetn)  (mxArray *ptr);
extern  int  C2F(mxgetstring)  (mxArray *ptr, char *str, int *strl);
extern  int  C2F(mxiscomplex)  (mxArray *ptr);
extern  int  C2F(mxisfull)  (mxArray *ptr);
extern  int  C2F(mxisnumeric)  (mxArray *ptr);
extern  int  C2F(mxissparse)  (mxArray *ptr);
extern  int  C2F(mxisstring)  (mxArray *ptr);
extern  int *mxGetIr (const mxArray *ptr);
extern  int *mxGetJc (const mxArray *ptr);
extern  int C2F(createptr)  (char *type, int *m, int *n, int *it, int *lr, int *ptr, long int type_len);
extern  int C2F(createstkptr)  (integer *m, vraiptrst *ptr);
extern  int C2F(endmex)  (integer *nlhs, mxArray **plhs, integer *nrhs, mxArray **prhs);
extern  int C2F(initmex)  (integer *nlhs, mxArray **plhs, integer *nrhs, mxArray **prhs);
extern  int C2F(mexcallscilab)  (integer *nlhs, mxArray **plhs, integer *nrhs, mxArray **prhs, char *name, int namelen);
extern  int C2F(mxcopyptrtoreal8)  (mxArray *ptr, double *y, integer *n);
extern  int C2F(mxcopyreal8toptr)  (double *y, mxArray *ptr, integer *n);
extern  int fortran_mex_gateway (char *fname, FGatefuncH F);
extern  int mexAtExit (mxArray *ptr);
extern  int mexCallSCILAB (int nlhs, mxArray **plhs, int nrhs, mxArray **prhs, const char *name);
extern  int mexCallMATLAB (int nlhs, mxArray **plhs, int nrhs, mxArray **prhs, const char *name);
extern  int mex_gateway (char *fname, GatefuncH F);
extern  int mxGetElementSize (const mxArray *ptr);
extern  int mxGetM (const mxArray *ptr);
extern  int mxGetN (const mxArray *ptr);
extern  int mxGetNzmax (const mxArray *ptr);
extern  int mxGetString (const mxArray *ptr, char *str, int strl);
extern  char *mxArrayToString (const mxArray *array_ptr);
extern  bool mxIsComplex (const mxArray *ptr);
extern  bool mxIsDouble (const mxArray *ptr);
extern  bool mxIsSingle (const mxArray *ptr);
extern  bool mxIsFull (const mxArray *ptr);
extern  bool mxIsNumeric (const mxArray *ptr);
extern  bool mxIsSparse (const mxArray *ptr);
extern  bool mxIsLogical (const mxArray *ptr);
extern  bool mexIsGloball (const mxArray *ptr);
extern  void mxSetLogical (mxArray *ptr);
extern  void mxClearLogical (mxArray *ptr);
extern  bool mxIsString (const mxArray *ptr);
extern  bool mxIsChar (const mxArray *ptr);
extern  bool mxIsEmpty (const mxArray *ptr);
extern  bool mxIsClass (const mxArray *ptr, const char *name);
extern  bool mxIsCell (const mxArray *ptr);
extern  bool mxIsStruct (const mxArray *ptr);

extern  bool mxIsInt8 (const mxArray *ptr);
extern  bool mxIsInt16 (const mxArray *ptr);
extern  bool mxIsInt32 (const mxArray *ptr);
extern  bool mxIsUint8 (const mxArray *ptr);
extern  bool mxIsUint16 (const mxArray *ptr);
extern  bool mxIsUint32 (const mxArray *ptr);

extern  void mxSetM (mxArray *ptr, int m);
extern  void mxSetN (mxArray *ptr, int n);
extern  void mxSetJc  (mxArray *array_ptr, int *jc_data);
extern  void mxSetIr  (mxArray *array_ptr, int *ir_data);
extern  void mxSetNzmax  (mxArray *array_ptr, int nzmax);
extern  void mxSetCell (mxArray *pa, int i, mxArray *value);

extern   int sci_gateway (char *fname, GatefuncS F);
extern   mxArray *mexGetArray (char *name, char *workspace);

extern mxArray *mexGetVariable (const char *workspace, const char *name);
extern const mxArray *mexGetVariablePtr (const char *workspace, const char *name);

extern unsigned long int C2F(mxcalloc)  (unsigned int *n, unsigned int *size);

extern void  C2F(mexprintf)  (char *error_msg, int len);

extern void *mxCalloc (size_t n, size_t size);
extern void *mxMalloc (size_t nsize);
extern void *mxCalloc_m (unsigned int n, unsigned int size);
extern void *mxMalloc_m (unsigned int nsize);
extern void  mxFree_m (void *);

extern void C2F(mexerrmsgtxt)  (char *error_msg, int len);
extern  void C2F(mxfreematrix)  (mxArray *ptr);
extern  void mexErrMsgTxt (const char *error_msg);
extern  int  mexEvalString (char *name);
extern  void mexWarnMsgTxt (const char *error_msg);
extern  void mexprint (char* fmt,...);
extern  void mxFree (void *ptr);
extern  void mxFreeMatrix (mxArray *ptr);
extern  void mxDestroyArray (mxArray *ptr);
extern  int mxGetFieldNumber (const mxArray *ptr, const char *string);
extern  mxArray *mxGetField (const mxArray *pa, int i, const char *fieldname);
extern  void  mxSetFieldByNumber (mxArray *array_ptr, int index, int field_number, mxArray *value);
extern  void mxSetField (mxArray *pa, int i, const char *fieldname, mxArray *value);

extern mxArray *mxGetFieldByNumber (const mxArray *ptr, int index, int field_number);
extern const char *mxGetFieldNameByNumber (const mxArray *array_ptr, int field_number);
extern mxLOGICAL *mxGetLogicals (mxArray *array_ptr);

extern vraiptrst C2F(locptr) (void *x);

typedef enum {
	mxCELL_CLASS = 1,
	mxSTRUCT_CLASS,
	mxOBJECT_CLASS,
	mxCHAR_CLASS,
	mxSPARSE_CLASS,
	mxDOUBLE_CLASS,
	mxSINGLE_CLASS,
	mxINT8_CLASS,
	mxUINT8_CLASS,
	mxINT16_CLASS,
	mxUINT16_CLASS,
	mxINT32_CLASS,
	mxUINT32_CLASS,
	mxUNKNOWN_CLASS = 0
} mxClassID;

typedef enum { mxREAL, mxCOMPLEX } mxComplexity; 




extern mxClassID mxGetClassID (const mxArray *ptr);
extern  const char *mxGetName (const mxArray *array_ptr);
extern  void mxSetName ( mxArray    *pa,    const char *s );
extern  void mxSetPr (mxArray *array_ptr, double *pr);
extern  void mxSetPi (mxArray *array_ptr, double *pi);
extern  void mxSetData (mxArray *array_ptr, void *pr);
extern  mxArray *mxCreateNumericArray (int ndim, const int *dims, mxClassID classid, mxComplexity flag);
extern  mxArray *mxCreateNumericMatrix (int m, int n, mxClassID classid, int cmplx_flag);
extern  int mxSetDimensions (mxArray *array_ptr, const int *dims, int ndim);
extern  mxArray *mxCreateDoubleMatrix (int m, int n, mxComplexity it);
extern  mxArray *mxCreateDoubleScalar (double value);
extern  mxArray *mxCreateSparse (int m, int n, int nzmax, mxComplexity cmplx);
extern  mxArray *mxDuplicateArray (const mxArray *ptr);

/*function added*/

typedef enum {
	mxLUPOINTER,
	mxBLOCKPOINTER,
	mxLINKPOINTER,
	mxSBLOCKPOINTER,
	mxDIAGRAMPOINTER,
	mxCPRPOINTER,
	mxXORDPOINTER,
	mxCORPOINTER,
	mxNULLPOINTER,
	mxCPRDIAGPOINTER,
	mxSIMPARAMSPOINTER,
	mxMODELPOINTER,
} mxPointerID;

typedef void *mxPointer;
extern int *mxGetHeader (const mxArray *ptr); 
extern mxArray *mxHeader2Ptr (int *header);
extern mxArray *mxCreatePointer (int m, int n, double *p, mxPointerID pointerId);
extern void mxSetPointerPrToNull (mxArray *ptr);
extern mxPointer mxGetPointerPr (const mxArray *ptr);
extern bool mxIsPointer (const mxArray *ptr);
extern bool mxIsDiagram (const mxArray *ptr);
extern bool mxIsBlock (const mxArray *ptr);
extern bool mxIsSubSystem (const mxArray *ptr);
extern bool mxIsLink (const mxArray *ptr);
extern bool mxIsCpr (const mxArray *ptr);
extern bool mxIsXord (const mxArray *ptr);
extern bool mxIsCorinv (const mxArray *ptr);
extern bool mxIsNULL (const mxArray *ptr);
extern bool mxIsCprDiagram (const mxArray *ptr);
extern bool mxIsSimParams (const mxArray *ptr);
extern bool mxIsModel (const mxArray *ptr);

/* typedef uint16_T mxChar; */
/* typedef short int mxChar; */

typedef unsigned short mxChar;

#define INT8_T char
#define UINT8_T unsigned char
#define INT16_T short
#define UINT16_T unsigned short
#define INT32_T int
#define UINT32_T unsigned int
#define REAL32_T float

typedef INT8_T int8_T;
typedef UINT8_T uint8_T;
typedef INT16_T int16_T;
typedef UINT16_T uint16_T;
typedef INT32_T int32_T;
typedef UINT32_T uint32_T;
typedef REAL32_T real32_T;

#endif /* SCI_MEX  */

#ifdef __cplusplus
}
#endif

/* generic mexfunction name */
#ifdef __cplusplus
extern "C" {
  extern void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
}
#endif
