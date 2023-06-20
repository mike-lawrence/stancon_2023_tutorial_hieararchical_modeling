data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	matrix[n_obs,n_id] obs ;
}
parameters {
	// sigma: likelihood sd
	real<lower=0> sigma ;
	// id_mu: likelihood mean for each id
	vector[n_id] id_mu ;
}
model {
	// priors (adjust when using real data!!)
	sigma ~ weibull(2,1) ;
	id_mu ~ std_normal() ;  //n.b. implicit loop
	// likelihood
	for(i_id in 1:n_id){
		obs[,i_id] ~ normal(id_mu[i_id],sigma) ;
	}
}
