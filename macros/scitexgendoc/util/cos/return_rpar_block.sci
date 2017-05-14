function tt=return_rpar_block(name)
 //load scicos libraries 
 load SCI/macros/scicos/lib
 
 //execute define case
 ierror=execstr('blk='+name+'(''define'')','errcatch')
 if ierror<>0 then
    x_message(['Error in case define of GUI function';lasterror()] )
    disp(name)
    fct=[]
    return
 end

 tt=blk.model.rpar
endfunction