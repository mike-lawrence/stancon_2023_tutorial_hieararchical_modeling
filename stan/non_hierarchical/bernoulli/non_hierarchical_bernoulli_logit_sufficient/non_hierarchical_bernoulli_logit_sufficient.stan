data {
	// n_obs: number of bernoulli observations
	int<lower=1> n_obs ;
	// n_successes: number of "successes" in the n_obs observations
	int<lower=0,upper=n_obs> n_successes ;
}
parameters {
	// log_odds_of_success: log-odds of success
	real log_odds_of_success ;
}
model {
	// priors (adjust when using real data!!)
	log_odds_of_success ~ std_normal() ;
	// likelihood
	n_successes ~ binomial_logit(n_obs, log_odds_of_success) ;
}
