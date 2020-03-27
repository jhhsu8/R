#This program performs t-test to determine whether the wild-type and mutant means are equal to each other.

library(ggplot2)
rm(list = ls(all.names = TRUE)) # clears all environment variables to avoid leaking state to another script

# read data from a csv file
data <- read.csv("Pain/acute_hargreaves.csv")
count <- 1
# loop through data rows from second to eigth columns 
for (name in colnames(data[, 2:8])) {
  
  #Welch’s t-test for unequal variances
  ttest <- t.test(data$B6N, data[, name])
  
  #print p-values and wild-type and mutant means
  df <- data.frame(row.names=count, wt=colnames(data)[1], mut=name, pvalue=ttest$p.value, wtmean=ttest$estimate[1], mutmean=ttest$estimate[2])
  print(df)
  
  count = count + 1
}
