
function varargout=eigenspace(a)
// eigenspace for the maximal eigenvalue
// (for the characterization of the eigenspace for the others eigenvalues
// see e.g. cite[chap 4]{gaubert92a} and cite{maxplus97}
n=size(a,1)
[chi,v]=howard(a)
rho=%ones(1,n)*chi
anorm=rho^(-1)*a
b=dadinv(anorm,v)
[ir,ic]=find(b==#(0))
g=mat_2_graph(sparse([ir',ic'],ones(1,size(ir,2)),[n,n]),1,'node-node');
[ncomp,nc]=strong_connex(g)
c=plus(anorm)
//we select one node per strongly connected component
basis=[]
for i=1:ncomp
	j=min(find(nc==i))
	if (c(j,j)==%1)
		basis=[basis,c(:,j)]
	end
end
varargout=list(basis,rho)
endfunction
