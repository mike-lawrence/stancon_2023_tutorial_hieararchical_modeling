data {
	...
	// time_of_day:
	vector[n_obs] time_of_day ;
}
parameters {
	// mu_intercept: value for the mean when time-of-day==0
	real mu_intercept ;
	// mu_tod_beta: effect of time-of-day on mean
	real mu_tod_beta ;
	...
}
model {
	// priors (adjust when using real data!!)
	mu_intercept ~ std_normal() ;
	mu_tod_beta ~ std_normal() ;
	...
	// likelihood
	obs ~ normal(
		mu_intercept + mu_tod_beta .* time_of_day
		, sigma
	) ;
}
