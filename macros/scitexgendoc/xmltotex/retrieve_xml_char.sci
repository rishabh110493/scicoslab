//retrieve_xml_char
//fonction qui convertit les caractères particuliers
//des pages d'aides scilab xml en caractères
//normaux
//Entrée : vecteur de chaînes de caractères
//Sortie : vecteur de chaîne de caractères

function txt=retrieve_xml_char(txt)

  txt=strsubst(txt,'&apos;','''');
  txt=strsubst(txt,'&lt;','<');
  txt=strsubst(txt,'&gt;','>');
  txt=strsubst(txt,'&quot;','""');

endfunction
