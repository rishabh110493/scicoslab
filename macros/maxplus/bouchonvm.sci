
function q=bouchonvm(N,k,l)
// Function vitesse moyenne
// Parametres: 
//     l: probabilite de la vitesse v2
//     N: quantite de voitures
//     k:quantite de bouchons
q=l;
for n=1:N-1,
	q=l/(n+k)*(k+n*q);
end;
endfunction
