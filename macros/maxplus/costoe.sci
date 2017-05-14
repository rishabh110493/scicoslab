
  
function [v0,q]=costoe(D,H,pre)
[v,p]=costoa(D,H,0.011,pre)
[w,q]=costoa(D,H,0.001,pre)
v0=0.0011*(w-v)
endfunction
