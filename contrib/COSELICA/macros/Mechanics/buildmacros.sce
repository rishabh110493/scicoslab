mode(-1);
lines(0);

mechanics_pathB=get_absolute_file_path('buildmacros.sce');

chdir(mechanics_pathB);

mechanics_dirsB=list('Translational','Rotational','Planar');

for dirB = mechanics_dirsB
  if isdir( dirB ) then
    chdir( dirB );
    exec('buildmacros.sce');
    chdir( '..' );
  end
end

clear mechanics_pathB mechanics_dirsB dirB

