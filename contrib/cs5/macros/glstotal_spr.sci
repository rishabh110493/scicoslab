function [alist,flist,nf]=gls2(func,data,xl,xu,x,p,alist,flist,nloc,small,smax)
  nf=[];
  [nargout,nargin] = argn(0)
  //

  // function [alist,flist,nf]=gls2(func,data,xl,xu,x,p,alist,flist,nloc,small,smax)
  // local and global line search for noiseless functions
  //
  // debug mode: repeats last line search with new print level
  //
  // func:  name for function f=f(data,x)
  // data:  data vector for function call
  // xl,xu: box [xl,xu] for x
  // x:   starting point
  // p:  search direction
  // alist,flist: list of known steps and corresponding function values
  //  (at output in order of increasing alp)
  // nloc:  saturate nloc best local optima (default 1)
  // small: saturation tolerance (default 0.1)
  // smax:  approximate limit of list size (default 10)
  //   1: plot progress along the line, and
  //   2: print some things
  //   3: print more things
  // nf:  number of function evaluations used
  //
  // Note: This is a very slow implementation since lots of sort and
  // reshape are used for simplicity of programming
  // but the number of function values used is low
  //
  // Note: subroutines without arguments
  // return with a sorted alist and an updated s=size(alist,2);
  //


  //  tuning parameters

  short = 0.381966;
  // fraction for splitting intervals
  // golden section fraction is (3-sqrt(5))/2= 0.38196601125011


  //  set debug info

  // save input for analysis of problems in debug mode
  if nargin==1 then
    disp(' ');
    disp('**** debug mode; old data are used *****');
    disp(' ');
    load('glsinput');
  else
    if nargin<9 then
      nloc = 1;
    end
    if nargin<10 then
      small = 0.1;
    end
    if nargin<11 then
      smax = 10;
    end
    save('glsinput');
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////////


  // save information for nf computation and extrapolation decision
  sinit = size(alist,2);          // initial list size


  // get 5 starting points (needed for lslocal)
  bend = 0;

  [amin,%amax,scale]=lsrange2(xl,xu,x,p,alist,flist,bend)


  [alist,flist,abest,fmed,unitlen,monotone,nmin]=lsinit2(alist, flist,amin,%amax,scale)
  // 2 points needed for lspar and lsnew

  s=size(alist,2)
  nf = s-sinit;       // number of function values used

  while s<min(35,smax)

    if nloc==1 then
      [alist,flist,abest,fmed,unitlen,monotone,nmin]=lspar2(func,data,x,p,alist,flist,nloc,small,amin,%amax,abest,fmed,sinit,unitlen)

      // parabolic interpolation step
      // when s==3 we haven't done a true parabolic step
      // and may appear monotonic without being so!
      s=size(alist,2)
      if (s>3 & monotone & (abest==amin|abest==%amax)) then
	nf = s-sinit;           // number of function values used
	lsdraw2(alist,flist);
	return
      end
    else
      [alist,flist,step]=lsnew2(func,data,x,p,alist,flist,nloc,small,amin,%amax,abest,fmed,sinit,unitlen)

      // extrapolation or split

      s=size(alist,2)
    end
  end

  saturated = 0;          	// is reset in lsquart2

  // shape detection phase

  if nmin==1 then
    if (monotone & (abest==amin|abest==%amax)) then
      nf = s-sinit;			    // number of function values used
      lsdraw2(alist,flist);
      return
    end

    if s==5 then
      [alist,flist,abest,fmed,monotone,nmin,saturated]=lsquart2(alist,flist,x,p,nloc,amin,%amax,small,fmed)
    end

    // try quartic interpolation step

    // check descent condition
    [alist,flist,abest,fmed,unitlen,monotone,nmin]=lsdescent2(alist,flist)

    s=size(alist,2)

    // check convexity
    [convex]=lsconvex2(alist,flist,nmin)


    if convex then
      
      nf = s-sinit;			// number of function values used
      lsdraw2(alist,flist);
      return
    end
  end

  sold = 0;

  // refinement phase

  while 1 then
    // check descent condition
    [alist,flist,abest,fmed,unitlen,monotone,nmin]=lsdescent2(alist,flist)

    s=size(alist,2)

    // check saturation
    [saturated]=lssat2(alist,flist,amin,%amax,small,saturated,s)


    if (saturated|s==sold|s>=smax) then
      break
    end

    sold = s;
    nminold = nmin;
    if (~saturated & nloc>1) then

      // separate close minimizers
      [alist,flist]=lssep2(alist,flist,nloc,nmin)

    end
    // local interpolation step
    [alist,flist,abest,fmed,monotone,nmin,saturated]=lslocal2(alist,flist,x,p,nloc,amin,%amax,small,fmed)

    if nmin>nminold then
      saturated = 0;
    end
  end

  // get output information

  nf = s-sinit; 			// number of function values used
