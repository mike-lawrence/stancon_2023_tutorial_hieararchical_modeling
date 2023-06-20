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
...
model {
	...
	// likelihood
	n_successes ~ binomial_logit(n_obs, intercept + tod_beta * time_of_day) ;
}
