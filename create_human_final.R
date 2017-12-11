# Name: Elisabet Rams 
# Date: 11/12/2017
# Email: elisabet.ramsbeltran@helsinki.fi
# File description: Data wrangling for the final assignment
# Source of the data: Introduction to Open Data Science course through MOOC. 
# [Meta file for data set](http://hdr.undp.org/en/content/human-development-index-hdi)

# We read the data files:

hd <- read.csv("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/human_development.csv", stringsAsFactors = F)

gii <- read.csv("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/gender_inequality.csv", stringsAsFactors = F, na.strings = "..")

# Look the structure, dimensions and summaries:

str(hd)
dim(hd)
summary(hd)

###########################################################

str(gii)
dim(gii)
summary(gii)


# Rename variables with shorter names:

colnames(hd)[1] <- "HDI.rank"
colnames(hd)[2] <- "country"
colnames(hd)[3] <- "HDI"
colnames(hd)[4] <- "lifexp"
colnames(hd)[5] <- "yr.eduexp"
colnames(hd)[6] <- "meanyr.edu"
colnames(hd)[7] <- "GNI"
colnames(hd)[8] <- "GNIrank-HDIrank"


colnames(gii)[1] <- "GII.rank"
colnames(gii)[2] <- "country"
colnames(gii)[3] <- "GII"
colnames(gii)[4] <- "matermor"
colnames(gii)[5] <- "adobirth"
colnames(gii)[6] <- "repreparl"
colnames(gii)[7] <- "edu2F"
colnames(gii)[8] <- "edu2M"
colnames(gii)[9] <- "labforceF"
colnames(gii)[10] <- "labforceM"

colnames(hd)
colnames(gii)

# Mutate the "Gender inequality" data to create 1 new variable, the mean of female and male population with at least seconday education. 

library(dplyr)
gii <- mutate(gii, edu2.mean = (gii$edu2F+gii$edu2M)/2)

colnames(gii)
summary(gii$edu2.mean)


# Join the two datasets using variable country as the identifier:

human <- inner_join(hd, gii, by = "country")

# Overview the new dataset:

glimpse(human)

# We mutate the data transforming the GNI variable to numeric. But first we must transform the comma separating the thousands so R would be able to read it properly.

install.packages("stringr")
library(stringr)

human <- mutate(human, GNI = str_replace(human$GNI, pattern = ",", replace = "") %>% as.numeric())
human$GNI

# We want to keep only few variables in our dataset to analyze:

keep <- c("country", "yr.eduexp", "meanyr.edu", "edu2F", "edu2.mean", "lifexp", "matermor", "adobirth", "GNI")
human <- select(human, one_of(keep))

# Remove all rows with missing values:
complete.cases(human)
data.frame(human, comp = complete.cases(human))
human_ <- filter(human, complete.cases(human))

str(human_)

# Remove observations which relate to regions instead of countries:
tail(human_, n= 10)

# It seems that the last 7 observations from human has regions instead of countries, so we should remove the last 7 observations.
# First we identify with a new object the last 7 observations and then we select everything except those last 7 observations.

last <- nrow(human_) - 7

human_ <- human_[1:last,]

# We define the row names of the data by the country names.

rownames(human_) <- human_$country

# We remove the country name column from the data.

human_ <- select(human_, -country)

str(human_)
glimpse(human_)

# Finally, we save overwriting the previous human.csv file.
setwd("C:/Users/Elisabet/Desktop/ELI/MASTER'S DEGREE/Open Data Science/GitHub/IODS-final/")

write.table(human_, file = "human.csv", sep = " ", col.names = TRUE, row.names = TRUE)

human <- read.table(file="human.csv", header = TRUE, row.names = 1)
str(human)