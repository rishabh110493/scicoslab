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

proc initinternetconnectionsettings {} {
# initialize internet connection configuration settings
# and take care of all cases:
#   - no proxy
#   - with proxy, no authentication
#   - with proxy, with authentication
# the proxy host name and port may be autodetected or not
    configureproxyhostandport
    configureproxyauthenticationheader
}

proc cb_menu_autodetectproxy {} {
# called when clicking on the "Autodetect proxy" menu item
# in the options menu
    configureproxyhostandport
    togglegreyproxyoptions
    configureproxyauthenticationheader ; # must be after togglegreyproxyoptions
    showdetectedproxyhostandport
}

proc cb_menu_useproxyauth {} {
# called when clicking on the "Use proxy authentication"
# in the options menu
    inputproxyauthenticationdataifheaderempty
    configureproxyauthenticationheader ; # must be before togglegreyproxyoptions
    togglegreyproxyoptions
}

proc configureproxyhostandport {} {
# configure the proxy settings (proxy host name or IP address, and proxy port)
# either to be autodetected by the autoproxy package,
# or to be forced to the settings previously input by the user

    global internetpackagesloaded
    global autodetectproxy forcedproxyhost forcedproxyport
    global useaproxy

    if {!$internetpackagesloaded} {
        return
    }

    if {$autodetectproxy} {

        # try to detect the proxy settings

        set detectedproxyserverandport [autoproxy::init]

        if {$detectedproxyserverandport ne ""} {

            # proxy settings were found in the environment(Linux)
            # or in the registry (Windows)
            # the call to autoproxy::init is then enough to hook
            # the http package to the proxy because autoproxy::init
            # ran  http::config -proxyfilter autoproxy::filter  and
            # this filter returns then the proxy host and port that
            # were detected during autoproxy::init
            # in short there is nothing more to do: http::geturl
            # will use the proxy for any request
            # however, to be clean, the -proxyhost and -proxyport
            # options *from the http package* are emptied so that
            # they do not contain possibly wrong (user forced)
            # proxy name and port information - the correct proxy
            # name and port will be returned by autoproxy::filter
            # which gets called during http::geturl
            http::config -proxyhost {} -proxyport {}

            set useaproxy true

        } else {

            # no proxy detected, autoproxy::init did not hook the
            # http package to any proxy
            # there is nothing more to do, http::geturl will not use
            # a proxy
            # however, clean the -proxyhost and -proxyport options
            # so that no wrong forced proxy name and port remain
            # also -proxyfilter is reset to its default value,
            # which will return {} since -proxyhost is empty
            http::config -proxyhost {} -proxyport {}
            http::config -proxyfilter http::ProxyRequired

            set useaproxy false

        }

    } else {

        # don't try to detect the proxy settings, take the values input
        # by the user and set them in the http package
        # autoproxy is not used at all in this case
        http::config -proxyhost $forcedproxyhost -proxyport $forcedproxyport

        # the -proxyfilter option must be set to the default proxy filter
        # from the http package because if the proxy was previously
        # autodetected, then this option contains the filter from the
        # autoproxy package (i.e. autoproxy::filter)
        # this would not harm since both filters return the list
        # {$forcedproxyhost $forcedproxyport}, i.e. no filter is
        # really set (all requests will go through the proxy), but let's
        # do it entirely properly which means do not use anything from
        # the autoproxy package when the proxy settings are forced
        http::config -proxyfilter http::ProxyRequired

        # there is nothing more to do: http::geturl will use the forced
        # proxy settings (responsibility left to the user about correctness
        # of proxy name and port he entered), and nothing from autoproxy is used

        set useaproxy true

    }
}

proc showdetectedproxyhostandport {} {

    global pad
    global useaproxy autodetectproxy

    if {$autodetectproxy} {
        set tit [mc "Detected proxy"]
        if {$useaproxy} {
            set mes [mc "Detected proxy is:"]
            append mes "\n  "
            append mes [mc "Host:"] "  " [autoproxy::cget -proxy_host]
            append mes "\n  "
            append mes [mc "Port:"] "  " [autoproxy::cget -proxy_port]
        } else {
            set mes [mc "No proxy settings could be detected.\nScipad will assume that Internet connection does not go through a proxy."]
        }
        tk_messageBox -message $mes -icon info -title $tit -parent $pad
    }
}

proc inputproxyauthenticationdataifheaderempty {} {

    global proxyauthentication geturlauthheaders

    set geturlauthheaders_emptynamepwd [list Proxy-Authorization \
                                             [concat Basic [base64::encode :] ] ]
    if {$proxyauthentication} {
        if {($geturlauthheaders eq $geturlauthheaders_emptynamepwd) || $geturlauthheaders eq ""} {
            inputproxyauthenticationdata
        }
    }
}

