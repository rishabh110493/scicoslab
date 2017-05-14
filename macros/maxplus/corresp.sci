
function [cor]=corresp(col1,col2,dim)
//      Prend deux vecteurs "col1" et "col2" prenant les memes
//    valeurs, mais pas dans le meme ordre, le vecteur 
//    résultat "cor" donne les cases du vecteur "col1"
//    dont les valeurs correspondent à celles du vecteur
//    "col2" mises en ordre croissant. 
//       Si cor(1)=3 par exemple, alors la col1(3)=col2(1).
  for i=1:dim do
    [a,b]=min(abs(col1-col2(i)))
    cor(i)=b
  end
endfunction
