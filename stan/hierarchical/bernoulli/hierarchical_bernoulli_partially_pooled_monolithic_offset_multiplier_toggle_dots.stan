data {
	...
	int<lower=0,upper=1> centered_and_scaled ;
}
parameters {
	...
	// log_odds_of_success: log-odds of success
	vector<
		offset = ( centered_and_scaled ? 0 : log_odds_of_success_mean )
		, multiplier = ( centered_and_scaled ? 1 : log_odds_of_success_sd )
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
