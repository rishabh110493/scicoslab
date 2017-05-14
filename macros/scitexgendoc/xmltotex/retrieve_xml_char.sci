//retrieve_xml_char
//fonction qui convertit les caract�res particuliers
//des pages d'aides scilab xml en caract�res
//normaux
//Entr�e : vecteur de cha�nes de caract�res
//Sortie : vecteur de cha�ne de caract�res

function txt=retrieve_xml_char(txt)

  txt=strsubst(txt,'&apos;','''');
  txt=strsubst(txt,'&lt;','<');
  txt=strsubst(txt,'&gt;','>');
  txt=strsubst(txt,'&quot;','""');

endfunction
