

function [chi,v,pi,N,N2]=howard01(A0,A1)
//howard semimarkov algorithm 
// computes the cycle time of the system x(k)=A0*x(k)+A1*x(k-1)
// syntax : howard01(A0: max plus matrix, A1: max plus matrix)
// matrices can be full or sparse 
if type(A0)==257 then
	[ij,a0,s]=spget(sparse(A0))
elseif type(A0)==261 then
	[ij,a0,s]=spget(A0)
else
	error('first argument must be a max-plus (full or sparse) matrix')
end
T=zeros(size(a0,1),1)
if type(A1)==257 then
	[ij2,a1,s2]=spget(sparse(A1))
elseif type(A1)==261 then
	[ij2,a1,s2]=spget(A1)
else
	error('second argument must be a max-plus (full or sparse) matrix')
end
T=[T;ones(size(a1,1),1)]
if [a0;a1]==#([])
	error('zero matrix in HOWARD')
end
[chi1,v1,pi,N,N2]=hsemihoward([ij;ij2]',[tropical(a0,0);tropical(a1,0)],s(1),T)
chi=#(chi1)
v=#(v1)
pi=pi+1
endfunction
