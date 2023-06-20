data {
	...
	// obs: array of gaussian observations
	vector[n_obs*n_id] obs ;
}
...
model {
	...
	// likelihood
	obs ~ normal(mu,sigma) ;
}
