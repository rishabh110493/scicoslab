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

##########################################################################
# Saved preferences
#
# all one needs in order to add a new retrievable preference is:
#  - add the variable name to $listofpref below, if it is not a list
#  - add the variable name to $listofpref_list below, if it is a list
#  - use the variable when needed in the program, such that 
#    it is visible at main level (i.e. globalize it)
#  - if needed, assign an initial fallback value here

# group here for convenience all the color settings
set bgcolors {BGCOLOR BGLNMARGCOLOR BGMLMARGCOLOR SELCOLOR \
        BREAKPOINTCOLOR ANYFOUNDTEXTCOLOR CURFOUNDTEXTCOLOR \
        CONTLINECOLOR MODELICAANNOTATIONCOLOR}
set fgcolors {FGCOLOR FGLNMARGCOLOR FGUSMLMARGCOLOR FGSMLMARGCOLOR \
        CURCOLOR PARCOLOR BRAKCOLOR \
        BRACCOLOR PUNCOLOR INTFCOLOR COMMCOLOR OPCOLOR QTXTCOLOR \
        REMCOLOR XMLCOLOR NUMCOLOR LFUNCOLOR PDEFCOLOR SCICCOLOR \
        USERFUNCOLOR USERVARCOLOR CLICKABLELINKCOLOR \
        MODELICAPUNCOLOR MODELICAPARCOLOR MODELICABRAKCOLOR MODELICABRACCOLOR \
        MODELICAOPCOLOR MODELICANUMBERCOLOR \
        MODELICAKEYWORDCOLOR MODELICAINTROPCOLOR \
        MODELICASTRINGCOLOR MODELICACOMMENTCOLOR}
set colorpref "$bgcolors $fgcolors"

# those are the preferences which are going to be saved (unconditionally, i.e. always)
set listofpref "$colorpref wordWrap \
       WMGEOMETRY WMSTATE printCommand indentspaces tabsizeinchars \
       usekeywordindent filenamesdisplaytype maxrecentfiles maxrecentencodings \
       scilabSingleQuotedStrings tabinserts lang completionbinding \
       showContinuedLines filebackupdepth bindstyle doubleclickscheme \
       colorizeenable windowsmenusorting linenumbersmargin linenumberstype \
       modifiedlinemargin \
       ScilabErrorMessageBox colorizeuserfuns colorizeuservars \
       autoreleasecolorization showclosureXcross \
       exitwhenlastclosed autodetectencodinginxmlfiles \
       show_message_missing_tkdnd currenteolchar showuservartooltips \
       hideModelicaannot highlightModelicaannot \
       highlightmatchingchars loadpreviouslyopenedfilesonstartup \
       detectbinaryfiles \
       scipadupdatelasttimecheckedsecs scipadupdatecheckinterval \
       maintoolbarvisibleflag maintoolbarsmalliconsflag \
       autodetectproxy forcedproxyhost forcedproxyport \
       proxyauthentication rememberauthentication \
       fileglobpat initdir findresultsinnewwindow layoutstartdir"

# those are the preferences which are going to be saved (unconditionally, i.e. always)
# as lists
set listofpref_list { listofrecentfiles listofrecentencodings textFont menuFont \
       layoutstructureatendofprevsession \
       findtextcombolistvar replacetextcombolistvar glopatterncombolistvar indirectorycombolistvar \
       incfindtextcombolistvar }

# those are the preferences which are going to be saved conditionally
# each item is a list of two elements  {thepref cond}
# if $cond is true, then thepref gets saved
set listofcondpref { {geturlauthheaders rememberauthentication} }

