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
# procedures dealing with pruned file names
##################################################
proc RefreshWindowsMenuLabelsWrtPruning {} {
# Manage displayed name in the windows menu according to the selected preference:
#
#   - full file names
#       always:  C:/a/b/c/fnam.ext
#
#   - full file names for ambiguous names (same file tail)
#       given:   C:/a/b/c/fnam.ext
#                C:/e/r/d/g/fff.ex2
#                C:/a/b/t/j/b/fnam.txt
#       display: C:/a/b/c/fnam.ext
#                fff.ex2
#                C:/a/b/t/j/b/fnam.txt
#       i.e. display full path when file tail is ambiguous, and just file tail if not
#
#   - unambiguous pruned file names
#       given:   C:/a/b/c/fnam.ext
#                C:/e/r/d/g/fff.ex2
#                C:/a/b/t/j/b/fnam.txt
#       display: c/fnam.ext
#                fff.ex2
#                t/j/b/fnam.txt
#       i.e. display minimal non-ambiguous file paths when file tail is ambiguous, and just file tail if not
#
#   - pruned directories
#       given:   C:/a/b/c/fnam.ext
#                C:/a/r/d/g/fff.ex2
#                C:/a/b/t/j/b/fnam.txt
#       display: b/c/fnam.ext
#                r/d/g/fff.ex2
#                t/j/b/fnam.txt
#       i.e. prune all full filepaths from the maximum length start sequence that is common to all of them
#
# The first 9 labels displayed in the windows menu also get a prepended underlined number,
# this is refreshed as well (through the calls to proc setwindowsmenuentrylabel)

    global listoffile listoftextarea pad filenamesdisplaytype

    if {$filenamesdisplaytype == "fullifambig" || $filenamesdisplaytype == "pruned"} {

        # Reset all to file tails
        foreach ta $listoftextarea {
            set i [extractindexfromlabel $pad.filemenu.wind $listoffile("$ta",displayedname)]
            foreach {dname peerid} [removepeerid $listoffile("$ta",displayedname)] {}
            set pn [file tail $listoffile("$ta",fullname)]
            lappend ind $i $pn $ta $peerid
        }
        foreach {i pn ta peerid} $ind {
            set pn [appendpeerid $pn $peerid]
            set listoffile("$ta",displayedname) $pn
            setwindowsmenuentrylabel $i $pn
        }
        # Detect duplicates and remove ambiguities
        foreach ta $listoftextarea {
            set tochange [IsPrunedNameAmbiguous $ta]
            if {$tochange != ""} {
                RemoveAmbiguity $tochange $ind
            }
        }

    } elseif {$filenamesdisplaytype == "full"} {

        # full file names are displayed, even if unambiguous
        foreach ta $listoftextarea {
            set i [extractindexfromlabel $pad.filemenu.wind $listoffile("$ta",displayedname)]
            foreach {dname peerid} [removepeerid $listoffile("$ta",displayedname)] {}
            set pn [appendpeerid $listoffile("$ta",fullname) $peerid]
            set listoffile("$ta",displayedname) $pn
            lappend ind $i $pn
        }        
        foreach {i pn} $ind {
            setwindowsmenuentrylabel $i $pn
        }

    } else {

        # $filenamesdisplaytype == "pruneddir"
        # Detect common starting sequence in the full filepath (naive implementation)
        # and remove this part from the displayed name
        set allelts [list ] 
        foreach ta $listoftextarea {
            set tapathelts [file split $listoffile("$ta",fullname)]
            lappend allelts $tapathelts
        }
        set firsttaallelts [lindex $allelts 0]
        set alleltsbutfirstone [lreplace $allelts 0 0]
        set commonpart -1
        set iscommon true
        for {set i 0} {$i <= [llength $firsttaallelts]} {incr i} {
            set elttocomparewith [lindex $firsttaallelts $i]
            foreach tapathelts $alleltsbutfirstone {
                if {[lindex $tapathelts $i] ne $elttocomparewith} {
                    set iscommon false
                    set commonpart $i
                    break
                }
            }
            if {!$iscommon} {
                # now go out of the loop: elements from 0 to $commonpart (excluded)
                # are common to all pathnames
                break
            }
        }
        if {$commonpart != -1} {
            # there is a prefix common to all filenames opened in Scipad
            set k 0  ;  # index of the textarea in list $allelts
            foreach ta $listoftextarea {
                set i [extractindexfromlabel $pad.filemenu.wind $listoffile("$ta",displayedname)]
                foreach {dname peerid} [removepeerid $listoffile("$ta",displayedname)] {}
                set pruneddirname ""
                set alleltsofthista [lindex $allelts $k]
                set maxindex [llength $alleltsofthista]
                for {set j $commonpart} {$j <= $maxindex} {incr j} {
                    set pruneddirname [file join $pruneddirname [lindex $alleltsofthista $j]]
                }
                set pn [appendpeerid $pruneddirname $peerid]
                set listoffile("$ta",displayedname) $pn
                lappend ind $i $pn
                incr k
            }        
            foreach {i pn} $ind {
                setwindowsmenuentrylabel $i $pn
            }
        } else {
            # there is no common prefix to the filenames, default to displaying full filenames
            set filenamesdisplaytype "full"
            RefreshWindowsMenuLabelsWrtPruning
            set filenamesdisplaytype "pruneddir"
        }
    }
    updatepanestitles
}

