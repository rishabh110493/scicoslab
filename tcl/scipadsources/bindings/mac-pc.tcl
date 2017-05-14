#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2011 - Francois Vogel
#
#  Localization files ( in tcl/msg_files/) are copyright of the 
#  individual authors, listed in the header of each file
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# See the file scipad/license.txt
#

# mac (or, more recently, pc) style sbindings

#delete "native" text sbindings in the textarea -- we want all text
# manipulation to pass through our procs, so that e.g. colorization and
# edit while debug are correctly treated
sbind Text <Control-k> {}
sbind Text <Control-i> {}
sbind Text <Control-f> {} ; # avoids selection deletion on find box open
# remove the default sbind ctrl-d=delete char
sbind Text <Control-d> ""

# remove the default sbind ctrl-o=insert new line
sbind Text <Control-o> {}
sbind $pad <Control-o>     {showopenwin currenttile}
sbind $pad <Control-Key-4> {showopenwin horizontal}
sbind $pad <Control-Key-5> {showopenwin vertical}
sbind $pad <Control-Key-6> {opensourceof}

sbind Text <Control-z> {undo [gettextareacur]}
sbind Text <Control-Z> {redo [gettextareacur]}


sbind $pad <Control-f> {findtextdialog find}
sbind $pad <Control-r> {findtextdialog replace}
sbind $pad <F3>        {incsearchnext}
# binding for <Shift-F3> to proc incsearchprevious is done in commonbindings.tcl
# (it is a platform dependant binding)
sbind $pad <Control-F3>       {findnext}
sbind $pad <Control-Shift-F3> {reversefindnext}

sbind Text <Control-x> {cuttext normal}
sbind Text <Control-X> {cuttext block}
sbind $pad <Control-c> {copytext}
sbind Text <Control-v> {pastetext normal}
sbind Text <Control-V> {pastetext block}
sbind Text <Delete>    {deletetext}

sbind Text <Control-h> {backspacetext}
sbind Text <Control-t> {transposechars}

#cut-copy-paste for entries
sbind Entry <Control-x> [bind Entry <<Cut>>]
sbind Entry <Control-c> [bind Entry <<Copy>>]
sbind Entry <Control-v> [bind Entry <<Paste>>]

# erase the default <Control-a> binding of entry widgets and use it
# to select all the text, which is a usual behavior
sbind Entry <Control-a> [bind Entry <Control-/>]


sbind Text <Control-slash> ""
sbind $pad <Control-a> {selectall}


sbind $pad <Control-w> {closecurfile yesnocancel} 
sbind $pad <Control-W> {closeallreallyall} 

sbind $pad <Control-n> {filesetasnew}

sbind $pad <Control-q> {exitapp_yesnocancel}
sbind $pad <Alt-F4>    {exitapp_yesnocancel}

sbind $pad <Control-g> {gotoline}
sbind $pad <Control-p> {selectprint [gettextareacur]}
sbind $pad <Control-P> {printsetup}
sbind $pad <Control-s> {filetosavecur}
sbind $pad <Control-S> {filesaveascur}

sbind $pad <Control-m> {CommentSel}
sbind $pad <Control-M> {UnCommentSel}
sbind $pad <Control-Alt-m> {togglecomments}

sbind $pad <Control-l> {execfile}
sbind $pad <Control-L> {execallfiles}
sbind $pad <Control-Alt-l> {execfile_tocursor}
sbind $pad <Control-y> {execselection}

sbind $pad <Control-B> {showwhichfun}

sbind $pad <F5> {filetosavecur; execfile}
sbind $pad <F2> {filetosavecur}

sbind $pad <F1> {helpme}
sbind $pad <Control-F1> {helpword}

sbind $pad <Control-d> {IndentSel}
sbind $pad <Control-D> {UnIndentSel}

sbind $pad <Control-j> {tolowercase}
sbind $pad <Control-J> {touppercase}
sbind $pad <Control-Alt-j> {switchcase}
sbind $pad <Control-Alt-J> {capitalize}

sbind $pad <F6> {prevbuffer all}
sbind $pad <F7> {nextbuffer all}
sbind $pad <Control-F6> {prevbuffer visible}
sbind $pad <Control-F7> {nextbuffer visible}
sbind $pad <Shift-F6> {switchbuffersinpane "current" "backward"}
sbind $pad <Shift-F7> {switchbuffersinpane "current" "forward"}

sbind $pad <F4> {importmatlab}

sbind $pad <Control-R> {revertsaved [gettextareacur]}

sbind Text <Control-slash> {openlibfunsource [[gettextareacur] index insert]}

sbind $pad <Control-Key-1> {maximizebuffer}
sbind $pad <Control-Key-2> {splitwindow vertical "" tile}
sbind $pad <Control-Key-3> {splitwindow horizontal "" tile}
if {$Tk85} {
    sbind $pad <Control-Alt-Key-2> {splitwindow vertical "" file}
    sbind $pad <Control-Alt-Key-3> {splitwindow horizontal "" file}
}
