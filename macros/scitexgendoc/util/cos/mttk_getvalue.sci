function [%ok,%1,%2,%3,%4,%5,...
          %6,%7,%8,%9,%10,...
          %11,%12,%13,%14,%15,...
          %16,%17,%18,%19,%20]=mttk_getvalue(%desc,%labels,%typ,%ini)
//Copyright METALAU - INRIA
//
// getvalues - %window dialog for data acquisition
//
//%Syntax%
//  [%ok,%1,..,%11]=getvalue(desc,labels,typ,ini)
//
//%Parameters
//  desc    : column vector of strings, dialog general comment
//  labels  : n column vector of strings, labels(i) is the label of
//            the ith required value
//  typ     : list(typ1,dim1,..,typn,dimn)
//            typi : defines the type of the ith required value
//                   if may have the following values:
//                   'mat' : stands for matrix of scalars
//                   'col' : stands for column vector of scalars
//                   'row' : stands for row vector of scalars
//                   'vec' : stands for  vector of scalars
//                   'str' : stands for vector of strings
//                   'lis' : stands for list
//                   'pol' : stands for polynomials
//                   'r'   : stands for rational
//            dimi : defines the size of the ith required value
//                   it must be
//                    - an integer or a 2-vector of integers (-1 stands for
//                      arbitrary dimension)
//                    - an evaluatable character string
//  ini     : n column vector of strings, ini(i) gives the suggested
//            response for the ith required value
//  %ok      : boolean ,%t if %ok button pressed, %f if cancel button pressed
//  xi      : contains the ith required value if %ok==%t
//
//%Description
// getvalues macro encapsulate x_mdialog function with error checking,
// evaluation of numerical response, ...
//
//%Remarks
// All correct scilab syntax may be used as responses, for matrices
// and vectors getvalues automatically adds [ ] around the given response
// before numerical evaluation
//
//%Example
// labels=['magnitude';'frequency';'phase'];
// [ampl,freq,ph]=getvalue('define sine signal',labels,..
//            list('vec',1,'vec',1,'vec',1),['0.85';'10^2';'%pi/3'])
//
//%See also
// x_mdialog, x_dialog

[%lhs,%rhs]=argn(0)

%nn=prod(size(%labels))
if %lhs<>%nn+2&%lhs<>%nn+1 then error(41),end
if size(%typ)<>2*%nn then
  error('%typ : list(''type'',[sizes],...)')
end
%1=[];%2=[];%3=[];%4=[];%5=[];
%6=[];%7=[];%8=[];%9=[];%10=[];
%11=[];%12=[];%13=[];%14=[];%15=[];
%16=[];%17=[];%18=[];%19=[];%20=[];

