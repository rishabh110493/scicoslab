#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>


static int Flujo(int *tl, int *hl, int nn, int na, int nd, int *td, int *hd, double *dd, int *lor, int *rutas, double *lamda, int*mapa, int *selva, double *f, double *F)
{
  double s1,s2;
  int a,k,r,un,ua,arbol,esta;
  
  for (a=0;a<na;a++)
	{
	  s1=0;
	  for (k=0;k<nd;k++)
		{
		  s2=0;
		  r=k;
		  while (r>-1)
			{
			  /*Ver si a esta en la ruta r*/
			  esta=0;
			  un=hd[k]-1;
			  arbol=mapa[2*(rutas[2*r]-1)]-1;
			  /*printf("arbol= %d un= %d\r\n",arbol,un);*/
			  
			  ua=selva[arbol+un]-1;
			  while (ua>-1)
				{
				  if (ua==a)
					esta=1;
				  un=tl[ua]-1;
				  ua=selva[arbol+un]-1;
				}
			  if (esta)
				s2=s2+lamda[r]*dd[k];
			  r=rutas[2*r+1]-1;   /* Siguiente ruta */
			}
		  f[a*nd+k]=s2;
		  s1=s1+s2;
		}
	  F[a]=s1;
	}
}

	  
