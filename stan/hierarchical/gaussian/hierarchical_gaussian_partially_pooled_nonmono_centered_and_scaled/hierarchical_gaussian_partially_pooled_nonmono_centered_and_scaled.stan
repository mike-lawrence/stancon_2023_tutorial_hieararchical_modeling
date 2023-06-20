data {
	// n_obs: number of gaussian observations
	int<lower=1> n_obs ;
	// n_id: number of "individuals"
	int<lower=2> n_id ;
	// obs: array of gaussian observations
	vector[n_obs*n_id] obs ;
	// obs_id: array of ids associated with each obs
	array[n_obs*n_id] int<lower=1,upper=n_id> obs_id ;
	// id_centered_and_scaled: array of binary toggles for each id indicating whether it should be centered/scaled
	array[n_id] int<lower=0,upper=1> id_centered_and_scaled ;
}
transformed data{
	// n_id_centered_and_scaled: number of individuals to be centered-and-scaled
	int<lower=0> n_id_centered_and_scaled = sum(id_centered_and_scaled);
	// n_id_not_centered_nor_scaled: number of individuals to be uncentered-and-unscaled
	int<lower=0> n_id_not_centered_nor_scaled = n_id - n_id_centered_and_scaled ;
	// id_index_centered_and_scaled: which id's should be centered-and-scaled
	array[n_id_centered_and_scaled] int<lower=1,upper=n_id> id_index_centered_and_scaled ;
	// id_index_not_centered_nor_scaled: which id's should be centered-and-scaled
	array[n_id_not_centered_nor_scaled] int<lower=1,upper=n_id> id_index_not_centered_nor_scaled ;
	// fill the
	int i = 1 ;
	int j = 1 ;
	for(i_id in 1:n_id){
		if(id_centered_and_scaled[i_id]==1){
			id_index_centered_and_scaled[i] = i_id ;
			i += 1 ;
		}else{
			id_index_not_centered_nor_scaled[j] = i_id ;
			j += 1 ;
		}
	}
}
parameters {
	// sigma: likelihood sd
	real<lower=0> sigma ;
	// mu_mean: mean (across individuals) likelihood mean
	real mu_mean ;
	// mu_sd: sd (across individuals) likelihood mean
	real<lower=0> mu_sd ;
	// id_mu_centered_scaled: helper variable for centered-and-scaled individuals
	vector[n_id_centered_and_scaled] id_mu_centered_scaled ;
	// id_mu_centered_scaled: helper variable for uncentered-and-unscaled individuals
	vector[n_id_not_centered_nor_scaled] id_mu_uncentered_unscaled ;
}
model {
	// priors (adjust when using real data!!)
	sigma ~ weibull(2,1) ;
	mu_mean ~ std_normal() ;
	mu_sd ~ weibull(2,1) ;
	id_mu_uncentered_unscaled ~ std_normal() ;
	id_mu_centered_scaled ~ normal(mu_mean, mu_sd) ;
	// computing the derived quantity "id_mu"
	// id_mu: likelihood mean for each individual
	vector[n_id] id_mu ;
	id_mu[id_index_centered_and_scaled] = id_mu_centered_scaled ;
	id_mu[id_index_not_centered_nor_scaled] = (
		id_mu_uncentered_unscaled
		.* mu_sd
		+ mu_mean
	) ;
	// likelihood
	obs ~ normal(id_mu[obs_id], sigma) ;
}
