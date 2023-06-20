data {
	// n_tod: number of time-of-day observations
	int<lower=2> n_tod ;
	// time_of_day: timing of observations
	vector[n_tod] time_of_day ;
	// n_obs: array of observation counts per time-of-day
	array[n_tod] int<lower=1> n_obs ;
	// n_successes: array of "success" counts per time-of-day
	array[n_tod] int<lower=0> n_successes ;
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
	n_successes ~ binomial_logit(n_obs, intercept + tod_beta * time_of_day) ;
}