proc IsPrunedNameAmbiguous {ta} {
# Returns the list of textareas containing pruned file names
# identical to the pruned file name attached to $ta
# Note also that peers of $ta are never included in the output list
    global listoffile listoftextarea

    # file tail not needed when called from proc RefreshWindowsMenuLabelsWrtPruning
    # but needed when called from proc stringifyfunid
    foreach {pn peerid} [removepeerid [file tail $listoffile("$ta",displayedname)]] {}

    set peerlist [getpeerlist $ta]

    set whichta ""
    foreach ta1 $listoftextarea {
        foreach {pn1 peerid1} [removepeerid [file tail $listoffile("$ta1",displayedname)]] {}
        # $ta1 is identified as being ambiguous with $ta if and only if:
        #   - displayednames (which at this point are file tails) are the same
        # and
        #   - $ta1 is not a peer of $ta (note that a text widget is never
        #     identified by Tk as a peer of itself, therefore this second
        #     condition is true if $ta1==$ta)
        if {$pn1 == $pn && [lsearch -exact $peerlist $ta1] == -1} {
            lappend whichta $ta1
        }
    }

    # if there is only one element in the ambiguous textarea list, then
    # this element is $ta itself and there is actually no ambiguity
    if {[llength $whichta] == 1} {
        set whichta ""
    }

    return $whichta
}

proc RemoveAmbiguity {talist indlist} {
# $talist containing the list of textareas attached to ambiguous
# file tails, expand file names as necessary to remove ambiguities
# $indlist contains a flat list of chunks of four elements, ordered
# in the same order as $listoftextarea (one chunk for each entry in
# $listoftextarea):
#   - index in the windows menu of the entry
#   - file tail of the textarea fullname having this index in the windows menu
#   - textarea pathname
#   - peer identifier (or -1 in Tk 8.4 or if it is not a peer)
    global listoffile pad filenamesdisplaytype

    if {$filenamesdisplaytype == "fullifambig"} {

        # full file names are displayed if tails are ambiguous
        foreach ta $talist {
            # do it for the ambiguous displayedname of $ta
            foreach {i pn ta1 peerid} $indlist {
                if {$ta1 == $ta} {
                    # now $i and $peerid have the good value
                    break
                }
            }
            set en [appendpeerid $listoffile("$ta",fullname) $peerid]
            set listoffile("$ta",displayedname) $en
            setwindowsmenuentrylabel $i $en

            # do it also for peers of $ta
            foreach peerta [getpeerlist $ta] {
                foreach {i pn ta1 peerid} $indlist {
                    if {$ta1 == $peerta} {
                        # now $i and $peerid have the good value
                        break
                    }
                }
                set en [appendpeerid $listoffile("$ta",fullname) $peerid]
                set listoffile("$peerta",displayedname) $en
                setwindowsmenuentrylabel $i $en
            }

        }

    } else {

        # assert: $filenamesdisplaytype must be "pruned"
        # unambiguous pruned file names are displayed

        # from the fullnames, create the unambiguous displayednames without
        # changing the labels of the windows menu
        CreateUnambiguousPrunedNames $talist
        foreach ta $talist {

            # update the menu label for the ambiguous displayedname of $ta
            foreach {i pn ta1 peerid} $indlist {
                if {$ta1 == $ta} {
                    # now $i and $peerid have the good value
                    break
                }
            }
            set lab [appendpeerid $listoffile("$ta",displayedname) $peerid]
            set listoffile("$ta",displayedname) $lab
            setwindowsmenuentrylabel $i $lab

            # update also the menu label for peers of $ta
            foreach peerta [getpeerlist $ta] {
                foreach {i pn ta1 peerid} $indlist {
                    if {$ta1 == $peerta} {
                        # now $i and $peerid have the good value
                        break
                    }
                }
                set lab [appendpeerid $listoffile("$ta",displayedname) $peerid]
                set listoffile("$peerta",displayedname) $lab
                setwindowsmenuentrylabel $i $lab
            }

        }
    }
}

proc CreateUnambiguousPrunedNames {talist} {
# Example:
# From D:/a1/b1/c1/d1/afile.sci
#      E:/a1/b2/c1/d1/afile.sci   as full pathnames
# create b1/c1/d1/afile.sci
#        b2/c1/d1/afile.sci       as pruned names
    global listoffile
    # split full names into a number $ind("$ta") of elements
    foreach ta $talist {
        set elts("$ta") [file split $listoffile("$ta",fullname)]
        set ind("$ta") [llength $elts("$ta")]
    }
    # determine number of levels to keep in pruned filenames
    # and index of the first element to keep for each textarea
    set completetalist $talist
    set ta1 [lindex $talist [expr {[llength $talist] - 1}]]
    set talist [lreplace $talist end end]
    set leveltokeep true
    set nleveltokeep 0
    while {$leveltokeep} {
        incr nleveltokeep
        foreach ta $talist {
            incr ind("$ta") -1
        }
        incr ind("$ta1") -1
        set tocompare [lindex $elts("$ta1") $ind("$ta1")]
        foreach ta $talist {
            if { [lindex $elts("$ta") $ind("$ta")] != $tocompare } {
                set leveltokeep false
            }
        }
    }
    # create new minimally pruned unambiguous filenames
    foreach ta $completetalist {
        set newname ""
        for {set i $ind("$ta")} {$i <= [expr {$ind("$ta") + $nleveltokeep}]} {incr i} {
            set tojoin [lindex $elts("$ta") $i]
            set newname [file join $newname $tojoin]
        }
        set listoffile("$ta",displayedname) $newname
    }
}
