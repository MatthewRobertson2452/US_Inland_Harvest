
# R version 4.4.2
# nhdR version 0.6.1

library(nhdR)

# These datasets can take up a lot of memory
# In practice, this data extraction was done in smaller steps to avoid crashing R
# However, the code is presented here to complete extraction in one step for simplicity

# Northeast

nh_nhd<-nhd_load(c("NH"),c("NHDWaterbody"))
nh_nhd_sub<-data.frame(perm_id =nh_nhd$permanent_identifier, area=nh_nhd$areasqkm, fcode=nh_nhd$fcode)

me_nhd<-nhd_load(c("ME"),c("NHDWaterbody"))
me_nhd_sub<-data.frame(perm_id =me_nhd$permanent_identifier, area=me_nhd$areasqkm, fcode=me_nhd$fcode)

cn_nhd<-nhd_load(c("CT"),c("NHDWaterbody"))
cn_nhd_sub<-data.frame(perm_id =cn_nhd$permanent_identifier, area=cn_nhd$areasqkm, fcode=cn_nhd$fcode)

ma_nhd<-nhd_load(c("MA"),c("NHDWaterbody"))
ma_nhd_sub<-data.frame(perm_id =ma_nhd$permanent_identifier, area=ma_nhd$areasqkm, fcode=ma_nhd$fcode)

vt_nhd<-nhd_load(c("VT"),c("NHDWaterbody"))
vt_nhd_sub<-data.frame(perm_id =vt_nhd$permanent_identifier, area=vt_nhd$areasqkm, fcode=vt_nhd$fcode)

ny_nhd<-nhd_load(c("NY"),c("NHDWaterbody"))
ny_nhd_sub<-data.frame(perm_id =ny_nhd$permanent_identifier, area=ny_nhd$areasqkm, fcode=ny_nhd$fcode)

pa_nhd<-nhd_load(c("PA"),c("NHDWaterbody"))
pa_nhd_sub<-data.frame(perm_id =pa_nhd$permanent_identifier, area=pa_nhd$areasqkm, fcode=pa_nhd$fcode)

ri_nhd<-nhd_load(c("RI"),c("NHDWaterbody"))
ri_nhd_sub<-data.frame(perm_id =ri_nhd$permanent_identifier, area=ri_nhd$areasqkm, fcode=ri_nhd$fcode)

nj_nhd<-nhd_load(c("NJ"),c("NHDWaterbody"))
nj_nhd_sub<-data.frame(perm_id =nj_nhd$permanent_identifier, area=nj_nhd$areasqkm, fcode=nj_nhd$fcode)

wv_nhd<-nhd_load(c("WV"),c("NHDWaterbody"))
wv_nhd_sub<-data.frame(perm_id =wv_nhd$permanent_identifier, area=wv_nhd$areasqkm, fcode=wv_nhd$fcode)

md_nhd<-nhd_load(c("MD"),c("NHDWaterbody"))
md_nhd_sub<-data.frame(perm_id =md_nhd$permanent_identifier, area=md_nhd$areasqkm, fcode=md_nhd$fcode)

de_nhd<-nhd_load(c("DE"),c("NHDWaterbody"))
de_nhd_sub<-data.frame(perm_id =de_nhd$permanent_identifier, area=de_nhd$areasqkm, fcode=de_nhd$fcode)

# Midwest

mi_nhd<-nhd_load(c("MI"),c("NHDWaterbody"))
mi_nhd_sub<-data.frame(perm_id =mi_nhd$permanent_identifier, area=mi_nhd$areasqkm, fcode=mi_nhd$fcode)

mn_nhd<-nhd_load(c("MN"),c("NHDWaterbody"))
mn_nhd_sub<-data.frame(perm_id =mn_nhd$permanent_identifier, area=mn_nhd$areasqkm, fcode=mn_nhd$fcode)

wisc_nhd<-nhd_load(c("WI"),c("NHDWaterbody"))
wisc_nhd_sub<-data.frame(perm_id =wisc_nhd$permanent_identifier, area=wisc_nhd$areasqkm, fcode=wisc_nhd$fcode)

