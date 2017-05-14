
function [k]=includespan(A,B,varargin)
[lhs,rhs]=argn(0)
if rhs==2 then
	precision=getprecision([A,B])
elseif rhs==3 then
	precision=varargin(1)
else
	error('INCLUDESPAN requires two or three arguments')
end
if ((type(A)<>257)|(type(B)<>257)) then
	error('inputs must be full max-plus matrices')
      end
if size(A,1)<>size(B,1) then
  error('incompatible dimensions') 
end
k=hinclude_span(tropical(A,0),tropical(B,0),precision)
if k==1 then
	k=%t
	else
	k=%f
end
endfunction
