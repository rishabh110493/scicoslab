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

proc gettgactionsiconsdirtouse {} {
# return the directory in which the small or large tango icons
# are stored, as a function of the corresponding preference

    global maintoolbarsmalliconsflag
    global tgactionssmalliconsdir tgactionslargeiconsdir

    if {$maintoolbarsmalliconsflag} {
        set tgactionsiconsdirtouse $tgactionssmalliconsdir
    } else {
        set tgactionsiconsdirtouse $tgactionslargeiconsdir
    }
    return $tgactionsiconsdirtouse
}

proc createmaintoolbar {} {
# construct the main toolbar of Scipad

    global pad MenuEntryId
    global maintoolbarframe maintoolbarframe_tb1
    global maintoolbarframe_tb1_buttonnames
    global textFont maxcharinascilabname

    set tgactionsiconsdirtouse [gettgactionsiconsdirtouse]
    image create photo icon_document_new         -file [file join $tgactionsiconsdirtouse "document-new.gif"]
    image create photo icon_document_open        -file [file join $tgactionsiconsdirtouse "document-open.gif"]
    image create photo icon_document_save        -file [file join $tgactionsiconsdirtouse "document-save.gif"]
    image create photo icon_edit_cut             -file [file join $tgactionsiconsdirtouse "edit-cut.gif"]
    image create photo icon_edit_copy            -file [file join $tgactionsiconsdirtouse "edit-copy.gif"]
    image create photo icon_edit_paste           -file [file join $tgactionsiconsdirtouse "edit-paste.gif"]
    image create photo icon_edit_undo            -file [file join $tgactionsiconsdirtouse "edit-undo.gif"]
    image create photo icon_edit_redo            -file [file join $tgactionsiconsdirtouse "edit-redo.gif"]
    image create photo icon_edit_find            -file [file join $tgactionsiconsdirtouse "edit-find.gif"]
    image create photo icon_edit_find_replace    -file [file join $tgactionsiconsdirtouse "edit-find-replace.gif"]
    image create photo icon_format_indent_less   -file [file join $tgactionsiconsdirtouse "format-indent-less.gif"]
    image create photo icon_format_indent_more   -file [file join $tgactionsiconsdirtouse "format-indent-more.gif"]
    image create photo icon_load_into_scilab     -file [file join $tgactionsiconsdirtouse "media-playback-start.gif"]
    image create photo icon_load_all_into_scilab -file [file join $tgactionsiconsdirtouse "media-seek-forward.gif"]

    # toolbar frame, which is the global container of the thing
    # the orientation and packing side of the tollbar frame is
    # not saved in the preferences file, thus always set it horizontal
    set maintoolbarframe [::toolbar::ToolbarFrame $pad.toolbarFrame -orientation horizontal]

    # a first (and currently unique) toolbar in this toolbar frame
    # it receives -hide false because:
    #   - I didn't find how to make it visible again once hidden
    #     through the popup menu on right click on the toolbar handle!
    #   - the toolbar is supposed to be hidden through the Options menu
    # however it can float around, and this is triggered by right click
    # on the toolbar handle
    # the floating toolbar can the be docked again by moving it above the
    # toolbar frame
    set maintoolbarframe_tb1 [::toolbar::create $maintoolbarframe.tb1 -hide false -float true]

    # add buttons/widgets in this toolbar

    set lab [mcra "&New"]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_document_new \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.files entrycget $MenuEntryId($pad.filemenu.files.$lab) -command]

    set lab [mcra "&Open..."]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_document_open \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.files entrycget $MenuEntryId($pad.filemenu.files.$lab) -command]

    set lab [mcra "&Save"]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_document_save \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.files entrycget $MenuEntryId($pad.filemenu.files.$lab) -command]

    ::toolbar::addseparator $maintoolbarframe_tb1

    set lab [mcra "Cu&t"]
    set tb1_cut_butname [ \
        ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_edit_cut \
                -tooltip $lab -statuswidget $pad.statusmes \
                -command [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.$lab) -command] \
    ]
    set maintoolbarframe_tb1_buttonnames(tb1_cut_butname) $tb1_cut_butname

    set lab [mcra "&Copy"]
    set tb1_copy_butname [ \
        ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_edit_copy \
                -tooltip $lab -statuswidget $pad.statusmes \
                -command [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.$lab) -command] \
    ]
    set maintoolbarframe_tb1_buttonnames(tb1_copy_butname) $tb1_copy_butname

    set lab [mcra "&Paste"]
    set tb1_paste_butname [ \
        ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_edit_paste \
                -tooltip $lab -statuswidget $pad.statusmes \
                -command [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.$lab) -command] \
    ]
    set maintoolbarframe_tb1_buttonnames(tb1_paste_butname) $tb1_paste_butname

    set lab [mcra "&Undo"]
    set tb1_undo_butname [ \
        ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_edit_undo \
                -tooltip $lab -statuswidget $pad.statusmes \
                -command [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.$lab) -command] \
    ]
    set maintoolbarframe_tb1_buttonnames(tb1_undo_butname) $tb1_undo_butname

    set lab [mcra "&Redo"]
    set tb1_redo_butname [ \
        ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_edit_redo \
                -tooltip $lab -statuswidget $pad.statusmes \
                -command [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.$lab) -command] \
    ]
    set maintoolbarframe_tb1_buttonnames(tb1_redo_butname) $tb1_redo_butname

    ::toolbar::addseparator $maintoolbarframe_tb1

    set lab [mcra "&Find..."]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_edit_find \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.search entrycget $MenuEntryId($pad.filemenu.search.$lab) -command]

    set lab [mcra "&Replace..."]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_edit_find_replace \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.search entrycget $MenuEntryId($pad.filemenu.search.$lab) -command]

    ::toolbar::addseparator $maintoolbarframe_tb1

    set lab [mcra "Unin&dent selection"]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_format_indent_less \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.$lab) -command]

    set lab [mcra "&Indent selection"]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_format_indent_more \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.$lab) -command]

    ::toolbar::addseparator $maintoolbarframe_tb1

    set lab [mcra "&Load into Scilab"]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_load_into_scilab \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.exec entrycget $MenuEntryId($pad.filemenu.exec.$lab) -command]

    set lab [mcra "Load &all into Scilab"]
    ::toolbar::addbutton $maintoolbarframe_tb1 -image icon_load_all_into_scilab \
            -tooltip $lab -statuswidget $pad.statusmes \
            -command [$pad.filemenu.exec entrycget $MenuEntryId($pad.filemenu.exec.$lab) -command]

    ::toolbar::addseparator $maintoolbarframe_tb1 -showifv false

    # -listvar is needed here because one uses proc setcombolistboxwidthtolargestcontent
    # on this combobox, which calls getcombolistvarcontent, which uses the -listvar content
    set cw [ \
        ::toolbar::addwidget $maintoolbarframe_tb1 combobox -font $textFont \
          -width $maxcharinascilabname -editable false -listvar formattedlistofallfunnamesinallbuffers \
          -textvariable funnamewhereinsertcursoris -command "invoketoolbarfunnamecombo" \
          -tooltip [mc "Click on a function name jumps there"] -statuswidget $pad.statusmes \
          -showifv false \
    ]
    $cw configure -opencommand "updatefunnameslistboxintoolbar $cw"

    # pack the toolbar inside the toolbar frame
    pack $maintoolbarframe_tb1 -side left -fill y

    # pack the toolbar frame in the main window
    pack $maintoolbarframe -side top -fill x -before $pad.pw0

    # show the toolbar if it must be visible (depending on the saved
    # preference flag), or hide it otherwise
    toggletoolbarvisible

    contextactivatetoolbarbuttons
}

