//fonction qui trie des fichiers eps
//issus de la fonction scop_results
//en regardant dans un fichier SPECIALDESC

function make_scope_order(lisf,lind,%gd)

if fileinfo(%gd.mpath.tex(lind)+...
            get_extname(lisf,%gd)+'/SPECIALDESC')<>[] then
  //trouve l'ordre des scope dans SPECIALDESC
  tt=mgetl(%gd.mpath.tex(lind)+...
            get_extname(lisf,%gd)+'/SPECIALDESC')
  a=[];
  for i=1:size(tt,1)
    if strindex(tt(i),'scope_order')<>[] then
      sorder_equ=strindex(tt(i),'=')
      txt=part(tt(i),sorder_equ+1:length(tt(i)))
      a=evstr(txt)
      break
    end
  end

  //remet les fichiers dans le bon ordre
  if a<>[] then
    for j=1:size(a,1)
      f=%gd.cmd.cp+%gd.lang(lind)+'/'+get_extname(lisf,%gd)+...
        '/'+basename(lisf(1,2))+'_scope_'+string(j)+'.eps '+...
        %gd.lang(lind)+'/'+get_extname(lisf,%gd)+...
        '/'+basename(lisf(1,2))+'_scope_'+string(j)+'_tmp.eps '
      unix_g(f)
    end

    for j=1:size(a,1)
      f=%gd.cmd.cp+%gd.lang(lind)+'/'+get_extname(lisf,%gd)+...
        '/'+basename(lisf(1,2))+'_scope_'+string(j)+'_tmp.eps '+...
        %gd.lang(lind)+'/'+get_extname(lisf,%gd)+...
        '/'+basename(lisf(1,2))+'_scope_'+string(a(j))+'.eps '
      unix_g(f)
    end

    unix_g(%gd.cmd.rm+...
           %gd.lang(lind)+'/'+get_extname(lisf,%gd)+...
           '/*_tmp.eps')
  end
end
endfunction