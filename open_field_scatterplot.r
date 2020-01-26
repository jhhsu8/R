# A program creates a scatter plot of the number of rears vs date in the Open Field experiment

library(RMySQL)
library(ggplot2)
library(scales)

# connect to database
mydb <- dbConnect(
  MySQL(),
  user = "username",
  password = "password",
  dbname = "database",
  host = "hostname"
)

# query the data from the table
data <- dbGetQuery(
  mydb,
  "SELECT open_fields.datetime AS date, open_fields.number_of_rears
  FROM open_fields
  INNER JOIN mice ON mice.mouse_id = open_fields.mouse_name
  INNER JOIN projects ON projects.id = mice.project_id
  INNER JOIN project_types ON project_types.id = projects.project_type_id
  WHERE project_types.name IN ('K2P2EA', 'KOMP2')
  AND datediff(open_fields.datetime, mice.birth_date) / 7 <= 11
  AND datediff(open_fields.datetime, mice.birth_date) / 7 >= 7;")

# close database connection
dbDisconnect(mydb)

# get the rear number column values
# convert the column values to numeric type
data[, "number_of_rears"] <- as.numeric(data[, "number_of_rears"])

# set NA values in the rear number column to 0
data$number_of_rears[is.na(data$number_of_rears)] <- 0

#set date string as date object 
data$date = as.Date(data$date)

# create a scatterplot of the date versus number of rears
plot <- ggplot(data = data, aes(x = date, y = number_of_rears)) + geom_point() + 
  scale_x_date(labels = date_format("%b %Y")) + 
  labs(x = "Date", y = "Number of rears / 5 minutes", title="Number of Rears vs Date") 

# save the plot to a png file
png(paste0("plots/open_field_rears.png"))

# close the plot
dev.off()