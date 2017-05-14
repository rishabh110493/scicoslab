//#include <math.h>
//#include <values.h>

int Flujo(int *tl, int *hl, int nn, int na, int nd, int *td, int *hd, double *dd, int *lor, int *rutas, double *lamda, int*mapa, int *selva, double *f, double *F)
{
  int a,k,r,un,ua,arbol;
  
  for (a=0;a<na;a++)
    { 
      F[a]=0;
      for (k=0;k<nd;k++) f[a*nd+k]=0;
    }

  for (k=0;k<nd;k++)
    {
      r=k;
      while (r>-1)
	{
	  /*Recorrer la ruta r*/
	  un=hd[k]-1;
	  arbol=mapa[2*(rutas[2*r]-1)]-1;
	  /*printf("arbol= %d un= %d\r\n",arbol,un);*/
		  
	  ua=selva[arbol+un]-1;
	  while (ua>-1)
	    {
	      f[ua*nd+k]+=lamda[r]*dd[k];
	      F[ua]+=lamda[r]*dd[k];
	      un=tl[ua]-1;
	      ua=selva[arbol+un]-1;
	    }
	  r=rutas[2*r+1]-1;   /* Siguiente ruta */
	}
    }
  return 0;
}

	  
