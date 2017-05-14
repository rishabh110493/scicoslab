
function a=%mps_c_talg(b,c)
if c<>#([]) then a=[b,sparse(c)]; else a=b; end,
endfunction
