//Single Stock Ricker Model

data {
int<lower=0> N; // number of data items
vector[N] R_Obs; // recruits
vector[N] S;   // spawners
real logA_mean;
real logA_sig;
real Sig_Gam_Dist;
vector[4] B_means;
vector[4] B_sigs;
}

parameters {
real logA; // intercept
vector<lower=0>[4] Beta; // coefficients for predictors
real<lower=0> sigma; // error scale
}



model {
vector[N-3] logR_Fit;
for (i in 4:N){
  logR_Fit[i-3] = logA + log(S[i]) - 
                   Beta[1]*S[i] - Beta[2]*S[i-1] - 
                   Beta[3]*S[i-2] - Beta[4]*S[i-3];
  R_Obs[i] ~ lognormal(logR_Fit[i-3], sigma); // likelihood
}


//Priors
// lognormal prior on a
logA ~ normal( logA_mean, logA_sig);
// inverse gamma on variance (sigma^2), need jacobian adjustment
pow(sigma, 2) ~ inv_gamma(Sig_Gam_Dist, Sig_Gam_Dist);
// Jacobian adjustment
target += log(2*sigma); // log|x^2 d/dx|
// Normal prior on betas
Beta[1] ~ normal( B_means[1], B_sigs[1]);
Beta[2] ~ normal( B_means[2], B_sigs[1]);
Beta[3] ~ normal( B_means[3], B_sigs[1]);
Beta[4] ~ normal( B_means[4], B_sigs[1]);
}

generated quantities {
vector[N-3] R_Pred;
vector[N-3] R_Fit;
for (i in 4:N){
 R_Pred[i-3] = lognormal_rng(logA + log(S[i]) -  
                   Beta[1]*S[i] - Beta[2]*S[i-1] - 
                   Beta[3]*S[i-2] - Beta[4]*S[i-3], sigma);
 R_Fit[i-3] = exp(logA + log(S[i]) -  
                   Beta[1]*S[i] - Beta[2]*S[i-1] - 
                   Beta[3]*S[i-2] - Beta[4]*S[i-3]);
}
}
