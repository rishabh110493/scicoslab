//  Scipad - programmer's editor and debugger for Scilab
//
//  Copyright (C) 2002 -      INRIA, Matthieu Philippe
//  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
//  Copyright (C) 2004-2011 - Francois Vogel
//
//  Localization files ( in tcl/msg_files/) are copyright of the
//  individual authors, listed in the header of each file
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// See the file scipad/license.txt
//

function dynamickeywords()
// Populate specific Tcl arrays with keywords that will be colorized
// by Scipad according to their type
// This is wrapped in a function to have all variables local

// Debug for bug 4053 - <TODO> can be removed later
TCL_EvalStr("set dynamickeywords_running true","scipad")

  function cset=lineform(keywordlist)
     keywordlist=gsort(keywordlist,"r","i")
     initial=gsort(unique(part(keywordlist,1)),"r","i")
     cset=[]
     for i=1:size(initial,1)
         cset(i)=strcat(keywordlist(part(keywordlist,1)==initial(i))," ")
     end
  endfunction


  function setscipadwords(wset,wtype)
    // checks that scipad interp exists (test added by the opteam 26/08/08, no idea why)
    if TCL_ExistInterp("scipad") then
      if or(wset=="") then
        warning(" empty name found of type "+wtype+" (BUG #3631)")
        wset=wset(wset<>"")
      end
      // check if bug 4317 is hit (i.e. what() outputs garbage)
      // The Tcl regexp engine is used for two reasons:
      //   1. the regular expression from Scipad is OK as is (as compared to
      //      the perl-like regexp engine embedded in Scilab 5)
      //   2. it is not needed to check for what Scilab environment this is
      //      running in (Scilab 4 or Scicoslab has no regexp engine)
      regexpresultarray = TCL_EvalStr("regexp -- {(?:[^\w%#!?$])} "+wset,"scipad")
      wrongchars = sum(evstr(regexpresultarray))
      if wrongchars<>0 then
        warning(" non-Scilab names found in type "+wtype+", maybe garbage (BUG #4317) - Scipad will not colorize the following:")
        mprintf("%s\n",wset(regexpresultarray<>"0"))
        wset=wset(regexpresultarray=="0")
      end
      lp=lineform(wset);
      TCL_EvalStr("set chset(scilab."+wtype+") {}","scipad")
      for i=1:size(lp,1)
        initial=part(lp(i),1);
        TCL_EvalStr("append chset(scilab."+wtype+") """+..
                     initial+"""","scipad")
        TCL_EvalStr("set words(scilab."+wtype+"."+initial+") """+..
                     lp(i)+"""","scipad")
      end
    else
      warning("TCL_ExistInterp(""scipad"") returned %F in function setscipadwords - This is not supposed to happen! Please report.");
    end
  endfunction

  // are we in a Scilab-4 code tree or in a Scilab-5 tree?
  if listfiles(SCI+"/modules/")<>[] then
    Scilab5=%t;
  else
    Scilab5=%f;
  end

  // commands and primitives
  [primitives,commands]=what();
  setscipadwords(commands,"command")
  setscipadwords(primitives,"intfun")

  // predefined variables
  names=who("get"); p=names(($-predef())+1:$);
  setscipadwords(p,"predef")

  // library functions
  libfun=[]; libvar=[];
  for i=1:size(names,1)
    if type(eval(names(i)))==14 then
      libvar=[libvar;names(i)];
      libstring=string(eval(names(i)));
      if or(libstring=="") then
        warning(" empty function name found in "+names(i)+" (BUG #2338)")
        libstring=libstring(libstring<>"")
      end
      libfun=[libfun;libstring(2:$)];
    end
  end

  setscipadwords(libfun,"libfun")

  // scicos functions
  if exists("scicos") then  // was once %scicos==%t -- which test is stabler?
    if Scilab5 then
      scicosdir=SCI+"/modules/scicos/macros/scicos_scicos";
      if listfiles(scicosdir+"/lib")<>[] then
        // scicos basic functions: read the lib
        [l,s,b]=listvarinfile(scicosdir+"/lib");
        load(scicosdir+"/lib");
        scicoslibfound=%t;
      else
        // might happen some day: future of Scicos in Scilab 5
        // is uncertain, especially its directory structure
        scicoslibfound=%f;
      end
    else
      scicosdir=SCI+"/macros/";
      if listfiles(scicosdir+"scicos/lib")<>[] then
        // scicos basic functions: read the lib
        [l,s,b]=listvarinfile(scicosdir+"scicos/lib");
        load(scicosdir+"scicos/lib");
        scicoslibfound=%t;
      else
        // might happen some day, even in Scilab 4, you never know...
        scicoslibfound=%f;
      end
    end

    if scicoslibfound then
      // scicos basic functions: read the lib
      n=string(eval(l)); scicosfun=(n(2:$));
      execstr("clear "+l);
    else
      scicosfun=[];
      warning(" File "+scicosdir+"/lib cannot be found - Scipad will not colorize the names from the Scicos library")
    end

    // scicos palettes: read each lib
    scicosblocks=[];
    if Scilab5 then
      scicos_blocksdir = SCI+"/modules/scicos_blocks/macros";
      subdirs=listfiles(scicos_blocksdir);
      for i=1:size(subdirs,"r")
        blocklib=scicos_blocksdir+"/"+subdirs(i)+"/lib";
        if fileinfo(blocklib)<>[] then
          [l,s,b]=listvarinfile(blocklib);
          load(blocklib);
          n=string(eval(l)); scicosblocks=[scicosblocks;(n(2:$))];
          execstr("clear "+l);
        end
      end
    else
      subdirs=listfiles(scicosdir+"/scicos_blocks");
        for i=1:size(subdirs,"r")
          blocklib=scicosdir+"/scicos_blocks/"+subdirs(i)+"/lib";
          if fileinfo(blocklib)<>[] then
            [l,s,b]=listvarinfile(blocklib);
            load(blocklib);
            n=string(eval(l)); scicosblocks=[scicosblocks;(n(2:$))];
            execstr("clear "+l);
          end
      end
    end

    setscipadwords([scicosfun;scicosblocks],"scicos")
  end

  // TCL_EvalStr("tk_messageBox -message $words(scilab.predef.%)","scipad")

// Debug for bug 4053 - <TODO> can be removed later
TCL_EvalStr("set dynamickeywords_running false","scipad")
TCL_EvalStr("set dynamickeywords_ran_once true","scipad")

endfunction

dynamickeywords()

clear dynamickeywords
