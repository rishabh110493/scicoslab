#ifndef SCIGRAPHIC_H
#define SCIGRAPHIC_H

#include "../graphics/bcg.h" 

/**sciSetScrollInfo 
 *@description: Sets the dimension of the scroll bars 
 * Do not call SetScrollInfo windows function, 
 * sciSetScrollInfo do that and more things ! 
 *@input: struct BCG *Scilabgc, int sb_ctl, SCROLLINFO 
 *si, BOOLEAN bRedraw 
 *@output: int *@author: Matthieu PHILIPPE  *@date: Dec 1999 
 **/

extern int sciSetScrollInfo(struct BCG *Scilabgc, int sb_ctl,SCROLLINFO *si, BOOLEAN bRedraw);
/**sciGetScrollInfo 
 *@description: Returns the dimension of the scroll bars 
 * Do not call GetScrollInfo windows function, 
 * sciGetScrollInfo do that and more things ! 
 *@input: struct BCG *Scilabgc, int sb_ctl, SCROLLINFO 
 *si *@output: int *@author: Matthieu PHILIPPE  *@date: Dec 1999 
 **/
extern int sciGetScrollInfo(struct BCG *Scilabgc, int sb_ctl, SCROLLINFO *si);
/**sciGetScrollInfo 
 *@description: Returns the wresize status. 
 * 0: it's in scroll bars mode * 1: it's in wresize mode 
 *@input: NONE 
 *@output: integer *@author: Matthieu PHILIPPE  *@date: Dec 1999 
 **/
extern integer sciGetwresize();
/**sciGetPixmapStatus 
 *@description: Returns the pixmap status. * 0: it's drawn directly on screen * 1: it's drawn by a pixmap first 
 *@input: NONE *@output: integer 
 *@author: Matthieu PHILIPPE  *@date: Dec 1999 
 **/
extern integer sciGetPixmapStatus();
/**SciViewportGet 
 *@description: used to get panner position through scilab command. 
 * *@input: struct BCG *ScilabGC : structure associated to a Scilab Graphic window 
 *        int x,y : the x,y point of the graphic window to be moved at  
 *        the up-left position of the viewport
 * *@output: NONE * 
 *@author:  
 *@date: **/
extern void SciViewportGet (struct BCG *ScilabXgc,int *x,int *y);
/**SciViewportMove 
 *@description: used to move the panner and the viewport interactively 
 *              through scilab command. 
 * *@input: struct BCG *ScilabGC : structure associated to a Scilab Graphic window 
 *        int x,y : the x,y point of the graphic window to be moved at  
 *        the up-left position of the viewport * *@output: NONE * *@author:  *@date: 
 **/
extern void SciViewportMove(struct BCG *ScilabXgc,int x,int y);
/**GPopupResize 
 *@description: a little beat different to windowdim. GPopupResize sets the visible 
 * window (parents dimension) 
 * *@input: struct BCG *ScilabXgc,int *x,int *y , where x,y are 
 * the new dimension * *@output: NONE * *@see: setwindowdim * *@author:  *@date:  
 **/

extern void GPopupResize(struct BCG *ScilabXgc,int *x,int *y);

#endif 
