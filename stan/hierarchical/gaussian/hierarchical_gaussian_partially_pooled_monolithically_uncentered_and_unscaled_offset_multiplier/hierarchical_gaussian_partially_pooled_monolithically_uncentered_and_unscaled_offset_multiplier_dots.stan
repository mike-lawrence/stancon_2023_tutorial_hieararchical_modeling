...
parameters {
	...
	// mu: likelihood mean
	vector<
		offset = mu_mean
		, multiplier = mu_sd
		>[n_id] id_mu ;
}
model {
	...
	id_mu ~ normal(mu_mean, mu_sd) ;
	...
}
