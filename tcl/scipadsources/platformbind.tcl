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


# <TODO>: this whole stuff about switchable bindings must absolutely be rethought
#         since this is really a horrible way of implementing it...
#         kind of a temporary mock-up that was never finished but nevertheless
#         made it into the code!



######################################
# platform-specific bindings
######################################
# We have found that some key sequences are given a variety of names
# on different platforms. E.g. Shift-F12 can be called XF86_Switch_VT_12
# on most unices, or even Shift-SunF37 on Suns. Therefore, when we need to
# bind these sequences, we try and catch all the known possibilities,
# using pbind instead of bind. The lists of possible names are defined in 
# the events argument of proc pbind
proc pbind {w events action} {
    global bindstyleentry bindstyle
    foreach e $events {
        if {![catch {bind $w <$e> $action}]} {
            # add it in the bindset array so that findbindings
            # will be able to return it later
            set bindstyleentry $bindstyle
            sbind $w <$e> $action
            # <TODO>: Well, this is absolutely not OK.
            #         We are making use here of a feature made for
            #         *switchable* bindings and add there something
            #         *NOT switchable*. If the binding scheme gets
            #         switched, then the binding we have just set
            #         is simply lost in the new scheme while it should
            #         stay unmodified instead.
        }
    }
}

##################################################
# procedures for supporting several switchable sets of bindings
##################################################
proc getswitchablebindnames {} {
# browse the disk for files named xxx.tcl in the bindings directory
# and extract their rootnames xxx, which will be considered to denote
# binding schemes
    global binddir
    set switchablebindnames [list ]
    set bindfiles [lsort [globtails $binddir *.tcl]]
    foreach m $bindfiles {
        set bindstyleentry [file rootname $m]
        # for some reason $bindstyleentry might be empty under cygwin
        # this is probably due to the /cygdrive/ syntax for paths
        if {$bindstyleentry ne ""} {
            lappend switchablebindnames $bindstyleentry
        }
    }
    return $switchablebindnames
}

proc initswitchablebindings {} {
# clear the bindset array containing the list of bindings
# for each switchable binding scheme
    global bindset
    foreach bindstyleentry [getswitchablebindnames] {
        set bindset($bindstyleentry) {}
    }
}

proc loadbindings {} {
# populate the bindset array containing the list of bindings
# for each switchable binding scheme, by sourceing each bindings
# file from disk
    global binddir
    # Warning: the  global bindstyleentry  below is absolutely needed
    #          it sets the element name of the bindset array in which
    #          the bindings sourced below will be stored
    #          this works because bindstyleentry is a global also in
    #          proc sbind  --  very ugly and prone to bugs <TODO>: FIX THIS!!!
    global bindstyleentry
    foreach bindstyleentry [getswitchablebindnames] {
        global Tk85 ; # required because sourcing bindings files
        global pad  ; # (e.g. mac-pc.tcl) require these variables
        source [file join $binddir $bindstyleentry.tcl]
    }
}

#each binding file contains sbind as a drop-in replacement of bind
proc sbind {scope event action} {
    global bindset bindstyleentry
    # <TODO>: Shoulnd't we look for duplicates before blindly lappending?
    #         Well normally there should be none, unless the programmer
    #         made a mistake and defined several times the same key
    #         combination for the same scope
    lappend bindset($bindstyleentry) [list $scope $event $action]
}

proc rebind {} {
# switch bindings to the newle selected scheme $bindstyle

    global bindset bindstyle

    # first null all bindings defined for all the styles
    # different from the currently selected $bindstyle
    set allstyles [array names bindset]
    foreach i $allstyles {
        if {$i != $bindstyle} {
            foreach b $bindset($i) {
                set scope [lindex $b 0]
                set event [lindex $b 1]
                bind $scope $event {}
            }
        }
    }

    # then effect the current ones
    foreach b $bindset($bindstyle) {
        set scope [lindex $b 0]
        set event [lindex $b 1]
        set action [lindex $b 2]
        bind $scope $event $action
    }

    # finally redraw the menues, so that the accelerators are updated
    createmenues
    setdbmenuentriesstates_bp
}

proc findbinding {command} {
# browse the list of *switchable* bindings for the key combination
# triggering the Tcl script $command in the switchable binding scheme
# named $bindstyle (this is a global)
#
# Warning: this proc does NOT search among ALL the bindings, it only
#          looks for $cmmand among the SWITCHABLE bindings (i.e. those
#          defined through  proc sbind

    global bindset bindstyle
    set event ""
    foreach b $bindset($bindstyle) {
        if  {[lindex $b 2] == $command} {
            set event [lindex $b 1]
            break
        }
    }
    return $event
}

proc bindenable {tag command} {
# how horrible this is...!
# 1. it uses proc findbinding, i.e. it works only for *switchable*
#    bindings (see this proc) - no reason for that!!
# 2. what ig $command is bound to more than a single $tag scope?
# <TODO> FIX this !!
    set b [findbinding $command]
    if {$b !=""} {
        bind $tag $b "$command"
    }
}

proc binddisable {tag command} {
# how horrible this is...! (ditto, see proc bindenable)
# <TODO> FIX this !!
    set b [findbinding $command]
    if {$b !=""} {
        bind $tag $b {}
    }
}

proc validpostfix {char status options} {
# only used in the emacs bindings scheme
# <TODO>: should be finished...

#      puts "$char $status"
    if {[regexp $char $options] & [expr {!($status & 252)}]} {
          showinfo " "
      } else {
          showinfo [mc "Invalid keyboard sequence!"]        
          bell; 
      }
}
