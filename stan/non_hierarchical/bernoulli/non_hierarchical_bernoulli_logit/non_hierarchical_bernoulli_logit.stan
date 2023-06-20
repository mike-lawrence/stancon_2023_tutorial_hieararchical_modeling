data {
	// n_obs: number of bernoulli observations
	int<lower=1> n_obs ;
	// obs: array of bernoulli observations
	array[n_obs] int<lower=0,upper=1> obs ;
}
parameters {
	// log_odds_of_success: log-odds of success
	real log_odds_of_success ;
}
model {
	// priors (adjust when using real data!!)
	log_odds_of_success ~ std_normal() ;
	// likelihood
	obs ~ bernoulli_logit(log_odds_of_success) ;
}
