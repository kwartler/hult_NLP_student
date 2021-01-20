# Example polarity with grouping


# 
fakeDF <- data.frame(team = c("Hawks", "Cavs", "Cavs"),
                     text    = c('this is horrible', 'this is amazing', 'they are great'))
fakeDF

x <- polarity(fakeDF$text)
x$group$ave.polarity



x <- polarity(fakeDF$text, fakeDF$team)
x$all                     
x$group$ave.polarity
