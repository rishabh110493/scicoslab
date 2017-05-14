//return_xml_param : fonction qui retourne
//                   les paramères d'un fichier xml
//                   d'aide scilab sous une forme
//                   formatée
//
//ex : return_xml_param(SCI+'/man/eng/'+..
//                      'nonlinear/bvode.xml')
//
//Entrée fname : chemin+nom du fichier xml
//
//Sortie  :
//  txt_list : une liste de paramètres
//     txt_list()
//             |
//             |--> 1  : vecteur de taile n
//                       profondeur de description
//
//                  2  : vecteur de taile n
//                       niveau d'indentation
//
//                  3  : tableau de chaines
//                       de caractères de taille n,1
//                         nom du paramètre
//
//                  4 : une liste de tableau de chaine de
//                      taille n,x
//                      x : nombre de sous-paragraphes dans
//                          l'item
//                      sous-paragraphes par paramètre
//

function txt_list=return_xml_param(fname)

 txt_list=[]
 a=[]
 b=[]
 c=[]

 nb_indent=0
 nb_max_indent=0
 nb_item=0

 if fileinfo(fname)<>[] then
   txt_temp=mgetl(fname);
 else
   printf("%s : xml file not found in %s\n",...
          'return_xml_param',...
          fname);
   return
 end

 //Cherche les bornes
 //   <PARAM>  </PARAM>
 //   <PARAM_ITEM>
//  disp('boucle 1');tic;
 for i=1:size(txt_temp,1)
   if a>0&strindex(txt_temp(i),'<PARAM_ITEM>')<>[] then
     nb_item=nb_item+1;
   end
   if strindex(txt_temp(i),'<PARAM>')<>[] then
     a=i;
   end;
   if strindex(txt_temp(i),'</PARAM>')<>[] then
     b=i;
     break
   end
 end
//  time=toc();disp(time);

 if a<>[]&b<>[] then

   //Détermine un tableau d'indice
   j=0; //prof indent
   k=0; //prof desc
   e=0; //nb param
   //g une matrice d'indice de taile nb_itemx7
   //g(:,1) la profondeur d'indentation
   //g(:,2) la profondeur de description
   //g(:,3) l'indice du paramètre parent
   //g(:,4),g(:,5) l'indice de début,fin du
   //              bloc PARAM_NAME
   //g(:,6),g(:,7) l'indice de début,fin du
   //              bloc PARAM_DESCRIPTION

   g=zeros(nb_item,7);

//    disp('boucle 2');tic;
   for i=a:b
     if strindex(txt_temp(i),'<PARAM_INDENT>')<>[] then
       j=j+1;
     end
     if strindex(txt_temp(i),'</PARAM_INDENT>')<>[] then
       j=j-1;
     end
     if strindex(txt_temp(i),'<PARAM_ITEM>')<>[] then
       e=e+1;
       g(e,1)=j;
       g(e,2)=k;
       g(e,3)=0;
     end
     if strindex(txt_temp(i),'<PARAM_NAME>')<>[] then
       g(e,4)=i;
     end
     if strindex(txt_temp(i),'</PARAM_NAME>')<>[] then
       g(e,5)=i;
     end
     if strindex(txt_temp(i),'<PARAM_DESCRIPTION>')<>[] then
       k=k+1
       g(e,6)=i
     end
     if strindex(txt_temp(i),'</PARAM_DESCRIPTION>')<>[] then
       k=k-1
       if g(e,7)==0 then
         g(e,7)=i
       else
         f=e
         while g(f,2)<>k
           f=f-1
         end
         //g(f,7)=i //?? le parseur ne fait pas cela !!
         g(f,7)=g(f+1,4)-1 //ATTENTION ICI
         ww=find(g(f+1:e,3)==0);
         g(f+ww,3)=f;
       end
     end
   end
//    time=toc();disp(time);

//    disp('boucle 3');tic;
   txt_temp=strsubst(txt_temp,'<PARAM_NAME>','');
   txt_temp=strsubst(txt_temp,'</PARAM_NAME>','');
   txt_temp=strsubst(txt_temp,'<PARAM_ITEM>','');
   txt_temp=strsubst(txt_temp,'</PARAM_ITEM>','');
   txt_temp=strsubst(txt_temp,'<PARAM_INDENT>','');
   txt_temp=strsubst(txt_temp,'</PARAM_INDENT>','');
   txt_temp=strsubst(txt_temp,'<PARAM_DESCRIPTION>','');
   txt_temp=strsubst(txt_temp,'</PARAM_DESCRIPTION>','');
