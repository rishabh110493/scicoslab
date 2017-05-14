mode(-1);

obsolete_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(obsolete_pathL,SCI,'SCI') );
load( obsolete_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ obsolete_pathL + 'gif_icons/' ];

clear obsolete_pathL

