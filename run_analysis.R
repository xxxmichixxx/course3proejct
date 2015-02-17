#load required packages
require(plyr)

### 1. Merge the training and the test sets to create one data set ###

train <- read.table("train/X_train.txt")
train.labels <- read.table("train/y_train.txt")

test <- read.table("test/X_test.txt")
test.labels <- read.table("test/y_test.txt")

data <- rbind(train,test)
labels <- rbind(train.labels,test.labels)


### 2.Extract only the measurements on the mean and standard deviation for each measurement ###
features <- read.table("features.txt")
#select indexes of rows which contain mean() or std() in V2 (these numbers will identify the correct columns in train data)
inx <- c(grep("mean\\(",features[,2]),grep("std\\(",features[,2]))
data2 <- data[,inx]

### 3.Use descriptive activity names to name the activities in the data set ###
activity <- read.table("activity_labels.txt")
activity.names <- merge(labels,activity,by.x="V1",by.y="V1")
data3 <- cbind(activity=activity.names[,2],data2)

### 4.Appropriately label the data set with descriptive variable names ###
names(data3) <- c("activity",as.character(features[inx,2]))
#write output table
write.table(data3,"clean.train-test.txt",sep="\t",col.names=TRUE,row.names=FALSE,append=FALSE,quote=FALSE)

###5. create a second, independent tidy data set with the average of each variable for each activity and each subject ###

#add the subject IDs
train.sub <- read.table("train/subject_train.txt")
test.sub <- read.table("test/subject_test.txt")
subjects <- rbind(train.sub,test.sub)
data4 <- cbind(subjectID=subjects[,1],data3)

#calculate means and write output table
data.means <- ddply(data4,.(subjectID,activity),colwise(mean))
write.table(data.means,"clean.train-test.means.txt",sep="\t",col.names=TRUE,row.names=FALSE,append=FALSE,quote=FALSE)

