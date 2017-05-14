//return_xml_salso : fonction qui retourne
//                   le texte plac� entre
//                   les drapeaux <SEE_ALSO_ITEM>
//                   et </SEE_ALSO_ITEM> du fichier fname
//
//ex : txt=return_xml_salso(SCI+'/man/eng/'+..
//                           'nonlinear/ode.xml')
//
//Entr�e fname : chemin+nom du fichier xml
//
//Sortie txt : tableau de chaines de caract�res
//             de taille nx4
//             ,1 : libell� du lien
//             ,2 : le fichier point�
//             ,3 : la description courte de l'objet point�
//             ,4 : le type d'objet point�
//
function txt=return_xml_salso(fname)

 txt=[]
 a=[]
 j=1

 if fileinfo(fname)<>[] then
   txt_temp=mgetl(fname);
 else
   printf("%s : xml file not found in %s\n",...
          'return_xml_salso',...
          fname);
   return
 end

 for i=1:size(txt_temp,'*')
   if strindex(txt_temp(i),'<SEE_ALSO_ITEM>')<>[] then
      a(j,1)=i;
   end
   if strindex(txt_temp(i),'</SEE_ALSO_ITEM>')<>[] then
     a(j,2)=i;
     j=j+1;
   end
 end

 if a<>[] then

   txt_temp=strsubst(txt_temp,('<SEE_ALSO_ITEM>'),'')
   txt_temp=strsubst(txt_temp,('</SEE_ALSO_ITEM>'),'')
   txt_temp=strsubst(txt_temp,('<LINK>'),'')
   txt_temp=strsubst(txt_temp,('</LINK>'),'')
   txt_temp=stripblanks_begin(txt_temp);
   txt_temp=stripblanks_end(txt_temp);

   tt='txt=[';
   for i=1:size(a,'r')
     tt=tt+""""+strsubst(evstr('striplines(txt_temp('+...
        'a('+string(i)+',1):a('+...
        string(i)+',2))),'),"""","""""")+...
        """;"
   end
   tt=part(tt,1:length(tt)-1);
   tt=tt+']';

   ierr=execstr(tt,'errcatch');

   if ierr<>0 then
       printf("%s : error in generation\n"+...
              "of string of see also items : %s\n",+...
              'return_xml_salso',fname);
       return
   end

   for i=1:size(txt,1)
     txt(i,1)=stripblanks_begin(txt(i,1));
     txt(i,1)=stripblanks_end(txt(i,1));
     if strindex(txt(i,1),"<A href=")<>[] then
        txt(i,2)=part(txt(i,1),...
                      1:strindex(txt(i,1),""">")+1)
        txt(i,1)=strsubst(txt(i,1),txt(i,2),"")
        txt(i,1)=strsubst(txt(i,1),"</A>","")
        txt(i,2)=strsubst(txt(i,2),"<A href=""","")
        txt(i,2)=strsubst(txt(i,2),""">","")
        txt(i,2)=stripblanks_begin(txt(i,2));
        txt(i,2)=stripblanks_end(txt(i,2));
     else
        txt(i,2)=txt(i,1)+".htm"
     end

     //peut rajouter d'autres rep. ici!
     test_file=fileparts(fname)+...
                 basename(txt(i,2))+'.xml'
     test_file($+1)=fileparts(txt(i,2))+...
                    basename(txt(i,2))+'.xml'
     test_file($+1)=fileparts(fname)+fileparts(txt(i,2))+...
                    '../xml/'+basename(txt(i,2))+'.xml'

     txt(i,3)=""
     txt(i,4)=""
     for j=1:size(test_file,1)
       if txt(i,3)=="" then
         if fileinfo(test_file(j))<>[] then
           txt(i,3)=return_xml_single_sdesc(test_file(j))
           txt(i,4)=return_xml_type(test_file(j))
         end
       else
         break
       end
     end
   end

 end
endfunction
