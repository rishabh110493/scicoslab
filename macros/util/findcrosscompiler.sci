function res = findcrosscompiler()
// Copyright Enpc (Jean-Philippe Chancelier)
// GPL or Scilab Licence.
// try to detect if we are using a scilab win32 version 
// on Linux under wine. If true a cross compiled gcc 
// is assumed to be present in the path.
  
  res = 'unknown';
  if ~MSDOS then return;end 
  try
    test = winqueryreg('name','HKEY_CURRENT_USER','Software\Wine\drivers');    
  catch
    // remove last error when 'winqueryreg' fails
    lasterror();
    return;
  end
  res = 'gcc';
endfunction


