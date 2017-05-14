
Note about icon formats:

  As of version 0.8.90, the tango icons are distributed by the Tango Desktop Project in PNG format.

  Tcl/Tk, as of versions 8.4 and 8.5, does not support PNG.
  Tcl/Tk 8.6 does (but not yet in 8.6b1), this is TIP #244, thanks to the inclusion of zlib (TIP #234).

  However I don't want to increase the requirement on the Tcl/tk version just because of this.

  As a consequence, a GIF version of each icon is used by Scipad, this GIF version being created from the PNG version.
  
  The Tango icons are delivered in Scipad in PNG format (unmodified native files distributed by the Tango Desktop project), and in GIF format as well.
  The GIF images are created through the following process:
    - Open The GIMP
    - Open the PNG icon
    - File/Save as, expand the file type area, select GIF, click Save button
    - A dialog opens, click "Convert to indexed...", click the Export button
    - Another dialog opens, click the Save button
    - Close the icon file
    - Start again with next icon

F. Vogel, 06 February 2011

