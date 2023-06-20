data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	vector[n_obs*n_id] obs ;
}
parameters {
	// sigma: likelihood sd
	real<lower=0> sigma ;
	// mu: likelihood mean
	real mu ;
}
model {
	// priors (adjust when using real data!!)
	sigma ~ weibull(2,1) ;
	mu ~ std_normal() ;
	// likelihood
	obs ~ normal(mu,sigma) ;
}
