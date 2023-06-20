data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	vector[n_obs*n_id] obs ;
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
	int<lower=0,upper=1> centered_and_scaled ;
}
parameters {
	// sigma: likelihood sd
	real<lower=0> sigma ;
	// mu_mean: mean (across individuals) likelihood mean
	real mu_mean ;
	// mu_sd: sd (across individuals) likelihood mean
	real<lower=0> mu_sd ;
	// mu: likelihood mean
	vector<
		offset = ( centered_and_scaled ? 0 : mu_mean )
		, multiplier = ( centered_and_scaled==1 ? 1 : mu_sd )
		>[n_id] id_mu ;
}
model {
	// priors (adjust when using real data!!)
	sigma ~ weibull(2,1) ;
	mu_mean ~ std_normal() ;
	mu_sd ~ weibull(2,1) ;
	id_mu ~ normal(mu_mean, mu_sd) ;
	// likelihood
	obs ~ normal(id_mu[obs_id], sigma) ;
}
