function y=dec2bin(x,n)
// Given x, a positive scalar/vector/matix of reals, this function returns
// a column vector of strings. Each string is the binary representation
// of the input argument components.
//    x : vector or matrix with positive entries
//    n : integer
//    y : vector of strings
rhs = argn(2);
// check the number of input arguments
if (rhs<1 | rhs>2) then
	error('dec2bin: Wrong number of input arguments');
end
	
// check type and size of the input arguments
if or(type(x)<>8) & (or(type(x)<>1) | or(x<0)) then
	error('dec2bin: invalid input argument');
end
	
if rhs==2 & ((type(n)<>8 & (type(n)<>1 | n<0)) | prod(size(n))<>1) then
	error('dec2bin: invalid 2nd input parameter')
end
	
// empty matrix
if x==[]
	y=string([]);
	return;
end
	
[nr,nc] = size(x);
x=x(:);
	
// input argument is a scalar/vector/matrix of zeros
	
if and(x==0)
if rhs==2
		y = strcat(string(zeros(1:n))) + emptystr(nr,nc);
	else
		y = "0" + emptystr(nr,nc);
	end
	return
end
	
// for x=25, pow=[4 3 0], because x=2^4+2^3+2^0
// for x=23, pow=[4 2 1 0] because x=2^4+2^2+2^1+2^0
// for x=[25 23]
// pow=[4 3 0 -1
//      4 2 1 0];
	
while find(x>0)<>[]
	pow(x>0,$+1) = floor(log2(double(x(x>0))));
	pow(x<=0,$)  = -1;
	x(x>0)       = floor(x(x>0)-2^pow(x>0,$));
end
	
pow   = pow+1;
ytemp = zeros(size(pow,1),size(pow,2));

for i=1:size(ytemp,1)
	ind          = pow(i,pow(i,:)>=1);
	ytemp(i,ind) = 1;
end
	
if rhs==2
	for i=1:size(ytemp,1)
		y(i)=strcat(string([zeros(1,round(n-size(ytemp,2))) ytemp(i,size(ytemp,2):-1:1)]));
	end
else
	for i=1:size(ytemp,1)
		y(i)=strcat(string(ytemp(i,size(ytemp,2):-1:1)));
	end
end
	
y = matrix(y,nr,nc);

endfunction
