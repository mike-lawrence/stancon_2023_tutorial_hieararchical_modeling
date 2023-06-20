data {
	...
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
	...
	vector[n_id_centered_and_scaled] id_log_odds_of_success_centered_scaled ;
	vector[n_id_not_centered_nor_scaled] id_log_odds_of_success_uncentered_unscaled ;
}
model {
	...
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
	...
}