# default options which can be overriden
setallcolorstodefault
set wordWrap "none"
set WMGEOMETRY 600x480
set WMSTATE normal
set printCommand lpr
set indentspaces 2
set tabsizeinchars 4
set usekeywordindent 1  ; # use smart keyword indentation: 0 (no) or 1 (yes)
set filenamesdisplaytype "pruned"  ;# "pruned" or "full" or "fullifambig" or "pruneddir"
set maxrecentfiles 15
set maxrecentencodings 5
set listofrecentfiles [list]    ;# always full filenames here
set listofrecentencodings [list]
set scilabSingleQuotedStrings "yes"
set tabinserts "spaces"    ;# "spaces" or "tabs"
set completionbinding "Control-Tab"
set showContinuedLines "yes"
set filebackupdepth 0
set bindstyle "mac-pc"
set doubleclickscheme "Scilab"  ;# "Scilab" or "Windows" or "Linux"
set windowsmenusorting "openorder" ; # "openorder", or "alphabeticorder", or "MRUorder"
set linenumbersmargin "right" ; # "hide" (line numbers are not displayed), or "left" (they are left-aligned), or "right" (right-aligned)
set linenumberstype "logical_ignorecontlines" ; # "physical" (line numbers in the file) or "logical" (line numbers in Scilab functions) or "logical_ignorecontlines" (logical, but continued lines ignored, which makes it identical to line numbers reported by error messages in Scilab/Scicoslab)
set modifiedlinemargin "show" ; # "hide" (modified line tags margin not displayed) or "show" (it is displayed)
set ScilabErrorMessageBox true
set colorizeenable "always"     ;# "always" or "ask" or "never"
set colorizeuserfuns "yes"
set colorizeuservars "yes"
set autoreleasecolorization "yes"
set showclosureXcross true
set exitwhenlastclosed false
set autodetectencodinginxmlfiles true
set show_message_missing_tkdnd true
set currenteolchar "detect"  ; # "detect" or "crlf" (Windows) or "cr" (Macintosh) or "lf" (Linux/Unix)
set showuservartooltips "always"  ; # "always", "debug" or "never"
set hideModelicaannot false      ;# COMMON to all textareas (for the time being <TODO>)
set highlightModelicaannot false ;# COMMON to all textareas 
set highlightmatchingchars "hover"  ;# "hover" or "cursor" or "both" or "never"
set layoutstructureatendofprevsession [list ]
set loadpreviouslyopenedfilesonstartup true
set detectbinaryfiles true
set scipadupdatelasttimecheckedsecs 0  ;# zero so that the first time Scipad is launched in a new install it will check for updates
set scipadupdatecheckinterval oneweek
set maintoolbarvisibleflag true
set maintoolbarsmalliconsflag true
set findtextcombolistvar [list ]
set replacetextcombolistvar [list ]
set glopatterncombolistvar [list ]
set indirectorycombolistvar [list ]
set incfindtextcombolistvar [list ]
set autodetectproxy true       ; # true means: autodetect proxy name and port (this is done by the autoproxy package)
set forcedproxyhost localhost  ; # may be a name (such as localhost or myproxy.com) or an IP address (e.g. 192.168.0.200)
set forcedproxyport 8118       ; # localhost:8118 is the configuration for privoxy (my testing conf...)
set proxyauthentication false
set geturlauthheaders [list ]  ; # the base64-encoded thing may be saved in the preferences file
set rememberauthentication false
set findresultsinnewwindow true
unset -nocomplain layoutstartdir  ; # no default value for this variable

# End of saved preferences
##########################################################################

setdefaultfonts

##########################################################################
# Other non-preferences initial settings

# Select the Scilab locale when starting Scipad for the first time
# The test ![info exists lang] should always be true
# The lang variable is set to the getlanguage() result from Scilab
# If a preferences file exists, the value of the pref file will overwrite this
# because the pref file is sourced later
# This way the code portion below is really useful only when Scipad is started
# for the very first time from a fresh Scilab installation
# Precautions are taken (try;end) against Scilab versions not havng a clue about
# getlanguage() so that this code can be used with no change in Scilab 4.x
# backports
if {![info exists lang]} {

    # try to use the same locale as Scilab
    ScilabEval_lt "try;TCL_SetVar(\"lang\",convstr(getlanguage(),\"l\"),\"scipad\");end" "sync" "seq"

    if {![info exists lang]} {
        # Select a fallback in case setting the locale through getlanguage() failed
        setdefaultScipadlangvar
    } else {
        # Select a fallback when the Scilab language is not available in Scilab
        # In fact the english locale must be set explicitely as a fallback here
        # this is because later the locale is set by ::msgcat::mclocale $lang
        # and when ::msgcat::mc will try to translate the string using this unknown
        # locale it will trigger ::msgcat::mcunknown which will return the label.
        # Since this label is the english string, we could be happy with this, but
        # it is not *always* the case, sometimes the label is not the english string
        if {[lsearch [getavailablelocales] $lang] == -1} {
            setdefaultScipadlangvar
        } else {
            # success: Scilab's locale is available in Scipad and will be used
        }
    }
}

set applicationname "Scipad"
set Scheme scilab
set ColorizeIt true ;# NOT common to all textareas: refreshed with $listoffile("$ta",colorize) everytime it's needed

# Insert cursors
# By default, the insert cursor in textareas is the I-shaped cursor
# The block cursor is emulated in Tk 8.4 (result is not very good),
# but it is a real block cursor in Tk 8.5
# In Tk 8.4:
#   I-cursor has     -insertwidth $textinsertcursorwidth
#                    -insertborderwidth $textinsertcursorborderwidth
#                    -insertbackground $CURCOLOR
#   Block cursor has -insertwidth $textreplacecursorwidth
#                    -insertborderwidth $textreplacecursorborderwidth
#                    -insertbackground $CURCOLOR
# In Tk 8.5:
#   I-cursor and block cursor both have
#                    -insertwidth $textinsertcursorwidth
#                    -insertborderwidth $textinsertcursorborderwidth
#                    -insertbackground $CURCOLOR
#   and I-cursor is     -blockcursor false
#       Block cursor is -blockcursor true
#   The I-cursor width in pixels is $textinsertcursorwidth
#   The block cursor width in pixels is (pixels occupied by 1 character
#                                        + $textinsertcursorwidth)
set textinsertmode true
set textinsertcursorwidth 3         ; # in pixels
set textinsertcursorborderwidth 2   ; # in pixels, inside $textinsertcursorwidth
set textreplacecursorwidth 6        ; # in pixels (only used if {!$Tk85})
set textreplacecursorborderwidth 0  ; # in pixels, inside $textreplacecursorborderwidth (only used if {!$Tk85})