proc configureproxyauthenticationheader {} {
# configure the proxy authentication to use the headers or not
# depending on if the user wants proxy authentication or not
# or to be forced to the settings previously input by the user

    global proxyauthentication
    global geturlheaders geturlauthheaders

    if {$proxyauthentication} {
        # authentication requested when connecting to the proxy
        set geturlheaders $geturlauthheaders
    } else {
        # don't use authentication when connecting to the proxy
        set geturlheaders [list ]
    }
}

proc periodiccheckfornewerscipadversion {} {
# if the elapsed time since the previous check is large enough,
# check the web for an updated Scipad, and pop up a message box
# only in case a new version is available, otherwise shut up
# and silently check again later

    global internetpackagesloaded
    global scipadupdatelasttimecheckedsecs scipadupdatecheckinterval

    if {!$internetpackagesloaded} {
        # don't reschedule since it's useless in this Scipad session
        # (the required packages will anyway not be found later in this session)
        return
    }

    set nowsecs [clock seconds]
    set recheckinterval "smallest"

    if {[expr {$nowsecs - $scipadupdatelasttimecheckedsecs}] > [timeintervalsecs $scipadupdatecheckinterval] && \
        $scipadupdatecheckinterval ne "never"} {

        # elapsed time since last check is large enough to allow for a new check

        # call this with "auto" so that the message box will later only show up
        # if there is an updated Scipad available
        set timeittakes [time {set communicationworked [launch_getlatestscipadversioninfofrominternet "auto"] }]
        if {!$communicationworked} {
            # could not contact the web site
            # this may change during the remaining time of this Scipad session,
            # for instance because the user can set working proxy settings,
            # and as a consequence the check is rescheduled (below)
            # however if the check takes too long (i.e. more than 1 s) then the
            # check interval must be longer than the minimum, in order to avoid
            # an apparent freeze of Scipad every [timeintervalsecs "smallest"]
            # (which is a minute)
            # note that ::http::geturl may take a few seconds even with the
            # -command option: it will not return immediately when there is an
            # error such as  "couldn't open socket: no such device or address"
            scan $timeittakes "%d %s" timeittakesms dropthis
            if {$timeittakesms > 1000000} {
                set recheckinterval "onehour"
            }
        } else {
            set scipadupdatelasttimecheckedsecs $nowsecs
        }

    } else {

        # requested time interval has not yet elapsed, simply reschedule (below)

    }

    # repeat the checking with a period equal to the smallest possible
    # time interval so that all values of scipadupdatecheckinterval are covered
    after [expr {[timeintervalsecs $recheckinterval] * 1000}] {periodiccheckfornewerscipadversion}

}

proc userrequestcheckfornewerscipadversion {} {
# check the web for availability of a newer Scipad version
# if there is one show it to the user
# if already up-to-date tell it as well
# otherwise (connection problems...) apologize

    global internetpackagesloaded

    if {!$internetpackagesloaded} {
        messageboxscipadversioncantcheck "At least one package required to access the Internet was not found."
        return
    }

    # call this with "user" so that the message box will later show up
    # whatever the result of the check is
    set communicationworked [launch_getlatestscipadversioninfofrominternet "user"]
    if {!$communicationworked} {
        # nothing to do: there was already a message box
        # in proc launch_getlatestscipadversioninfofrominternet
    }
}

proc launch_getlatestscipadversioninfofrominternet {requesttype} {
# launch a request for finding out what is the latest version
# of Scipad available on the web, and return true
# if there was any issue in retrieving the version info through the
# web then return false - this includes:
#   - no working internet connection
#   - website down
#   - proxy not responding, if a proxy is set (forced or not)
#   - other connection issues

    global pad latestscipadversionURL
    global useaproxy geturlheaders

    # lauch a request to fetch the html data at URL $latestscipadversionURL
    if {[catch {
                 # the geturl line will raise an error if there is no
                 # working Internet connection
                 # note the timeout set to 30s: SourceForge is a really
                 # slow web site!
                 # note: the test here really is  if $useaproxy  and not
                 #       if $proxyauthentication  since the former will
                 #       correctly be used to pass -headers {} when there
                 #       is a proxy with no required authentication (useful
                 #       if the user changed settings between two calls)
                 if {$useaproxy} {
                     ::http::geturl $latestscipadversionURL \
                             -headers $geturlheaders \
                             -command "callback_getlatestscipadversioninfofrominternet $requesttype" \
                             -timeout 30000
                 } else {
                     ::http::geturl $latestscipadversionURL \
                             -command "callback_getlatestscipadversioninfofrominternet $requesttype" \
                             -timeout 30000
                 }
               } returnresult] != 0} {
        if {$requesttype eq "user"} {
            messageboxscipadversioncantcheck "The returned error was:" "\n" $returnresult
        }
        return false
    } else {
        # no error raised, relax and just wait for the callback to trigger
        return true
    }
}

