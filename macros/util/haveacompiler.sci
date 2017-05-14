//-----------------------------------------------------------------------------
// Allan CORNET
// INRIA 2005
//-----------------------------------------------------------------------------
function bOK=haveacompiler()
  if MSDOS then
    global LCC
    findLCC=LCC;
    clear LCC
    if findLCC then
      bOK=%T
    else
      msvc=findmsvccompiler();
      if msvc == 'unknown' then 
	bOK=%F
      else
	bOK=%T
      end
    end
  else
    // To do under Unix
    bOK=%T;
  end
endfunction
//-----------------------------------------------------------------------------
