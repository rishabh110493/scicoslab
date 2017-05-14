function y=bin2dec(str)
// Given str a binary string, this function returns the decimal number whose the
// binary representation is given by str
// str : string (or vector/matrix of strings) made of characters '1' and '0'
//  y : scalar/vector/matrix
if type(str)<>10
   error('bin2dec: invalid input argument');
end
str = strsubst(str,' ','');
	
// check  str and convert the binary str to corresponing decimal number
for i=1:prod(size(str))
		
	ind1=strindex(str(i),'1')
	ind0=strindex(str(i),'0')
		
	if length(str(i)) <> sum([prod(size(ind0)) prod(size(ind1))]) then
		error('bin2dec: invalid input parameter');
	end
		
	if length(str(i)) > 54 then
		error('bin2dec: invalid size of argument');
	end
		
	if ~isempty(ind1)
		ind1   = length(str(i))-ind1($:-1:1);
		y($+1) = sum(2^ind1);
	elseif ~isempty(ind0)
		y($+1) = 0;
	else
		y($+1) = [];
	end
end

y=matrix(y,size(str));
endfunction
