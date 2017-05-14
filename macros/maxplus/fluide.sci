

function [v,Q,iter]=fluide(H,d,r,a,pre)
//
// Reseau d'eau
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
printf("Fluide/C/%5d/%5d/",m,n)
printf("=====================")
printf("  ")
printf("------------------")
printf("| iter |  erreur |")
printf("------------------")
while err>pre 
  iter=iter+1
  d1=2*d-H*q1
  w=lusolve(H*q*H'+a*speye(m,m),d1);
  q1=(q*H'*w+q1)/2
  q=R*diag(sparse(un./abs(q1)))
  err=norm(v-w,'inf')
  printf("|  %2d  | %2.1e |",iter,err)
  v=w
end
Q=q1
endfunction
