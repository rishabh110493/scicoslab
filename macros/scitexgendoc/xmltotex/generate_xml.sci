//generate_xml
//Fonction qui génère un fichier xml
//Entrée : lisf est une matrice 1x3 de chaîne de caractères
//         lisf(1,1) est le chemin du fichier scilab
//         lisf(1,2) est le chemin du fichier scilab 
//                   (avec extension si nécessaires)
//         lisf(1,3) renseigne sur le type d'objet
//               'block'
//               'diagr'
//               'pal' 
//               'scilib'
//               'sci'
//               'sim'
//               'sce'
//               'rout'
//
//        lang : langue
//               'eng'
//               'fr'
//
//
//Sortie : txt : texte du fichier xml à produire
function txt=generate_xml(lisf,lang)

 l_gen_xml= mlist(['convtable','lang',..
                        'tblock',..
                        'tpal',..
                        'tdiagr',..
                        'tscilib',..
                        'tsci',..
                        'trout',..
                        'troutcos',..
                        'tintfunc',..
                        'tsce',..
                        'tsim',..
                        'sz',..
                        'desc',..
                        'ex',..
                        'nparam',..
                        'dparam',..
                        'ddesc',..
                        'dex',..
                        'nauth',..
                        'rauth',..
                        'link',..
                        'dbib',..
                        'duf',..
                        'doparam',..
                        'prop',..
                        'title'],..
                        ["eng","fr"],..
                        ["Scicos Block","Bloc Scicos"],..
                        ["Scicos Palette","Palette Scicos"],..
                        ["Scicos Diagram","Diagramme Scicos"],..
                        ["Scilab Library","Librairie Scilab"],..
                        ["Scilab Function","Fonction Scilab"],..
                        ["Low level routine","Routine bas-niveau"],..
                        ["Computational routine","Fonction de calcul"],..
                        ["Interfacing function","Fonction d''interfaçage"],..
                        ["Scilab Script","Script Scilab"],..
                        ["Scilab simulation Script","Script de simulation Scilab"],..
                        ["of size","de taille"],..
                        ["The parameter description","La description du paramètre"],..
                        ["Example","Exemple"],..
                        ["Name of param.","Nom du paramètre"],..
                        ["add here the parameter description",..
                          "ajoutez ici la description du paramètre"],..
                        ["Add here a paragraph of the function description",..
                          "Ajoutez ici un paragraphe pour la description de la fonction"],..
                        ["Add here scilab instructions and comments",..
                          "Ajoutez ici les instructions scilab et les commentaires"],..
                        ["enter here the author name","entrez ici le nom des auteurs"],..
                        ["Add here the author  references","Ajoutez ici les références des auteurs"],..
                        ["add a key here","ajouter un lien ici"],..
                        ["Add here the function bibliography if any",..
                          "Ajoutez ici la bibliographie si besoin"],..
                        ["Add here the used function name and  references",..
                          "Ajoutez ici les noms et références des fonctions utilisées"],..
                        ["Other paragraph can be added",..
                          "Des autres paragraphes peuvent être ajoutés"],..
                        ["Properties",..
                          "Propriétés"],..
                        ["title","titre"]);

 ind_l=find(l_gen_xml.lang==lang);

 tt_uf='  '+['<USED_FUNCTIONS>';
             '  <SP>';
             '   '+l_gen_xml.duf(ind_l);
             '  </SP>';
             '</USED_FUNCTIONS>']

 tt_cs='  '+['<CALLING_SEQUENCE>';
             '<CALLING_SEQUENCE_ITEM>';
             ' </CALLING_SEQUENCE_ITEM>';
             '</CALLING_SEQUENCE>']

 tt_e='  '+['<EXAMPLE><![CDATA[';
            ']]></EXAMPLE>']

 tt_p='  '+['<PARAM>';'<PARAM_INDENT>';'';
            '  <PARAM_ITEM>';
            '  <PARAM_NAME>'+l_gen_xml.nparam(ind_l)+..
            '</PARAM_NAME>';
            '  <PARAM_DESCRIPTION>';'    <SP>';
            '    '+l_gen_xml.dparam(ind_l);
            '    </SP>';'  </PARAM_DESCRIPTION>';
            '  </PARAM_ITEM>';'';'</PARAM_INDENT>';
            '</PARAM>'];

 tt_x='  '+['<EXAMPLE>';'<P>';l_gen_xml.ex(ind_l)
      '</P>';'</EXAMPLE>']


 tt_desc=['  <DESCRIPTION>'
          '    <DESCRIPTION_INDENT>'
          '    <DESCRIPTION_ITEM>'
          '    <P>'
          '    '+l_gen_xml.ddesc(ind_l)
          '    </P>'
          '    </DESCRIPTION_ITEM>'
          '    </DESCRIPTION_INDENT>'
          '  </DESCRIPTION>']

 tt_see_also=['  <SEE_ALSO>'
              '  <SEE_ALSO_ITEM>'
              '   <LINK>'+l_gen_xml.link(ind_l)+..
                   '</LINK>'
              '  </SEE_ALSO_ITEM>'
              '  </SEE_ALSO>']

 tt_auth=['  <AUTHORS>'
          '    <AUTHORS_ITEM label='''+l_gen_xml.nauth(ind_l)+'''>'
          '    '+l_gen_xml.rauth(ind_l)
          '    </AUTHORS_ITEM>'
          '  </AUTHORS>']

 tt_bib=['  <BIBLIO>'
         '    <SP>'
         '     '+l_gen_xml.dbib(ind_l);
         '    </SP>'
         '  </BIBLIO>']

 tt_param=[];
 tt_pair_block=[];
 tt_call_seq=[];
 tt_rmk=[];
 tt_ex=[];
 tt_used_func=[];

 name=basename(lisf(1,2));
 flag=lisf(1,3)
 if flag=='mblock' then flag='block', end;

 select flag
   case 'block'
        typel=l_gen_xml.tblock(ind_l)
        tt_typ=return_typ_block(name,lisf(1,1));
        tt_lables=return_lables_block(name,lisf(1,1));
        tt_lables=tt_lables(:)
        tt_param=['<PARAM>';'  <PARAM_INDENT>';'']
        if tt_typ<>[] then
           for i=1:size(tt_lables,1)
              tt_param=[tt_param;'  <PARAM_ITEM>';
                        '  <PARAM_NAME>'+xmlsubst(tt_lables(i,1))+...
                          '</PARAM_NAME>';
                        '  <PARAM_DESCRIPTION>';
                        '    <SP>';
                        '    '+l_gen_xml.desc(ind_l)+' '+string(i)+'.';
                        '    </SP>';
                        '    <SP>';
                        '    '+l_gen_xml.prop(ind_l)+' : Type '''+...
                          xmlsubst(tt_typ(i,1))+''' '+...
                          l_gen_xml.sz(ind_l)+' '+xmlsubst(tt_typ(i,2))+'.';
                        '    </SP>';
                        '  </PARAM_DESCRIPTION>';
                        '  </PARAM_ITEM>';
                        '']
           end
        end
        tt_param='  '+[tt_param;'</PARAM_INDENT>';'</PARAM>']
        tt_ex=tt_x
        //tt_pair_block='  '+...
        //              ['<PAIR_BLOCK>';
        //               '<PAIR_BLOCK_ITEM> </PAIR_BLOCK_ITEM>';
        //               '</PAIR_BLOCK>']
        tt_used_func=tt_uf

   case 'pal'
        typel=l_gen_xml.tpal(ind_l)
        tt=return_block_pal(lisf(1,1)+lisf(1,2),,1);
//         if tt<>[] then
//           tt_see_also=['  <SEE_ALSO>']
//           for i=1:size(tt,1)
//            extname=get_extname(['',tt(i),'block'],%gd)
//            tt_see_also=[tt_see_also;
//                         '   <SEE_ALSO_ITEM>';
//                         '     <A href=""'+extname+'.htm"">'+..
//                           tt(i)+'</A>';
//                         '   </SEE_ALSO_ITEM>']
//           end
//           tt_see_also=[tt_see_also;
//                        '  </SEE_ALSO>']
//         end

   case 'diagr' 
        typel=l_gen_xml.tdiagr(ind_l)
        tt_ex=tt_x

   case 'scilib'
 tt_used_func=[];
        typel=l_gen_xml.tscilib(ind_l)
        tt=return_func_scilib(name)
//         if tt<>[] then
//           tt_see_also=['  <SEE_ALSO>']
//           for i=2:size(tt,1)
//            extname=get_extname(['',tt(i),'sci'],%gd)
//            tt_see_also=[tt_see_also;
//                         '   <SEE_ALSO_ITEM>';
//                         '     <A href=""'+extname+'.htm"">'+..
//                         tt(i)+'</A>';
//                         '   </SEE_ALSO_ITEM>']
//           end
//           tt_see_also=[tt_see_also;
//                        '  </SEE_ALSO>']

//           tt_used_func=['  <USED_FUNCTIONS>']
//           for i=2:size(tt,1)
//            extname=get_extname(['',tt(i),'sci'],%gd)
//            tt_used_func=[tt_used_func;
//                   '   <SP>';
//                   '     <A href=""'+extname+'.htm"">'+..
//                    tt(i)+'</A>';
//                   '   </SP>']
//           end
//           tt_used_func=[tt_used_func;
//                  '  </USED_FUNCTIONS>']

//         end

   case 'sci'
        prot=funcprot();funcprot(0);
        ierr=execstr('txt=help_skeleton(name);','errcatch');
        funcprot(prot);
        if ierr==0 then
         txt_tmp=[]
         for i=1:size(txt,1)
           if strindex(txt(i),'<SEE_ALSO_ITEM>'+..
                              ' <LINK> add a key here'+..
                              '</LINK> </SEE_ALSO_ITEM>')<>[] then
              txt_tmp=[txt_tmp;
                       '   <SEE_ALSO_ITEM>';
                       '     <A href=""fic.htm"">add a key here</A>';
                       '   </SEE_ALSO_ITEM>']
           else
            txt_tmp=[txt_tmp;txt(i)];
           end
          end
          txt=txt_tmp;
          if lang<>'eng' then
            txt=strsubst(txt,'<LANGUAGE>eng</LANGUAGE>',..
                             '<LANGUAGE>'+l_gen_xml.lang(ind_l)+..
                             '</LANGUAGE>');
            txt=strsubst(txt,'<TYPE>Scilab Function',..
                             '<TYPE>'+l_gen_xml.tsci(ind_l))
            txt=strsubst(txt,'Add here a paragraph of the function description',..
                             l_gen_xml.ddesc(ind_l))
            txt=strsubst(txt,'Add here scilab instructions and comments',..
                             l_gen_xml.dex(ind_l))
            txt=strsubst(txt,'enter here the author name',..
                             l_gen_xml.nauth(ind_l))
            txt=strsubst(txt,'Add here the author  references',..
                             l_gen_xml.rauth(ind_l))
            txt=strsubst(txt,'add a key here',..
                             l_gen_xml.link(ind_l))
            txt=strsubst(txt,'Add here the function bibliography if any',..
                             l_gen_xml.dbib(ind_l))
            txt=strsubst(txt,'Add here the used function name and  references',..
                             l_gen_xml.duf(ind_l))
            txt=strsubst(txt,'Other paragraph can be added',..
                             l_gen_xml.doparam(ind_l))
            txt=strsubst(txt,'add here the parameter description',..
                             l_gen_xml.dparam(ind_l))
            txt=strsubst(txt,'  add short decription here',..
                             name+' '+l_gen_xml.title(ind_l))
          end
          return
        else
          typel=l_gen_xml.tsci(ind_l)
          tt_param=tt_p
          tt_call_seq=tt_cs
          tt_ex=tt_e
          tt_used_func=tt_uf;
        end

   case 'rout'
        typel=l_gen_xml.trout(ind_l)
        tt_param=tt_p
        tt_call_seq=tt_cs
        tt_ex=tt_e
        tt_used_func=tt_uf

   case 'routcos'
        typel=l_gen_xml.troutcos(ind_l)
        tt_desc=[]
        tt_see_also=[]
        tt_bib=[]
        tt_auth=[]

   case 'intfunc'
        typel=l_gen_xml.tintfunc(ind_l)
        tt_desc=[]
        tt_see_also=[]
        tt_bib=[]
        tt_auth=[]

   case 'scifunc'
        typel=l_gen_xml.tsci(ind_l)
        tt_desc=[]
        tt_see_also=[]
        tt_bib=[]
        tt_auth=[]

   case 'sce'
        typel=l_gen_xml.tsce(ind_l)
        tt_used_func=tt_uf
        tt_call_seq=tt_cs

   case 'sim'
        typel=l_gen_xml.tsim(ind_l)
        tt_used_func=tt_uf
 end

 tt_head=['<?xml version='"1.0'" encoding='"ISO-8859-1'" standalone='"no'"?>'
          '<!DOCTYPE MAN SYSTEM '"'+SCI+'/man/manrev.dtd'">'
          '<MAN>'
          '  <LANGUAGE>'+lang+'</LANGUAGE>'
          '  <TITLE>'+name+'</TITLE>'
          '  <TYPE>'+typel+'</TYPE>'
          '  <DATE>'+date()+'</DATE>'
          '  <SHORT_DESCRIPTION name='"'+name+''">'+..
           name+' '+l_gen_xml.title(ind_l)+'</SHORT_DESCRIPTION>'
          '']

 txt=[tt_head]
 if tt_call_seq<>[] then
   txt=[txt
        tt_call_seq
        '']
 end
 if tt_desc<>[] then
   txt=[txt
        tt_desc
        '']
 end
 if tt_rmk<>[] then
   txt=[txt
        tt_rmk
        '']
 end
 if tt_ex<>[] then
   txt=[txt
        tt_ex
        '']
 end
 if tt_param<>[] then
   txt=[txt
        tt_param
        '']
 end
 if tt_pair_block<>[] then
   txt=[txt
        tt_pair_block
        '']
 end
 if tt_used_func<>[] then
   txt=[txt
        tt_used_func
        '']
 end
 if tt_see_also<>[] then
   txt=[txt
        tt_see_also
        '']
 end
 if tt_bib<>[] then
   txt=[txt
        tt_bib
        '']
 end
 if tt_auth<>[] then
   txt=[txt
        tt_auth
        '']
 end
 txt=[txt;'</MAN>']

endfunction
