function p=tk_getdir(startdir,tit)
  if ~with_tk() then error("Tcl/Tk interface not defined"),end
  arg=''
  if exists("startdir","local")==1 then 
    startdir=pathconvert(startdir,%f,%t)
    startdir=strsubst(startdir,"\","/")
    arg=arg+" -initialdir {"+startdir+"}"
  end
  if exists("tit","local")==1 then arg=arg+" -title {"+tit+"}",end
  arg=arg+" -parent $root"
  TCL_EvalStr("set getdir [tk_chooseDirectory"+arg+"]") 
  p=TCL_GetVar("getdir");
endfunction

