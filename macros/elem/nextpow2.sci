function e=nextpow2(n)
  n=abs(n)
  kf=find(~isnan(n)&n<>%inf)
  e=n;f=zeros(n)
  [f(kf),e(kf)]=frexp(n(kf))
  k=find(f==0.5) // n(k) is a power of 2
  e(k)=e(k)-1
endfunction

