mode(-1);
lines(0);

cd(SCI+'/contrib/COSELICA');
mainpathB=get_absolute_file_path('builder.sce');

chdir(mainpathB);

mprintf('Coselica version %s\n', stripblanks(read("VERSION",1,1,'(a)')) );
mprintf('Copyright (C) 2009-2011 Dirk Reusch, Kybernetik Dr. Reusch\n\n' );

if isdir('macros') then
  chdir('macros');
  exec('buildmacros.sce');
  chdir('..');
end

clear mainpathB

