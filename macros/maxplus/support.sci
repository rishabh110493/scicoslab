function []=support() 
//  tlist(['StopTime';'Mtrans';'cout';'Einit';'Eps';'Efilt';'MTfilt';'Cmoy';'Popt';'Copt'],
//                   M,C,E,Eps,[],[],[],[],[])
//  Mtrans : tlist(['mat';'nbr';'y1';'y2'],nrb,M1,M2) : matrices de transition.
//  cout : [c1,c2]  :  c1 et c2 vecteurs colonnes des couts  
//  Einit : Loi initiale
//  Eps : Nombre de bits de quantification    
//  Efilt : Etats obtenus
//  MTfilt : Matrice de transition obtenue
//  Cmoy : Cout moyen
//  Popt : Politique optimale
//  Vopt : Cout optimal

 global %StopTime 
 nbr_col=3     
 [n,n]=size(%StopTime.Mtrans.y1)
 y=%StopTime.Mtrans.nbr
 M=[]
 for i=1:y do
   M=[M,%StopTime.Mtrans(2+i)]
 end
 reel=%StopTime.Einit
 q=reel
 entier=quantifier(q,n,%StopTime.Eps)
 vect=(2^%StopTime.Eps)^(nbr_col-1-(0:nbr_col-1)')
 colonne=entier(:,1:nbr_col)*vect
 while q~=[] do
     qq=[]
     [sx,sy]=size(q)
     h=sx*y
     q1=(matrix((q*M)',n,h))'
     den=sparse([(1:h)',(1:h)'],q1*ones(n,1).\1)
     qq=[qq;den*q1]          
     ii=find(1-qq(:,1)<10^(-10))
     qq(ii,:)=[]
     entier1=quantifier(qq,n,%StopTime.Eps)
     colonne1=entier1(:,1:nbr_col)*vect
     [ex]=existe(colonne,colonne1)
     colonne1(ex)=[]
     [colonne1,d]=unique(colonne1)
     colonne=[colonne;colonne1]
     qq(ex,:)=[]
     qq=qq(d,:)
     reel=[reel;qq]
     entier1(ex,:)=[]
     entier1=entier1(d,:)
     entier=[entier;entier1]
     q=qq
 end
 [dim,nn]=size(entier)
 re1=eye(1,n)
 ent1=(2^%StopTime.Eps-1)*re1
 reel=[reel;re1]
 entier=[entier;ent1]
 dim=dim+1
 colonne=entier(:,1:nbr_col)*vect
 [colonne,b]=sort(colonne)
 entier=entier(b,:)
 reel=reel(b,:)
 mat=sparse([],[],[dim,dim])
 for k=1:y do
   f=reel(2:dim,:)*%StopTime.Mtrans(2+k)
   prob=f*ones(n,1)
   den=sparse([(1:dim-1)',(1:dim-1)'],prob.\1)
   ent=quantifier(den*f,n,%StopTime.Eps)
   ent=[ent1;ent]
   col=ent(:,1:nbr_col)*vect
   cor=corresp(colonne,col)
   mat=mat+sparse([(1:dim)',cor],[0;prob],[dim,dim])
 end
 mat(1,1)=1
 b=dim+1-(1:dim)
 entier=entier(b,:)
 reel=reel(b,:)
 cc=reel(:,1)
 mat=mat(b,b)
 %StopTime.Efilt=entier
 %StopTime.MTfilt=mat
endfunction
