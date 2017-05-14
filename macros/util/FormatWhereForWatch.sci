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

function txt = FormatWhereForWatch(startitem)
// Converts input information (provided by where()) into a single string that
// mimics the output of whereami()
// This is used for the watch window of the debugger in Scipad.
// The callstackfuns and callstacklines lists are also set inside the scipad
// interpreter by this function for later use during step by step, run to
// cursor, or to open a stack level by double-clicking in the call stack area
// note that $callstacklines contains:
//   logical line numbers in Scilab-4.1.2, Scilab-Gtk-4.2, Scicoslab-4.3
//   physical line numbers in Scilab-5, Scicoslab-4.x (x>3)
// however txt (i.e. the returned text) will always display logical line
// numbers, unless the function corresponding to one of the call stack cannot
// be found among the opened buffers, in which case the physical line number
// will be displayed and will be tagged with "(physical)"
// Author: Francois Vogel, 2004-2011 (freely inspired from whereami())

// Localisation
str0=LocalizeForScipad("Breakpoint");
str1=LocalizeForScipad("called at line");
str2=LocalizeForScipad("of exec file");
str3=LocalizeForScipad("of execstr instruction");
str4=LocalizeForScipad("called under pause");
str5=LocalizeForScipad("of macro");
str6=LocalizeForScipad("physical");

[linn,mac] = where()
nn  = prod(size(linn))
lm  = maxi(maxi(length(mac(2:$))),length(str0))
txt = emptystr()

// Create a Tcl list containing the calling stack functions list
macstring = strcat(mac(startitem+1:nn-1)," ")
macstring = strsubst(macstring,"$","\$")
TCL_SetVar("callstackfuns",macstring,"scipad")

// Create a Tcl list containing the calling stack line numbers list
if startitem+1 <= nn-1 then
    linnstring = msprintf("%d ",linn(startitem+1:nn-1))
else
    linnstring = ""
end
// depending on the underlying Scilab environment, $callstacklines
// receives logical or physical line numbers
TCL_SetVar("callstacklines",linnstring,"scipad")

// get the type of line numbers displayed in the margin
linenumtyp = TCL_GetVar("linenumberstype","scipad")

// Properly format the call stack and line numbers in a single string
// that will be displayed in the call stack area of the watch window
for k = 2:nn-1    // The first item is omitted since it is always "FormatWhereForWatch"
                  // The last item is omitted since it is the execstr from the ScilabEval "foo_to_debug()"
    if mac(k)=='exec' then
        txt = txt + part(mac(k-1),1:lm) + " " + str1 + " " + msprintf("%d",linn(k)) + " " + str2 + "\n"
    elseif mac(k)=='execstr' then
        txt = txt + part(mac(k-1),1:lm) + " " + str1 + " " + msprintf("%d",linn(k)) + " " + str3 + "\n"
    elseif mac(k)=='pause' then
        txt = txt + part(mac(k-1),1:lm) + " " + str4 + "\n"
    else
        if linenumtyp == "logical" then
            linenumstr = TCL_EvalStr("condphyslinetologline "+mac(k)+" "+msprintf("%d",linn(k)),"scipad")
        else
            linenumstr = msprintf("%d",linn(k))
        end
        if evstr(linenumstr) < 0 then
          // negative line number encodes a physical line number in a function that could not be found
          // among the opened buffers, therefore the corresponding logical line number is not available
          linenumstr = msprintf("%d",-evstr(linenumstr)) + " (" + str6 + ")"
        end
        txt = txt + part(mac(k-1),1:lm) + " " + str1 + " " + linenumstr + " " + str5 + " " + mac(k) + "\n"
    end
end

// Remove the first startitem-1 lines (not relevant since they list the stack content
// for the pause level(s) at the breakpoint)
pos = strindex(txt,"\n")
if pos ~= [] then
    if size(pos,'c') > 1 then
        txt = part(txt,pos(startitem-1)+2:length(txt))
        txt = str0 + part(txt,length(str0)+1:length(txt))
    else
        txt = emptystr();
    end
end

// Special case : the dollar sign must be escaped otherwise what follows is
// interpreted as a Tcl variable
// A dollar can be found in txt when debugging a function whose name starts
// with $
txt = strsubst(txt,"$","\$")

endfunction