# Drag and drop feature initial state
set mouseoversel false
set dndinitiated false

# this array will contain frame ids such that $pwframe($textarea) is the
# frame pathname in which $textarea is packed, or "none" if it is not packed
array unset pwframe

# default encoding is the system native encoding
set defaultencoding [encoding system]
set currentencoding $defaultencoding

# number of files currently being opened (and probably colorized,
# depending on their sizes) by Scipad, and maximum number of files
# that will be accepted for simultaneous opening
# (this is particularly used when dropping files/directories on Scipad)
set nbfilessimultaneouslybeingopened 0
set maxnbfilessimultaneouslybeingopened 100

# identifier of the mark denoting an unsaved modified line,
# and a saved modified line
set unsavedmodifiedmarkID 0
set   savedmodifiedmarkID 0

# width in pixels of the margin displaying visual clues about
# what lines were modified since opening of the file, and since
# last save action
set modifiedlinemarginpixelwidth 5

# maximum number of entries allowed in listboxes of comboboxes
# receiving user input from their entry field
# (so far this is used in the find/replace comboboxes only)
set maxnbentriesindropdownlistboxes 20

# when opening files the line endings are checked, this flag says if the outcome
# of this check shall be shown to the user (true) or not (false)
# this is intentionally not a user preference, however this setting can be modified
# by the user each time the line endings check procedure shows something, so that
# Scipad will be silent for the rest of the session
set showlineendingswarningsonfileopen true

##########################################################################
# source the user preferences file if any
# this must happen after the locale selection from Scilab's getlanguage() above

set preffilename [file join $env(SCIHOME) .SciPadPreferences.tcl]
catch {source $preffilename}

##########################################################################

# ensure the menu option settings for margins are consistent with
# the default or the value from the preferences file
set linenumbersmarginmenusetting  $linenumbersmargin
set modifiedlinemarginmenusetting $modifiedlinemargin

# recompute $textfontsize and $menufontsize from the preferences file fonts
settextandmenufontsize


##########################################################################
# Additional packages

# add path for finding the additional packages in Scilab binary versions
# (bug 3806) - the paths organization is not the same in binary versions
# and in the development tree
if {$Scilab5 && !$standaloneScipad} {
    lappend ::auto_path $env(SCIINSTALLPATH)/modules/tclsci/tcl
} else {
    lappend ::auto_path $env(SCIINSTALLPATH)/tcl
}


# message files and localization

if {[catch {package require msgcat}] == 0} {

    # package is present and loaded

    namespace import -force msgcat::*
    ::msgcat::mclocale $lang

    # the names of the locales are common for all languages (each one is the
    # native language name), and are defined in a separate file.
    # the common definition can anyway be overridden by a definition in the
    # $msgsdir/$lang.msg file
    source [file join "$msgsdir" "localenames.tcl"]
    if {[::msgcat::mcload $msgsdir] == 0} {
        # no msg file found for the current locale (bug 3781)
        set lang "en_us"
        ::msgcat::mclocale $lang
        ::msgcat::mcload $msgsdir
    } else {
        # nothing to do, mcload succeeded at the first place
    }

} else {

    # package is not present, define default fallbacks

    namespace eval msgcat {

        # used when switching locales through the Options menu
        proc ::msgcat::mclocale {args} {
            tk_messageBox -message "Package msgcat is not present - Localization features are disabled." \
                          -icon warning -title "Tcl msgcat package not found"
        }

        proc ::msgcat::mcload {args} {}

        # define mcset and read the english message file so that named labels
        # will receive the English translation, then erase mcset so that it
        # will no longer be used when switching locales
        proc ::msgcat::mcset {args} {
            global englishfallbacktrans
            foreach {localename label trans} $args {}
            set englishfallbacktrans($label) $trans
        }
        if {$Tcl85} {
            # utf-8 since this is the encoding of the message file, and it's needed
            # to have the correct special characters in contributor's names
            source -encoding utf-8 [file join "$msgsdir" "en_us.msg"]
        } else {
            # too bad for 8.4, characters will be mangled
            source [file join "$msgsdir" "en_us.msg"]
        }
        proc ::msgcat::mcset {args} {}

        proc ::msgcat::mc {str} {
            global englishfallbacktrans
            if {[info exists englishfallbacktrans($str)]} {
                # case where there is a match in en_us.msg,
                # which should be the case of a named label
                # since the other labels are directly the English string
                return $englishfallbacktrans($str)
            } else {
                return $str
            }
        }

       proc ::msgcat::mcmax {args} {
            set le 0
            foreach arg $args {
                set argle [string length $arg]
                if {$argle > $le} {set le $argle}
            }
            return $le
        }
    }
    proc mc    {str}  {return [eval [list ::msgcat::mc $str]]}
    proc mcmax {args} {return [eval "::msgcat::mcmax $args"]}
}


