
function [k]=WEAKBASIS0(A,varargin)
[lhs,rhs]=argn(0)
if rhs==1 then
	precision=getprecision(A)
elseif rhs==2 then
	precision=varargin(1)
else
	error('WEAKBASIS requires one or two arguments')
end
if (type(A)<>257) then
	error('input must be a full max-plus matrix')
end
k=tropical(hweakbasis(tropical(A,0),precision),1)
endfunction