oh_nhd<-nhd_load(c("OH"),c("NHDWaterbody"))
oh_nhd_sub<-data.frame(perm_id =oh_nhd$permanent_identifier, area=oh_nhd$areasqkm, fcode=oh_nhd$fcode)

in_nhd<-nhd_load(c("IN"),c("NHDWaterbody"))
in_nhd_sub<-data.frame(perm_id =in_nhd$permanent_identifier, area=in_nhd$areasqkm, fcode=in_nhd$fcode)

il_nhd<-nhd_load(c("IL"),c("NHDWaterbody"))
il_nhd_sub<-data.frame(perm_id =il_nhd$permanent_identifier, area=il_nhd$areasqkm, fcode=il_nhd$fcode)

ia_nhd<-nhd_load(c("IA"),c("NHDWaterbody"))
ia_nhd_sub<-data.frame(perm_id =ia_nhd$permanent_identifier, area=ia_nhd$areasqkm, fcode=ia_nhd$fcode)

mo_nhd<-nhd_load(c("MO"),c("NHDWaterbody"))
mo_nhd_sub<-data.frame(perm_id =mo_nhd$permanent_identifier, area=mo_nhd$areasqkm, fcode=mo_nhd$fcode)

# Northern Great Plains

mt_nhd<-nhd_load(c("MT"),c("NHDWaterbody"))
mt_nhd_sub<-data.frame(perm_id =mt_nhd$permanent_identifier, area=mt_nhd$areasqkm, fcode=mt_nhd$fcode)

nd_nhd<-nhd_load(c("ND"),c("NHDWaterbody"))
nd_nhd_sub<-data.frame(perm_id =nd_nhd$permanent_identifier, area=nd_nhd$areasqkm, fcode=nd_nhd$fcode)

sd_nhd<-nhd_load(c("SD"),c("NHDWaterbody"))
sd_nhd_sub<-data.frame(perm_id =sd_nhd$permanent_identifier, area=sd_nhd$areasqkm, fcode=sd_nhd$fcode)

wy_nhd<-nhd_load(c("WY"),c("NHDWaterbody"))
wy_nhd_sub<-data.frame(perm_id =wy_nhd$permanent_identifier, area=wy_nhd$areasqkm, fcode=wy_nhd$fcode)

ne_nhd<-nhd_load(c("NE"),c("NHDWaterbody"))
ne_nhd_sub<-data.frame(perm_id =ne_nhd$permanent_identifier, area=ne_nhd$areasqkm, fcode=ne_nhd$fcode)

# Southern Great Plains

ok_nhd<-nhd_load(c("OK"),c("NHDWaterbody"))
ok_nhd_sub<-data.frame(perm_id =ok_nhd$permanent_identifier, area=ok_nhd$areasqkm, fcode=ok_nhd$fcode)

tx_nhd<-nhd_load(c("TX"),c("NHDWaterbody"))
tx_nhd_sub<-data.frame(perm_id =tx_nhd$permanent_identifier, area=tx_nhd$areasqkm, fcode=tx_nhd$fcode)

ks_nhd<-nhd_load(c("KS"),c("NHDWaterbody"))
ks_nhd_sub<-data.frame(perm_id =ks_nhd$permanent_identifier, area=ks_nhd$areasqkm, fcode=ks_nhd$fcode)

# Southeast

nc_nhd<-nhd_load(c("NC"),c("NHDWaterbody"))
nc_nhd_sub<-data.frame(perm_id =nc_nhd$permanent_identifier, area=nc_nhd$areasqkm, fcode=nc_nhd$fcode)

va_nhd<-nhd_load(c("VA"),c("NHDWaterbody"))
va_nhd_sub<-data.frame(perm_id =va_nhd$permanent_identifier, area=va_nhd$areasqkm, fcode=va_nhd$fcode)

ga_nhd<-nhd_load(c("GA"),c("NHDWaterbody"))
ga_nhd_sub<-data.frame(perm_id =ga_nhd$permanent_identifier, area=ga_nhd$areasqkm, fcode=ga_nhd$fcode)

