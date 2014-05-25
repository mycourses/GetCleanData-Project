# Coursera - Johns Hopkins - Getting and Cleaning Data
# Course Project (1 of 1)

<br/>
-----
<br/>

### Load the main data column names
```{r}
features <- read.table("features.txt", header=FALSE,
                       stringsAsFactors = FALSE, col.names=c("featureID", "featureName"))
```

<br/>
### Remove potentially problematic characters from column names
```{r}
features$featureName <- gsub("\\(\\)", features$featureName, replacement="")
features$featureName <- gsub(")$", features$featureName, replacement="")
features$featureName <- gsub("[[:punct:]]", features$featureName, replacement=".")
features$featureName <- gsub("\\.\\.", features$featureName, replacement=".")
```

<br/>
### Load the training set tables
```{r}
x.train <- read.table("./train/X_train.txt", header=FALSE, col.names=features$featureName)
y.train <- read.table("./train/y_train.txt", header=FALSE, col.names="activityID")
subject.train <- read.table("./train/subject_train.txt", header=FALSE, col.names="subjectID")
```

<br/>
### Load the test set tables
```{r}
x.test <- read.table("./test/X_test.txt", header=FALSE, col.names=features$featureName)
y.test <- read.table("./test/y_test.txt", header=FALSE, col.names="activityID")
subject.test <- read.table("./test/subject_test.txt", header=FALSE, col.names="subjectID")
```

<br/>
### Add subject ID and activity ID columns to the main data frames
```{r}
train <- cbind(subject.train, y.train, x.train)
test <- cbind(subject.test, y.test, x.test)
```

<br/>
### Combine train and test data frames into one
```{r}
alldata <- rbind(train, test)
```

<br/>
### Subset the data frame by removing unwanted columns
```{r}
subset.cols <- grep("subjectID|activityID|\\.mean\\.|\\.mean$|\\.std\\.|\\.std$",
                    names(alldata))
alldata <- alldata[,subset.cols]
```

<br/>
### Add activity names column and populate with labels from activity_labels.txt
```{r}
library(plyr)
act <- read.table("activity_labels.txt", header=FALSE, col.names=c("activityID", "activity"))
alldata <- join(alldata, act, by="activityID")
alldata <- alldata[, c(1:2, ncol(alldata), 3:(ncol(alldata)-1))]
```

<br/>
### Tidy the column names a bit
```{r}
names(alldata) <- gsub("\\.mean", "\\.Mean", names(alldata))
names(alldata) <- gsub("\\.std", "\\.SD", names(alldata))
```

<br/>
### Create separate data set with mean for each variable per activity and subject
```{r}
library(reshape2)
groups = c("activityID", "activity", "subjectID")
values = setdiff(colnames(alldata), groups)
mdata <- melt(alldata, id=groups, measure.vars=values)
tidy.data <- dcast(mdata, subjectID + activity ~ variable, mean)    
```

<br/>
### Create tab-separated text file with tidy data set for upload / submission
```{r}
write.table(tidy.data, file="tidydata.txt", sep="\t", row.names=TRUE)
```

<br/>
### Clean up and free memory - remove intermediate data frames and variables
```{r}
rm(list=c("act", "alldata", "features", "groups", "mdata", "subject.test"))
rm(list=c("subject.train", "subset.cols", "test", "tidy.data", "train"))
rm(list=c("values", "x.test", "x.train", "y.test", "y.train"))
```

## All done!

