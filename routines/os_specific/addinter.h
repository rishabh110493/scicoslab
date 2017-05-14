#ifndef __ADDINTER_H__
#define  __ADDINTER_H__
/** the first dynamic interface is at position 500+1 **/
/* Copyright ENPC */
#define DynInterfStart 500

#if defined(WIN32) && ! defined(__MINGW32__)
extern char *GetExceptionString(DWORD ExceptionCode);
#endif 

/* Dynamic interface 
 *
 */

#if defined(WIN32) && ! defined(__MINGW32__) && ! defined(_DEBUG) 
#define CALL_DYNINTER(k1)			\			\
  _try									\
  {  (*DynInterf[k1].func)();}						\
  _except (EXCEPTION_EXECUTE_HANDLER)					\
  {									\
    extern char *GetExceptionString(DWORD ExceptionCode);		\
    char *ExceptionString=GetExceptionString(GetExceptionCode());	\
    sciprint("Warning !!!\nScilab has found a critical error (%s)\nwith \"%s\" function.\nScilab may become unstable.\n", \
	     ExceptionString,DynInterf[k1].name);			\
    if (ExceptionString) {FREE(ExceptionString);ExceptionString=NULL;}	\
  }									
#else 
#define CALL_DYNINTER(k1) (*DynInterf[k1].func)() 
#endif 

/* standard interface 
 *
 */

#if defined(WIN32) && ! defined(__MINGW32__) && ! defined(_DEBUG) 
#define CALL_INTERF()							\
  Rhs = Max(0, Rhs);							\
 _try									\
 {									\
   (*(Tab[Fin-1].f)) (Tab[Fin-1].name,strlen(Tab[Fin-1].name));		\
 }									\
 _except (EXCEPTION_EXECUTE_HANDLER)					\
 {									\
   char *ExceptionString=GetExceptionString(GetExceptionCode());	\
   sciprint("Warning !!!\nScilab has found a critical error (%s)\nwith \"%s\" function.\nScilab may become unstable.\n", \
	    ExceptionString,Tab[Fin-1].name);				\
   if (ExceptionString) {FREE(ExceptionString);ExceptionString=NULL;}	\
 }									
#else 
#define CALL_INTERF()							\
  Rhs = Max(0, Rhs);							\
  (*(Tab[Fin-1].f)) (Tab[Fin-1].name,strlen(Tab[Fin-1].name)) 
#endif 

/* interface with drivers 
 *
 */

#if defined(WIN32) && ! defined(__MINGW32__) && ! defined(_DEBUG) 
#define CALL_INTERF_F()							\
  Rhs = Max(0, Rhs);							\
 _try									\
 {									\
   (*(Tab[Fin-1].f)) (Tab[Fin-1].name,Tab[Fin-1].F);			\
 }									\
 _except (EXCEPTION_EXECUTE_HANDLER)					\
 {									\
   char *ExceptionString=GetExceptionString(GetExceptionCode());	\
   sciprint("Warning !!!\nScilab has found a critical error (%s)\nwith \"%s\" function.\nScilab may become unstable.\n", \
	    ExceptionString,Tab[Fin-1].name);				\
   if (ExceptionString) {FREE(ExceptionString);ExceptionString=NULL;}	\
 }									
#else 
#define CALL_INTERF_F()							\
  Rhs = Max(0, Rhs);							\
  (*(Tab[Fin-1].f)) (Tab[Fin-1].name,Tab[Fin-1].F)
#endif 

#endif /*  __ADDINTER_H__ */
