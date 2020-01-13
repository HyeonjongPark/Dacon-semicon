#install.packages("readr")

#load packages
library(xgboost)
library(caret)
library(randomForest)
library(readr)

setwd("D:/ensemble-practice")

# load raw data
train = fread("train.csv")
test = fread("test.csv")

str(train)
str(test)

# create the response variable
y = train$Hazard

# create the predictor data set and encode categorical variable using caret library
mtrain = train[,-c(1,2)]
mtest = test[,-c(1)]

dummies = dummyVars(~., data = mtrain)

mtrain = predict(dummies, newdata = mtrain)
mtest = predict(dummies , newdata = mtest)

cat("training model -rf\n")

set.seed(1234)

rf = randomForest(mtrain,y, ntree = 134, imp=TRUE, sampsize = 10000, do.trace = TRUE)
predict_rf = predict(rf, mtest)

param = list("objective" = "reg:linear", "nthread" = 8, "verbose" = 0)

cat("training model -xgboost\n")

xgb.fit = xgboost(param = param , data= mtrain , label = y , nrounds = 2000, eta = .01, 
                  mat_depth = 7, min_child_weight = 5 , scale_pos_weight = 1.0, subsample = 0.8)


predict_xgboost = predict(xgb.fit, mtest)

submission = data.frame(Id = test$Id)
submission$Hazard = (predict_rf + predict_xgboost) / 2
submission


