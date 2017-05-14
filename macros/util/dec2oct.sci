function y = dec2oct(x)
//decimal to octal	
rhs = argn(2);

// check the number of input arguments
if rhs<>1 then
	error('dec2oct: bad call');
end
	
if or(type(x)<>8) & (or(type(x)<>1) | or(x<0) ) then
	error("dec2oct: invalid input parameter");
end
	
[nr,nc] = size(x);
y  = emptystr(nr,nc);
	
for i=1:nr
	for j=1:nc
	
		if x(i,j) < 8 then
			y(i,j) = string(x(i,j));
			continue;
		end
		
		x_bin          = dec2bin(x(i,j));
		x_bin_length   = length(x_bin);
		
		// Right padd with 
		while (modulo(length(x_bin),3) ~= 0) ,
			x_bin = '0' + x_bin;
		end
		
		x_bin_splitted = strsplit(x_bin,3*[1:(length(x_bin)/3-1)]);
		y(i,j)         = code2str(bin2dec(x_bin_splitted));
		
	end
end
endfunction
