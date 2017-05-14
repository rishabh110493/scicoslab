function tt=get_extname(lisf,%gd)
tt=[];
for i=1:size(lisf,1)
  if lisf(i,2)<>'' then
    tt=[tt;basename(lisf(i,2))];
    ierr=execstr('ext=%gd.ext.'+lisf(i,3),'errcatch');
    if ierr==0 then
      if (ext<>"")&(ext<>[]) then
        tt(i)=tt(i)+'_'+ext;
      end
    end
  end
end
endfunction
