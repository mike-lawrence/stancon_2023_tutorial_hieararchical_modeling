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
parameters {
	// mu_intercept: value for the mean when time-of-day==0
	real mu_intercept ;
	// mu_tod_beta: effect of time-of-day on mean
	real mu_tod_beta ;
	// eta_intercept: value for the mean when time-of-day==0
	real eta_intercept ;
	// eta_tod_beta: effect of time-of-day on mean
	real eta_tod_beta ;
}
model {
	// priors (adjust when using real data!!)
	mu_intercept ~ std_normal() ;
	mu_tod_beta ~ std_normal() ;
	eta_intercept ~ std_normal() ;
	eta_tod_beta ~ std_normal() ;
	// likelihood
	obs ~ normal_sufficient(
		mu_intercept + mu_tod_beta .* time_of_day
		, exp( eta_intercept + eta_tod_beta .* time_of_day )
	) ;
}
