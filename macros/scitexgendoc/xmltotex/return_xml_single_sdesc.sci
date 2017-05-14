//return_xml_single_sdesc

function txt=return_xml_single_sdesc(fname)

 txt=[]
 tt=[]

 if fileinfo(fname)==[] then
   printf("%s : xml file not found in %s\n",...
          'return_xml_single sdesc',...
          fname);
   return
 end

 tt=return_xml_sdesc(fname);

 if tt<>[] then
   if size(tt,1)==1 then
     txt=tt(1,2);
   else
     name=basename(fname)
     for j=1:size(tt,1)
        if strindex(tt(j,1),name)<>[] then
           txt=tt(j,2)
           break
        end
     end
   end
 end

endfunction