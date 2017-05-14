function a=%mps_n_s(b,c)
if c==[], 
a=%T;
else a=b<>sparse(#(c));
end;
endfunction
