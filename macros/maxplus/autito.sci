function autito(x,r,a,color)
xset("pattern",color);
x1=r*cos(2*%pi*x);
y1=r*sin(2*%pi*x);
xfarc(x1-a/2,y1+a/2,a,a,0,360*64);
endfunction
