
# R version 4.4.2
# TMB version 1.9.16
# ggplot2 version 3.5.1
# ggpubr version 0.6.0

library(TMB)
library(ggplot2)
library(ggpubr)

# Load Data

load("Data/Model_dat.Rdata")

# Run the model -----------------------------------------------------------

# Remove data without waterbody area
useable_dat<-subset(useable_dat, is.na(Area)==FALSE)

# Remove great lakes data
useable_dat<-subset(useable_dat, GL==0)

# One waterbody in Minnesota that was Lake Superior but was spelled incorrectly so did not get captured by Great Lakes map
useable_dat<-subset(useable_dat, WaterbodyID!="MN_1198")

model_run<-list(
  data_type = "2000", # Give info on any data subsets for Rdata naming
  n_covars=1, # 0 is no covariates, 1 is one covariates, 2 is 2 covariates
  first_covar=log(useable_dat$Area),
  second_covar=useable_dat$Area,
  third_covar=useable_dat$Area,
  #### ONLY USED FOR BASIC MODEL
  int_switch = 0, # 0 Means no intercept, #1 means intercept
  ### ONLY USED FOR RE MODEL
  effort_switch=1, # 0 is no random intercepts, 1 is random intercepts
  catch_switch=5 # Switch for random effect formulation in the catch model
)

if(model_run$n_covars==0){
  covars<-"None"
}

tmb.data<-list(
  log_C=log(useable_dat$cpd),
  log_E=log(useable_dat$epd),
  first_covar=model_run$first_covar,
  second_covar=model_run$second_covar,
  third_covar=model_run$third_covar,
  effort_switch=model_run$effort_switch, 
  catch_switch=model_run$catch_switch, 
  n_covars=model_run$n_covars,
  region = useable_dat$istate,
  iGL = useable_dat$GL
)

# Automation code to set-up data/parameters appropriately depending on desired model structure
# Effort intercept 
if(tmb.data$effort_switch==0){ tau_int=1} 
if(tmb.data$effort_switch==1){ tau_int = rep(1, length(unique(useable_dat$istate)))}

# Q modeling
if(tmb.data$catch_switch<3 & tmb.data$catch_switch>0){q_dev = rep(1, length(unique(useable_dat$istate)))}  
if(tmb.data$catch_switch>2){q_dev = 0.1}
if(tmb.data$catch_switch==0){q_dev = 0.1}

# Slope modeling
if(tmb.data$catch_switch==0){slope=rep(1,  length(unique(useable_dat$istate)))} 
if(tmb.data$catch_switch>0){slope = 1}

# Number of covariates
if(tmb.data$n_covars==0){tau=rep(1,1)}
if(tmb.data$n_covars==1){tau=rep(1,2)}
if(tmb.data$n_covars==2){tau=rep(1,3)}
if(tmb.data$n_covars==3){tau=rep(1,4)}

# Parameter definitions
parameters<-list(
  slope=slope,
  q_dev = q_dev,
  tau_int = tau_int,
  tau = tau,
  log_sd = rep(log(2),2)
)

# Naming the random effects
rname_temp = na.omit(c(ifelse(tmb.data$catch_switch==0,  "slope" ,NA),
                       ifelse(tmb.data$catch_switch<3,  "q_dev" ,NA),
                       ifelse(tmb.data$effort_switch==1,  "tau_int" ,NA)))
rname<-NULL
if(length(rname_temp)!=0)rname<-rname_temp

# Mapping out parameters depending on model formulation
map<-list(
  tau=factor(c("1",NA))
)

# Load cpp template
dyn.unload("CreelCatch")
TMB::compile("CreelCatch.cpp")
dyn.load("CreelCatch")

# Define data and parameters within the template
obj <- MakeADFun(tmb.data,parameters,map=map,random=rname,
                 DLL="CreelCatch",inner.control=list(maxit=500,trace=F))

# Run the model
opt<-nlminb(obj$par,obj$fn,obj$gr,
            control = list(trace=10,eval.max=2000,iter.max=1000))

# Get model output
rep = obj$report()
sdrep<-sdreport(obj)

