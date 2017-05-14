#include <stdlib.h>

/*
 * Given a list L of n repeated integers it simplifies it eliminating
 * repeated entries, obtaining the list Ls of ns components.
 * It gives also the list Lor whose components are the positiong in Ls of
 * the same component of L, i.e. L(i)=Ls(Lor(i))
 * nn is an upper bound of the size of Ls.
 */

extern void sciprint (char *fmt, ...);

int simplify(int *L, int n, int nn,  int *Lor, int *Ls, int *ns)
{  
  int *aux=0;
  int i,j;

  aux = (int*) calloc(nn,sizeof(int));
  if( aux == NULL )
    {
      sciprint("Memory allocation failed.");
      exit(1);
    }
  /*  for (i=0;i<n;i++)
   *  aux[L[i]-1]=0;
   */
  
  Lor[0]=1;
  Ls[0]=L[0];
  j=1;
  aux[L[0]-1]=1;
  for (i=1;i<n;i++)
    if (aux[L[i]-1]==0)
      {
	j++;
	aux[L[i]-1]=j;
	Lor[i]=j;
	Ls[j-1]=L[i];
      }
    else
      Lor[i]=aux[L[i]-1];
  *ns=j;
  free(aux);
  return(0);
}

