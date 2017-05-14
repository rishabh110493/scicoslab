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

##################################################
# ancillaries for file commands
##################################################
proc getpathandext {ta} {
# if textarea $ta has no associated pathname, return a flat list of two
#   empty elements
# otherwise return a flat list of two elements:
#   {full_path_of_file_displayed_in_$ta  extension_of_file_displayed_in_$ta}
    global listoffile
    if {$listoffile("$ta",new) == 1} {
        # new file, no associated pathname
        return [list [list ] [list ]]
    } else {
        set fullpathname [file normalize $listoffile("$ta",fullname)]
        return [list [file dirname $fullpathname] [file extension $fullpathname]]
    }
}

proc knowntypes {} {
# list of known file types - used for filtering items in the Open and Save dialogs
# and in the Find dialog
# note that preselection in the open and save dialogs is a useful feature even
# if there is no language scheme (colorization...) associated to a given extension:
# the dialog opens with preselection of the filter associated to the extension of
# the file displayed in the current textarea
    set scifiles [mc "Scilab files"]
    set cosfiles [mc "Scicos files"]
    set xmlfiles [mc "XML files"]
    set txtfiles [mc "Text files"]
    set tclfiles [mc "Tcl/Tk files"]
    set modfiles [mc "Modelica files"]
    set allfiles [mc "All files"]
    set types [concat "{\"$scifiles\"" "{*.sce *.sci *.tst *.dem}}" \
                      "{\"$cosfiles\"" "{*.cosf}}" \
                      "{\"$xmlfiles\"" "{*.xml *.xsd *.dtd *.xaml}}" \
                      "{\"$txtfiles\"" "{*.txt *.log *.bat}}" \
                      "{\"$tclfiles\"" "{*.tcl *.msg}}" \
                      "{\"$modfiles\"" "{*.mo}}" \
                      [knowntypes_layoutfiles] \
                      [knowntypes_allfiles] ]
    return $types
}

proc knowntypes_layoutfiles_or_allfiles {} {
    set types [concat [knowntypes_layoutfiles] \
                      [knowntypes_allfiles] ]
    return $types
}

proc knowntypes_layoutfiles {} {
    set layfiles [mc "Layout files"]
    set type [concat "{\"$layfiles\"" "{*.lay}}" ]
    return $type
}

proc knowntypes_allfiles {} {
    set allfiles [mc "All files"]
    set type [concat "{\"$allfiles\"" "{*.* *}}" ]
    return $type
}

proc knownextensions {} {
# return a flat list of all known extensions (not including *.* nor *)
# limited to the extension only (i.e. .xyz and not *.xyz)
# this is achieved by parsing the output of knowntypes, which is perhaps
# a bit more work than hardcoding the result, but it's more generic
    set exts [list ]
    foreach kntype [knowntypes] {
        foreach {typename listofextensions} $kntype {}
        foreach ext $listofextensions {
            if {$ext ne "*.*" && $ext ne "*"} {
                lappend exts [string range $ext 1 end]
            }
        }
    }
    return $exts
}

proc extenstoknowntypes {exttomatch} {
# given a file extension (including the leading dot) $exttomatch such as .xzy
# return the localized name of the file type from the known types
# in case there is no match, return {}
# in case there is more than one match, return the first match
    set exttomatch "*$exttomatch"
    foreach typenameandext [knowntypes] {
        foreach {localizedtypename listofextens} $typenameandext {
            foreach ext $listofextens {
                if {$ext eq $exttomatch} {
                    return $localizedtypename
                } else {
                    # nothing to do: same player, play again
                }
            }
        }
    }
    # we didn't return before this, this means there is no match
    return [list ]
}

proc extenstolang {file} {
# given a file extension, return the associated language scheme
    set type [extenstoknowntypes [string tolower [file extension $file]]]
    if {$type eq [mc "XML files"]} {
        return "xml"
    } elseif {$type eq [mc "Scilab files"] || $type eq "Scicos files"} {
        return "scilab"
    } elseif {$type eq [mc "Modelica files"]} {
        return "modelica"
    } else {
        return "none"
    }
}

proc direxists {dir} {
# check whether $dir is an existing directory
# return value:
#   1  $dir exists and is a directory
#   0  otherwise
    set ret 0
    if {[file exists $dir]} {
        if {[file isdirectory $dir]} {
            set ret 1
        }
    }
    return $ret
}

