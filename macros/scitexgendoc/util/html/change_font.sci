//change_font
//Fonction qui change les fontes
//d'une page d'aide html produits par latex2html
//aux "normes" des pages d'aides scilab
//produites par xmltohtml
//Entrée : htmf  : un nom de fichier à modifier
//         flag : 'block','pal','sci','scilib',....
//Sortie : tt le texte du fichier htm
function tt=change_font(htmf,flag,%gd)
 if ~exists('flag') then flag='sci', end;
 ok=%f
 notyet=%f;cb=0;
 if fileinfo(htmf(1,1))<>[] then
  tt=mgetl(htmf(1,1));
  if tt<>[] then
    gendoc_printf(%gd,"\tFont convertion... ");

    //1ere analyse : ajuste le texte en gras

    flaga='<SPAN  CLASS=""textbf"">';
    flagb='<SPAN ';
    flagc='</SPAN>'
    count=0;

    while i<>size(tt,1)
      a=strindex(tt(i),flaga);
      if a<>[] then
        tt(i)=strsubst(tt(i),flaga,'<b>');
      end

      b=strindex(tt(i),flagb);
      if b<>[] then
        count=count+size(b,'*');
      end

      c=strindex(tt(i),flagc);
      if c<>[] then
        for j=1:size(c,2)
           if count<>0 then
             count=count-1
           else
             len=length(flagc)
             tt(i)=part(tt(i),1:c(1,j)-1)+'</b>'+...
                    part(tt(i),c(1,j)+len:length(tt(i)))
           end
        end
      end

      i=i+1
    end
    gendoc_printf(%gd,"Done\n");

    //2eme analyse : Change la 1ere ligne des fichiers d'aide
    //type 'sci' et 'rout' - enlève le les délimiteurs <H1> </H1>
    if flag=='sci'|flag=='rout'|flag=='sce' then
     if flag=='sci' then
       gendoc_printf(%gd,"\tScilab function : change font of first line... ");
     elseif flag=='rout' then
       gendoc_printf(%gd,"\tLow level routine : change font of first line... ");
     elseif flag=='sce' then
       gendoc_printf(%gd,"\tScilab script : change font of first line... ");
     end
     for i=1:size(tt,1)
      tt(i)=strsubst(tt(i),'<H1>','<BR>');
      tt(i)=strsubst(tt(i),'</H1>','');
     end
     gendoc_printf(%gd,"Done\n");
    end

    //3eme analyse : change la profondeur des titres et sous-titres
    gendoc_printf(%gd,"\tChange level of subtitles... ")
    for i=1:size(tt,1)
     tt(i)=strsubst(tt(i),'<H2>','<H3>');
     tt(i)=strsubst(tt(i),'</H2>','</H3>');
     tt(i)=strsubst(tt(i),'<H1>','<H2>');
     tt(i)=strsubst(tt(i),'</H1>','</H2>');
    end
    gendoc_printf(%gd,"Done\n");

    //4eme analyse : enlève la ligne du bas et passe
    //<BODY > en <BODY bgcolor="#FFFFFF">
    gendoc_printf(%gd,"\tChange body color and remove address line... ")
    for i=1:size(tt,1)
      tt(i)=strsubst(tt(i),'<BODY>','<BODY bgcolor=""#FFFFFF"">');
      tt(i)=strsubst(tt(i),'<BODY >','<BODY bgcolor=""#FFFFFF"">');
      if strindex(tt(i),'<ADDRESS>')<>[] then
       aa=i
       if strindex(tt(i-1),'<HR>')<>[] then
         tt(i-1)=strsubst(tt(i-1),'<HR>','');
       end
      end
      if strindex(tt(i),'</ADDRESS>')<>[] then
       bb=i
      end
    end

    if exists('aa')&exists('bb') then
     for i=aa:bb
      tt(i)=""
     end
    end
    gendoc_printf(%gd,"Done\n");

    //5eme analyse : change les délimiteurs '<P><A' en '<A'
    //et </A></P>
    gendoc_printf(%gd,"\tVerification of labels... ")
    for i=1:size(tt,1)
     if strindex(tt(i),'<P><A')<>[] then
      tt(i)=strsubst(tt(i),'<P><A','<A');
      tt(i)=strsubst(tt(i),'</A></P>','');
     end
    end
    gendoc_printf(%gd,"Done\n");

    //6eme analyse : change <P ALIGN="RIGHT">
    // end <P ALIGN="LEFT">
    gendoc_printf(%gd,"\tAlign equation... ")
    for i=1:size(tt,1)
     if strindex(tt(i),'<!-- MATH')<>[] then
       if strindex(tt(i),'<P ALIGN=""RIGHT"">')<>[] then
         tt(i)=strsubst(tt(i),'<P ALIGN=""RIGHT"">',...
                              '<P ALIGN=""LEFT"">')
       elseif strindex(tt(i),'<DIV ALIGN=""RIGHT"">')<>[] then
         tt(i)=strsubst(tt(i),'<DIV ALIGN=""RIGHT"">',...
                              '<DIV ALIGN=""LEFT"">')
       end
     end
    end
    gendoc_printf(%gd,"Done\n");
  end
 else
  tt=[]
 end
endfunction