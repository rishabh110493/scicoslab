//return_xml_desc : fonction qui retourne
//                  la description d'un fichier xml
//                  d'aide scilab sous une forme
//                  formatée
//
//ex : return_xml_desc(SCI+'/man/eng/'+..
//                     'nonlinear/ode.xml')
//     return_xml_desc(SCI+'/man/eng/'+..
//                     'metanet/graph-list.xml')
//
//Entrée fname : chemin+nom du fichier xml
//
//Sortie txt_list() : une liste de description
//               |
//               |
//               |--> 1 : vecteur de taile n
//                        profondeur de description
//
//                    2 : vecteur de taile n
//                        niveau d'indentation
//
//                    3 : tableau de chaines
//                        de caractères de taille n,2
//                        ,1 : nom du paramètre
//                        ,2 : description du paramètre
//

function txt_list=return_xml_desc(fname)

 txt_list=[]
 a=[]
 b=[]

 nb_para=0
 i_indent=0
 i_item=0
 last_item=0;
 last_item2=0;
 last_indent=0

 if fileinfo(fname)<>[] then
   txt_temp=mgetl(fname);
 else
   printf("%s : xml file not found in %s\n",...
          'return_xml_desc',...
          fname);
   return
 end

 //g une matrice d'indice de taile nb_itemx7
 //g(:,1) la profondeur d'indentation
 //g(:,2) la profondeur de description
 //g(:,3) l'indice du paramètre parent
 //g(:,4),g(:,5) l'indice de début,fin du
 //              bloc DESCRIPTION_ITEM
 //              (label)
 //g(:,6),g(:,7) l'indice de début,fin du
 //              bloc DESCRIPTION_ITEM
 //              (texte)

 g=zeros(1,7);

 //Cherche les bornes
 //   <DESCRIPTION>  </DESCRIPTION>
 //   <DESCRIPTION_ITEM
//  disp('boucle 1');tic;
 for i=1:size(txt_temp,1)

   if strindex(txt_temp(i),'<DESCRIPTION_INDENT>')<>[] then

     if last_indent<>0 then
       if i-last_indent>1 then
         nb_para=nb_para+1
         g(nb_para,1)=i_indent
         g(nb_para,2)=i_item
         g(nb_para,6)=last_indent+1
         g(nb_para,7)=i-1
         last_indent=0
       end
     end

     if nb_para<>0&...
          g(nb_para,4)<>0&...
              last_item2==0 then
        g(nb_para,7)=i-1
     end

     if nb_para==0 & i-a>1 then
        nb_para=nb_para+1
        g(nb_para,1)=i_indent
        g(nb_para,2)=i_item
        g(nb_para,6)=a+1
        g(nb_para,7)=i-1
     end

     i_indent=i_indent+1;

   end

   if strindex(txt_temp(i),'</DESCRIPTION_INDENT>')<>[] then
     i_indent=i_indent-1;
     last_indent=i
   end

   if strindex(txt_temp(i),'</DESCRIPTION_ITEM>')<>[] then
     g(nb_para,7)=i
     last_item=0

     if i_indent==0 then
       last_item=i
     else
       last_item2=i
     end

     i_item=i_item-1
   end

   if a>0&strindex(txt_temp(i),'<DESCRIPTION_ITEM>')<>[] then

     i_item=i_item+1

     if nb_para==0 & i-a>1 then
      nb_para=nb_para+1
      g(nb_para,1)=i_indent
      g(nb_para,2)=i_item
      g(nb_para,6)=a+1
      g(nb_para,7)=i-1
     end

     if last_item<>0 then
       if i_indent==0 & i-last_item>1 then
        nb_para=nb_para+1
        g(nb_para,1)=i_indent
        g(nb_para,2)=i_item
        g(nb_para,6)=last_item+1
        g(nb_para,7)=i-1
       end
     end

     last_item2=0

     nb_para=nb_para+1
     g(nb_para,1)=i_indent
     g(nb_para,2)=i_item
     g(nb_para,6)=i

   end

   if a>0&strindex(txt_temp(i),'<DESCRIPTION_ITEM label=')<>[] then

     i_item=i_item+1

     if nb_para==0 & i-a>1 then
      nb_para=nb_para+1
      g(nb_para,1)=i_indent
      g(nb_para,2)=i_item
      g(nb_para,6)=a+1
      g(nb_para,7)=i-1
     end

     if last_item<>0 then
       if i_indent==0 & i-last_item>1 then
        nb_para=nb_para+1
        g(nb_para,1)=i_indent
        g(nb_para,2)=i_item
        g(nb_para,6)=last_item+1
        g(nb_para,7)=i-1
       end
     end

     last_item2=0

     nb_para=nb_para+1
     g(nb_para,1)=i_indent
     g(nb_para,2)=i_item
     g(nb_para,4)=i
     g(nb_para,5)=g(nb_para,4)
     g(nb_para,6)=i+1

   end

   if strindex(txt_temp(i),'<DESCRIPTION>')<>[] then
     a=i
   end

   if strindex(txt_temp(i),'</DESCRIPTION>')<>[] then
     b=i;

     if last_item<>0 then
       nb_para=nb_para+1
       g(nb_para,1)=i_indent
       g(nb_para,2)=i_item
       g(nb_para,6)=last_item+1
       g(nb_para,7)=b-1
     else
       if last_indent<>0 & b-last_indent>1 then
         nb_para=nb_para+1
         g(nb_para,1)=i_indent
         g(nb_para,2)=i_item
         g(nb_para,6)=last_indent+1
         g(nb_para,7)=b-1
       elseif last_indent==0 //cas sans indent ni item
         nb_para=nb_para+1
         g(nb_para,6)=a+1
         g(nb_para,7)=b-1
       end
     end

     break
   end
 end
