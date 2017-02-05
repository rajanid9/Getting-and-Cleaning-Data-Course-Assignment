This document describes the code used in run_analysis.R for generating a tidy data set (tidydata.txt) from the raw data (UCI HAR Dataset)

##Assumptions:
Excluding Inertial Data - Since the inertial signals data in the data set have no columns associated with mean and standard deviation 
which is the course assignment goal, this data will be excluded from the tidy data set

Mean and STD columns - All columns with mean and std in the column names will be extracted in the process of creating the tidy data set


##R Packages used:

Downloader package for easier download of files over http and https
install.packages("downloader")
library(downloader)

data.table package for fast manipulation and aggregation of large data
install.packages("data.table")
library(data.table)

dplyr package for transforming tabular data
install.packages("dplyr")
library(dplyr)

##Download Raw data into working directory

Create an R object data_url to store the raw data set location
data_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

Use download function to download the UCI HAR Dataset.zip into working directory with binary mode
download(data_url,dest = "./UCI HAR Dataset.zip",mode = "wb")

Use unzip function to extract the contents into working directory "R:/Data Science Coursera"
unzip("UCI HAR Dataset.zip",exdir = "R:/Data Science Coursera")

After this step, UCI HAR Dataset will be saved in the working directory

## Creating Tidy Data Set

## Step1 : Merge the test and training data sets to create one data set

The UCI HAR Dataset has test, train folders and other text files:activity_labels,features,features_info and README

Please refer to README.txt for information on each of the files in the UCI HAR Dataset

## Read Metadata
Create R data frame objects for storing metadata for the test and train data sets using read.table

features.txt - contains feature names
features <- read.table("./UCI HAR Dataset/features.txt",header = FALSE)
Adding column names for easier understanding
colnames(features) <- c("featurelabel","featurename")

activity_labels.txt - contains activity names
activities <- read.table("./UCI HAR Dataset/activity_labels.txt",header = FALSE)
Adding column names for easier understanding
colnames(activities) <- c("activitylabel","activityname")


## Read test and training data
The test and train data sets are split into separate text files for activity, features and subject

Create R data frame objects for storing test and train data sets using read.table

testdataset <- read.table("./UCI HAR Dataset/test/X_test.txt",header = FALSE)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",header = FALSE)
activity_test <- read.table("./UCI HAR Dataset/test/y_test.txt",header = FALSE)

traindataset <- read.table("./UCI HAR Dataset/train/X_train.txt",header = FALSE)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",header = FALSE)
activity_train <- read.table("./UCI HAR Dataset/train/y_train.txt",header = FALSE)

## Merging data

Use the row binding function to merge the test and training datasets for subject, activity and features

subjectdata <- rbind(subject_train,subject_test)
activitydata <- rbind(activity_train,activity_test)
testtraindataset <- rbind(traindataset,testdataset)

Adding column names for easier understanding
colnames(subjectdata) <- "subject"
colnames(activitydata) <- "activitylabel"

Using the column names from metadata- features to give column names for testtraindataset
using the unlist function to convert features dataframe into a vector containing the required column names
colnames(testtraindataset) <- unlist(features$featurename)

combine the metadata with the testtraindataset using cbind function
dataset <- cbind(subjectdata,activitydata,testtraindataset)

## Step 2: Extract only the measurements on the mean and standard deviation for each measurement

Extract only the columns with mean and std in their column names from the testtraindataset
using the grep function to search mean and std string in column names

columnswithmeanstd <- grep("*mean*|*std*",colnames(dataset),ignore.case = TRUE)

add subject and activity columns as well for traceability

extractcolumns <- c(1,2,columnswithmeanstd)

extract the data set with only the required columns

extractdataset <- dataset[,extractcolumns]

## Step 3: Use descriptive activity names to name the activities in the data set

Get activity names by joining (left join) extractdataset with activities (metadata)
Using dplyr function left_join to lookup activity names based on activity_label.
This function will create activityname as the last column in the dataset

extractdataset <- left_join(extractdataset,activities)

extracting columns in the order subject[1] activityname[89] and featurecolumns [3:388] for better visibility

tidydataset <- extractdataset[c(1,89,3:88)]

## step 4: Appropriately label the data set with descriptive variable names

use the str function to see the variable names and data types
There are abbreviations(t,f,acc,gyro,mag) in the data set and repetetions(bodybody) and special characters (-)

use the gsub function to replace abbreviations with full names for easier understanding

Replace t with time and f with frequency
colnames(tidydataset) <- gsub("^t","time",colnames(tidydataset))
colnames(tidydataset) <- gsub("^f","frequency",colnames(tidydataset))

change columnnames to lowercase to avoid case issues
colnames(tidydataset) <- tolower(colnames(tidydataset))

Replace acc with accelerometer, gyro with gyroscope and Mag with magnitude
colnames(tidydataset) <- gsub("acc","accelerometer",colnames(tidydataset))
colnames(tidydataset) <- gsub("gyro","gyroscope",colnames(tidydataset))
colnames(tidydataset) <- gsub("mag","magnitude",colnames(tidydataset))

Replace tbody with timebody and bodybody with body
colnames(tidydataset) <- gsub("tbody","timebody",colnames(tidydataset))
colnames(tidydataset) <- gsub("bodybody","body",colnames(tidydataset))

Replace -mean() with mean and -std() with std and meanfreq with frequency
colnames(tidydataset) <- gsub("-mean()","mean",colnames(tidydataset))
colnames(tidydataset) <- gsub("-std()","std",colnames(tidydataset))
colnames(tidydataset) <- gsub("meanfreq","meanfrequency",colnames(tidydataset))

Replace activityname with activity
colnames(tidydataset) <- gsub("activityname","activity",colnames(tidydataset))

Make subject as a factor variable 
tidydataset$subject <- as.factor(tidydataset$subject)

## Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

Creating independent dataset tidydata as a data.table for fast aggregation from tidydataset object created in the prev step
tidydata <- data.table(tidydataset)

Use aggregate function (dot notation) to create summary statisitics by grouping on subject and activity and then calculating the mean of remaining variables

tidydata <- aggregate(.~ subject+activity,tidydata,mean)

Sorting by subject and activity for better visibility
tidydata <- tidydata[order(tidydata$subject,tidydata$activity),]

use str(tidydata) to check the resulting dataset
The resulting data frame tidydata has 180 observations with 88 variables

## Exporting the tidydata object to a text file
write.table(tidydata,file = 'tidydata.txt',row.names = FALSE)

