//
//=================
//MISE EN PARALLELE
//=================
//
function [s]=%mpls_a_mpls(s1,s2)
//
//  Ss=S1+S2 in state-space
//
//[s1 s2]=sysconv(s1,s2)
[a1,b1,c1,d1,x1]=s1(2:6);
[a2,b2,c2,d2,x2]=s2(2:6);
[n1,n1]=size(a1);
[n2,n2]=size(a2);
a1=[a1,%zeros(n1,n2);%zeros(n2,n1),a2];
d1=[d1,%zeros(n1,n2);%zeros(n2,n1),d2];
s=tlist(['mpls','A','B','C','D','X0'],a1,[b1;b2],[c1,c2],d1,[x1;x2]);
endfunction
