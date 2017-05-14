#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2014 - Francois Vogel
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
# procs closing textareas and files
##################################################
#
# High level architecture of the closing procs:
#
#   closeallreallyall
#   closeallbutcurrentfilekeeppeers
#   closeallbutcurrentfileclosepeers
#   closeallviewsofcurrenttabutcurrentview
#   closeallhiddenta
#   crossclosefile
#   closecurfile
#       |->    closelistofta
#                   |->     filetosave
#                   |->     closecurta
#
#   buttonclosetile
#   closecurtile
#       |->    closecurta
#   
#   closecurta
#       |->    byebyeta_askconfirmation
#                          |->            asksaveconfirm
#                          |->            filetosave
#                          |->            byebyeta

proc closeallreallyall {} {
# close absolutely all files
# the flag instructing Scipad to exit when last file gets closed is ignored,
# as a consequence at the end of this proc all files were closed and a new
# empty buffer was opened upon last file closure

    global listoftextarea exitwhenlastclosed

    set listoftatocheckforsaving $listoftextarea
    set listoftatoclose $listoftextarea

    set listoftatosave [getuseranswerstoasksaveconfirm $listoftatocheckforsaving yesnocancel]

    if {$listoftatosave eq "UserHitCancel"} {
        # the user clicked cancel during the questions asking
        # about saving the modified textareas
        # --> don't save or close anything
        return "aborted"

    } else {
        # close all ta, save those asked by the user
        # in the process, ignore the flag instructing Scipad to exit when last file gets closed
        set exitwhenlastclosed_saved $exitwhenlastclosed
        set exitwhenlastclosed false
        closelistofta $listoftatoclose $listoftatosave
        set exitwhenlastclosed $exitwhenlastclosed_saved
        return "allwereclosed"
    }
}

proc closeallbutcurrentfilekeeppeers {} {
# close all files but the current one, i.e. the file whose textarea
# has the focus - the peers of this textarea are not closed

    set curta [gettextareacur]

    set listoftatoclose [getlistoftanotcontainingfileshowninta $curta]

    # the list of textareas for which the user must be asked for saving
    # is exactly the list of textareas to close because $curta and its
    # peers are kept open
    set listoftatosave [getuseranswerstoasksaveconfirm $listoftatoclose yesnocancel]

    if {$listoftatosave eq "UserHitCancel"} {
        # the user clicked cancel during the questions asking
        # about saving the modified textareas
        # --> don't save or close anything
        return

    } else {
        # close all ta but those containing the current file and keep peers,
        # save those asked by the user
        closelistofta $listoftatoclose $listoftatosave
    }

    # ensure that the initially selected textarea keeps the focus, which
    # may not be automatically the case when this textarea has peers (which
    # are not closed by this proc)
    # note that $curta is always still available because all files NOT
    # displayed in the current textarea (or its peers) are closed
    showtext $curta
}

proc closeallbutcurrentfileclosepeers {} {
# close all files but the current one, i.e. the file whose textarea
# has the focus - the peers of this textarea are closed

    set curta [gettextareacur]

    # get the list of textareas containing any file but the current file
    # (which is identified from the current textarea)
    set listoftatoclose [getlistoftanotcontainingfileshowninta $curta]

    # since the current file will not be closed, the textarea list for which
    # the user must be asked for saving must not contain $curta or any
    # of its peers, thus it's just the value that listoftatoclose has NOW
    set listoftatocheckforsaving $listoftatoclose

    # and NOW complete the list of textareas we want to close by adding
    # the peers of the current textarea (these ones will not be asked
    # for saving, which is intentional since we retain $curta, thus no
    # loss of data)
    foreach peerta [getpeerlist $curta] {
        lappend listoftatoclose $peerta
    }

    set listoftatosave [getuseranswerstoasksaveconfirm $listoftatocheckforsaving yesnocancel]

    if {$listoftatosave eq "UserHitCancel"} {
        # the user clicked cancel during the questions asking
        # about saving the modified textareas
        # --> don't save or close anything
        return

    } else {
        # close all ta but those containing the current file and keep peers,
        # save those asked by the user
        closelistofta $listoftatoclose $listoftatosave
    }

    # ensure that the initially selected textarea keeps the focus, which
    # may not be automatically the case when this textarea has peers (which
    # are not closed by this proc)
    # note that $curta is always still available because all files NOT
    # displayed in the current textarea (or its peers) are closed
    showtext $curta
}

