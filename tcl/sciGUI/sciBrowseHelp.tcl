# sciBrowseHelp.tcl
# Browse help GUI
# This file is part of sciGUI toolbox
# Copyright (C) 2004 Jaime Urzua Grez
# mailto:jaime_urzua@yahoo.com
# rev. 0.2 - 2004/06/23


# sciGUI
# Copyright (c) 2004 Jaime Urzua Grez
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

set BWpath [file dirname "$env(SCIPATH)/tcl/BWidget-1.7.0"]
 if {[lsearch $auto_path $BWpath]==-1} {
     set auto_path [linsert $auto_path 0 $BWpath]
 }

set scilabpath $SciPath
package require BWidget 1.7.0

lappend ::auto_path [file dirname  "$env(SCIPATH)/tcl/BWidget-1.7.0"]
namespace inscope :: package require BWidget

global Gifpath
set Gifpath "$env(SCIPATH)/macros/scicos/scicos_doc/man/gif_icons"

# ----------------------------------------------------------------------------
# Function    : sciGUIBroeseHelpINI
# Parameters  :
# Description : Initialice
# ----------------------------------------------------------------------------
proc sciGUIBrowseHelpINI { } {
        global sciGUITable      
        set sciGUITable(browsehelp,nchap) 0
        set sciGUITable(browsehelp,curid) 0
        set sciGUITable(browsehelp,nitems) 0
        set sciGUITable(browsehelp,filelist) ""
        set sciGUITable(browsehelp,mode) 0
        set sciGUITable(browsehelp,last_0) 0
        set sciGUITable(browsehelp,last_1) 0
        set sciGUITable(browsehelp,last_2) 0
}



