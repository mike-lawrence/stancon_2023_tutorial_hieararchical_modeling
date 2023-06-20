data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	vector[n_obs*n_id] obs ;
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
}
parameters {
	// chol_fac_cor: correlation between mu & eta, cholesky-factored representation
	cholesky_factor_corr[2] chol_fac_cor ;
	// means: mean (across individuals) mu & eta
	row_vector[2] means ;
	// sds: sd (across individuals) mu & eta
	row_vector<lower=0>[2] sds ;
	// id_mu_eta_: mu & eta for each id expressed as z-scores
	//		Note: "_" suffix used to denote that this is a "helper" variable for the parameterization
	matrix[n_id,2] id_mu_eta_ ;
}
model {
	// priors (adjust when using real data!!)
	means ~ std_normal() ;
	sds ~ weibull(2,1) ;
	to_vector(id_mu_eta_) ~ std_normal() ;
	chol_fac_cor ~ lkj_corr_cholesky(1) ;

	// computing the non-z-score mu & eta for each id
	matrix[n_id,2] id_mu_eta = (
		id_mu_eta_
		.* diag_pre_multiply(  // MIKE: DOUBLE CHECK THIS
			sds
			, chol_fac_cor
		)
		+ rep_matrix(means,n_id)
	) ;

	// likelihood
	obs ~ normal(
		id_mu_eta[,1][obs_id]
		, sqrt(exp(id_mu_eta[,2]))[obs_id]
	) ;
}
