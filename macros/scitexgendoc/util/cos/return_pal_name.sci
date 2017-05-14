function txt=return_pal_name(lisf,lind,%gd)

 txt=[]

 pal_lis=dir(%gd.mpath.xml(lind)+"*"+%gd.ext.pal+"*.xml");
 pal_lis=pal_lis.name

 for i=1:size(pal_lis,1)
   tt=return_xml_salso(pal_lis(i))
   if tt<>[] then
     ind=find(basename(lisf(1,2))==tt(:,1))
     if ind<>[] then
       txt=pal_lis(i)
       return
     end
   end
 end
endfunction