proc closeallviewsofcurrenttabutcurrentview {} {
# close all peers of the current textarea
# this proc does not ask any question about saving because a peer
# (which is $curta) will always be kept open, thus no loss of data

    set curta [gettextareacur]

    closelistofta [getpeerlist $curta] {}

    # ensure that the initially selected peer textarea keeps the focus, which
    # is usually not automatically the case if there are other files opened
    showtext $curta
}

proc closeallhiddenta {} {
# close all hidden textareas, after having asked for confirmation
# from the user when this would close a file (i.e. close all textareas
# that display a given file)

    set curta [gettextareacur]

    set listoftatoclose [getlistofhiddenta]

    # the list of textareas to check for saving is not the full $listoftatoclose
    # but only a subset (the list of textareas that do not have a visible peer, i.e.
    # the list of textareas containing hidden files (in the sense: a file is hidden
    # if and only if all textareas containing it are hidden)
    # this is therefore the list of textareas $ta for which all textareas from
    # [getfullpeerset $ta] have [isdisplayed] == false)
    set listoftatocheckforsaving [getlistoftacontaininghiddenfiles]

    set listoftatosave [getuseranswerstoasksaveconfirm $listoftatocheckforsaving yesnocancel]

    if {$listoftatosave eq "UserHitCancel"} {
        # the user clicked cancel during the questions asking
        # about saving the modified textareas
        # --> don't save or close anything
        return

    } else {
        # close all hidden ta, save those asked by the user
        closelistofta $listoftatoclose $listoftatosave
    }

    # ensure that the initially selected peer textarea keeps the focus, which
    # is usually not automatically the case if there are other files opened
    # note that $curta is always a visible textarea, therefore it must still
    # be available after the closures above
    showtext $curta
}

proc crossclosefile {ta} {
# called when closing a file by clicking on the little cross at the right
# $ta is the textarea displaying the file
    global restorelayoutrunning
    if {$restorelayoutrunning} {return}
    focustextarea $ta
    closecurfile yesnocancel
}

proc closecurfile {quittype} {
# close current file, i.e. close the current textarea and also
# all its peers
# confirmation for saving is asked only once (of course, the information
# in peers is the same information displayed several times)

    global restorelayoutrunning
    if {$restorelayoutrunning} {return}

    set curta [gettextareacur]

    set listoftatoclose [getfullpeerset $curta]

    # since proc getuseranswerstoasksaveconfirm will anyway filter out peers
    # in order to ask the save question once only, just pass $curta instead
    # of $listoftatoclose
    set listoftatosave [getuseranswerstoasksaveconfirm $curta $quittype]

    if {$listoftatosave eq "UserHitCancel"} {
        # the user clicked cancel during the questions asking
        # about saving the modified textareas
        # --> don't save or close anything
        return

    } else {
        # close all hidden ta, save those asked by the user
        closelistofta $listoftatoclose $listoftatosave
    }
}

proc buttonclosetile {ta} {
# called when closing a tile by clicking on the "Close" button
# $ta is the textarea to close
    global restorelayoutrunning
    if {$restorelayoutrunning} {return}
    focustextarea $ta
    closecurtile yesnocancel
}