al_nhd<-nhd_load(c("AL"),c("NHDWaterbody"))
al_nhd_sub<-data.frame(perm_id =al_nhd$permanent_identifier, area=al_nhd$areasqkm, fcode=al_nhd$fcode)

la_nhd<-nhd_load(c("LA"),c("NHDWaterbody"))
la_nhd_sub<-data.frame(perm_id =la_nhd$permanent_identifier, area=la_nhd$areasqkm, fcode=la_nhd$fcode)

ms_nhd<-nhd_load(c("MS"),c("NHDWaterbody"))
ms_nhd_sub<-data.frame(perm_id =ms_nhd$permanent_identifier, area=ms_nhd$areasqkm, fcode=ms_nhd$fcode)

fl_nhd<-nhd_load(c("FL"),c("NHDWaterbody"))
fl_nhd_sub<-data.frame(perm_id =fl_nhd$permanent_identifier, area=fl_nhd$areasqkm, fcode=fl_nhd$fcode)

ar_nhd<-nhd_load(c("AR"),c("NHDWaterbody"))
ar_nhd_sub<-data.frame(perm_id =ar_nhd$permanent_identifier, area=ar_nhd$areasqkm, fcode=ar_nhd$fcode)

ky_nhd<-nhd_load(c("KY"),c("NHDWaterbody"))
ky_nhd_sub<-data.frame(perm_id =ky_nhd$permanent_identifier, area=ky_nhd$areasqkm, fcode=ky_nhd$fcode)

tn_nhd<-nhd_load(c("TN"),c("NHDWaterbody"))
tn_nhd_sub<-data.frame(perm_id =tn_nhd$permanent_identifier, area=tn_nhd$areasqkm, fcode=tn_nhd$fcode)

sc_nhd<-nhd_load(c("SC"),c("NHDWaterbody"))
sc_nhd_sub<-data.frame(perm_id =sc_nhd$permanent_identifier, area=sc_nhd$areasqkm, fcode=sc_nhd$fcode)

# Southwest

ca_nhd<-nhd_load(c("CA"),c("NHDWaterbody"))
ca_nhd_sub<-data.frame(perm_id =ca_nhd$permanent_identifier, area=ca_nhd$areasqkm, fcode=ca_nhd$fcode)

nv_nhd<-nhd_load(c("NV"),c("NHDWaterbody"))
nv_nhd_sub<-data.frame(perm_id =nv_nhd$permanent_identifier, area=nv_nhd$areasqkm, fcode=nv_nhd$fcode)

az_nhd<-nhd_load(c("AZ"),c("NHDWaterbody"))
az_nhd_sub<-data.frame(perm_id =az_nhd$permanent_identifier, area=az_nhd$areasqkm, fcode=az_nhd$fcode)

nm_nhd<-nhd_load(c("NM"),c("NHDWaterbody"))
nm_nhd_sub<-data.frame(perm_id =nm_nhd$permanent_identifier, area=nm_nhd$areasqkm, fcode=nm_nhd$fcode)

co_nhd<-nhd_load(c("CO"),c("NHDWaterbody"))
co_nhd_sub<-data.frame(perm_id =co_nhd$permanent_identifier, area=co_nhd$areasqkm, fcode=co_nhd$fcode)

ut_nhd<-nhd_load(c("UT"),c("NHDWaterbody"))
ut_nhd_sub<-data.frame(perm_id =ut_nhd$permanent_identifier, area=ut_nhd$areasqkm, fcode=ut_nhd$fcode)

# Northwest

wa_nhd<-nhd_load(c("WA"),c("NHDWaterbody"))
wa_nhd_sub<-data.frame(perm_id =wa_nhd$permanent_identifier, area=wa_nhd$areasqkm, fcode=wa_nhd$fcode)

or_nhd<-nhd_load(c("OR"),c("NHDWaterbody"))
or_nhd_sub<-data.frame(perm_id =or_nhd$permanent_identifier, area=or_nhd$areasqkm, fcode=or_nhd$fcode)

id_nhd<-nhd_load(c("ID"),c("NHDWaterbody"))
id_nhd_sub<-data.frame(perm_id =id_nhd$permanent_identifier, area=id_nhd$areasqkm, fcode=id_nhd$fcode)


