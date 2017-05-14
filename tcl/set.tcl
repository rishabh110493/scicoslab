############################################
# TKSCILAB Gui Interface facility for Scilab
# Bertrand Guiheneuf - 1998 
############################################
#
# -->   set.tcl

proc GetGoodValue { h val} {
    global Win
    global STRING_$h
    
    set mystring STRING_$h
    if {[array exists $mystring] == 1} {
  	set size [array size $mystring]
  	set tmp ""
	set tab $mystring
	
	set sizlist [array size $mystring]
        set sortedlist [lsort [array names $mystring]]
	
	set index [expr $sizlist-1]
	set aa [lindex $sortedlist $index]

	set aa [split $aa ',']
	
	set xsize [lindex $aa 0]
	set ysize [lindex $aa 1]
	
	if { $xsize == 1} {
	    for {set i 1} {$i<=$size} {incr i} { 
		set aa $mystring\(1,$i\)
		set bb $$aa
		lappend tmp [expr $bb]
	    }
	    set tmp [join $tmp "|"]
	    return $tmp
	} elseif {  $ysize == 1} {
	    for {set i 1} {$i<=$size} {incr i} { 
		set aa $mystring\($i,1\)
		set bb $$aa
		lappend tmp [expr $bb]
	    }
	    set tmp [join $tmp "|"]
	    return $tmp
	} else {
	    ScilabEval "disp(\'wrong input : a matrix has been entered\')";
	    return $val
	}
    } else {
	return $val
    }
}


######################################################################################
proc SetField { handle field value } {
    # This the procedure we use to call the 
    # "set..." func. There is 
    # a default behaviour when there is no
    # specific function associated to $field, it
    # only sets the field "field" of the control corresponding
    # to handle "handle" to the *string* "value"

    global Win;
    set name $Win($handle);
    global "$name";
    
    if { $field == "string" } {
	set value [GetGoodValue $handle $value]
    }
    
    set control [set "$name\(control)"];
    set handle [GetRealParent $handle $control];
    set style [set "$name\(style)"];
    

    switch -exact -- $style {

	# The way menu properties are managed
	# is a bit different so we call a specific 
	# set procedure.
	uimenu {
	    menuSetField $handle $field $value;
	}
	
	figure {
	    # implemented fields
	    set KnownFunc  { backgroundcolor callback fontangle fontname fontsize \
		    fontweight fontunits foregroundcolor horizontalalignment listboxtop max min \
		    parent position string units value figure_name verticalalignment };
	    
	    # is it an implemented?
	    set idx  [lsearch $KnownFunc $field];
	    
	    if { $idx != -1} {
		# YES there is a specific behaviour
		# call the specific setfield
		"Set$field" $name $value;    
		
		set path [set "$name\(path)"];
		
	    } else {
		# NO
		# then just set the array 
		set "$name\($field)" $value;
	    }
	}
	
    
	default {
	    # implemented fields
	    set KnownFunc  { backgroundcolor callback fontangle fontname fontsize \
		    fontweight fontunits foregroundcolor horizontalalignment listboxtop max min \
		    parent position string sliderstep units value figure_name verticalalignment };

	    # is it an implemented?
	    set idx  [lsearch $KnownFunc $field];
	    
	    if { $idx != -1} {
		# YES there is a specific behaviour
		# call the specific setfield
		"Set$field" $name $value;    # param = (name, str) dans Setstring 
		
		set path [set "$name\(path)"];
		bind $path <Configure> {ChgConfigure %W %w %h};
	    } else {
		# NO
		# then just set the array 
		set "$name\($field)" $value;
	    }
	}
 
   }

}
	










######################################################################################
#######      Specific answers to the set command
######################################################################################




