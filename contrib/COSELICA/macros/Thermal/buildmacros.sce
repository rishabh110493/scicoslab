mode(-1);
lines(0);

thermal_pathB=get_absolute_file_path('buildmacros.sce');

chdir(thermal_pathB);

thermal_dirsB=list('HeatTransfer');

for dirB = thermal_dirsB
  if isdir( dirB ) then
    chdir( dirB );
    exec('buildmacros.sce');
    chdir( '..' );
  end
end

clear thermal_pathB thermal_dirsB dirB

