# Include the required libraries for the script. Reshape2 /Plyr package will help Flexibly restructure and aggregate data. 
library(reshape2)
library(plyr)

#Download the File from the Source URL given
if (!file.exists("UCI")) {	dir.create("UCI") }
{
  filedownloadURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(filedownloadURL, destfile="UCI.zip")
}  
# Unzip the file.If the unzipped file already exists skip it. 
if (!file.exists("UCI HAR Dataset")) 
{ 
  unzip("UCI.zip") 
}

# Load the Raw data from Training data set and Testing Data Set
train <- read.table("UCI HAR Dataset/train/X_train.txt") 
test <- read.table("UCI HAR Dataset/test/X_test.txt")

# Load the Features Data
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract the Features from Features' data that contains the Features description as Mean or Std 
features_mean_std <- grep(".*mean.*|.*std.*", features[,2])

# Extract only the extracted Features from the Training and Testing Data 
TrainSubset<-train[,features_mean_std]
TestSubset<-test[,features_mean_std]

# Merge the Training and testing data
TrainTest<-rbind(TrainSubset, TestSubset)

# Get the Feature Description for the Extracted features in order to update the column names of the merged Data set
features_mean_std_desc<-features[features_mean_std,2]

# Tidy up the Feature Description
features_mean_std_desc = gsub('-mean', 'Mean', features_mean_std_desc)
features_mean_std_desc = gsub('-std', 'Std', features_mean_std_desc)
features_mean_std_desc <- gsub('[-()]', '', features_mean_std_desc)

# update the Column names of merged Training and Testing Data set with tidied description extracted from Features
colnames(TrainTest)<-c(features_mean_std_desc)

# Load  Activities Data from Training and Testing
TrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TestActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")

# Combine the Activities data
TrainTestActivities<-rbind(TrainActivities, TestActivities)

# Load the Activity Labels Data
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Rename the column name of Activities dataset as "activity"
names(TrainTestActivities)<-c("activity")

# Update the Values of the Activities dataset with the description of the activities from Activity label data
TrainTestActivities[,1]<-activityLabels[TrainTestActivities[,1],2]

# Load the Subjects data of Training and Testing Data 
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
TestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

# Combine the Subject Data
TrainTestSubjects<-rbind(TrainSubjects, TestSubjects)

# Rename the column name of Subject data
names(TrainTestSubjects)<-c("subject")

#Combine all the datasets :Traintest Data with Activities and Subject Data
AlltranformedData<-cbind(TrainTestSubjects, TrainTestActivities, TrainTest)

# Calculate the mean of the Transformed data based on Subject and Activity.
Tidy_Averagedata <- ddply(AlltranformedData, .(subject, activity), function(x) {colMeans(x[, 3:81])})

# Write the tidy dataset with quotes removed and row names removed
write.table(Tidy_Averagedata, "Tidy_Averagedata.txt", row.name=FALSE, quote=FALSE)


