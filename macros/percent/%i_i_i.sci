function M=%i_i_i(varargin)
//insertion of an integer matrix in an matrix of integers for more than 2 indices

  M=varargin($)
  it=inttype(M)
  M=mlist(['hm','dims','entries'],int32(size(M)),M(:))
  varargin($)=M;
  M=generic_i_hm(iconvert(0,it),varargin(:))

endfunction
