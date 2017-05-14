lines(0);

CurrentDirectorym2sci=pwd();
Directoriesm2sci=["kernel","percent","sci_files"];

stacksize(5000000);
 
Dim=size(Directoriesm2sci);
for i=1:Dim(2) do 
  chdir(Directoriesm2sci(i));
  mprintf("%s\n",'---------- Creation of m2sci/'+Directoriesm2sci(i)+' (Macros) --------');
  exec('buildmacros.sce');
  chdir(CurrentDirectorym2sci);
end

clear CurrentDirectorym2sci Directoriesm2sci Dim
