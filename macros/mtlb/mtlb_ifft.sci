function r=mtlb_ifft(x,n,job)
// Copyright INRIA
// Translation function for ifft() Matlab function
// Number of RHS arguments: 1 <= rhs <= 3
// Number of LHS arguments: lhs = 1

[lhs,rhs]=argn(0)
if size(x,'*')==0 then
  r=[]
  return
end
if rhs<2 then n=[],end
if rhs==3 then //row or column-wise fft
  select job
  case 1 then //row-wise
    if n<>[] then //pad or truncate
      s=size(x,1)
      if s>n then //truncated fft
	x=x(1:n,:)
      elseif s<n then //padd with zeros
	x(n,:)=0
      end
    end  
    r=[]
    for xk=x
      r=[r fft(xk,1)]
    end
  case 2 then //column-wise
    if n<>[] then //pad or truncate
      s=size(x,2)
      if s>n then //truncated fft
	x=x(:,1:n)
      elseif s<n then //padd with zeros
	x(:,n)=0
      end
    end  
    r=[]
    for k=1:size(x,1)
      r=[r;fft(x(k,:),1)]
    end
  end
else 
  if mini(size(x))==1 then  //fft of a vector
    if n<>[] then //pad or truncate
      s=size(x,'*')
      if s>n then //truncated fft
	x=x(1:n)
      elseif s<n then //padd with zeros
	x(n)=0
      end
      r=fft(x,1)
      if s==1 then
	r=r.'
      end
    else
      r=fft(x,1)
    end
  else //row-wise fft
    if n<>[] then //pad or truncate
      s=size(x,1)
      if s>n then //truncated fft
	x=x(1:n,:)
      elseif s<n then //padd with zeros
	x(n,:)=0
      end
    end
    r=[]
    for xk=x
      r=[r fft(xk,1)]
    end
  end  
end
endfunction
