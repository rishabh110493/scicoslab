
function [precision]=getprecision(A)
u=mnorm(A)
if u==%inf
        precision=0.0000000001
else
	precision=0.0000000001*u
end
endfunction
