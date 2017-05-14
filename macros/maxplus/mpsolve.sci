
function [W]=mpsolve(A,B,varargin)
[lhs,rhs]=argn(0)
if rhs==2 then
	precision=getprecision([A,B])
elseif rhs==3 then
	precision=varargin(1)
else
	error('SOLVE requires two or three arguments')
end
if ((type(A)<>257)|(type(B)<>257)) then
	error('inputs must be full max-plus matrices')
end
W=tropical(hsolve3(tropical(A,0),tropical(B,0),precision),1)
endfunction
