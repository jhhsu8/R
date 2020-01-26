# This R program prints the total embryo number that is not equal to the sum of wild-type, heterozygous, and homozygous embryos
library(RMySQL)
rm(list = ls(all.names = TRUE)) # clears all environment variables to avoid leaking state to another script
# connect to database
mydb <- dbConnect(
  MySQL(),
  user = "xxx",
  password = "xxx",
  dbname = "mbplims",
  host = "viper.komp.org"
)

# query the data from the embryos table
data <- dbGetQuery(
  mydb,
  "SELECT DISTINCT *
  FROM (SELECT embryos.colony_name, count(embryos.colony_name) as number, embryos.age, date(embryos.datetime) AS date
  FROM embryos
  GROUP BY embryos.colony_name, embryos.age) AS a
  LEFT OUTER JOIN
  (SELECT embryos.colony_name as wt_name, count(embryos.colony_name) as wt_number, embryos.age as wt_age
  FROM embryos
  WHERE genotype = 'Wt'
  GROUP BY embryos.colony_name,  embryos.age) AS b
  ON a.colony_name = b.wt_name  AND a.age = b.wt_age
  LEFT OUTER JOIN
  (SELECT embryos.colony_name as het_name,  count(embryos.colony_name) as het_number, embryos.age as het_age
  FROM embryos
  WHERE genotype = 'Het'
  GROUP BY embryos.colony_name, embryos.age) AS c
  ON a.colony_name = c.het_name  AND a.age = c.het_age
  LEFT OUTER JOIN
  (SELECT embryos.colony_name as hom_name, count(embryos.colony_name) as hom_number, embryos.age as hom_age
  FROM embryos
  WHERE genotype = 'Hom'
  GROUP BY embryos.colony_name, embryos.age) AS d
  ON a.colony_name = d.hom_name AND a.age = d.hom_age;"
)

dbDisconnect(mydb)

# create a vector containing the three elements: wild-type, heterozygous, and homozygous numbers
cols <- c('wt_number','het_number','hom_number')

# sum of the wild-type, heterozygous, and homozygous embryos by row
data$wt_het_hom_number<-rowSums(data[,cols], na.rm = TRUE)

# get column values
age <- data$age
colony_name <- data$colony_name
date <- data$date
total_number <- data$number
wt_het_hom_number <- data$wt_het_hom_number
date <- data$date

# get index of total_number that is not equal to wt_het_hom_number 
ind <- total_number != wt_het_hom_number 
# create the data frame
df <- data.frame(colony_name=colony_name[ind], age=age[ind], total_embryo_number=total_number[ind], total_wt_het_hom_embryos=wt_het_hom_number[ind], date=date[ind], stringsAsFactors = FALSE)
# save the data frame to a csv file
write.table(df, file="data/total_embryos.csv", row.names = FALSE, col.names = !file.exists("data/total_embryos.csv"), append = TRUE, sep = ',')