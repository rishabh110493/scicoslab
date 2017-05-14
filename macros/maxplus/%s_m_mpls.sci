//
//idem avec un scalaire standard
//
function [s]=%s_m_mpls(m,s)
[a,b,c,d,x]=s(2:6);
s=tlist(['mpls','A','B','C','D','X0'],a,b,#(m)*c,d,x);
endfunction