proc closecurtile {quittype} {
# close current tile
# this proc closes the current tile, i.e. the current textarea
# if the current textarea has peers, no confirmation is asked (and
# this is justified because there is at least one peer that contain
# the file information)
# if the current textarea has no peers, the normal confirmation
# process is required (which is mandatory to prevent the user from
# loosing data)
# important note:
#   closecurtile does not check for $restorelayoutrunning because
#   it is never called by a user action without previous filtering
#   on $restorelayoutrunning, see proc buttonclosetile
#   if closecurtile was to be called directly without previous such
#   filtering, then one would need to add if {$restorelayoutrunning} {return}
#   and proc restorelayoutstructure would fail to close the temporary
#   textarea 
    if {[llength [getpeerlist [gettextareacur]]] >= 1} {
        closecurta "NoSaveQuestion"
    } else {
        closecurta $quittype
    }
}

proc closelistofta {listoftatoclose listoftatosave {forceexit opennewemptyfile}} {
# for each textarea of $listoftatosave, save this textarea (no question asked to the user)
# then
# for each textarea of $listoftatoclose, close this textarea
# warning: side effect of this proc is that the current textarea is changed!

    foreach ta $listoftatoclose {

        # first display the file, in case a save as question is asked
        # but also because below closecurta is called
        showtext $ta

        if {[lsearch -exact $listoftatosave $ta] != -1} {
            # <TODO> get a return value from filetosave, and in case user
            #        clicked cancel in the save dialog don't close the file
            filetosave $ta
        } else {
        }

        closecurta "NoSaveQuestion" $forceexit
    }
}

proc closecurta {quittype {forceexit opennewemptyfile}} {
# close current textarea
#
# possible options for $quittype are "yesno", "yesnocancel" and "NoSaveQuestion"
#
# parameter $forceexit is used to prevent from opening a new empty
# file when the last one gets closed, thus forcing Scipad to exit
# most of the time forceexit is not given and defaults then to
# "opennewemptyfile", i.e. when closing the last buffer an empty
# new one will be created
# however, when called from doexitapp, forceexit receives "nonewemptyfile"
# thus preventing from opening a new empty file while closing the last
# file, and in turn forcing Scipad exit when this last file gets closed
# this proc first checks that there is no tile proc running (attempts to
# close a buffer while splitting buffers for instance would throw errors)

    global tileprocalreadyrunning

    # first check that there is no tile proc running (attempts to close
    # a buffer while splitting buffers for instance would throw errors)
    if {$tileprocalreadyrunning} {
        return
    }

    disablemenuesbinds

    byebyeta_askconfirmation [gettextareacur] $quittype $forceexit

    catch {restoremenuesbinds} ; # catched because pad is unknown after last buffer close
}

proc byebyeta_askconfirmation {ta quittype forceexit} {
# close textarea $ta, but first offer the user a chance to save or cancel
# possible options for $quittype are "yesno", "yesnocancel" and "NoSaveQuestion"
# this proc should only be called from the relevant wrapper, which is proc closecurta
# (because the latter checks for $tileprocalreadyrunning and runs
# disablemenuesbinds/restoremenuesbinds

    global tileprocalreadyrunning
    global listoffile pad

    set cancelled false

    if {$quittype ne "NoSaveQuestion"} {

        set answ [asksaveconfirm $ta $quittype]

        # <TODO> get a return value from filetosave, and in case user
        #        clicked cancel in the save dialog don't close the textarea
        #        (force $cancelled to true)
        switch -- $answ {
            yes     { filetosave $ta }
            no      { }
            cancel  { set cancelled true }
        }

    } else {
        # no confirmation question to ask
    }

    if {!$cancelled} {
        byebyeta $ta $forceexit
    }
}

