
function [k]=karp(B,varargin)
//chi(B')_entry 
[lhs,rhs]=argn(0)
if rhs==1 then
	entry=1
elseif rhs==2 then
	entry=varargin(1)
else
	error('Karp requires one or two arguments")
end
if type(B)==257 then
	[ij,a,s]=spget(sparse(B))
elseif type(B)==261 then
	[ij,a,s]=spget(B)
else
	error('Karp requires a max-plus (full or sparse) matrix')
end
k=#(hkarp(ij',tropical(a,0),s(1),entry))
endfunction
