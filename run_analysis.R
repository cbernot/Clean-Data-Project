
setwd("./gatherproject")
library(dplyr)
library(tidyr)
fileurl<-("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
download.file(fileurl,destfile="./data.zip")
unzip("./data.zip")
##check out files before reading to see format
##read tables in
xtest<-read.table("./UCI HAR Dataset/test/X_test.txt")
ytest<-read.table("./UCI HAR Dataset/test/y_test.txt")
subtest<-read.table("./UCI HAR Dataset/test/subject_test.txt")
xtrain<-read.table("./UCI HAR Dataset/train/X_train.txt")
ytrain<-read.table("./UCI HAR Dataset/train/y_train.txt")
subtrain<-read.table("./UCI HAR Dataset/train/subject_train.txt")
actlabels<-read.table("./UCI HAR Dataset/activity_labels.txt")
xvarlabels<-read.table("./UCI HAR Dataset/features.txt")
##assign in column names
colnames(xtrain)<-xvarlabels[,2]
colnames(xtest)<-xvarlabels[,2]
colnames(ytrain)<-"activityid"
colnames(ytest)<-"activityid"
colnames(subtest)<-"volunteer"
colnames(subtrain)<-"volunteer"
colnames(actlabels)<-c("activityid","activityname")
##merge datasets for test and train
train<-cbind(xtrain,ytrain,subtrain)
test<-cbind(xtest,ytest,subtest)
masterdata<-rbind(train,test)

##extract only mean and std dev activities

subsetin<-grepl("std|mean|volunteer|activityid",names(masterdata))
subsetdata<-masterdata[,subsetin==TRUE]
subsetdata<-select(subsetdata,-contains("meanFreq"))
##add activityname to dataframe by activityid
subsetdata2<-merge(subsetdata,actlabels,by="activityid",all.x=TRUE)
##creat descriptive names for variables
##need to take out punctuation
subnames<-names(subsetdata2)
subnames<-gsub("[()]","",subnames)
subnames<-gsub("-","",subnames)
subnames<-gsub("BodyBody","Body",subnames)
subnames<-gsub("mean","Mean",subnames)
subnames<-gsub("std","Std",subnames)
subnames<-gsub("^t","time",subnames)
subnames<-gsub("^f","freq",subnames)
colnames(subsetdata2)<-subnames
##create a second data set that contains the average of each variable for each activity by each subject
subgroup<-subsetdata2%>%group_by(volunteer,activityname)
newdata<-summarise_each(subgroup,funs(mean),timeBodyAccMeanX:freqBodyGyroJerkMagStd)
##write newdata to a final tidydata csv file
write.csv(newdata, file = "tidydata.csv")
write.table(newdata, file="tidydata.txt",row.names=FALSE)







