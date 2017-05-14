//#include "stack-c.h"
//#include <stddef.h>
//#include <stdlib.h>
//#include <math.h>
//#include <stdio.h>
//#include <values.h>


int DH(int *tl,int *hd,double *dd, int nr, int na,double *t, double *dt, int *rutas,  int*mapa, int *selva, int *rutaOD,double *dir, double der, double der2)
{
  double s1,s2;
  int a,k,r,s,ks,un,uns,ua,arbol,estas,estar;

  der=0;
  der2=0;
  
  for (r=0;r<nr;r++)
    {
      k=rutaOD[r]-1;
      un=hd[k]-1;
      arbol=mapa[2*(rutas[2*r]-1)]-1;
      s1=0;
	  
      for (s=0;s<nr;s++)
	{
	  ks=rutaOD[s]-1;
	  uns=hd[ks]-1;
	  arbol=mapa[2*(rutas[2*s]-1)]-1;
	  s2=0;
		  
	  for (a=0;a<na;a++)
	    {
	      /*Ver si a esta en la ruta r */
	      estar=0;
	      ua=selva[arbol+un]-1;
	      while (ua>-1)
		{
		  if (ua==a)
		    estar=1;
		  un=tl[ua]-1;
		  ua=selva[arbol+un]-1;
		}
	      /*Ver si a esta en la ruta s  */
	      estas=0;
	      ua=selva[arbol+uns]-1;
	      while (ua>-1)
		{
		  if (ua==a)
		    estas=1;
		  un=tl[ua]-1;
		  ua=selva[arbol+un]-1;
		}

	      if (estar*estas)
		{
		  s2=s2+dt[a];
		}
	      if (s==0)
		if (estar)
		  s1=s1+t[a];
	    }
	  der2=der2+s2*dir[r]*dir[s]*dd[k]*dd[ks];
	}
      der=der+s1*dir[r]*dd[k];
    }
  return 0;
}

  
  
