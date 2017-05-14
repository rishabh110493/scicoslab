mode(-1);

routing_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(routing_pathL,SCI,'SCI') );
load( routing_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ routing_pathL + 'gif_icons/' ];

clear routing_pathL

