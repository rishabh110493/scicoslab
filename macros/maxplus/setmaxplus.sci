
function [%0,%1,%top,#]=setmaxplus()
%0=maxplus(-%inf)
%1=maxplus(0)
%top=maxplus(%inf)
%talg_setalg(1,-%inf,0,%inf)
#=maxplus
endfunction
