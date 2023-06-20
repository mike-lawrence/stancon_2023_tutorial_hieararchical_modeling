...
parameters {
	// chol_fac_cor: correlation between mu & eta, cholesky-factored representation
	cholesky_factor_corr[2] chol_fac_cor ;
...
}
model {
	...
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

	...
}