endfunction




//////////////////////////////////////////////////////////////////
////                       lsrange2                           ////
//////////////////////////////////////////////////////////////////

function [amin,%amax,scale]=lsrange2(xl,xu,x,p,alist,flist,bend)
// find range of useful alp (x=x0+alp*p) in truncated or bent line search

  if max(abs(p))==0 then
    error('zero search direction in line search');
  end

  // find sensible step size scale

  pp = abs(p(p~=0));
  u = abs(x(p~=0)) ./ pp;
  scale = min(u);
  if scale==0 then
    u(u==0)=(1)./pp(u==0)
    scale = min(u);
  end

  if ~bend then
    // find range of useful alp in truncated line search
    amin = -%inf;
    %amax = %inf;

    for i = 1:max(size(x)) //le agregue el max
      if p(i)>0 then
	amin = max(amin,(xl(i)-x(i))/p(i));
	%amax = min(%amax,(xu(i)-x(i))/p(i));
      elseif p(i)<0 then
	amin = max(amin,(xu(i)-x(i))/p(i));
	%amax = min(%amax,(xl(i)-x(i))/p(i));
      end
    end
    if amin>%amax then
      error('no admissible step in line search');
    end

  else
    // find range of useful alp in bent line search
    amin = %inf;
    %amax = -%inf;

    for i = 1:max(size(x,1))
      if p(i)>0 then
	amin = min(amin,(xl(i)-x(i))/p(i));
	%amax = max(%amax,(xu(i)-x(i))/p(i));
      elseif p(i)<0 then
	amin = min(amin,(xu(i)-x(i))/p(i));
	%amax = max(%amax,(xl(i)-x(i))/p(i));
      end
    end
  end
endfunction



//////////////////////////////////////////////////////////////////
////                       lsinit2                            ////
//////////////////////////////////////////////////////////////////

function [alist,flist,abest,fmed,unitlen,monotone,nmin]=lsinit2(alist,flist,amin,%amax,scale)
// find first two points and establish correct scale

  if size(alist,2)==0 then
    // evaluate at absolutely smallest point
    alp = 0;
    if amin>0 then
      alp = amin;
    end

    if %amax<0 then
      alp = %amax;
    end
    // new function value
    
    falp = func(data,x+alp*p);
    alist = alp;
    flist = falp;
  elseif size(alist,2)==1 then
    // evaluate at absolutely smallest point
    alp = 0;
    if amin>0 then
      alp = amin;
    end

    if %amax<0 then
      alp = %amax;
    end
    if alist~=alp then
      // new function value
      falp = func(data,x+alp*p);
      alist = [alist,alp];
      flist = [flist,falp];
    end
  end

  aamin = min(alist);
  aamax = max(alist);

  if amin>aamin | %amax<aamax then
    disp([alist,amin,%amax]);
    error('non-admissible step in alist');
  end

  // establish correct scale

  if (aamax-aamin)<=scale then
    alp1 = max(amin,min(-scale,%amax));
    alp2 = max(amin,min(scale,%amax));
    alp = %inf;
    if (aamin-alp1)>=(alp2-aamax) then
      alp = alp1;
    else
      alp = alp2;
    end
    if alp<aamin | alp>aamax then
      // new function value
      falp = func(data,x+alp*p);
      alist = [alist,alp];
      flist = [flist,falp];
    end
  end
  //
  if size(alist,2)==1 then
    disp([scale,aamin,aamax,alp1,alp2]);
    error('lsinit bug: no second point found');
  end
  [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist )
endfunction


