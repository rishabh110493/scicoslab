
function varargout=spectral_analysis(a)
//first, we build the graph of the matrix
ga=mp_2_graph(a);
n=size(a,1)
[chi,v]=howard(a)
rho=%ones(1,n)*chi
anorm=rho^(-1)*a
b=dadinv(anorm,v)
c=plus(b)
[ir,ic]=find(b==#(0))
//here is the saturation graph of a
g=mat_2_graph(sparse([ir',ic'],ones(1,size(ir,2)),[n,n]),1,'node-node');
[ncomp,nc]=strong_connex(g)
head=ga('head')
tail=ga('tail')
va=zeros(1,arc_number(ga))
wa=zeros(1,n)
for i=1:(arc_number(ga))
	colortail=nc(tail(i))
	j=head(i)
	if ((colortail==nc(j))& c(j,j)==#(0)) then
	          color=nicecolor(colortail)
		  va(i)=color
		  wa(tail(i))=color
	end
end
ga('edge_color')=va
ga('node_color')=wa
varargout=list(ga,g,rho,chi,v)
endfunction
