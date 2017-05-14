//change_capt_tex_file
//fonction qui effectue les changements sur les
//titres des figures dans un fichier tex pour rendre la page finale
//convertie en html par latex2html correctement affichable
//par le browser de scilab
//Entrée file_tex : fichier à analyser
//Sorite txt : texte du nouveau fichier tex

function txt=change_capt_tex_file(file_tex)

 txt_tex_main=mgetl(file_tex)
 num_fig=0;
 tt_fig=list();
 for i=1:size(txt_tex_main,1)
   if strindex(txt_tex_main(i),'\begin{figure}')<>[] then
     num_fig=num_fig+1
     a(num_fig)=i
     tt_fig(num_fig)=""
   elseif strindex(txt_tex_main(i),'\end{figure}')<>[] then
     b(num_fig)=i;
     //cherche \label{}
     lbl=[];
     for j=a(num_fig):b(num_fig)
       if strindex(txt_tex_main(j),'\label{')<>[] then
         lbl=part(txt_tex_main(j),...
                  strindex(txt_tex_main(j),'\label{'):...
                  length(txt_tex_main(j)));
         ja=1;
         //trouve le label
         for k=1:length(lbl)
           tt_lbl=part(lbl,k);
           if tt_lbl=='{' then
             ja=ja+1;
           elseif tt_lbl=='}' then
             ja=ja-1;
           end
           if ja==0 then break, end
         end
         lbl=part(lbl,1:k-1);
         lbl=strsubst(lbl,'\label{','\ref{')+'}';
       end
     end
     //cherche la ligne caption
     for j=a(num_fig):b(num_fig)
       if strindex(txt_tex_main(j),'\caption{')<>[] then
         capt=strsubst(txt_tex_main(j),'\caption{','');
         capt=stripblanks_begin(capt)
         if part(capt,1)<>'%' then
           ja=1;
           //trouve la légende
           for k=1:length(capt)
             tt_char=part(capt,k)
             if tt_char=='{' then
               ja=ja+1
             elseif tt_char=='}' then
               ja=ja-1
             end
             if ja==0 then break, end
           end
           capt=part(capt,1:k-1);

           tt_fig(num_fig)=[txt_tex_main(a(num_fig):j-1);
                            '%'+txt_tex_main(j);
                            txt_tex_main(j+1:b(num_fig));
                            '\begin{center}';
                            '  \textbf{Figure '+lbl+':} '+capt;
                            '\end{center}']
         end
       end
     end
     if tt_fig(num_fig)=="" then
      tt_fig(num_fig)=txt_tex_main(a(num_fig):b(num_fig));
     end
   end
 end

 if num_fig<>0 then
  txt=[]
  for i=1:num_fig
   if i==1 then
    i_beg=0
   else
    i_beg=b(i-1)
   end
   i_end=a(i)
   txt=[txt;txt_tex_main(i_beg+1:i_end-1);
        tt_fig(i);]
  end
  txt=[txt;txt_tex_main(b(num_fig)+1:size(txt_tex_main,1))]
 else
  txt=[];
 end

endfunction