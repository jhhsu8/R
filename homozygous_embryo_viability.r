# Homozygous embryo viability is assessed by examining embryos at 9.5, 12.5, 15.5, or 18.5 weeks produced from mating heterozygous animals.
# If the total embryo number is less than 28 and less than 4 total homozygous embryos are produced, the homozygosity cannot be determined.
# The homozygosity is viable if live homozygous embryos are equal to or greater than 12.5% of the litter.
# The homozygosity is subviable if live homozygous embryos are less than 12.5% but greater than 0% of the litter.
# The homozygosity is lethal if live homozygous embryos are 0%.
library(RMySQL)
rm(list = ls(all.names = TRUE)) # clears all environment variables to avoid leaking state to another script

# connect to database
mydb <- dbConnect(
  MySQL(),
  user = "username",
  password = "password",
  dbname = "database",
  host = "hostname"
)

# query the data from the embryos table
data <- dbGetQuery(
  mydb,
  "SELECT DISTINCT *
  FROM (SELECT count(embryos.colony_name) AS total_embryo_no, embryos.age as age1, embryos.colony_name as colony_name1
  FROM embryos
  GROUP BY embryos.colony_name, embryos.age) AS a
  LEFT OUTER JOIN
  (SELECT count(embryos.colony_name) AS homozygous_embryo_no, embryos.age as age2, embryos.colony_name as colony_name2
  FROM embryos
  WHERE genotype = 'Hom'
  GROUP BY embryos.colony_name, embryos.age) AS b
  ON a.colony_name1 = b.colony_name2 AND a.age1 = b.age2;"
)

dbDisconnect(mydb)

colony_names = data[, "colony_name1"] # get the colony names
embryo_ages = data[, "age1"] # get the embryo ages
total_numbers = data[, "total_embryo_no"] # get the total number of embryos
data$homozygous_embryo_no[is.na(data$homozygous_embryo_no)] <- 0 # set NA values in the homozygous_embryo_no column to 0
homozygous_numbers = data[, "homozygous_embryo_no"] # get the number of homogzyous embryos
percent_viables = (data[, "homozygous_embryo_no"] / data[, "total_embryo_no"]) * 100 # calculate the percentage of live homogzyous embryos

# if live homozygous embryos are equal to or greater than 12.5%, return "Viable"
# if live homozygous embryos are equal to 0%, return "Lethal"
# if live homozygous embryos are less than 12.5% but greater than 0%, return "Subviable"
viability = ifelse(total_numbers < 28 & homozygous_numbers < 4, "Cannot determined", ifelse(percent_viables >= 12.5, "Viable", ifelse(percent_viables == 0, "Lethal", "Subviable")))

# create the dataframe that contains the homozygous embryo viability data
df <- data.frame(colony_names, embryo_ages, total_numbers, homozygous_numbers, round(percent_viables, digits = 2), viability, stringsAsFactors = FALSE)
colnames(df) <- c("colony_name", "embryo_age", "total_embryo_no", "homozygous_embryo_no", "percent_homozygous", "homozygosity_viability")

# save the dataframe to a csv file
write.table(df, file="data/homozygous_embryo_viability.csv", row.names = FALSE, col.names = !file.exists("data/homozygous_embryo_viability.csv"),
            append = TRUE, sep = ',')