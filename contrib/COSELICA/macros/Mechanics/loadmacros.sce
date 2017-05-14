mode(-1);
lines(0);

mechanics_pathL=get_absolute_file_path('loadmacros.sce');

chdir(mechanics_pathL);

mechanics_dirsL=list('Translational','Rotational','Planar');

for dirL = mechanics_dirsL
  if isdir( dirL ) then
    chdir( dirL );
    exec('loadmacros.sce');
    chdir( '..' );
  end
end

clear mechanics_pathL mechanics_dirsL dirL

