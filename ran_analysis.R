#libraries
library(dplyr)
library(reshape2)

#get data via internet
Data_Raw <- "./Data_Raw"
Data_Raw_Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
Data_Raw_file <-"Data_Raw.zip"
Data_Raw_final <-paste(Data_Raw, "/", "Data.zip", sep = "")
Data <-"./data"

if (!file.exists(Data_Raw)) {
  dir.create(Data_Raw)
  download.file(url = Data_Raw_Url, destfile = Data_Raw_final)
}
if (!file.exists(Data)) {
  dir.create(Data)
  unzip(zipfile = Data_Raw_final, exdir = Data)
}

#train data
X_train <- read.table(paste(sep = "", Data, "/UCI HAR Dataset/train/X_train.txt"))
Y_train <- read.table(paste(sep = "", Data, "/UCI HAR Dataset/train/Y_train.txt"))
Subject_train <- read.table(paste(sep = "", Data, "/UCI HAR Dataset/train/subject_train.txt"))


# test data
X_test <- read.table(paste(sep = "", Data, "/UCI HAR Dataset/test/X_test.txt"))
Y_test <- read.table(paste(sep = "", Data, "/UCI HAR Dataset/test/Y_test.txt"))
Subject_test <- read.table(paste(sep = "", Data, "/UCI HAR Dataset/test/subject_test.txt"))


#merge the train and test set
X_data <- rbind(X_train, X_test)
Y_data <- rbind(Y_train, Y_test)
Subject_data <-rbind(Subject_train,Subject_test)



#load activities  info and features
Feature <- read.table(paste(sep = "", Data, "/UCI HAR Dataset/features.txt"))
Activities <-read.table(paste(sep = "", Data, "/UCI HAR Dataset/activity_labels.txt"))

# extract feature cols & names named 'mean, std'
selectedCols <- grep("-(mean|std).*", as.character(Feature[,2]))
selectedColNames <- Feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)

# using descriptive name
x_data <- X_data[selectedCols]
allData <- cbind(Subject_data, Y_data, X_data)

colnames(allData) <- c("Subject", "Activity", selectedColNames)


allData$Activity <- factor(allData$Activity, levels = Activities[,1], labels = Activities[,2])
allData$Subject <- as.factor(allData$Subject)



#tidy data

melted_Data <- melt(allData, id = c("Subject", "Activity"))
tidy_Data_final <- dcast(melted_Data, Subject + Activity ~ variable, mean)


# tidy data final version as text 
write.table(tidy_Data_final, "FinalData.txt", row.name=FALSE)


