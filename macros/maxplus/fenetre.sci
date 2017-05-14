
function fenetre(data);
// no,x,y,w,h,autoclear
n=max(size(data));
xset("window",data(1));
if n>1,
xset('wpos',data(2),data(3)); 
if n>3,
xset('wdim',data(4),data(5));
if n>5,
if data(6)==1, xset("auto clear","on");end;
end;end;end;
endfunction
