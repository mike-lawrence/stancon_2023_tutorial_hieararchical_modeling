data {
	// n_x_cols: number of predictor-variables in x (as columns)
	int<lower=1> n_x_cols ;
	// n_x_rows: number of combinations (rows) of the predictor variables in x
	int<lower=1> n_x_rows ;
	// x: predictor matrix
	matrix[n_x_rows,n_x_cols] x ;
	// obs: observation for each row in x
	vector[n_x_rows] obs ;
}
transformed data{
	matrix[n_x_cols,n_x_rows] x_transpose ; // so we can use `columns_dot_product()`, which is faster than `rows_dot_product()`
}
parameters {
	// mu_intercept: value for the mean at the intercept
	real mu_intercept ;
	// mu_tod_beta: effect of each predictor on the mean
	vector[n_x_cols] mu_beta ;
	// eta_intercept: value for the log-variance at the intercept
	real eta_intercept ;
	// eta_tod_beta: effect of each predictor on the log-variance
	vector[n_x_cols] eta_beta ;
}
model {
	// priors (adjust when using real data!!)
	mu_intercept ~ std_normal() ;
	mu_beta ~ std_normal() ;
	eta_intercept ~ std_normal() ;
	eta_beta ~ std_normal() ;
	// likelihood
	obs ~ normal(
		(
			mu_intercept
			+ (
				columns_dot_product(
					rep_matrix(mu_beta,n_x_rows)
					, x_transpose
				)
			)
		)
		, sqrt(exp(
			eta_intercept
			+ (
				columns_dot_product(
					rep_matrix(eta_beta,n_x_rows)
					, x_transpose
				)
			)
		))
	) ;
}
