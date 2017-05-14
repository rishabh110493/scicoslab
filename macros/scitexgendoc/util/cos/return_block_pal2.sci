
function tt=return_block_pal2(lisf,%gd)

  tt=[]
  reppal=%gd.opath.pal
  if reppal<>"" then

    files=[]
    for i=1:size(reppal,1)
       files=dir(reppal(i)+"*.cosf")
       files=files.name
       for j=1:size(files,1)
         blklst=return_block_pal(files(j),,1)
         if find(blklst==basename(lisf(1,2)))<>[] then
           tt=basename(files(j))
           return
         end
       end
    end
  end

endfunction
