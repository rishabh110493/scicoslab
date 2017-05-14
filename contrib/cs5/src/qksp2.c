/* Solution of nk Quadratic Knapsacks
 For k=0 a nk-1 solve 
 \sum_i a_{ki} x_{ki}+ 0.5 b_{ki} (x_{ki} - y_{ki})^2
  subject to \sum_i x_{ki}=1 and x_{ki} \geq 0
  where a,b,y are given
 is the current problem,  
 It is assumed that allthe bi are geq than zero
*/ 


// primera ruta 

  
// Determinacion de I0


#include <stdlib.h>
#include <stdio.h>
//#include <cstdlib>
#include <math.h>





/*
void qksp(double *a, double *b, double *y,int nd,int nR, int *rutas, double *lambda, double *ppi)
{	int pq=0,s,r,cardI0,cardI1,rstar=0,rI1,Newton=0;
	double cosa=0,astar=0,pi0=0,pi0a=0,pi0b=0,pi=0,fpi,fPpi,zero=1e-10,ci;
	int *pI1=0, cont=0,cont2=0, *pr=0;

	pI1 = (int*) calloc(nR+1,sizeof(int));
	if( pI1 == NULL )
	{
		printf("Memory allocation failed. ");
		//	  sciprint("Memory allocation failed.");
		//	  exit(1);
	}


	for (pq=0;pq<nd;pq++)
	{
		r=pq;
		if (b[r]> zero) 
		{
			cardI1=1;cardI0=0;
			pi0b=(y[r]-1)*b[r]-a[r];
			*pI1=r+1;
		}
		else
		{
			cardI0=1;cardI1=0;
			pi0a=-a[r];	
			rstar=r;
		}
		lambda[r]=0;
		s=rutas[pq];
		while (s != 0)
		{
			r=s-1;lambda[r]=0;
			if (b[r]> zero) 
			{
				if (cardI1==0) pi0b=(y[r]-1)*b[r]-a[r];
				else
					pi0b=__min(pi0b,(y[r]-1)*b[r]-a[r]);
				*(pI1+cardI1)=r+1;
				cardI1++;	
			}
			else
			{
				if (cardI0==0) 
				{pi0a=-a[r]; rstar=r;}
				else
					if (pi0a < -a[r]) {pi0a=-a[r]; rstar=r;}
					cardI0++;
			}
			s=rutas[r];
		}
		*(pI1+cardI1)=0;
		
		Newton=1;
		if (cardI1==0)
		{if (cardI0>0) *(lambda+rstar)=1;}	
		else
		{
			if (cardI0 > 0) pi=pi0a; else pi=pi0b;
			fpi=-1; fPpi=0; cont=0; rI1=*pI1;
			while (rI1 != 0) 
			{
				ci=b[rI1-1]*y[rI1-1]-a[rI1-1];
				//fpi=fpi+__max(0,ci-pi)/b[rI1-1];
				//fpi=fpi+(fabs(ci-pi)+ci-pi)/2/b[rI1-1];
				if (pi<ci) {fPpi=fPpi-1/b[rI1-1]; fpi=fpi+(ci-pi)/b[rI1-1];}
				if (pi==ci) cosa=cosa-1/b[rI1-1];
				cont++;
				rI1=*(pI1+cont);
			}
			if (fpi>0) fPpi=fPpi+cosa;
			if (cardI0>0 && fpi<-zero) {*(lambda+rstar)=-fpi;Newton=0;}
			while (Newton*fabs(fpi)>zero)
			{
				pi=pi-fpi/fPpi;
				fpi=-1; fPpi=0; cont=0; rI1=*pI1;
				while (rI1 != 0) 
				{
					ci=b[rI1-1]*y[rI1-1]-a[rI1-1];
					fpi=fpi+__max(0,ci-pi)/b[rI1-1];
					if (pi<ci) fPpi=fPpi-1/b[rI1-1];
					if (pi==ci) cosa=cosa-1/b[rI1-1];
					cont++;
					rI1=*(pI1+cont);
				}
				if (fpi>0) fPpi=fPpi+cosa;
				cont2++;
			}
			rI1=*pI1;cont=0;
			while (rI1 != 0) 
			{
				lambda[rI1-1]=__max(0,y[rI1-1]-(a[rI1-1]+pi)/b[rI1-1]);
				cont++;
				rI1=*(pI1+cont);
			}
		}
		*(ppi+pq)=pi;
	}

}
*/


