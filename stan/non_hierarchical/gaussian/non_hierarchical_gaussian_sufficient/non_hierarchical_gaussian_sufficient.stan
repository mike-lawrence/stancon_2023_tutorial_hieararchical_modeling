functions{
	real normal_sufficient_lpdf(
		matrix obs
		, vector mean
		, vector variance
	){
		return(
			normal_lpdf(
				obs[,1]
				| mean
				, sqrt(variance) ./ obs[,3]
			)
			+ gamma_lpdf(
				obs[,2]
				| obs[,4]
				, obs[,4] ./ variance
			)
		) ;
	}
	real normal_sufficient_lpdf(
		vector obs
		, real mean
		, real variance
	){
		return(
			normal_lpdf(
				obs[1]
				| mean
				, sqrt(variance) ./ obs[3]
			)
			+ gamma_lpdf(
				obs[2]
				| obs[4]
				, obs[4] ./ variance
			)
		) ;
	}
}
data {
	// n_obs: number of observations
	int<lower=1> n_obs ;
	// obs_mean: mean of observations
	real obs_mean ;
	// obs_var: variance of observations
	real obs_var ;
}
transformed data{
	vector[4] obs = transpose([obs_mean,obs_var,sqrt(n_obs),(n_obs-1.0)/2.0]) ;
}
parameters {
	// mu: mean
	real mu ;
	// eta: log-variance
	real<lower=0> eta ;
}
model {
	// priors (adjust when using real data!!)
	mu ~ std_normal() ;
	eta ~ std_normal() ;
	// likelihood
	obs ~ normal_sufficient(mu,exp(eta)) ;
}
