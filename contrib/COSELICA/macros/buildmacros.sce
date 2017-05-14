mode(-1);

macros_pathB=get_absolute_file_path('buildmacros.sce');
chdir(macros_pathB);

macros_dirsB=list('utils','Electrical','Mechanics','Thermal','Blocks','Obsolete');

for dirB = macros_dirsB
  if isdir( dirB ) then
    chdir( dirB );
    exec('buildmacros.sce');
    chdir( '..' );
  end
end

clear macros_pathB macros_dirsB dirB

