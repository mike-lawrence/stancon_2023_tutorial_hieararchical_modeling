data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	vector[n_obs*n_id] obs ;
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
}
parameters {
	// mu_mean: mean (across individuals) likelihood mean
	real mu_mean ;
	// mu_sd: sd (across individuals) likelihood mean
	real<lower=0> mu_sd ;
	// mu_: likelihood mean expressed as z-scores
	//		Note: "_" suffix used to denote that this is a "helper" variable for the parameterization
	vector[n_id] id_mu_ ;
	// eta_mean: mean (across individuals) likelihood log-variance
	real eta_mean ;
	// eta_sd: sd (across individuals) likelihood log-variance
	real<lower=0> eta_sd ;
	// eta_: likelihood mean expressed as z-scores
	//		Note: "_" suffix used to denote that this is a "helper" variable for the parameterization
	vector[n_id] id_eta_ ;
}
model {
	// priors (adjust when using real data!!)
	mu_mean ~ std_normal() ;
	mu_sd ~ weibull(2,1) ;
	id_mu_ ~ std_normal() ;
	eta_mean ~ std_normal() ;
	eta_sd ~ weibull(2,1) ;
	id_eta_ ~ std_normal() ;

	// computing the derived quantity "id_mu"
	vector[n_id] id_mu = (
		id_mu_
		.* mu_sd
		+ mu_mean
	) ;

	// computing the derived quantity "id_eta"
	vector[n_id] id_eta = (
		id_eta_
		.* eta_sd
		+ eta_mean
	) ;

	// likelihood
	obs ~ normal(id_mu[obs_id], sqrt(exp(id_eta[obs_id]))) ;
}
