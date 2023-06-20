...
parameters {
	...
	// eta_mean: mean (across individuals) likelihood log-variance
	real eta_mean ;
	// eta_sd: sd (across individuals) likelihood log-variance
	real<lower=0> eta_sd ;
	// eta_: likelihood mean expressed as z-scores
	//		Note: "_" suffix used to denote that this is a "helper" variable for the parameterization
	vector[n_id] id_eta_ ;
}
model {
	...
	eta_mean ~ std_normal() ;
	eta_sd ~ weibull(2,1) ;
	id_eta_ ~ std_normal() ;
	...
	// computing the derived quantity "id_eta"
	vector[n_id] id_eta = (
		id_eta_
		.* eta_sd
		+ eta_mean
	) ;
	// likelihood
	obs ~ normal(id_mu[obs_id], sqrt(exp(id_eta[obs_id]))) ;
}
