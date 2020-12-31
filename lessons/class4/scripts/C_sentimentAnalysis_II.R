#' Title: Sentiment Analysis
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
library(lexicon)
library(tidytext)
library(dplyr)
library(qdap)
library(radarchart)
library(fst)
library(pbapply)
library(mgsub)

# Bring in our supporting functions & support data objects
source('~/Desktop/hult_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')
emoji <- read.csv('emojis.csv')
stops <- c(stopwords('SMART'),'dell','laptop', 'inspiron')

# Data
forum <- read_fst('2020-12-18_dellForum_k1_k5540.fst', from = 1, to = 1000) #limited for class ~26k posts

# You can do all the same word frequencies, associations and dendrogams as before but let's explore a bit more indepth

# sub emojis
forum$post <- pbsapply(as.character(forum$post), mgsub, emoji$emoji, emoji$name)

# Clean and Organize
txt <- VCorpus(VectorSource(forum$post))
txt <- cleanCorpus(txt, stops)
content(txt[[1]])

# Extract the clean and subbed text to use polarity 
cleanForum <- data.frame(postID = forum$postID, # keep track of posts
                         text = unlist(sapply(txt, `[`, "content")),stringsAsFactors=F)
# ID the moderators
cleanForum$mods <- ifelse(grepl('DELL-', forum$author)==T, 'DellModerator','Customer')
head(cleanForum)

# Polarity & append each post score
pol <- polarity(cleanForum$text,cleanForum$mods)
pol$group

cleanForum$pol <- pol$all$polarity

# No let's assign an emotion to each post; no need to "re-clean" the text
txtDTM <- DocumentTermMatrix(VCorpus(VectorSource(cleanForum$text)))
tidyCorp <- tidy(txtDTM)
tidyCorp
dim(tidyCorp)

# get nrc
nrc <- get_sentiments(lexicon = c("nrc"))


# End
