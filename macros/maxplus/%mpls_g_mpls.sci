//
//==============
// CONCATENATION
//==============
//
function [s]=%mpls_g_mpls(s1,s2)
//
// computes S1|S2 that is : concatenation of systems
//
[a1,b1,c1,d1,x1]=s1(2:6);
[a2,b2,c2,d2,x2]=s2(2:6);
[n1,n1]=size(a1);
[n2,n2]=size(a2);
[n1,nb1]=size(b1);
[n2,nb2]=size(b2);
[nc1,n1]=size(c1);
[nc2,n2]=size(c2);
a1=[a1,%zeros(n1,n2);%zeros(n2,n1),a2];
d1=[d1,%zeros(n1,n2);%zeros(n2,n1),d2];
b1=[b1,%zeros(n1,nb2);%zeros(n2,nb1),b2];
c1=[c1,%zeros(nc1,n2);%zeros(nc2,n1),c2];
s=tlist(['mpls','A','B','C','D','X0'],a1,b1,c1,d1,[x1;x2]);
endfunction
