//1 - create _head.tex
function []=gen_aux_sce(lisf,typdoc,lind,%gd)

  bsnam=get_extname(lisf,%gd)
  bsrep=%gd.lang(lind)+'/'+bsnam

  ////////////////////////
  //1 - create _head.tex
  ////////////////////////
  gendoc_printf(%gd,"\tWrite a _head.tex file... ")
  txt=get_head_tex(lisf,typdoc,lind,%gd)
  mputl(txt,'./'+bsrep+'/'+bsnam+'_head.tex');
  gendoc_printf(%gd,"Done\n");

endfunction