//    time=toc();disp(time);

//    disp('boucle 4');tic;
   txt_temp=stripblanks_begin(txt_temp);
   txt_temp=stripblanks_end(txt_temp);
//    time=toc();disp(time);

   if min(g(:,2))==0 then g(:,2)=g(:,2)+1; end

   sp_hh='';
   for i=1:nb_item
     h=0;
     hh=[];
     for j=g(i,6):g(i,7)
       if strindex(txt_temp(j),'<SP>')<>[] then
          h=h+1;
          hh=[hh;j,0];
       elseif strindex(txt_temp(j),'</SP>')<>[] then
          hh(h,2)=j;
       end
     end
     if i<>nb_item then
       sp_hh=sp_hh+'list(';
       for j=1:size(hh,1)
         if j<>size(hh,1) then
           sp_hh=sp_hh+...
                 'strcat('+...
                 'striplines(strsubst(strsubst(txt_temp('+...
                 string(hh(j,1))+':'+...
                 string(hh(j,2))+...
                 '),''<SP>'',''''),''</SP>'','''')),'' ''),';
         else
           sp_hh=sp_hh+...
                 'strcat('+...
                 'striplines(strsubst(strsubst(txt_temp('+...
                 string(hh(j,1))+':'+...
                 string(hh(j,2))+...
                 '),''<SP>'',''''),''</SP>'','''')),'' '')';
         end
       end
       sp_hh=sp_hh+'),';
     else
       sp_hh=sp_hh+'list(';
       for j=1:size(hh,1)
         if j<>size(hh,1) then
           sp_hh=sp_hh+...
                 'strcat('+...
                 'striplines(strsubst(strsubst(txt_temp('+...
                 string(hh(j,1))+':'+...
                  string(hh(j,2))+...
                 '),''<SP>'',''''),''</SP>'','''')),'' ''),';
         else
           sp_hh=sp_hh+...
                 'strcat('+...
                 'striplines(strsubst(strsubst(txt_temp('+...
                 string(hh(j,1))+':'+...
                 string(hh(j,2))+...
                 '),''<SP>'',''''),''</SP>'','''')),'' '')';
         end
       end
       sp_hh=sp_hh+')';
     end
   end
   ierr=execstr('sp = list('+sp_hh+')','errcatch')
   clear sp_hh

   txt_temp=strsubst(txt_temp,'<SP>','');
   txt_temp=strsubst(txt_temp,'</SP>','');

//    disp('boucle 5');tic;
   tt=[];
   tt=tt+sci2exp(g(:,1),'aa',0)+...
          ','+sci2exp(g(:,2),'bb',0)+',[';
//    for i=1:nb_item
//         tt=tt+'strcat('+...
//               'striplines(txt_temp(g('+...
//                string(i)+...
//                ',4):g('+...
//                string(i)+...
//                ',5))),'' ''),';
//         tt=tt+'strcat('+...
//               'striplines(txt_temp(g('+...
//                string(i)+...
//                ',6):g('+...
//                string(i)+...
//                ',7))),'' '');';
// //    end
//    tt=part(tt,1:length(tt)-1);
//    tt=tt+']';
//    tt='txt_list=list('+tt+')';
//    ierr=execstr(tt,'errcatch');

   if nb_item<>0 then
     for i=1:nb_item
          tt=tt+'strcat('+...
                'striplines(txt_temp(g('+...
                 string(i)+...
                 ',4):g('+...
                 string(i)+...
                 ',5))),'' '');';
     end

     tt=part(tt,1:length(tt)-1);
   end
   tt=tt+']';
   tt='txt_list=list('+tt+',sp)';
//    time=toc();disp(time);

//    disp('boucle 5');tic;
   ierr=execstr(tt,'errcatch');
//    time=toc();disp(time);

   if ierr<>0 then
       printf("%s : error in generation\n"+...
              "of list of parameters : %s\n",+...
          'return_xml_param',fname);
    end

 end

endfunction 
