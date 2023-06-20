data {
	...
	// n_successes: number of "successes" in the n_obs observations
	int<lower=0,upper=n_obs> n_successes ;
}
...
model {
	...
	// likelihood
	n_successes ~ binomial_logit(n_obs, log_odds_of_success) ;
}
