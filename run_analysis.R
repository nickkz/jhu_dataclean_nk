##1. initial setup - libraries and working folder
library(httr)
library(httpuv)
library(sqldf)
library(dplyr)
library(jpeg)
library(reshape2)
setwd("Q:/dev/coursera/dataclean/jhu_dataclean_nk")

##2. load common files
features <- read.table("./UCI HAR Dataset/features.txt")
colnames(features) = c("var", "header")
activities <- read.table("./UCI HAR Dataset/activity_labels.txt", colClasses = c("factor", "character"))
colnames(activities) = c("id", "activity")

##3. load test data
test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
colnames(test_subject) <- c("participant")
test_labels <- read.table("./UCI HAR Dataset/test/y_test.txt", colClasses = c("factor"))
colnames(test_labels) <- c("id")
test_labels_activity <- left_join (test_labels, activities)
test_set <- read.table("./UCI HAR Dataset/test/X_test.txt")
colnames(test_set) <- features$header
test_data <- cbind(test_subject, test_labels_activity, test_set)

##4. load train data
train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
colnames(train_subject) <- colnames(test_subject)
train_labels <- read.table("./UCI HAR Dataset/train/y_train.txt", colClasses = c("factor"))
colnames(train_labels) <- colnames(test_labels)
train_labels_activity <- left_join (train_labels, activities)
train_set <- read.table("./UCI HAR Dataset/train/X_train.txt")
colnames(train_set) <- colnames(test_set)
train_data <- cbind(train_subject, train_labels_activity, train_set)

##5. merge test and training data sets
merged_data <- rbind(train_data, test_data)

##6. extract mean and std columns
mean_std_cols <- colnames(merged_data)[grep("*(participant|activity|mean|std)",colnames(merged_data))]
merged_data_mean_std <- merged_data[,mean_std_cols]

##7. reshape into 1 row per participant, activity, data collection type
merged_data_mean_std_melted <- melt(merged_data_mean_std, id.vars=c("participant", "activity"))

##8. then create a summarized data set 
merged_data_mean_std_group_by <- group_by(merged_data_mean_std_melted, participant, activity, variable)
merged_data_mean_std_summarize <- summarize(merged_data_mean_std_group_by, mean = mean(value))

##9. verify final data
cat (nrow(merged_data_mean_std_summarize), 30 * 6 * 79)
head(merged_data_mean_std_summarize)

##10. output final data
write.table(merged_data_mean_std_summarize, file = "merged_data_mean_std_summarize.txt", quote=FALSE, row.names=FALSE)
