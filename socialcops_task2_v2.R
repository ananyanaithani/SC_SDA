
# 1a. read files in

monthly_data <- read.csv("Monthly_data_cmo.csv")
msp_data <- read.csv("CMO_MSP_Mandi.csv")

# 1b. clean commodity names to produce merge ID for MSP

library(stringr)
monthly_data$Commodity2<- tolower(str_replace_all(monthly_data$Commodity,"[[:punct:]]",""))
msp_data$commodity2<- tolower(str_replace_all(msp_data$commodity,"[[:punct:]]",""))

# 1c. function to remove outliers using 25-75 %iles in interquartile range

remove_outliers <- function(x,na.rm=TRUE,...){
  qnt <- quantile(x, probs=c(0.25,0.75),na.rm=na.rm,...)
  H <- 1.5*IQR(x,na.rm=na.rm)
  y <- x
  y[x < (qnt[1]-H)] <- NA
  y[x > (qnt[2]+H)] <- NA
  y
}

# 1d. merge in data and sort by APMC, Commodity and Date. Plot raw prices

merg1 <- merge(monthly_data,msp_data,by.x=c("Commodity2","Year"),by.y=c("commodity2","year"))
merg1 <- merg1[order(merg1$APMC,merg1$Commodity2,merg1$date),]
ggplot(merg1,aes(x=date,y=modal_price)) + geom_point() + facet_wrap(~Commodity2, scales = "free") + 
  labs(x="Time",y="Modal Price (Raw)", title="Commodity Prices, Untreated") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank())


# 1e. dplyr outlier removal. Plot treated prices

library(dplyr)
merg2 <- merg1 %>% group_by(Commodity2,Year) %>% mutate(mod_wo = remove_outliers(modal_price))
ggplot(merg2,aes(x=date,y=mod_wo)) + geom_point() + facet_wrap(~Commodity2, scales = "free") + 
  labs(x="Time",y="Modal Price (Treated)", title="Commodity Prices, Treated") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank())


# 2a. Identify valid APMC-Commodity clusters, with enough data to constitute a time series

pairs <- as.data.frame(table(merg1$APMC,merg1$Commodity2))
pairs2 <- pairs[pairs$Freq >= 12,]

# 2b. example subset

subs1 <- subset(merg2,APMC %in% "Chopda" & Commodity2 %in% "bajri", na.rm=TRUE)

# 2c. plot as timeseries

plot(as.ts(subs1$mod_wo),xlab="Time",ylab="Modal Price",main="Chopda Bajri Prices")

# 2d. ACF and ADF tests for stationarity - p < 0.05 means stationary

library(tseries)
acf(subs1$mod_wo,main="Autocorrelation Check for Modal Prices")
adf.test(subs1$mod_wo)

# 2e. decompose timeseries

library(forecast)
ts_1 = ts(subs1$mod_wo,frequency = 4)

# additive decomposition

decompose_1 = decompose(ts_1,"additive")
plot(decompose_1)

subs1$mp_sa <- subs1$mod_wo - decompose_1$seasonal

# 3a. simultaneous plot comparing msp to modal price to deseasonalised

library(ggplot2)
ggplot(subs1,aes(x=date,group=1)) + geom_line(aes(y=mod_wo, colour="Raw Price")) + 
  geom_line(aes(y=msprice, colour="MSP")) + geom_line(aes(y=mp_sa,colour="Deseasonalised (Add)")) +
  theme(axis.text.x=element_text(angle=90,hjust=1)) +
  labs(y="Prices",title="Bajri Prices in Chopda")

# multiplicative decomposition

decompose_2 = decompose(ts_1,"multiplicative")
plot(decompose_2)

subs1$mp_sa_m <- subs1$mod_wo / decompose_2$seasonal

# 3b. simultaneous plot comparing msp to modal price to deseasonalised

ggplot(subs1,aes(x=date,group=1)) + geom_line(aes(y=mod_wo, colour="Raw Price")) + 
  geom_line(aes(y=msprice, colour="MSP")) + geom_line(aes(y=mp_sa_m,colour="Deseasonalised (Mult)")) +
  theme(axis.text.x=element_text(angle=90,hjust=1)) +
  labs(y="Prices",title="Bajri Prices in Chopda")

# 4. flag APMC/commodity clusters with max variation

# 4a. by year

testmerg6 <- merg2 %>% mutate(fluct = max_price - min_price, fluctrel = ((max_price - min_price)/min_price)*100) %>% group_by(Commodity2,APMC,date) %>% select(Commodity2,APMC,Year,date,max_price,min_price,fluctrel,fluct)
testmerg6 <- testmerg6[is.finite(testmerg6$fluctrel),]
final_out1 <- testmerg6 %>% group_by(Commodity2,APMC,Year) %>% summarise(maxfluctrel = max(fluctrel,na.rm=TRUE), maxfluct = max(fluct,na.rm=TRUE)) %>% arrange(desc(maxfluct),desc(maxfluctrel))

# 4b. by year and crop season

testmerg7 <- merg2 %>% mutate(fluct = max_price - min_price, fluctrel = ((max_price - min_price)/min_price)*100) %>% group_by(Commodity2,APMC,Type) %>% select(Commodity2,APMC,Year,Type,max_price,min_price,fluctrel,fluct)
testmerg7 <- testmerg7[is.finite(testmerg7$fluctrel),]
final_out2 <- testmerg7 %>% group_by(Commodity2,APMC,Year,Type) %>% summarise(maxfluctrel = max(fluctrel,na.rm=TRUE), maxfluct = max(fluct,na.rm=TRUE)) %>% arrange(desc(maxfluct),desc(maxfluctrel))
