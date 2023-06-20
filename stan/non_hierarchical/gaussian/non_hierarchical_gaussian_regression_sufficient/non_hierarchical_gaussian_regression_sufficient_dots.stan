...
data {
	// n_tod: number of time-of-day observations
	int<lower=2> n_tod ;
	// time_of_day: timing of observations
	vector[n_tod] time_of_day ;
	// obs_mean: mean of observations for each time of day
	vector[n_tod] obs_mean ;
	// obs_var: variance of observations for each time of day
	vector<lower=0>[n_tod] obs_var ;
	// obs_n: count of observations for each time of day
	vector<lower=2>[n_tod] obs_n ;
}
transformed data{
	matrix[n_tod,4] obs ;
	obs[,1] = obs_mean ;
	obs[,2] = obs_var ;
	obs[,3] = sqrt(obs_n) ;
	obs[,4] = (obs_n-1.0)/2.0 ;
}
...
model {
	...
	// likelihood
	obs ~ normal_sufficient(
		mu_intercept + mu_tod_beta .* time_of_day
		, exp( eta_intercept + eta_tod_beta .* time_of_day )
	) ;
}
