
//function a=%talg_round(b)
//a=maxplus(round(plustimes(b)))

//function a=%zeros(n,varargin)
//[lhs,rhs]=argn(0)
//if rhs==1 then
//	a=%0*%ones(n)
//elseif rhs==2 then
//	a=%0*%ones(n,varargin(1))
//else
//	error('%zero requires one or two arguments")
//end

function [%0,%1,%top,#]=setmaxplus()
%0=maxplus(-%inf)
%1=maxplus(0)
%top=maxplus(%inf)
%talg_setalg(1,-%inf,0,%inf)
#=maxplus
endfunction
