mode(-1);

interfaces_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(interfaces_pathL,SCI,'SCI') );
load( interfaces_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ interfaces_pathL + 'gif_icons/' ];

clear interfaces_pathL

