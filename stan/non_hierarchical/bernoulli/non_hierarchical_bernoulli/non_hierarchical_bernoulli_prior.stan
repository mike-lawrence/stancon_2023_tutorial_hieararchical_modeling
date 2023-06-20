data {
	// n_obs: number of bernoulli observations
	int<lower=1> n_obs ;
}
generated quantities {
	// obs: array of bernoulli observations
	array[n_obs] int<lower=0,upper=1> obs ;
	// prob_success: probability of success
	real<lower=0,upper=1> prob_success ;
	// priors (adjust when using real data!!)
	prob_success = beta_rng(1,1) ;
	// likelihood
	for(i_obs in 1:n_obs){
		obs[i_obs] = bernoulli_rng(prob_success) ;
	}
}
