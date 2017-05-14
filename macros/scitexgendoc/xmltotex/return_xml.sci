//return_xml : fonction qui retourne le texte
//             situé entre deux balises xml
//
//entrée : fname : le fichier xml à
//                 sonder
//
//         flag : une chaîne de caractères
//                'sdesc'
//                'cseq'
//                'desc'
//                'rmk'
//                'ex'
//                'param'
//                'ufunc'
//                'salso'
//                'bib'
//                'auth'
//                'spdesc'
//
//sortie : tt : le texte situé entre les
//              balises correspondantes
//              au flag
//
//         a  : l'indice de la balise d'ouverture
//         b  : l'indice de la balise de fermeture

function [tt,a,b]=return_xml(fname,flag)

 tt=[]
 a=[]
 b=[]

 if size(flag,'*')<>1 then
   printf("%s : bad flag parameter size.\n",...
         'return_xml');
 end

 select flag
   case 'sdesc' then
        b1='<SHORT_DESCRIPTION'
        b2='</SHORT_DESCRIPTION>'
   case 'cseq' then
        b1='<CALLING_SEQUENCE>'
        b2='</CALLING_SEQUENCE>'
   case 'desc' then
        b1='<DESCRIPTION>'
        b2='</DESCRIPTION>'
   case 'rmk' then
        b1='<REMARKS>'
        b2='</REMARKS>'
   case 'ex' then
        b1='<EXAMPLE>'
        b2='</EXAMPLE>'
   case 'param' then
        b1='<PARAM>'
        b2='</PARAM>'
   case 'ufunc' then
        b1='<USED_FUNCTIONS>'
        b2='</USED_FUNCTIONS>'
   case 'salso' then
        b1='<SEE_ALSO>'
        b2='</SEE_ALSO>'
   case 'bib' then
        b1='<BIBLIO>'
        b2='</BIBLIO>'
   case 'auth' then
        b1='<AUTHORS>'
        b2='</AUTHORS>'
   else
       printf("%s : bad flag %s.\n",...
              'return_xml',flag);
       return
 end

 if fileinfo(fname)<>[] then
   txt=mgetl(fname);
 else
   printf("%s : file %s not found.\n",...
         'return_xml',fname);
   return
 end


 if txt<>[] then
   //Cherche les bornes b1 et b2
   for i=1:size(txt,'*')
     if strindex(txt(i),b1)<>[] then
       a=i;
     end;
     if strindex(txt(i),b2)<>[] then
       b=i;
       break;
     end
   end

   if a<>[]&b<>[] then
     //tt=stripblanks_end(stripblanks_begin(txt(a:b)));
     tt=stripblanks_end(txt(a:b));
   end
 end
endfunction
