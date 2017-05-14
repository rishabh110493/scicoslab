function y=mtlb_strcmp(A,B)
// Copyright INRIA
// Emulation function for strcmp() Matlab function
// V.C.

if type(A)==10 & type(B)==10 then
  y=A==B
else
  y=%F
end
endfunction
