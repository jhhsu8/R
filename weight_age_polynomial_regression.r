# A program for generating polynomial regression of body weight on mouse age for each mouse
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
  WHERE project_types.name IN ('K2P2LA', 'K2P2LWT')
  AND datediff(wts.datetime, mice.birth_date) / 7 <= 61
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
  mouse_weight <- data[which(data$mouse_name==name), "weight"]
  # get the age column values
  mouse_age <- data[which(data$mouse_name==name), "age"]
  # get the sex value (M or F)
  mouse_sex <- data[which(data$mouse_name==name), "sex"][1]
  
  #create a function that creates equation and r-squared as a string
  lm_eqn <- function (x, y) {
    model <- lm(y ~ x + I(x^2)) # create a linear model
    r2 <- format(summary(model)$r.squared, digits = 3) # get R-squared
    y_int = format(coef(model)[1], digits = 2) # get y-intercept
    coef2 = format(coef(model)[2], digits = 2) # get second coefficient
    coef3 = format(coef(model)[3], digits = 2) # get third coefficient
    names(y_int) <- names(coef2) <- names(coef3) <- NULL # remove the names attribute of vectors
 
    # create the equation and r-squared as a string
    eq <-
      substitute(italic(y) == y_int + coef2 %.% italic(x) + coef3 %.% italic(x)^2 * "," ~ ~ italic(r) ^ 2 ~ "=" ~ r2,
                 list(y_int = y_int, coef2 = coef2, coef3 = coef3, r2 = format(summary(model)$r.squared, digits = 3)))
    as.character(as.expression(eq))
  }
   
  #create a scatterplot displaying a regression line, equation, r-squared, and title label
  pdf(paste0("plots/",name, ".pdf")) # save the plot to a pdf file
  plot <- ggplot(data = subset(data, data$mouse_name == name), aes(x = mouse_age, y = mouse_weight)) + geom_point() +
    geom_smooth(method = "lm", se = FALSE, formula = y ~ x + I(x^2)) + geom_text(x = -Inf, y = Inf, label = lm_eqn(mouse_age, mouse_weight), hjust = 0, vjust = 1, parse = TRUE)  + labs(title=paste0(name, " (", mouse_sex, ")"))
  print(plot)
  dev.off() # close the plot
  
  x <- mouse_age # set x to mouse age
  y <- mouse_weight # set y to mouse weight
  model <- lm(y ~ x + I(x^2)) # create a linear model
  r2 <- format(summary(model)$r.squared, digits = 3)  # get R-squared
  second_coef = format(coef(model)[2], digits = 2) # get second coefficient
  third_coef = format(coef(model)[3], digits = 2) # get third coefficient
  
  # set column names
  name_col <- "mouse"
  sex_col <- "sex"
  coef2_col <- "second_coefficient"
  coef3_col <- "third_coefficient"
  r_squared_col <- "r_squared"
  
  # create the dataframe
  df <- data.frame(name, mouse_sex, second_coef, third_coef, r2, stringsAsFactors=FALSE)
  colnames(df) <- c(name_col, sex_col, coef2_col, coef3_col, r_squared_col)
  # save the dataframe to a csv file
  write.table(df, file="data/late_adult_r_squared.csv", row.names = FALSE, col.names = !file.exists("data/late_adult_r_squared.csv"),
              append = TRUE,
              sep = ',')
}