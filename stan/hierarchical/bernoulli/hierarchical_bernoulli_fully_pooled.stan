data {
	// n_obs: number of bernoulli observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of bernoulli observations
	array[n_obs,n_id] int<lower=0,upper=1> obs ;
}
parameters {
	// log_odds_of_success: log-odds of success
	real log_odds_of_success ;
}
model {
	// priors (adjust when using real data!!)
	log_odds_of_success ~ std_normal() ;
	// likelihood
	for(i_id in 1:n_id){
		obs[,i_id] ~ bernoulli_logit(log_odds_of_success) ;
	}
}
