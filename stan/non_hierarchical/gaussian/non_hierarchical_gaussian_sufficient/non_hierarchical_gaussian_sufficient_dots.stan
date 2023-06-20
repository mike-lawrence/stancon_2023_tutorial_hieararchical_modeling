... // see full code for user-defined `normal_sufficient_lpdf()`
data {
	...
	// obs_mean: mean of observations
	real obs_mean ;
	// obs_var: variance of observations
	real obs_var ;
}
transformed data{
	vector[4] obs = transpose([obs_mean,obs_var,sqrt(n_obs),(n_obs-1.0)/2.0]) ;
}
parameters {
	...
	// eta: log-variance
	real<lower=0> eta ;
}
model {
	...
	eta ~ std_normal() ;
	// likelihood
	obs ~ normal_sufficient(mu,exp(eta)) ;
}
