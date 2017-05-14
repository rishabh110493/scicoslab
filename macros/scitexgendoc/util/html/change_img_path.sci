function txt=change_img_path(name,lind,%gd)
 txt=[];
 tt_done='';
 if fileinfo(name)<>[] then
   tt=mgetl(name);
   if tt<>[] then
     a=[];
     gendoc_printf(%gd,"\tChange path and name of images... ");
     for i=1:size(tt,1)
       if(strindex(tt(i),'<IMG'))<>[] then
         a=1;
       end
       if((strindex(tt(i),'SRC=""'))<>[])&(a==1) then
         a=[];
         //rename file
         bsname=basename(name);
         //cas gui
         if strindex(tt(i+1),bsname+'.eps')<>[] then
           cur_img=strsubst(tt(i),"SRC=","");
           cur_img=stripblanks(strsubst(cur_img,"""",""));
           tt(i)=strsubst(tt(i),cur_img,bsname+'_blk.gif');
           unix_g(%gd.cmd.mv+'./'+bsname+'/'+cur_img+' ./'+bsname+'/'+bsname+'_blk.gif');
         elseif strindex(tt(i+2),'_gui.eps')<>[] then
           filen=part(tt(i+2),strindex(tt(i+2),'file=')+5:strindex(tt(i+2),'.eps')-1)
           cur_img=strsubst(tt(i),"SRC=","");
           cur_img=stripblanks(strsubst(cur_img,"""",""));
           //tt(i)=strsubst(tt(i),cur_img,bsname+'_gui.gif');
           tt(i)=strsubst(tt(i),cur_img,filen+'.gif');
           unix_g(%gd.cmd.mv+'./'+bsname+'/'+cur_img+' ./'+bsname+'/'+filen+'.gif');
         elseif strindex(tt(i+2),'_pal.eps')<>[] then
           filen=part(tt(i+2),strindex(tt(i+2),'file=')+5:strindex(tt(i+2),'.eps')-1)
           cur_img=strsubst(tt(i),"SRC=","");
           cur_img=stripblanks(strsubst(cur_img,"""",""));
           tt(i)=strsubst(tt(i),cur_img,filen+'.gif');
         else
           cur_img=strsubst(tt(i),"SRC=","");
           cur_img=stripblanks(strsubst(cur_img,"""",""));
           bsnam=basename(cur_img);
           tt(i)=strsubst(tt(i),cur_img,bsnam+'_'+%gd.lang(lind)+'.gif');
           if fileinfo('./'+bsname+'/'+bsnam+'_'+%gd.lang(lind)+'.gif')==[] then
             str=%gd.cmd.mv+...
                    './'+bsname+...
                    '/'+cur_img+' ./'+...
                    bsname+'/'+...
                    bsnam+'_'+...
                    %gd.lang(lind)+'.gif';
             ierr=unix(str);
             if ierr<>0 then
                gendoc_printf(%gd,"\n\t  %s : warning, can''t move %s\n",...
                       'change_img_path',...
                       bsnam+'_'+%gd.lang(lind)+'.gif');
                tt_done="\t";
             end
           else
             gendoc_printf(%gd,"\n\t  %s : %s already exists!\n",...
                    'change_img_path',...
                     bsnam+'_'+%gd.lang(lind)+'.gif');
             tt_done="\t";
           end
         end
         //change path
         tt(i)=strsubst(tt(i),'SRC=""','SRC=""'+%gd.mpath.html_img);
       end
     end
     txt=tt;
     gendoc_printf(%gd,tt_done+"Done\n");
   end
 end
endfunction
