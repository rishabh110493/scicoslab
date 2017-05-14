function [s]=flowshop(E)
//
//===================================
// A PARTIR DE LA MATRICE E DES TEMPS
// DES TACHES (mach, piece) --> tache
// CONSTRUIT UN SYST. LIN. MAX PLUS s.
//===================================
//
//
[nmach,npiece]=size(E)
A=sparse(%zeros(nmach*npiece,nmach*npiece))
D=A, X0=sparse(%zeros(nmach*npiece,1))
B=sparse(%zeros(nmach*npiece,nmach+npiece))
C=sparse(%zeros(nmach+npiece,nmach*npiece))
l=0*ones(1,nmach); d=0*ones(1,npiece);
for i=1:npiece,
 for j=1:nmach,
  ij=i+(j-1)*npiece;
  if E(j,i)==%0 then 
    if l(j)<>0 then l(j)=l(j)+1, end ; 
    if d(i)<>0 then d(i)=d(i)+1, end ; 
   else  
    if l(j)<>0 then D(ij,ij-l(j))=E(j,i-l(j)), end ;
    if d(i)<>0 then D(ij,ij-d(i)*npiece)=E(j-d(i),i), end ;
    if d(i)==0 then B(ij,i)=%1,  end , d(i)=1;
    if l(j)==0 then B(ij,j+npiece)=%1, end , l(j)=1; 
    end;
  end ; 
  C(i,ij-(d(i)-1)*npiece)=E(nmach-d(i)+1,i); 
end ;
for j=1:nmach, 
C(j+npiece,j*npiece-l(j)+1)=E(j,npiece-l(j)+1), 
end ;
s=mpsyslin(A,B,C,D,X0);
endfunction
