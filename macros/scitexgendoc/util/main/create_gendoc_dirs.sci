function [ok]=create_gendoc_dirs(%gd)
  ok=%t

  //verifie présence %gd
  [lsh,rsh]=argn(0)
  if rsh<1 then
   ok=%f
   return
  end

 deff('[ko]=create_dirs(dirn)',...
     ['parent=dirname(dirn)'
      'if fileinfo(parent)==[] then'
      ' ko=%f'
      ' create_dirs(parent)'
      'else'
      ' ndirn=strsubst(dirn,parent+''/'',"""")'
      ' mkdir(parent,ndirn)'
      ' ko=%f'
      'end'])

  //crée les mpath
  sz_mpath=size(%gd.mpath);
  for i=2:sz_mpath
    if %gd.mpath(1)(i)=='html_img' then
      if %gd.mpath(i)<>'' then
        if fileinfo(%gd.mpath.html(1)+...
                     %gd.mpath(i))==[] then
          unix_g(%gd.cmd.mk+...
                  %gd.mpath.html(1)+...
                    %gd.mpath(i))
        end
      end
    else
      for j=1:size(%gd.mpath(i)(:),1)
        if %gd.mpath(i)(j)<>'' & %gd.mpath(i)(j)<>[] then
          ko=%f
          while ~ko then
            if fileinfo(%gd.mpath(i)(j))==[] then
               ko=create_dirs(%gd.mpath(i)(j))
            else
              ko=%t
            end
          end
        end
      end
    end
  end

endfunction
