//mdo_export
//fonction qui export le contenu graphique d'une liste
//scs_m dans un fichier .eps
//Entrée : scs_m  : liste de donnée scicos
//         fnameN : nom du ficher à produire
//         flag : html pour produire une figure pour mettre dans du html
//                guide pour du papier
//                cosguide pour du papier

function mdo_export(scs_m,fnameN,flag)
  //Créer un répertoire
  if fileinfo(fnameN+'/')==[] then 
//     unix_g("mkdir "+fnameN+"/")
    mkdir(fnameN)
  end;

  //Teste le paramètre 
  if fnameN==emptystr() then return;end
  fnameN=stripblanks(fnameN);
  ff=str2code(fnameN+'/'+fnameN);
  ff(find(ff==40|ff==53))=36;
  fnameN=code2str(ff);

  //récupère dimension
  rect=dig_bound(scs_m)
  wpar=scs_m.props.wpar
  wa=(rect(3)-rect(1))
  ha=(rect(4)-rect(2))
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
  rect(1)=rect(1)-wa*%scicos_lr_margin
  rect(3)=rect(3)+wa*%scicos_lr_margin
  rect(2)=rect(2)-ha*%scicos_ud_margin
  rect(4)=rect(4)+ha*%scicos_ud_margin
  if flag=='html_lblock' then
     rect(2)=rect(2)-ha*%scicos_ud_margin
  elseif flag=='guide_lblock' then
     rect(2)=rect(2)-3.5*ha*%scicos_ud_margin
  elseif flag=='html_pal'
    rect(2)=rect(2)-1.2*ha*%scicos_ud_margin
  end
  wa=(rect(3)-rect(1))
  ha=(rect(4)-rect(2))
  wa=max(60,wa);
  ha=max(40,ha);
  //Initialise drivers graphique
  driver('Pos')
  set_posfig_dim(wa*%zoom/1.8,ha*%zoom/1.8)
  xinit(fnameN),
  xsetech(wrect=[0 0 1 1],frect=rect,arect=[0,0,0,0])
  options=scs_m.props.options
  cmap=options.Cmap
  for k=1:size(cmap,1)
    [mc,kk]=mini(abs(colmap-ones(size(colmap,1),1)*cmap(k,:))*[1;1;1])
    if mc>.0001 then
      colmap=[colmap;cmap(k,:)]
    end
  end
  xset('colormap',colmap)
  xset('pattern',default_color(0));
  //Dessine scs_m
  drawobjs(scs_m),
  set_posfig_dim(0,0),
  xend();

  //convertion finale avec BEpsf
  %scicos_landscape=0
  opt=""
  if %scicos_landscape then opt=" -landscape ";end
  if MSDOS then
    fnameN=pathconvert(fnameN,%f,%t,'w')
    comm=pathconvert(SCI+'\bin\BEpsf',%f,%f,'w')
    rep=unix_g(''"'+comm+''" '+opt+fnameN)
  else
    rep=unix_g(SCI+'/bin/BEpsf '+opt+fnameN)
  end
  if rep<>[] then
    x_message(['Problem generating ps file.';..
               'Perhaps directory not writable'] )
  end
  driver('Rec')
endfunction