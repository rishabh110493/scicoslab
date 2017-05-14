
function [chi,v,pi,N,N2]=howard(B)
//howard algorithm 
//see Howard.help for more info
if type(B)==257 then
	[ij,a,s]=spget(sparse(B))
elseif type(B)==261 then
	[ij,a,s]=spget(B)
else
	error('HOWARD requires a max-plus (full or sparse) matrix')
end
if a==#([])
	error('zero matrix in HOWARD')
end
[chi1,v1,pi,N,N2]=hhoward(ij',tropical(a,0),s(1))
chi=#(chi1)
v=#(v1)
pi=pi+1
endfunction
