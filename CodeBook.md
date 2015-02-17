## The original dataset  

For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

The dataset includes the following files:

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

Notes: 
- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

### Feature Selection 


The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

- tBodyAcc-XYZ  
- tGravityAcc-XYZ  
- tBodyAccJerk-XYZ  
- tBodyGyro-XYZ  
- tBodyGyroJerk-XYZ  
- tBodyAccMag  
- tGravityAccMag  
- tBodyAccJerkMag  
- tBodyGyroMag  
- tBodyGyroJerkMag  
- fBodyAcc-XYZ  
- fBodyAccJerk-XYZ  
- fBodyGyro-XYZ  
- fBodyAccMag  
- fBodyAccJerkMag  
- fBodyGyroMag  
- fBodyGyroJerkMag  

The set of variables that were estimated from these signals are: 

- mean(): Mean value  
- std(): Standard deviation  
- mad(): Median absolute deviation   
- max(): Largest value in array  
- min(): Smallest value in array  
- sma(): Signal magnitude area  
- energy(): Energy measure. Sum of the squares divided by the number of values.   
- iqr(): Interquartile range   
- entropy(): Signal entropy  
- arCoeff(): Autorregresion coefficients with Burg order equal to 4  
- correlation(): correlation coefficient between two signals  
- maxInds(): index of the frequency component with largest magnitude  
- meanFreq(): Weighted average of the frequency components to obtain a mean frequency  
- skewness(): skewness of the frequency domain signal  
- kurtosis(): kurtosis of the frequency domain signal  
- bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.  
- angle(): Angle between to vectors.  

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

- gravityMean  
- tBodyAccMean  
- tBodyAccJerkMean  
- tBodyGyroMean  
- tBodyGyroJerkMean  

## The tidy data

#### The first tidy dataset is called clean.train-test.txt

To generate this tidy dataset, fist the training and test data were combined using the code below. 
The X_*.txt files contain the data, while the y_*.txt files contain the labels that indicate which activity was performed.

```
train <- read.table("train/X_train.txt")
train.labels <- read.table("train/y_train.txt")

test <- read.table("test/X_test.txt")
test.labels <- read.table("test/y_test.txt")

data <- rbind(train,test)
labels <- rbind(train.labels,test.labels)
```

Then only the measurements on the mean and standard deviation for each measurement were extracted from the data. This means that I first identified the columns that contain mean() or std() in the list of features, and then selected these columns from the data. 

```
features <- read.table("features.txt")
#select indexes of rows which contain mean() or std() in V2 (these numbers will identify the correct columns in train data)
inx <- c(grep("mean\\(",features[,2]),grep("std\\(",features[,2]))
data2 <- data[,inx]
```

Then I added descriptive activity names to name the activities in the data set. This was done by matching the activity names as given in the activity_labels.txt file with the activity labels are given in the y_*.txt files.
The resulting activity names can then simply be added as an additional variable (termed "activity") to the tidy dataset.

```
activity <- read.table("activity_labels.txt")
activity.names <- merge(labels,activity,by.x="V1",by.y="V1")
data3 <- cbind(activity=activity.names[,2],data2)
```

To appropriately label the data set with descriptive variable names, I replaced the column headers with the names of the features as given in the feature table. 

```
names(data3) <- c("activity",as.character(features[inx,2]))
```

This line of codes writes the resulting first tidy dataset to a tab delimited text file called "clean.train-test.txt".

```
write.table(data3,"clean.train-test.txt",sep="\t",col.names=TRUE,row.names=FALSE,append=FALSE,quote=FALSE)
```

It contains the following variables:
- activity: this variable describes the activity that was done while the measurements were taken. 
- 66 variables containing mean or standard deviation of the variables described in the feature selection part of this document. 

#### The second tidy dataset is called clean.train-test.means.txt

This tidy data set contains the average of each variable for each activity and each subject.

Therefore i first added the subject IDs to the data.

```
train.sub <- read.table("train/subject_train.txt")
test.sub <- read.table("test/subject_test.txt")
subjects <- rbind(train.sub,test.sub)
data4 <- cbind(subjectID=subjects[,1],data3)
```

Then I used plyr to calculate the means of each variable for each activity and subject.

```
data.means <- ddply(data4,.(subjectID,activity),colwise(mean))
```

This line of codes writes the resulting second tidy dataset to a tab delimited text file called "clean.train-test.means.txt".

```
write.table(data.means,"clean.train-test.means.txt",sep="\t",col.names=TRUE,row.names=FALSE,append=FALSE,quote=FALSE)
```

It contains the following variables:
- SubjectID: This variable gives the ID of the subject that was tested.
- activity: this variable describes the activity that was done while the measurements were taken. 
- 66 variables containing mean or standard deviation of the variables described in the feature selection part of this document, averaged by Subject and activity. 

