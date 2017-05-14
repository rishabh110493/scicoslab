//met à jour la liste de définition
//du générateur de documentation
//
//Entrée : liste tl_doc
//         flag : 0 : cas par défault
//
//Sortie : liste tl_doc mise à jour
//
function tl_doc=set_gendoc_def(tl_doc,flag)

  //verifie présence flag
  [lsh,rsh]=argn(0)
  if rsh<2 then
   flag=0;
  end

  //all is one column
  tl_doc.lang=tl_doc.lang(:);

  //cas man/../eng
  if flag==0 then
    //met à jour les mpath
    sz_mpath=size(tl_doc.mpath);
    for j=3:sz_mpath
      if tl_doc.mpath(j)<>'' then
        tl_doc.mpath(j)=tl_doc.mpath.man+tl_doc.mpath(1)(j)+..
                        '/'+tl_doc.lang+'/';
      end
    end

  //cas man/eng/..
  elseif flag==1 then
    //met à jour les mpath
    sz_mpath=size(tl_doc.mpath);
    for j=3:sz_mpath
      if tl_doc.mpath(j)<>'' then
        tl_doc.mpath(j)=tl_doc.mpath.man+tl_doc.lang+..
                        '/'+tl_doc.mpath(1)(j)+'/';
      end
  end

  end

endfunction