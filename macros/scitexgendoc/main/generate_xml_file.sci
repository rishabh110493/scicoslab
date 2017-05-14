//generate_xml_file
//fonction qui crée des fichiers d'aide xml
//Entrée : lisf est une matrice nx3 de chaîne de caractères
//         lisf(:,1) sont les chemins des fichiers scilab
//         lisf(:,2) sont les chemins des fichiers scilab 
//                   (avec extension si nécessaires)
//         lisf(:,3) renseigne sur le type d'objet
//              'block' pour une fonction d'interface scicos
//              'pal' pour un fichier palette scicos (cosf)
//              'diagr' pour un diagramme de simulation scicos 
//              'scilib' pour une librairie de fonctions scilab
//              'sci' pour une fonction scilab.
//              'sim' pour un script de simulation scilab
//              'rout' pour une routine bas-niveau
//
//         %gd : une liste de définition du générateur
//               de documentation.
//
function generate_xml_file(lisf,%gd)

// check_lisf(lisf)

//  ierc=check_flag(flag)
//  if ierc<1 then
//    abort
//  else
// //    ierf=check_lisf(lisf);
//    if ierc==1 then
//      flag(1:size(lisf,1))=flag
//    else
//      if ierc<>size(lisf,1) then
//        gendoc_printf(%gd,"error : size of flag is not equal to size of lisf\n")
//        return
//      end
//    end
//  end

for i=1:size(%gd.lang,1)
  for k=1:size(lisf,1)
    name=get_extname(lisf(k,:),%gd)
    if fileinfo(%gd.mpath.xml(i)+name+'.xml')==[] then
      gendoc_printf(%gd,"%s.xml not found.\n",name)
      gendoc_printf(%gd,"(%s) Generate an empty xml file... ",...
             %gd.lang(i));
      txt=generate_xml(lisf(k,:),%gd.lang(i))
      mputl(txt,%gd.mpath.xml(i)+name+'.xml')
      gendoc_printf(%gd,"Done\n");
    else
      gendoc_printf(%gd,"(%s) %s.xml already exists.\n",...
             %gd.lang(i),name)
    end
  end
end
endfunction
