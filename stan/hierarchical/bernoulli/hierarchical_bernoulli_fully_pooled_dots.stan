data {
	...
	// n_id: number of "individuals"
	int<lower=2> n_id ;
}
...
model {
	...
	// likelihood
	for(i_id in 1:n_id){
		obs[,i_id] ~ bernoulli_logit(log_odds_of_success) ;
	}
}
