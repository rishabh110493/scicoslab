

function dd=%diag(vec)
  len=length(vec)
  dd=%zeros(len,len)
  for i=1:len do
    dd(i,i)=vec(i)
  end
endfunction
