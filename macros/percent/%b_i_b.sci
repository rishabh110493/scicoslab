function M=%b_i_b(varargin)
//insertion of a boolean matrix in an matrix of boolean for more than 2 indices

  rhs=argn(2)
  M=varargin(rhs)
  M=mlist(['hm','dims','entries'],int32(size(M)),M(:))
  varargin(rhs)=M;
  M=generic_i_hm(%f,varargin(:))
endfunction
