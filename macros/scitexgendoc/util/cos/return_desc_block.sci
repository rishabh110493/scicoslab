function txt=return_desc_block(name)

 //Disable scilab function protection
 prot=funcprot();
 funcprot(0);

 //load scicos libraries 
 load SCI/macros/scicos/lib
 exec(loadpallibs,-1)
 %scicos_prob=%f;
 alreadyran=%f
 needcompile=4
 //%zoom=1.8;
  
 //redefine getvalue
 getvalue=mgetvalue;
 
 //retrieve labels of getvalue fonction
 global mydesc
 
 ierror=execstr('blk='+name+'(''define'')','errcatch')
 if ierror<>0 then
    x_message(['Error in GUI function';lasterror()] )
    disp(name)
    fct=[]
    return
 end
        
 ierror=execstr('blk='+name+'(''set'',blk)','errcatch')
 if ierror <>0 then
    x_message(['Error in GUI function';lasterror()] )
    disp(name)
    fct=[]
    return
 end
   
 //restore function protection
 funcprot(prot);
 
 //
 txt=mydesc
 
 clearglobal mydesc
 clearglobal mylables
 clearglobal mytyp
 clearglobal myini
endfunction