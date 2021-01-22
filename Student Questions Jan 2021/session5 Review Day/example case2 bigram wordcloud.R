
# setwd
setwd("~/Desktop/hult_NLP_student/cases/Call of Duty E-Sport/teamTimeline")

# libraries
library(fst)
library(tm)
library(RColorBrewer)

x <- read_fst("student_TeamTimelines.fst")

table(x$screen_name)

# custom functions
tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  #corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

stops <- c(stopwords('english'), 'call', 'duty', 'games', 'cod')
# Bigram token maker
bigramTokens <-function(x){
  unlist(lapply(NLP::ngrams(words(x), 2), paste, collapse = " "), 
         use.names = FALSE)
}

# Make a volatile corpus
txtCorpus <- VCorpus(VectorSource(x$text))
# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Make bi-gram TDM according to the tokenize control & convert it to matrix
codTDM  <- TermDocumentMatrix(txtCorpus, 
                              control=list(tokenize=bigramTokens))
smallerTDM <- removeSparseTerms(codTDM, 0.999)
codTDM <- as.matrix(smallerTDM)

# Get Row Sums & organize
codTDMv <- sort(rowSums(codTDM), decreasing = TRUE)
codTDMv   <- data.frame(word = names(codTDMv), freq = codTDMv)


# Choose a color & drop light ones
pal <- brewer.pal(8, "Purples")
pal <- pal[-(1:2)]

# Make simple word cloud
# Reminder to expand device pane
set.seed(1234)
wordcloud(codTDMv$word,
          codTDMv$freq,
          max.words    = 50,
          random.order = FALSE,
          colors       = pal,
          scale        = c(2,1))