proc toggletoolbarvisible {} {
    global maintoolbarvisibleflag maintoolbarframe_tb1
    if {$maintoolbarvisibleflag} {
        # show the toolbar
        ::toolbar::deiconify $maintoolbarframe_tb1
    } else {
        # hide the toolbar
        # but first don't forget to remove the possibly floating thing
        # (catched to avoid testing if it is floating)
        catch {event generate $maintoolbarframe_tb1.fltWin <Destroy>}
        ::toolbar::HandleCallback $maintoolbarframe_tb1 -2
    }
}

proc redrawmaintoolbar {} {
    global maintoolbarframe
    destroy $maintoolbarframe
    createmaintoolbar
}

proc contextactivatetoolbarbuttons {} {
# contextually enable or disable each item of the main toolbar
# the enable status of the menu entry is copied to the status
# of the corresponding button in the main toolbar, which avoids
# testing again a lot of flags for Scipad state (this is done
# in proc dokeyposn, which should therefore obviously be called
# before the present proc)

    global pad MenuEntryId maintoolbarframe_tb1
    global maintoolbarframe_tb1_buttonnames

    if {[winfo exists $maintoolbarframe_tb1.fltWin]} {
        # floating toolbar
        # $maintoolbarframe_tb1_buttonnames is an array of names
        # such as     .scipad.toolbarFrame.tb1.widgets.3
        # the name of the corresponding button in the floating
        # toolbar is  .scipad.toolbarFrame.tb1.fltWin.3
        # this is a strong assumtion on the toolbar package,
        # but how to do otherwise?
        foreach butname [array names maintoolbarframe_tb1_buttonnames] {
            set buttonnames($butname) [string map {widgets fltWin} $maintoolbarframe_tb1_buttonnames($butname)]
        }
    } else {
        # docked toolbar
        # $maintoolbarframe_tb1_buttonnames already contains the right names
        array set buttonnames [array get maintoolbarframe_tb1_buttonnames]
    }

    # Undo/Redo
    set stat [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.[mcra "&Undo"]) -state]
    $buttonnames(tb1_undo_butname) configure -state $stat
    set stat [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.[mcra "&Redo"]) -state]
    $buttonnames(tb1_redo_butname) configure -state $stat

    # Cut/Copy/Paste
    set stat [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.[mcra "Cu&t"]) -state]
    $buttonnames(tb1_cut_butname) configure -state $stat
    set stat [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.[mcra "&Copy"]) -state]
    $buttonnames(tb1_copy_butname) configure -state $stat
    set stat [$pad.filemenu.edit entrycget $MenuEntryId($pad.filemenu.edit.[mcra "&Paste"]) -state]
    $buttonnames(tb1_paste_butname) configure -state $stat
}

