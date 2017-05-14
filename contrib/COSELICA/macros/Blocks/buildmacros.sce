mode(-1);
lines(0);

blocks_pathB=get_absolute_file_path('buildmacros.sce');

chdir(blocks_pathB);

blocks_dirsB=list('Interfaces','Routing','Math','Sources','Continuous','Nonlinear');

for dirB = blocks_dirsB
  if isdir( dirB ) then
    chdir( dirB );
    exec('buildmacros.sce');
    chdir( '..' );
  end
end

clear blocks_pathB blocks_dirsB dirB

