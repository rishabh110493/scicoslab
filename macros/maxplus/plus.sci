
function [B]=plus(A)
if type(A)<>257 then 
	error('plus requires a full max-plus matrix')
end
B=maxplus(hplus(plustimes(A)))
endfunction
