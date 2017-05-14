function txt=return_lables_block2(name,txt_exprs)

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
 getvalue=mgetvalue2;
 
 //retrieve labels of getvalue fonction
 global mylables

 ierror=execstr('blk='+name+'(''define'')','errcatch')
 if ierror<>0 then
    x_message(['Error in GUI function';lasterror()] )
    disp(name)
    fct=[]
    return
 end
 
 execstr(txt_exprs);       
 
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
 txt=mylables
 
 clearglobal mydesc
 clearglobal mylables
 clearglobal mytyp
 clearglobal myini
 
endfunction