######################################################################################
proc Setfont { name } {

    global "$name" Win
    set path [set "$name\(path)"];
    set style [set "$name\(style)"];
    
    #set validStyles { pushbutton edit text listbox popupmenu };
    set validStyles { pushbutton edit text listbox popupmenu };
    # is it an implemented?
    set idx  [lsearch $validStyles $style];
    if { $idx == -1 } { return }


    set fa(normal) "r";
    set fa(italic) "i";
    set fa(oblique) "o";
    set fa(*) "*";

    set fw(normal) medium;
    set fw(light) medium;
    set fw(bold) bold;
    set fw(demi) bold;
    set fw(*) "*";
    
    # get the real path which send the configure 
    set fpath $path;
    if {[string compare $style listbox]==0 } { set fpath $path.list }
   
    
    foreach prop { fontangle fontname fontsize  fontweight } {  
	if {[info exist "$name\($prop)"]==1} {
	    set "$prop" [set "$name\($prop)"];
	} else {
	    set "$prop" "*";
	}
    }
    set fu [set "$name\(fontunits)"];
    switch -exact -- $fu {
	pixels {
	    
	    if { [string compare $fontsize "*"] != 0 } {set fontsize [expr round($fontsize)];}
	    set font "-*-$fontname-$fw($fontweight)-$fa($fontangle)-*-*-$fontsize-*-*-*-*-*-*-*";
	    if { [catch { $fpath configure -font $font }] == 0 } { return; }
	    $fpath configure -font fixed;
	}

	points {
	    if { [string compare $fontsize "*"] != 0 } {set fontsize [expr round($fontsize)];}
	    set font "-*-$fontname-$fw($fontweight)-$fa($fontangle)-*-*-*-$fontsize-*-*-*-*-*-*" 
	    if { [catch { $fpath configure -font $font }] == 0 } { return; }
	    $fpath configure -font fixed;
	}
 
	normalized {
	    if { [string compare  fontsize "*"]!=0 } {
		set hparent [ set "$name\(parent)"];
		set parent $Win($hparent);
		global $parent;
		set width [ winfo  width $path ]; if {[ info exist "$name\(w)"]} { set width [set "$name\(w)"]; };
		set height  [ winfo height $path ];if {[ info exist "$name\(h)"]} { set height [set "$name\(h)"]; };
		set size $height; 
		set fontsize [expr round($size * $fontsize)];
	    }   
	    set font "-*-$fontname-$fw($fontweight)-$fa($fontangle)-*-*-$fontsize-*-*-*-*-*-*-*" 
	    
	    set fpath $path;
	    if {[string compare $style listbox]==0 } { set fpath $path.list }
	    if { [catch { $fpath configure -font $font }] == 0 } { return; }
	    $fpath configure -font fixed;
	
	}
	
    }
}


######################################################################################
proc Setbackgroundcolor { name value } {

    global "$name";
    set path [set "$name\(path)"];
    set "$name\(backgroundcolor)" $value;
    
    
    set color [split $value "|"];
    
    
    set r [expr [lindex $color 0] *255];
    set g [expr [lindex $color 1] *255];
    set b [expr [lindex $color 2] *255];
 
    set cr [format "%02x" [expr round($r) ]];
    set cg [format "%02x" [expr round($g) ]];
    set cb [format "%02x" [expr round($b) ]];
    
    
    set rdis [expr $r/2;];
    set gdis [expr $g/2;];
    set bdis [expr $b/2;];
    
    set crdis [format "%02x" [expr round($rdis) ]];
    set cgdis [format "%02x" [expr round($gdis) ]];
    set cbdis [format "%02x" [expr round($bdis) ]];
    
    
    
    set "$name\(disablebackgroundcolor)" "#$crdis$cgdis$cbdis";
    
 
    set style [set "$name\(style)"];
    switch -exact -- $style {
	listbox {
	    $path.list configure -background "#$cr$cg$cb";
	    $path configure -background "#$cr$cg$cb";
	}
	default {
	    $path configure -background "#$cr$cg$cb";
	}
    }
 }

