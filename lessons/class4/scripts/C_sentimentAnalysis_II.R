#' Title: Robust Sentiment Analysis
#' Purpose: Inner join sentiment lexicons to text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'

# Wd
setwd("~/Desktop/hult_NLP_student/lessons/class4/data")

# Libs
library(tm)
library(qdap)
library(lexicon)
library(dplyr)
library(fst)
library(pbapply)
library(mgsub)
library(tidytext)
library(reshape2)
library(wordcloud)
library(viridisLite)

# Bring in our supporting functions & support data objects
source('~/Desktop/hult_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')
emoji <- read.csv('emojis.csv')
stops <- c(stopwords('SMART'),'dell','laptop', 'inspiron', 'windows', 'support')

# Data
forum <- read_fst('2020-12-18_dellForum_k1_k5540.fst', from = 1, to = 1000) #limited for class ~26k posts
#forum <- read_fst('2020-12-18_dellForum_k1_k5540.fst') 

# You can do all the same word frequencies, associations and dendrogams as before but let's explore a bit more indepth

# sub emojis
forum$post <- pbsapply(as.character(forum$post), mgsub, emoji$emoji, emoji$name)

# Clean and Organize
txt <- VCorpus(VectorSource(forum$post))
txt <- cleanCorpus(txt, stops)
content(txt[[1]])

# Extract the clean and subbed text to use polarity 
cleanForum <- data.frame(document = seq_along(forum$postID), #simple id order
                         postID = forum$postID, # keep track of posts
                         text = unlist(sapply(txt, `[`, "content")),stringsAsFactors=F)
# ID the moderators
cleanForum$mods <- ifelse(grepl('DELL-', forum$author)==T, 'DellModerator','Customer')
head(cleanForum)

# Polarity & append each forum post score
pol <- polarity(cleanForum$text,cleanForum$mods)
pol$group

# Append to the clean data
cleanForum$polarityValue <- pol$all$polarity

# Some documents returns NA from polarity, could be only stop words, screenshots etc, chg to 0 
cleanForum$polarityValue[is.na(cleanForum$polarityValue)] <- 0

# Classify the polarity scores
cleanForum$polarityClass <- ifelse(cleanForum$polarityValue>0, 'positive',
                                   ifelse(cleanForum$polarityValue<0, 'negative', 'neutral'))

# No let's assign an emotion to each post; no need to "re-clean" the text
txtDTM   <- DocumentTermMatrix(VCorpus(VectorSource(cleanForum$text)))
tidyCorp <- tidy(txtDTM)
tidyCorp
dim(tidyCorp)

# get nrc
# sometimes there is an issue with this lexicon stemming from a pain with license
#textdata::lexicon_nrc(delete = TRUE) #remove an old verion is you get an error
#textdata::lexicon_nrc() #re-download
nrc     <- get_sentiments(lexicon = c("nrc"))
nrcSent <- inner_join(tidyCorp,nrc, by=c('term' = 'word'))
nrcSent

# Now group by document and select the most numerous 
grpSent <- nrcSent %>% group_by(document, sentiment) %>% summarise(n = sum(count))
grpSent$document <- as.numeric(as.character(grpSent$document))
grpSent

# Cast to wide format
wideSent <- dcast(grpSent, document~sentiment,fun.aggregate = sum,value.var = "n")
head(wideSent) #rowsum of 1 should be 6 based on grpSent
wideSent[grep('\\b100\\b',wideSent$document),] #"negative" should be 5 based on grpSent

# Drop positive/negative & get maximum column, but need to use  if else in case some docs were only pos/neg
wideSent <- wideSent[,-c(7,8)]
wideSent$maxEmotion <- ifelse(rowSums(wideSent[,2:ncol(wideSent)])>0,
                              names(wideSent)[2:ncol(wideSent)][max.col(wideSent[,2:ncol(wideSent)])],
                              'noEmotion')
head(wideSent)

# Some posts are neutral so you cant cbind, instead left_join
cleanForum <- left_join(cleanForum, wideSent, by = c('document'='document'))
cleanForum$maxEmotion[is.na(cleanForum$maxEmotion)] <- 'noEmotion' #NA introduced from join on docs that had no emotion

# Finally, a clean text, with ID, moderators, polarity, and emotional sentiment
head(cleanForum)

# Let's start by subsetting and getting WFM for mods and customers
mods <- subset(cleanForum$text, cleanForum$mods=='DellModerator')
cust <- subset(cleanForum$text, cleanForum$mods=='Customer')
plot(freq_terms(mods, top=35, at.least=2, stopwords = stops))
plot(freq_terms(cust, top=35, at.least=2, stopwords = stops))

# Now let's make a comparison cloud using a loop
polarityLst <- list()
for(i in 1:length(unique(cleanForum$polarityClass))){
  x <- subset(cleanForum$text, cleanForum$polarityClass == unique(cleanForum$polarityClass)[i])
  x <- paste(x, collapse = ' ')
  polarityLst[[unique(cleanForum$polarityClass)[i]]] <- x
}

# Using the list
allPolarityClasses <- do.call(rbind, polarityLst)
allPolarityClasses <- VCorpus(VectorSource(allPolarityClasses))
allPolarityClasses <- TermDocumentMatrix(cleanCorpus(allPolarityClasses, stops))
allPolarityClasses <- as.matrix(allPolarityClasses)

# Add the names from the list, get the order right!
colnames(allPolarityClasses) <- names(polarityLst)

# Make comparison cloud
comparison.cloud(allPolarityClasses, 
                 max.words=75, 
                 random.order=FALSE,
                 title.size=1,
                 colors=brewer.pal(ncol(allPolarityClasses),"Dark2"),
                 scale=c(3,0.1))
dev.off()

# Repeat for the max emotion
emotionLst <- list()
for(i in 1:length(unique(cleanForum$maxEmotion))){
  x <- subset(cleanForum$text, cleanForum$maxEmotion == unique(cleanForum$maxEmotion)[i])
  x <- paste(x, collapse = ' ')
  emotionLst[[unique(cleanForum$maxEmotion)[i]]] <- x
}

# Using the list
allEmotionClasses <- do.call(rbind, emotionLst)
allEmotionClasses <- VCorpus(VectorSource(allEmotionClasses))
allEmotionClasses <- TermDocumentMatrix(allEmotionClasses)
allEmotionClasses <- as.matrix(allEmotionClasses)

# Make sure order is the same as the c(objA, objB) on line ~80
colnames(allEmotionClasses) <- names(emotionLst)

# Make comparison cloud, with this many classes you need a lot more posts to make it viable
comparison.cloud(allEmotionClasses, 
                 max.words=75, 
                 random.order=FALSE,
                 title.size=1,
                 colors=viridis(10),
                 scale=c(3,0.1))

# End
