function M=%s_2_hm(s,M)
// Copyright INRIA
//s>M
if size(s,'*')<> 1 then
  error('> : arguments have incompatible dimensions')
end
M('entries')=s>M('entries')
endfunction