void qksp(double *a, double *b, double *y,int nd,int nR, int *rutas, double *lambda, double *ppi)
{	int pq=0,s,r,cardI0,cardI1,rstar=0,rI1,Newton=0;
	double cosa=0,astar=0,pi0=0,pi0a=0,pi0b=0,pi=0,fpi,fPpi,zero=1e-10,ci;
	int *pI1=0, cont=0,cont2=0, *pr=0;

	pI1 = (int*) calloc(nR+1,sizeof(int));
	if( pI1 == NULL )
	{
		printf("Memory allocation failed. ");
		//	  sciprint("Memory allocation failed.");
		//	  exit(1);
	}


	for (pq=0;pq<nd;pq++)
	{
		r=pq;
		if (b[r]> zero) 
		{
			cardI1=1;cardI0=0;
			pi0b=(y[r]-1)*b[r]-a[r];
			*pI1=r+1;
		}
		else
		{
			cardI0=1;cardI1=0;
			pi0a=-a[r];	
			rstar=r;
		}
		lambda[r]=0;
		s=rutas[pq];
		while (s != 0)
		{
			r=s-1;lambda[r]=0;
			if (b[r]> zero) 
			{
				if (cardI1==0) pi0b=(y[r]-1)*b[r]-a[r];
				else
				{
					cosa=(y[r]-1)*b[r]-a[r];
					if (cosa<pi0b) pi0b=cosa;
				}
				*(pI1+cardI1)=r+1;
				cardI1++;	
			}
			else
			{
				if (cardI0==0) 
				{pi0a=-a[r]; rstar=r;}
				else
					if (pi0a < -a[r]) {pi0a=-a[r]; rstar=r;}
					cardI0++;
			}
			s=rutas[r];
		}
		*(pI1+cardI1)=0;
		
		Newton=1;
		if (cardI1==0)
		{if (cardI0>0) *(lambda+rstar)=1;}	
		else
		{
			if (cardI0 > 0) pi=pi0a; else pi=pi0b;
			fpi=-1; fPpi=0; cont=0; rI1=*pI1;cosa=0;
			while (rI1 != 0) 
			{
				ci=b[rI1-1]*y[rI1-1]-a[rI1-1];
				if (pi<ci) {fpi=fpi+(ci-pi)/b[rI1-1]; fPpi=fPpi-1/b[rI1-1];}
				if (pi==ci) cosa=cosa-1/b[rI1-1];
				cont++;
				rI1=*(pI1+cont);
			}
			if (fpi>0) fPpi=fPpi+cosa;
			if (cardI0>0 && fpi<-zero) {*(lambda+rstar)=-fpi;Newton=0;}
			while (Newton*fabs(fpi)>zero)
			{
				pi=pi-fpi/fPpi;
				fpi=-1; fPpi=0; cont=0; rI1=*pI1;cosa=0;
				while (rI1 != 0) 
				{
					ci=b[rI1-1]*y[rI1-1]-a[rI1-1];
					if (pi<ci) { fpi=fpi+(ci-pi)/b[rI1-1]; fPpi=fPpi-1/b[rI1-1];}
					if (pi==ci) cosa=cosa-1/b[rI1-1];
					cont++;
					rI1=*(pI1+cont);
				}
			
				if (fpi>0) fPpi=fPpi+cosa;
				cont2++;
			}
			rI1=*pI1;cont=0;
			while (rI1 != 0) 
			{	
				cosa=y[rI1-1]-(a[rI1-1]+pi)/b[rI1-1];
				if (cosa>zero) lambda[rI1-1]=cosa;
				cont++;
				rI1=*(pI1+cont);
			}
		}
		*(ppi+pq)=pi;
	}
	free(pI1);
}

















void main ()
{
/* int rutas[10]={6,4,5,8,9,7,10,0,0,0};
double a[10]={2, 3.1, 2.5, 1, 5, 3, 7, 4, 2, 10};
double b[10]={1, 0, 4, 3, 6, 2, 8, 2, 9, 0};
double y[10]={3, 6, 1, 7, 2, 87, 2, 7, 4, 1}; */
/*
int rutas[4]={3,0,4,0},nR=3;   //nR is the max of the number of routes per commodity
double a[4]={1,1,1,1};
double b[4]={1, 0, 0, 1};
double y[4]={1, 1, 1, 1};
double lambda[4]={1.,1.,1.,1.};
*/

int rutas[4]={3,4,0,0},nR=2,nd=2,pq=0,r=0;   //nR is the max of the number of routes per commodity
double a[4]={1,1,1,1};
double b[4]={1, 1, 1, 1};
double y[4]={0.75, 0, 3, 0.75};
double lambda[4]={0,0,0,0};
double pi[2] ;

/*	printf( "The cardinal of I0 is %d\n", cardI0 );
	printf( "The cardinal of I1 is %d\n", cardI1 );
	printf( "The value of pi0 is %f and for pi is %f \n", pi0 ,pi);
	printf( "The routes with b>0 are: ");
	cont=0;
	while (*(pI1+cont)!=0)
	{	
		printf(" %d ", *(pI1+cont));
		cont++;
	}
	printf( "\n"); */

	qksp(a,b,y,nd,nR,rutas,lambda,pi);
	printf( "The values of lambda are: ");
	for (pq=0;pq<nd;pq++)
	{
		printf("\n For the commodity %d the values of  lambda are:",pq+1 );
		r=pq+1;
		while (r != 0)
		{		
			printf(" %f ", lambda[r-1]);
			r=rutas[r-1];	
		}
	}
	if (nd>1) printf("\n The values of pi are: "); else printf("\n The value of pi is: "); 
	for (pq=0; pq<nd;pq++)	printf(" %f ,",pi[pq]);
	printf(" \n  \n");
}
