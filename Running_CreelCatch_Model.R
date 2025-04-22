
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

tmb.data<-list(
  log_C=log(useable_dat$cpd),
  log_E=log(useable_dat$epd),
  wb_area=log(useable_dat$Area),
  region = useable_dat$istate
)

# Parameter definitions
parameters<-list(
  slope= 1,
  q_dev = 0.1,
  tau_int = rep(1, length(unique(useable_dat$istate))),
  tau = 1,
  log_sd = rep(log(2),2)
)

rname = c(
  "tau_int"
)

# Load cpp template
dyn.unload("CreelCatch")
TMB::compile("CreelCatch.cpp")
dyn.load(dynlib("CreelCatch"))

# Define data and parameters within the template
obj <- MakeADFun(tmb.data,parameters,random=rname,
                 DLL="CreelCatch",inner.control=list(maxit=500,trace=F))

# Run the model
opt<-nlminb(obj$par,obj$fn,obj$gr,
            control = list(trace=10,eval.max=2000,iter.max=1000))

2*opt$objective+ 2*length(opt$par) # AIC

# Get model output
rep = obj$report()
sdrep<-sdreport(obj)


# Calculate R^2 based on Nakagawa and Schielzeth (2013)
fe_var_E<-var(rep$tau*tmb.data$wb_area) #fixed effects variance from effort model
fe_var_C<-var(rep$log_q + rep$slope*rep$log_pred_E) #fixed effects variance from catch model

u_hat <- obj$env$last.par[3:9] # extract random effects from effort model
re_var <- var(u_hat) #calculate variance of random effects

var_resid_E<-rep$sd[1] #residual variance from effort model
var_resid_C<-rep$sd[2] #residual variance from catch model

conditional_r2_E<-(fe_var_E+re_var)/(fe_var_E+re_var+var_resid_E) #conditional r2 from effort model
marginal_r2_C<-(fe_var_C)/(fe_var_C+var_resid_C) #marginal r2 from catch model (no random effects)


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
  geom_line(data=pred_c_e, aes(x=pred_E, y=pred_C), linewidth=1.5)+#xlim(0,10)+
  xlab("log(Effort Hours per Day)")+ylab("log(Catch Numbers per Day)")+
  theme_bw()+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))

# Plot effort - waterbody area relationship -------------------------------

pred_wb_area<-seq(from=min(log(useable_dat$Area)), to=max(log(useable_dat$Area)), by=0.01)
pred_area<-mean(rep$tau_int) + rep$tau[1]*pred_wb_area
pred_area_low<-mean(rep$tau_int) + (rep$tau[1]-qnorm(0.975)*sdrep$sd[3])*pred_wb_area
pred_area_high<-mean(rep$tau_int) + (rep$tau[1]+qnorm(0.975)*sdrep$sd[3])*pred_wb_area

pred_area_df<-data.frame(pred_wb_area=pred_wb_area,pred_area=pred_area, pred_area_low=pred_area_low, pred_area_high=pred_area_high)
area_dat<-data.frame(log_E=tmb.data$log_E, area=tmb.data$wb_area)

p2<-ggplot()+
  geom_ribbon(data=pred_area_df, aes(ymin=pred_area_low, ymax=pred_area_high, x=pred_wb_area), fill="lightblue", alpha=0.5)+
  geom_point(data=area_dat, aes(y=log_E, x=area), col="darkgrey")+
  geom_line(data=pred_area_df, aes(x=pred_wb_area, y=pred_area), linewidth=1.5)+
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


# Effort residual plots -------------------------------------------------------

effort_resids<-data.frame(resids= rep$E_resid, std_resids = rep$std_resid_E,
                          region = tmb.data$region, wb_area = tmb.data$wb_area,
                          effort_dat = tmb.data$log_E, effort_pred = rep$log_pred_E,
                          survey_time = useable_dat$Duration)

