//dessin_scs_m
//fonction qui dessine le contenu graphique 
//d'une structure scs_m dans un fichier .eps
//
//Entrée scs_m : structure de données scicos
//       name : nom du fichier produit
//       flag : 'html' ou 'guide'
//         lr_margin (facultatif) spécifie les marges verticales pour do_export
//         up_margin (facultatif) spécifie les marges horizontales pour do_export
function dessin_scs_m(scs_m,name,flag,lr_margin,ud_margin)
  //retrouve le nombre d'argument
  [lhs,rhs]=argn()

  //check rhs parameters
  if rhs<4 then
    lr_margin=[];
  end
  if rhs<5 then
    ud_margin=[];
  end

  //load scicos variable and library
  load SCI/macros/scicos/lib;
  exec(loadpallibs,-1);

  //%zoom definition
  %zoom  = 1.3;

  //Tests for scicos version
  ierr = execstr('current_version=get_scicos_version()','errcatch')
  if ierr==0 then //scilab > 4.1x

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

    //redefinit %scicos_lr/ud_margin si ils sont
    //passés en paramètres
    if lr_margin<>[] then
      %scicos_lr_margin=lr_margin;
    end
    if ud_margin<>[] then
      %scicos_ud_margin=ud_margin
    end

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

    //**** Ajout 11/08/07 : execute do_version pour vieux sbloc ****//
    if type(scs_m)==17 then
      if find(getfield(1,scs_m)=='version')<>[] then
        if scs_m.version<>'' then
          scicos_ver=scs_m.version
        else
          scicos_ver = "scicos2.7.3" //for compatibility
        end
      else
        scicos_ver = "scicos2.7.3" //for compatibility
      end
    else
      message("Can''t import block in scicos, sorry" )
    end

    //do version
    if scicos_ver<>current_version then
      ierr=execstr('scs_m=do_version(scs_m,scicos_ver)','errcatch')
      if ierr<>0 then
        message("Can''t import block in scicos, sorry (problem in version)")
      end
    end
    //**** ****//

    Replot_();
    %scicos_landscape=0;
    [w,h] = do_export(scs_m,name,0);
    if fileinfo(name+'/')==[] then
      mkdir(name);
    end
    unix_g(%gd.cmd.mv+name+'.eps '+name); //AATTENTION ICI %GD utilisé en global

    delete(gh_current_window);

  else
    //load scicos variable and library
    bak=get('figure_style');
    set("figure_style","old");
    olds=get('old_style');
    set('old_style','on');

    %scicos_prob=%f;
    alreadyran=%f
    needcompile=4
    colmap=xget('colormap');

    mdo_export(scs_m,name,flag)

    //restore figure_style
    gg=xget('window')  // for bug in figure_style and winsid
    xset('window',0) // for bug in figure_style and winsid
    set('figure_style',bak);
    set('old_style',stripblanks(olds));
    xset('window',gg) // for bug in figure_style and winsid
  end
endfunction