proc fileunreadable {file} {
# check readability of $file, and tell the user if $file is not readable
# (but keep silent if it is readable)
# $file might be a file name or a directory name, but if it is a directory
# name the return value will always be 1 (normally a directory is never given
# to proc fileunreadable in Scipad so this doesn't matter)
# return value:
#   1  $file exists and is not readable
#   0  otherwise (either $file does not exist or if it exists it is readable)
# note that this proc will answer 0 (not unreadable, i.e. readable), any time
# $file does not exist, and this is the intended behaviour
# comments about the way readability is checked:
#   The instruction file readable has a number of bugs in Tcl:
#     - Tcl bug 1394972: file readable answers 1 or 0 but the file is
#       locked therefore cannot actually be read
#       Note: this bug has been marked as WONTFIX in the Tcl tracker
#       since it is an OS limitation. On Windows there is no way to
#       know before trying to open a file that it is locked.
#       A test with constraint "knownBug" has been added in fCmd.test
#       (in the Tcl test suite)
#     - Tcl bug 1613456: file readable checks wrong permissions on a
#       Samba share - this bug has been filed in the Tcl tracker because
#       it is the root cause for Scilab bug 2243, at least for the part
#       of this bug related to readability (there is also a writability
#       issue reported in bug 2243)
#   The quest for a reliable way to check readability of a file has
# therefore led to directly trying to read the file and see whether it
# works or not. This approach still suffers from possible race conditions
# (but there would be such races anyway with file readable) but is
# believed to be better than to wait for the above bugs be possibly fixed

    global pad

    if {![file exists $file]}  {
        return 0
    } else {
        if {[catch {set fileid [open $file r]} errormessage] == 0} {
            # the file can really be read
            close $fileid
            return 0
        } else {
            # the file cannot be read
            append msgboxmess [mc "The file"] $file \
                              [mc "exists but is not readable!"] \
                              "\n\n" [mc "Error message:"] "\n    " $errormessage
            tk_messageBox -title [mc "Unreadable file"] \
                -message $msgboxmess \
                -icon warning -type ok -parent $pad
            return 1
        }
    }
}

proc fileunwritable {file} {
# check writability of $file
# $file might be a file name or a directory name
# return value:
#   1  $file is not writable
#   0  otherwise
# note that this proc may answer 0 (not unwritable, i.e. writable), even
# if $file does not exist, and this is the intended behaviour: a new
# file can be written somewhere as soon as sufficient permissions exist
# comments about the way writability is checked:
#   The instruction file writable has a number of bugs in Tcl:
#     - Tcl bug 1613456: file writable checks wrong permissions on a
#       Samba share - this bug has been filed in the Tcl tracker because
#       it is the root cause for Scilab bug 2243, at least for the part
#       of this bug related to writability (there is also a readability
#       issue reported in bug 2243)
#     - Scilab bug 2319 seems to be also a writability problem on a
#       special distributed filesystem (DFS)
#   The quest for a reliable way to check writability of a file has
# therefore led to directly trying to write the file and see whether it
# works or not. This approach still suffers from possible race conditions
# (but there would be such races anyway with file writable) but is
# believed to be better than to wait for the above bugs be possibly fixed
#   If $file is a directory, then a test file is created in $file to
# check for writability in directory $file
#   Test files are immediately deleted after creation

    if {[file isdirectory $file]} {
        set file [file join $file Scipadwritabilitytestfile.txt ]
    }

    if {[file exists $file]}  {
        set preexistingfile true
    } else {
        set preexistingfile false
    }

    if {[catch {set fileid [open $file a]}] == 0} {
        # the file can really be written
        close $fileid
        if {!$preexistingfile} {
            # if the file did not exist before trying to open it in
            # append mode, then the open command created it above
            # the file should then be suppressed
            file delete -- $file
        }
        return 0
    } else {
        # the file cannot be written
        return 1
    }
}

proc filehaschangedondisk {ta} {
# return value:
#   2  the file opened in $ta does not exist on disk and is not a new
#      file, thus it has been erased from disk by another process
#   1  the file opened in $ta exists on disk, is not a new file, and:
#        its last saving time is different from the modify date retrieved
#        from the file on disk
#      or
#        its last size is different from the size retrieved
#        from the file on disk
#      or
#        its readonly flag changed (this is checked only for non-binary files)
#   0  otherwise
    global listoffile
    if {[fileexistsondisk $ta]} {
        if {[filetimeondiskisdifferent $ta]} {
            return 1
        }
        if {[filesizeondiskisdifferent $ta]} {
            return 1
        }
        if {!$listoffile("$ta",binary)} {
            if {$listoffile("$ta",readonly) != [fileunwritable $listoffile("$ta",fullname)]} {
                return 1
            }
        }
    } else {
        # file does not exist on disk
        if {$listoffile("$ta",new) == 0} {
            # file has been erased from disk by another process
            return 2
        }
    }
    return 0
}