######################################################################################
proc Setforegroundcolor { name value } {

    global "$name";
    set path [set "$name\(path)"];
    set "$name\(foregroundcolor)" $value;
    
    
    set color [split $value "|"];
    
    
    set r [expr [lindex $color 0] *255];
    set g [expr [lindex $color 1] *255];
    set b [expr [lindex $color 2] *255];
 
    set cr [format "%02x" [expr round($r) ]];
    set cg [format "%02x" [expr round($g) ]];
    set cb [format "%02x" [expr round($b) ]];
    
    
    set rdis [expr $r/2;];
    set gdis [expr $g/2;];
    set bdis [expr $b/2;];
    
    set crdis [format "%02x" [expr round($rdis) ]];
    set cgdis [format "%02x" [expr round($gdis) ]];
    set cbdis [format "%02x" [expr round($bdis) ]];
    
    
    
    set "$name\(disableforegroundcolor)" "#$crdis$cgdis$cbdis";
    
 
    set style [set "$name\(style)"];
    switch -exact -- $style {
	listbox {
	    $path.list configure -foreground "#$cr$cg$cb";
	    $path configure -foreground "#$cr$cg$cb";
	}
	default {
	    $path configure -foreground "#$cr$cg$cb";
	}
    }
 }


######################################################################################
proc Setcallback { name callback } {
# set the call back command of a control
# (calls SciCallback)

  global "$name";
  set path [set "$name\(path)"];

  set command "SciCallback $name $callback";
    
  set "$name\(callback)" $callback;
    
    set style [set "$name\(style)"];
    switch -exact -- $style {
	
	edit {$path configure -command $command;}
	pushbutton {$path configure -command $command;}
	radiobutton  {$path configure -command $command;}
	checkbox  {$path configure -command $command;}
	slider {
	    set command "SliderSciCallback $name $callback";
	    $path configure -command $command;
	}
	listbox {$path.list configure -command $command;}
	
    }	

}



######################################################################################
proc Setfontangle { name value } {
# set the font propoerties of  a control


  global "$name";
  set path [set "$name\(path)"];

  set "$name\(fontangle)" $value;
  Setfont $name;
}

  
######################################################################################
proc Setfontname { name value } {
# set the font propoerties of  a control


  global "$name";
  set path [set "$name\(path)"];

  set "$name\(fontname)" $value;
  Setfont $name;
}

######################################################################################
proc Setfontsize { name value } {
# set the font propoerties of  a control

  global "$name";
  set path [set "$name\(path)"];
    
  #set value [expr round($value)];
  set "$name\(fontsize)" $value;
  Setfont $name;
}



######################################################################################
proc Setfontweight { name value } {
# set the font propoerties of  a control


  global "$name";
  set path [set "$name\(path)"];

  set "$name\(fontweight)" $value;
  Setfont $name;
}

  
######################################################################################
proc Setfontunits { name value } {
# set the font propoerties of  a control

  global "$name";
  set path [set "$name\(path)"];

  set "$name\(fontunits)" $value;
  Setfont $name;
}

  



######################################################################################
proc Sethorizontalalignment { name value } {

 global "$name" HorizontalAnchorEq;
 global "$name" VerticalAnchorEq;
 set path [set "$name\(path)"];
 set "$name\(horizontalalignment)" $value;
 set style [set "$name\(style)"];
 
 if {[string compare $value "center"] != 0} {
     if {[info exist "$name\(verticalalignment)"] == 1} {
	 set vanchor $VerticalAnchorEq([set "$name\(verticalalignment)"]);
	 if {[string compare $vanchor "center"] == 0} {
	      set anchor $HorizontalAnchorEq($value);
	 } else {
	     set anchor $vanchor$HorizontalAnchorEq($value);
	 }
     } else {
	 set anchor $HorizontalAnchorEq($value);
     }
 } else {
     if {[info exist "$name\(verticalalignment)"] == 1} {
	 set anchor $VerticalAnchorEq([set "$name\(verticalalignment)"]);
     } else {
	 set anchor "center";
     }
 }

 # Warning messages
 if {[string equal $value "e"] != 0} {
     ScilabEval "warning(\"Obsolete horizontal alignment \"\"e\"\", use \"\"right\"\" instead\")";
 }
 if {[string equal $value "w"] != 0} {
     ScilabEval "warning(\"Obsolete horizontal alignment \"\"w\"\", use \"\"left\"\" instead\")";
 }
 
     switch -exact -- $style {
	text {$path configure -anchor $anchor}
	edit {$path configure -justify $value}
	radiobutton {$path configure -anchor $anchor}
	checkbox {$path configure -anchor $anchor}
	#listbox {$path.list configure -anchor $AnchorEq($value)}
    }

}

