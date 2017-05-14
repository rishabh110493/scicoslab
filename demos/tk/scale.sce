
function demredraw(alpha)
  global alpha0
  if alpha0==[] then alpha0=30,end
  if done&abs(alpha-alpha0)>2 then
    done=%f
    a=gca();
    drawlater() 
    a.rotation_angles = [alpha,30];
    alpha0=alpha
    xset('wwpc');
    drawnow();
    xset('wshow');
    done=%t
  end
endfunction

xbasc();
//set figure_style new;
xset('pixmap',1);
xset('wwpc');
plot3d1();
xset('wshow');

done=%t
if ~exists('tkpath') then tkpath ="";end 

TCL_EvalFile(tkpath+'scale.tcl')
while %t //wait for toplevel to disapear
  TCL_EvalStr('set h [winfo exists .vscale]');
  if TCL_GetVar("h")=='0' then break,end
  sleep(1)
end