# drag and drop capability using TkDnD

if { [catch {package require -exact tkdnd 1.0}] == 0 } {
    # package could be loaded from somewhere
    # (i.e. it is available from outside of Scipad)
    set TkDnDloaded true
} else {
    # try to load the tkdnd package provided with Scipad
    lappend ::auto_path [file join $sourcedir tkdnd]
    if { [catch {package require -exact tkdnd 1.0}] == 0 } {
        # package could be loaded
        set TkDnDloaded true
    } else {
        # this should never happen under Windows (32 or 64 bits)
        # nor under Linux (32 or 64 bits)
        set TkDnDloaded false
    }
}


# scrolledframe (this is used in the breakpoints properties dialog)
namespace import ::scrolledframe::scrolledframe


# combobox
namespace import ::combobox::combobox


# http is used for checking the internet for an updated Scipad version
if { [catch {package require http 2.0}] == 0 } {
    # package is present and loaded
    set httploaded true
} else {
    set httploaded false
}


# autoproxy
# this package is not distributed with Scilab nor with Scicoslab
# but it is needed for automatic detection of the proxy configuration
# it has the following dependencies:
#    http
#        the http package is distributed with Scicoslab and with Scilab
#        ==> no problem, package require http should succeed, and anyway
#        variable $httploaded is here to deal with all cases
#    uri
#    base64
#        these two packages are not distributed with Scicoslab/Scilab
#        they are therefore distributed with Scipad
#        both are pure Tcl packages
#        none of these packages are  package required  here because they
#        are sourced in scipad.tcl
#    registry (only on Windows - on other OSs this is not a dependency)
#        this package is not distributed with Scicoslab, neither with
#        Scilab-5.4.0-alpha-1 (but it was up to Scilab-5.3.3)
#        it is therefore distributed with Scipad
#        however this is a package distributed in binary form
#        Linux: the package is not needed and is completely ignored
#        Win 32 bits / 64 bits : the package is made available through
#        the adequate addition in $::auto_path
# note that  namespace import ::autoproxy::*  is not done here because the
# fully qualified proc names are always used
if {$tcl_platform(platform) eq "windows"} {
    if { [catch {package require registry}] == 0 } {
        # package could be loaded from somewhere
        # (i.e. it is available from outside of Scipad)
        set registryloaded true
    } else {
        # try to load the registry package provided with Scipad
        # here one must guess if the 32 bits or 64 bits version of
        # the package shall be loaded
        # decision based on  if {$tcl_platform(wordSize) == 4}
        # does not make it: $tcl_platform(wordSize) is 4 even when
        # running a 64 bits version of Scilab in a 64 bits OS (Vista)
        # reason unknown.
        # Perhaps tcl_platform(pointerSize) could help, but this is not
        # available in Tcl 8.4
        # In any case, first:
        # try the 32 bits package provided with Scipad
        lappend ::auto_path [file join $sourcedir proxy registry_win32]
        if { [catch {package require registry}] == 0 } {
            # package could be loaded
            # (and Scipad is running in a 32 bits Scilab environment)
            set registryloaded true
        } else {
            # remove the path and any info for 32 bits package, and
            # try the 64 bits package provided with Scipad
            #  package forget  is needed for the next  package require  to
            # succeed since it failed previously in folder registry_win32
            # because of wrong architecture (specifically: Scilab x64 is
            # running in a 64 bits platform, and attempt was made to load
            # the 32 bits registry package). It tried to load the 32 bits
            # package, and still knows the package ifneeded info, which
            # must be removed before trying to load the 64 bits version of
            # the registry package
            package forget registry
            set ::auto_path [lreplace $::auto_path end end]
            lappend ::auto_path [file join $sourcedir proxy registry_win64]
            if { [catch {package require registry}] == 0 } {
                # package could be loaded
                # (and Scipad is running in a 64 bits Scilab environment)
                set registryloaded true
            } else {
                set registryloaded false
            }
        }
    }
} else {
    # package is not needed on Linux, let's say it's available
    # otherwise flags depending on $registryloaded, such as
    # $internetpackagesloaded, will get later a wrong value
    set registryloaded true
}

if {$httploaded && $registryloaded} {
    set internetpackagesloaded true
} else {
    set internetpackagesloaded false
}


# End of additional packages
##########################################################################


