//------------------------------------
// Allan CORNET INRIA 2005
//------------------------------------
SCI=getenv('SCI');
if %t then 
  // jpc 2009 the following code is 
  // much simpler that the util/genmacros.sce 
  // and simplify cross-compilation.
  exec(SCI+'/macros/util/fileparts.sci');
  exec(SCI+'/macros/util/getshell.sci');
  exec(SCI+'/macros/util/pathconvert.sci');
  exec(SCI+'/macros/util/stripblanks.sci');
  exec(SCI+'/macros/util/listfiles.sci');
  exec(SCI+'/macros/util/unix_g.sci');
  exec(SCI+'/macros/util/OS_Version.sci');
  exec(SCI+'/macros/util/isdir.sci');
  exec(SCI+'/macros/percent/%c_a_c.sci');
  exec(SCI+'/macros/util/basename.sci');
  exec(SCI+'/macros/util/mputl.sci');
  exec(SCI+'/macros/util/genlib.sci');
else
  // genmacros necessaire pour le Bootstrap de la compilation des macros
  exec('SCI/util/genmacros.sce');
end
//------------------------------------
SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
//------------------------------------
stacksize(5000000);
genlib('utillib','SCI/macros/util');
//------------------------------------
