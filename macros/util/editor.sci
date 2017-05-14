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

function editor(filepaths,linenums,funnames)

  if ~with_tk() then
    error("Editor works only with Tcl/Tk.")
  end

  [lhs,rhs]=argn()

  if rhs == 0 then
    // simply open Scipad
    scipad()
  end

  if rhs == 1 then
    // open the given filepaths in Scipad
    scipad(filepaths)
  end

  if rhs > 3 then
    error("editor: too many input arguments")
  end

  if rhs >= 2 then

    if type(linenums) <> 1 then
        error("editor: line numbers argument must be numbers")
    elseif and(~isreal(linenums)) then
        error("editor: line numbers argument must be real numbers")
    end
    if size(filepaths,"*") <> size(linenums,"*") then
        error("editor: incompatible size of input arguments (filepaths, linenums)")
    end

    if rhs == 2 then
      // open the given filepaths at the given physical line numbers in these files
      for i = 1:size(filepaths,"*")
        scipad(filepaths(i))
        TCL_EvalStr("dogotoline physical "+msprintf("%d",linenums(i))+" current_file {}","scipad");
      end
    else
      // rhs is necessarily 3

      if type(funnames) <> 10 then
        error("editor: function names argument must be a matrix of strings")
      end
      if size(filepaths,"*") <> size(funnames,"*") then
        error("editor: incompatible size of input arguments (filepaths, funnames)")
      end

      // open the given filepaths at the given logical line numbers in these files,
      // relative to the given macro (function) names
      for i = 1:size(filepaths,"*")
        scipad(filepaths(i))
        funids = TCL_EvalStr("getlistoffunidsincurrenttextarea","scipad")
        if funids == "" then
            found = %f
        else
          funids = stripblanks(strsplit(funids,strindex(funids," ")))
          nbfunsinta = size(funids,"*")/3
          found = %f
          for j = 1:nbfunsinta
            if funids((j-1)*3+1) == funnames(i) then
              found = %t
              tatogo = funids((j-1)*3+2)
              funstart = funids((j-1)*3+3)
              break
            end
          end
        end
        if found then
          TCL_EvalStr("dogotoline logical "+msprintf("%d",linenums(i))+" {} [list "+funnames(i)+" "+tatogo+" "+funstart+"]","scipad");
        else
          warning("function "+funnames(i)+" not found in file "+filepaths(i))
          TCL_EvalStr("dogotoline physical "+msprintf("%d",linenums(i))+" current_file {}","scipad");
        end
      end
    end
  end

endfunction