######################################################################################
proc Setverticalalignment { name value } {

 global "$name" HorizontalAnchorEq;
 global "$name" VerticalAnchorEq;
 set path [set "$name\(path)"];
 set "$name\(verticalalignment)" $value;
 set style [set "$name\(style)"];

 if {[string compare $VerticalAnchorEq($value) "center"] != 0} {
     if {[info exist "$name\(horizontalalignment)"] == 1} {
	 set hanchor $HorizontalAnchorEq([set "$name\(horizontalalignment)"]);
	 set anchor $VerticalAnchorEq($value)$hanchor;
     } else {
	 set anchor $VerticalAnchorEq($value);
     }
 } else {
     if {[info exist "$name\(horizontalalignment)"] == 1} {
	 set anchor $HorizontalAnchorEq([set "$name\(horizontalalignment)"]);
	 if {[string compare $anchor {}] == 0} {
	     set anchor "center";
	 } 
     } else {
	 set anchor "center";
     }
 }


 # Warning messages
 if {[string equal $value "center"] != 0} {
     ScilabEval "warning(\"Obsolete vertical alignment \"\"center\"\", use \"\"middle\"\" instead\")";
 }
 
    switch -exact -- $style {
	text {$path configure -anchor $anchor}
	edit { unset "$name\(verticalalignment)"}
	radiobutton {$path configure -anchor $anchor}
	checkbox {$path configure -anchor $anchor}
	#listbox {$path.list configure -anchor $AnchorEq($value)}

    }

}

######################################################################################
proc Setlistboxtop { name value } {
global "$name";
 set path [set "$name\(path)"];
 set "$name\(listboxtop)" $value;
 set style [set "$name\(style)"];
    
    switch -exact -- $style {
	listbox {$path.list yview $value}
	
    }

}




######################################################################################
proc Setmax { name  value} {
# Max field of a control


  global "$name";
  set path [set "$name\(path)"];

  
  set "$name\(max)" $value;
  set style [set "$name\(style)"];

  switch -exact -- $style {
    "radiobutton" { $path configure -value $value }
    "checkbox" { $path configure -onvalue $value }
    "slider" { $path configure -to $value }
    "listbox" {
	$path.list configure -selectmode single;
	if {[info exist "$name\(min)"] == 1} {
	    set diff [expr $value- [set "$name\(min)"]];
	    if {$diff >1} { 
		$path.list configure -selectmode extended;
	    }
	}
    }
    default {
    }
  }
  

}

######################################################################################
proc Setmin { name  value} {
# Min field of a control


  global "$name";
  set path [set "$name\(path)"];

  
  set "$name\(min)" $value;
  set style [set "$name\(style)"];

  switch -exact -- $style {
    "radiobutton" { $path configure -value $value }
    "checkbox" { $path configure -offvalue $value }
    "slider" { $path configure -from $value }
    "listbox" {
	$path.list configure -selectmode single;
	if {[info exist "$name\(max)"] == 1} {
	    set diff [expr [set "$name\(max)"] - $value];
	    if {$diff >1} { 
		$path.list configure -selectmode extended;
	    }
	}
    }
    default {
    }
  }
  

}


