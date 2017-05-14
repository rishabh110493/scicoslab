//return_xml_sdesc
//fonction qui retourne le texte placé entre
//les deux premiers drapeaux <SHORT_DESCRIPTION>
//et </SHORT_DESCRIPTION> trouvés dans le fichier fname
//ex : txt=return_xml_sdesc(SCI+'/man/eng/nonlinear/intc.xml')
//Entrée fname : chemin+nom du fichier xml
//Sortie txt : tableau de chaines de caractères
function txt=return_xml_sdesc(fname)

 txt=[]
//  tt=[]
//  j=1
//  a=[]

 if fileinfo(fname)<>[] then
   txt_temp=mgetl(fname);
 else
   printf("\n\t  %s : Warning :"+...
          "\n\t    xml file %s.xml not found.\n\t",...
          'return_xml_sdesc',...
          basename(fname));
   return
 end

 deff('[data]=char_handl(data,txt)',...
     [' if data.a==1 then';
      '  data.mystr(data.i,2)=[';
      '              stripblanks_end('+...
      '              stripblanks_begin(txt)'+...
      '                             )]';
      '  data.mystr(data.i,2)=striplines(data.mystr(data.i,2))';
      ' end'])

 deff('[data]=start_handl(data,el,attr)',...
     [' if el==data.tag then';
      '   data.a=1'
      '   data.i=data.i+1';
      '   if size(attr,1)<>0 then';
      '     data.mystr(data.i,1)=[';
      '                stripblanks_end('+...
      '                stripblanks_begin(attr(1,2))'+...
      '                             )]';
      '   end';
      ' end'])

 deff('[data]=end_handl(data,el)',...
     [' if el==data.tag then';
      '   data.a=0';
      ' end']);


 %ptr=XML_ParserCreate("ISO-8859-1");
 XML_Conv2Latin(%ptr);
 XML_SetUserData(%ptr,'data');
 XML_SetElementHandler(%ptr,'start_handl','end_handl');
 XML_SetCharDataHandler(%ptr,'char_handl');

 data = struct('a',0,'i',0,'tag','SHORT_DESCRIPTION','mystr',['','']);

 XML_Parse(%ptr, txt_temp);

 txt=data.mystr;

endfunction
