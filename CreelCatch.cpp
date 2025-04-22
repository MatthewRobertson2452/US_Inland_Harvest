
#include <TMB.hpp> 
#include <iostream>

template<class Type>
Type objective_function<Type>::operator() ()
{
  
  // Load data
  DATA_VECTOR(log_C); // Catch
  DATA_VECTOR(log_E); // Effort
  DATA_VECTOR(wb_area); // Waterbody area
  DATA_IVECTOR(region); //Region
  
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
  
  int it;
  
  vector<Type> log_pred_C = log(pred_C);
  vector<Type> log_pred_E = log(pred_E);
  vector<Type> log_q = log(q_dev);
  
  //effort model
  for(int n = 0;n < N;++n){ 
    it = region(n);
    
    log_pred_E(n) = tau_int(it)+ tau(0)*wb_area(n);
    
    // Define effort model residuals
    E_resid(n) = log_E(n) - log_pred_E(n);
    std_resid_E(n) = E_resid(n)/sd(0);
    
    //catch model formulations
    log_pred_C(n) = log_q(0) + slope(0) * log_pred_E(n);
    
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
