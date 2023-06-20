data {
	...
	// n_obs: array of observation counts per row in x
	array[n_x_rows] int<lower=1> n_obs ;
	// n_successes: array of "success" counts per row in x
	array[n_x_rows] int<lower=0> n_successes ;
}
...
model {
	// priors (adjust when using real data!!)
	intercept ~ std_normal() ;
	beta ~ std_normal() ;
	// likelihood
	n_successes ~ binomial_logit(
		n_obs
		, (
			intercept
			+ columns_dot_product(
				rep_matrix(beta,n_x_rows)
				, x_transpose
			)
		)
	) ;
}
