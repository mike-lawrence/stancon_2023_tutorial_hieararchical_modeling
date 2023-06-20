data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	vector[n_obs*n_id] obs ;
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
}
parameters {
	// sigma: likelihood sd
	real<lower=0> sigma ;
	// mu: likelihood mean
	vector[n_id] id_mu ;
}
model {
	// priors (adjust when using real data!!)
	sigma ~ weibull(2,1) ;
	id_mu ~ std_normal() ;  //n.b. implicit loop
	// likelihood
	obs ~ normal(id_mu[obs_id],sigma) ;
}
