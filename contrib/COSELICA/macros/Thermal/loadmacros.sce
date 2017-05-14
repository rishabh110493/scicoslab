mode(-1);
lines(0);

thermal_pathL=get_absolute_file_path('loadmacros.sce');

chdir(thermal_pathL);

thermal_dirsL=list('HeatTransfer');

for dirL = thermal_dirsL
  if isdir( dirL ) then
    chdir( dirL );
    exec('loadmacros.sce');
    chdir( '..' );
  end
end

clear thermal_pathL thermal_dirsL dirL

