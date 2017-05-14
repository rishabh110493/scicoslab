//-------------------------------------------------------------
//                 Micro finance Problem 
//-------------------------------------------------------------
//
//          We have to choose between two investments :
//   1) the first is determinic with gain 1
//   2) the second is stochastic with two possible random gains :
//        -  a with probability p
//        -  b with probability q
//
//     We maximize the actualized gain with actualization l. 
//
p=0.5, q=0.5 , a=0 , b=3, l=0.01
H=sparse([1 0 0; 0 p q])
D=sparse(#([1 1; a a; b b]))
[v,s]=costo(D,H,l)
//
//-------------------------------------------------------------
//             Tests costo
//-------------------------------------------------------------
//
n=20;  m=20; l=0.01;
D=#(sprand(n,m,1));
H=sprand(m,n,0.0005);
H(:,1)=1;
D(:,1)=%ones(n,1);
rr=sparse(ones(m,1)) ./ (H*sparse(ones(n,1)));
H=sparse(diag(rr))*H;
timer(); [v,s]=costo(D,H,l); timer()
v(1:10)
//
//-----------------------------------------------------------
// Approximation des pbs ergodiques par des pbs actualises
//----------------------------------------------------------
//
eps=0.0001;
D=sparse(#([1 0; 0 1-eps]))
H=speye(2,2)
[v,s]=costo(D,H,0.1)
//
//-------------------------------------
//  Howard deterministe et stochastique
//-------------------------------------
//
n=5; l=0.01;
D=#(sprand(n,n,1));
H=speye(n,n);
D=D+#(0.001*H);
timer(); [w,s]=costo(D,H,l); timer()
timer();[ll,v,p,c,n]=howard(D);timer()
norm(w-plustimes(ll))
ll(1:10)
//
//----------------------------------------
// Algebre standard et Algebre quadratique
//----------------------------------------
//
n=200; m=1000;
H=spzeros(n,m);
for j=1:m
  ij=ceil(n*rand(2,1));
  H(ij(1),j)=1;
  H(ij(2),j)=-1;
  end
d=rand(n,1);
moy=d'*ones(n,1)/n;
d=d-moy;
timer();[v1,q1,iter1]=mwardrop(H,d,0.01,0.001);timer() 
timer();[v1,q1,iter1]=fluide(H,d,0.0001,0.000001);timer()   
timer();[v2,q2,iter2]=hamam(H,d,0.0001,0.000001);timer()
norm(v1-v2)/norm(v1)
qq1=q1\ones(m,1);
qq2=q2\ones(m,1);
norm(qq1-qq2)/norm(qq1)
//
//------------------------
// Comparaison algo reseau
//------------------------
//
// Newton primal
//
x=1; d=2; n=5;
for i=1:n
  x=x/2+d/(2*x)
end
for i=1:n
  x=(3*d*x-x*x)/(d+x)
end
for i=1:n
  x=sqrt(x)*d
end

