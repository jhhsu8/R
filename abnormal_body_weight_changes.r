# This R program retrieves mice that have gained or lost more than 15% of its body weight in one week.

library(RMySQL)

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
  "SELECT DISTINCT wts.mouse_name,
  datediff(wts.datetime, mice.birth_date) / 7 AS age,
  wts.weight
  FROM wts
  INNER JOIN mice ON mice.mouse_id = wts.mouse_name
  INNER JOIN projects ON projects.id = mice.project_id
  INNER JOIN project_types ON project_types.id = projects.project_type_id
  WHERE project_types.name IN ('K2P2EA', 'KOMP2')
  AND datediff(wts.datetime, mice.birth_date) / 7 <= 18
  AND datediff(wts.datetime, mice.birth_date) / 7 >= 3
  AND wts.weight <> -999
  ORDER BY wts.mouse_name, datediff(wts.datetime, mice.birth_date) / 7;")

# close database connection
dbDisconnect(mydb)

# return a vector containing unique mouse names
names <- unique(data$mouse_name)

# count the number of mice with abnormal weight changes
total_number <- 0

# loop through each mouse name
for (name in names){
  # get the body weight column values
  mouse_weight <- as.numeric(data[which(data$mouse_name == name), "weight"])
  # remove the last value in body weight column
  mouseweight <- mouse_weight[1:(length(mouse_weight)-1)]
  # get the mouse age column values
  mouse_age <- as.numeric(data[which(data$mouse_name == name), "age"])
  # remove the last value in mouse age column
  mouseage <- mouse_age[1:(length(mouse_age)-1)]
  # calculate age difference between last and current weight measurements
  age_diff <- diff(mouse_age)
  # calculate weight difference between last and current weight measurements
  weight_diff <- abs(diff(mouse_weight))
  # calculate weight percentage change between last and current weight measurements
  weight_change <- (weight_diff / mouse_weight[-length(mouse_weight)]) * 100

  # loop through the age_diff vector
  for (i in seq_along(age_diff)) {
   
    # the weight change limit is set to the age difference multiplied by 15%
    if (age_diff[i] == 0) { # if age difference is zero, set age difference to 0.1
      age_diff[i] <- 0.1
      weight_change_limit <- age_diff * 15
    } else {
      weight_change_limit <- age_diff * 15
    }
  }
 
  # if weight change is greater than weight change limit, return True, else return False
  weight_boolean = ifelse(weight_change > weight_change_limit, TRUE, FALSE)

  # if True exists in the weight_boolean, add mouse to the dataframe
  if (TRUE %in% weight_boolean) {
    total_number <- total_number + 1
    
    # set column names
    mouse_col <- "mouse"
    age_col <- "mouse_age"
    weight_col <- "mouse_weight"
    wt_diff_col <- "weight_difference"
    age_diff_col <- "age_difference"
    wt_change_col <- "weight_change"
    wt_change_limit_col <- "weight_change_limit"
    abnormal_change_col <- "abnormal_change"
    
    # create the dataframe
    df <- data.frame(name, mouseage, mouseweight, weight_diff, age_diff, weight_change, weight_change_limit, weight_boolean, stringsAsFactors = FALSE)
    colnames(df) <- c(mouse_col, age_col, weight_col, wt_diff_col, age_diff_col, wt_change_col, wt_change_limit_col, abnormal_change_col)
    
    # save the dataframe to a csv file
    write.table(df, file="data/abnormal_wt_changes.csv", row.names = FALSE, col.names = !file.exists("data/abnormal_wt_changes.csv"),
               append = TRUE,
               sep = ',')
  }
}

# print the total number of mice with abnormal weight changes
cat("Total number of mice with abnormal weight changes:", total_number, "\n")