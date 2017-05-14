mode(-1);

math_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(math_pathL,SCI,'SCI') );
load( math_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ math_pathL + 'gif_icons/' ];

clear math_pathL

