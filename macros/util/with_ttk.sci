function r=with_ttk()
  //## look at for Ttk
  r=%f
  [majver,minver]=gettkversion()
  if eval(majver)>=8 then
    minver=part(stripblanks(minver),1)
    if minver<>part('',1) then
      minver=eval(minver)
      if minver>=5 then
        r=%t
      end
    end
  end
endfunction