//////////////////////////////////////////////////////////////////
////                       lssort2                            ////
//////////////////////////////////////////////////////////////////

function [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist )
// sort points by increasing alp;
// count list size and number of strict local extrema
// simple but inefficient
// may be updated in a much faster way
// by looking at in which intervals points are added



  [alist,perm]=sort(-alist);
  alist = -alist
  flist = flist(perm);
  s = size(alist,2);

  // find number of strict local minima, etc.
  up = flist(1:s-1)<flist(2:s);
  down = flist(2:s)<=flist(1:s-1);
  down(1,s-1) =  flist(s)<flist(s-1)
  monotone = sum(up)==0 | sum(down)==0;
  minima = [up,1]&[1,down];
  nmin = sum(minima);

  [fbest,i] = min(flist);
  abest = alist(i);

  fmed = median(flist);
  //
  // distance from best minimum to next

  if nmin>1 then
    al = alist(minima);
    al(al==abest) = matrix([],1,-1)
    unitlen = min(abs(al-abest));
  else
    unitlen = max(abest-alist(1),alist(s)-abest);
  end
endfunction


//////////////////////////////////////////////////////////////////
////                       lspar2                            ////
//////////////////////////////////////////////////////////////////

function [alist,flist,abest,fmed,unitlen, monotone,nmin]=lspar2(func,data,x,p,alist,flist,nloc,small,amin,%amax,abest,fmed,sinit,unitlen)