proc byebyeta {textarea forceexit} {
# destroy all information related to textarea $ta

    global listoftextarea listoffile
    global pad FirstBufferNameInWindowsMenu pwframe
    global exitwhenlastclosed
    global closeinitialbufferallowed

    # if the last buffer will be closed, first open a new empty file (bug 3726)
    # but do it only if the exitwhenlastclosed preference is not set
    if {[llength $listoftextarea] == 1 && $forceexit=="opennewemptyfile" && !$exitwhenlastclosed} {
        # the next line is needed since otherwise filesetasnew will close
        # the buffer that we want to close right now, making showtext
        # and following commands fail
        set closeinitialbufferallowed false
        filesetasnew
        showtext $textarea
    }

    # properly removing breakpoints in Scipad is mandatory here
    # otherwise the bptsprops entries are not unset - see details
    # in proc deletebreakpoint
    # if in a debug session, this will also remove the breakpoints
    # from Scilab
    removebpt_scipad $textarea

    removefuns_bp $textarea

    if {[llength $listoftextarea] > 1} {

        focustextarea $textarea

        # delete the textarea entry in the listoftextarea
        set pos [lsearch $listoftextarea $textarea]
        set listoftextarea [lreplace $listoftextarea $pos $pos]

        # delete the windows menu entry
        set ilab [extractindexfromlabel $pad.filemenu.wind $listoffile("$textarea",displayedname)]
        $pad.filemenu.wind delete $ilab
        # from now on and until RefreshWindowsMenuLabelsWrtPruning gets executed below,
        # the windows menu may have only 8 underlined entries, not 9

        # refresh peer identifiers in the windows menu and title bars
        #   first decrease peer id for buffers having a peer id larger than
        #   the peer id of the buffer to close
        foreach {dname removedpeerid} [removepeerid $listoffile("$textarea",displayedname)] {}
        set peerslist [getpeerlist $textarea]
        foreach peerta $peerslist {
            set ilab [extractindexfromlabel $pad.filemenu.wind $listoffile("$peerta",displayedname)]
            foreach {dname peerid} [removepeerid $listoffile("$peerta",displayedname)] {}
            if {$peerid > $removedpeerid} {
                set dname [appendpeerid $dname [expr {$peerid - 1}]]
                set listoffile("$peerta",displayedname) $dname
                setwindowsmenuentrylabel $ilab $dname
            }
        }
        #   second, if there is only one peer buffer remaining, then remove its peer id
        if {[llength $peerslist] == 1} {
            set ilab [extractindexfromlabel $pad.filemenu.wind $listoffile("$peerslist",displayedname)]
            foreach {dname peerid} [removepeerid $listoffile("$peerslist",displayedname)] {}
            set listoffile("$peerslist",displayedname) $dname
            setwindowsmenuentrylabel $ilab $dname
        }
        # refresh panes titles (actually only needed for peers)
        updatepanestitles

        # delete the textarea entry in listoffile
        unset listoffile("$textarea",fullname)
        unset listoffile("$textarea",displayedname)
        unset listoffile("$textarea",new)
        unset listoffile("$textarea",thetime)
        unset listoffile("$textarea",disksize)
        unset listoffile("$textarea",language)
        unset listoffile("$textarea",colorize)
        unset listoffile("$textarea",readonly)
        unset listoffile("$textarea",binary)
        unset listoffile("$textarea",undostackdepth)
        unset listoffile("$textarea",redostackdepth)
        unset listoffile("$textarea",undostackmodifiedlinetags)
        unset listoffile("$textarea",redostackmodifiedlinetags)
        unset listoffile("$textarea",progressbar_id)
        unset listoffile("$textarea",encoding)
        unset listoffile("$textarea",eolchar)

        # the rest of this proc is similar to proc hidetext,
        # but not identical
        # unpack the textarea
        if {[llength $listoftextarea] <= [gettotnbpanes]} {
            destroypaneframe $textarea
        }

        # destroy the textarea widget itself
        destroy $textarea

        # place as current textarea the last one that is not already visible
        set i [getlasthiddentextareamenuind]
        if {$i == ""} {set i $FirstBufferNameInWindowsMenu}
        $pad.filemenu.wind invoke $i
        RefreshWindowsMenuLabelsWrtPruning

        # remove tile title if there is a single pane
        if {[gettotnbpanes] == 1} {
            set visibletapwfr [lindex [array get pwframe] 1]
            pack forget $visibletapwfr.topbar
        }

    } else {
        killscipad
    }
}
