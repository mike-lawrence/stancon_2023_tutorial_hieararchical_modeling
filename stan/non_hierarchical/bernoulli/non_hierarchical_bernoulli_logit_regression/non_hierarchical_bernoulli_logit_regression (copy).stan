data {
	// n_obs: number of bernoulli observations
	int<lower=1> n_obs ;
	// obs: array of bernoulli observations
	array[n_obs] int<lower=0,upper=1> obs ;
	// time_of_day:
	vector[n_obs] time_of_day ;
}
parameters {
	// intercept: log-odds of success when time-of-day==0
	real intercept ;
	// tod_beta: effect of time-of-day
	real tod_beta ;
}
model {
	// priors (adjust when using real data!!)
	intercept ~ std_normal() ;
	tod_beta ~ std_normal() ;
	// likelihood
	obs ~ bernoulli_logit( intercept + tod_beta .* time_of_day ) ;
}
