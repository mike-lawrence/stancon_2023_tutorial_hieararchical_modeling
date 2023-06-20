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
	// log_odds_of_success: log-odds of success
	vector[n_id] id_log_odds_of_success ;
}
model {
	// priors (adjust when using real data!!)
	id_log_odds_of_success ~ std_normal() ;  //n.b. implicit loop
	// likelihood
	obs ~ bernoulli_logit(id_log_odds_of_success[obs_id]) ;
}