jpeg("effort_resid_hist.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=effort_resids, aes(x=resids))+
  geom_histogram(colour="black",fill="lightblue")+
  geom_vline(xintercept=0, col="red", linetype="dashed")+ 
  theme_bw()+xlab("Effort Residuals")+ylab("Count")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

jpeg("effort_qq.jpeg", width=6,height=4, units="in", res=400)
qqnorm(effort_resids$resids, pch=19)
qqline(effort_resids$resids, col="red")
dev.off()

jpeg("effort_obs_pred.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=effort_resids, aes(x=effort_dat, y=effort_pred))+
  geom_point(colour="black",fill="lightblue")+
  coord_cartesian(xlim=c(-1,11),ylim=c(-1,11))+
  geom_abline(intercept=0, slope=1, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Effort) Observations")+ylab("log(Effort) Predictions")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

jpeg("effort_resid_pred.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=effort_resids, aes(x=effort_pred, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Effort) Predictions")+ylab("Standardized Effort Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

jpeg("effort_resid_wb.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=effort_resids, aes(x=wb_area, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Waterbody Area)")+ylab("Standardized Effort Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

effort_resids$region<-factor(effort_resids$region, 
                             labels=c("Midwest","Northeast","Northern Great Plains","Southeast","Southwest","Southern Great Plains","Northwest"))

jpeg("effort_resid_wb_region.jpeg", width=7,height=7, units="in", res=400)
ggplot(data=effort_resids, aes(x=wb_area, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Waterbody Area)")+ylab("Standardized Effort Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))+
  facet_wrap(~region)
dev.off()

jpeg("effort_resid_surv_duration.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=effort_resids, aes(x=survey_time, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=2)+ 
  theme_bw()+xlab("Survey Duration (days)")+ylab("Standardized Effort Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

# Catch residual plots -------------------------------------------------------

catch_resids<-data.frame(resids= rep$C_resid, std_resids = rep$std_resid_C,
                         region = tmb.data$region, wb_area = tmb.data$wb_area,
                         catch_dat = tmb.data$log_C, catch_pred = rep$log_pred_C,
                         survey_time = useable_dat$Duration,
                         effort_pred = rep$log_pred_E)

jpeg("catch_resid_hist.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=catch_resids, aes(x=resids))+
  geom_histogram(colour="black",fill="lightblue")+
  geom_vline(xintercept=0, col="red", linetype="dashed")+ 
  theme_bw()+xlab("Residuals")+ylab("Count")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

jpeg("catch_qq.jpeg", width=6,height=4, units="in", res=400)
qqnorm(catch_resids$resids, pch=19)
qqline(catch_resids$resids, col="red")
dev.off()

jpeg("catch_obs_pred.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=catch_resids, aes(x=catch_dat, y=catch_pred))+
  geom_point(colour="black",fill="lightblue")+
  coord_cartesian(xlim=c(-1,11),ylim=c(-1,11))+
  geom_abline(intercept=0, slope=1, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Catch) Observations")+ylab("log(Catch) Predictions")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

jpeg("catch_resid_pred.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=catch_resids, aes(x=catch_pred, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Catch) Predictions")+ylab("Standardized Catch Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

jpeg("catch_resid_wb.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=catch_resids, aes(x=wb_area, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Waterbody Area)")+ylab("Standardized Catch Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

catch_resids$region<-factor(catch_resids$region, 
                            labels=c("Midwest","Northeast","Northern Great Plains","Southeast","Southwest","Southern Great Plains","Northwest"))

jpeg("catch_resid_wb_region.jpeg", width=7,height=7, units="in", res=400)
ggplot(data=catch_resids, aes(x=wb_area, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Waterbody Area)")+ylab("Standardized Catch Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))+
  facet_wrap(~region)
dev.off()

jpeg("catch_resid_effort.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=catch_resids, aes(x=effort_pred, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("log(Effort) Predictions")+ylab("Standardized Catch Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()

jpeg("catch_resid_surv_duration.jpeg", width=6,height=4, units="in", res=400)
ggplot(data=catch_resids, aes(x=survey_time, y=std_resids))+
  geom_point(colour="black",fill="lightblue")+
  geom_smooth(se=FALSE)+
  geom_hline(yintercept=0, col="red", linetype="dashed", linewidth=1)+ 
  theme_bw()+xlab("Survey Duration (days)")+ylab("Standardized Catch Residuals")+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))
dev.off()


save(rep, file="Model_output.RData")