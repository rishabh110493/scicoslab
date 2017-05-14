//fonction qui change des titres donn�s dans
//un vecteur de cha�nes de caract�res
//suivant le param�tre lang
//entr�e : lang : 'fr' pour du francais
//         title : vecteurs de chaines de carat�res
function txt=change_lang_title(lg,ttitle)
 txt=ttitle

 if lg=='fr' then
  txt=strsubst(txt,'Theorical background','Rappel th�orique');
  txt=strsubst(txt,'Technical background','Rappel technique');
  txt=strsubst(txt,'Algorithm','Algorithmes');
  txt=strsubst(txt,'Basic blocks equivalent model','Mod�le �quivalent en blocs de base');
  txt=strsubst(txt,'Scilab script/function equivalent Model','Script/fonction scilab �quivalente');
  txt=strsubst(txt,'Dialog box','Bo�te de dialogue');
  txt=strsubst(txt,'Example','Exemple');
  txt=strsubst(txt,'Default properties','Propri�t�s par d�faut');
  txt=strsubst(txt,'Interfacing function','Fonction d''interface');
  txt=strsubst(txt,'Compiled Super Block content','Contenu du super-bloc compil�');
  txt=strsubst(txt,'Modelica model','Mod�le Modelica');
  txt=strsubst(txt,'Computational function','Fonction de calcul');
  txt=strsubst(txt,'Used functions','Fonction utilis�e');
  txt=strsubst(txt,'See also','Voir aussi');
  txt=strsubst(txt,'See Also','Voir aussi');
  txt=strsubst(txt,'Authors','Auteurs');
  txt=strsubst(txt,'Bibliography','Bibliographie');
  txt=strsubst(txt,'Blocks','Blocs');
  txt=strsubst(txt,'Context file(s)','Fichier(s) contexte');
  txt=strsubst(txt,'Context','Contexte');
  txt=strsubst(txt,'Scope Results','R�sultats des oscilloscopes');
  txt=strsubst(txt,'Scope results','R�sultats des oscilloscopes');
  txt=strsubst(txt,'Used blocks','Blocs utilis�s');
  txt=strsubst(txt,'Simulation script(s)','Script(s) de simulation');
  txt=strsubst(txt,'Scicos diagram(s)','Diagramme(s) Scicos');
//   txt=strsubst(txt,'Scilab function','Fonction Scilab');
  txt=strsubst(txt,'Scilab functions','Fonctions Scilab');
  txt=strsubst(txt,'Package','Paquet');
  txt=strsubst(txt,'Library','Librairie');
  txt=strsubst(txt,'Calling Sequence','S�quence d''appel');
  txt=strsubst(txt,'Parameters','Param�tres');
  txt=strsubst(txt,'File content','Contenu du fichier');
  txt=strsubst(txt,'Used function(s)','Fonction(s) utilis�e(s)');
  txt=strsubst(txt,'Used function','Fonction(s) utilis�e(s)');
  txt=strsubst(txt,'Scicos Block','Bloc Scicos');
  txt=strsubst(txt,'Low level routine','Routine de calcul bas-niveau');
  txt=strsubst(txt,'Palettes','Palettes');
 end

endfunction