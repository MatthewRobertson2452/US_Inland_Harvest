
#include <TMB.hpp> 
#include <iostream>

template<class Type>
Type objective_function<Type>::operator() ()
{
 
  DATA_VECTOR(log_C);
  DATA_VECTOR(log_E);
  DATA_VECTOR(first_covar);
  DATA_VECTOR(second_covar);
  DATA_VECTOR(third_covar);
  DATA_SCALAR(effort_switch);
  DATA_SCALAR(catch_switch);
  DATA_SCALAR(n_covars);
  DATA_IVECTOR(season);
  DATA_IVECTOR(iGL);
  
  int N = log_C.size();
  Type zero = 0.0;
  
  PARAMETER_VECTOR(slope);
  PARAMETER_VECTOR(q_dev);
  PARAMETER_VECTOR(tau_int);
  PARAMETER_VECTOR(tau_season);
  PARAMETER_VECTOR(tau);
  PARAMETER_VECTOR(log_sd);
  
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
  
  for(int n = 0;n < N;++n){ 
    it = season(n);
    igl = iGL(n);
    
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
    
    E_resid(n) = log_E(n) - log_pred_E(n);
    std_resid_E(n) = E_resid(n)/sd(0);
    
    if(catch_switch==0){log_pred_C(n) = log_q(0) + slope(it) * log_pred_E(n);}
    if(catch_switch==1){log_pred_C(n) = log_q(it) + slope(0) * log_pred_E(n);}
    if(catch_switch==2){log_pred_C(n) = log_q(it) + log_pred_E(n);}
    if(catch_switch==3){log_pred_C(n) = slope(0) * log_pred_E(n);}
    if(catch_switch==4){log_pred_C(n) = log_q(0) + log_pred_E(n);}
    if(catch_switch==5){log_pred_C(n) = log_q(0) + slope(0) * log_pred_E(n);}

    C_resid(n) = log_C(n) - log_pred_C(n);
    std_resid_C(n) = C_resid(n)/sd(1);
  }
  
  for(int n = 0;n < N;++n){ 
    nll -= dnorm(E_resid(n),zero,sd(0),true);
    nll -= dnorm(C_resid(n),zero,sd(1),true);
  }
  
  REPORT(tau_int)
  REPORT(slope);
  REPORT(log_pred_C);
  REPORT(log_pred_E);
  REPORT(tau);
  REPORT(tau_season);
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
