data {
	...
	// obs: array of bernoulli observations
	array[n_obs*n_id] int<lower=0,upper=1> obs ;
}
...
model {
	...
	// likelihood
	obs ~ bernoulli_logit(log_odds_of_success) ;
}