// local parabolic minimization

  cont = 1;
  // continue?
  s=size(alist,2)
  if s<3 then
    [alist,flist,step]=lsnew2(func,data,x,p,alist,flist,nloc,small,amin,%amax,abest,fmed,sinit,unitlen)
    cont = 0;
  end

  s=size(alist,2)

  if cont then
    // select three points for parabolic interpolation
    [fmin,i] = min(flist);

    if i<=2 then
      ind = 1:3;
      ii = i;
    elseif i>=(s-1) then
      ind = s-2:s;
      ii = i-s+3;
    else
      ind = i-1:i+1;
      ii = 2;
    end

    aa = alist(ind);
    ff = flist(ind);
    // in natural order the local minimum is at ff(ii)

    // get divided differences
    f12 = (ff(2)-ff(1))/(aa(2)-aa(1));
    f23 = (ff(3)-ff(2))/(aa(3)-aa(2));
    f123 = (f23-f12)/(aa(3)-aa(1));

    // handle concave case

    if ~(f123>0) then
      [alist,flist,step]=lsnew2(func,data,x,p,alist,flist,nloc,small,amin,%amax,abest,fmed,sinit,unitlen)
      cont = 0;
    end
  end

  if cont then
    // parabolic minimizer
    alp0 = 0.5*(aa(2)+aa(3)-f23/f123);

    alp = lsguard2(alp0,alist,%amax,amin,small);

    alptol = small*(aa(3)-aa(1));

    // handle infinities and close predictor

    if f123==%inf|min(abs(alist-alp))<=alptol then
      // split best interval
      if ii==1|(ii==2)&(aa(2)>=0.5*(aa(1)+aa(3))) then
	alp = 0.5*(aa(1)+aa(2));
      else
	alp = 0.5*(aa(2)+aa(3));
      end
    end

    // add point to the list

    // new function value
    
    falp = func(data,x+alp*p');
    alist = [alist,alp];
    flist = [flist,falp];
    
  end


  [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist )
  // lssort();
endfunction



//////////////////////////////////////////////////////////////////
////                       lsnew2                            ////
//////////////////////////////////////////////////////////////////

function [alist,flist,step]=lsnew2(func,data,x,p,alist,flist,nloc,small,amin,%amax,abest,fmed,sinit,unitlen)
// find one new point by extrapolation or split of wide interval

  s=size(alist,2)


  if alist(1)<=amin then
    // leftmost point already at boundary
    leftok = 0;
  elseif flist(1)>=max(fmed,flist(2)) then
    // bad leftmost point
    // extrapolate only if no scale known or global search

    leftok = sinit==1 | nloc>1;
  else
    // good interior leftmost point
    leftok = 1;
  end

  if alist(s)>=%amax then
    // rightmost point already at boundary
    rightok = 0;
  elseif flist(s)>=max(fmed,flist(s-1)) then
    // bad rightmost point
    // extrapolate only if no scale known or global search
    rightok = sinit==1 | nloc>1;
  else
    // good interior rightmost point
    rightok = 1;
  end

  // number of intervals used in extrapolation step

  if sinit==1 then
    step = s-1;
  else
    step = 1;
  end
  //
  // do the step


  if leftok&(flist(1)<flist(s)|~rightok) then
    extra = 1;
    al = alist(1)-(alist(1+step)-alist(1))/small;
    alp = max(amin,al);
  elseif rightok then
    extra = 1;
    au = alist(s)+(alist(s)-alist(s-step))/small;
    alp = min(au,%amax);
  else
    // no extrapolation
    
    
    extra = 0;
    len = alist(2:s)-alist(1:s-1);
    dist = max([alist(2:s)-abest;abest-alist(1:s-1);unitlen*ones(1,s-1)]);
    [wid,%i] = max(len ./ dist);

    [alist, flist,alp]=lssplit2(alist,flist,short,%i)
  end

  // new function value

  falp = func(data,x+alp*p);
  alist = [alist,alp];
  flist = [flist,falp];

  [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist )
endfunction


//////////////////////////////////////////////////////////////////
////                       lssplit2                           ////
//////////////////////////////////////////////////////////////////

function [alist, flist,alp]=lssplit2(alist,flist,short,%i)
// lssplit;
// find split of interval [i,i+1] towards better point
// no lssort at the end!

  if flist(%i)<flist(%i+1) then
    fac = short;
  elseif flist(%i)>flist(%i+1) then
    fac = 1-short;
  else
    fac = 0.5;
  end

  alp = alist(%i)+fac*(alist(%i+1)-alist(%i));
endfunction



//////////////////////////////////////////////////////////////////
////                       lsguard2                           ////
//////////////////////////////////////////////////////////////////


function [alp]=lsguard2(mul,alist,%amax,amin,small)
// function alp=lsguard(alp,alist,%amax,amin,small);
// safeguard a point alp
// alist   current list of steps
// %amax,amin  admissible range for alp
// small   relative minimal distance from end point
// assumes that alist(1:s) is within these bounds

  asort=-sort(-alist)
  s = size(asort,2);

  // enforce extrapolation to be cautious
  al = asort(1)-(asort(s)-asort(1))/small;
  au = asort(s)+(asort(s)-asort(1))/small;

  alp = max(al,mini(mul,au));
  alp = max(amin,min(alp,%amax));

  // enforce some distance from end points
  //  factor 1/3 ensures equal spacing if s=2 and the third point
  //  in a safeguarded extrapolation is the maximum.
  if abs(alp-asort(1))<small*(asort(2)-asort(1)) then
    alp = (2*asort(1)+asort(2))/3;
  end
  if abs(alp-asort(s))<small*(asort(s)-asort(s-1)) then
    alp = (2*asort(s)+asort(s-1))/3;
  end
endfunction



//////////////////////////////////////////////////////////////////
////                       lsquart2                           ////
//////////////////////////////////////////////////////////////////

function [alist,flist,abest,fmed,monotone,nmin,saturated]=lsquart2(alist,flist,x,p,nloc,amin,%amax,small,fmed)
// quartic interpolation step
//  unfortunately, this may be unstable for huge extrapolation
// (interpolant loses inflection points)
//  maybe expansion around boundary points work better
// find quartic interpolant

  if alist(1)==alist(2) then
    f12 = 0;
  else
    f12 = (flist(2)-flist(1))/(alist(2)-alist(1));
  end

  if alist(2)==alist(3) then
    f23 = 0;
  else
    f23 = (flist(3)-flist(2))/(alist(3)-alist(2));
  end

  if alist(3)==alist(4) then
    f34 = 0;
  else
    f34 = (flist(4)-flist(3))/(alist(4)-alist(3));
  end

  if alist(4)==alist(5) then
    f45 = 0;
  else
    f45 = (flist(5)-flist(4))/(alist(5)-alist(4));
  end

  f123 = (f23-f12)/(alist(3)-alist(1));
  f234 = (f34-f23)/(alist(4)-alist(2));
  f345 = (f45-f34)/(alist(5)-alist(3));
  f1234 = (f234-f123)/(alist(4)-alist(1));
  f2345 = (f345-f234)/(alist(5)-alist(2));
  f12345 = (f2345-f1234)/(alist(5)-alist(1));


  if f12345<=0 then
    // quartic not bounded below

    good = 0;
    [alist,flist,abest,fmed,monotone,nmin,saturated]=lslocal2(alist,flist,x,p,nloc,amin,%amax,small,fmed)
    quart = 0;
  else
    quart = 1;
  end

  if quart then
    // expand around alist(3)
    c(1) = f12345;

    c(2) = f1234+c(1)*(alist(3)-alist(1))

    c(3) = f234+c(2)*(alist(3)-alist(4))

    c(2) = c(2)+c(1)*(alist(3)-alist(4))

    c(4) = f23+c(3)*(alist(3)-alist(2))

    c(3) = c(3)+c(2)*(alist(3)-alist(2))

    c(2) = c(2)+c(1)*(alist(3)-alist(2))

    c(5) = flist(3)

    
    cmax = max(c);
    c = c/cmax;
    hk = 4*c(1);
    compmat = [0,0,-c(4);hk,0,-2*c(3);0,hk,-3*c(2)];
    ev = spec(compmat)/hk;
    i = find(imag(ev)==0)';
    //
    if max(size(i))==1 then
      // only one minimizer
      
      pqsr=real(ev(i))
      alp = alist(3)+pqsr;

    else
      // two minimizers
      ev = -sort(-ev);

      pqsr1=real(ev(1))
      mul1=alist(3)+pqsr1
      alp1 = lsguard2(mul1,alist,%amax,amin,small);
      pqsr3=real(ev(3))
      mul2=alist(3)+pqsr3
      alp2 = lsguard2(mul2,alist,%amax,amin,small);

      f1 = cmax*quartic2(c,alp1-alist(3));
      f2 = cmax*quartic2(c,alp2-alist(3));

      // pick extrapolating minimizer if possible

      if (alp2>alist(5))&(f2<max(flist)) then
	alp = alp2;
      elseif (alp1<alist(1))&(f1<max(flist)) then
	alp = alp1;
      elseif f2<=f1 then
	alp = alp2;
      else
	alp = alp1;
      end
    end

    if (or(alist==alp)) then
      // predicted point already known
      quart = 0;
    end
  end
  //
  if quart then
    alp = lsguard2(alp,alist,%amax,amin,small);
    // new function value
    falp = func(data,x+alp*p);
    alist = [alist,alp];
    flist = [flist,falp];
    [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist )
  end
endfunction


//////////////////////////////////////////////////////////////////
////                       lslocal2                           ////
//////////////////////////////////////////////////////////////////


function [alist,flist,abest,fmed,monotone,nmin,saturated]=lslocal2(alist,flist,x,p,nloc,amin,%amax,small,fmed)
// refine nloc best local minimizers
// find all strict local minima

  s=size(alist,2);
  fmin = min(flist);
  up = [flist(1:s-1)<flist(2:s)];
  down = [flist(2:s)<=flist(1:s-1)];
  down(s-1) = [flist(s)<flist(s-1)]
  minima = ([up,1]&[1,down]);
  imin = find(minima);

  // consider nloc best local minima only
  
  %v = flist(imin)
  [ff,perm]=sort(-%v);
  ff = -ff
  imin = imin(perm);
  nind = min(nloc,size(imin,2));
  imin = imin(nind:-1:1);
  // best point last for final improvement


  nadd = 0;
  // number of added points
  nsat = 0;
  // number of saturated points

  for i = imin
    // select nearest five points for local formula
    if i<=2 then
      ind = 1:5;
      ii = i;
    elseif i>=(s-1) then
      ind = s-4:s;
      ii = i-s+5;
    else
      ind = i-2:i+2;
      ii = 3;
    end

    aa = alist(ind);
    ff = flist(ind);
    // in natural order
    // the local minimum is at ff(ii)

    // get divided differences
    f12 = (ff(2)-ff(1))/(aa(2)-aa(1));
    f23 = (ff(3)-ff(2))/(aa(3)-aa(2));
    f34 = (ff(4)-ff(3))/(aa(4)-aa(3));
    f45 = (ff(5)-ff(4))/(aa(5)-aa(4));
    f123 = (f23-f12)/(aa(3)-aa(1));
    f234 = (f34-f23)/(aa(4)-aa(2));
    f345 = (f45-f34)/(aa(5)-aa(3));

    // decide on action
    // cas=-1:  no local refinement at boundary
    // cas=0:  use parabolic minimizer
    // cas=1:  use higher order predictor in i-2:i+1
    // cas=5:  use higher order predictor in i-1:i+2
    // select formula on convex interval
    if ii==1 then
      // boundary minimum
      // parabolic minimizer or extrapolation step
      cas = 0;
      if (f123>0)&(f123<%inf) then
	alp = 0.5*(aa(2)+aa(3)-f23/f123);
	if alp<amin then
	  cas = -1;
	end
      else
	alp = -%inf;

	if (alist(1)==amin)&(flist(2)<flist(3)) then
	  cas = -1;
	end
      end
      alp = lsguard2(alp,alist,%amax,amin,small);
    elseif ii==5 then
      // boundary minimum
      // parabolic minimizer or extrapolation step
      cas = 0;
      if (f345>0)&(f345<%inf) then
	alp = 0.5*(aa(3)+aa(4)-f34/f345);
	if alp>%amax then
	  cas = -1;
	end
      else
	alp = %inf;

	if (alist(s)==%amax)&(flist(s-1)<flist(s-2)) then
	  cas = -1;
	end
      end
      alp = lsguard2(alp,alist,%amax,amin,small);
    elseif ~((f234>0)&(f234<%inf)) then
      // parabolic minimizer
      cas = 0;
      if ii<3 then
	alp = 0.5*(aa(2)+aa(3)-f23/f123);
      else
	alp = 0.5*(aa(3)+aa(4)-f34/f345);
      end
    elseif ~((f123>0)&(f123<%inf)) then
      if (f345>0)&(f345<%inf) then
	cas = 5;
	// use 2345
      else
	// parabolic minimizer
	cas = 0;
	alp = 0.5*(aa(3)+aa(4)-f34/f234);
      end
    elseif ((f345>0)&(f345<%inf))&(ff(2)>ff(4)) then
      cas = 5;
      // use 2345
    else
      cas = 1;
      // use 1234
    end
    //
    if cas==0 then
      // parabolic minimizer might extrapolate at the boundary

      alp = max(amin,min(alp,%amax));
    elseif cas==1 then
      // higher order minimizer using 1234
      if ff(2)<ff(3) then
	// compute f1x4=f134
	f13 = (ff(3)-ff(1))/(aa(3)-aa(1));
	f1x4 = (f34-f13)/(aa(4)-aa(1));
      else
	// compute f1x4=f124
	f24 = (ff(4)-ff(2))/(aa(4)-aa(2));
	f1x4 = (f24-f12)/(aa(4)-aa(1));
      end
      alp = 0.5*(aa(2)+aa(3)-f23/(f123+f234-f1x4));

      if alp<=min(aa)|alp>=max(aa) then
	cas = 0;
	alp = 0.5*(aa(2)+aa(3)-f23/max(f123,f234));

      end
    elseif cas==5 then
      // higher order minimizer using 2345
      if ff(3)<ff(4) then
	// compute f2x5=f245
	f24 = (ff(4)-ff(2))/(aa(4)-aa(2));
	f2x5 = (f45-f24)/(aa(5)-aa(2));
      else
	// compute f2x5=f235
	f35 = (ff(5)-ff(3))/(aa(5)-aa(3));
	f2x5 = (f35-f23)/(aa(5)-aa(2));
      end
      alp = 0.5*(aa(3)+aa(4)-f34/(f234+f345-f2x5));

      if alp<=min(aa)|alp>=max(aa) then
	cas = 0;
	alp = 0.5*(aa(3)+aa(4)-f34/max(f234,f345));
      end
    end

    
    // tolerance for accepting new step

    if cas<0|flist(i)>fmed then
      alptol = 0;
    elseif cas>=0 then
      if i==1 then
	alptol = small*(alist(3)-alist(1));
      elseif i==s then
	alptol = small*(alist(s)-alist(s-2));
      else
	alptol = small*(alist(i+1)-alist(i-1));
      end
    end

    cclose = min(abs(alist-alp))<=alptol;

    if cas<0 | cclose then
      nsat = nsat+1;
    end
    saturated = nsat==nind;
    // check if saturated and best point changes
    final = saturated&(~(or(alist==alp)));
    if (cas>=0)&(final | ~cclose) then
      // add point to the list
      nadd = nadd+1;
      // new function value
      falp = func(data,x+alp*p);
      alist = [alist,alp];
      flist = [flist,falp];
      // no sort since this would destroy old index set!!!
    end
  end

  if nadd then
    [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist )
  end
endfunction



//////////////////////////////////////////////////////////////////
////                       lsconvex2                         ////
//////////////////////////////////////////////////////////////////

function [convex]=lsconvex2(alist,flist,nmin)
// check convexity

  s=size(alist,2)
  if nmin>1 then
    convex = 0;
  else
    convex = 1;
    for i = 2:s-1
      f12 = (flist(i)-flist(i-1))/(alist(i)-alist(i-1));
      f13 = (flist(i)-flist(i+1))/(alist(i)-alist(i+1));
      f123 = (f13-f12)/(alist(i+1)-alist(i-1));
      if f123<0 then
	convex = 0;
	break
      end
    end
  end
endfunction




//////////////////////////////////////////////////////////////////
////                       lsdescent2                         ////
//////////////////////////////////////////////////////////////////

function [alist,flist,abest,fmed,unitlen,monotone,nmin]=lsdescent2(alist,flist)
// check descent condition
  cont = or(alist)==0;
  // condition for continue
  s=size(alist,2)

  if cont then
    [fbest,i] = min(flist);
    if alist(i)<0 then
      if alist(i)>=4*alist(i+1) then
	cont = 0;
      end
    elseif alist(i)>0 then
      if alist(i)<4*alist(i-1) then
	cont = 0;
      end
    else
      if i==1 then
	fbest = flist(2);
      elseif i==s then
	fbest = flist(s-1);
      else
	fbest = min(flist(i-1),flist(i+1));
      end
    end
  end


  if cont then
    // force local descent step
    if alist(i)~=0 then
      alp = alist(i)/3;
    elseif i==s then
      alp = alist(s-1)/3;
    elseif i==1 then
      alp = alist(2)/3;
    else
      // split wider adjacent interval
      if (alist(i+1)-alist(i))>(alist(i)-alist(i-1)) then
	alp = alist(i+1)/3;
      else
	alp = alist(i-1)/3;
      end
    end
    //
    // new function value

    falp = func(data,x+alp*p');
    alist = [alist,alp];
    flist = [flist,falp];


    [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist)
  end

  [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist)
endfunction


//////////////////////////////////////////////////////////////////
////                          lssat2                          ////
//////////////////////////////////////////////////////////////////

function [saturated]=lssat2(alist,flist,amin,%amax,small,saturated,s)
// check saturation condition
  cont = saturated;

  if cont then
    // check boundary minimizer
    [fmin,i] = min(flist);
    if i==1|i==s then
      cont = 0;
    end
  end

  if cont then
    // select three points for parabolic interpolation

    aa = alist(i-1:i+1);
    ff = flist(i-1:i+1);

    // get divided differences
    f12 = (ff(2)-ff(1))/(aa(2)-aa(1));
    f23 = (ff(3)-ff(2))/(aa(3)-aa(2));
    f123 = (f23-f12)/(aa(3)-aa(1));

    if f123>0 then
      // parabolic minimizer
      alp = 0.5*(aa(2)+aa(3)-f23/f123);
      alp = max(amin,min(alp,%amax));
      alptol = small*(aa(3)-aa(1));
      saturated = abs(alist(i)-alp)<=alptol;
    else
      saturated = 0;
    end
  end
endfunction


//////////////////////////////////////////////////////////////////
////                          lssep2                          ////
//////////////////////////////////////////////////////////////////

function [alist,flist]=lssep2(alist,flist,nloc,nmin)
// separate close local minimizers
// and maybe add a few global points
  nsep = 0;

  while nsep<nmin
    // find intervals where the monotonicity behavior of both
    // adjacent intervals is opposite
    down = flist(2:s)<flist(1:s-1);
    up=flist(1:s-1)<flist(2:s);
    sep = ([1,1,down]&[0,up,0])&[down,1,1];
    sep = sep|([1,1,up]&[0,down,0])&[up,1,1];
    ind = find(sep);
    if ind==[] then
      break
    end

    aa = 0.5*(alist(ind)+alist(ind-1));

    // interval midpoints
    if max(size(aa))>nloc then
      // select nloc best interval midpoints
      ff = min(flist(ind),flist(ind-1));
      [ff,ind]=sort(-ff);
      ff = -ff
      aa = aa(ind(1:nloc));
    end
    for alp = aa
      // new function value
      falp = func(data,x+alp*p);
      alist = [alist,alp];
      flist = [flist,falp];
      nsep = nsep+1;
      if nsep>=nmin then
	break = break;
      end
    end
    [alist,flist,abest,fmed,unitlen,monotone,nmin]=lssort2(alist,flist )
  end

  // instead of unnecessary separation, add some global points
  for times = 1:nmin-nsep
    s=size(alist,2)
    [alist,flist,step]=lsnew2(func,data,x,p,alist,flist,nloc,small,amin,%amax,abest,fmed,sinit,s,unitlen)

    // extrapolation or split
  end
endfunction


//////////////////////////////////////////////////////////////////
////                         lspost2                          ////
//////////////////////////////////////////////////////////////////

function [alist,flist,gTp,pTGp,nmin,new]=lspost2(alist,flist)
  gTp=[];pTGp=[];nmin=[];new=[];
  [nargout,nargin] = argn(0)
  // postprocessing of line search output
  // find local quadratic model around best point
  // and discard nonminimal points
  //
  // alist,flist: list of steps and corresponding function values
  //  at input: steps with known function values
  //  at output: extrema found, except bad ones at boundary
  // sorted by increasing f
  //  in particular, the best point is at alist(1)
  //  0: nothing plotted or printed (default)
  //   1: mark extrema in plot
  // gTp,pTGp gradient and Hessian information from
  //  local quadratic model around best point
  // nmin:  number of local minima detected
  // new:  is alp=0 separated from abest by a barrier?

  s = size(alist,2);

  // calculate local quadratic model information

  [fbest,i] = min(flist);
  if i==1 then
    ind = [1,2,3];
  elseif i==s then
    ind = [s,s-1,s-2];
  else
    ind = [i,i-1,i+1];
  end

  aa = alist(ind);

  ff = flist(ind);
  f12 = (ff(2)-ff(1))/(aa(2)-aa(1));
  f13 = (ff(3)-ff(1))/(aa(3)-aa(1));
  f23 = (ff(3)-ff(2))/(aa(3)-aa(2));
  f123 = (f23-f12)/(aa(3)-aa(1));
  gTp = f12+f13-f23;
  pTGp = 2*f123;

  // find local extrema
  up = flist(1:s-1)<=flist(2:s);
  // <= needed for constant f
  down = flist(2:s)<=flist(1:s-1);
  // <= needed for constant f
  maxima = [down,1]&[1,up];
  minima = [up,1]&[1,down];
  nmin = sum(minima);


  // purge list from nonextremal points
  ind = maxima|minima;

  if ind==[] then
    error('1???');
  end
  alist = alist(ind);
  flist = flist(ind);
  s = size(alist,2);

  // check for separating barrier
  // (sitting on a local maximum is also counted as barrier)
  i = max(find(alist<=0));
  if i==[] then
    f0 = flist(1);
  elseif i==s then
    f0 = flist(s);
  else
    f0 = min(flist(i),flist(i+1));
  end
  new = f0>min(flist);


  // sort list by function value
  [flist,perm] = sort(-flist);flist = -flist
  alist = alist(perm);

  // discard bad boundary points
  for k = 1:2
    if s==0 then
      error('2???');
    end
    if s<=1 then
      break
      ;
    end
    if alist(s)==min(alist)|alist(s)==max(alist) then
      alist(s) = matrix([],1,-1)
      flist(s) = matrix([],1,-1)
      s = s-1;
    else
      break = break;
    end
  end

endfunction
