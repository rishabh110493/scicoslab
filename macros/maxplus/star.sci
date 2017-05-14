function [B]=star(A)
if type(A)<>257 then 
	error('star requires a full max-plus matrix')
end
B=maxplus(hstar(plustimes(A)))
endfunction
