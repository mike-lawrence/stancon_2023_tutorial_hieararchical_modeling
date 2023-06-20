...
parameters {
	...
	// log_odds_of_success_: log-odds of success expressed as z-scores
	//		Note: "_" suffix used to denote that this is a "helper" variable for the parameterization
	vector[n_id] id_log_odds_of_success_ ;
}
model {
	...
	id_log_odds_of_success_ ~ std_normal() ;

	// computing the derived quantity "id_log_odds_of_success"
	vector[n_id] id_log_odds_of_success = (
		id_log_odds_of_success_
		.* log_odds_of_success_sd
		+ log_odds_of_success_mean
	) ;

	...
}
