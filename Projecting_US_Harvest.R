
load("Data/all_states_nhd_for_modeling.RData")

load("Model_output.RData")

#US National survey claims there were 35.1 million freshwater anglers in 2022
fishers<-35000000

# Extrapolate for all waterbodies -----------------------------------

sub_all_nhd<-subset(full_nhd, (fcode==39004|fcode==39009|fcode==39010|fcode==39011|fcode==39012|fcode==43600))

wisc_E<-rep(NA, length(sub_all_nhd$perm_id))
for(j in 1:length(sub_all_nhd$perm_id)){
  wisc_E[j]<-rep$tau_int[sub_all_nhd$istate[j]+1] + rep$tau[1]*log(sub_all_nhd$area[j])
}
all_total_e<-sum(exp(wisc_E))*365
all_e_per_fisher<-(sum(exp(wisc_E))*365)/(fishers)


wisc_C<-rep$log_q + rep$slope*wisc_E
all_total_c<-sum(exp(wisc_C))*365
all_c_per_fisher<-(sum(exp(wisc_C))*365)/(fishers)

#Assuming every waterbody is fished gives us 58 billion fish caught annually
all_total_c/1000000000

#Assuming every waterbody is fished tells us that each fisher catches 1700 fish a year
all_c_per_fisher

# Extrapolate based on areas > 0.16 km2 -----------------------------------

#min based on 5% wb quantile
sub_all_nhd<-subset(full_nhd, (fcode==39004|fcode==39009|fcode==39010|fcode==39011|fcode==39012|fcode==43600) & area>0.16)

prop_lakes<-c(1,2,3,4,5,10,20)
prop_lakes_lab<-c("100%","50%", "33%", "25%", "20%","10%","5%")

c_per_fisher<-matrix(nrow=100, ncol=7)
colnames(c_per_fisher)<-prop_lakes_lab

e_per_fisher<-matrix(nrow=100, ncol=7)
colnames(e_per_fisher)<-prop_lakes_lab

total_c<-matrix(nrow=100, ncol=7)
colnames(total_c)<-prop_lakes_lab

total_e<-matrix(nrow=100, ncol=7)
colnames(total_e)<-prop_lakes_lab


for(k in 1:7){
  for(i in 1:100){
    sm_size<-subset(sub_all_nhd, area<=1)
    int_size<-subset(sub_all_nhd, area>1 & area <7)
    big_size<-subset(sub_all_nhd, area>=7)
    
    new_small_lake_areas<-sm_size[sample(nrow(sm_size), length(sm_size$perm_id)/prop_lakes[k]),]
    new_int_lake_areas<-int_size[sample(nrow(int_size), length(int_size$perm_id)),]
    new_big_lake_areas<-big_size[sample(nrow(big_size), length(big_size$perm_id)),]
    
    new_lake_areas<-rbind( new_small_lake_areas,new_int_lake_areas, new_big_lake_areas)
    
    wisc_E<-rep(NA, length(new_lake_areas$perm_id))
    for(j in 1:length(new_lake_areas$perm_id)){
      wisc_E[j]<-rep$tau_int[new_lake_areas$istate[j]+1] + rep$tau[1]*log(new_lake_areas$area[j])
    }
    total_e[i,k]<-sum(exp(wisc_E))*365
    e_per_fisher[i,k]<-(sum(exp(wisc_E))*365)/(fishers)
    
    
    wisc_C<-rep$log_q + rep$slope*wisc_E
    total_c[i,k]<-sum(exp(wisc_C))*365
    c_per_fisher[i,k]<-(sum(exp(wisc_C))*365)/(fishers)
  }
}

c_per_fisher_df<-data.frame(catch=c(c_per_fisher), lake_sub=factor(rep(colnames(c_per_fisher),each=length(c_per_fisher[,1]))))

level_order=c("100%","50%","33%","25%","20%","10%","5%")

e_per_fisher_df<-data.frame(catch=c(e_per_fisher), lake_sub=factor(rep(colnames(e_per_fisher),each=length(e_per_fisher[,1]))))

level_order=c("100%","50%","33%","25%","20%","10%","5%")


