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
# file line endings procs
##################################################
proc getfilelineendingchar {fullfilename} {
# return the line ending character used in the file named $fullfilename
# this is done by reading the file and analysing its content
# the file must exist and be readable
# return values:
#   crlf : lines end with carriage return + line feed (\r\n) - Typical Windows file
#   cr   : lines end with carriage return (\r) - Typical Macintosh file
#   lf   : lines end with line feed (\n) - Typical Unix/Linux file
#   mixed: inconsistent line endings in the file

    # read the file in binary mode and put it in a string for further analysis
    set fid [open $fullfilename r]
    fconfigure $fid -translation binary
    set bintextcontent [read $fid]  ; # mandatory: no -nonewline option!
    close $fid

    # count number of eol characters in each possible case
    set nb_crlf_matches [regexp -all -- {\r\n}         $bintextcontent]
    set nb_cr_matches   [regexp -all -- {\r[^\n]|\r\Z} $bintextcontent]
    set nb_lf_matches   [regexp -all -- {\A\n|[^\r]\n} $bintextcontent]

    if {$nb_cr_matches == 0 && $nb_lf_matches == 0} {
        # Windows line endings (carriage return + line feed)
        return "crlf"
    } elseif {$nb_crlf_matches == 0 && $nb_lf_matches == 0} {
        # Macintosh line endings (carriage return)
        return "cr"
    } elseif {$nb_crlf_matches == 0 && $nb_cr_matches == 0} {
        # Unix line endings (line feed)
        return "lf"
    } else {
        # Mixed (inconsistent) line endings
        return "mixed"
    }
}

proc getlineendingchar {textarea forceplatformeol} {
# return the real line ending character to use in the
# -translation option of fconfigure when saving the file
# displayed in $textarea
    global listoffile currenteolchar
    if {$forceplatformeol} {
        return [platformeolchar]
    } elseif {$currenteolchar eq "detect"} {
        return $listoffile("$textarea",eolchar)
    } else {
        return $currenteolchar
    }
}

proc platformeolchar {} {
# return the line ending character for files on disk specific to the platform
# Scipad is running on. This is:
#   crlf on Windows
#   cr on Macintosh
#   lf on Unix/Linux
    global tcl_platform
    switch -- $tcl_platform(platform) {
        windows   {return "crlf"}
        macintosh {return "cr"}
        unix      {return "lf"}
    }
}

proc warnifchangedlineendings {textarea filenam eolchar fileisbin} {
# for binary files ($fileisbin is true):
#   return [platformeolchar], as a default value that should not be used
# for non-binary files ($fileisbin is false):
#   if $eolchar is "mixed", display a warning message, set line endings
#   selection (options menu) to [platformeolchar] and return [platformeolchar]
#   otherwise return $eolchar

    global pad tcl_platform currenteolchar
    global showlineendingswarningsonfileopen

    if {$fileisbin} {
        return [platformeolchar]
    }

    if {$eolchar eq "mixed"} {
 
        if {$showlineendingswarningsonfileopen} {
            set tit [mc "Inconsistent line endings"]
            set mes [mc "Inconsistent line endings in file:"]
            append mes "  " $filenam
            append mes "\n\n" [mc "This file contains mixed (inconsistent) line ending characters."]
            append mes "\n\n" [mc "When saving this file, it will receive consistent line endings as selected in the Options menu."]
            append mes "\n\n" [mc "Do you want to stop seeing this warning?"]
            set answ [tk_messageBox -message $mes -icon warning -title $tit -type yesno -parent $pad]
            switch -- $answ {
                yes {set showlineendingswarningsonfileopen false}
                no  {set showlineendingswarningsonfileopen true}
            }
        }
        foreach ta [getfullpeerset $textarea] {
            forcemodified $ta
            modifiedtitle $ta
        }
        return [platformeolchar]

    } else {

        # $eolchar ne "mixed"

        if {$currenteolchar ne "detect"} {

            if {$eolchar ne $currenteolchar} {
                if {$showlineendingswarningsonfileopen} {
                    set tit [mc "Change of line endings"]
                    set mes [mc "Change of line endings in file:"]
                    append mes "  " $filenam
                    append mes "\n\n" [mc "This file is using"] "  \"" $eolchar "\"  " [mc "as its line ending character."]
                    append mes "\n"  [mc "Warning: when saving this file, it will receive"] "  \"" $currenteolchar
                    append mes "\"  " [mc "line endings unless you change this in the Options menu."]
                    append mes "\n\n" [mc "Do you want to stop seeing this warning?"]
                    set answ [tk_messageBox -message $mes -icon warning -title $tit -type yesno -parent $pad]
                    switch -- $answ {
                        yes {set showlineendingswarningsonfileopen false}
                        no  {set showlineendingswarningsonfileopen true}
                    }
                }
                foreach ta [getfullpeerset $textarea] {
                    forcemodified $ta
                    modifiedtitle $ta
                }

            } else {

                # $eolchar eq $currenteolchar
                # no message to display: the selection in the options menu is identical
                # to the line endings already used by the file
            }

            return $eolchar

        } else {

            # $currenteolchar eq "detect"
            return  $eolchar
        }

    }

}
