mode(-1);

sources_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(sources_pathL,SCI,'SCI') );
load( sources_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ sources_pathL + 'gif_icons/' ];

clear sources_pathL

