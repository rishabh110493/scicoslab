//dessin_pal
//fonction qui charge un fichier cosf dans une liste
//scs_m et qui exporte les données graphiques dans un fichier
//eps grâce à mdo_export
//Entrée name : chemin+nom de la palette
//              ex : name=MODNUM+'/macros/scicos_blocks/Tools.cosf'
//         flag 'html' ou 'guide'
//         lr_margin (facultatif) spécifie les marges verticales pour do_export
//         up_margin (facultatif) spécifie les marges horizontales pour do_export
//         (spécifie si le bloc possède une identification)
function dessin_pal(name,flag,lr_margin,ud_margin)

  //retrouve le nombre d'argument
  [lhs,rhs]=argn()

  //check rhs parameters
  if rhs<3 then
    lr_margin=[];
  end
  if rhs<4 then
    ud_margin=[];
  end

  //check file existance
  if fileinfo(name)<>[] then
    //load palettes and scicos libraries
    load SCI/macros/scicos/lib;
    exec(loadpallibs,-1);

    //run cosf file
    exec(name,-1) //SUPPOSE ETRE AU BON FORMAT

    //## 13/07/08, Alan
    //## extract palette from PAL_f only if the palette
    //## is composed by only one PAL_f block
    if lstsize(scs_m.objs)==1 then
       if scs_m.objs(1).gui == 'PAL_f' then
         scs_m=scs_m.objs(1).model.rpar
       end
    end

    //%zoom definition
    %zoom  = 1.3;

    //flag test
    if flag=='html' then
      newflag='html_pal'
    else
      newflag=flag
    end

    //Tests for scicos version
    ierr = execstr('scicos_ver=get_scicos_version()','errcatch')
    if ierr==0 then //scilab > 4.1x

      //DOIT FAIRE UNE FONCTION ENCAPSULANTE POUR LE NOUVEAU SCICOS
      if newflag=='guide'|newflag=='guide_lblock'  then
        %scicos_lr_margin=.2;
        %scicos_ud_margin=.1
      elseif newflag=='cosguide' then
        %scicos_lr_margin=.005;
        %scicos_ud_margin=.05
      elseif newflag=='html_diagr' then
        %scicos_lr_margin=.15;//.3;
        %scicos_ud_margin=.05//.4;
      elseif newflag=='html_block'|newflag=='html_lblock' then
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
      %zoom=3.8
      %scicos_lr_margin=0.3
      //%scicos_ud_margin=0.35

      [w,h] = do_export(scs_m,basename(name)+'_pal',0);
      if fileinfo(basename(name)+'_pal'+'/')==[] then
        mkdir(basename(name)+'_pal'+'/');
      end
      //ATTENTION ICI %GD utilisé en global
      unix_g(%gd.cmd.mv+basename(name)+'_pal.eps '+...
                             basename(name)+'_pal'); 

      delete(gh_current_window);

      //## temp export of cosf
      //## tobereviewlatter.
      for i=1:lstsize(scs_m.objs)
        if scs_m.objs(i).gui=='PAL_f' then
          disp('A palette in a palette has been detected.')
          nscs_m=scs_m.objs(i).model.rpar;
          //##detect empty palette
          if size(nscs_m.props.title,2)==2 then
            fname=nscs_m.props.title(1);
            path=nscs_m.props.title(2);
            disp('Create '+path+fname+'.cosf')
            //## open file
            [u,err]=file('open',path+fname+'.cosf','unknown','formatted')
            if err<>0 then
              message('File or directory write access denied')
              return
            end
            //## write scs_m in file with cos2cosf
            ierr=cos2cosf(u,do_purge(nscs_m))
            if ierr<>0 then
              message('Directory write access denied')
              file('close',u)
              return
            end
            //## close file
            file('close',u)
          end
        end
      end

    else //code for scilab 3.0-4.1x
      //load scicos variable and library
      bak=get('figure_style');
      set("figure_style","old");
      olds=get('old_style');
      set('old_style','on');

      //load scicos variable and library
      %scicos_prob=%f;
      alreadyran=%f
      needcompile=4
      colmap=xget('colormap');

      //call mdo_export
      mdo_export(scs_m,basename(name)+'_pal',newflag)

      //restore figure_style
      gg=xget('window')  // for bug in figure_style and winsid
      xset('window',0) // for bug in figure_style and winsid
      set('figure_style',bak)
      set('old_style',stripblanks(olds));
      xset('window',gg) // for bug in figure_style and winsid
    end
  else
    printf("Unable to find cosf file");
  end
endfunction
