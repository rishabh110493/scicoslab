
if ~exists('tkpath') then tkpath ="";end 

TCL_EvalFile(tkpath+'timer.tcl')
while %t //wait for toplevel to disapear
  TCL_EvalStr('set h [winfo exists .vscale]');
  if TCL_GetVar("h")=='0' then break,end
end
