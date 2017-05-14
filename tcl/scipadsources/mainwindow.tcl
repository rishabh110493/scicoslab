#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2015 - Francois Vogel
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

toplevel $pad
wm withdraw $pad ; # $pad will be deiconified after Scipad's startup is completely over
setscipadicon $pad

set winopened 1
set textareaid $winopened
settextareacur $pad.new$winopened

set ta [gettextareacur]
set listoftextarea [list $ta]

set listoffile("$ta",fullname)       "[mc "Untitled"]$winopened.sce"
set listoffile("$ta",displayedname)  "[mc "Untitled"]$winopened.sce"
set listoffile("$ta",new)            1; # is not an opened file from disk
set listoffile("$ta",thetime)        0; # set the time of the last modify
set listoffile("$ta",disksize)       0; # set the size of the file on disk
set listoffile("$ta",readonly)       0; # file can be written
set listoffile("$ta",binary)         0; # file is text (not binary)
set listoffile("$ta",language)       "scilab"; 
setlistoffile_colorize "$ta"         ""; 
set listoffile("$ta",undostackdepth) 0; # used to enable/disable the undo menu entry
set listoffile("$ta",redostackdepth) 0; # used to enable/disable the redo menu entry
set listoffile("$ta",undostackmodifiedlinetags) [list ]
set listoffile("$ta",redostackmodifiedlinetags) [list ]
set listoffile("$ta",progressbar_id) ""; # colorization progressbar identifier
set listoffile("$ta",encoding)       $defaultencoding
set listoffile("$ta",eolchar)        [platformeolchar]

array unset chset  ; # see description of this array at the top of colorize.tcl
array unset words  ; # see description of this array at the top of colorize.tcl

# main window settings
eval destroy [winfo children $pad]
wm iconname $pad $applicationname

# catch the kill from the window manager
wm protocol $pad WM_DELETE_WINDOW {exitapp_yesnocancel}

wm minsize $pad 1 1 

# create main menu
menu $pad.filemenu -tearoff 0
$pad.filemenu configure -font $menuFont

# main paned window
panedwindow $pad.pw0 -orient vertical -opaqueresize true
set pwmaxid 0

# creates the default textarea
# -width 1 and -height 1 ensure that the scrollbars show up
# whatever the size of the textarea
text [gettextareacur] -relief sunken -bd 0 \
    -wrap $wordWrap -width 1 -height 1\
    -fg $FGCOLOR -bg $BGCOLOR  -setgrid 0 -font $textFont \
    -insertwidth $textinsertcursorwidth \
    -insertborderwidth $textinsertcursorborderwidth \
    -insertbackground $CURCOLOR \
    -selectbackground $SELCOLOR -exportselection 1 \
    -undo 1 -autoseparators 1
if {$cursorblink} {
    [gettextareacur] configure -insertofftime 500 -insertontime 500
} else {
    [gettextareacur] configure -insertofftime 0
}

# this is for the status bar at the bottom of the main window
frame $pad.bottom
pack $pad.bottom -side bottom -expand 0 -fill both

set colormen [$pad.filemenu cget -background]

# status indicator
label $pad.statusind -relief groove -state disabled -background $colormen \
   -width 20
# status message
label $pad.statusmes -relief groove -state disabled -background $colormen \
    -width 30
# second status indicator to display the line number in functions
label $pad.statusind2 -relief groove -state disabled -background $colormen \
    -width 24 -anchor w
pack $pad.statusind2 $pad.statusind -in $pad.bottom -side right\
    -expand 0
pack $pad.statusmes -in $pad.bottom -side bottom -expand 0 -fill x

# packing of the bottom line with status info *must* be done before packing
# anything in the panedwindow otherwise the status area can get clipped on
# window resize
packnewbuffer [gettextareacur] $pad.pw0 0

# from now on, keep checking the availability of the scilab prompt 
displaybusystate

# the following update makes the initial textarea reactive to dnd!
update

# Drag and drop feature using TkDnD
tkdndbind [gettextareacur]

# the main toolbar is created after the menues are populated, because
# the toolbar creation process needs the content of the menu in order
# to avoid duplication of information in the code
