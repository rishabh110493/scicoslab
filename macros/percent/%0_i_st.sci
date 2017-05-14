function st=%0_i_st(i,void,st)
  if type(i)==10 then
    f=getfield(1,st);
    k=find(f(3:$)==i);
    if k<>[] then
      f(k+2)=[];
      setfield(k+2,null(),st);
      setfield(1,f,st);
    else
      error("Invalid index")
    end
  else
    error("Incorrect assignment")
  end
endfunction
