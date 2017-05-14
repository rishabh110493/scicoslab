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

##################################################
# procs for brand new buffers
##################################################
proc filesetasnew {{checkforrestorelayoutrunning "checkit"}} {
    global winopened listoffile
    global listoftextarea pad
    global defaultencoding
    global closeinitialbufferallowed
    global restorelayoutrunning

    if {$checkforrestorelayoutrunning ne "NoRestoreLayoutRunningCheck"} {
        if {$restorelayoutrunning} {
            return
        }
    }

    # ensure that the cursor is changed to the default cursor
    event generate [gettextareacur] <Leave>

    incr winopened
    set ta $pad.new$winopened
    dupWidgetOption [gettextareacur] $ta
    set listoffile("$ta",fullname) [mc "Untitled"]$winopened.sce
    set listoffile("$ta",displayedname) [mc "Untitled"]$winopened.sce
    set listoffile("$ta",new) 1
    set listoffile("$ta",thetime) 0
    set listoffile("$ta",disksize) 0
    set listoffile("$ta",language) "scilab"
    setlistoffile_colorize $ta ""
    set listoffile("$ta",readonly) 0
    set listoffile("$ta",binary) 0
    set listoffile("$ta",undostackdepth) 0
    set listoffile("$ta",redostackdepth) 0
    set listoffile("$ta",undostackmodifiedlinetags) [list ]
    set listoffile("$ta",redostackmodifiedlinetags) [list ]
    set listoffile("$ta",progressbar_id) ""
    set listoffile("$ta",encoding) $defaultencoding
    set listoffile("$ta",eolchar) [platformeolchar]
    lappend listoftextarea $ta

    addwindowsmenuentry $winopened $listoffile("$ta",displayedname)
    RefreshWindowsMenuLabelsWrtPruning

    newfilebind
    showinfo [mc "New script"]
    if {$closeinitialbufferallowed} {
        set closeinitialbufferallowed false
        byebyeta $pad.new1 opennewemptyfile
    }
    showtext $ta
    resetmodified $ta "clearundoredostacks"
}
