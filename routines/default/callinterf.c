/**************************************
 * Copyright Jean-Philippe Chancelier 
 * ENPC 
 **************************************/
#include <setjmp.h>
#include <stdio.h>
#include <ctype.h>
#include <signal.h>

#include "../machine.h"
#include "../os_specific/addinter.h" /* for DynInterfStart */
#include "../os_specific/Os_specific.h" /* for DynInterfStart */

static  jmp_buf jmp_env; 

extern int  C2F(error) __PARAMS((int *));
extern void sciprint __PARAMS((char* ,...));
extern int  Scierror __PARAMS((int iv,char *fmt,...));

extern void  errjump(int n);
extern void  sci_sig_tstp(int n);
extern void  controlC_handler(int n);
static void  sci_sigint_addinter(int n);

/***********************************************************
 * interface function 
 ***********************************************************/

static int c_local = 9999;

void C2F(NoTclsci)(void)
{
  sciprint("TclSci interface not loaded \n");
  C2F(error)(&c_local);
  return;
}

void C2F(NoPvm)(void)
{
  sciprint("pvm interface not loaded \n");
  C2F(error)(&c_local);
  return;
}

void C2F(NoExpatsci)(void)
{
  sciprint("Expatsci interface not loaded \n");
  C2F(error)(&c_local);
  return;
}

void C2F(NoExpatsciutil)(void)
{
  sciprint("Expatsci interface not loaded \n");
  C2F(error)(&c_local);
  return;
}

void C2F(NoExpatscistring)(void)
{
  sciprint("Expatsci interface not loaded \n");
  C2F(error)(&c_local);
  return;
}

/** table of interfaces **/

typedef  struct  {
  void  (*fonc)();} OpTab ;

#include "callinterf.h"


/***********************************************************
 * call the apropriate interface according to the value of k 
 * iflagint is no more used here ....
 ***********************************************************/


static int sig_ok = 0;

int C2F(callinterf) ( int *k, int * iflagint)
{
  int returned_from_longjump ;
  static int count = 0;
  if ( count == 0) 
    {
      if (sig_ok) signal(SIGINT,sci_sigint_addinter);
      if (( returned_from_longjump = setjmp(jmp_env)) != 0 )
	{
	  if (sig_ok) signal(SIGINT, controlC_handler);
	  Scierror(999,"SIGSTP: aborting current computation\r\n");
	  count = 0;
	  return 0;
	}
    }
  count++;
  if (*k > DynInterfStart) 
    C2F(userlk)(k);
  else
    (*(Interfaces[*k-1].fonc))();
  count--;
  if (count == 0) { 
    if (sig_ok) signal(SIGINT, controlC_handler);
  }
  return 0;
}

static void sci_sigint_addinter(int n)
{
  int c;
  sciprint("Trying to stop scilab in the middle of an interface\n");
  sciprint("Do you really want to abort computation (y n  ?) ");
  c = getchar();
  if ( c == 'y' ) errjump(n);
}


/***********************************************************
 * Unused function just here to force linker to load some 
 * functions 
 ***********************************************************/

#ifndef WIN32
extern int   Blas_contents (int);
extern int   Lapack_contents (int);
extern int   Calelm_contents (int);
extern int   Sun_contents (int);
extern int   System2_contents (int);
extern int   System_contents (int);
extern int  Intersci_contents (int);
extern int  Sparse_contents (int);
#endif 

#ifdef __MINGW32__ 
/* force the load of f2c to enable 
 * dynamic linking with code compiled 
 * with f2c 
 */
extern void f2c_entries(void);

#endif 
int ForceLink(void)
{
#ifndef WIN32 
  Blas_contents(0);
  Lapack_contents(0);
  Calelm_contents(0);
  Sun_contents(0);
  System2_contents(0);
  System_contents(0);
  Intersci_contents(0);
  Sparse_contents(0);
#endif 

#ifdef __MINGW32__ 
  f2c_entries();
#endif 
  return 0;
}


/*-------------------------------------
 * long jump to stop interface computation 
 *-------------------------------------*/

void errjump(int n)
{
  longjmp(jmp_env,-1); 
}
