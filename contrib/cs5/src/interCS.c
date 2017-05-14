#include "stack-c.h"
#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
/* #include <values.h> */
#include <limits.h>
#include <float.h>
#include <string.h>



//Costo        //////////////////////////////////////////////////////////////////
extern int Costo _PARAMS((int *td,int *hd,double *dd, int nr, int na, double *t, double *dt, int *rutas,  int*mapa, int *selva, int *rutaOD,double *apq, double *bpq));

int iCosto(fname)
  char* fname;
{
  int uno=1,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11;
  int n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11 ;
  int l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11 ;
  int p1,p2,nr;
  
  
  static int minlhs=1, minrhs=11, maxlhs=2, maxrhs=11;
  CheckRhs(minrhs,maxrhs) ;
  CheckLhs(minlhs,maxlhs) ;

  
  GetRhsVar(1, "i", &m1, &n1, &l1); /* demand tail list */
  GetRhsVar(2, "i", &m2, &n2, &l2); /* demand head list */
  GetRhsVar(3, "d", &m3, &n3, &l3); /* demand value list */
  GetRhsVar(4, "i", &m4, &n4, &l4); /* number of routes */
  GetRhsVar(5, "i", &m5, &n5, &l5); /* number of arcs*/
  GetRhsVar(6, "d", &m6, &n6, &l6); /* t=travel time function */
  GetRhsVar(7, "d", &m7, &n7, &l7); /* t'=derivative of " */
  GetRhsVar(8, "i", &m8, &n8, &l8); /* rutas */
  GetRhsVar(9, "i", &m9, &n9, &l9); /* mapa */
  GetRhsVar(10, "i", &m10, &n10, &l10); /* selva */
  GetRhsVar(11, "i", &m11, &n11, &l11); /* rutaOD */

  nr=*istk(l4);
  
  

  CreateVar(12, "d", &uno, &nr, &p1); /* apq */
  CreateVar(13, "d", &uno, &nr, &p2); /* bpq */

  Costo(istk(l1),istk(l2),stk(l3),*istk(l4),*istk(l5),stk(l6),stk(l7),istk(l8),istk(l9),istk(l10),istk(l11),stk(p1),stk(p2));

  LhsVar(1)=12;
  LhsVar(2)=13;

  
  return(0);
  
}

//DH //////////////////////////////////////////////////////////////////
extern int DH _PARAMS((int *tl,int *hd,double *dd, int nr, int na,double *t, double *dt, int *rutas,  int*mapa, int *selva, int *rutaOD,double *dir, double der, double der2));

int iDH(fname)
  char* fname;
{
  int uno=1,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12 ;
  int n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12 ;
  int l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12 ;
  int p1,p2,nr;
  
  

	
  static int minlhs=1, minrhs=12, maxlhs=2, maxrhs=12;
  CheckRhs(minrhs,maxrhs) ;
  CheckLhs(minlhs,maxlhs) ;

  
  GetRhsVar(1, "i", &m1, &n1, &l1); /* demand head list */
  GetRhsVar(2, "i", &m2, &n2, &l2); /* tail list */
  GetRhsVar(3, "d", &m3, &n3, &l3); /* demand value list */
  GetRhsVar(4, "i", &m4, &n4, &l4); /* number of routes */
  GetRhsVar(5, "i", &m5, &n5, &l5); /* number of arcs*/
  GetRhsVar(6, "d", &m6, &n6, &l6); /* t=travel time function */
  GetRhsVar(7, "d", &m7, &n7, &l7); /* t'=derivative of " */
  GetRhsVar(8, "i", &m8, &n8, &l8); /* rutas */
  GetRhsVar(9, "i", &m9, &n9, &l9); /* mapa */
  GetRhsVar(10, "i", &m10, &n10, &l10); /* selva */
  GetRhsVar(11, "i", &m11, &n11, &l11); /* rutaOD */
  GetRhsVar(12, "d", &m12, &n12, &l12); /* direccion */
  nr=*istk(l4);

  CreateVar(13, "d", &uno, &uno, &p1); /* derivada primera */
  CreateVar(14, "d", &uno, &uno, &p2); /* derivada segunda */


  DH(istk(l1),istk(l2),stk(l3),*istk(l4),*istk(l5),stk(l6),stk(l7),istk(l8),istk(l9),istk(l10),istk(l11),stk(l12),*stk(p1),*stk(p2));

  LhsVar(1)=13;
  LhsVar(2)=14;
  
  return(0);
  
}

