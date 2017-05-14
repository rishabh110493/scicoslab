TCL_EvalFile(tkpath+'puzzle.tcl')
while %t //wait for toplevel to disapear
  order=TCL_GetVar('order');
  TCL_EvalStr('set h [winfo exists .puzzle]');
  if TCL_GetVar("h")=='0' then break,end
  sleep(1);
end
disp(order)
