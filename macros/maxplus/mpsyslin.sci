//
//=================================================================
// SYSTEMES LINEAIRES MAXPLUS (CREATION ET OPERATIONS ELEMENTAIRES)
//================================================================
//
function [sl]=mpsyslin(a,b,c,d,x0)
//
[lhs,rhs]=argn(0)
//
if rhs==1 then [m,n]=size(a)
  sl=tlist(['mpls','A','B','C','D','X0'],%zeros(n,n),..
      %eye(n,n),#(a),%zeros(n,n),%zeros(n,1))
else 
  if rhs==2 then error('mpsyslin: not enough arguments')  
  elseif rhs>2 then 
    //mpsyslin(A,B,C [,D [X0]])
    if type(a)<>[1,5,257,261] then
      error('mpsyslin : A must be a square matrix of numbers')
    end
    [ma,na]=size(a);
    if ma<>na then 
      error('mpsyslin : A must be a square matrix of numbers')
    end
    if type(b)<>[1,5,257,261] then
      error('mpsyslin : B must be a  matrix of numbers')
    end
    [mb,nb]=size(b);
    if na<>mb&mb<>0 then 
      error('mpsyslin : row dimension of B do not agree dimensions of A')
    end
    if type(c)<>[1,5,257,261] then
	error('mpsyslin : C must be a  matrix of numbers')
    end
    [mc,nc]=size(c);
    if na<>nc&nc<>0 then 
	error('mpsyslin : column dimension of C do not agree dimensions of A')
    end
    if rhs<5 then
	  x0=%zeros(na,1)
    else
          if type(x0)<>[1,5,257,261] then
	    error('mpsyslin : X0 must be a vector of numbers')
           end
	  [mx,nx]=size(x0);
          if mx<>na|nx<>min(na,1) then 
	    error('mpsyslin : dimensions of X0 do not agree')
           end
    end
    if rhs<4  then
	    d=%zeros(na,na)
     else
	    if type(d)<>[1,5,257,261] then
	      error('mpsyslin : D must be a  matrix of numbers or polynomials')
	    end
	    [md,nd]=size(d);
	    if md<>na|nd<>na then 
	      error('syslin : column dimension of D do not agree dimensions of A')
	    end
     end
	    sl=tlist(['mpls','A','B','C','D','X0'],#(a),#(b),#(c),#(d),#(x0))
  end 
end
endfunction	
