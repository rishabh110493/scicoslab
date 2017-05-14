//fonction qui retourne les info nécessaires contenues dans
//SPECIALDESC pour dessiner les fenetres de dialogues sous-
//adjacentes à la fenetre de dialogue principale
//Entrée : name : nom du fichier (ex :'CONVOLGEN_f')
//         flag : html ou guide
//Sortie : txt : une matrice vide si on ne trouve pas d'info ([])
//               une liste si on trouve des info
function txt=return_dial_param(name,flag)
 txt=[];
 if fileinfo(name+'/SPECIALDESC')<>[] then
   tt=mgetl(name+'/SPECIALDESC');
   a=[];
   b=[];
   j=1;
   for i=1:size(tt,1)
     if strindex(tt(i),'>><<')<>[] then
       a(j)=i;
     elseif strindex(tt(i),'<<>>')<>[] then
       b(j)=i;
       j=j+1;
     end
   end
   
   if a<>[]&b<>[] then
     txt_temp=[];
     
     //initialisation de la liste
     txt=list();
     for i=1:j-1
       txt(i)=list()
       txt(i)(1)=0
       txt(i)(2)=""
       txt(i)(3)=""
       txt(i)(4)=[]
       txt(i)(5)=[]
     end
     
     for i=1:(j-1)
       txt_temp=tt(a(i)+1:b(i)-1);
       execstr(txt_temp);
       
       if exists('num_param') then //numéro du param
         txt(i)(1)=num_param       //qui fait afficher
       end                     //la boite de dialogue
     
       if exists('val_param') then //expression symbolique
         txt(i)(2)=val_param       //qui fait afficher
       end                         //la boite de dialogue
       
       if exists('exp_param') then //expression symbolique
         txt(i)(3)=exp_param       //a executer pour afficher
       end                         //la boite de dialogue
       
       if exists('txt_param') then //le texte de description
         txt(i)(4)=txt_param       //des paramètres de la
       end                        //boite de dialogue
       
       if flag=='html' then
         if exists('size_dial_param_html') then //la taille de la
           txt(i)(5)=size_dial_param_html      //boite de dialogue 
         end                                   //pour du html
       elseif flag=='guide' then
         if exists('size_dial_param_guide') then //la taille de la
           txt(i)(5)=size_dial_param_guide       //boite de dialogue 
         end                                    //pour du papier
       end
       
       clear num_param;clear exp_param;clear txt_param;
       clear size_dial_param_html;clear size_dial_param_guide;
     end
   end
 end
endfunction