//  time=toc();disp(time);

 if a<>[]&b<>[] then

//    disp('boucle 2');tic;
   txt_temp=strsubst(txt_temp,'<DESCRIPTION>',"");
   txt_temp=strsubst(txt_temp,'</DESCRIPTION>',"");
   txt_temp=strsubst(txt_temp,'<DESCRIPTION_INDENT>',"");
   txt_temp=strsubst(txt_temp,'</DESCRIPTION_INDENT>',"");
   txt_temp=strsubst(txt_temp,'<DESCRIPTION_ITEM>',"");
   txt_temp=strsubst(txt_temp,'</DESCRIPTION_ITEM>',"");
   txt_temp=strsubst(txt_temp,'<SP>',"");
   txt_temp=strsubst(txt_temp,'</SP>',"");
   txt_temp=strsubst(txt_temp,'<DESCRIPTION_ITEM label=""',"");
   txt_temp=strsubst(txt_temp,'"">',"");
//    time=toc();disp(time);

//    disp('boucle 3');tic;
   txt_temp=stripblanks_begin(txt_temp);
   txt_temp=stripblanks_end(txt_temp);
//    time=toc();disp(time);

   ind=[]
   //elimine les paragraphes vides
   for i=1:nb_para
     if g(i,4)==0 then
       if strcat(striplines(txt_temp(g(i,6):g(i,7))),...
                 ' ')<>"" then
         ind=[ind,i]
       end
     else
       ind=[ind,i]
     end
   end
   g=g(ind,:)
   nb_para=size(g,1)

   if nb_para<>0 then
     if min(g(:,2))==0 then g(:,2)=g(:,2)+1; end

//    disp('boucle 4');tic;
     tt=[];
     tt=tt+sci2exp(g(:,1),'aa',0)+...
            ','+sci2exp(g(:,2),'bb',0)+',[';
     for i=1:nb_para
          if g(i,4)<>0 then
          tt=tt+'strcat('+...
                'striplines(txt_temp(g('+...
                 string(i)+...
                 ',4):g('+...
                 string(i)+...
                 ',5))),'' ''),';
          else
            tt=tt+''''',';
          end
          tt=tt+'strcat('+...
                'striplines(txt_temp(g('+...
                 string(i)+...
                 ',6):g('+...
                 string(i)+...
                 ',7))),'' '');';
     end
     tt=part(tt,1:length(tt)-1);
     tt=tt+']';
     tt='txt_list=list('+tt+')';
//    time=toc();disp(time);

//    disp('boucle 5');tic;
     ierr=execstr(tt,'errcatch');
//    time=toc();disp(time);

     if ierr<>0 then
       printf("%s : error in generation\n"+...
              "of list of descriptions : %s\n",+...
          'return_xml_desc',fname);
     end
   else
     txt_list=[]
   end
 end
endfunction
