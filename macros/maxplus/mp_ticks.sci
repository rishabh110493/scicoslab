function [T]=mp_ticks(g)
  no1=ones(1,g('node_number')); no0=no1*0;
  T=tiplusto(g,no0,no1);
endfunction


