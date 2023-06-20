data {
	// n_obs: number of bernoulli observations
	int<lower=1> n_obs ;
	// obs: array of bernoulli observations
	array[n_obs] int<lower=0,upper=1> obs ;
}
parameters {
	// prob_success: probability of success
	real<lower=0,upper=1> prob_success ;
}
model {
	// priors (adjust when using real data!!)
	prob_success ~ beta(1,1) ;
	// likelihood
	obs ~ bernoulli(prob_success) ;
}
