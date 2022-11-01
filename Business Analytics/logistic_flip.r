library(readr)
library(caret)
library(glmnet)

data <- read_csv("finalv1.csv")

data2 <- data

data2$flipped <- ifelse(data2$flipped  == TRUE, 1,0)
data2$party <- ifelse(data2$party  == "DEMOCRAT", 1,0)



randrows <- runif(nrow(data2))
train <- randrows < .75
test <- randrows >=.75
data2.train <- data2[train ,]

data2.test <- data2[test,]

formula <- flipped ~ party+ White + Black.AfricanAmerican +AmericanIndian.AlaskanNative +Asian +
  NativeHawaiian.PacificIslander + Other +TwoOrMore + WC + BC+ AIC +AC + NH +OC + TMC

x.train <- model.matrix(formula,data2.train)
y.train <- data2.train$flipped
lasso.fit1 <- cv.glmnet(x.train,y.train, alpha=1 , lambda = 10^(-3:3) , nfolds=5,type.measure = "class", family = "binomial")
bestlam <- lasso.fit1$lambda.min
lasso.fit2 <- glmnet(x.train,y.train, alpha=1 , lambda = bestlam, family = "binomial")
predict(lasso.fit2,type="coefficients",s=bestlam)

x.test <- model.matrix(formula,data2.test)
y.test <- data2.test$flipped

logit.test <- predict(lasso.fit2, x.test, type="response")
logit.error <- mean((ifelse(logit.test >= i/100, 1,0) - y.test)**2)
mist <- c()
for (i in 1:100){
  error <- mean((ifelse(logit.test >= i/100, 1,0) - y.test)**2)
  mist <- c(mist,error)
}
which.max(mist)
mist
