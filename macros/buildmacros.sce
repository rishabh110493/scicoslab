// -*- Mode: scilab -*- 
lines(0);
MSDOS=(getos()=='Windows');

exec('util/isdir.sci');

CurrentDirectory=pwd();
Directories=["util",
	     "percent",
	     "algebre",
	     "arma",
	     "auto",
	     "calpol",
	     "elem",
	     "int",
	     "metanet",
	     "mtlb",
	     "optim",
	     "robust",
	     "sci2for",
	     "signal",
	     "sound",
	     "statistics",
	     "tdcs",
	     "texmacs",
	     "tksci",
	     "xdess",
	     "sparse",
	     "scicos",
	     "scicos_blocks",
	     "m2sci",
	     "gui",
	     "maxplus",
	     "scitexgendoc"];
 
Dim=size(Directories);
timer();

for i=1:Dim(1) do 
  if isdir(Directories(i)) then
    chdir(Directories(i));
    mprintf("%s\n",'-------- Creation of '+Directories(i)+' (Macros) --------');
    exec('buildmacros.sce');
    chdir(CurrentDirectory);
  end
end
clear CurrentDirectory Dim Directories
exit