######################################################################################
proc Setparent { name handle } {
    # set Parent field of a control 
    # this routine is also used to create an uicontrol
    # it is also used to change control's parent. 
    #
    # input : 'name' variable name of the control
    #         'handle' parent handle
    # output : void

    global "$name" gcf;
    set rdrw 0;

    # if the control already exist, then destroy it
    # and put the redraw flag on. This is used to 
    # allow th user to change control's parent at runtime
    if {[info exists "$name\(path)"]} {  
	set path [set "$name\(path)"];
	set rdrw 1;
	if [winfo exist $path] { destroy $path }
    }

    # we have to round the handle value
    # to prevent any numerical bias introduced 
    # by scilab from killing tk
    set handle [expr round($handle)];
    set style [set "$name\(style)"];     # scilab's control style
    set control [set "$name\(control)"]; # tk's control style
  
    global Win;
    # get the parent's name
    set parent "$Win($handle)";
  
    # create the real name and path of the control
    # This has to be done because of the . which is the main win.
    # and would otherwise produce ..obj$name 
    if { [string compare $parent "."] == 0} {
	set realparent "." ;
	set path ".obj$name" ;
    } else {
	global "$parent";
	set parentpath [set "$parent\(path)"];
	set realparent $parentpath ;
	set path "$parentpath.obj$name" ;
    }

    set "$name\(parent)" $handle;
    set "$name\(path)" $path;
    
    switch -exact -- $style {
	
	figure {
	    $control $path -class figure -bg #d0d0d0;
	}
	
	default {
	    $control $path  -bg #d0d0d0;
	}
    }
    # redraw here means : set all the control
    # properties back
    if {$rdrw == 1} { Redraw [set "$name\(handle)"];}
  
    # if the current object we created or modified
    # is a figure (toplevel window) then it becomes
    # the current figure: (gcf is the handle of the current figure)
    if { [string compare $style "figure"] == 0} {
	set gcf [set "$name\(handle)" ];
    }
}




######################################################################################
proc Setposition { name value } {
    # position a control in its parent window
    
    global "$name";
    set path [set "$name\(path)"];
    set units [set "$name\(units)"];
    
    set unt(pixels) "";
    set unt(points) "p";
    set unt(centimeters) "c";
    set unt(inches) "i";
    set unt(normalized) "";
    set u $unt($units);

    set coord [split $value "|"];
    set x [lindex $coord 0];
    set y [lindex $coord 1];
    set w [lindex $coord 2];
    set h [lindex $coord 3];
    set "$name\(position)" "$x|$y|$w|$h";
    
    
    set style [set "$name\(style)"];
    
    switch -exact -- $style {
	
	slider { # Style = slider
	    
	    if { [string compare $units "normalized"]==0 } {
		
		set y [expr 1 - $y -$h];
		place "$path" -x 0 -y 0 -width 0 -height 0 -relx $x -rely $y -relwidth $w -relheight $h;
		set realh [winfo height $path];
		set realw [winfo width $path];
		if {[ info exist "$name\(h)"]} { set realh [set "$name\(h)"]; }
		
		set realh [expr $realh -2]; 
		$path configure -borderwidth 0 -width $realh  -showvalue 0 -orient horizontal;
		
	    } else { # modif bruno (en copiant le cas default: en tk la position est fct 
                     # du coin sup gauche, il faut donc faire un y <- h(figure) - y(scilab) )
                     # enfin pour un slider le width ne comprends que le slider lui-meme
                     # sans compter la taille de son bord : ici j'impose un bord de 1 ....
                     # sans doute a revoir ....
		global Win;
		set parent $Win([set "$name\(parent)"]);
		global "$parent";
		set parent_path [set "$parent\(path)"];
                set h [expr $h -2];  # a explique...
		"$path" configure  -borderwidth 1 -length $w$u -width $h$u -sliderlength [expr $w/5]; 
		
		set pheight [winfo reqheight $parent_path];
		#set pheight [winfo height $parent_path];
		set y [expr $pheight -  $y -$h -3 ];  
		place "$path" -x $x$u -y $y$u 
		
	    }
	    
	}
	figure { 
	    set w [expr round($w)];
	    set h [expr round($h)];
	    set x [expr round($x)];
	    set y [expr round($y)];
	    set scrh [winfo screenheight $path];
	    set scrw [winfo screenwidth $path];
	    
	    if { [string compare $units "normalized"]==0 } {
		set w [expr $w * $scrw]
		set h [expr $h * $scrh]
		set x [expr $x * $scrh]
		set y [expr $y * $scrh]
	    }
	    wm geometry $path "+$x\+$y"; 
	    $path configure -width $w$u;
	    $path configure -height $h$u;
	}
	default { #style = default
	    
	    
	    if { [string compare $units "normalized"] == 0 } {
		set y [expr 1 - $y -$h];
		
		place "$path" -x 0 -y 0 -width 0 -height 0 -relx $x -rely $y -relwidth $w -relheight $h;
	    } else {
		global Win;
		set parent $Win([set "$name\(parent)"]);
		global "$parent";
		set parent_path [set "$parent\(path)"];
		
		set pheight [winfo reqheight $parent_path];
		#set pheight [winfo height $parent_path];
		set y [expr $pheight -  $y -$h];
		place "$path" -x $x$u -y $y$u -width $w$u -height $h$u;
		
		
	}
    }
}




	
    
}