# Extrapolate based on creel cdf ------------------------------------------

break_pts<-seq(0,50,by=0.5)
# transforming the data
data_transform = cut(useable_dat$Area, break_pts,
                     right=FALSE)
# creating the frequency table
freq_table = table(data_transform)

cumulative_freq = c(0, cumsum(freq_table))/max(cumsum(freq_table))
plot(break_pts, cumulative_freq,
     xlab="Area_sq_km",
     ylab="Cumulative Frequency", pch=19, xlim=c(0,40))


cum_freq_df<-data.frame(cum_freq=cumulative_freq, area=break_pts)


new_list<-list()
sub_wisc_nhd<-subset(full_nhd, (fcode==39004|fcode==39009|fcode==39010|fcode==39011|fcode==39012|fcode==43600) & area<7000)
for(i in 2:length(break_pts)){
  if(i<length(break_pts)){
    sub_nhd<-subset(sub_wisc_nhd, area<=break_pts[i] & area>break_pts[i-1])
  }
  if(i==length(break_pts)){
    sub_nhd<-subset(sub_wisc_nhd, area>break_pts[i])
  }
  if(i==2){
    rest_nhd<-subset(sub_wisc_nhd, area>break_pts[i])
    new_area<-sub_nhd[sample(nrow(sub_nhd), cum_freq_df$cum_freq[i-1]*length(rest_nhd$perm_id)),]
  }
  if(i>2){
    if(length(sub_nhd$perm_id)>round((cum_freq_df$cum_freq[i-1]-cum_freq_df$cum_freq[i-2])*length(rest_nhd$perm_id),0)){
      new_area<-sub_nhd[sample(nrow(sub_nhd), round((cum_freq_df$cum_freq[i-1]-cum_freq_df$cum_freq[i-2])*length(rest_nhd$perm_id),0)),]
    }else{
      new_area<-sub_nhd
    }
  }
  new_list[[i]]<-new_area
}

lst2 <- lapply(new_list,function(x) cbind(rowname=rownames(x),x))
df1 <- Reduce(function(x,y) merge(x,y,all=T),lst2)

new_lake_areas<-df1

break_pts<-seq(0,50,by=0.5)
# transforming the data
data_transform = cut(useable_dat$Area, break_pts,
                     right=FALSE)
# creating the frequency table
freq_table = table(data_transform)

cumulative_freq = c(0, cumsum(freq_table))/max(cumsum(freq_table))
plot(break_pts, cumulative_freq,
     xlab="Area_sq_km",
     ylab="Cumulative Frequency", pch=19, xlim=c(0,40))

data_transform = cut(df1$area, break_pts,
                     right=FALSE)
# creating the frequency table
freq_table = table(data_transform)

cumulative_freq_nhd = c(0, cumsum(freq_table))/max(cumsum(freq_table))
points(break_pts, cumulative_freq_nhd,
       xlab="Area_sq_km",
       ylab="Cumulative Frequency", col="red")


wisc_E<-rep(NA, length(new_lake_areas$perm_id))
for(j in 1:length(new_lake_areas$perm_id)){
  wisc_E[j]<-rep$tau_int[new_lake_areas$istate[j]+1] + rep$tau[1]*log(new_lake_areas$area[j])
}

wisc_C<-rep$log_q + rep$slope*wisc_E


# Plot combined extrapolations from both methods --------------------------

new_c_per_fisher<-data.frame(catch=(sum(exp(wisc_C))*365)/(fishers), lake_sub="CDF")

c_per_fisher_df<-rbind(c_per_fisher_df,new_c_per_fisher)

level_order=c("100%","50%","33%","25%","20%","10%","5%", "CDF")

new_e_per_fisher<-data.frame(catch=(sum(exp(wisc_E))*365)/(fishers), lake_sub="CDF")

e_per_fisher_df<-rbind(e_per_fisher_df,new_e_per_fisher)

level_order=c("100%","50%","33%","25%","20%","10%","5%", "CDF")

