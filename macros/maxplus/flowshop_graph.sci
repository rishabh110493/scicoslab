//
//

//
function [g,T,N]=flowshop_graph(E,m,p,hh)
//
//===========================================
// A PARTIR DES  MATRICES
//   - E(mach, palette) -->temps de  tache
//   - m(mach) nbre de machines
//   - p(palette) nbre de palettes
// CONSTRUIT UN GRAPHE REPRESENTANT LE FLOWSHOP
// et construit la matrice des dates T
// et des compteurs N.
//===========================================
//
//
[nmach,npiece]=size(E)
EE=string(E); pp=string(p); mm=string(m);
nd=0; l=0*ones(1,nmach); d=0*ones(1,npiece);
h=[]; t=[]; ce=[]; e=#([]); x=[]; y=[]; kk=hh*nmach/npiece*1.3; N=%0; T=%0;
for i=1:npiece,
 for j=1:nmach, 
  if E(j,i)==%0 then 
    A(j,i)=0;
    if l(j)<>0 then l(j)=l(j)+1, end ; 
    if d(i)<>0 then d(i)=d(i)+1, end ; 
  else  
    nd=nd+1 ;
    A(j,i)=nd ; x(nd)=i*kk+kk; y(nd)=j*hh+hh; c(nd)=1;
    if l(j)<>0 then hc=A(j,i-l(j)), h=[h,hc], t=[t,nd], 
        e=[e,E(j,i-l(j))], ce=[ce,1], T(hc,nd)=E(j,i-l(j)), N(hc,nd)=%1, end ;
    if d(i)<>0 then hc=A(j-d(i),i), h=[h,hc], t=[t,nd], 
        e=[e,E(j-d(i),i)], ce=[ce,1], T(hc,nd)=E(j-d(i),i), N(hc,nd)=%1, end ;
    if d(i)==0 then 
     nd=nd+1; x(nd)=kk*i+kk*3/4  ; y(nd)=hh; c(nd)=11;
     h=[h,nd]; t=[t,A(j,i)]; e=[e,p(i)]; ce=[ce,11]; bp(i)=nd;
     N(nd,A(j,i))=p(i); T(nd,A(j,i))=%1;
//      s(nd)=2, 
    end ; 
    d(i)=1;
    if l(j)==0 then 
      nd=nd+1; x(nd)=kk  ; y(nd)=j*hh+hh*3/4 ; c(nd)=11;
       h=[h,nd]; t=[t,A(j,i)]; e=[e,m(j)]; ce=[ce,11]; bm(j)=nd;
       N(nd,A(j,i))=m(j); T(nd,A(j,i))=%1;
//      s(nd)=2, 
    end ; 
    l(j)=1; 
    end ;
 end ; 
//   s(A(nmach-d(i)+1,i))=1;
nd=nd+1; x(nd)=kk*i+kk*3/4  ; y(nd)=(nmach+1)*hh+hh ; c(nd)=13;
hc=A(nmach-d(i)+1,i);h=[h,hc]; t=[t,nd];
e=[e,E(nmach-d(i)+1,i)]; ce=[ce,1]; 
T(hc,nd)=E(nmach-d(i)+1,i);N(hc,nd)=%1; 
h=[h,nd]; t=[t,bp(i)]; e=[e,0]; ce=[ce,32];
T(nd,bp(i))=%1; N(nd,bp(i))=%1;
end ;
for j=1:nmach, 
// s(A(j,npiece-l(j)+1))=1;
nd=nd+1; x(nd)=kk*(npiece+1)+kk  ; y(nd)=j*hh+hh*3/4 ; c(nd)=13;
hc=A(j,npiece-l(j)+1); h=[h,hc]; t=[t,nd];
e=[e,E(j,npiece-l(j)+1)]; ce=[ce,1];
T(hc,nd)=E(j,npiece-l(j)+1); N(hc,nd)=%1;
h=[h,nd]; t=[t,bm(j)]; e=[e,0]; ce=[ce,32];
T(nd,bm(j))=%1; N(nd,bm(j))=%1;
end ;
g=make_graph('flowshop',1,nd,h,t);
g('node_x')=x';
g('node_y')=y';
g('node_color')=c';
g('edge_color')=ce;
//g('edge_label')=e;
g('edge_length')=plustimes(e);
g('edge_name')=string([1:edge_number(g)]);
//g('node_type')=s';
show_graph(g);
T=sparse(T'); N=sparse(N');
endfunction
