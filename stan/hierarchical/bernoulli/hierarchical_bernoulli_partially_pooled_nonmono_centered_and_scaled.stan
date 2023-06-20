data {
	// n_obs: number of bernoulli observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of bernoulli observations
	array[n_obs*n_id] int<lower=0,upper=1> obs ;
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
	// n_id_centered_and_scaled: number of individuals to be centered-and-scaled
	int<lower=2> n_id_centered_and_scaled ;
	// id_centered_and_scaled: which id's should be centered-and-scaled
	array[n_id_centered_and_scaled] int<lower=1,upper=n_id> id_centered_and_scaled ;
	// n_id_not_centered_nor_scaled: number of individuals to be uncentered-and-unscaled
	int<lower=2> n_id_not_centered_nor_scaled ;
	// id_not_centered_nor_scaled: which id's should be centered-and-scaled
	array[n_id_not_centered_nor_scaled] int<lower=1,upper=n_id> id_not_centered_nor_scaled ;
}
parameters {
	// log_odds_of_success_mean: mean (across individuals) log-odds of success
	real log_odds_of_success_mean ;
	// log_odds_of_success_sd: sd (across individuals) log-odds of success
	real<lower=0> log_odds_of_success_sd ;

	vector[n_id_centered_and_scaled] id_log_odds_of_success_centered_scaled ;
	vector[n_id_not_centered_nor_scaled] id_log_odds_of_success_uncentered_unscaled ;
}
model {
	// priors (adjust when using real data!!)
	log_odds_of_success_mean ~ std_normal() ;
	log_odds_of_success_sd ~ weibull(2,1) ;
	id_log_odds_of_success_uncentered_unscaled ~ std_normal() ;
	id_log_odds_of_success_centered_scaled ~ normal(
		log_odds_of_success_mean
		, log_odds_of_success_sd
	) ;
	// computing the derived quantity "id_log_odds_of_success"
	vector[n_id] id_log_odds_of_success ;
	id_log_odds_of_success[id_centered_and_scaled] = id_log_odds_of_success_centered_scaled ;
	id_log_odds_of_success[id_not_centered_nor_scaled] = (
		id_log_odds_of_success_uncentered_unscaled
		.* log_odds_of_success_sd
		+ log_odds_of_success_mean
	) ;
	// likelihood
	obs ~ bernoulli_logit(id_log_odds_of_success[obs_id]) ;
}
