function vars=macrovar(macro)
// Returns in a list the set of varibles used by a macro
//    mac  : macro
//    vars : list(in,out,globals,called,locals)
//           in : input variables
//           out: output variables
//           globals: global variables
//           called : macros called
//           locals : local variables
//!
//origin S Steer inria 1992
// Copyright INRIA
if type(macro)==11 then comp(macro),end
if type(macro)<>13 then error('Argument to macrovars must be a macro!'),end
lst=macr2lst(macro);
out=lst(2)',if prod(size(out))==0 then out =[],end
in=lst(3)'
vars=[]
getted=[]
[vars,getted]=listvars(lst,vars,getted)
getted=setdiff(getted,in)
getted=unique(getted)
ng=prod(size(getted))
globals=[],called=[]
for k=1:ng
    clear w //to avoid redefinition warning (bug 1774)
    ierr=execstr('w='+getted(k),'errcatch')
    if ierr==0 then //the variable exists
      if or(type(w)==[13 130 11]) then
        called=[called;getted(k)]
      else
        globals=[globals;getted(k)]
      end
    else
      globals=[globals;getted(k)]
      lasterror(%t)  // clear the error (bug 2393)
    end
end
locals=setdiff(vars,out)
locals=unique(locals)
vars=list(in,out,globals,called,locals)

endfunction

function [vars,getted]=listvars(lst,vars,getted)
for lstk=lst
  if type(lstk)==15 then
    [vars,getted]=listvars(lstk,vars,getted)
  else
    if lstk(1)=='1'|lstk(1)=='for' then 
      // case 1 retained for 2.7 and earlier versions
       vars=[vars;lstk(2)],
    elseif lstk(1)=='29' then 
      nlhs=(size(lstk,'*')-2)/2
      for k=0:nlhs-1
	vars=[vars;lstk(3+2*k)],
      end
    elseif or(lstk(1)==['2','20']) then 
       getted=[getted;setdiff(lstk(2),vars)],
    end
  end
end
endfunction

