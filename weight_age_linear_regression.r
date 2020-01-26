# A program creates a regression plot of body weight versus weeks for each mouse
# The plot displays the regression line, equation, R-squared, and title.

library(RMySQL)
library(ggplot2)

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
  mice.sex,
  wts.weight
  FROM wts
  INNER JOIN mice ON mice.mouse_id = wts.mouse_name
  INNER JOIN projects ON projects.id = mice.project_id
  INNER JOIN project_types ON project_types.id = projects.project_type_id
  WHERE project_types.name IN ('K2P2EA', 'KOMP2')
  AND datediff(wts.datetime, mice.birth_date) / 7 <= 18
  AND datediff(wts.datetime, mice.birth_date) / 7 >= 3
  AND wts.weight <> -999
  LIMIT 999;")

# close database connection
dbDisconnect(mydb)

# return a vector containing unique mouse names
names <- unique(data$mouse_name)

# loop through each mouse name
for (name in names) {
  
  # get the body weight colunm values
  mouse_weight <- as.numeric(data[which(data$mouse_name==name), "weight"])
  # get the age column values
  mouse_age <- as.numeric(data[which(data$mouse_name==name), "age"])
  # get the sex value (M or F)
  mouse_sex <- data[which(data$mouse_name==name), "sex"][1]
  
  # create a function that creates equation and r-squared as a string
  lm_eqn <- function (x, y) {
    
    model <- lm(x ~ y) # create a linear model
    r2 <- format(summary(model)$r.squared, digits = 3) # get R-squared
    y_int = format(coef(model)[1], digits = 2) # get y-intercept
    coef = format(coef(model)[2], digits = 2) # get coefficient
    names(y_int) <- names(coef) <- NULL # remove the names attribute of vectors
    
    # create the equation and r-squared as a string
    eq <-
      substitute(italic(y) == y_int + coef %.% italic(x) * "," ~ ~ italic(r) ^ 2 ~ "=" ~ r2,
                 list(y_int = y_int, coef = coef, r2 = format(summary(model)$r.squared, digits = 3)))
    as.character(as.expression(eq))
  }
  
  #create a scatterplot displaying a regression line, equation, r-squared, and title label
  pdf(paste0("plots/",name, ".pdf")) # save the plot to a pdf file
  plot <- ggplot(data = subset(data, data$mouse_name == name), aes(x = mouse_age, y = mouse_weight)) + geom_point() +
    geom_smooth(method = "lm", se = FALSE) + geom_text(x = -Inf, y = Inf, label = lm_eqn(mouse_age, mouse_weight), hjust = 0, vjust = 1, parse = TRUE)  + labs(title=paste0(name, " (", mouse_sex, ")"))
  print(plot)
  dev.off() # close the plot
  
  model <- lm(mouse_age ~ mouse_weight) # create a linear model
  r2 <- summary(model)$r.squared # get R-squared
  coef = format(coef(model)[2], digits = 2) # get the rate of weight change
  
  # set column names
  name_col <- "mouse"
  sex_col <- "sex"
  coef_col <- "weight_change_rate"
  r_squared_col <- "r_squared"

  # create the dataframe
  df <- data.frame(name, mouse_sex, coef, r2, stringsAsFactors=FALSE)
  colnames(df) <- c(name_col, sex_col, coef_col, r_squared_col)
  
  # save the dataframe to a csv file
  write.table(df, file="data/r_squared.csv", row.names = FALSE, col.names = !file.exists("data/r_squared.csv"),
              append = TRUE,
              sep = ',')
 }