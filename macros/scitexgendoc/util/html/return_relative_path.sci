function txt=return_relative_path(j,%gd)

if MSDOS then sep='\';
else sep='/';
end

txt=[];
for i=1:size(%gd.mpath.html,'*')
 tt=[]
 if i<>j then
   l=1;
   while part(%gd.mpath.html(i),l)==part(%gd.mpath.html(j),l)
    l=l+1;
   end
   tt=part(%gd.mpath.html(j),l:length(%gd.mpath.html(j)));
   nb=strindex(tt,sep);
   tmp=[]
   for k=1:size(nb,'*')
     if MSDOS then tmp=tmp+'..\';
     else tmp=tmp+'../';
     end
   end
   tt=tmp+part(%gd.mpath.html(i),l:length(%gd.mpath.html(i)));
 end
 txt=[txt;tt];
end

endfunction