full_nhd<-list(
  # Midwest
  mi_nhd = mi_nhd_sub, # Michigan
  mn_nhd = mn_nhd_sub, # Minnesota
  wisc_nhd = wisc_nhd_sub, # Wisconsin
  oh_nhd = oh_nhd_sub, # Ohio
  in_nhd = in_nhd_sub, # Indiana
  il_nhd = il_nhd_sub, # Illinois
  ia_nhd = ia_nhd_sub, # Iowa
  mo_nhd = mo_nhd_sub, # Missouri
  # Northeast
  ct_nhd = cn_nhd_sub, # Connecticut
  ma_nhd = ma_nhd_sub, # Massachussettes
  vt_nhd = vt_nhd, # Vermont
  nh_nhd = nh_nhd_sub, # New Hampshire
  me_nhd = me_nhd_sub, # Maine
  ny_nhd = ny_nhd_sub, # New york
  pa_nhd = pa_nhd_sub, # Pennsylvania 
  ri_nhd = ri_nhd_sub, # Rhode Island
  nj_nhd = nj_nhd_sub, # New Jersey
  wv_nhd = wv_nhd_sub, # West Virginia
  md_nhd = md_nhd_sub, # Maryland
  de_nhd = de_nhd_sub, # Delaware
  # Northern Great Plains
  ne_nhd = ne_nhd_sub, # Nebraska
  nd_nhd = nd_nhd, # North Dakota
  sd_nhd = sd_nhd, # South Dakota
  wy_nhd = wy_nhd, # Wyoming
  mt_nhd = mt_nhd_sub, # Montana
  # Southeast
  ar_nhd = ar_nhd, # Arkansas
  fl_nhd = fl_nhd_sub, # Florida
  ky_nhd = ky_nhd, # Kentucky
  tn_nhd = tn_nhd, # Tennessee
  sc_nhd = sc_nhd, # South Carolina
  nc_nhd = nc_nhd_sub, # North Carolina
  va_nhd = va_nhd_sub, # Virginia
  ga_nhd = ga_nhd_sub, # Georgia
  al_nhd = al_nhd_sub, # Alabama
  la_nhd = la_nhd_sub, # Louisiana
  ms_nhd = ms_nhd_sub, # Mississippi
  # Southwest
  ut_nhd = ut_nhd, # Utah
  ca_nhd = ca_nhd_sub, # California
  nv_nhd = nv_nhd_sub, # Nevada
  az_nhd = az_nhd_sub, # Arizona
  nm_nhd = nm_nhd_sub, # New Mexico
  co_nhd = co_nhd_sub, # Colorado
  # Southern Great Plains
  tx_nhd = tx_nhd, # Texas
  ks_nhd = ks_nhd, # Kansas
  ok_nhd = ok_nhd_sub, # Oklahoma
  # Northwest
  wa_nhd = wa_nhd_sub, # Washington
  or_nhd = or_nhd_sub, # Oregon
  id_nhd = id_nhd_sub # Idaho
)



# Midwest
full_nhd$mn_nhd$istate<-0
full_nhd$mn_nhd$state<-"Minnesota"

full_nhd$mi_nhd$istate<-0
full_nhd$mi_nhd$state<-"Michigan"

full_nhd$wisc_nhd$istate<-0
full_nhd$wisc_nhd$state<-"Wisconsin"

full_nhd$oh_nhd$istate<-0
full_nhd$oh_nhd$state<-"Ohio"

full_nhd$in_nhd$istate<-0
full_nhd$in_nhd$state<-"Indiana"

full_nhd$ia_nhd$istate<-0
full_nhd$ia_nhd$state<-"Iowa"

full_nhd$mo_nhd$istate<-0
full_nhd$mo_nhd$state<-"Missouri"

full_nhd$il_nhd$istate<-0
full_nhd$il_nhd$state<-"Illinois"

# Northeast
full_nhd$ct_nhd$istate<-1
full_nhd$ct_nhd$state<-"Connecticut"

full_nhd$ma_nhd$istate<-1
full_nhd$ma_nhd$state<-"Massachusetts"

