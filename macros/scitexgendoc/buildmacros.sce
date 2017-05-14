SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
lines(0);
CurrentDir=pwd();
SubDirs=["auxi",
         "main",
         "util",
         "xmltotex"];

Dim=size(SubDirs);
for i=1:Dim(1) do
  chdir(SubDirs(i));
  printf("%s\n",'---------- Creation of scitexgendoc/'+SubDirs(i)+' (Macros) --------');
  exec('buildmacros.sce');
  chdir(CurrentDir);
end
clear Dim CurrentDir SubDirs
