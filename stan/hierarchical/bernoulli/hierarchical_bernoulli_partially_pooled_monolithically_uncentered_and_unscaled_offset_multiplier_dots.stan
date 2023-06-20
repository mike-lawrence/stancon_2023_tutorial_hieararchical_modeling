...
parameters {
	...
	// log_odds_of_success: log-odds of success
	vector<
		offset = log_odds_of_success_mean
		, multiplier = log_odds_of_success_sd
		>[n_id] id_log_odds_of_success ;
}
model {
	...
	id_log_odds_of_success ~ normal(
		log_odds_of_success_mean
		, log_odds_of_success_sd
	) ;
	...
}
