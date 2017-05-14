function res = dec2base (n, base, len)
//Convert decimal integer to base B string.
//dec2base(D,B) returns the representation of D as a string in base B.  
//D must be a non-negative integer array smaller than 2^52 and B must 
//be an integer between 2 and 36.
//dec2base(D,B,len) produces a representation with at least len digits.
//Examples: 
//dec2base (123, 3) should return  "11120"
  [nargout,nargin]=argn(0);
  if (nargin < 2 | nargin > 3)
    error('dec2base: invalid call');
  end
    nn = n(:);
  symbols = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  if (type(base)==10)
    symbols = base;
    base = length (symbols);
    if mtlb_any (diff (mtlb_sort (ascii (symbols))) == 0)
      error ("dec2base: symbols representing digits must be unique");
    end
  elseif (~size(base,'*')==1)
    error ("dec2base: invalid base size");
  elseif (base < 2 | base > length (symbols))
    error ("dec2base: base must be between 2 and 36");
  end
  max_len = round(log (max (max (n), 1)) ./ log (base)) + 1;
  if (nargin == 3)
    max_len = max (max_len, len);
  end
  for k=1:size(nn,1);
  n=nn(k);
  power = ones (length (n), 1) * (base .^ (max_len-1 : -1 : 0));
  n = n * ones (1, max_len);
  digits = floor((n-fix(n ./(base*power)) .*(base*power)) ./power);
  res(k,1) = part(symbols,digits+1);
  end
endfunction


