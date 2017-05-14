mode(-1);

heattransfer_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(heattransfer_pathL,SCI,'SCI') );
load( heattransfer_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ heattransfer_pathL + 'gif_icons/' ];

clear heattransfer_pathL

