int Costo(int *tl,int *hd,double *dd, int nr, int na,
	  double *t, double *dt, int *rutas,  int*mapa,
	  int *selva, int *rutaOD,double *apq, double *bpq)
{
  /* Computes a(r)=Sum_a t_a(f_a) x d_pq x delta_pqr,a
   * and  b(r)=Sum_a t'_a(f_a) x d_pq^2 x delta_pqr,a
   */
  int k,r,un,ua,arbol;
  for (r=0;r<nr;r++)
    {
      apq[r]=0;bpq[r]=0;
      /*Recorrer la ruta r*/
      k=rutaOD[r]-1;
      un=hd[k]-1;
      arbol=mapa[2*(rutas[2*r]-1)]-1;
      ua=selva[arbol+un]-1;
      while (ua>-1)
	{
	  apq[r]+=t[ua];
	  bpq[r]+=dt[ua];
	  un=tl[ua]-1;
	  ua=selva[arbol+un]-1;
	}
      apq[r]=apq[r]*dd[k];
      bpq[r]=bpq[r]*dd[k]*dd[k];
    }
  return 0;
}

	  
