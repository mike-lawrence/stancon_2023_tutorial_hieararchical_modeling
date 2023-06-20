data {
	// n_obs: number of observations
	int<lower=1> n_obs ;
	// obs: vector of observations
	vector[n_obs] obs ;
	// time_of_day:
	vector[n_obs] time_of_day ;
}
parameters {
	// mu_intercept: value for the mean when time-of-day==0
	real mu_intercept ;
	// mu_tod_beta: effect of time-of-day on mean
	real mu_tod_beta ;
	// eta_intercept: value for the mean when time-of-day==0
	real eta_intercept ;
	// eta_tod_beta: effect of time-of-day on mean
	real eta_tod_beta ;
}
model {
	// priors (adjust when using real data!!)
	mu_intercept ~ std_normal() ;
	mu_tod_beta ~ std_normal() ;
	eta_intercept ~ std_normal() ;
	eta_tod_beta ~ std_normal() ;
	// likelihood
	obs ~ normal(
		mu_intercept + mu_tod_beta .* time_of_day
		, sqrt(exp( eta_intercept + eta_tod_beta .* time_of_day ))
	) ;
}
