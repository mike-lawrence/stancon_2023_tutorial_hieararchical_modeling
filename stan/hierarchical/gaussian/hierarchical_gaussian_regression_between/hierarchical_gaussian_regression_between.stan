data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	vector[n_obs*n_id] obs ;
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
	// n_x_across_id: number of across-id predictors
	int<lower=1> n_x_across_id ;
	// x_across_id: matrix of across-id predictors
	matrix[n_id,n_x_across_id] x_across_id ;
}
transformed data{
	// x_across_id_transposed: matrix of across-id predictors
	matrix[n_x_across_id,n_id] x_across_id_transposed = transpose(x_across_id) ;
}
parameters {
	// sigma: likelihood sd
	real<lower=0> sigma ;
	// x_across_coef: coefficients for the effect of the across-id predictors
	vector[n_x_across_id] x_across_coef ;
	// sds: sd (across individuals) mu in each x_across group
	row_vector<lower=0>[n_x_across_id] sds ;
	// id_mu_: coefficients for each id expressed as z-scores
	//		Note: "_" suffix used to denote that this is a "helper" variable for the parameterization
	matrix[n_id,n_x_across_id] id_mu_ ;
}
model {
	// priors (adjust when using real data!!)
	sigma ~ weibull(2,1) ;
	x_across_coef ~ std_normal() ;
	sds ~ weibull(2,1) ;
	to_vector(id_mu_) ~ std_normal() ;

	// means: mean (across individuals) mu in each x_across group
	row_vector[n_x_across_id] means = (
		columns_dot_product(
			rep_matrix(x_across_coef,n_id)
			, x_across_id
		)
	) ;

	// computing the non-z-score mu & eta for each id
	vector[n_id] id_mu = (
		id_mu_
		.* rep_matrix(sds,n_id)
		+ rep_matrix(means,n_id)
	) ;

	// likelihood
	obs ~ normal(
		id_mu[,1][obs_id]
		, sigma
	) ;
}
