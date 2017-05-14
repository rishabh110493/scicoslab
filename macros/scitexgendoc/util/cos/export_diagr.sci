//export_diagr
//fonction qui charge un fichier scicos dans une liste
//scs_m et qui exporte le contenu graphique dans un
//fichier grâce à la fonction mdo_export
//Entrée : path : le chemin du fchier à exporter
//         fileN : le nom du ficher à exporter
//         flag 'html'
//              'guide' 
//              'cosguide'
function export_diagr(path,fileN,flag)

  //load palettes and scicos libraries
  load SCI/macros/scicos/lib;
  exec(loadpallibs,-1);

  //flag test
 [ppath,name,ext]=fileparts(fileN)
  //name=basename(fileN);
  if strindex(name,'sbeq')<>[] then
    if flag=='guide' then flag='sbeq_guide', end;
  end

  //%zoom definition
  %zoom  = 1.8;

  //Tests for scicos version
  ierr = execstr('current_version=get_scicos_version()','errcatch')
  if ierr==0 then //scilab > 4.1x
    if ext=='.cosf' then
      //load cosf file
      exec(path+fileN,-1);
    else
      //load cos file
      load(path+fileN);
    end

    //check version
    if type(scs_m)==17 then
      if find(getfield(1,scs_m)=='version')<>[] then
        if scs_m.version<>'' then
          scicos_ver=scs_m.version
        end
      end
    end
    if current_version<>scicos_ver then
      scs_m=do_version(scs_m,scicos_ver)
    end

    //DOIT FAIRE UNE FONCTION ENCAPSULANTE POUR LE NOUVEAU SCICOS
    if flag=='guide'|flag=='guide_lblock'  then
      %scicos_lr_margin=.2;
      %scicos_ud_margin=.1
    elseif flag=='cosguide' then
      %scicos_lr_margin=.005;
      %scicos_ud_margin=.05
    elseif flag=='html_diagr' then
      %scicos_lr_margin=.15;//.3;
      %scicos_ud_margin=.05//.4;
    elseif flag=='html_block'|flag=='html_lblock' then
      %scicos_lr_margin=.3;//.3;
      %scicos_ud_margin=.35//.4;
    elseif flag=='html_pal' then
      %scicos_lr_margin=.1;//.3;
      %scicos_ud_margin=.15//.4;
    elseif flag=='html' then
      %scicos_lr_margin=.05;//.3;
      %scicos_ud_margin=.05//.4;
    elseif flag=='sbeq_guide' then
      %scicos_lr_margin=.05;//.3;
      %scicos_ud_margin=.02//.4;
    else
      %scicos_lr_margin=.25;//.3;
      %scicos_ud_margin=.35//.4;
    end

    prot = funcprot();
    funcprot(0);
    deff('disablemenus()',' ');
    deff('enablemenus()',' ');
    swap_handles = permutobj; //TO be removed in Scilab 5
    xstringb = xstringb2; //** BEWARE: TO be removed in Scilab 5
    funcprot(prot);
    pixmap = 0;
    Select = [];
    gh_current_window = gcf();
    //##Patch for scilab-4.1.2
    curwin = gh_current_window.figure_id;
    options = scs_m.props.options;
    if ~set_cmap(options('Cmap')) then // add colors if required
     options('3D')(1) = %f //disable 3D block shape
    end
    Replot_();
    %scicos_landscape=0;
    [w,h] = do_export(scs_m,name,0);
    if fileinfo(name+'/')==[] then
      mkdir(name);
    end
    unix_g(%gd.cmd.mv+name+'.eps '+name); //AATTENTION ICI %GD utilisé en global

    delete(gh_current_window);

  else //code for scilab 3.0-4.1x

    if ext=='.cosf' then
      //load cosf file
      exec(path+fileN,-1);
    else
      //load cos file
      load(path+fileN);
    end

    //load scicos variable and library
    bak=get('figure_style');
    set("figure_style","old");
    olds=get('old_style');
    set('old_style','on');

    //some definitions of scicos global variables
    %scicos_prob=%f;
    alreadyran=%f
    needcompile=4
    colmap=xget('colormap');

    //call mdo_export
    mdo_export(scs_m,name,flag);

    //restore figure_style
    gg=xget('window')  // for bug in figure_style and winsid
    xset('window',0) // for bug in figure_style and winsid
    set('figure_style',bak);
    set('old_style',stripblanks(olds));
    xset('window',gg) // for bug in figure_style and winsid
  end
endfunction