function xbasc(win_num)
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
    if rhs==0, 
      win_num=xget("window"), 
      delete('all') ;
    else 
      zz = winsid();
      if ~isempty(zz) then 
	yyy=xget('window');
      end
      [n1,n2]=size(win_num);
      for xxx=win_num, 
	xset('window',xxx);
	delete('all');
      end
      if ~isempty(zz) then 
	xset('window',yyy);
      end
    end
  else
    if rhs==0,win_num=xget("window");end
    [n1,n2]=size(win_num);
    for xxx=win_num,xclear(xxx);xtape('clear',xxx);end
  end
endfunction 


