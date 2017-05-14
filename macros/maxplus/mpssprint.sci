//
//=====================================
// PRETTY PRINT MAX-PLUS LINEAR SYSTEMS
//=====================================
//
function []=mpssprint(sl,out)
// pretty print of a linear system in state-space form
// sl=(A,B,C,D) syslin list.
[lhs,rhs]=argn(0)
mess='system cannot be displayed in this page'
fil=%f
if rhs==1 then 
  out=%io(2),
else
  if type(out)==10 then
  out=file('open',out,'unknown')
  fil=%t
  end
end

//
// x=dx+ax'+ bu
//
write(out,' ')
sgn='+'
ll=lines();ll=ll(1)
[a,b,c,d]=sl(2:5)
a=full(a)
b=full(b)
c=full(c)
d=full(d)
withd=%ones(1,size(d,1))*d*%ones(size(d,2),1)<>%0
na=size(a,1)
nc=size(c,1)
nb=size(b,2)
if na>0 then
  blank=[];for k=1:na,blank=[blank;'           '],end

  ta=%cv(a);
  tb=%cv(b);
  if withd then td=%cv(d);end
  //
  blank=part(blank,1:4)
  if na==1 then
    if withd then
      t=['    ';'x = ']+[' ';td]+['  ';'x + ']+['  ';ta]+[' ';'x''']
    else
      t=['    ';'x = ']+['  ';ta]+[' ';'x''']
    end
  else
    blank([na/2,na/2+1])=['    ';'x = ']
    if withd then
      t=blank+td
      blank([na/2,na/2+1])=['    ';'x + ']
      t=t+blank+ta;
    else
      t=blank+ta
    end
  end
  if nb>0 then
    if na==1 then
      t=t+['    ';' + ']+[' ';tb]+[' ';'u   ']
    else
      blank([na/2,na/2+1])=['    ';'x''+ ']
      t=t+blank+tb
      t(na/2+1)=t(na/2+1)+'u   '
    end
  end
  n1=maxi(length(t))+1
  //
  n2=maxi(length(t))
  if n2<ll then
    write(out,t)
  else
    if n1<ll,
      if n2-n1<ll then
	write(out,part(t,1:n1)),
	write(out,' ')
	write(out,part(t,n1+1:n2),'(3x,a)')
      else          
	disp('x(n)=Dx(n)+Ax(n-1)+Bu(n)')
	disp(sl('A'),'A='),
	disp(sl('B'),'B='),
	disp(sl('D'),'D='),  // error(mess)
      end ;
    else 
     disp('x(n)=Dx(n)+Ax(n-1)+Bu(n)')
     disp(sl('A'),'A='),
     disp(sl('B'),'B='),
     disp(sl('D'),'D='),  // error(mess)
    end ;
  end ;
end
//
//y = cx 
//
if nc==0 then if fil then file('close',out);end;return,end
write(out,' ')
blank=[];for k=1:nc,blank=[blank;'           '],end
tc=%cv(c);

if na==0 then
  if nc==1 then 
    t='y = '+td+'u'
  else
    blank(nc/2+1)='y = '
    t=blank
    t(nc/2+1)=t(nc/2+1)+'u   '
  end
  n1=maxi(length(t))+1
else
  blank=part(blank,1:4);
  if nc==1 then 
    t='y = '+tc
  else
    blank(nc/2+1)='y = '
    t=blank+tc;
  end
  if nc==1 then 
    t=t+'x   '
  else
    t(nc/2+1)=t(nc/2+1)+'x   '
  end
end
n2=maxi(length(t))
if n2<ll then
  write(out,t)
else
  if n1<ll,
    if n2-n1<ll then
      write(out,part(t,1:n1)),
      write(out,' ')
      write(out,part(t,n1+1:n2),'(3x,a)')
    else 
      disp(sl('C'),'C='), //  error(mess)
    end
  else 
    disp(sl('C'),'C='),  // error(mess)
  end
end
if fil then file('close',out),end
endfunction

function ta=%cv(x)
[m,n]=size(x);
if m*n==0 then ta=' ',return,end;
frmt=format();frmt=10^frmt(2);
//x=round(frmt*x)/frmt;
t=[];
for k=1:m,t=[t;'|'],end;
ta=t;
for k=1:n,
  aa=string(x(:,k))
  for l=1:m
    if part(aa(l),1)<>'-' then
      aa(l)=' '+aa(l)
    end
  end
  nn=maxi(length(aa));
  aa=part(aa+blank,1:nn);
  ta=ta+aa+part(blank,1)
end;
ta=ta+t;
endfunction
