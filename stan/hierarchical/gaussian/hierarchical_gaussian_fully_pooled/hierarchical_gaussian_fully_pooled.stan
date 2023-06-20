data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	array[n_obs,n_id] int<lower=0,upper=1> obs ;
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
	for(i_id in 1:n_id){
		obs[,i_id] ~ normal(mu,sigma) ;
	}
}
