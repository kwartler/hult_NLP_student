# Text Analytics
Hult University Student Repository 


## Working with R
If you are new to R, please take an online course to get familarity prior to the first session.  We will still cover R basics but students have been aided by spending a few hours taking a free online course at [DataQuest](www.dataquest.com) or [DataCamp](www.datacamp.com).  The code below should be run in the console to install packages needed for the semester.

## Please install the following packages with this R code.
If you encounter any errors don't worry we will find time to work through them.  The `qdap` library is usually the trickiest because it requires Java and `rJava` and does not work on Mac.  So if you get any errors, try removing that from the code below and rerunning.  This will take **a long time** if you don't already have the packages, so please run prior to class, and at a time you don't need your computer ie *at night*.
```
# Individually you can use 
# install.packages('packageName') such as below:
install.packages('ggplot2')

# or 
install.packages('pacman')
pacman::p_load(caret,clue,cluster,dplyr,e1071,echarts4r,fst,ggalt,ggdendrogram,
 ggplot2,ggthemes,ggwordcloud,glmnet,hunspell,kmed,lda,LDAvis,leaflet,lexicon,
 lsa,mapproj,maps,mgsub,MLmetrics,pbapply,pdftools,plotrix,plyr,pROC,qdap,
 radarchart,rbokeh,RColorBrewer,readxl,reshape2,RTextTools,rvest,skmeans,
 spelling,stringi,stringr,text2vec,tidytext,tm,treemap,viridisLite,vtreat,
 wordcloud,wordcloud2,yardstick)

# Additionally we will need this package from a different repo
install.packages('openNLPmodels.en', 
                  repos= 'http://datacube.wu.ac.at/')
```