median_c_per_fisher<-aggregate(c_per_fisher_df$catch, by=list(c_per_fisher_df$lake_sub), FUN="median")
median_e_per_fisher<-aggregate(e_per_fisher_df$catch, by=list(e_per_fisher_df$lake_sub), FUN="median")

p1<-ggplot(data=median_c_per_fisher, aes(x=factor(Group.1, level=level_order), y=x))+
  geom_hline(yintercept=36, colour="darkgrey", linetype="dashed", linewidth=1)+
  geom_text(x=7.5, y=66, label="Canada", colour="darkgrey", size=6)+
  geom_hline(yintercept=60, colour="darkgrey", linetype="dashed", linewidth=1)+
  geom_text(x=7.5, y=32, label="Netherlands", colour="darkgrey", size=6)+
  geom_hline(yintercept=137, colour="darkgrey", linetype="dashed", linewidth=1)+
  geom_text(x=7.5, y=143, label="MRIP", colour="darkgrey", size=6)+
  geom_point(size=5)+ggtitle("Catch")+
  ylab("Mean Annual Catch per Fisher")+xlab("Small Lake Subset Method")+
  ylim(0,200)+
  theme_bw()+theme(plot.title = element_text(hjust=0.5, size=16, face="bold"))+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

p2<-ggplot(data=median_e_per_fisher, aes(x=factor(Group.1, level=level_order), y=x))+
  geom_point(size=5)+ggtitle("Effort")+
  ylab("Mean Annual Effort Hours per Fisher")+xlab("Small Lake Subset Method")+
  theme_bw()+theme(plot.title = element_text(hjust=0.5, size=16, face="bold"))+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

new_total_c<-data.frame(catch=(sum(exp(wisc_C))*365)/1000000000, lake_sub="CDF")

total_c_df<-rbind(total_c_df,new_total_c)

median_total_c<-aggregate(total_c_df$catch, by=list(total_c_df$lake_sub), FUN="median")


new_total_e<-data.frame(catch=(sum(exp(wisc_E))*365)/1000000, lake_sub="CDF")

total_e_df<-rbind(total_e_df,new_total_e)

median_total_e<-aggregate(total_e_df$catch, by=list(total_e_df$lake_sub), FUN="median")


p3<-ggplot(data=median_total_c, aes(x=factor(Group.1, level=level_order), y=x))+
  geom_point(size=5)+
  ylab("Total Annual Catch (billions)")+xlab("Small Lake Subset Method")+
  theme_bw()+ylim(0,6)+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

p4<-ggplot(data=median_total_e, aes(x=factor(Group.1, level=level_order), y=x))+
  geom_point(size=5)+
  ylab("Total Annual Effort Hours (millions)")+xlab("Small Lake Subset Method")+
  theme_bw()+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

jpeg("model_extrapolations_bothmethods.jpeg", width=12,height=10, units="in", res=400)
ggpubr::ggarrange(p2, p1, p4, p3,
                  nrow = 2, ncol=2, heights=c(1,1.25)
) 
dev.off()


# Convert extrapolated catch numbers to weights ---------------------------

#Using estimates from fishbase for Fusiform bodyshapes (Froese & Thorson 2014), 
#l-w parameters would be a=0.0112, b=3.04
avg_wgt<-c((0.0112*28.8^3.04)/1000)*0.34
avg_wgt_est<-((total_c_df$catch*1000000000)*avg_wgt)/1000

avg_wgt_df<-data.frame(wgt=c(avg_wgt_est/1000), lake_sub=total_c_df$lake_sub)

level_order=c("100%","50%","33%","25%","20%","10%","5%", "CDF")

median_wgt<-aggregate(avg_wgt_df$wgt, by=list(total_e_df$lake_sub), FUN="median")


p5<-ggplot(data=median_wgt, aes(x=factor(Group.1, level=level_order), y=x))+
  geom_point(size=5)+
  ylab("Total Annual Harvest ('000 tonnes)")+xlab("Small Lake Subset Method")+
  theme_bw()+
  theme(axis.text= element_text(size=14),axis.title=element_text(size=16,face="bold"))

jpeg("total_harvest_tonnes.jpeg", width=6,height=6, units="in", res=400)
p5
dev.off()