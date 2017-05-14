function [w]=astarb(A,b)
// calcule star(A)*b pour A et B maxplus
// sparse
  [n,n]=size(A);
  Ab=[[A';b'],[%zeros(n,1);%1]];
  [ij,v,nm]=spget(sparse(Ab));
  w=hFordBellman(ij',plustimes(v'),n+1,n+1);
  w=#(w([1:n]))
endfunction
