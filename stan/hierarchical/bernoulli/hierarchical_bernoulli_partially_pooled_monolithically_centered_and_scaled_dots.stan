...
parameters {
	// log_odds_of_success_mean: mean (across individuals) log-odds of success
	real log_odds_of_success_mean ;
	// log_odds_of_success_sd: sd (across individuals) log-odds of success
	real<lower=0> log_odds_of_success_sd ;
	...
}
model {
	// priors (adjust when using real data!!)
	log_odds_of_success_mean ~ std_normal() ;
	log_odds_of_success_sd ~ weibull(2,1) ;
	id_log_odds_of_success ~ normal(
		log_odds_of_success_mean
		, log_odds_of_success_sd
	) ;
	...
}
