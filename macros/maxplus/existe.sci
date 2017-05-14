
function [ex]=existe(col1,col2)
//      La fonction "existe" :
//    Le vecteur résultat "ex" donne les cases, par rapport 
//    au vecteur "col2", des valeurs communes entre les deux
//    vecteurs colonnes "col1" et "col2".
  ex=[]
  [a,b,c]=intersect(col1,col2)
  while c~=[] do
    ex=[ex,c]
    col2(c)=0
    [a,b,c]=intersect(col1,col2)
  end
endfunction
