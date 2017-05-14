

function [v,Q,iter]=fluideHow(H,d,a,pre)
err=1
[m,n]=size(H)
v=ones(m,1)
un=ones(n,1)
q=diag(sparse(un/2.0))
iter=1
while err>pre 
  iter=iter+1
  disp(iter)
  w=lusolve(H*q*H'+a*speye(m,m),d);
  q=diag(sparse(un./sqrt(abs(H'*w))))
  err=norm(v-w,'inf')
  disp(err)
  v=w
end
Q=q*H'*w
endfunction
