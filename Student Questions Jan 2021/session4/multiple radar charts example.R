# Multiple radarcharts on single plot
library(tm)
library(lexicon)
library(tidytext)
library(dplyr)
library(reshape2)
library(radarchart)

# Bring in our supporting functions
source('~/Desktop/hult_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')
setwd("~/Desktop/hult_NLP_student/Student Questions Jan 2021/session4")

# 500 news articles
news <- read.csv('exampleNews.csv')

# sources
table(news$id)

# Clean and tidy the corpus
# Create custom stop words
stops <- c(stopwords('english'))

# Paste and collapse by the sources
allTidyCorpora <- list()
for(i in 1:length(unique(news$id))){
  print(unique(news$id)[i])
  x <- subset(news, news$id == unique(news$id)[i])
  x <- VCorpus(VectorSource(x$description))
  x <- cleanCorpus(x, stops)
  x <- DocumentTermMatrix(x)
  x <- tidy(x)
  allTidyCorpora[[make.names(unique(news$id)[i])]] <- x
}

# Now we have 5 list elements, one per source.  Think of it like an Excel workbook with 5 sheets.  Lets look at one
allTidyCorpora$the.washington.post


# Quick NRC and make into the right shape
nrc <- nrc_emotions
terms <- subset(nrc, rowSums(nrc[,2:9])!=0)
sent  <- apply(terms[,2:ncol(terms)], 1, function(x)which(x>0))
head(sent)

# Reshape
nrcLex <- list()
for(i in 1:length(sent)){
  x <- sent[[i]]
  x <- data.frame(term      = terms[i,1],
                  sentiment = names(sent[[i]]))
  nrcLex[[i]] <- x
}
nrcLex <- do.call(rbind, nrcLex)
head(nrcLex)

# Now we need to perform the inner join on each of the 5 list elements 
sentimentTerms <- lapply(allTidyCorpora, inner_join, y = nrcLex, by = c('term'='term'))

# examine one source, we did this 5 times over
head(sentimentTerms$the.washington.post)

# Let's aggregate the term count by source (each list element), sentiment and count 
sourceEmotions <- list()
for(i in 1:length(sentimentTerms)) {
  sentimentTerms[[i]]$source <- names(sentimentTerms)[i] # so far we've been working on individual documents but now we want to aggregate up to the sources, so we append the name, Its like naming a worksheet in a workbook...then using that name and appending a column in the worksheet
  sourceEmotions[[i]] <- aggregate(count ~ sentiment + source, sentimentTerms[[i]], sum) 
}

# Examine
sourceEmotions[[1]] 

# Now we can just put all these together
sourceEmotions <- do.call(rbind, sourceEmotions)

# Just reshape the data with dcast
emos <- dcast(sourceEmotions,sentiment   ~ source )
emos #examine
chartJSRadar(scores = emos, labelSize = 10, showLegend = F)

# Of course if you were doing this for real you would need to control for the leangth document because this is a frequentist look and affected by article length.  For example divide each sum value by the total number of terms used in the articles or something.

# End



