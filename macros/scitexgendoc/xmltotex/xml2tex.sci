//xml2tex : fonction qui convertit un ficher
//          d'aide scilab xml en un ensemble
//          de fichiers latex.
//
// 1  _sdesc.tex     : description courte
// 2  _call_seq.tex  : séquence d'appel
// 3  _long.tex      : description longue
// 4  _rmk.tex       : remarques
// 5  _ex.tex        : exemples
// 6  _param.tex     : paramètres
// 7  _used_func.tex : fonction utilisée
// 8  _see_also.tex  : voir aussi
// 9  _bib.tex       : bibliographie
// 10 _authors.tex   : auteurs
//
//Entrée :
//
// namef : nom du fichier xml à convertir
//         ('chemin+nom.xml')
//
//Sortie néant
function tt=xml2tex(namef,typdoc)

 rhs=argn(2)
 if rhs<2 then
   typdoc='html'
 end

 tt=[]

 if ~(typdoc=='html'|typdoc=='guide') then
   printf("%s : bad ''typdoc'' parameter : %s\n",...
          'xml2tex',...
          typdoc);
   return
 end

 namef=namef(:)

 def='[''xml2tex'','
 def2='xml2tex'
 str=[]
 str2=''
 //Pour chaque fichier
 for ij=1:size(namef,1)

   //description courte
   ierr=execstr('txt=return_xml_sdesc(namef(ij))','errcatch');
   if ierr<>0 then
     printf("%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_sdesc',...
            namef(ij));
    exit
   end
   tt1=conv2tex_sdesc(txt);

   //séquence d'appel
   ierr=execstr('txt=return_xml_cseq(namef(ij))','errcatch');
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_cseq',...
            namef(ij));
     error(10000)
     return
   end
   tt2=conv2tex_cseq(txt);

   //description
   ierr=execstr('list_txt=return_xml_desc(namef(ij))','errcatch');
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_desc',...
            namef(ij));
     error(10000)
     return
   end
   tt3=conv2tex_desc(list_txt)

   //remarque(s)
   ierr=execstr('txt=return_xml_rmk(namef(ij))','errcatch');
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_rmk',...
            namef(ij));
     error(10000)
     return
   end
   tt4=conv2tex_rmk(txt)

   //exemple(s)
   ierr=execstr('txt=return_xml_ex(namef(ij))','errcatch')
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_ex',...
            namef(ij));
     error(10000)
     return
   end
   tt5=conv2tex_ex(txt)

   //paramètre(s)
   ierr=execstr('txt_list=return_xml_param(namef(ij))','errcatch')
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_param',...
            namef(ij));
     error(10000)
     return
   end
   tt6=conv2tex_param(txt_list)

   //fonction(s) utilisée(s)
   ierr=execstr('txt=return_xml_ufunc(namef(ij))','errcatch')
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_ufunc',...
            namef(ij));
     error(10000)
     return
   end
   tt7=conv2tex_ufunc(txt)

   //voir aussi
   ierr=execstr('txt=return_xml_salso(namef(ij))','errcatch')
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_salso',...
            namef(ij));
     error(10000)
     return
   end
   tt8=conv2tex_salso(txt)

   //bibliographie
   ierr=execstr('txt=return_xml_bib(namef(ij))','errcatch')
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_bib',...
            namef(ij));
     error(10000)
     return
   end
   tt9=conv2tex_bib(txt)

   //auteur(s)
   ierr=execstr('txt=return_xml_auth(namef(ij))','errcatch')
   if ierr<>0 then
     printf("\n%s : Error in %s for file %s\n",...
            'xml2tex',...
            'return_xml_auth',...
            namef(ij));
     error(10000)
     return
   end
   tt10=conv2tex_auth(txt)

   //update str tlist
   def=def+''''+basename(namef(ij))+''',';
   def2(1,ij+1)=basename(namef(ij))
   str=str+'tlist('+...
       '['''',''sdesc'',''cseq'',''desc'',''rmk'',''ex'','+...
         '''param'',''ufunc'',''salso'',''bib'','+...
         '''auth''],'

   for i=1:10
     str=str+evstr(...
         'sci2exp(tt'+string(i)+','+...
         '''aa'',0)')+','
//      if evstr('tt'+string(i))==[] then
//        str2(i,ij)=''
//      else
//        str2(i,ij)=evstr('tt'+string(i))
//      end
   end
   str=part(str,1:length(str)-1)
   str=str+'),'
 end
 def=part(def,1:length(def)-1)
 def=def+']'
 str=part(str,1:length(str)-1)

 str='tt=tlist('+def+','+str+')'
 ierr=execstr(str,'errcatch');

 if ierr<>0 then
  printf("%s : error in convertion\n",...
         'xml2tex');
 end

endfunction