

function [F,q,w]=Wardrop(H,d,l,r,a,pre,niter)
//function [F,q,ww]=Wardrop(H,d,l,r,a,k,pre,niter)
//
// Equilibre de Wardrop temps terme lineaire
// plus un terme quadratique
//
k=1;
R=diag(sparse(r));
err=1;
[m,n]=size(H);
un=ones(n,1);
unm=ones(m,1);
nd=size(d,2);
und=ones(nd,1);
w=ones(m,nd);
D=full(d*und);
Q=R;
F=r;
sq=diag(sparse(un));
q=r*ones(1,nd);
//
// Resolution du probleme agrege
//
iter=0;
printf("  ")
printf("==========================")
printf("Wardropn/Q/%4d/%4d/%4d/",m,n,nd)
printf("==========================")
printf("  ")
printf("------------------")
printf("| iter |  erreur |")
printf("------------------")
iter=0;
ac=a;
// wold=0;
ww=0;
while niter>iter & err>pre
  ac=ac/k;
  iter=iter+1;
  DL=D*sqrt(nd)+H*sq*R*l+a*ww
  ww=lusolve(H*sq*R*H'+a*speye(m,m),DL);
//  printf("%2.1e|%2.1e",max(ww-wold),min(ww-wold));
  f=max(0,full(R*(H'*ww-l)));
  sq=diag(sparse(sign(f)));
  err=norm(f-F,'inf')
  printf("|  %2d  | %2.1e |",iter,err)
  F=f
//  wold=ww
end
errV=norm(diag(sparse(sign(F)))*(R*(H'*ww-l)-F))/(norm(F)+1.e-10);
errQ=norm(H*F-sqrt(nd)*D)/(sqrt(nd)*norm(D)+1.e-10);
printf("===========================");
printf("|errV=%2.1e|errQ=%2.1e|",errV,errQ);
printf("===========================");
//
// Iteration pour assurer la positivite
// des flots individuels.
//
iter=0;
err=1;
ac=a;
for i=1:nd
  q(:,i)=f/nd;
  w(:,i)=ww;
end
while niter>iter & err>pre
  ac=ac/k;
  iter=iter+1;
//  wold=ww; 
  for i=1:nd
    qi=q(:,i);
    fi=f-qi;
    admit=diag(sparse(sign(qi)));
    iteri=0;
    erri=1;
//    w(:,i)=unm;
    while 8>iteri & erri>pre
      iteri=iteri+1;
      di=d(:,i)+H*admit*(fi+R*l)+a*w(:,i);
      ww=lusolve(H*admit*R*H'+a*speye(m,m),full(di));
      qi=max(full(R*(H'*ww-l)-fi),0);
      admit=diag(sparse(sign(qi)));
//      erri=norm(ww-wold);
      erri=norm(ww-w(:,i));
//      printf("|  %2d  | %2.1e |",iteri,erri) //
      w(:,i)=ww;
//      wold=ww
    end
    q(:,i)=qi;
    f=fi+qi;
  end 
  f=q*und
  err=norm(f-F,'inf')
//printf("------------------")
printf("|  %2d  | %2.1e |",iter,err)
//printf("------------------")
F=f
end
errV=0;
errQ=0;
//admit=diag(sparse(sign(F)));
//W=lusolve(H*admit*R*H'+ac*speye(m,m),full(H*admit*(F+R*l)));
//W=W-min(W);
for i=1:nd
  errV=errV+norm(diag(sparse(sign(q(:,i))))*(R*(H'*w(:,i)-l)-F));
//  errV=errV+norm(diag(sparse(sign(q(:,i))))*(R*(H'*ww-l)-F));
   errQ=max(errQ,norm(H*q(:,i)-d(:,i),"inf"));
end
printf("===========================");
printf("|errV=%2.1e|errQ=%2.1e|",errV/(nd*norm(F)+1.e-10),errQ/(1.e-10+norm(q,"inf")));
printf("===========================");
endfunction
