function [v,p]=costoa(D,H,l,pre)
err=1
[m,n]=size(H)
v=-%inf*ones(n,1)
id=(1+l)*speye(n,n)
iter=1
while err>pre 
  iter=iter+1
  [h,p,c]=amax(D,H*v)
  w=lusolve(id-p*H,c)
  err=norm(v-w,'inf')
  v=w
end
endfunction
