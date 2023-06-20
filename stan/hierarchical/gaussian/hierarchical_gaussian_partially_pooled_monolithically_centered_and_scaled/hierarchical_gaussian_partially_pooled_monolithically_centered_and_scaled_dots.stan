...
parameters {
	...
	// mu_mean: mean (across individuals) likelihood mean
	real mu_mean ;
	// mu_sd: sd (across individuals) likelihood mean
	real<lower=0> mu_sd ;
	...
}
model {
	// priors (adjust when using real data!!)
	mu_mean ~ std_normal() ;
	mu_sd ~ weibull(2,1) ;
	id_mu ~ normal(mu_mean, mu_sd) ;
	...
}
