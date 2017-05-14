mode(-1);

// loader for macros 

//libname='CSlib'
mess=[' --------------------------------------------';
      ' CiudadSim toolbox loaded, help menu updated.';
      '     Standard edit_graph has been modified   '; 
      ' Enter edit_graph at Scicoslab prompt-->     ';
      ' --------------------------------------------'];
libtitle=['Traffic Assignment algorithms and graphic interface'];

// generic 

CS_DIR=SCI+'/contrib/cs5';
exec(CS_DIR+'/macros/loader.sce')

// loader for src 
exec(CS_DIR+'/src/loader.sce');
write(%io(2),mess)

// Chargement des helps 
add_help_chapter('Traffic Assignment',CS_DIR+'/man')  


// Chargement des demos
//add_demo('CiudadSim  Demo', CS_DIR+'demo/TrafficAssignDemo.sce')  

EXAMPLES=CS_DIR+'/examples/';
default_font_size=14
clear libtitle mess get_file_path 
global %net
global %VERBOSE



