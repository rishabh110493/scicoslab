
function a=%mps_c_s(b,c)
if c<>[] then a=[b,sparse(#(c))], else a=b, end;
endfunction
