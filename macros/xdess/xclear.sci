function xclear(win_num)
//xbasc([win_num])
// Clear the graphic window win_num and erase the recorded graphics of
// window win_num
// if win_num is omited, it's the current graphic window
// win_num can also be a vector of window Id to clear a set of windows
//!
// Copyright ENPC
  [lhs,rhs]=argn(0);
  vvv=xget("old_style");
  if vvv==0 then
    // new graphic style 
    if rhs==0, 
      win_num=xget("window"), 
      win=get('current_figure'),
      set(win,'visible','off') ;
    else
      [n1,n2]=size(win_num);
      zz = winsid();
      if ~isempty(zz) then 
	yyy=xget('window');
      end
      for xxx=win_num, 
	xset('window',xxx); 
	win=get('current_figure'),
	set(win,'visible','off');
      end
      if ~isempty(zz) then 
	xset('window',yyy);
      end
    end
  else
    if rhs==1 then
      oldxclear(win_num)
    else
      oldxclear()
    end
  end
endfunction 
