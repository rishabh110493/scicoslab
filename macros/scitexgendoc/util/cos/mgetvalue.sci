function [ok,%1,%2,%3,%4,%5,...
             %6,%7,%8,%9,%10,...
             %11,%12,%13,%14,%15,...
             %16,%17,%18,%19,%20]=mgetvalue(%desc,%lables,%typ,%ini)

 global mydesc
 global mylables
 global mytyp
 global myini
 
 mydesc=%desc
 mylables=%lables
 mytyp=%typ
 myini=%ini

if %scicos_prob==%t then 
	ok=%f
        [%1,%2,%3,%4,%5,...
         %6,%7,%8,%9,%10,...
         %11,%12,%13,%14,%15,...
         %16,%17,%18,%19,%20]=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
return;end
[%lhs,%rhs]=argn(0)

%nn=prod(size(%lables))
if %lhs<>%nn+2&%lhs<>%nn+1 then error(41),end
if size(%typ)<>2*%nn then
  error('typ : list(''type'',[sizes],...)')
end
%1=[];%2=[];%3=[];%4=[];%5=[];
%6=[];%7=[];%8=[];%9=[];%10=[];
%11=[];%12=[];%13=[];%14=[];%15=[];
%16=[];%17=[];%18=[];%19=[];%20=[];

if exists('%scicos_context') then
  %mm=getfield(1,%scicos_context)
  for %mi=%mm(3:$)
    if execstr(%mi+'=%scicos_context(%mi)','errcatch')<>0 then
      disp(lasterror())
      ok=%f
      return
    end
  end
end

if %rhs==3 then  %ini=emptystr(%nn,1),end
ok=%t
while %t do
  %str=%ini;
  if %str==[] then ok=%f,break,end
  for %kk=1:%nn
    %cod=ascii(%str(%kk))
    %spe=find(%cod==10)
    if %spe<>[] then
      %semi=ascii(';')
      %cod(%spe)=%semi*ones(%spe')
      %str(%kk)=ascii(%cod)
    end
  end
  %noooo=0
  for %kk=1:%nn
    select part(%typ(2*%kk-1),1:3)
    case 'mat'
      if execstr('%vv=['+%str(%kk)+']','errcatch')<>0  then 
	%noooo=-%kk,break,
      end
      if and(type(%vv)<>[1 8]) then %noooo=-%kk,break,end
      //if type(%vv)<>1 then %noooo=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      [%mmmm,%nnnnn]=size(%vv)
      %ssss=string(%sz(1))+' x '+string(%sz(2))
      if %mmmm*%nnnnn==0 then
	if  %sz(1)>=0&%sz(2)>=0&%sz(1)*%sz(2)<>0 then %noooo=%kk,break,end
      else
	if %sz(1)>=0 then if %mmmm<>%sz(1) then %noooo=%kk,break,end,end
	if %sz(2)>=0 then if %nnnnn<>%sz(2) then %noooo=%kk,break,end,end
      end
    case 'vec'
      if execstr('%vv=['+%str(%kk)+']','errcatch')<>0  then 
	%noooo=-%kk,break,
      end
      if and(type(%vv)<>[1 8]) then %noooo=-%kk,break,end
      //if type(%vv)<>1 then %noooo=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssss=string(%sz(1))
      %nnnnn=prod(size(%vv))
      if %sz(1)>=0 then if %nnnnn<>%sz(1) then %noooo=%kk,break,end,end
    case 'pol'
      if execstr('%vv=['+%str(%kk)+']','errcatch')<>0  then 
	%noooo=-%kk,break,
      end
      if type(%vv)>2 then %noooo=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssss=string(%sz(1))
      %nnnnn=prod(size(%vv))
      if %sz(1)>=0 then if %nnnnn<>%sz(1) then %noooo=%kk,break,end,end
    case 'row'
      if execstr('%vv=['+%str(%kk)+']','errcatch')<>0  then 
	%noooo=-%kk,break,
      end
      if and(type(%vv)<>[1 8]) then %noooo=-%kk,break,end
      //if type(%vv)<>1 then %noooo=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      if %sz(1)<0 then
	%ssss='1 x *'
      else
	%ssss='1 x '+string(%sz(1))
      end
      [%mmmm,%nnnnn]=size(%vv)
      if %mmmm<>1 then %noooo=%kk,break,end,
      if %sz(1)>=0 then if %nnnnn<>%sz(1) then %noooo=%kk,break,end,end
    case 'col'
      if execstr('%vv=['+%str(%kk)+']','errcatch')<>0  then 
	%noooo=-%kk,break,
      end
      if and(type(%vv)<>[1 8]) then %noooo=-%kk,break,end
      //if type(%vv)<>1 then %noooo=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      if %sz(1)<0 then
	%ssss='* x 1'
      else
	%ssss=string(%sz(1))+' x 1'
      end
      [%mmmm,%nnnnn]=size(%vv)
      if %nnnnn<>1 then %noooo=%kk,break,end,
      if %sz(1)>=0 then if %nnnnn<>%sz(1) then %noooo=%kk,break,end,end
    case 'str'
      %vv=%str(%kk)
      if type(%vv)<>10 then %noooo=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssss=string(%sz(1))
      %nnnnn=prod(size(%vv))
      if %sz(1)>=0 then if %nnnnn<>1 then %noooo=%kk,break,end,end
    case 'lis'
      if execstr('%vv='+%str(%kk),'errcatch')<>0  then 
	%noooo=-%kk,break,
      end    
      if type(%vv)<>15& type(%vv)<>16 then %noooo=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssss=string(%sz(1))
      %nnnnn=size(%vv)
      if %sz(1)>=0 then if %nnnnn<>%sz(1) then %noooo=%kk,break,end,end
    case 'r  '
      if execstr('%vv=['+%str(%kk)+']','errcatch')<>0  then 
	%noooo=-%kk,break,
      end
      if type(%vv)<>16 then %noooo=-%kk,break,end
      if typeof(%vv)<>'rational' then %noooo=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      [%mmmm,%nnnnn]=size(%vv(2))
      %ssss=string(%sz(1))+' x '+string(%sz(2))
      if %mmmm*%nnnnn==0 then
	if  %sz(1)>=0&%sz(2)>=0&%sz(1)*%sz(2)<>0 then %noooo=%kk,break,end
      else
	if %sz(1)>=0 then if %mmmm<>%sz(1) then %noooo=%kk,break,end,end
	if %sz(2)>=0 then if %nnnnn<>%sz(2) then %noooo=%kk,break,end,end
      end
    else
      error('Incorrect type :'+%typ(2*%kk-1))
    end
    execstr('%'+string(%kk)+'=%vv')
  end
  if %noooo>0 then 
    message(['answer given for  '+%lables(%noooo);
             'has invalid dimension: ';
             'waiting for dimension  '+%ssss])
    %ini=%str
    ok=%f;break
  elseif %noooo<0 then
    message(['answer given for  '+%lables(-%noooo);
             'has incorrect type :'+ %typ(-2*%noooo-1)])
    %ini=%str
    ok=%f;break
  else
    break
  end 
end
if %lhs==%nn+2 then
  execstr('%'+string(%lhs-1)+'=%str')
end
ok=%f
endfunction
 
