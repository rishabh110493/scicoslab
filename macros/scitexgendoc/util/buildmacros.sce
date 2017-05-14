SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
lines(0);
CurrentDirAux=pwd();
SubDirsAux=["cos",
            "html",
            "lang",
            "main",
            "sci",
            "spec",
            "str",
            "tex"];

Dim=size(SubDirsAux);
for i=1:Dim(1) do
  chdir(SubDirsAux(i));
  exec('buildmacros.sce');
  chdir(CurrentDirAux);
end
clear Dim CurrentDirAux SubDirsAux
