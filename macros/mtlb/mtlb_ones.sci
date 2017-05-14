function r=mtlb_ones(a)
// Copyright INRIA
// Emulation function for ones() Matlab function
// V.C.

if and(size(a)==[1 1]) then
  r=ones(a,a)
else
  tmp=list()
  for k=1:size(a,"*")
    tmp(k)=a(k)
  end
  r=ones(tmp(1:$))
end
endfunction
