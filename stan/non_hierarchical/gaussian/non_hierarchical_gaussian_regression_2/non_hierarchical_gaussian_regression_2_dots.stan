...
parameters {
	...
	// eta_intercept: value for the log-variance when time-of-day==0
	real eta_intercept ;
	// eta_tod_beta: effect of time-of-day on log-variance
	real eta_tod_beta ;
}
model {
	...
	eta_intercept ~ std_normal() ;
	eta_tod_beta ~ std_normal() ;
	// likelihood
	obs ~ normal(
		mu_intercept + mu_tod_beta .* time_of_day
		, sqrt(exp( eta_intercept + eta_tod_beta .* time_of_day ))
	) ;
}
