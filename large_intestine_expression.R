# This program retrieve mice without any large intestine recorded but have large intestine subunits assessed for lacZ expression

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
  "SELECT laczs.mouse_name,
  laczs.large_intestine,
  laczs.colon,
  laczs.cecum
  FROM laczs 
  WHERE laczs.large_intestine = 'tissue not available';"
)

dbDisconnect(mydb)

len <- length(colnames(data)) #get number of columns

# exclude mice with all large intestine subunits that are "not available".
data <- data[apply(data[,2:len], 1, function(x) length(unique(x)) != 1), ]

# if at least one subunit is lacZ-expressed, large intestine should be lacZ-expressed
df1 <- data[apply(data[,3:len], 1, function(x) any(x == "expression")), ]
write.table(df1, file="data/expression_large_intestine.csv", row.names = FALSE, col.names = !file.exists("data/expression_large_intestine.csv"),
             append = TRUE, sep = ',')

# if all available subunits are not lacZ-expressed, large intestine is not be lacZ-expressed
df2 <- data[apply(data[,3:len], 1, function(x) all(x %in% c("no expression", "tissue not available"))), ]
write.table(df2, file="data/no_expression_large_intestine.csv", row.names = FALSE, col.names = !file.exists("data/no_expression_large_intestine.csv"),
             append = TRUE, sep = ',')
