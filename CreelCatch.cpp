
#include <TMB.hpp> 
#include <iostream>

template<class Type>
Type objective_function<Type>::operator() ()
{
 
 // Load data
  DATA_VECTOR(log_C); // Catch
  DATA_VECTOR(log_E); // Effort
  DATA_VECTOR(first_covar); // Covariate
  DATA_VECTOR(second_covar); // Covariate
  DATA_VECTOR(third_covar); // Covariate
  DATA_SCALAR(effort_switch); // Switch to determine effort model structure
  DATA_SCALAR(catch_switch); // Switch to determine catch model structure
  DATA_SCALAR(n_covars); // Scalar to define the number of covariates included
  DATA_IVECTOR(region); // Integer that defines regions
  DATA_IVECTOR(iGL); // Integer to denote great lakes waterbodies
  
  // Create object that is the length of the catch data
  int N = log_C.size();
  Type zero = 0.0;
  
  // Define parameters
  PARAMETER_VECTOR(slope); // Effect of effort on catch
  PARAMETER_VECTOR(q_dev); // Catch intercept
  PARAMETER_VECTOR(tau_int); // Effort intercept
  PARAMETER_VECTOR(tau); // Effect of covariates(s) on effort
  PARAMETER_VECTOR(log_sd); // Sd of catch and effort models
  
  // Define other objects used within the code
  vector<Type> sd = exp(log_sd);
  vector<Type> pred_C(N);
  vector<Type> pred_E(N);
  vector<Type> C_resid(N);
  vector<Type> E_resid(N);
  vector<Type> std_resid_E(N);
  vector<Type> std_resid_C(N);  
  
  using namespace density;
  Type nll = 0.0;  
  
  int it, igl;
  
  vector<Type> log_pred_C = log(pred_C);
  vector<Type> log_pred_E = log(pred_E);
  vector<Type> log_q = log(q_dev);
  
  //effort model
  for(int n = 0;n < N;++n){ 
    it = region(n);
    igl = iGL(n);
    
    // Model without regional effects
    if(effort_switch==0){
      if(n_covars==0){
        log_pred_E(n) = tau_int(0);
      }
      if(n_covars==1){
        if(igl==0){
          log_pred_E(n) = tau_int(0)+ tau(0)*first_covar(n);
        }
        if(igl==1){
          log_pred_E(n) = tau_int(0)+ tau(1)*first_covar(n);
        }
      }
      if(n_covars==2){
        if(igl==0){
          log_pred_E(n) = tau_int(0)+ tau(0)*first_covar(n) + tau(2)*second_covar(n);
        }
        if(igl==1){
          log_pred_E(n) = tau_int(0)+ tau(1)*first_covar(n) + tau(2)*second_covar(n);
        }
      }
      if(n_covars==3){
        if(igl==0){
          log_pred_E(n) = tau_int(0)+ tau(0)*first_covar(n) + tau(2)*second_covar(n)+ tau(3)*third_covar(n);
        }
        if(igl==1){
          log_pred_E(n) = tau_int(0)+ tau(1)*first_covar(n) + tau(2)*second_covar(n)+ tau(3)*third_covar(n);
        };
    }
    }
    
    // Model with regional effects
    if(effort_switch==1){
      if(n_covars==0){
        log_pred_E(n) = tau_int(it);
      }
      if(n_covars==1){
        if(igl==0){
        log_pred_E(n) = tau_int(it)+ tau(0)*first_covar(n);
        }
        if(igl==1){
          log_pred_E(n) = tau_int(it)+ tau(1)*first_covar(n);
        }
      }
      if(n_covars==2){
        if(igl==0){
          log_pred_E(n) = tau_int(it)+ tau(0)*first_covar(n) + tau(2)*second_covar(n);
        }
        if(igl==1){
          log_pred_E(n) = tau_int(it)+ tau(1)*first_covar(n) + tau(2)*second_covar(n);
        }
      }
      if(n_covars==3){
        if(igl==0){
          log_pred_E(n) = tau_int(it)+ tau(0)*first_covar(n) + tau(2)*second_covar(n)+ tau(3)*third_covar(n);
        }
        if(igl==1){
          log_pred_E(n) = tau_int(it)+ tau(1)*first_covar(n) + tau(2)*second_covar(n)+ tau(3)*third_covar(n);
        };
      }
    }
    
    // Define effort model residuals
    E_resid(n) = log_E(n) - log_pred_E(n);
    std_resid_E(n) = E_resid(n)/sd(0);
    
    //catch model formulations
    if(catch_switch==0){log_pred_C(n) = log_q(0) + slope(it) * log_pred_E(n);}
    if(catch_switch==1){log_pred_C(n) = log_q(it) + slope(0) * log_pred_E(n);}
    if(catch_switch==2){log_pred_C(n) = log_q(it) + log_pred_E(n);}
    if(catch_switch==3){log_pred_C(n) = slope(0) * log_pred_E(n);}
    if(catch_switch==4){log_pred_C(n) = log_q(0) + log_pred_E(n);}
    if(catch_switch==5){log_pred_C(n) = log_q(0) + slope(0) * log_pred_E(n);}

    // Define catch model residuals
    C_resid(n) = log_C(n) - log_pred_C(n);
    std_resid_C(n) = C_resid(n)/sd(1);
  }
  
  // Catch and effort model likelihood functions
  for(int n = 0;n < N;++n){ 
    nll -= dnorm(E_resid(n),zero,sd(0),true);
    nll -= dnorm(C_resid(n),zero,sd(1),true);
  }
  
  // Model reporting
  REPORT(tau_int)
  REPORT(slope);
  REPORT(log_pred_C);
  REPORT(log_pred_E);
  REPORT(tau);
  REPORT(log_q);
  REPORT(sd);
  REPORT(E_resid);
  REPORT(C_resid);
  REPORT(std_resid_E);
  REPORT(std_resid_C);
  
  ADREPORT(log_q);
  ADREPORT(slope);
  ADREPORT(tau);
  ADREPORT(tau_int);
  
  return nll;
}