# Check parameter estimates and CIs
sdrep$value+qnorm(0.975)*sdrep$sd
sdrep$value-qnorm(0.975)*sdrep$sd


# Plot catch - effort relationship ----------------------------------------

pred_E<-seq(from=-1, to=10, by=0.01)

pred_C<- rep$log_q+rep$slope*pred_E
pred_C_low<-(rep$log_q-qnorm(0.975)*sdrep$sd[1])+(rep$slope-qnorm(0.975)*sdrep$sd[2])*pred_E
pred_C_high<-(rep$log_q+qnorm(0.975)*sdrep$sd[1])+(rep$slope+qnorm(0.975)*sdrep$sd[2])*pred_E

pred_c_e<-data.frame(pred_E=pred_E, pred_C=pred_C, pred_C_low=pred_C_low, pred_C_high=pred_C_high)
ce_dat<-data.frame(log_E=tmb.data$log_E, log_C=tmb.data$log_C)

p1<-ggplot()+
  geom_ribbon(data=pred_c_e, aes(ymin=pred_C_low, ymax=pred_C_high, x=pred_E), fill="lightblue", alpha=0.5)+
  geom_point(data=ce_dat, aes(x=log_E, y=log_C), col="darkgrey")+
  geom_line(data=pred_c_e, aes(x=pred_E, y=pred_C), size=1.5)+#xlim(0,10)+
  xlab("log(Effort Hours per Day)")+ylab("log(Catch Numbers per Day)")+
  theme_bw()+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))

# Plot effort - waterbody area relationship -------------------------------

pred_wb_area<-seq(from=min(log(useable_dat$Area)), to=max(log(useable_dat$Area)), by=0.01)
pred_area<-mean(rep$tau_int) + rep$tau[1]*pred_wb_area
pred_area_low<-mean(rep$tau_int) + (rep$tau[1]-qnorm(0.975)*sdrep$sd[3])*pred_wb_area
pred_area_high<-mean(rep$tau_int) + (rep$tau[1]+qnorm(0.975)*sdrep$sd[3])*pred_wb_area

pred_area_df<-data.frame(pred_wb_area=pred_wb_area,pred_area=pred_area, pred_area_low=pred_area_low, pred_area_high=pred_area_high)
area_dat<-data.frame(log_E=tmb.data$log_E, area=tmb.data$first_covar)

p2<-ggplot()+
  geom_ribbon(data=pred_area_df, aes(ymin=pred_area_low, ymax=pred_area_high, x=pred_wb_area), fill="lightblue", alpha=0.5)+
  geom_point(data=area_dat, aes(y=log_E, x=area), col="darkgrey")+
  geom_line(data=pred_area_df, aes(x=pred_wb_area, y=pred_area), size=1.5)+#xlim(0,10)+
  ylab("log(Effort Hours per Day)")+xlab(bquote(bold('Waterbody Area log'(km^2))))+
  theme_bw()+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))


# Plot regional random effects --------------------------------------------

val_names<-names(sdrep$value)
ind<-val_names=="tau_int"

high_conf<-sdrep$value[ind] + qnorm(0.975)*sdrep$sd[ind]
low_conf<-sdrep$value[ind] - qnorm(0.975)*sdrep$sd[ind]
est<-sdrep$value[ind]

int_df<-data.frame(est, low_conf, high_conf, regions=c("Midwest","Northeast","Northern Great Plains","Southeast","Southwest","Southern Great Plains","Northwest"))

p3<-ggplot(int_df, aes(x=reorder(regions,est), y=est))+
  geom_point(size=4)+
  geom_segment(aes(x=regions,xend=regions,y=low_conf,yend=high_conf), data=int_df)+
  theme_bw()+xlab("Region")+ylab("Regional Effect")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

jpeg("general_model_output.jpeg", width=8,height=10, units="in", res=400)
ggarrange(p1,ggarrange(p2, p3, ncol = 2, labels=c("B","C")),
          nrow = 2, labels="A"
) 
dev.off()

save(rep, file="Model_output.RData")