proc updatefunnameslistboxintoolbar {comboname} {
# populate the listbox of the combobox showing the function names
# that can be jumped to

    global maintoolbarframe_tb1

    # establish the formatted list of entries normally going in the
    # -listvar variable of the combobox
    set thelist [list ]
    set funidslist [getlistofallfunidsinalltextareas]
    set allfunnames [getallfunnamesfromalltextareas]
    foreach {funname ta funstartline} $funidslist {
        lappend thelist [stringifyfunid [list $funname $ta $funstartline] $allfunnames]
    }
    set thelist [lsort -dictionary -increasing $thelist]

    if {[winfo exists $maintoolbarframe_tb1.fltWin]} {
        # floating toolbar
        set coname [string map {widgets fltWin} $comboname]
    } else {
        # docked toolbar
        set coname $comboname
    }

    # populate the dropdown listbox of the combobox
    # normally this should be done by a simple:
    #    global formattedlistofallfunnamesinallbuffers
    #    set formattedlistofallfunnamesinallbuffers $thelist
    # but due to a bug (see comments at the top of combobox.tcl)
    # the elements have to be inserted one by one in the listbox,
    # otherwise the possibly needed scrollbar would be missing
    $coname list delete 0 end
    foreach elt $thelist {
        $coname list insert end $elt
    }

    setcombolistboxwidthtolargestcontent $coname
}

proc invoketoolbarfunnamecombo {w selecteditem} {
# this proc is executed whenever the user clicks on a function name
# in the listbox of the combobox from the main toolbar
# $w is the name of the combobox (useless but passed by the combobox
# package)

    if {$selecteditem eq ""} {
        return
    }

    set funtogoto [parsefunidstring $selecteditem]
    dogotoline "physical" 1 "function" $funtogoto

    # in the combobox entry area one wants just the function name
    # to be displayed, not the full length disambiguation stuff
    # (filename, line number)
    # there is no need to do it here since dokeyposn already does
}
