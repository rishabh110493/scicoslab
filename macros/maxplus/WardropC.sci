

function [W,f,iter]=WardropC(H,d,a,pre)
//
// tentative wardrop cout cubique
// pour memoire
//
pen=0.01
ci=10
C=0.1
err=100
[m,n]=size(H)
V=ones(m,1)
un=ones(n,1)
nd=size(d,2)
D=d*ones(nd,1)
Q=diag(sparse(un*C))
qs=zeros(n,1)
QS=qs 
q=sparse(ones(n,nd)*ci)
iter=1
while err>pre 
  iter=iter+1
  DD=nd*D+H*Q*qs
  W=lusolve(H*Q*H'+a*speye(m,m),DD);
  QS=(H'*W-qs)/nd
  Q=diag(sparse(max(0.001,C*real(un./sqrt(QS)))))
  qs=spzeros(n,1)
  for i=1:nd
    di=d(:,i)+H*diag(QS)*q(:,i)
    w=lusolve(H*sparse(diag(q(:,i)))*H'+a*speye(m,m),di);
    qqq=H'*w-QS
    qs=qs+qqq
     q(:,i)=sparse(max(pen,ci*real(un./sqrt(qqq))))
  end 
  err=norm(V-W,'inf')
  disp(iter,err)
  V=W
end
f=Q
endfunction
