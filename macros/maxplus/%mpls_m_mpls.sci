//
//=============
//MISE EN SERIE
//=============
//
function [s]=%mpls_m_mpls(s2,s1)
//
// computes S1*S2 in state-space form.
//
[a1,b1,c1,d1,x1]=s1(2:6);
[a2,b2,c2,d2,x2]=s2(2:6);
[n1,n1]=size(a1);
[n2,n2]=size(a2);
[n1,nb1]=size(b1);
[nc2,n2]=size(c2);
a1=[a1,%zeros(n1,n2);%zeros(n2,n1),a2];
d1=[d1,%zeros(n1,n2);b2*c1,d2];
b1=[b1;%zeros(n2,nb1)];
c1=[%zeros(nc2,n1),c2];    
s=tlist(['mpls','A','B','C','D','X0'],a1,b1,c1,d1,[x1;x2]);
endfunction
