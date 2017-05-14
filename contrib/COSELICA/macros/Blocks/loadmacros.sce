mode(-1);
lines(0);

blocks_pathL=get_absolute_file_path('loadmacros.sce');

chdir(blocks_pathL);

blocks_dirsL=list('Interfaces','Routing','Math','Sources','Continuous','Nonlinear');

for dirL = blocks_dirsL
  if isdir( dirL ) then
    chdir( dirL );
    exec('loadmacros.sce');
    chdir( '..' );
  end
end

clear blocks_pathL blocks_dirsL dirL

