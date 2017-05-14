
function a=%talg_c_mps(b,c)
if b<>#([]) then a=[sparse(b),c]; else a=c; end,
endfunction
