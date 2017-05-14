//dessin_block
//fonction qui charge une structure graphique
//d'un block scicos dans une liste scs_m et qui
//exporte les données graphiques en fichier eps
//grâce à la fonction mdo_export
//Entrée : nom de la fonction d'interface du bloc
//         flag 'html' ou 'guide'
//         lr_margin (facultatif) spécifie les marges verticales pour do_export
//         up_margin (facultatif) spécifie les marges horizontales pour do_export
//         (spécifie si le bloc possède une identification)
function dessin_block(name,flag,lr_margin,ud_margin)

  //retrouve le nombre d'argument
  [lhs,rhs]=argn()

  //check rhs parameters
  if rhs<3 then
    lr_margin=[];
  end
  if rhs<4 then
    ud_margin=[];
  end

  //load palettes and scicos libraries
  load SCI/macros/scicos/lib;
  exec(loadpallibs,-1);

  //run 'define' case of block
  ierror=execstr('blk='+name+'(''define'')','errcatch')
  if ierror <>0 then
    x_message(['Error in GUI function';lasterror()] )
    disp('define'+name)
    return
  end

  //size adjustement of block
  blk.graphics.sz=20*blk.graphics.sz;

  //create a vois scs_m structure
  scs_m=scicos_diagram();

  //put block list in scs_m
  scs_m.objs(1)=blk;

  //%zoom definition
  %zoom  = 1.8;

  //flag test
  if flag=='html' then
    newflag='html_block'
  else
    newflag=flag
  end

    //DOIT FAIRE UNE FONCTION ENCAPSULANTE POUR LE NOUVEAU SCICOS
    if newflag=='guide'  then
      %scicos_lr_margin=.2;
      %scicos_ud_margin=.1
    elseif newflag=='cosguide' then
      %scicos_lr_margin=.005;
      %scicos_ud_margin=.05
    elseif newflag=='html_diagr' then
      %scicos_lr_margin=.15;//.3;
      %scicos_ud_margin=.05//.4;
    elseif newflag=='html_block' then
      %scicos_lr_margin=.3;//.3;
      %scicos_ud_margin=.35//.4;
    elseif newflag=='html_pal' then
      %scicos_lr_margin=.1;//.3;
      %scicos_ud_margin=.15//.4;
    elseif newflag=='html' then
      %scicos_lr_margin=.05;//.3;
      %scicos_ud_margin=.05//.4;
    elseif newflag=='sbeq_guide' then
      %scicos_lr_margin=.05;//.3;
      %scicos_ud_margin=.02//.4;
    else
      %scicos_lr_margin=.25;//.3;
      %scicos_ud_margin=.35//.4;
    end

    //redefinit %scicos_lr/ud_margin si ils sont
    //passés en paramètres
    if lr_margin<>[] then
      %scicos_lr_margin=lr_margin;
    end
    if ud_margin<>[] then
      %scicos_ud_margin=ud_margin
    end

  //Tests for scicos version
  ierr = execstr('scicos_ver=get_scicos_version()','errcatch')
  if ierr==0 then //scilab > 4.1x

    prot = funcprot();
    funcprot(0);
    deff('disablemenus()',' ');
    deff('enablemenus()',' ');
    funcprot(prot);
    pixmap = 0;
    Select = [];
    gh_current_window = gcf();
    options = scs_m.props.options;
    if ~set_cmap(options('Cmap')) then // add colors if required
     options('3D')(1) = %f //disable 3D block shape
    end
    Replot_();
    %scicos_landscape=0;

    //@@ 04/03/09 : Try to fix bad display of text in palette
    %zoom=4.5
    //%scicos_ud_margin=1

    [w,h] = do_export(scs_m,name,0);
    if fileinfo(name+'/')==[] then
      mkdir(name);
    end
    unix_g(%gd.cmd.mv+name+'.eps '+name); //AATTENTION ICI %GD utilisé en global

    delete(gh_current_window);

  else //code for scilab 3.0-4.1x

    //switch to old graphic mode
    bak=get('figure_style');
    set("figure_style","old");
    olds=get('old_style');
    set('old_style','on');

    //some definitions of scicos global variables
    %scicos_prob=%f;
    alreadyran=%f
    needcompile=4
    %zoom=1.8;
    colmap=xget('colormap');

    //call mdo_export
    mdo_export(scs_m,name,newflag)

    //switch to current graphic mode
    gg=xget('window')  // for bug in figure_style and winsid
    xset('window',0) // for bug in figure_style and winsid
    set('figure_style',bak)
    set('old_style',stripblanks(olds));
    xset('window',gg) // for bug in figure_style and winsid
  end

endfunction