# variable used to track changes to the initial buffer
# so that Scipad can automatically close it if first
# action in Scipad is a successful file/open
set closeinitialbufferallowed true

# The following must be unset otherwise the goto line box can produce errors
# when it is opened again with the same file that was opened before in another
# textarea
catch {unset physlogic linetogo curfileorfun funtogoto}

# variable used to prevent more than one single instance of any of the tile
# procs from running concurrently, e.g. maximize and splitwindow
# for some unknown reason, disabling the bindings in proc disablemenuesbinds
# does not *always* prevent concurrent running, so this was needed
set tileprocalreadyrunning false

# variable used to prevent dropping files while restoring the layout of
# the previous Scipad session
set restorelayoutrunning false

# guard variable used to prevent more than one simultaneous launch of the
# find/replace box, which can happen during startup when hammering
# Scipad with ctrl-r ctrl-f or the opposite
set findreplaceboxalreadyopen false

# guard variable used to prevent more than one simultaneous launch of proc
# checkifanythingchangedondisk (see reasons in that proc)
set checkifanythingchangedondisk_running false

# variable used to prevent launching simultaneously multiple searches in files
# during search in file, the other functionalities of Scipad are however enabled
set searchinfilesalreadyrunning 0

# variable used to detect buffer changes between two Find Next commands
# with Ctrl-F3
set buffermodifiedsincelastsearch false

# default find/replace direction
set SearchDir "forwards"

# find/replace color tags
set REPLACEDTEXTCOLOR $CURFOUNDTEXTCOLOR
set FAKESELCOLOR $SELCOLOR

# no item is selected by default in the tags list of the find/replace dialog
set listoftagsforfind [list ]

# some commands cannot be executed while colorization is in progress, and
# this variable is used to prevent them from being executed in such a case
set nbfilescurrentlycolorized 0

# timings for performance measurement of colorization processes
set thresholdcolorizeuservartime_us 200000 ; # 0.2 second, which is considered as the usability limit
set previoustimecolorizeuservar_us 0       ; # init value that must be lower than the threshold above
set thresholdcolorizeuserfuntime_us 100000 ; # 0.1 second
set previoustimecolorizeuserfun_us 0       ; # init value that must be lower than the threshold above

# user idle time before colorization of user functions and variables is launched (Tk 8.5 only)
set minuseridletime 1500 ; # in milliseconds

# identifier of the progressbar for background colorization - increments only
set progressbarId 0

# Scilab limit for the length of names (see help names)
set maxcharinascilabname 24

# this variable is used to restore the word wrap mode after a block selection
set blockseltoggledwordwrap false

# the display of the busy state in the status bar is normally on
# (in fact it's only off when retrieving user variables values from Scilab
# for displaying them in tooltips - if it's on during the roundtrip, the
# user gets a disturbing blinking of the status bar almost whenever he moves
# the mouse! - at least in scilab scheme when the mouse cursor hovers text
# tagged as uservar, and the users selected the option to show the tooltip)
set show_displaybusystate true

# by default when opening the find dialog, force recursivity for search in files
set recursesearchindir 1

# init value when the mouse never hovered any clickable link
set mouseoverlink ""

##########################################################################
# URLs definitions