// FBPV //////////////////////////////////////////////////////////////////
extern int FBPV _PARAMS((int *tl, int *hl,double *v,int nnodes, int narcs, int no, int *origins, double *u, int *policy, int *niterations));

int iFBPV(fname)
  char* fname;
{ 
  int l1, l2, l3, l4, l5,p1,p2,p3;
  int m1, n1, m2, n2, m3, n3, m4,m5,n5,n4,nn,errorflag;

  static int minlhs=1, minrhs=5, maxlhs=3, maxrhs=6;
  CheckRhs(minrhs,maxrhs) ;
  CheckLhs(minlhs,maxlhs) ;
  GetRhsVar(1, "i", &m1, &n1, &l1); /* link tail list */
  GetRhsVar(2, "i", &m2, &n2, &l2); /* link head list */
  GetRhsVar(3, "d", &m3, &n3, &l3); /* weight vector */
  GetRhsVar(4, "i", &m4, &n4, &l4); /* nnodes */
  GetRhsVar(5, "i", &m5, &n5, &l5); /* list of origins */
  nn=*istk(l4);
  CreateVar(6, "d", &nn, &n5, &p1); /* shortest path cost */
  CreateVar(7, "i", &nn, &n5, &p2); /* policy */
  CreateVar(8, "i", &m5, &n5, &p3); /* iteration number */
  
  errorflag = FBPV(istk(l1),istk(l2),stk(l3),*istk(l4),n1,n5,istk(l5),stk(p1),istk(p2),istk(p3));
  
  if (errorflag==1)
    {
      sciprint("Error in FordBellman: the digraph has a circuit with negative weight");
      Error(999);
      return(0);
    }
  LhsVar(1)=6;
  LhsVar(2)=7;
  LhsVar(3)=8;
  return(0);
}


//Flujo //////////////////////////////////////////////////////////////////

extern int Flujo _PARAMS((int *tl, int *hl, int nn, int na, int nd, int *td, int *hd, double *dd, int *lor, int *rutas, double *lamda, int*mapa, int *selva, double *f, double *F));

int iFlujo(fname)
  char* fname;
{
  int uno=1,m1,m2,m6,m7,m8,m9,m10,m11,m12,m13;
  int n1,n2,n6,n7,n8,n9,n10,n11,n12,n13 ;
  int l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13 ;
  int p1,p2,nd,na;
  
  

	
static int minlhs=1, minrhs=13, maxlhs=2, maxrhs=13;
  CheckRhs(minrhs,maxrhs) ;
  CheckLhs(minlhs,maxlhs) ;

  GetRhsVar(1, "i", &m1, &n1, &l1); /* link tail list */
  GetRhsVar(2, "i", &m2, &n2, &l2); /* link head list */
  GetRhsVar(3, "i", &uno, &uno, &l3); /* nn */
  GetRhsVar(4, "i", &uno, &uno, &l4); /* na */
  GetRhsVar(5, "i", &uno, &uno, &l5); /* nd */
  GetRhsVar(6, "i", &m6, &n6, &l6); /* demand tail list */
  GetRhsVar(7, "i", &m7, &n7, &l7); /* demand head list */
  GetRhsVar(8, "d", &m8, &n8, &l8); /* demand value list*/
  GetRhsVar(9, "i", &m9, &n9, &l9); /* list of origins */
  GetRhsVar(10, "i", &m10, &n10, &l10); /* rutas */
  GetRhsVar(11, "d", &m11, &n11, &l11); /* lamda */
  GetRhsVar(12, "i", &m12, &n12, &l12); /* mapa  */
  GetRhsVar(13, "i", &m13, &n13, &l13); /* selva */

  na=*istk(l4);nd=*istk(l5);

  CreateVar(14, "d", &nd, &na, &p1); /* flujo fka */
  CreateVar(15, "d", &uno, &na, &p2); /* flujo F */

  Flujo(istk(l1),istk(l2),*istk(l3),*istk(l4),*istk(l5),istk(l6),istk(l7),stk(l8),istk(l9),istk(l10),stk(l11),istk(l12),istk(l13),stk(p1),stk(p2));

  LhsVar(1)=14;
  LhsVar(2)=15;
  
  return(0);
  
}


// FlujoT //////////////////////////////////////////////////////////////////

extern int FlujoT _PARAMS((int *tl, int *hl, int nn, int na, int nd, int *td, int *hd, double *dd, int *lor, int *rutas, double *lamda, int*mapa, int *selva, double *F));

