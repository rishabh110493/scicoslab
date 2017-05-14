
function qq=Vm(N,V2,lam);
// Function vitesse moyenne
// Parametres: 
//     V2: vector de vitesses v2
//     lam: probabilite de la vitesse v2
//     N: quantite de voitures
//     k: quantite de bouchons
q=lam*ones(V2);
K=ceil(V2.^(-1));
qq=q./K;
for n=1:N-1,
	q=(lam./(n+K)).*(K+n*q);
	qq=[qq;q./K];
end;
endfunction