proc fileexistsondisk {ta} {
# return value:
#   1  the file opened in $ta exists on disk and is not a new file
#   0  otherwise
    global listoffile
    if { [file exists $listoffile("$ta",fullname)] && \
         $listoffile("$ta",new) == 0 } {
        return 1
    }
    return 0
}

proc filetimeondiskisdifferent {ta} {
# return value:
#   1  the file saving time on disk is different from the time as known by
#      Scipad
#   0  otherwise
    global listoffile
    if {$listoffile("$ta",thetime) != [file mtime $listoffile("$ta",fullname)]} {
        return 1
    }
    return 0
}

proc filesizeondiskisdifferent {ta} {
# return value:
#   1  the file size on disk is different from the size as known by
#      Scipad
#   0  otherwise
    global listoffile
    if {$listoffile("$ta",disksize) != [file size $listoffile("$ta",fullname)]} {
        return 1
    }
    return 0
}

proc setlistoffile_colorize {ta fullfilename} {
# set listoffile("$ta",colorize) to the right value according to the colorize
# option "always", "ask" or "never"
# the fullfilename parameter can be set to "", which is used for new files not
# yet saved on disk, and which have therefore no size - colorize defaults to
# true in the "ask" case
# this proc is supposed to be used only when:
#   - opening files from disk
#   - creating new files (not when creating peers)
# listoffile("$ta",colorize) can also be changed after opening of the
# file through the Scheme menu and proc switchcolorizefile

# note: no need in this proc to loop on [getfullpeerset $ta]
#       because it is only called when opening or creating a new file
#       (that has then no peers)

    global pad listoffile colorizeenable

    # arbitrary size in bytes above which Scipad will ask for colorization
    set sizelimit 130000

    if {$colorizeenable == "always"} {
        set listoffile("$ta",colorize) true

    } elseif {$colorizeenable == "ask"} {
        if {[catch {file size $fullfilename} fsize] != 0} {
            # file size cannot be obtained, maybe the file does not exist
            set listoffile("$ta",colorize) true
        } else {
            if {$fsize > $sizelimit} {
                set answ [tk_messageBox \
                     -message [mc "This file is rather large and colorization might take some time.\n\nColorize anyway?"] \
                     -title [mc "File size warning"] \
                     -parent $pad -icon warning -type yesno]
                if {$answ == "yes"} {
                    set listoffile("$ta",colorize) true
                } else {
                    set listoffile("$ta",colorize) false
                }
            } else {
                set listoffile("$ta",colorize) true
            }
        }

    } else {
        # assert: $colorizeenable == "never"
        set listoffile("$ta",colorize) false
    }
}

proc fileiswindowsshortcut {filename} {
# check whether $filename denotes a Windows shortcut or not   
# return value:
#   1  $filename is a Windows shortcut
#   0  otherwise (includes the case when $filename does not exist, as well
#      as anything else)

    global pad

    # catched to allow to call this proc even if $filename does not exist
    # for instance
    if {[catch {iswindowsshortcut $filename} isashortcut] != 0} {
        return 0
    }

    if {$isashortcut} {
        tk_messageBox -title [mc "Windows shortcut file"] \
            -message [concat [mc "The file"] $filename \
                     [mc "is a Windows shortcut and will not be opened!"]] \
            -icon warning -type ok -parent $pad
        return 1
    } else {
        return 0
    }
}

proc iswindowsshortcut {filename} {
# on anything else than windows, return 0
# on windows, return 1 if $filename is a shortcut, and false otherwise
# $filename should contain the final (invisible) .lnk extension, but this
# is not the way this proc checks that the argument is a shortcut. Rather
# it reads the first 4 bytes of the file in binary mode and decides of the
# result based on those bytes
# See: http://www.i2s-lab.com/Papers/The_Windows_Shortcut_File_Format.pdf
# Notes:
#  . $filename is supposed to exist and be readable
#  . The GUID is not checked since it might change in the future when
#    Microsoft decides to change the shortcut file format
    global tcl_platform

    if {$tcl_platform(platform) != "windows"} {
        return 0
    }

    # $filetype might be undefined after reading the first bytes, if the file
    # size is zero for instance, therefore define a fallback value here so
    # that the check on that value will return false below
    set filetype {}

    set ch [open $filename r]
    fconfigure $ch -encoding binary -translation binary -eofchar {}
    binary scan [read $ch 4] i filetype
    close $ch

    # shortcut files are identified by their four first bytes being 0000004Ch
    # i.e. 76 in decimal, or letter "L" in ASCII
    if {$filetype != "76"} {
        return 0
    } else {
        return 1
    }
}

