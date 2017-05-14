mode(-1);
lines(0);

macros_pathL=get_absolute_file_path('loadmacros.sce');

chdir(macros_pathL);

macros_dirsL=list('misc','utils','Blocks','Electrical','Mechanics','Thermal','Obsolete');

for dirL = macros_dirsL
  if isdir( dirL ) then
    chdir( dirL );
    exec('loadmacros.sce');
    chdir( '..' );
  end
end

mprintf( ' %s\n', 'Adding Modelica library ' + macros_pathL + 'Coselica.mo' );
modelica_libs($+1)=part(macros_pathL,1:(length(macros_pathL)-1));
mprintf( ' %s\n', 'Adding Scicos palette ' + macros_pathL + 'Coselica.cosf');
scicos_pal($+1,:)=[ 'Coselica', macros_pathL + 'Coselica.cosf'];

clear macros_pathL macros_dirsL dirL

