library(dplyr)
library(lubridate)
library(ggplot2)

# Data
tweets <- read.csv('A_Oct2019.csv')

# Just get a subset to show how its done
teamSample <- tweets %>% group_by(team) %>% sample_n(25)

# Deal with timestamp
teamSample$timeStamp <- as.Date(teamSample$created)
teamSample$day      <- day(teamSample$timeStamp)# just different temporal windows, you could do yr, month, quarter etc
teamSample$weekdays <- weekdays(teamSample$timeStamp)

# Examine 
head(teamSample)

# Get a sentiment or polarity score for each document, I chose polarity but it could be any of the others 
sampPolarity <- polarity(teamSample$text) # this will take a while but the other methods are faster

# Join the polarity back
teamSample <- cbind(teamSample, polarity = sampPolarity$all$polarity)
head(teamSample)

# Aggregate by some timeframe & team group
aggregate(polarity ~ team + weekdays, teamSample, mean) #every team, every weekday what is the avg polarity
aggregate(polarity ~ + weekdays, teamSample, mean) # no teams but now every weekday what is avg polarity
aggregate(polarity ~ day + team, teamSample, mean) #polarity by day of the month and team

# Any of the above data can be a dataframe for visualising
leaguePolarityByDay <- aggregate(polarity ~ + weekdays, teamSample, mean)

# Reorder the weekdays since its a factor level
leaguePolarityByDay$weekdays <- factor(leaguePolarityByDay$weekdays , levels= c("Sunday", "Monday", 
                                         "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

leaguePolarityByDay[order(leaguePolarityByDay$weekdays), ]

ggplot(leaguePolarityByDay, aes(weekdays,polarity))+
  geom_col() +
  labs(title="Barplot with geom_col()")

