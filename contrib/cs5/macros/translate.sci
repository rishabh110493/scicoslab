///////////////////////////////////////////////////////////////////////////////////////
/////     Function MapInfo -> Scilab         //////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

function [net,color,Bidir]=ImportMI(name)


  [fd1,err1]=mopen(name+'.MIF','r')
  [fd2,err2]=mopen(name+'.MID','r')

  if err1+err2 == 0 

    mif=mgetl(fd1,-1);
    mclose(fd1)

    mid=mgetl(fd2,-1);
    mclose(fd2)

    vtail=[]
    vhead=[]
    vlpf1=[]
    vlpf2=[]
    vlpf3=[]
    vlpf4=[]

    color=[]

    nf=size(mif,1)
    nd=size(mid,1)

    posf=0
    posd=0

    Bidir=spzeros(nd,nd);i1=0;i2=0

    while posf<nf,
      p1=''
      while p1<>'Pline' & posf<nf,
	posf=posf+1
	lmif=mif(posf)
	p1=msscanf(lmif,"%s")
      end
      if posf<nf,
	[n,N]=msscanf(lmif,'%*s%i')
	if N>0,
	  posf=posf+1
	  lmif=mif(posf)
	  [n,x1,y1]=msscanf(lmif,'%f%f')
	  posf=posf+N-1
	  lmif=mif(posf)
	  [n,x2,y2]=msscanf(lmif,'%f%f')
	  lmif=mif(posf+1)
	  [n,width,style,lcolor]=msscanf(lmif," Pen (%f,%f,%f")
	  posd=posd+1
	  lmid=mid(posd)
	  [n,lpf1,lpf2,lpf3,lpf4]=msscanf(lmid,"%f,%f,%f,%f")
	  vlpf1=[vlpf1 lpf1]
	  vlpf2=[vlpf2 lpf2]
	  vlpf3=[vlpf3 lpf3]
	  vlpf4=[vlpf4 lpf4]
	  vtail=[vtail [x1 ; y1]]
	  vhead=[vhead [x2 ;y2]]
	  color=[color;lcolor]
	  i1=i1+1;i2=i2+1
	  Bidir(i1,i2)=1;
	  if style==2,   // If the arc in MapInfo is a two-way arc, we dupplicate it in Scilab 
	    vlpf1=[vlpf1 lpf1]
	    vlpf2=[vlpf2 lpf2]
	    vlpf3=[vlpf3 lpf3]
	    vlpf4=[vlpf4 lpf4]
	    vtail=[vtail [x2 ; y2]]
	    vhead=[vhead [x1 ;y1]]
	    color=[color;lcolor]
	    i2=i2+1;Bidir(i1,i2)=1;
	  end

	end
      end
    end
    V=[vtail vhead];
    U=V(1,:)+%i*V(2,:)
    nn=size(U,2)
    M=abs((U.').*.ones(1,nn)-ones(nn,1).*.U)
    tol=1e-7
    key=zeros(1,nn)
    nkey=0
    for i=1:nn,
      ind=find(M(i,:)<tol)
      if key(i)==0,
	nkey=nkey+1
	key(ind)=nkey
	x(nkey)=V(1,i)
	y(nkey)=V(2,i)
      end
    end
    xm=min(x)
    ym=min(y)
    M=max([x-xm;y-ym])


    net=MakeNet(size(x,'*'),(x'-xm)/M*3000,(y'-ym)/M*3000,key(1:nn/2),key(nn/2+1:$),6,[vlpf1;vlpf2;vlpf3;vlpf4],[],[],[])


  else
    disp('*.mif or *.mid files not found')
    return
  end
endfunction


///////////////////////////////////////////////////////////////////////////////////////
/////     Function Scilab -> MapInfo          /////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////


function ok=ExportMI(net,name,nameout,disp_option)
  [lhs,rhs]=argn()
  ok=%F


  if rhs<2 | rhs>4,
    disp("Bad input");
    return
  end

  if rhs<4,   // By default the width of the links will be propportional to the flow
    disp_option="flow";
  end


  if rhs<3,   // if nameout doesnt exist 
    nameout=name;
  end

  [fd1,err1] = mopen( name + '.MIF','r')
  [fd2,err2] = mopen( name + '.MID','r')

  if err1+err2 > 0 
    disp('*.mif or *.mid files not found')
    return
  end

  mif=mgetl(fd1,-1)
  nmif=size(mif,'r')
  mclose(fd1)
  mid=mgetl(fd2,-1)
  nmid=size(mid,'r')
  mclose(fd2)


  max_width=150  /// Max width of the links in the MI map


  select disp_option,

   case 'flow'
    idisp=6
   case 'time'
    idisp=7
  else
    disp("Bad parameters, the options are: ''flow'' , ''time''")
    return
  end

  posf=1

  while part(mif(posf),1:7)<>"Columns" & posf<=nmif, posf=posf+1; end   // Skip until the start of the data

  l=[]
  l2=[]
  if posf>=nmif
    disp("Error in the mif file");
    return
  end

  nl=size(net.links.tail,2)


  max_value=0

  l=[mif(1:posf-1);"Columns 2";"  flow Float";"  time Float";"Data";""]

  max_value=max(max_value,2*max(net.links(idisp)));

  if max_value<=0 then max_value=1; end


  while mif(posf)<>"Data", posf=posf+1; end   // Skip until the start of the data

  /// Scan the original mif an reproduce each line for all the classes.mif

  posf=posf-1;
  posl=0;    //// Current link in the total link list
  posd=0

  while posf<nmif,    /// Recorro .mif
    pl=''
    while pl<>'Pline' & posf<nmif,
      posf=posf+1
      pl=msscanf(mif(posf),"%s")
    end				

    if posf<nmif,
      [n,N]=msscanf(mif(posf),'%*s%i')
      if N>0,
	[n,width,style,color]=msscanf(mif(posf+N+1)," Pen (%f,%f,%f")
	posd=posd+1
	posl=posl+1
	l = [l ; mif(posf:posf+N)];
	add=""
	if style==2 ,
	  add=msprintf("%f,%f",...
		       net.links.flow(posd)+net.links.flow(posd+1),...
		       net.links.time(posd)+net.links.time(posd+1))
	  value=net.links(idisp)(posd)+net.links(idisp)(posd+1)
	  l2 = [l2; add]
	else
	  add=msprintf("%f,%f",...
		       net.links.flow(posd),net.links.time(posd))
	  value=net.links(idisp)(posd)
	  l2 = [l2; add]
	end
	width=1+round(value/max_value*max_width)
	l = [l;msprintf(" Pen (%d,%d,%d)",width,style,color)]
      end
    end
  end

  mputl(l,nameout+".mif")
  mputl(l2,nameout+".mid")

  ok=%T
endfunction
