function [s]=%talg_string(n)
s=string(tropical(n,0));
if s<>[], s=strsubst(s,'-Inf','.'), end ;
endfunction
