...
parameters {
	...
	// mu: likelihood mean for each id
	vector[n_id] id_mu ;
}
model {
	...
	// likelihood
	for(i_id in 1:n_id){
		obs[,i_id] ~ normal(id_mu[i_id],sigma) ;
	}
}
