

library(ggplot2)
library(lubridate)
library(TMB)


# Load the relevant CreelCat data
effort<-read.csv("Data/AngEffort_Data.csv")
fish<-read.csv("Data/FishDataCompiled.csv")
surv<-read.csv("Data/Survey_Data.csv")

surv$Duration<-as.numeric(as.character(surv$Duration))

which(surv$Duration<0)
which(surv$Duration>365)

names(surv)[names(surv) == 'State_Ab'] <- 'StateAb'

table(surv$StateAb)

#####Limit states to those with enough data
surv_s<-subset(surv, StateAb=="AK"|StateAb=="AR"|StateAb=="AZ"|StateAb=="CT"|StateAb=="DE"|StateAb=="FL"|StateAb=="GA"|StateAb=="IA"|
                 StateAb=="ID"|StateAb=="IL"|StateAb=="IN"|StateAb=="KS"|StateAb=="KY"|StateAb=="MA"|StateAb=="ME"|StateAb=="MI"|
                 StateAb=="MN"|StateAb=="MT"|StateAb=="ND"|StateAb=="NE"|StateAb=="NJ"|StateAb=="NM"|StateAb=="NV"|StateAb=="OR"|
                 StateAb=="SC"|StateAb=="SD"|
                 StateAb=="TN"|StateAb=="TX"|StateAb=="UT"|StateAb=="VT"|StateAb=="WA"|StateAb=="WI"|StateAb=="WY")

surv_s$State<-as.factor(surv_s$State)
surv_s$StateAb<-as.factor(surv_s$StateAb)
surv_s$State<-droplevels(surv_s$State)
surv_s$StateAb<-droplevels(surv_s$StateAb)

#remove species specific surveys
surv_s<-subset(surv_s, Focal_Species==""|Focal_Species=="All"|Focal_Species=="ALL")

surv_s<-subset(surv_s, Survey_Type=="Angler Intercept"|Survey_Type=="Angler Intercept Survey")

# Make a Great Lakes Survey Identified
surv_s$GL<-0

surv_s[which(grepl("Lake Erie", surv_s$Waterbody_Name)),58]<-1
surv_s[which(grepl("Lake Michigan", surv_s$Waterbody_Name)),58]<-1
surv_s[which(grepl("Lake Superior", surv_s$Waterbody_Name)),58]<-1
surv_s[which(grepl("Lake Huron", surv_s$Waterbody_Name)),58]<-1
surv_s[which(grepl("Lake Ontario", surv_s$Waterbody_Name)),58]<-1

#remove surveys with no duration data
surv_s<-subset(surv_s, Start_Date!="")
surv_s<-surv_s[!is.na(surv_s$Duration),]

for(i in 1:length(surv_s$Survey_ID)){
  if(!is.na(surv_s$Reported_Duration[i])){
    surv_s$Duration[i]<-surv_s$Reported_Duration[i]
  }
  if(surv_s$Lost_Duration[i]>0){
    surv_s$Duration[i]<-surv_s$Duration[i]-surv_s$Lost_Duration[i]
  }
}

#convert remaining surveys with duration 0 to duration 1
surv_s$Duration<-ifelse(surv_s$Duration==0, 1, surv_s$Duration)

fish$Release<-as.numeric(as.character(fish$Release))
fish$Harvest<-as.numeric(as.character(fish$Harvest))
fish$Catch<-as.numeric(as.character(fish$Catch))
fish$Catch_HR<-fish$Release+fish$Harvest
fish$Catchdiff<-fish$Catch_HR-fish$Catch

fish$Harvest[is.na(fish$Harvest)] <- 0
fish$Release[is.na(fish$Release)] <- 0

fish$true_catch<-NA

for(i in 1:length(fish$Survey_ID)){
  if(fish$Catch[i]==0|is.na(fish$Catch[i])){
    fish$true_catch[i]<-fish$Catch_HR[i]
  }else{
    fish$true_catch[i]<-fish$Catch[i]
  }
}


effort$Effort_Hours<-as.numeric(as.character(effort$Effort_Hours))

#create dataframe with important identifying information and add to all dataframes
map<-data.frame(Survey_ID=surv_s$Survey_ID, State=surv_s$State, Year=surv_s$Year, WaterbodyID = surv_s$WB_ID, GL = surv_s$GL)

fish_s<-merge(map, fish, by="Survey_ID")
eff_s<-merge(map, effort, by="Survey_ID") 

map_eff<-data.frame(Survey_ID=eff_s$Survey_ID, Effort=eff_s$Effort_Hours)

true_fish<-merge(fish_s, map_eff, by="Survey_ID")

surv_time<-data.frame(Survey_ID=surv_s$Survey_ID, Duration=as.numeric(as.character(surv_s$Duration)), SurveyType=surv_s$Survey_Type,
                      StartDate=surv_s$Start_Date, EndDate=surv_s$End_Date, Area=surv_s$Survey_Acres)


