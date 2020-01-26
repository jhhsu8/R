# Brain is not available, but at least one brain subunit is incorrectly marked as available for assessing lacZ expression.
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

# query the data from the laczs table
data <- dbGetQuery(
  mydb,
  "SELECT laczs.mouse_name,
  laczs.brain,
  laczs.cerebellum,
  laczs.olfactory_lobe,
  laczs.midbrain,
  laczs.forebrain,
  laczs.hippocampus,
  laczs.brainstem,
  laczs.cerebral_cortex,
  laczs.hypothalamus,
  laczs.pituitary,
  laczs.hindbrain
  FROM laczs
  WHERE laczs.brain = 'tissue not available';"
)

dbDisconnect(mydb)

len <- length(colnames(data)) # get number of columns

# exclude mice with all brain subunits that are "not available".
data <- data[apply(data[,2:len], 1, function(x) length(unique(x)) != 1), ]

# if at least one brain subunit is lacZ-expressed, brain should be lacZ-expressed
df1 <- data[apply(data[,3:len], 1, function(x) any(x == "expression")), ]

# save the dataframe to a cvs file
write.table(df1, file="data/expression_brain.csv", row.names = FALSE, col.names = !file.exists("data/expression_brain.csv"),
            append = TRUE, sep = ',')

# if all available subunits are not lacZ-expressed, brain should not be lacZ-expressed
df2 <- data[apply(data[,3:len], 1, function(x) all(x %in% c("no expression", "tissue not available"))), ]

# save the dataframe to a cvs file
write.table(df2, file="data/no_expression_brain.csv", row.names = FALSE, col.names = !file.exists("data/no_expression_brain.csv"),
            append = TRUE, sep = ',')