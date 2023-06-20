data {
	// n_obs: number of observations
	int<lower=1> n_obs ;
	// obs: vector of observations
	vector[n_obs] obs ;
}
parameters {
	// mu: mean
	real mu ;
	// sigma: standard deviation
	real<lower=0> sigma ;
}
model {
	// priors (adjust when using real data!!)
	mu ~ std_normal() ;
	sigma ~ weibull(2,1) ;
	// likelihood
	obs ~ normal(mu,sigma) ;
}
