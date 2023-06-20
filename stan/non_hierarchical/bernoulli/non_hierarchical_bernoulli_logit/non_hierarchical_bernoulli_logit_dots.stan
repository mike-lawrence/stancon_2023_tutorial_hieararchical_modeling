...
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