int iFlujoT(fname)
  char* fname;
{
  int uno=1,m1,m2,m6,m7,m8,m9,m10,m11,m12,m13;
  int n1,n2,n6,n7,n8,n9,n10,n11,n12,n13 ;
  int l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13 ;
  int p1,nd,na;
  
  

	
static int minlhs=1, minrhs=13, maxlhs=2, maxrhs=13;
  CheckRhs(minrhs,maxrhs) ;
  CheckLhs(minlhs,maxlhs) ;

  GetRhsVar(1, "i", &m1, &n1, &l1); /* link tail list */
  GetRhsVar(2, "i", &m2, &n2, &l2); /* link head list */
  GetRhsVar(3, "i", &uno, &uno, &l3); /* nn */
  GetRhsVar(4, "i", &uno, &uno, &l4); /* na */
  GetRhsVar(5, "i", &uno, &uno, &l5); /* nd */
  GetRhsVar(6, "i", &m6, &n6, &l6); /* demand tail list */
  GetRhsVar(7, "i", &m7, &n7, &l7); /* demand head list */
  GetRhsVar(8, "d", &m8, &n8, &l8); /* demand value list*/
  GetRhsVar(9, "i", &m9, &n9, &l9); /* list of origins */
  GetRhsVar(10, "i", &m10, &n10, &l10); /* rutas */
  GetRhsVar(11, "d", &m11, &n11, &l11); /* lamda */
  GetRhsVar(12, "i", &m12, &n12, &l12); /* mapa  */
  GetRhsVar(13, "i", &m13, &n13, &l13); /* selva */

  na=*istk(l4);nd=*istk(l5);

  CreateVar(14, "d", &uno, &na, &p1); /* flujo F */


  FlujoT(istk(l1),istk(l2),*istk(l3),*istk(l4),*istk(l5),istk(l6),istk(l7),stk(l8),istk(l9),istk(l10),stk(l11),istk(l12),istk(l13),stk(p1));

  LhsVar(1)=14;

  return(0);
  
}


// Simplify //////////////////////////////////////////////////////////////////

extern int simplify _PARAMS((int *lista, int n, int nm,int *lista1, int *lista2, int *ns));

int isimplify(fname)
  char* fname;
{ 
  int l1,l2,p1,p2,p3;
  int m1, n1,m2,n2,uno=1;

  static int minlhs=1, minrhs=2, maxlhs=3, maxrhs=2;

  CheckRhs(minrhs,maxrhs) ;
  CheckLhs(minlhs,maxlhs) ;
  
  GetRhsVar(1, "i", &m1, &n1, &l1); /* original list */
  GetRhsVar(2, "i", &m2, &n2, &l2); /* number of nodes */
  CreateVar(3, "i", &m1, &n1, &p1); /* order in the simplified list */
  CreateVar(4, "i", &m1, &n1, &p2); /* simplified list */
  //CreateVar(4, "i", &m1, &l2, &p2); /* simplified list */
  CreateVar(5, "i", &uno, &uno, &p3); /* length of simplified list */
  
  simplify(istk(l1),n1,*istk(l2),istk(p1),istk(p2),istk(p3));
  
  LhsVar(1)=4;
  LhsVar(2)=3;
  LhsVar(3)=5;

  return(0);
}

// QKSP //////////////////////////////////////////////////////////////////

extern int qksp _PARAMS((double *a, double *b, double *y,int nd,int nR, int *rutas, double *lambda, double *pi));

int iqksp(fname)
  char* fname;
{ 
  int l1,l2,l3,l4,l5,l6,p1,p2;
  int m1,m2,m3,m4,m5,m6,n1,n2,n3,n4,n5,n6;

  static int minlhs=1, minrhs=6, maxlhs=2, maxrhs=6;

  CheckRhs(minrhs,maxrhs) ;
  CheckLhs(minlhs,maxlhs) ;
  
  GetRhsVar(1, "d", &m1, &n1, &l1); /* a */
  GetRhsVar(2, "d", &m2, &n2, &l2); /* b */
  GetRhsVar(3, "d", &m3, &n3, &l3); /* y */
  GetRhsVar(4, "i", &m4, &n4, &l4); /* number of commodities */
  GetRhsVar(5, "i", &m5, &n5, &l5); /* maximum number of routes per commodity */
  GetRhsVar(6, "i", &m6, &n6, &l6); /* rutas */
  
  CreateVar(7, "d", &m6, &n6, &p1); /* lambda */
  CreateVar(8, "d", &m4, &(*istk(l4)), &p2); /* pi */
  
  qksp(stk(l1),stk(l2),stk(l3),*istk(l4),*istk(l5),istk(l6),stk(p1),stk(p2));
  
  LhsVar(1)=7;
  LhsVar(2)=8;
  

  return(0);
}

