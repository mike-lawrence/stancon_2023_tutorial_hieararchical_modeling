...
parameters {
	// log_odds_of_success: log-odds of success
	vector[n_id] id_log_odds_of_success ;
}
model {
	...
	// likelihood
	for(i_id in 1:n_id){
		obs[,i_id] ~ bernoulli_logit(id_log_odds_of_success[i_id]) ;
	}
}
