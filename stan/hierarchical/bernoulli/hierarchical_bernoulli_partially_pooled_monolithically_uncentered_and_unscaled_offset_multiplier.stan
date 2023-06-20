data {
	// n_obs: number of bernoulli observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of bernoulli observations
	array[n_obs*n_id] int<lower=0,upper=1> obs ;
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
}
parameters {
	// log_odds_of_success_mean: mean (across individuals) log-odds of success
	real log_odds_of_success_mean ;
	// log_odds_of_success_sd: sd (across individuals) log-odds of success
	real<lower=0> log_odds_of_success_sd ;
	// log_odds_of_success: log-odds of success
	vector<
		offset = log_odds_of_success_mean
		, multiplier = log_odds_of_success_sd
		>[n_id] id_log_odds_of_success ;
}
model {
	// priors (adjust when using real data!!)
	log_odds_of_success_mean ~ std_normal() ;
	log_odds_of_success_sd ~ weibull(2,1) ;
	id_log_odds_of_success ~ normal(
		log_odds_of_success_mean
		, log_odds_of_success_sd
	) ;
	// likelihood
	obs ~ bernoulli_logit(id_log_odds_of_success[obs_id]) ;
}
