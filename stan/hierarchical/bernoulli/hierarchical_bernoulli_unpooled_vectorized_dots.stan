data {
	...
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
}
...
model {
	...
	// likelihood
	obs ~ bernoulli_logit(id_log_odds_of_success[obs_id]) ;
}
