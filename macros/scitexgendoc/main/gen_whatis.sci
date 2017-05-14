//Fonction qui genère le fichier whatis.htm

function gen_whatis(ffile,%gd)

 if fileinfo(ffile)<>[] then
   txt_tmp=mgetl(ffile);
 else
   gendoc_printf(%gd,"%s : xml file not found in %s\n",...
          basename(ffile),...
          ffile);
   return
 end

 deff('[dt]=char_handl(dt,txt)',...
     [' if dt.a==1 then';
      '  dt.mystr=[dt.mystr;';
      '              stripblanks_end('+...
      '              stripblanks_begin(txt)'+...
      '                             )]';
      ' end'])

 deff('[dt]=start_handl(dt,el,attr)',...
     ['select el';
      ' case ''WHATIS'' then';
      '   dt.mystr=[dt.mystr;""<html>""]';
      ''
      ' case ''DATE'' then';
      ''//TOBEDONE
      ' case ''TITLE'' then';
      '    for i=1:size(attr,2)';
      ''
      '      if attr(1,i)==dt.lang then';
      ''
      '        tt_ltitle=[%gd.lang+""</A>""];';
      '        tt_ltitle(dt.ind)=""<A HREF=""""'+basename(ffile)+'.htm"""">""+tt_ltitle(dt.ind);';
      '        k=1;';
      '        tt=return_relative_path(dt.ind,%gd);';
      '        for j=1:size(%gd.lang,''*'')';
      '          if j<>dt.ind then';
      '            tt_ltitle(j)=""<A HREF=""""""+tt(k)+""'+basename(ffile)+'.htm"""">""+tt_ltitle(j)';
      '            k=k+1;';
      '          end';
      '        end';
      '        for j=1:size(%gd.lang,''*'')';
      '           if j<>size(%gd.lang,''*'')';
      '              tt_ltitle(j)=tt_ltitle(j) + "" - ""'
      '           end'
      '        end'
      ''
      '        dt.mystr=[dt.mystr;';
      '                  ""<head>"";';
      '                  ""  <meta http-equiv=""""Content-Type"""" content=""""text/html; charset=ISO-8859-1"""">"";';
      '                  ""    <title>""+attr(2,i)+""</title>"";';
      '                  ""</head>"";';
      '                  ""<body bgcolor=""""#FFFFFF"""">"";';
      '                  ""<DIV ALIGN=""""CENTER"""">"";';
      '                  attr(2,i);';
      '                  ""<BR>"";';
      '                  tt_ltitle'
      '                  ""<font color=""""black"""">"";';
      '                  ""<BR>"";';
      '                  ""</DIV>"";';
      '                  ""<BR>""]';
      '      end';
      '    end'
      ' case ''CHAPTER'' then';
      '    for i=1:size(attr,2)';
      '      if attr(1,i)==dt.lang then';
      '        dt.mystr=[dt.mystr;';
      '                  ""<BR>"";';
      '                  ""<b><LI>""+attr(2,i)+""</b>"";';
      '                  ""<UL>"";]';
      '      end';
      '    end'
      ' case ''SUBCHAPTER'' then';
      '    for i=1:size(attr,2)';
      '      if attr(1,i)==dt.lang then';
      '        dt.mystr=[dt.mystr;';
      '                  ""<BR>"";';
      '                  ""<LI>""+attr(2,i);';
      '                  ""<UL>"";]';
      '      end';
      '    end'
      ' case ''SECTION'' then';
      '    for i=1:size(attr,2)';
      '      if attr(1,i)==dt.lang then';
      '        dt.mystr=[dt.mystr;';
      '                  ""<P>"";';
      '                  ""<LI>""+attr(2,i)];';
      '      end';
      '    end'
      ' case ''DIAGR'' then';
      '    dt.tag=el';
      '    dt.attr=attr;'
      ' case ''SIM'' then';
      '    dt.tag=el';
      '    dt.attr=attr;'
      ' case ''ROUT'' then';
      '    dt.tag=el';
      '    dt.attr=attr;'
      ' case ''PAL'' then';
      '    dt.tag=el';
      '    dt.attr=attr;'
      ' case ''PALREF'' then';
      '    dt.tag=el';
      '    dt.attr=attr;'
      ' case ''SCILIB'' then';
      '    dt.tag=el';
      '    dt.attr=attr;'
      ' case ''BLK'' then';
      '    dt.tag=el';
      '    dt.attr=attr;';
      ' case ''SCI'' then';
      '    dt.tag=el';
      '    dt.attr=attr;'
      ' case ''SCE'' then';
      '    dt.tag=el';
      '    dt.attr=attr;'
      'end']);

 deff('[dt]=end_handl(dt,el)',...
     ['select el';
      ' case ''WHATIS'' then';
      '    dt.mystr=[dt.mystr;';
      '              ""</body></html>""]';
      ' case ''DATE'' then';
      ' case ''TITLE'' then';
      ' case ''CHAPTER'' then';
      '    dt.mystr=[dt.mystr;';
      '              ""</UL>""]';
      ' case ''SUBCHAPTER'' then';
      '    dt.mystr=[dt.mystr;';
      '              ""</UL>""]';
      ' case ''SECTION'' then';
      '    dt.mystr=[dt.mystr;';
      '              ""</P>""]';
      ' case ''DIAGR'' then';
      ' case ''ROUT'' then';
      ' case ''SIM'' then';
      ' case ''PAL'' then';
      '    dt.mystr=[dt.mystr;';
      '              ""</BLOCKQUOTE>"";';
      '              ""</P>""]';
      ' case ''PALREF'' then';
      ' case ''SCILIB'' then';
      '    dt.mystr=[dt.mystr;';
      '              ""</P>""]';
      ' case ''BLK'' then';
      ' case ''SCI'' then';
      ' case ''SCE'' then';
      'end']);

 for i=1:size(%gd.lang,1)

   gendoc_printf(%gd,"(%s) Creation of %s.htm... ",%gd.lang(i),basename(ffile));

   %ptr=XML_ParserCreate("ISO-8859-1");
   XML_Conv2Latin(%ptr);
   XML_SetUserData(%ptr,'dt');
   XML_SetElementHandler(%ptr,'start_handl','end_handl');
   XML_SetCharDataHandler(%ptr,'char_handl');

   dt = struct('a',0,'tag',[],'attr',[],'lang',%gd.lang(i),'ind',i,'mystr',['']);

   for j=1:size(txt_tmp,1)

      XML_Parse(%ptr, txt_tmp(j), j==size(txt_tmp,1));

      //this is done here because the call of return_sdesc
      //which use XMLParser()
      if dt.tag<>[] then
        select dt.tag
          case 'PAL' then

            bsnam=get_extname(["",dt.attr(2,2),"pal"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                          "<P>";
                          "<LI><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)
                          "<BLOCKQUOTE>"];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)];
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

          case 'PALREF' then

            bsnam=get_extname(["",dt.attr(2,2),"pal"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                         "<BR><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)]
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

          case 'SCILIB' then

            bsnam=get_extname(["",dt.attr(2,2),"scilib"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                          "<P>";
                          "<LI><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)];
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

          case 'DIAGR' then

            bsnam=get_extname(["",dt.attr(2,2),"diagr"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                          "<BR><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)];
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

          case 'SIM' then

            bsnam=get_extname(["",dt.attr(2,2),"sim"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                          "<BR><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)];
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

          case 'ROUT' then
            bsnam=get_extname(["",dt.attr(2,2),"rout"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                          "<BR><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)];
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

          case 'BLK' then

            bsnam=get_extname(["",dt.attr(2,2),"block"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                         "<BR><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)];
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

          case 'SCI' then

            bsnam=get_extname(["",dt.attr(2,2),"sci"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                         "<BR><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)]
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

          case 'SCE' then

            bsnam=get_extname(["",dt.attr(2,2),"sce"],%gd);
            ierr=execstr('sdesc=return_xml_sdesc(%gd.mpath.xml(i)+bsnam+''.xml'');','errcatch');
            if ierr==0 then
              if sdesc<>[] then
                dt.mystr=[dt.mystr;
                         "<BR><A HREF="""+bsnam+".htm"">"+sdesc(1,1)+"</A> - "+sdesc(1,2)];
              else
                dt.mystr=[dt.mystr;
                          "<BR>"+dt.attr(2,2)]
              end
            else
               gendoc_printf(%gd,"\n%s : error while parsing file %s\n",...
               'gen_whatis',bsnam+'.xml');
               return
            end

        end
      end

      dt.tag=[];
      dt.attr=[];
   end

   mputl(dt.mystr,%gendoc.mpath.html(i)+basename(ffile)+".htm");

   gendoc_printf(%gd,"Done\n");
 end
endfunction