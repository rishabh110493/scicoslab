//change_equa_tex_file
//fonction qui effectue les changements sur les
//equations dans un fichier tex pour rendre la page finale
//convertie en html par latex2html correctement affichable
//par le browser de scilab
//Entrée file_tex : fichier à analyser
//Sortie txt : texte du nouveau fichier tex

function txt=change_equa_tex_file(file_tex)

 txt_tex_main=mgetl(file_tex)

 num_equa=0;
 tt_equa=list();
 for i=1:size(txt_tex_main,1)
   if strindex(txt_tex_main(i),'\begin{eqnarray}')<>[] then
     num_equa=num_equa+1
     a(num_equa)=i
     tt_equa(num_equa)=""
   elseif strindex(txt_tex_main(i),'\begin{equation}')<>[] then
     num_equa=num_equa+1
     a(num_equa)=i
     tt_equa(num_equa)=""
   elseif strindex(txt_tex_main(i),'\end{eqnarray}')<>[] then
     b(num_equa)=i;
     tt_equa(num_equa)=txt_tex_main(a(num_equa):b(num_equa)); 
   elseif strindex(txt_tex_main(i),'\end{equation}')<>[] then
     b(num_equa)=i;
     tt_equa(num_equa)=txt_tex_main(a(num_equa):b(num_equa)); 
   end  
 end
 if num_equa<>0 then
   for i=1:num_equa
    tt_equa(i)=strsubst(tt_equa(i),'\begin{eqnarray}','$$');
    tt_equa(i)=strsubst(tt_equa(i),'\end{eqnarray}','$$');
    tt_equa(i)=strsubst(tt_equa(i),'\begin{equation}','$$');
    tt_equa(i)=strsubst(tt_equa(i),'\end{equation}','$$');
    tt_equa(i)=strsubst(tt_equa(i),'&=&','\,=\,'); 
    tt_equa(i)=strsubst(tt_equa(i),'&','\,'); 
   end

   new_tt_equa=list("");
   for i=1:num_equa
     k=1;
     for j=1:size(tt_equa(i),1)
       i_break=[];
       i_break=strindex(tt_equa(i)(j),'\\')
       if i_break<>[] then
         for e=1:size(i_break,2) 
           if e==1 then i_beg=1, else i_beg=i_break(e-1)+2, end
           i_end=i_break(e)-1;
           new_tt_equa(i)(k)=part(tt_equa(i)(j),i_beg:i_end);k=k+1;
           new_tt_equa(i)(k)="$$";k=k+1;
           new_tt_equa(i)(k)="$$";k=k+1;
         end
       else
         if k==1 then new_tt_equa(i)="", end;
         new_tt_equa(i)(k)=tt_equa(i)(j);
         k=k+1;
       end
     end
   end
 end

 if num_equa<>0 then
  tt_equa=new_tt_equa
  txt=[]
  for i=1:num_equa
   if i==1 then
    i_beg=0
   else
    i_beg=b(i-1)
   end
   i_end=a(i)
   txt=[txt;txt_tex_main(i_beg+1:i_end-1);
        tt_equa(i);]
  end
  txt=[txt;txt_tex_main(b(num_equa)+1:size(txt_tex_main,1))]
 else
  txt=[];
 end

endfunction