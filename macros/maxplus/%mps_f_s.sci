
function a=%mps_f_s(b,c)
if c<>[] then a=[b;sparse(#(c))], else a=b, end;
endfunction
