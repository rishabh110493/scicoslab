

function [quan]=quantifier(q,n,l)
//    Prend un vecteur ligne (proba) "q", sa taille
// "n" et le nombre de bits de quantification "l", et
//  retourne le vecteur quantifié correspondant en
//  arrondissant au plus proche des entier, et on 
//  redistribuant le surplus (positif ou negatif).
  quan=round((2^l-1)*q)
  dif=(2^l-1)-sum(quan,'c')
  i=find(dif~=0)
  r=dif(i)./abs(dif(i))
  reste=zeros(quan)
  for j=1:length(i) do
    reste(i(j),1:abs(dif(i(j))))=r(j)
  end
  quan=quan+reste
endfunction
