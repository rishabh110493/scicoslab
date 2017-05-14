//#include "stack-c.h"
//#include <stddef.h>
//#include <stdlib.h>
#include <math.h>
//#include <stdio.h>
/* #include <values.h> */
#include <limits.h>
#include <float.h>

#define EPSILONI MAXINT
#define EPSILON HUGE_VAL
#define ZEROD 1e-10
#define U(i,j) u[i*nn+j]
#define PI(i,j) policy[i*nn+j]

extern void sciprint (char *fmt, ...);

/* Pablo.Lotito@inria.fr 23/04/2001.
   Based on Stephane Gaubert's code of Ford Bellman
   Ford-Bellman Algorithm with Gauss-Seidel variant,
   Ref: Gondran and  Minoux, Graphes et Algorithmes,
   Eyrolles, 1979, chap3, sec 4.2
   
   Given an initial node and a weighted digraph (ij,A),
   computes for all j, the minimal weight u[j] of a path from I to j
   Also returns a policy pi: pi[j] is by definition the predecessor
   of j on an optimal path. Thus, the arcs pi[j]->j form a tree,
   with root the initial node.

   ij: tail/head matrix. the i-th arc goes from ij[2*i] to ij[2*i+1]
   A: weight vector. A[i] = weight of arc i
*/

int FBPV(int *tl, int *hl,double *v,int nn, int na, int no, int *origins, double *u, int *policy, int *niterations)
{  
  int i,j,or,initial,improved=0,horizon;
  /*  sciprint("Value of no %d \r\n",no);*/
  for (or=0; or<no; or++)
    {	
      initial=origins[or];
      for (i=0; i<nn; i++)
	{
	  u[or*nn+i]=EPSILON;
	  policy[or*nn+i]=0;
	}
	  
      U(or,initial-1)=0;
      PI(or,initial-1)=0;
      horizon=nn;
      for (j=0;j<horizon;j++)
	{
	  improved=0;
	  for (i=0;i<na; i++)
	    {
	      if( (v[i] + U(or,tl[i]-1) - U(or,hl[i]-1) < -ZEROD) && (U(or,tl[i]-1)<EPSILON)) 
		{
		  /*			      printf("Valore= %f \n",v[i]+u[tl[i]-1]-u[hl[i]-1]);
					      printf("Valore de i= %d, v(i)=%f,  u(tl(i))=%f, u(h(li))=%f\n",i,v[i],u[tl[i]-1],u[hl[i]-1]); */
		  improved=1;
		  policy[or*nn+hl[i]-1]=i+1;
		  u[or*nn+hl[i]-1]= v[i]+U(or,tl[i]-1);
		}
	    }
	  if (improved==0) horizon=0; /* end of loop */
	}
      niterations[or]=j;
    }
  if (improved)
    {
      sciprint("Error in FordBellman, the digraph contains a circuit with positive weight\n");
      return(1);
    }
  else
    return(0);   
};