full_nhd$vt_nhd$istate<-1
full_nhd$vt_nhd$state<-"Vermont"

full_nhd$nh_nhd$istate<-1
full_nhd$nh_nhd$state<-"New Hampshire"

full_nhd$me_nhd$istate<-1
full_nhd$me_nhd$state<-"Maine"

full_nhd$ny_nhd$istate<-1
full_nhd$ny_nhd$state<-"New York"

full_nhd$pa_nhd$istate<-1
full_nhd$pa_nhd$state<-"Pennsylvania"

full_nhd$ri_nhd$istate<-1
full_nhd$ri_nhd$state<-"Rhode Island"

full_nhd$nj_nhd$istate<-1
full_nhd$nj_nhd$state<-"New Jersey"

full_nhd$wv_nhd$istate<-1
full_nhd$wv_nhd$state<-"West Virginia"

full_nhd$md_nhd$istate<-1
full_nhd$md_nhd$state<-"Maryland"

full_nhd$de_nhd$istate<-1
full_nhd$de_nhd$state<-"Delaware"

# Northern Great Plains

full_nhd$ne_nhd$istate<-2
full_nhd$ne_nhd$state<-"Nebraska"

full_nhd$nd_nhd$istate<-2
full_nhd$nd_nhd$state<-"North Dakota"

full_nhd$sd_nhd$istate<-2
full_nhd$sd_nhd$state<-"South Dakota"

full_nhd$wy_nhd$istate<-2
full_nhd$wy_nhd$state<-"Wyoming"

full_nhd$mt_nhd$istate<-2
full_nhd$mt_nhd$state<-"Montana"

# Southeast

full_nhd$ar_nhd$istate<-3
full_nhd$ar_nhd$state<-"Arkansas"

full_nhd$fl_nhd$istate<-3
full_nhd$fl_nhd$state<-"Florida"

full_nhd$ky_nhd$istate<-3
full_nhd$ky_nhd$state<-"Kentucky"

full_nhd$tn_nhd$istate<-3
full_nhd$tn_nhd$state<-"Tennessee"

full_nhd$sc_nhd$istate<-3
full_nhd$sc_nhd$state<-"South Carolina"

full_nhd$nc_nhd$istate<-3
full_nhd$nc_nhd$state<-"North Carolina"

full_nhd$va_nhd$istate<-3
full_nhd$va_nhd$state<-"Virginia"

full_nhd$ga_nhd$istate<-3
full_nhd$ga_nhd$state<-"Georgia"

full_nhd$al_nhd$istate<-3
full_nhd$al_nhd$state<-"Alabama"

full_nhd$la_nhd$istate<-3
full_nhd$la_nhd$state<-"Louisiana"

full_nhd$ms_nhd$istate<-3
full_nhd$ms_nhd$state<-"Mississippi"

# Southwest

full_nhd$ut_nhd$istate<-4
full_nhd$ut_nhd$state<-"Utah"

full_nhd$ca_nhd$istate<-4
full_nhd$ca_nhd$state<-"California"

full_nhd$nv_nhd$istate<-4
full_nhd$nv_nhd$state<-"Nevada"

full_nhd$az_nhd$istate<-4
full_nhd$az_nhd$state<-"Arizona"

full_nhd$nm_nhd$istate<-4
full_nhd$nm_nhd$state<-"New Mexico"

full_nhd$co_nhd$istate<-4
full_nhd$co_nhd$state<-"Colorado"


# Southern Great Plains

full_nhd$ks_nhd$istate<-5
full_nhd$ks_nhd$state<-"Kansas"

full_nhd$tx_nhd$istate<-5
full_nhd$tx_nhd$state<-"Texas"

full_nhd$ok_nhd$istate<-5
full_nhd$ok_nhd$state<-"Oklahoma"

#northwest

full_nhd$wa_nhd$istate<-6
full_nhd$wa_nhd$state<-"Washington"

full_nhd$or_nhd$istate<-6
full_nhd$or_nhd$state<-"Oregon"

full_nhd$id_nhd$istate<-6
full_nhd$id_nhd$state<-"Idaho"



save(full_nhd, file="Data//all_states_nhd_for_modeling.RData")

