titanic <- titanic_train  %>% filter(!is.na(Age)) %>% ggplot(aes(x=Age,group=Sex, y= ..count.., fill=Sex)) +
  scale_x_continuous() + geom_density(alpha = 0.2, position = "stack") 

params <- titanic_train %>%
  filter(!is.na(Age)) %>%
  summarize(mean = mean(Age), sd = sd(Age))

p <- titanic_train %>%
  filter(!is.na(Age)) %>% ggplot(aes(sample=Age)) + geom_qq(dparams = params) + geom_abline()


options(digits = 3)    # report 3 significant digits
library(tidyverse)
library(titanic)
library(dplyr)
c <- titanic_train %>% summarise(count=n())
x <- titanic_train %>% summarise(sum(Survived))
p <- titanic_train %>% group_by(Sex) %>% summarise(survived = sum(Survived))
z <- titanic_train %>% group_by(Sex) %>% summarise(survived = sum(Survived))  %>% ggplot(aes(x=Sex, y=survived)) + geom_bar(stat="identity", position = position_dodge())

titanic <- titanic_train  %>% filter(Survived %in% c(0,1)) %>% mutate(agegroup = case_when(.$Age >= 0  & .$Age <= 8 ~ '0-8',
                                                                                                 .$Age >= 10 & .$Age <= 18 ~ '10-18',
                                                                                           .$Age >= 18 & .$Age <= 30 ~ '18-30',
                                                                                                 .$Age >= 30  & .$Age <= 50 ~ '30-50',
                                                                                                 .$Age >= 50  & .$Age <= 70 ~ '50-70',
                                                                                                 .$Age >= 70  & .$Age <= 80 ~ '70-80')) %>% ggplot(aes(x=agegroup, y=..count.., fill=agegroup)) + geom_density(alpha = 0.2) + facet_grid(Survived ~ agegroup) 

p <- titanic_train %>% filter(Fare!= 0) %>% 
  ggplot(aes(group=Survived, x=Survived, y=Fare)) + geom_boxplot() + geom_jitter(alpha= 0.2) 

p0 <- titanic_train %>% filter(Survived ==1) %>% ggplot(aes(x=Pclass, y = ..count..)) + geom_bar()
p1 <- titanic_train %>% filter(Survived ==0) %>% ggplot(aes(x=Pclass, y = ..count..)) + geom_bar()
p2 <- titanic_train %>% filter(Survived %in% c(0,1)) %>% ggplot(aes(x=Pclass, y = ..count..)) + geom_bar() + facet_grid(Survived~.)
p3 <- titanic_train %>% filter(Survived %in% c(0,1)) %>% ggplot(aes(x=Pclass, y = ..prop..)) + geom_bar() + facet_grid(Survived~.)

titanic <- titanic_train  %>% filter(Pclass %in% c(1,2,3), Sex %in% c("male", "female")) %>% mutate(agegroup = case_when(.$Age >= 0  & .$Age <= 8 ~ '0-8',
                                                                                           .$Age >= 10 & .$Age <= 18 ~ '10-18',
                                                                                           .$Age >= 18 & .$Age <= 30 ~ '18-30',
                                                                                           .$Age >= 30  & .$Age <= 50 ~ '30-50',
                                                                                           .$Age >= 50  & .$Age <= 70 ~ '50-70',
                                                                                           .$Age >= 70  & .$Age <= 80 ~ '70-80')) %>% ggplot(aes(x=agegroup, y=..count.., fill=Survived)) + geom_density(alpha = 0.2, , position="stack") + facet_grid(Sex ~ Pclass) 