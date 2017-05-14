function rep=ilib_unix_soname()
	
	// Copyright Enpc 
	// Copyright INRIA
	// try to get the proper sufix for 
	// shared unix library sl or so ?
	
  rep = ".so";
  rep = part(rep, (2:length(rep)));

endfunction
