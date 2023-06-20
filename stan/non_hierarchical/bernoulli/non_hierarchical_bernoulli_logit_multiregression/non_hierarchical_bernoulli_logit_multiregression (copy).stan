data {
	// n_x_cols: number of predictor-variables in x (as columns)
	int<lower=1> n_x_cols ;
	// n_x_rows: number of combinations (rows) of the predictor variables in x
	int<lower=1> n_x_rows ;
	// x: predictor matrix
	matrix[n_x_rows,n_x_cols] x ;
	// obs: array of bernoulli observations, one for each row in x
	array[n_x_rows] int<lower=0,upper=1> obs ;
}
transformed data{
	matrix[n_x_cols,n_x_rows] x_transpose ; // so we can use `columns_dot_product()`, which is faster than `rows_dot_product()`
}
parameters {
	// intercept: log-odds of success at the intercept
	real intercept ;
	// beta: effect of each predictor in x on log-odds of success
	vector[n_x_cols] beta ;
}
model {
	// priors (adjust when using real data!!)
	intercept ~ std_normal() ;
	beta ~ std_normal() ;
	// likelihood
	obs ~ bernoulli_logit(
		intercept
		+ columns_dot_product(
			rep_matrix(beta,n_x_rows)
			, x_transpose
		)
	) ;
}