map_surv<-data.frame(Survey_ID=surv_s$Survey_ID)

map_surv<-merge(map_surv, surv_time, by="Survey_ID", all.x=TRUE)

true_fish<-merge(true_fish, map_surv, by="Survey_ID")


# Aggregate catch and harvest across all species for the same survey
agg_catch<-aggregate(true_fish$true_catch, by=list(true_fish$Survey_ID), FUN=sum, na.rm=TRUE)
colnames(agg_catch)<-c("Survey_ID","Agg_catch")


agg_harvest<-aggregate(true_fish$Harvest, by=list(true_fish$Survey_ID), FUN=sum, na.rm=TRUE)
colnames(agg_harvest)<-c("Survey_ID","Agg_harvest")

census_map<-data.frame(Survey_ID=true_fish$Survey_ID, WaterbodyID=true_fish$WaterbodyID, Year=true_fish$Year,
                       State=true_fish$State, Effort=true_fish$Effort, 
                       Duration=true_fish$Duration, SurveyType=true_fish$SurveyType, StartDate=true_fish$StartDate, EndDate=true_fish$EndDate,
                       Area=true_fish$Area, GL=true_fish$GL)

agg_catch_harvest<-merge(agg_catch,agg_harvest, by="Survey_ID")

agg_catch_eff<-merge(agg_catch_harvest, census_map, by="Survey_ID")

agg_catch_nodups<-agg_catch_eff[!duplicated(agg_catch_eff),]


agg_catch_nodups$Agg_catch[agg_catch_nodups$Agg_catch==0] <- NA
agg_catch_nodups$Agg_harvest[agg_catch_nodups$Agg_harvest==0] <- NA


# Calculate catch, harvest, and effort per day
agg_catch_nodups$cpd<-(agg_catch_nodups$Agg_catch)/agg_catch_nodups$Duration
agg_catch_nodups$hpd<-(agg_catch_nodups$Agg_harvest)/agg_catch_nodups$Duration
agg_catch_nodups$epd<-(agg_catch_nodups$Effort)/agg_catch_nodups$Duration

agg_catch_nodups$cpd[agg_catch_nodups$cpd<=0] <- NA
agg_catch_nodups$hpd[agg_catch_nodups$hpd<=0] <- NA
agg_catch_nodups<-agg_catch_nodups[!is.infinite(agg_catch_nodups$cpd),]


####CUT OUT DUPLICATES
n_survs_tab<-as.data.frame(table(agg_catch_nodups$WaterbodyID))
few_survs<-subset(n_survs_tab, Freq<5)

new_agg_catch_nodups<-agg_catch_nodups[agg_catch_nodups$WaterbodyID %in% few_survs$Var1,]

many_survs<-subset(n_survs_tab, Freq>=5)

for(i in 1:length(many_survs$Var1)){
  one_surv<-subset(agg_catch_nodups, WaterbodyID==many_survs[i,1])
  
  new_agg_catch_nodups<-rbind(new_agg_catch_nodups, 
                              agg_catch_nodups[agg_catch_nodups$Survey_ID %in% one_surv[order(one_surv$Year, decreasing=TRUE),][1:5,]$Survey_ID,])
}

# Only keep surveys since 2000
remove_recents<-subset(new_agg_catch_nodups, Year>1999)

# Only keep rows that have necessary data 
useable_dat<-subset(remove_recents, is.na(cpd)==FALSE & is.na(epd)==FALSE)

#create region identifier for the CreelCatch model
istate<-as.numeric(droplevels(useable_dat$State))-1

grouped_istate<-6
#MW
grouped_istate<-ifelse(useable_dat$State=="Iowa", 0, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Michigan", 0, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Minnesota", 0, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Wisconsin", 0, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Illinois", 0, grouped_istate)
#iowa and kentucky together
grouped_istate<-ifelse(useable_dat$State=="Vermont", 1, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Connecticut", 1, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Massachusetts", 1, grouped_istate)
#vermont alone
grouped_istate<-ifelse(useable_dat$State=="North Dakota", 2, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="South Dakota", 2, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Nebraska", 2, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Wyoming", 2, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Montana", 2, grouped_istate)
#nd and sd together
grouped_istate<-ifelse(useable_dat$State=="Arkansas", 3, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Florida", 3, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Kentucky", 3, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Tennessee", 3, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="South Carolina", 3, grouped_istate)
#fl, tn, tx, and sc together
grouped_istate<-ifelse(useable_dat$State=="Utah", 4, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Arizona", 4, grouped_istate)

grouped_istate<-ifelse(useable_dat$State=="Texas", 5, grouped_istate)
grouped_istate<-ifelse(useable_dat$State=="Kansas", 5, grouped_istate)


useable_dat$istate<-grouped_istate

#convert area from hectares to sqkm
useable_dat$Area<-useable_dat$Area*0.00404686

save(data=useable_dat, file="Model_dat.RData")
