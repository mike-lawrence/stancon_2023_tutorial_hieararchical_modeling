...
parameters {
	...
	// mu_: likelihood mean expressed as z-scores
	//		Note: "_" suffix used to denote that this is a "helper" variable for the parameterization
	vector[n_id] id_mu_ ;
}
model {
	...
	id_mu_ ~ std_normal() ;

	// computing the derived quantity "id_mu"
	vector[n_id] id_mu = (
		id_mu_
		.* mu_sd
		+ mu_mean
	) ;

	...
}
