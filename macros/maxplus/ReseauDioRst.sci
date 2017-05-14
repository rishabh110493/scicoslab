

function [v,Q]=ReseauDioRst(H,d,r,a,pre,niter)
//
// Reseau de resistances laissant passer le courant
// dans une seule direction
//
err=1
[m,n]=size(H)
v=ones(m,1)
un=ones(n,1)
R=diag(sparse(r))
q1=r
q=R
iter=0
printf("  ")
printf("=====================")
printf("Wardrop1/Q/%4d/%4d/",m,n)
printf("=====================")
printf("  ")
printf("------------------")
printf("| iter |  erreur |")
printf("------------------")
while err>pre & iter<niter
  iter=iter+1
//  pause
  w=lusolve(H*q*H'+a*speye(m,m),d);
  q1=H'*w
  q=R*diag(sparse(max(0,sign(q1))))
  err=norm(v-w,'inf')
  printf("|  %2d  | %2.1e |",iter,err)
  v=w
end
Q=R*max(0,q1)
endfunction
