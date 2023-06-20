data {
	...
	int<lower=0,upper=1> centered_and_scaled ;
}
parameters {
	...
	// mu: likelihood mean
	vector<
		offset = ( centered_and_scaled ? 0 : mu_mean )
		, multiplier = ( centered_and_scaled ? 1 : mu_sd )
		>[n_id] id_mu ;
}
model {
	...
	id_mu ~ normal(
		mu_mean
		, mu_sd
	) ;
	...
}
