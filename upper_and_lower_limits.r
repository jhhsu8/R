# A program that queries data from a data table and calculates means and 
# upper and lower limits (IQR and 3-sigma) of parameters for males and females

library(RMySQL)
# connect to database
mydb <- dbConnect(
  MySQL(),
  user = "xxx",
  password = "xxx",
  dbname = "mbplims",
  host = "mbpdev.komp.org"
)

# query data from the table
data <- dbGetQuery(
  mydb,
  "SELECT DISTINCT
  mice.sex,
  hemas.mean_platelet_volume,
  hemas.red_blood_cell_count,
  hemas.white_blood_cell_count,
  hemas.neutrophil_cell_count,
  hemas.lymphocyte_cell_count,
  hemas.monocyte_cell_count,
  hemas.eosinophil_cell_count,
  hemas.basophil_cell_count,
  hemas.hemoglobin,
  hemas.hematocrit,
  hemas.mean_cell_hemoglobin_concentration,
  hemas.mean_cell_volume,
  hemas.mean_corpuscular_hemoglobin,
  hemas.red_blood_cell_distribution_width,
  hemas.platelet_count,
  hemas.neutrophil_differential_count,
  hemas.lymphocyte_differential_count,
  hemas.monocyte_differential_count,
  hemas.eosinophil_differential_count,
  hemas.basophil_differential_count
  FROM hemas
  INNER JOIN mice ON mice.mouse_id = hemas.mouse_name
  INNER JOIN projects ON projects.id = mice.project_id
  INNER JOIN project_types ON project_types.id = projects.project_type_id
  WHERE project_types.name IN ('KOMP2', 'K2P2EA')
  AND mice.genotype IN ('Wt','Wt-l') AND datediff(hemas.collection_datetime, mice.birth_date) / 7 >= 14
  AND datediff(hemas.collection_datetime, mice.birth_date) / 7 <= 18;"
)

# close database connection
dbDisconnect(mydb)

# return a vector containing unique groups (male and female)
groups <- unique(data$sex)

# loop through each group in the vector
for (group in groups) {
  # loop through each column in the dataframe
  for (column in colnames(data)) {
    if (column != "sex") {
      
      data[, column] <- as.numeric(data[, column]) # convert column values to numeric type
      data[data == -999] <- NA # set -999 values to NA
      mean <- mean(data[which(data$sex == group), column], na.rm = TRUE) # calculate mean
      iqr <- IQR(data[which(data$sex == group), column], na.rm = TRUE) # calculate interquartile range
      first_q <- quantile(data[which(data$sex == group), column], c(0.25), na.rm = TRUE) # calculate first quartile
      third_q <- quantile(data[which(data$sex == group), column], c(0.75), na.rm = TRUE) # calculate third quartile
      iqr_upper_limit <- third_q + (1.5 * iqr) # calculate IQR upper limit
      iqr_lower_limit <- first_q - (1.5 * iqr) # calculate IQR lower limit
      std <- sd(data[which(data$sex == group), column], na.rm = TRUE) # calculate standard deviation
      sigma_upper_limit <- mean + 3 * std # calculate 3-sigma upper limit
      sigma_lower_limit <- mean - 3 * std # calculate 3-sigma lower limit
      
      # convert negative lower limit values to zero
      if (iqr_lower_limit < 0) {
        iqr_lower_limit <- 0
      }
      if (sigma_lower_limit < 0) {
        sigma_lower_limit <- 0
      }
      
      #print results
      cat(group, column, "Mean:", mean, "\n")
      cat(group, column, "IQR upper limit:", iqr_upper_limit, "\n")
      cat(group, column, "IQR lower limit:", iqr_lower_limit, "\n")
      cat(group, column, "3-sigma upper limit:", sigma_upper_limit,"\n")
      cat(group, column, "3-sigma lower limit:", sigma_lower_limit, "\n")