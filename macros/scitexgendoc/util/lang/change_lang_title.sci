//fonction qui change des titres donnés dans
//un vecteur de chaînes de caractères
//suivant le paramètre lang
//entrée : lang : 'fr' pour du francais
//         title : vecteurs de chaines de caratères
function txt=change_lang_title(lg,ttitle)
 txt=ttitle

 if lg=='fr' then
  txt=strsubst(txt,'Theorical background','Rappel théorique');
  txt=strsubst(txt,'Technical background','Rappel technique');
  txt=strsubst(txt,'Algorithm','Algorithmes');
  txt=strsubst(txt,'Basic blocks equivalent model','Modèle équivalent en blocs de base');
  txt=strsubst(txt,'Scilab script/function equivalent Model','Script/fonction scilab équivalente');
  txt=strsubst(txt,'Dialog box','Boîte de dialogue');
  txt=strsubst(txt,'Example','Exemple');
  txt=strsubst(txt,'Default properties','Propriétés par défaut');
  txt=strsubst(txt,'Interfacing function','Fonction d''interface');
  txt=strsubst(txt,'Compiled Super Block content','Contenu du super-bloc compilé');
  txt=strsubst(txt,'Modelica model','Modèle Modelica');
  txt=strsubst(txt,'Computational function','Fonction de calcul');
  txt=strsubst(txt,'Used functions','Fonction utilisée');
  txt=strsubst(txt,'See also','Voir aussi');
  txt=strsubst(txt,'See Also','Voir aussi');
  txt=strsubst(txt,'Authors','Auteurs');
  txt=strsubst(txt,'Bibliography','Bibliographie');
  txt=strsubst(txt,'Blocks','Blocs');
  txt=strsubst(txt,'Context file(s)','Fichier(s) contexte');
  txt=strsubst(txt,'Context','Contexte');
  txt=strsubst(txt,'Scope Results','Résultats des oscilloscopes');
  txt=strsubst(txt,'Scope results','Résultats des oscilloscopes');
  txt=strsubst(txt,'Used blocks','Blocs utilisés');
  txt=strsubst(txt,'Simulation script(s)','Script(s) de simulation');
  txt=strsubst(txt,'Scicos diagram(s)','Diagramme(s) Scicos');
//   txt=strsubst(txt,'Scilab function','Fonction Scilab');
  txt=strsubst(txt,'Scilab functions','Fonctions Scilab');
  txt=strsubst(txt,'Package','Paquet');
  txt=strsubst(txt,'Library','Librairie');
  txt=strsubst(txt,'Calling Sequence','Séquence d''appel');
  txt=strsubst(txt,'Parameters','Paramètres');
  txt=strsubst(txt,'File content','Contenu du fichier');
  txt=strsubst(txt,'Used function(s)','Fonction(s) utilisée(s)');
  txt=strsubst(txt,'Used function','Fonction(s) utilisée(s)');
  txt=strsubst(txt,'Scicos Block','Bloc Scicos');
  txt=strsubst(txt,'Low level routine','Routine de calcul bas-niveau');
  txt=strsubst(txt,'Palettes','Palettes');
 end

endfunction