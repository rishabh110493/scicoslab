function ko=isemptystr(tt)
  ko=%t;
  for i=1:size(tt,1)
     for j=1:size(tt,2)
        if tt(i,j)<>[] then
           txt=stripblanks_end(stripblanks_begin(tt(i,j)));
           if txt<>"" then
             ko=%f;
             return
           end
        end
     end
  end
endfunction