proc callback_getlatestscipadversioninfofrominternet {requesttype token} {
# this callback proc gets executed when the transaction with the Scipad
# website is over (or a timeout occurred)
# it extracts the latest Scipad version numbers found on the web
# and inform the user as required by $requesttype:
#   "auto": only show the "update available" message box (used when
#           periodically and silently checking for updates)
#   "user": show any check result (used on user request for checking)

    global ScipadVersion_major ScipadVersion_minor

    if {[::http::status $token] eq "timeout"} {
        if {$requesttype eq "user"} {
            messageboxscipadversioncantcheck "Timeout occurred."
        }
        ::http::cleanup $token
        return
    }

    set html [::http::data $token]
    ::http::cleanup $token

    # extract version information from the html text, more precisely
    # from the *folder* name found in this html text
    # version details are ignored (if present) because these details are
    # either "" or any text starting with the dash "-" sign, and there
    # is no easy way to use this info to compare versions
# this has changed...!
# flimsy ground... but see http://sourceforge.net/apps/ideatorrent/sourceforge/ideatorrent/idea/874
#    set extractOK [regexp {http://sourceforge.net/projects/scipad/files/scipad-(\d+).(\d+)} $html => latestversion_major latestversion_minor]
    set extractOK [regexp {<a href="/projects/scipad/files/latest/download" title="Download /scipad-(\d+).(\d+)} $html => latestversion_major latestversion_minor]

    if {!$extractOK} {
        # probably the html text was different from what was expected
        if {$requesttype eq "user"} {
            messageboxscipadversioncantcheck "Error when parsing the returned information from the Scipad website."
        }
        return
    }

    if {($ScipadVersion_major eq "") || ($ScipadVersion_minor eq "")} {

        # running in standalone mode with no version numbers set, do nothing
        if {$requesttype eq "user"} {
            messageboxscipadversioncantcheck "No version information locally set (probable reason: Scipad running in standalone mode)."
        }

    } else {

        # latest version info could be retrieved correctly and are stored
        # in latestversion_major and latestversion_minor

        if {(($latestversion_major == $ScipadVersion_major) && ($latestversion_minor > $ScipadVersion_minor)) || \
              ($latestversion_major > $ScipadVersion_major)} {
            messageboxscipadversionnewavailable $latestversion_major $latestversion_minor

        } elseif {($latestversion_major == $ScipadVersion_major) && ($latestversion_minor == $ScipadVersion_minor)} {
            # Scipad version is up-to-date
            if {$requesttype eq "user"} {
                messageboxscipadversionuptodate
            }
        } else {
            # the version on the web is older than the local version
            # (this is not supposed to happen unless you are a Scipad developer)
            if {$requesttype eq "user"} {
                messageboxscipadversioninconsistent
            }
        }
    }

}

proc messageboxscipadversioncantcheck {args} {
# display the message box informing that new Scipad versions can't be checked
# the optional arguments usually are reasons why version checking did not work
# in fact it can be any (number of) string(s)
# each arg of the $args list is supposed to be NOT YET localized when received
# by this proc
    global pad ScipadprojectatSourceForgeURL downloadentrypointatScipadprojectatSourceForgeURL
    set tit [mc "Check for updates"]
    set mes [mc "Unable to check availability of a new version."]
    append mes "\n"
    foreach arg $args {
        append mes [mc $arg]
        append mes " "
    }
    append mes "\n\n"
    append mes [concat [mc "Please visit"] $ScipadprojectatSourceForgeURL ]
    append mes "\n\n"
    append mes [mc "Do you want to attempt connecting to the Scipad website using your default browser?"]
    set answ [tk_messageBox -message $mes -icon warning -title $tit -type yesno -parent $pad]
    switch -- $answ {
        yes {invokebrowser "$downloadentrypointatScipadprojectatSourceForgeURL"}
        no  {}
    }
}

proc messageboxscipadversionuptodate {} {
   global pad
   set tit [mc "Check for updates"]
   set mes [mc "Your version of Scipad is up-to-date."]
   tk_messageBox -message $mes -icon info -title $tit -parent $pad
}

proc messageboxscipadversionnewavailable {webmajor webminor} {
    global pad ScipadprojectatSourceForgeURL downloadentrypointatScipadprojectatSourceForgeURL
    global ScipadVersion_major ScipadVersion_minor ScipadVersion_details
    set tit [mc "Check for updates"]
    set mes [mc "A new version of Scipad is available."]
    append mes "\n\n"
    append mes [concat [mc "Your version of Scipad:"] $ScipadVersion_major.$ScipadVersion_minor ]
    if {$ScipadVersion_details ne ""} {
        append mes " ($ScipadVersion_details)"
    }
    append mes "\n\n"
    append mes [concat [mc "Current version is:"] $webmajor.$webminor ]
    append mes "\n\n"
    append mes [concat [mc "Please visit"] $ScipadprojectatSourceForgeURL [mc "to get it."] ]
    append mes "\n\n"
    append mes [mc "Do you want to browse to this website now?"]
    set answ [tk_messageBox -message $mes -icon info -title $tit -type yesno -parent $pad]
    switch -- $answ {
        yes {invokebrowser "$downloadentrypointatScipadprojectatSourceForgeURL/scipad-$webmajor.$webminor"}
        no  {}
    }
}

proc messageboxscipadversioninconsistent {} {
    global pad
    set tit [mc "Check for updates"]
    set mes [mc "Inconsistent version numbers found."]
    append mes "\n\n"
    append mes [mc "The version from web site is not supposed to be older than your version!"]
    tk_messageBox -message $mes -icon error -title $tit -parent $pad
}

proc timeintervalsecs {intervalname} {
# compute the time interval in seconds corresponding to $intervalname
# these intervals are approximate: no precautions are taken for different
# number of days in different months, who cares, this is used to decide when
# Scipad has to check the web for an update and does not need to be accurate
# in the same spirit, "never" is defined to be 10 years
    switch $intervalname {
        smallest  {set secs [timeintervalsecs oneminute]}
        oneminute {set secs 60}
        onehour   {set secs [expr {60  * [timeintervalsecs oneminute]}]}
        oneday    {set secs [expr {24  * [timeintervalsecs onehour  ]}]}
        oneweek   {set secs [expr {7   * [timeintervalsecs oneday   ]}]}
        onemonth  {set secs [expr {31  * [timeintervalsecs oneday   ]}]}
        oneyear   {set secs [expr {365 * [timeintervalsecs oneday   ]}]}
        never     {set secs [expr {10  * [timeintervalsecs oneyear  ]}]}
    }
    return $secs
}

proc inputproxyhostandport {} {
# let the user enter the proxy host name (or IP address) and port
# depending on the "Autodetect proxy" checkbutton in the Options menu,
# this information will be used or not when connecting to the Internet

    global forcedproxyhost forcedproxyport
    global pad textFont menuFont
    global Tk85

    set iphp $pad.inputproxy
    toplevel $iphp -class Dialog
    wm transient $iphp $pad
    wm withdraw $iphp
    setscipadicon $iphp
    wm title $iphp [mc "Proxy settings"]

    frame $iphp.f

    frame $iphp.f.f1

    set tl [mc "Proxy name or IP address:"]
    label $iphp.f.f1.label -text $tl -font $menuFont
    entry $iphp.f.f1.entry -width 20 -font $textFont
    grid $iphp.f.f1.label -row 0 -column 0 -sticky we
    grid $iphp.f.f1.entry -row 0 -column 1 -sticky we
    grid columnconfigure $iphp.f.f1 1 -weight 1

    set tl [mc "Proxy port:"]
    label $iphp.f.f1.label2 -text $tl -font $menuFont
    entry $iphp.f.f1.entry2 -width 20 -font $textFont
    grid $iphp.f.f1.label2 -row 1 -column 0 -sticky we
    grid $iphp.f.f1.entry2 -row 1 -column 1 -sticky we

    pack $iphp.f.f1 -expand 1 -fill x

    frame $iphp.f.f9

    button $iphp.f.f9.buttonOK -text "OK" -font $menuFont \
            -command "set forcedproxyhost \[$iphp.f.f1.entry get\] ; \
                      set forcedproxyport \[$iphp.f.f1.entry2 get\] ; \
                      configureproxyhostandport ; \
                      destroy $iphp"
    eval "button $iphp.f.f9.buttonCancel [bl "Cance&l"] -font \[list $menuFont\] \
           -command \"destroy $iphp\" "
    grid $iphp.f.f9.buttonOK     -row 0 -column 0 -sticky we -padx 10
    grid $iphp.f.f9.buttonCancel -row 0 -column 1 -sticky we -padx 10
    grid columnconfigure $iphp.f.f9 0 -uniform 1
    grid columnconfigure $iphp.f.f9 1 -uniform 1
    if {$Tk85} {
        grid anchor $iphp.f.f9 center
    }
    pack $iphp.f.f9 -expand 1 -fill x -pady 4

    pack $iphp.f -expand 1 -fill x

    bind $iphp <Return> "$iphp.f.f9.buttonOK invoke"
    bind $iphp <Escape> "$iphp.f.f9.buttonCancel invoke"

    bind $iphp <Alt-[fb $iphp.f.f9.buttonCancel]> "$iphp.f.f9.buttonCancel invoke"

    $iphp.f.f1.entry delete 0 end
    $iphp.f.f1.entry insert end $forcedproxyhost
    $iphp.f.f1.entry2 delete 0 end
    $iphp.f.f1.entry2 insert end $forcedproxyport
    focus $iphp.f.f1.entry

    $iphp.f.f1.entry selection range 0 end

    # this update is required for the width and height to be taken into account in minsize
    update idletasks
    grab $iphp
    setwingeom $iphp
    wm resizable $iphp 1 0
    wm minsize $iphp [winfo width $iphp] [winfo height $iphp]
    wm deiconify $iphp
}

proc inputproxyauthenticationdata {} {
# let the user enter its user name and password related to the proxy
# and build the authentication header that will later be used by http::geturl
# note that on windows the domain may be needed and shall then be input
# as  DOMAIN\USERNAME  (note the single antislash, it is not interpreted
# as an escape when input in the entry)
# depending on the "Autodetect proxy" checkbutton in the Options menu,
# this information will be used or not when connecting to the Internet

    global geturlauthheaders
    global pad textFont menuFont
    global Tk85

    set ipup $pad.inputproxy
    toplevel $ipup -class Dialog
    wm transient $ipup $pad
    wm withdraw $ipup
    setscipadicon $ipup
    wm title $ipup [mc "Proxy authentication settings"]

    frame $ipup.f

    frame $ipup.f.f1

    set tl [mc "User name:"]
    label $ipup.f.f1.label -text $tl -font $menuFont
    entry $ipup.f.f1.entry -width 20 -font $textFont
    grid $ipup.f.f1.label -row 0 -column 0 -sticky we
    grid $ipup.f.f1.entry -row 0 -column 1 -sticky we
    grid columnconfigure $ipup.f.f1 1 -weight 1

    set tl [mc "Password:"]
    label $ipup.f.f1.label2 -text $tl -font $menuFont
    entry $ipup.f.f1.entry2 -width 20 -font $textFont -show * 
    grid $ipup.f.f1.label2 -row 1 -column 0 -sticky we
    grid $ipup.f.f1.entry2 -row 1 -column 1 -sticky we

    pack $ipup.f.f1 -expand 1 -fill x

    frame $ipup.f.f9

    button $ipup.f.f9.buttonOK -text "OK" -font $menuFont \
            -command " set geturlauthheaders \[list Proxy-Authorization \
                                                   \[concat Basic \[base64::encode \[$ipup.f.f1.entry get\]:\[$ipup.f.f1.entry2 get\]\]\] \] ; \
                       configureproxyauthenticationheader ; \
                       destroy $ipup"
    eval "button $ipup.f.f9.buttonCancel [bl "Cance&l"] -font \[list $menuFont\] \
           -command \"destroy $ipup\" "
    grid $ipup.f.f9.buttonOK     -row 0 -column 0 -sticky we -padx 10
    grid $ipup.f.f9.buttonCancel -row 0 -column 1 -sticky we -padx 10
    grid columnconfigure $ipup.f.f9 0 -uniform 1
    grid columnconfigure $ipup.f.f9 1 -uniform 1
    if {$Tk85} {
        grid anchor $ipup.f.f9 center
    }
    pack $ipup.f.f9 -expand 1 -fill x -pady 4

    pack $ipup.f -expand 1 -fill x

    bind $ipup <Return> "$ipup.f.f9.buttonOK invoke"
    bind $ipup <Escape> "$ipup.f.f9.buttonCancel invoke"

    bind $ipup <Alt-[fb $ipup.f.f9.buttonCancel]> "$ipup.f.f9.buttonCancel invoke"

    focus $ipup.f.f1.entry

    # this update is required for the width and height to be taken into account in minsize
    update idletasks
    grab $ipup
    setwingeom $ipup
    wm resizable $ipup 1 0
    wm minsize $ipup [winfo width $ipup] [winfo height $ipup]
    wm deiconify $ipup
}