if %rhs==3 then  %ini=emptystr(%nn,1),end
%ok=%t
while %t do
  %str=mdialog(%desc,%labels,%typ,%ini)
  if %str==[] then
    %ok=%f;
    break //## end of while
  end
  for %kk=1:%nn
    %cod=ascii(%str(%kk))
    %spe=find(%cod==10)
    if %spe<>[] then
      %semi=ascii(';')
      %cod(%spe)=%semi*ones(%spe')
      %str(%kk)=ascii(%cod)
    end
  end
  ieeer=execstr('[%vv_list,%ierr_vec,%err_mess,%ok]=context_evstr(%str,%scicos_context,%typ,''get'')','errcatch');
  if ieeer<>0 then
    x_message('Undefined evaluation error.')
    %ok=%f;
    break //## end of while
  else
    if ~%ok then
       x_message(%err_mess)
       break //## end of while
    end
  end
  %ok=%t
  %nok=0
  for %kk=1:%nn
    %vv=%vv_list(%kk)
    %ierr=%ierr_vec(%kk)
    select part(%typ(2*%kk-1),1:3)
    case 'mat'
      if %ierr<>0 then 
        %err_mess=%err_mess(%kk)
        %nok=%inf;break
      end
      if and(type(%vv)<>[1 8]) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      [%mv,%nv]=size(%vv)
      %ssz=string(%sz(1))+' x '+string(%sz(2))
      if %mv*%nv==0 then
        if  %sz(1)>=0&%sz(2)>=0&%sz(1)*%sz(2)<>0 then %nok=%kk,break,end
      else
        if %sz(1)>=0 then if %mv<>%sz(1) then %nok=%kk,break,end,end
        if %sz(2)>=0 then if %nv<>%sz(2) then %nok=%kk,break,end,end
      end
    case 'vec'
      if %ierr<>0 then
        %err_mess=%err_mess(%kk)
        %nok=%inf;break
      end
      if and(type(%vv)<>[1 8]) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssz=string(%sz(1))
      %nv=prod(size(%vv))
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'pol'
      if %ierr<>0 then
        %err_mess=%err_mess(%kk)
        %nok=%inf;break
      end 
      if (type(%vv)>2 & type(%vv)<>8) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssz=string(%sz(1))
      %nv=prod(size(%vv))
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'row'
      if %ierr<>0 then
        %err_mess=%err_mess(%kk)
        %nok=%inf;break
      end
      if and(type(%vv)<>[1 8]) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      if %sz(1)<0 then
        %ssz='1 x *'
      else
        %ssz='1 x '+string(%sz(1))
      end
      [%mv,%nv]=size(%vv)
      if %mv<>1 then %nok=%kk,break,end,
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'col'
      if %ierr<>0 then
        %err_mess=%err_mess(%kk)
        %nok=%inf;break
      end
      if and(type(%vv)<>[1 8]) then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      if %sz(1)<0 then
        %ssz='* x 1'
      else
        %ssz=string(%sz(1))+' x 1'
      end
      [%mv,%nv]=size(%vv)
      if %nv<>1 then %nok=%kk,break,end,
      if %sz(1)>=0 then if %mv<>%sz(1) then %nok=%kk,break,end,end
    case 'str'
      %sde=%str(%kk)
      %spe=find(ascii(%str(%kk))==10)
      %spe($+1)=length(%sde)+1
      clear %vv
      %vv=[];%kk1=1
      for %kkk=1:size(%spe,'*')
        %vv(%kkk,1)=part(%sde,%kk1:%spe(%kkk)-1)
        %kk1=%spe(%kkk)+1
      end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssz=string(%sz(1))
      %nv=prod(size(%vv))
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'lis'
      if %ierr<>0 then
        %err_mess=%err_mess(%kk)
        %nok=%inf;break
      end
      if type(%vv)<>15& type(%vv)<>16& type(%vv)<>17 then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      %ssz=string(%sz(1))
      %nv=size(%vv)
      if %sz(1)>=0 then if %nv<>%sz(1) then %nok=%kk,break,end,end
    case 'r  '
      if %ierr<>0 then
        %err_mess=%err_mess(%kk)
        %nok=%inf;break
      end
      if type(%vv)<>16 then %nok=-%kk,break,end
      if typeof(%vv)<>'rational' then %nok=-%kk,break,end
      %sz=%typ(2*%kk);if type(%sz)==10 then %sz=evstr(%sz),end
      [%mv,%nv]=size(%vv(2))
      %ssz=string(%sz(1))+' x '+string(%sz(2))
      if %mv*%nv==0 then
        if  %sz(1)>=0&%sz(2)>=0&%sz(1)*%sz(2)<>0 then %nok=%kk,break,end
      else
        if %sz(1)>=0 then if %mv<>%sz(1) then %nok=%kk,break,end,end
        if %sz(2)>=0 then if %nv<>%sz(2) then %nok=%kk,break,end,end
      end
    case 'gen'
      // accept everything
      if %ierr<>0 then
        %err_mess=%err_mess(%kk)
        %nok=%inf;break
      end
    else
      error('type not handle :'+%typ(2*%kk-1)) //## end of while ?
    end
    execstr('%'+string(%kk)+'=%vv')
    clear %vv
  end //end of for
  if %nok==%inf then
    hilite_items(%kk)
    x_message(['The evaluation of block parameters results in the error: '
               %err_mess])
    unhilite_items(%kk)
    %ini=%str
  elseif %nok>0 then
    hilite_items(%kk)
    x_message(['Answer given for '+%labels(%nok)
               'has invalid dimension: '
               'waiting for dimension  '+%ssz])
    unhilite_items(%kk)
    %ini=%str
  elseif %nok<0 then
    hilite_items(%kk)
    if %ierr==0 then
      x_message(['Answer given for '+%labels(-%nok)
                 'has incorrect type :'+ %typ(-2*%nok-1)])
    else
      x_message(['Answer given for '+%labels(-%nok)
                 'is incorrect:'+%err_mess(-%nok)])
    end
    unhilite_items(%kk)
    %ini=%str
  else
    break //## end of while
  end
end
if %lhs==%nn+2 then
  execstr('%'+string(%lhs-1)+'=%str')
end
endfunction

function hilite_items(%kk)
    TCL_EvalStr('HiliteEntry '+string(%kk))
endfunction
function unhilite_items(%kk)
    TCL_EvalStr('UnHiliteEntry '+string(%kk))
endfunction

function [result]=mdialog(titlex,items,typ,init)
  if argn(2)<1 then
    titlex=['this is a demo';'this is a demo']
    items=['item 1';'item 2']
  end
  if argn(2)<3 then
    init=['init 1';'init 2']
  end

  titlex_init=titlex
  items_init=items
  typ_init=typ
  titlex=sci2tcl(titlex)
  for i=1:size(items,'*')
    items(i)=sci2tcl(items(i))
    init(i)=sci2tcl(init(i))
    typ(2*i-1)=sci2tcl(typ(2*i-1))
    typ(2*i)=sci2tcl(sci2exp(typ(2*i)))
  end

  result=[]
  cur_xml_file=[]
  fname=[]
  done=string(3)
  open_ttkgetvalue(titlex,items,typ,init)
endfunction

function []=close_ttkgetvalue()
 //## set typ
 typv=''"'"'
 if exists('%scs_help') then
   if(%scs_help<>[]) then
     typv=%scs_help
   end
 end
 clos = 1
 TCL_EvalStr('TkGetValue '+string(0)+' '+string(0)+' '+...
            string(0)+' '+string(0)+...
            ' toto'+' toto'+' toto'+...
            ' '+string(0)+' '+string(0)+' '+typv+' '+string(clos))

 //## save for state of toolbar
 if TCL_ExistVar('switcha') then
    a=evstr(TCL_GetVar('switcha'))
      TCL_EvalStr('global with_tool')
    if a==1 then
      TCL_EvalStr('set with_tool 0')
    else
      TCL_EvalStr('set with_tool 1')
    end
 end
 if TCL_ExistVar('switchb') then
   a=evstr(TCL_GetVar('switchb'))
   TCL_EvalStr('global with_tool_tk')
   if a==1 then
     TCL_EvalStr('set with_tool_tk 0')
   else
     TCL_EvalStr('set with_tool_tk 1')
   end
 end
 if TCL_ExistVar('switchc') then
   a=evstr(TCL_GetVar('switchc'))
   TCL_EvalStr('global with_but')
   if a==1 then
     TCL_EvalStr('set with_but 0')
   else
     TCL_EvalStr('set with_but 1')
   end
 end
endfunction

function []=open_ttkgetvalue(titlex,items,typ,init,fname)
 //## set typ
 typv=''"'"'
 if exists('%scs_help') then
   if(%scs_help<>[]) then
     typv=%scs_help
   end
 end

 //## Init TCL/TK sciGUI interf
 if typv=='Setup_Scicos' then
   [numx,numy,ledtx,ledty,...
        InFile,OutFile,HelpFile]=get_ttk_vars(typ)
 else
   [numx,numy,ledtx,ledty,...
        InFile,OutFile,HelpFile]=get_ttk_vars('getvalue')
 end

 mputl(titlex_init,HelpFile);

 clos = 2
 nitems = size(items,'*')
 ln=max(length(items));
 if ln==1 then ln=3, end
 for i=1:nitems
   TCL_EvalStr('global label_f'+string(i)+';set label_f'+string(i)+' '"'+string(items(i))+''"')
   TCL_EvalStr('global init_f'+string(i)+';set init_f'+string(i)+' '"'+string(init(i))+''"')
   TCL_EvalStr('global typ_f'+string(i)+';set typ_f'+string(i)+' [list '"'+string(typ(2*i-1))+''" '"'+string(typ(2*i))+''"]')
 end

 //## run tk text editor
 TCL_EvalStr('TkGetValue '+string(10)+' '+string(20)+' '+...
             string(nitems)+' '+string(ln)+...
             ' '+InFile+' '+OutFile+' '+HelpFile+...
             ' '+string(numx)+' '+string(numy)+' '+typv+' '+string(clos))

  //##
  TCL_EvalStr('global title;set title '"Set Block properties'"')
endfunction