######################################################################################
proc Setsliderstep { name value } {
    # set slider steps (big and small)

    global "$name";
    set style [set "$name\(style)"];
    set path [set "$name\(path)"];

    set  step [split $value "|"];
    set smallstep  [lindex $step 0];
    set bigstep [lindex $step 1];

#enrico
    if {$bigstep==""} {set bigstep "0"}
    switch -exact -- $style {
       slider {
          $path configure -resolution $smallstep -bigincrement $bigstep
       }
	default {
	}
    }
}
######################################################################################
proc Setstring { name  str} {
    # set control string field
    # for multiple strings, the different 
    # strings are separated by a '|'

    global "$name";
    set style [set "$name\(style)"];
    set path [set "$name\(path)"];
    
    set "$name\(string)" $str;
    set item [split $str "|"];
    set nbitem [llength $item];
    switch -exact -- $style {
	listbox {    
	    $path.list delete 0 end;
	    for { set i 0 } { $i < $nbitem } { incr i } {
		$path.list insert end [lindex $item $i]; 
	    }
	}
	popupmenu {
	    $path.menu delete 0 end;
	    for { set i 0 } { $i < $nbitem } { incr i } {
		$path.menu add command  -label  [lindex $item $i] -command "popupsel $name $i"; 
	    }
	    $path configure -text [lindex $item 0]
	}
	text { $path configure -text $str; }
	radiobutton { $path configure -text $str; }
	checkbox { $path configure -text $str; }
	pushbutton { $path configure -text $str;}
	default {
	    
	}
    }
}




######################################################################################
proc Setunits { name units } {
# set placement units of a control 

  global "$name";
  set "$name\(units)" $units;
}


######################################################################################
proc Setvalue { name  str} {
# set control value field

  global "$name";
  set style [set "$name\(style)"];
  set path [set "$name\(path)"];

  set "$name\(value)" $str;

  switch -exact -- $style {
    "toto" {$path configure -value $str;}
    "popupmenu" {
	set string [set "$name\(string)"];
    
	set item  [split $string "|"];
	set label [lindex $item $str];

	$path configure -text $label;
    }
    "listbox" {
	set item [split $str "|"];
	set nbit [llength $item];
	# clear the selection
	$path.list selection clear 0 end;
	for {set i 0} {$i<$nbit} {incr i} {
	    set curit [lindex $item $i];
	    $path.list selection set [expr round($curit - 1)];
	    $path.list see [expr round( $curit - 1)];
	}
    }
    default { }
     
  }
}

######################################################################################
# V.C. 03/08/2004 from bug 895
proc Setfigure_name { name value } {
# set the title of a figure

  global "$name";
  set "$name\(figure_name)" $value;
  set path [set "$name\(path)"];
  wm title $path $value
  if { $value eq "PDE_IHM" } {
  wm protocol $path WM_DELETE_WINDOW  "pde_ihm_Quit_cross"    
  }
}

proc pde_ihm_Quit_cross {} {}

