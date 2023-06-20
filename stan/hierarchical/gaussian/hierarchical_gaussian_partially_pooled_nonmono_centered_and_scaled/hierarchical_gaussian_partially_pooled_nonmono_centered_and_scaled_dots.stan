data {
	...
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
	...
	vector[n_id_centered_and_scaled] id_mu_centered_scaled ;
	vector[n_id_not_centered_nor_scaled] id_mu_uncentered_unscaled ;
}
model {
	...
	id_mu_uncentered_unscaled ~ std_normal() ;
	id_mu_centered_scaled ~ normal(mu_mean, mu_sd) ;
	// computing the derived quantity "id_mu"
	vector[n_id] id_mu ;
	id_mu[id_index_centered_and_scaled] = id_mu_centered_scaled ;
	id_mu[id_index_not_centered_nor_scaled] = (
		id_mu_uncentered_unscaled
		.* mu_sd
		+ mu_mean
	) ;
	...
}