# ----------------------------------------------------------------------------
# Function    : sciGUIBrowseHelpParseFile
# Parameters  : 
# Description : Initialice
# ----------------------------------------------------------------------------
proc sciGUIBrowseHelpParseFile { } {
        global sciGUITable
        set sciGUITable(browsehelp,curid) 0
        set sciGUITable(browsehelp,nitems) 0
        set fid [open $sciGUITable(browsehelp,filelist) r]
        set p 1
        set var1 ""; set var2 ""; set var3 ""; set var4 ""
        while { [eof $fid]==0 } {
                gets $fid lineRead
                set lineRead [string trimleft "$lineRead"]
                set var$p $lineRead
                incr p
                if { $p==5 } {
                        set posInTable [expr $sciGUITable(browsehelp,nitems)+1]
                        set sciGUITable(browsehelp,$posInTable,Deep) $var1


                        # Convert special characters in function name for index display
                        # Special characters handled: &apos; &quot; &amp; &gt; &lt; 
                        regsub -all -nocase -- {\&apos;} $var2 {'} var2
                        regsub -all -nocase -- {\&quot;} $var2 {"} var2
                        regsub -all -nocase -- {\&amp;} $var2 {\&} var2
                        regsub -all -nocase -- {\&gt;} $var2 {>} var2
                        regsub -all -nocase -- {\&lt;} $var2 {>} var2
                        set sciGUITable(browsehelp,$posInTable,Name) $var2
                        set sciGUITable(browsehelp,$posInTable,URL) $var3


                        # Convert special characters in function description for index display
                        # Special characters handled: &apos; &quot; &amp; &gt; &lt; 
                        regsub -all -nocase -- {\&apos;} $var4 {'} var4
                        regsub -all -nocase -- {\&quot;} $var4 {"} var4
                        regsub -all -nocase -- {\&amp;} $var4 {\&} var4
                        regsub -all -nocase -- {\&gt;} $var4 {>} var4
                        regsub -all -nocase -- {\&lt;} $var4 {>} var4
                        set sciGUITable(browsehelp,$posInTable,Extra) $var4
                        set sciGUITable(browsehelp,$posInTable,Status) 0
                        set sciGUITable(browsehelp,nitems) $posInTable
                        set var1 ""; set var2 ""; set var3 ""; set var4 ""; set p 1
                }
        }
        close $fid
}



# ----------------------------------------------------------------------------
# Function    : sciGUIBrowseHelpChange
# Parameters  : winId
# Description : Change the state in the tree
# ----------------------------------------------------------------------------
proc sciGUIBrowseHelpChange { winId } {
        global sciGUITable
        set id $sciGUITable(browsehelp,curid)
        set tmp $sciGUITable(browsehelp,$id,Status)
        set sciGUITable(browsehelp,$id,Status) 0
        if { $tmp == 0 } { set sciGUITable(browsehelp,$id,Status) 1 }
        sciGUIBrowseHelpShowTree $winId
}



# ----------------------------------------------------------------------------
# Function    : sciGUIBrowseHelpShowTree
# Parameters  : winId
# Description : Draw tree
# ----------------------------------------------------------------------------
proc sciGUIBrowseHelpShowTree { winId } {
        global sciGUITable
        set w "[sciGUIName $winId]"
#        set w "[sciGUIName $winId].l.b.tree"

        set pw1 $w.pw
        set pane [$pw1 getframe 0]
        set sw $pane.sw
        set lb $sw.l
        set w $lb.b.tree

        $w delete all
        set yLocal 0
        set lastDeep -1
        set lastStatus 1
        set gethtml 0
        for {set item 1} { $item<=$sciGUITable(browsehelp,nitems) } { incr item } {
                set curIcon "File" 
                set itemDeep $sciGUITable(browsehelp,$item,Deep)
                set isFolder 0
                set itemStatus $sciGUITable(browsehelp,$item,Status)
                if { $item < $sciGUITable(browsehelp,nitems) } {
                        set nextDeep $sciGUITable(browsehelp,[expr $item+1],Deep)
                        set IsOpen $sciGUITable(browsehelp,$item,Status)
                        if  { $nextDeep > $itemDeep } {
                                set isFolder 1
                                set curIcon "OpenBook"
                                if { $itemStatus == 0 } { set curIcon "ClosedBook" }
                        }
                }

                set disp $lastStatus
                if { $itemDeep <= $lastDeep } {
                        set lastDeep $itemDeep
                        set lastStatus 1
                        set disp 1
                }

                if { [expr $lastStatus*$isFolder] == 1 } {
                        set lastStatus $IsOpen
                        set lastDeep $itemDeep
                        set disp 1
                }


                set extra ""


                if { $sciGUITable(browsehelp,mode)==1 } {
                        set disp 0
                        set itemDeep 0
                        set toFind $sciGUITable(win,$winId,data,labFind)
                        set st "$sciGUITable(browsehelp,$item,Name) $sciGUITable(browsehelp,$item,Extra)"
                        if { $toFind!="" } {
                                if { [regexp -nocase "$toFind" "$st"] } {
                                        if { $isFolder==1 } { 
                                                set curIcon "ClosedBook"
                                        } else {
                                                set curIcon "File" 
                                        }
                                        set disp 1
                                        set extra $sciGUITable(browsehelp,$item,Extra)
                                        if { $toFind==$sciGUITable(browsehelp,$item,Name) & $sciGUITable(browsehelp,last_2)} {
                                                set sciGUITable(browsehelp,curid) $item
                                                set sciGUITable(browsehelp,last_2) 0
                                        }

                                }
                        }
                }

                if { $disp == 1 } {
                        set y [expr 15+18*$yLocal]
                        incr yLocal
                        set x [expr 5+$itemDeep*20]
                        set k0 [$w create image $x $y -image sciGUITable(icon,$curIcon) -anchor w]
                        set fc black
                        if { $sciGUITable(browsehelp,curid) == $item } {
                                set fc red
                                set gethtml $item
                        }

                        set txt $sciGUITable(browsehelp,$item,Name)
                        set k1 [$w create text [expr $x+20] $y -text "$txt $extra" -anchor w -fill $fc]
                        $w bind $k0 <1> "set sciGUITable(browsehelp,curid) $item; sciGUIBrowseHelpChange $winId"
                        $w bind $k1 <1> "set sciGUITable(browsehelp,curid) $item; sciGUIBrowseHelpChange $winId"
                }
        }
        $w config -scrollregion [$w bbox all]
        if { $gethtml > 0 } {
                help::init $sciGUITable(browsehelp,$gethtml,URL)
        }
        # 1 LINE ADDED BY FRANCOIS VOGEL, 03/04/05 - Implements Scilab request 106
        focus $w
}



# ----------------------------------------------------------------------------
# Function    : sciGUIBrowseHelpFind
# Parameters  : winId
# Description : Find
# ----------------------------------------------------------------------------
proc sciGUIBrowseHelpChangeMode { winId {force ""} } {
        global sciGUITable
        set w "[sciGUIName $winId]"
        #set btname "[sciGUIName $winId].l.t.butFind"
        #set laname "[sciGUIName $winId].l.t.labFind"

        set pw1 $w.pw
        set pane [$pw1 getframe 0]
        set sw $pane.sw
        set lb $sw.l

        set btname "$lb.t.butFind"
        set laname "$lb.t.labFind"

        set go 1
        while { $go==1 } {
                if  { $sciGUITable(browsehelp,mode)==0 } {
                        $btname configure -image sciGUITable(icon,iconViewTree)
                        set sciGUITable(browsehelp,last_0) $sciGUITable(browsehelp,curid)
                        set sciGUITable(browsehelp,mode) 1
                        set sciGUITable(browsehelp,curid) $sciGUITable(browsehelp,last_1)
                        set g0 [entry $laname -textvariable sciGUITable(win,$winId,data,labFind)]
                        bind $g0 <Return> "sciGUIBrowseHelpShowTree $winId"
                        pack $laname -side right -fill x -expand 1 -padx 5

                } else {
                        $btname configure -image sciGUITable(icon,iconFind)
                        set sciGUITable(browsehelp,last_1) $sciGUITable(browsehelp,curid)
                        set sciGUITable(browsehelp,mode) 0
                        set sciGUITable(browsehelp,curid) $sciGUITable(browsehelp,last_0)
                        catch {destroy $laname}
                }

                if { $force!="" } {
                        if {$sciGUITable(browsehelp,mode)==$force} {
                                set go 0
                        }
                } else {
                        set go 0
                }
        }
}



# ----------------------------------------------------------------------------
# Function    : sciGUIBrowseHelpQuit
# Parameters  : winId
# Description : Destroy help widget but keep the help information
# ----------------------------------------------------------------------------
proc sciGUIBrowseHelpQuit { winId } {
        global sciGUITable
        catch {unset sciGUITable(win,$winId,data,labFind)}
        ::help::destroy
        sciGUIDestroy $winId
}



# ----------------------------------------------------------------------------
# Function    : sciGUIBrowseHelp
# Parameters  : winId update filelist initialfile
# Description : BrowseHelp widget
# ----------------------------------------------------------------------------
proc sciGUIBrowseHelp { {winId -1} update filelist {toFind ""} } {
        global sciGUITable
        global Gifpath
        set create 1
        foreach winId2 $sciGUITable(win,id) {
                if { [sciGUIGetType $winId2]=="browsehelp" } { set create 0; break; }
        }
        if { $create==1 } {
                set winId2 [sciGUICreate $winId "browsehelp" ]
                set w [sciGUIName $winId2]
                wm title $w "ScicosLab Browse Help ($winId2)"
                wm protocol $w WM_DELETE_WINDOW "sciGUIBrowseHelpQuit $winId2"
                $w configure -background white
                frame $w.top -bd 0 -background white
                label $w.top.logo -image [image create photo -file "$Gifpath/puffin-gtk48.gif"] \
                                  -bg white
                label $w.top.mes01 -text "Browse Help" -font $sciGUITable(font,1) -bg white
                pack $w.top -expand 0 -pady [list 2m 2m]
                pack $w.top.logo -side left
                pack $w.top.mes01 -side right

                set pw1   [PanedWindow $w.pw -bg white]
                set pane  [$pw1 add]
                set pw2   [PanedWindow $pane.pw -side left]
                set pane1 [$pw2 add -weight 1]
                set pane2 [$pw1 add -weight 1000]

                set sw [ScrolledWindow $pane.sw -borderwidth 0]
                set lb [ScrollableFrame $sw.l -background white]
                frame $lb.t -bd 0 -background white
                frame $lb.b -bd 0 -background white

                set sciGUITable(win,$winId,data,labFind) ""
                #set g0 [entry $w.l.t.labFind -textvariable sciGUITable(win,$winId2,data,labFind)]
                #bind $g0 <Return> "sciGUIBrowseHelpShowTree $winId2"

                button $lb.t.butFind -width 20 -height 20 -image sciGUITable(icon,iconFind) \
                                     -command "sciGUIBrowseHelpChangeMode $winId2; sciGUIBrowseHelpShowTree $winId2"
                #pack $w.l.t.labFind -side right -fill x -expand 1 -padx 5
                pack $lb.t.butFind -side left -expand 0

                canvas $lb.b.tree -width 150 -height 1850 -bd 1 -background LightGray -relief sunken \
                                  -yscrollcommand "$lb.b.sb set" -highlightthickness 0
                scrollbar $lb.b.sb -command "$lb.b.tree yview"

                pack $lb.b.sb -side right -fill y
                pack $lb.b.tree -fill both -expand 1

                pack $lb.t -side top -fill x -expand 1 -padx [list 1m 0] -pady [list 0 1m]
                pack $lb.b -side top -fill both -expand 1 -padx [list 1m 0] -pady [list 0 1m]
                $sw setwidget $lb

                pack $sw -fill both -expand yes

                set sw [ScrolledWindow $pane2.sw -relief sunken -borderwidth 0]
                set sf [ScrollableFrame $sw.f]
                $sw setwidget $sf

                # 3 BINDINGS ADDED BY FRANCOIS VOGEL, 03/04/05 - Implements Scilab request 106
                bind $lb.b.tree <Enter> {focus %W}
                bind $lb.b.tree <Leave> "focus $sf.f.text"
                bind $lb.b.tree <MouseWheel> {
                    set w [winfo toplevel %W] ; \
                    set pw1 $w.pw ; \
                    set pane [$pw1 getframe 0] ; \
                    set sw $pane.sw ; \
                    set lb $sw.l ; \
                    set fra [$lb.b.sb get] ; \
                    if {[lindex $fra 0]!="0.0" || [lindex $fra 1]!="1.0"} { \
                        %W yview scroll [expr {-(%D/120)}] units \
                    }
                }
                bind $lb.b.tree <Button-4> {
                    set w [winfo toplevel %W] ; \
                    set pw1 $w.pw ; \
                    set pane [$pw1 getframe 0] ; \
                    set sw $pane.sw ; \
                    set lb $sw.l ; \
                    set fra [$lb.b.sb get] ; \
                    if {[lindex $fra 0]!="0.0"} { \
                        %W yview scroll -1 units \
                    }
                }
                bind $lb.b.tree <Button-5> {
                    set w [winfo toplevel %W] ; \
                    set pw1 $w.pw ; \
                    set pane [$pw1 getframe 0] ; \
                    set sw $pane.sw ; \
                    set lb $sw.l ; \
                    set fra [$lb.b.sb get] ; \
                    if {[lindex $fra 1]!="1.0"} { \
                        %W yview scroll 1 units \
                    }
                }
                pack $sw -fill both -expand yes -padx [list 1m 1m]

                pack $pw2 $pw1 -fill both -expand yes

                set sciGUITable(browsehelp,filelist) $filelist
                set myIni [file join $sciGUITable(internal,path) "tcl" "sciGUI" "data" "initial.help"]
                wm iconphoto $w [image create photo -file "$Gifpath/puffin-gtk48.gif"]
                help::init $myIni initial $sf 350 350
        }

        if { $update==1 } { sciGUIBrowseHelpParseFile }
        if { $toFind!="" } {
                set sciGUITable(win,$winId2,data,labFind) $toFind
                set sciGUITable(browsehelp,last_2) 1
                sciGUIBrowseHelpChangeMode $winId2 1
        }
        sciGUIBrowseHelpShowTree $winId2
}