# single place in Scipad where the bugzilla URL is defined
set ScilabBugzillaURL {http://bugzilla.scilab.org}

# the most recent backported Scipad version can be found at this URL
# this link points to Scipad_6.152.BP1
#set latestbackportedscipadversionURL {http://www.scilab.org/contrib/index_contrib.php?page=displayContribution&fileID=1130}
# Sept. 2010: still available! but no longer used since Scipad is now
#             a SourceForge project

# single place in Scipad where the Scipad project page URL is defined
set ScipadprojectatSourceForgeURL {http://sourceforge.net/p/scipad}

# ticket entry point at the Scipad project website
set ticketentrypointatScipadprojectatSourceForgeURL {http://sourceforge.net/p/scipad/tickets}

# download entry point at the Scipad project website
set downloadentrypointatScipadprojectatSourceForgeURL {https://sourceforge.net/projects/scipad/files}

# URL where the Scipad debugger internals are described
set scipaddebuggerinnerworkingsdescriptionURL {http://wiki.scilab.org/Scipad_debugger_inner_beauties}

# "best release" page of the Scipad project at SourceForge 2.0 beta
# it is hoped that this will be at least moderately perennial
# see also http://sourceforge.net/apps/ideatorrent/sourceforge/ideatorrent/idea/874
# which is requesting a web service from SourceForge for discovering
# the latest version
# if latest version checking fails for no apparent reason, check this first!
# and check html content of this URL second!
set latestscipadversionURL {http://sourceforge.net/projects/scipad/best_release.html}

# End of URLs definitions
##########################################################################

##########################################################################
# Regular expression patterns
# These are globals since used at different places of the code, or because
# they are rather generic

# Scilab names character class for first character of names
# From help names: Names of variables and functions must begin with a letter
# or one of the following special characters ' % ', ' _ ', ' # ', ' ! ', ' $ ', ' ? '
set sncc1RE {[[:alpha:]%_#!?$]}

# Scilab names character class for all but first character of names
# From help names: Next characters may be letters or digits or any special
# character in ' _ ', ' # ', ' ! ', ' $ ', ' ? '
# Note that \w already contains the underscore
set sncc2RE {[\w#!?$]}

# Negated Scilab names character class (non reporting)
# Note: this is neither the negation of $sncc1RE nor the negation of $sncc2RE
set notsnccRE {(?:\A|[^\w%#!?$])}
# Negated Scilab names character class lookahead
set notsncclookaheadRE {(?=[^\w%#!?$]|\Z)}

# Scilab names regexp, reporting version and non-reporting version
set snRE_rep {}
append snRE_rep {(} $sncc1RE $sncc2RE * {)}
set snRE {}
append snRE {(?:} $sncc1RE $sncc2RE * {)}

# Any number of blanks (spaces or tabs), possibly none
set sblRE {[[:blank:]]*}

# Scilab comment, reporting version and non-reporting version
set scommRE_rep {(//[^\n]*)}
set scommRE {(?://[^\n]*)}

# Scilab continuation mark
# Note: more than one continued line is a single match
# scontRE does not need an actual continued line to match (* case)
# scontRE1 does need an actual continued line to match (+ case)
# scontRE2 is the same as scontRE but may be followed by optional blanks
set scontRE {}
append scontRE {(?:} $sblRE {\.{2,}} $sblRE $scommRE {?} {\n} {)} {*}
set scontRE1 {}
append scontRE1 {(?:} $sblRE {\.{2,}} $sblRE $scommRE {?} {\n} {)} {+}
set scontRE2 {}
append scontRE2 {(?:} $scontRE1 $sblRE {)}

# List of Scilab names separated by commas, allowing blanks and continuations anywhere
# Note: empty list is NOT a match
set slnRE {}
append slnRE $snRE {(?:} $scontRE $sblRE {,} $scontRE $sblRE $snRE {)*}

# List of Scilab names separated by commas and enclosed in brackets,
# reporting version and non-reporting version
# Note: empty brackets [] is a match
set sbklnRE {}
append sbklnRE {\[} $scontRE $sblRE {(?:} $slnRE {)?} $scontRE $sblRE {\]}
set sbklnRE_rep {}
append sbklnRE_rep {\[} $scontRE $sblRE {(} $slnRE {)?} $scontRE $sblRE {\]}

# List of Scilab names separated by commas and enclosed in parenthesis,
# reporting version and non-reporting version
# Note: empty parenthesis () is a match
set spalnRE {}
append spalnRE {\(} $scontRE $sblRE {(?:} $slnRE {)?} $scontRE $sblRE {\)}
set spalnRE_rep {}
append spalnRE_rep {\(} $scontRE $sblRE {(} $slnRE {)?} $scontRE $sblRE {\)}

# Scilab left part of an assignment such as "[a,b,c] =" or just "a ="
set saslRE {}
append saslRE {(?:} {(?:} $sbklnRE {|} $snRE {)} $scontRE $sblRE {=} $scontRE {)} {?} $sblRE

# Scilab right part of an assignment, without the function name, such as "(a,b,c)" or just "a" or "()"
set sasrRE {}
append sasrRE $sblRE $scontRE $sblRE {(?:} $spalnRE {)} {?} $scontRE $sblRE {(?:} {[;,]} {|} {(?:} $sblRE $scommRE {)} {|} {\n} {)}

# Scilab function definition regexp (left part, i.e. up to but not including function name)
set sfdlRE {}
append sfdlRE {\mfunction\M[[:blank:]]*} $scontRE $saslRE

# Scilab function definition regexp (right part, i.e. from but not including function name)
set sfdrRE {}
append sfdrRE $sasrRE

set funlineREpat1 $sfdlRE
set funlineREpat2 $sfdrRE
set scilabnameREpat $snRE_rep

# regular expression matching a line starting with a return statement of a
# Scilab function, i.e. either
#   endfunction          or
#   [..] = resume(...)   or
#   [..] = return(...)
# note that the regexp starts with the \A constraint, i.e it matches at the
# beginning of the string, therefore the text passed to the regexp engine
# must be a single line of a scilab text buffer (and not an entire buffer)
# if this is a nuisance, replace \A by ^ and use regexp -line option
# note also that we don't care about what is after the return statement, we
# only need the return statement be the first executable instruction of the
# line
set sresRE {}
append sresRE {\A} $sblRE {(} {(endfunction)} {|}
append sresRE                 {(} $saslRE {(return)|(resume)} $sasrRE {)}
append sresRE             {)}

###

# Strictly positive integer number, with no leading zero, or zero itself,
# reporting
set strictlypositiveintegerREpat {\A((0)|([1-9][0-9]*))\Z}

# Floating point number, reporting version and non-reporting version
# The reporting version is used in the find dialog only, and satisfies itself from
# using \m and \M constraints (beginning and end of a word, a word being defined
# as in man re_syntax, i.e.:
#   A word is defined as a sequence of word characters that is neither preceded
#   nor followed by word characters. A word character is an alnum character or
#   an underscore ("_")
# )
# The non-reporting version however must take into account the correct word
# characters, as defined by tcl_wordchars and tcl_nonwordchars below,
# otherwise numbers will be matched inside Scilab names, e.g. in za?145#
# which shall not be the case.
# \M can easily be replaced by a negative lookahead:  (?=[^\w%#!?$]|\Z)
# but there is no lookbehind in Tcl to replace \m. A regular match must then
# be used instead of \m, which implies that the real match will be in the
# first subMatchVar of regexp instead of in matchVar
# See the discussion here:
#    http://groups.google.com/group/comp.lang.tcl/browse_thread/thread/2e55997cf4895199
# Note: for the sake of simplicity I decide there is no need to dynamically
#       update $floatingpointnumberREpat when tcl_(non)wordchars is changed
set floatingpointnumberREpat_rep {\m((\.\d+)|(\d+(\.\d*)?))([deDE][+\-]?\d{1,3})?\M}
set floatingpointnumberREpat {}
append floatingpointnumberREpat $notsnccRE
append floatingpointnumberREpat {((?:(?:\.\d+)|(?:\d+(?:\.\d*)?))(?:[deDE][+\-]?\d{1,3})?)}
append floatingpointnumberREpat $notsncclookaheadRE

# Rational number, reporting version
set rationalnumberREpat_rep      {\m((\.\d+)|(\d+(\.\d*)?))\M}

###

# Scilab operators
set Scilab_operatorREpat {}
append Scilab_operatorREpat {>=|<=|==|<>|~=}
append Scilab_operatorREpat {|\.\*\.|\.\/\.|\.\\\.|\.\^|\.\*|\.\/|\.'|\.\\|\\\.}
append Scilab_operatorREpat {|['\^*\/+\-\\><=$|&~]}

###

# regular expression matching a continued line identified as such because
# it has trailing dots possibly followed by a comment
set dotcontlineRE_rep {}
append dotcontlineRE_rep {(^} {([^/]/?)*\.{2,}} $sblRE {(//.*)?} {$)}
set dotcontlineRE {}
append dotcontlineRE     {(?:^} {(?:[^/]/?)*\.{2,}} $sblRE {(?://.*)?} {$)}

# maximum level of nesting for brackets and braces
# if a higher level of nesting exists in a continued line of the textarea,
# then continued lines detection algorithm will be fooled
set constructsmaxnestlevel 3

# regular expression matching a continued line identified as such because
# it has unbalanced brackets possibly followed by a comment
set bracketscontlineRE {(?:^(?:(?:[^/"']/?)*(?:[^\w%#!?$]["'][^"']*["'])*)*\[[^\]]*(?:(?:(?:}
append bracketscontlineRE [createnestregexp $constructsmaxnestlevel {[} {]}]
append bracketscontlineRE {)*[^\]]*)*\n)+(?:(?:[^/]/?)*\.{2,}} $sblRE {(?://.*)?\n)*)}

# regular expression matching a continued line identified as such because
# it has unbalanced braces possibly followed by a comment
set bracescontlineRE   {(?:^(?:(?:[^/"']/?)*(?:[^\w%#!?$]["'][^"']*["'])*)*\{[^\}]*(?:(?:(?:}
append bracescontlineRE [createnestregexp $constructsmaxnestlevel "{" "}"]
append bracescontlineRE {)*[^\}]*)*\n)+(?:(?:[^/]/?)*\.{2,}} $sblRE {(?://.*)?\n)*)}

###

# Scilab string, delimited by single quotes or double quotes, with no
# continuation dots nor comments (for this see proc colorizestringsandcomments_sd)
# reporting version and non-reporting version
set sstrRE   {(?:(?:["'][^"']*["'])+)}
set sstrRE_rep {((?:["'][^"']*["'])+)}

# Scilab matrix of strings (with no continuation dots nor comments)
set smstRE_rep {}
append smstRE_rep {\[} $sblRE {(?:} $sstrRE $sblRE {[,;]?} $sblRE {)+} {\]}

# Scilab matrix of strings or string (all with no continuation dots nor comments)
set ssmsRE {}
append ssmsRE {(?:} $smstRE_rep {)|(?:} $sstrRE {)}

###

# regular expression matching the start of an XML prolog and reporting
# an encoding name in that prolog
# see the XML specification http://www.w3.org/TR/xml
# see also use of this RE in proc detectencoding
set xml_prologstart_RE_rep {<\?xml[[:blank:]]+version[[:blank:]]*=[[:blank:]]*["']1.[[:digit:]]+["'][[:blank:]]+encoding[[:blank:]]*=[[:blank:]]*["']([[:alpha:]][\w.-]+)["']}

###

# a sequence of three characters %xy (x and y being hex digits),
# that is used for substituting this sequence in filenames provided by TkDnD
set percenthexseqRE {%[[:xdigit:]]{2}}

###

# regular expressions used to colorize Modelica files

# Modelica keywords are names composed of just lowercase letters
# The following regexp allows a pre-filtering of what in the textarea could
# be a Modelica keyword
# they are all names composed of only letters or numbers (see the Modelica specification)
set Modelica_keywordlike_RE {}
append Modelica_keywordlike_RE {(?:} {\m[[:alnum:]]+\M} {)}

# Modelica operators (from Modelica spec. sections 3.4 and 3.5)
set Modelica_operatorREpat {}
append Modelica_operatorREpat {>=|<=|==|<>}
append Modelica_operatorREpat {|[\^*\/+\-><]}
append Modelica_operatorREpat {|\mand\M}
append Modelica_operatorREpat {|\mor\M}
append Modelica_operatorREpat {|\mnot\M}

# Modelica floating point number
set Modelica_floatingpointnumberREpat {}
append Modelica_floatingpointnumberREpat $notsnccRE
append Modelica_floatingpointnumberREpat {((?:(?:\.\d+)|(?:\d+(?:\.\d*)?))(?:[eE][+\-]?\d{1,3})?)}
append Modelica_floatingpointnumberREpat $notsncclookaheadRE

# Modelica string
set Modelica_string_RE {(?:"(?:[^"\\]*(?:\\[^"]|\\"(?:[^"\\]|\\[^"])*)*)*")}

# Modelica single line comment, i.e. comment as   //  ...
set Modelica_singlelinecomment_RE {//[^\n]*}

# Modelica (potentially) multiline comment, i.e. comment as   /* ... */
set Modelica_multilinecomment_RE {/\*(?:[^\*]*|(?:[^\*]*\*[^/])*)*\*/}

###

# regular expression matching an URL
# The following one borrowed from  http://wiki.tcl.tk/15536  is far from
# being perfect, but it does the job most of the time:
#   set urlREpat {(?:[[:alpha:]]?)(?:\w){2,7}:(?://?)(?:[^[:space:]>"]*)}
# However, since we anyway now distribute the uri package with Scipad
# let's just use the regexp it provides
# only the http scheme will be considered here
# the other schemes (returned by set ::uri::schemes) are not taken into
# account to avoid a too complex regular expression, which could slow down
# the matching quite a lot. As a consequence, neither scheme from
# {ftp file gopher mailto news wais prospero ldap} is considered, which
# is not believed to be much of a problem since they are much less frequent
# than http
set urlREpat $::uri::http::url
# the regexp the uri package provides needs to be modified so that:
#    - https is accepted in addition to http
#    - the regexp does not report the submatches (this is required for
#      using the regexp in proc colorizetag)
set urlREpat [string replace $urlREpat 0 3 (http|https)]
set urlREpat [string map {( (?:} $urlREpat]

###

# the user might want the same behaviour on Windows as on Linux for
# double-clicking - this is bug 1792, see also
# http://groups.google.fr/group/comp.lang.tcl/browse_thread/thread/659fd6c1f41d9a81/eb2a841ac335580e
# note: the need to say catch {tcl_endOfWord} is due to Tk bug 1517768
# with this catch, tcl_wordchars and tcl_nonwordchars become known to wish
# however, the need to do this leads to infinite loop when $debuglog == true
# the second time Scipad is launched in the same Scilab session
# no attempt to fix this is made because it only happens in debuglog
# mode (due to the renaming of the procs) and because it is a Tk bug
# to have to say catch {tcl_endOfWord}
if {![info exists tcl_wordchars]} {
    catch {tcl_endOfWord}
}
set tcl_wordchars_linux {[a-zA-Z0-9_]}
set tcl_nonwordchars_linux {[^a-zA-Z0-9_]}
set tcl_wordchars_windows {\S}
set tcl_nonwordchars_windows {\s}
set tcl_wordchars_scilab {[\w%#!?$]}
set tcl_nonwordchars_scilab {[^\w%#!?$]}
updatedoubleclickscheme
# <TODO> this may need to be extended and *linked to the language scheme* (or not?)
#        for instance what is a word in the scilab language scheme may not be
#        a word in the modelica scheme (or vice versa)
#        this is a problem when using $textarea index "$ind wordend"  or  wordstart
#        for instance, e.g. in the indentation mechanism of proc insertnewline
#        in other words, tcl_wordchars and tcl_nonwordchars are not only used when
#        double clicking!

# End of regular expression patterns
##########################################################################
