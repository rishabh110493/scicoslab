
function [k]=inspan(A,b,varargin)
//
//returns true if b is in span(A)
// for full matrices only
//
[lhs,rhs]=argn(0)
//
if rhs==2  then 
  precision=getprecision(A) 
elseif rhs==3  then 
  precision=varargin(1)
else 
  error('INSPAN requires two or three arguments') 
end
//      
if ((type(A)<>257)|(type(b)<>257)) then
error('inputs must be full max-plus matrices')  
end
//
if size(A,1)<>size(b,1) then
  error('incompatible dimensions') 
end
//      
u=hin_span(tropical(A,0),tropical(b,0),precision)
//
if u==1 then
  k=%t 
else	
  k=%f
end
endfunction