proc fileisbinary {filename} {
# try to detect if a file is a binary file
# note that there is no really reliable way of doing this
# the rule used here is:
#   read the first 8 kbytes of the file, and if it contains
#   at least three null bytes (zero values), then it is a
#   binary file

    global detectbinaryfiles

    # assert: file existence has been ensured before calling this proc

    if {!$detectbinaryfiles} {
        # "Try to detect binary files" option is disabled,
        # all files are supposed to be text files
        return false
    }

    # that many bytes will be read (or less, if the file is shorter)
    set chunksizeinbytes 8192

    # minimum number of zeroes for deciding if the file is binary
    set threshold 3

    # read the beginning of the file
    set ch [open $filename r]
    fconfigure $ch -encoding binary -translation binary -eofchar {}
    set beginningoffile [read $ch $chunksizeinbytes]
    close $ch

    # convert the binary data read into a list of bytes in text string representation
    binary scan $beginningoffile c* listofbytes

    # count how many zeroes can be found
    # and decide about binary or not
    set nbofnull 0
    foreach abyte $listofbytes {
        if {$abyte == 0} {
            incr nbofnull
            if {$nbofnull >= $threshold} {
                return true
            }
        }
    }
    return false
}

proc globtails {directoryname pat} {
# this is a replacement for the construct
#     glob -nocomplain -tails -directory $directoryname $pat
# because there is a Tcl bug with the -tails option with old
# Tcl versions (for instance with 8.4.1, at least on cygwin)
    set matchfiles [glob -nocomplain -directory $directoryname $pat]
    for {set i 0} {$i < [llength $matchfiles]} {incr i} {
        set matchfiles [lreplace $matchfiles $i $i [file tail [lindex $matchfiles $i]]]
    }
    return $matchfiles
}

proc substitutepercentescapesequences {str} {
# substitute all %xy sequences in $str (x and y being two hex digits)
# by the character whose hex code is xy and return the substituted string
# this is used in URLs, where the percent sign is an escape character indicating
# that the next two characters are hex digits representing a single ASCII character
    global percenthexseqRE
    # first find out where %xy must be substituted
    set percentmatches [regexp -all -inline -indices -- $percenthexseqRE $str]
    # second, replace each %xy by the character which hex code can be found in range {$sta+1 $sto} in $str
    # lreverse the list of matches so that it's possible to work in place
    foreach amatch [lreverse $percentmatches] {
        foreach {sta sto} $amatch {}
        set newchar [format %c [expr 0x[string range $str [expr $sta + 1] $sto]]]
        set str [string replace $str $sta $sto $newchar]
    }
    return $str
}

proc escapequotes {filename} {
# possible quotes in $filename must be doubled before sending the filename to Scilab
# filenames with single quotes can be created (on Windows at least)
# filenames with double quotes cannot be created (on Windows at least), but you
# never know, so double them also
    set esc_f [string map {' ''} $filename]
    set esc_f [string map {\" \"\"} $esc_f]
    return $esc_f
}

proc expandSCI {filepath} {
# if $filepath starts with SCI, replace SCI in $filepath by
# the full Scilab installation path and return the modified filepath
# (and ditto for SCIHOME)
# otherwise return the unmodified $filepath
    global env
    if {$filepath eq "SCI"} {
        set filepath $env(SCIINSTALLPATH)
    } else {
        set startchars [string range $filepath 0 3]
        if {($startchars eq {SCI/}) || ($startchars eq {SCI\\})} {
            set filepath [file join $env(SCIINSTALLPATH) [string range $filepath 4 end]]
        } else {
            if {$filepath eq "SCIHOME"} {
                set filepath $env(SCIHOME)
            } else {
                set startchars [string range $filepath 0 6]
                if {($startchars eq {SCIHOME/}) || ($startchars eq {SCIHOME\\})} {
                    set filepath [file join $env(SCIHOME) [string range $filepath 7 end]]
                } else {
                }
            }
        }
    }
    return $filepath
}
