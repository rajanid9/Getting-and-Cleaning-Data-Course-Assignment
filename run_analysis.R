## R Script used to create tidy data set (tidydata.txt) from raw data (UCI HAR Dataset)    

## Packages used
install.packages("downloader")
library(downloader)

install.packages("data.table")
library(data.table)

install.packages("dplyr")
library(dplyr)

## Download Raw data into working directory
data_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download(data_url,dest = "./UCI HAR Dataset.zip",mode = "wb")
unzip("UCI HAR Dataset.zip",exdir = "R:/Data Science Coursera")

## Creating Tidy Data Set

## Step1 : Merge the test and training data sets to create one data set

## Read Metadata
features <- read.table("./UCI HAR Dataset/features.txt",header = FALSE)
colnames(features) <- c("featurelabel","featurename")

activities <- read.table("./UCI HAR Dataset/activity_labels.txt",header = FALSE)
colnames(activities) <- c("activitylabel","activityname")

## Read test and training data
testdataset <- read.table("./UCI HAR Dataset/test/X_test.txt",header = FALSE)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",header = FALSE)
activity_test <- read.table("./UCI HAR Dataset/test/y_test.txt",header = FALSE)

traindataset <- read.table("./UCI HAR Dataset/train/X_train.txt",header = FALSE)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",header = FALSE)
activity_train <- read.table("./UCI HAR Dataset/train/y_train.txt",header = FALSE)

## Merging data

subjectdata <- rbind(subject_train,subject_test)
activitydata <- rbind(activity_train,activity_test)
testtraindataset <- rbind(traindataset,testdataset)

colnames(subjectdata) <- "subject"
colnames(activitydata) <- "activitylabel"

## Using the column names from metadata- features to give column names for testtraindataset
colnames(testtraindataset) <- unlist(features$featurename)

dataset <- cbind(subjectdata,activitydata,testtraindataset)

## Step 2: Extract only the measurements on the mean and standard deviation for each measurement

## columns with mean and std
columnswithmeanstd <- grep("*mean*|*std*",colnames(dataset),ignore.case = TRUE)

## add subject and activity columns as well for traceability
extractcolumns <- c(1,2,columnswithmeanstd)

## extracted dataset with required columns
extractdataset <- dataset[,extractcolumns]

## Step 3: Use descriptive activity names to name the activities in the data set

## Get activity names by joining (left join) extractdataset with activities (metadata)

extractdataset <- left_join(extractdataset,activities)

## extracting columns in the order subject[1] activityname[89] and featurecolumns [3:388]

tidydataset <- extractdataset[c(1,89,3:88)]

## step 4: Appropriately label the data set with descriptive variable names

## Replace t with time and f with frequency
colnames(tidydataset) <- gsub("^t","time",colnames(tidydataset))
colnames(tidydataset) <- gsub("^f","frequency",colnames(tidydataset))

## change columnnames to lowercase to avoid case issues
colnames(tidydataset) <- tolower(colnames(tidydataset))

## Replace acc with accelerometer, gyro with gyroscope and Mag with magnitude
colnames(tidydataset) <- gsub("acc","accelerometer",colnames(tidydataset))
colnames(tidydataset) <- gsub("gyro","gyroscope",colnames(tidydataset))
colnames(tidydataset) <- gsub("mag","magnitude",colnames(tidydataset))

## Replace tbody with timebody and bodybody with body
colnames(tidydataset) <- gsub("tbody","timebody",colnames(tidydataset))
colnames(tidydataset) <- gsub("bodybody","body",colnames(tidydataset))

## Replace -mean() with mean and -std() with std and meanfreq with frequency
colnames(tidydataset) <- gsub("-mean()","mean",colnames(tidydataset))
colnames(tidydataset) <- gsub("-std()","std",colnames(tidydataset))
colnames(tidydataset) <- gsub("meanfreq","meanfrequency",colnames(tidydataset))

## Replace activityname with activity
colnames(tidydataset) <- gsub("activityname","activity",colnames(tidydataset))

## Make subject as a factor variable
tidydataset$subject <- as.factor(tidydataset$subject)

## Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
## Creating tidydata as a data.table for fast aggregation
tidydata <- data.table(tidydataset)

## Use aggregate function (dot notation) to create summary statisitics
tidydata <- aggregate(.~ subject+activity,tidydata,mean)

##Sorting by subject and activity for better visibility
tidydata <- tidydata[order(tidydata$subject,tidydata$activity),]

## Exporting the tidydata object to a text file
write.table(tidydata,file = 'tidydata.txt',row.names = FALSE)
