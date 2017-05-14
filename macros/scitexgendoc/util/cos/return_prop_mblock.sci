//return_prop_mblock
//fonction qui retourne les propriétés par default
//d'une fonction d'interface d'un bloc modelica/scicos
//
//Entrée : name : le nom de la fonction d'interface sans extension
//        lang :  (optionel) 'fr' pour du francais
//                           'eng' et autres pour de l'anglais
//Sortie : txt : liste de texte des propriétés par défauts
function [txt_model,txt_in,txt_out,txt_param] = return_prop_mblock(name,lang)

 //verify the lang parameter
 [lsh,rsh]=argn(0)
 if rsh<2 then
   lang='eng'
 end

 //load scicos libraries 
 load SCI/macros/scicos/lib

 //execute define case
 ierror=execstr('blk='+name+'(''define'')','errcatch')
 if ierror<>0 then
    x_message(['Error in case define of GUI function';lasterror()] )
    disp(name)
    return
 end

 txt_in = [];
 txt_out = [];
 txt_param =[];
 txt_model =[];

 //
 modeliK=blk.model.equations;

 if modeliK==list() then
  return
 end

 //
 txt_model = modeliK.model;

 //
 for in=1:size(modeliK.inputs,'*')
     if lang=='fr' then
       txt_in = [txt_in;
                 '  \item{\bf Nom de la variable Modelica :} '''+...
                    latexsubst(modeliK.inputs(in))+'''\\'];
       if blk.graphics.in_implicit(in)=="I" then
         txt_in = [txt_in;
                   '        {\bf Variable} implicite.'
                   ''];
       else
         txt_in = [txt_in;
                   '        {\bf Variable} explicite.'
                   ''];
       end
     else
       txt_in = [txt_in;
                 '  \item{\bf Modelica variable name :} '''+...
                    latexsubst(modeliK.inputs(in))+'''\\'];
       if blk.graphics.in_implicit(in)=="I" then
         txt_in = [txt_in;
                   '        Implicit {\bf variable.}'
                   ''];
       else
         txt_in = [txt_in;
                   '        Explicit {\bf variable.}'
                   ''];
       end
     end
 end

 //
 for out=1:size(modeliK.outputs,'*')
     if lang=='fr' then
       txt_out = [txt_out;
                 '  \item{\bf Nom de la variable Modelica :} '''+...
                    latexsubst(modeliK.outputs(out))+'''\\'];
       if blk.graphics.out_implicit(out)=="I" then
         txt_out = [txt_out;
                   '        {\bf Variable} implicite.'
                   ''];
       else
         txt_out = [txt_out;
                   '        {\bf Variable} explicite.'
                   ''];
       end
     else
       txt_out = [txt_out;
                 '  \item{\bf Modelica variable name :} '''+...
                    latexsubst(modeliK.outputs(out))+'''\\'];
       if blk.graphics.out_implicit(out)=="I" then
         txt_out = [txt_out;
                   '        Implicit {\bf variable.}'
                   ''];
       else
         txt_out = [txt_out;
                   '        Explicit {\bf variable.}'
                   ''];
       end
     end
 end

 //

 if modeliK.parameters<>[] then
   if lstsize(modeliK.parameters)<>0 then
     if lang=='fr' then
       for i=1:size(modeliK.parameters(1),'*')
          txt_param=[txt_param;
                     '  \item{\bf Nom du paramètre Modelica :} '''+...
                        latexsubst(modeliK.parameters(1)(i))+'''\\'
                     '       {\bf Valeur par défaut :} '+sci2exp(modeliK.parameters(2)(i))+'\\'
                     '       {\bf Variable d''état :} '];
          if lstsize(modeliK.parameters)>2 then
             if modeliK.parameters(3)(i)==0 then
               txt_param($) = txt_param($) + 'non.';
             else
               txt_param($) = txt_param($) + 'oui.';
             end
          else
            txt_param($) = txt_param($) + 'non.';
          end
          txt_param=[txt_param;
                     ''];
       end
     else
       for i=1:size(modeliK.parameters(1),'*')
          txt_param=[txt_param;
                     '  \item{\bf Modelica parameter name :} '''+...
                       latexsubst(modeliK.parameters(1)(i))+'''\\'
                     '       {\bf Default value :} '+sci2exp(modeliK.parameters(2)(i))+'\\'
                     '       {\bf Is a state variable :} '];
          if lstsize(modeliK.parameters)>2 then
             if modeliK.parameters(3)(i)==0 then
               txt_param($) = txt_param($) + 'no.';
             else
               txt_param($) = txt_param($) + 'yes.';
             end
          else
            txt_param($) = txt_param($) + 'no.';
          end
          txt_param=[txt_param;
                     ''];
       end
     end
   end
 end

endfunction