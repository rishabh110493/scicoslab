
function tt=get_gimp_cmd(name,rm_cmd)

  //verifie présence rm_cmd
  [lsh,rsh]=argn(0)
  if rsh<2 then
   rm_cmd="rm -fr ";
  end

tt1 = ["""# GIMP gimprc\\n"+..
      "#            \\n"+..
      "# This is your personal gimprc file.  Any variable defined in this file takes\\n"+..
      "# precedence over the value defined in the system-wide gimprc:\\n"+..
      "# /etc/gimp/2.0/gimprc"+..
      "# Most values can be set within The GIMP by changing some options in the\\n"+..
      "# Preferences dialog.\\n\\n"+..
      "(script-fu-path \""./\"")\\n\\n"+..
      "# end of gimprc\\n"""]

tt2= [""";; input parameter\\n"+..
      ";; filename : a string. This is the input filename.\\n"+..
      ";;                      For example \""toto.ps\"".\\n"+..
      ";; res : an int32. Give the desired input resolution.\\n"+..
      ";; pag : an int32. This is the page of the input file\\n"+..
      ";;                 that must be converted.\\n"+..
      ";; rot : an int32. Specify the rotation of the image.\\n\\n"+..
      ";; prototype\\n"+..
      "(define (script-fu-ps2eps filename res pag rot)\\n"+..
      ";; all is global\\n\\n"+..
      ";; set how load the ps file\\n"+..
      "(file-ps-load-setargs res 0 0 1 pag 4 2 4)\\n"+..
      ";; load input file\\n"+..
      "(set! img (car (file-ps-load 1 filename filename )))\\n"+..
      ";; get active layer\\n"+..
      "(set! layer (car  (gimp-image-get-active-layer img)))\\n"+..
      ";; crop the layer\\n"+..
      "(plug-in-autocrop 1 img layer)\\n"+..
      ";; extract base name file from filename\\n"+..
      "(set! basename (car (strbreakup filename \"".\"")))\\n"+..
      ";; save in eps format\\n"+..
      "(file-eps-save 1 img layer \\n"+..
      "          (string-append basename \"".eps\"")\\n"+..
      "          (string-append basename \"".eps\"")\\n"+..
      " 0 0 0 0 0 1 rot 1 0 2)\\n"+..
      "  )\\n\\n"+..
      "(script-fu-register \""script-fu-ps2eps\""\\n"+..
      "                   \""<Toolbox>/Xtns/Script-Fu/Utils/PsToEps...\""\\n"+..
      "\""PsToEps\""\\n"+..
      "\""Alan Layec\""\\n"+..
      "\""Alan Layec\""\\n"+..
      "\""Apr 2006\""\\n"+..
      "\""\""\\n"+..
      "SF-VALUE \""Image Name\"" \""\\\""\\\""\""\\n"+..
      "SF-VALUE \""res\"" \""400\""\\n"+..
      "SF-VALUE \""pag\"" \""\\\""1\\\""\""\\n"+..
      "SF-VALUE \""rot\"" \""0\"")\\n"""];

tt3=["gimp -c -d -i -g ""./gimprc"" -b """+..
     "(script-fu-ps2eps \"""+name+"\"" 400 \""1\"" 0)"""+...
     " ""(gimp-quit 0)"""];

tt4=[rm_cmd+"gimprc;"+rm_cmd+"ps2eps.scm"]

tt= ["echo -e "+tt1+">gimprc;echo -e "+tt2+">ps2eps.scm;"+tt3+";"+tt4]
endfunction