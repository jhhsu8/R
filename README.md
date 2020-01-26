This repository contains R programs used for analyzing or detecting data quality issues.

1.	abnormal_body_weight_changes.r:

This program retrieves mice that have gained or lost more than 15% of its body weight in one week.

2.	homozygous_embryo_viability.r:

This program queries data from the embryos table and determines homozygous embryo viability.

3.	incorrect_tissue_availability_hierarchies.r:

This program retrieves mice whose organs (e.g. brain) are marked as "not available" but have at least one subunit (e.g. cerebellum) available for assessing protein expression.

4.	incorrect_total_embryo_numbers.r

This program prints the total embryo number that is not equal to the sum of wild-type, heterozygous, and homozygous embryos and the experiment dates.

5.	open_field_scatterplot.r	

This program generates a scatter plot of the number of rears versus date in the Open Field experiment. The plot can be used to monitor the number of rears over time.

6.	Upper_and_lower_limits.r:

This program queries data from the data table and calculates the means and upper and lower limits (IQR and 3-sigma) of parameters for both males and females. It may be helpful for setting up programs for validating input data.

7.	weight_age_linear_regression.r:

This program creates a regression plot of body weight versus weeks for each mouse. The regression plot shows the trend of body weight change of a mouse over the weeks during which the mouse is weighed. Most regressions are found to have reasonably good coefficient of determination, or R-squared, with values mostly 0.8 or higher. A low R-squared, such as 0.5 or lower, could imply measuring problems or some issues with the mouse. Also, any significant deviation in weight from the trend line may suggest either an abrupt change in the health of the mouse or entry errors caused by human or measuring mechanism factors.

8.	weight_age_polynomial_regression.r:

This program generates polynomial regression of body weight on mouse age (in weeks) for each late adult mouse. The regression plot shows the trend of body weight change of a mouse over the weeks during which the mouse is weighed. Most regression results are found to have high R-squared values at 0.9 or higher. A low R-squared value, such as 0.5 or lower, could imply record-keeping problems or some issues with the mouse's health. Also, any significant deviation in weight from the line or curve may suggest either an abrupt change in the health of the mouse or entry 1.errors caused by human or measuring mechanism factors.
