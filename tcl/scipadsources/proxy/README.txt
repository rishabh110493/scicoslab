---- autoproxy ----

The autoproxy package is normally distributed with tcllib. However I don't want
to distribute the entire tcllib with Scipad just for the sake of using autoproxy,
thus only autoproxy and dependencies are included in the Scipad distribution.

The file in this directory was downloaded on 9 February 2013 from the CVS HEAD
from the following address:
http://tcllib.cvs.sourceforge.net/viewvc/tcllib/tcllib/modules/http/autoproxy.tcl


---- uri ----

The uri package is normally distributed with tcllib as well.
It is a dependency of the autoproxy package and is distributed with
Scipad for this reason.

The file in this directory was downloaded on 7 June 2011 from the CVS HEAD
from the following address:
http://tcllib.cvs.sourceforge.net/viewvc/tcllib/tcllib/modules/uri/uri.tcl


---- base64 ----

The base64 package is normally distributed with tcllib as well.
It is a dependency of the autoproxy package and is distributed with
Scipad for this reason.

The file in this directory was downloaded on 7 June 2011 from the CVS HEAD
from the following address:
http://tcllib.cvs.sourceforge.net/viewvc/tcllib/tcllib/modules/base64/base64.tcl


---- registry ----

The registry package is normally distributed with Tcl itself.
It is a dependency of the autoproxy package when running on Windows only. It is
distributed with Scipad for this reason.

The win32 version in this directory was copied from the installation of
ActiveTcl8.5.9.2.294317-win32-ix86-threaded.exe, more exactly from the folder
Tcl\lib\tcl8.5\reg1.2

The win64 version in this directory was copied from Tcl distributed with Scilab
5.3.2, more precisely from the folder
scilab-5.3.2\modules\tclsci\tcl\tcl8.5\reg1.2


---- tcllib license ----

autoproxy, uri and base64 are originally part of the tcllib, which is
distributed under the BSD license.
registry is originally part of Tcl, which is distributed under the same
BSD license as well.

The original license terms are (this is a copy of the license.terms
file from tcllib):

  This software is copyrighted by Ajuba Solutions and other parties.
  The following terms apply to all files associated with the software unless
  explicitly disclaimed in individual files.

  The authors hereby grant permission to use, copy, modify, distribute,
  and license this software and its documentation for any purpose, provided
  that existing copyright notices are retained in all copies and that this
  notice is included verbatim in any distributions. No written agreement,
  license, or royalty fee is required for any of the authorized uses.
  Modifications to this software may be copyrighted by their authors
  and need not follow the licensing terms described here, provided that
  the new terms are clearly indicated on the first page of each file where
  they apply.

  IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
  FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
  ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
  DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

  THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
  IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
  NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
  MODIFICATIONS.

  GOVERNMENT USE: If you are acquiring this software on behalf of the
  U.S. government, the Government shall have only "Restricted Rights"
  in the software and related documentation as defined in the Federal 
  Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
  are acquiring the software on behalf of the Department of Defense, the
  software shall be classified as "Commercial Computer Software" and the
  Government shall have only "Restricted Rights" as defined in Clause
  252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
  authors grant the U.S. Government and others acting in its behalf
  permission to use and distribute the software in accordance with the
  terms specified in this license. 

------------

