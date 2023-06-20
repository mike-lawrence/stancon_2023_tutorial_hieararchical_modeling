...
parameters {
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

	// computing the non-z-score mu & eta for each id
	matrix[n_id,2] id_mu_eta = (
		id_mu_eta_
		.* rep_matrix(sds,n_id)
		+ rep_matrix(means,n_id)
	) ;

	// likelihood
	obs ~ normal(
		id_mu_eta[,1][obs_id]
		, sqrt(exp(id_mu_eta[,2]))[obs_id]
	) ;
}
