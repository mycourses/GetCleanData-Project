## Coursera - Johns Hopkins - Getting and Cleaning Data
## Course Project (1 of 1)

# Load the main data column names
features <- read.table("features.txt", header=FALSE,
                       stringsAsFactors = FALSE, col.names=c("featureID", "featureName"))

# Remove potentially problematic characters from column names
features$featureName <- gsub("\\(\\)", features$featureName, replacement="")
features$featureName <- gsub(")$", features$featureName, replacement="")
features$featureName <- gsub("[[:punct:]]", features$featureName, replacement=".")
features$featureName <- gsub("\\.\\.", features$featureName, replacement=".")

# Load the training set tables
x.train <- read.table("./train/X_train.txt", header=FALSE, col.names=features$featureName)
y.train <- read.table("./train/y_train.txt", header=FALSE, col.names="activityID")
subject.train <- read.table("./train/subject_train.txt", header=FALSE, col.names="subjectID")

# Load the test set tables
x.test <- read.table("./test/X_test.txt", header=FALSE, col.names=features$featureName)
y.test <- read.table("./test/y_test.txt", header=FALSE, col.names="activityID")
subject.test <- read.table("./test/subject_test.txt", header=FALSE, col.names="subjectID")

# Add subject ID and activity ID columns to the main data frames
train <- cbind(subject.train, y.train, x.train)
test <- cbind(subject.test, y.test, x.test)

# Combine train and test data frames into one
alldata <- rbind(train, test)

# Subset the data frame by removing unwanted columns
subset.cols <- grep("subjectID|activityID|\\.mean\\.|\\.mean$|\\.std\\.|\\.std$", names(alldata))
alldata <- alldata[,subset.cols]

# Add activity names column and populate with labels from activity_labels.txt
library(plyr)
act <- read.table("activity_labels.txt", header=FALSE, col.names=c("activityID", "activity"))
alldata <- join(alldata, act, by="activityID")
alldata <- alldata[, c(1:2, ncol(alldata), 3:(ncol(alldata)-1))]

# Tidy the column names a bit
names(alldata) <- gsub("\\.mean", "\\.Mean", names(alldata))
names(alldata) <- gsub("\\.std", "\\.SD", names(alldata))

# Create separate data set with mean for each variable per activity and subject
library(reshape2)
groups = c("activityID", "activity", "subjectID")
values = setdiff(colnames(alldata), groups)
mdata <- melt(alldata, id=groups, measure.vars=values)
tidy.data <- dcast(mdata, subjectID + activity ~ variable, mean)    

# Create tab-separated text file with tidy data set for upload / submission
write.table(tidy.data, file="tidydata.txt", sep="\t", row.names=TRUE)

# Clean up and free memory - remove intermediate data frames and variables
rm(list=c("act", "alldata", "features", "groups", "mdata", "subject.test"))
rm(list=c("subject.train", "subset.cols", "test", "tidy.data", "train"))
rm(list=c("values", "x.test", "x.train", "y.test", "y.train"))

# All done!

