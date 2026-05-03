# Load libraries
library(tableone)
library(Matching)
library(ipw)
library(survey)
library(MatchIt)

# Load the Lalonde dataset
data(lalonde)

#Data Viewing

View(lalonde) 

#Converting dataset into numeric variables

treat<-as.numeric(lalonde$treat)
age<-as.numeric(lalonde$age)
educ<-as.numeric(lalonde$educ)
black<-as.numeric(lalonde$race == 'black')
hispan<-as.numeric(lalonde$race == 'hispan')
married<-as.numeric(lalonde$married)
nodegree<-as.numeric(lalonde$nodegree)
re74<-as.numeric(lalonde$re74)
re75<-as.numeric(lalonde$re75)
re78<-as.numeric(lalonde$re78)

#creating a dataframe

Lalondedataset <- data.frame(treat, age, educ, black, hispan, married, nodegree, re74, re75, re78)

# Fit the logistic regression model
ps_model <- glm(treat ~ age + educ + black + hispan + married + nodegree + re74 + re75, 
                family = binomial(), 
                data = Lalondedataset)

# Obtain the propensity scores
Lalondedataset$pscore <- predict(ps_model, type = "response")

#Propensity score plot 

hist(Lalondedataset$pscore[Lalondedataset$treat == 1], main="PScores: Treated", col="lightblue", xlim=c(0,1))
hist(Lalondedataset$pscore[Lalondedataset$treat == 0], main="PScores: Control", col="pink", xlim=c(0,1))

# Calculate the Inverse Probability of Treatment Weights (IPTW)
Lalondedataset$IPTW <- ifelse(Lalondedataset$treat == 1, 
                          1 /Lalondedataset$pscore, 
                          1 / (1 - Lalondedataset$pscore))
#Summary of weights

summary(Lalondedataset$IPTW)

# Plot to check distribution of weights

dotchart(Lalondedataset$IPTW, groups = as.factor(Lalondedataset$treat), 
         main="IPTW Weight Distribution", xlab="Weight Value")

#Standardised mean differences

weighted_data <- svydesign(ids = ~1, data = Lalondedataset, weights = ~IPTW)

weighted_table <- svyCreateTableOne(vars = c("age", "educ", "black", "hispan", "married", 
                                             "nodegree", "re74", "re75"), 
                                    strata = "treat", data = weighted_data, test = FALSE)

print(weighted_table, smd = TRUE)

#Average Causal Effect without truncation

iptw_model <- svyglm(re78 ~ treat, design = weighted_data)
summary(iptw_model)
confint(iptw_model)

#Average Causal Effect with truncation of 1st and 99th percentile

#calculation of 1st and 99th percentile
low <- quantile(Lalondedataset$IPTW, 0.01)
high <- quantile(Lalondedataset$IPTW, 0.99)

#Truncation

Lalondedataset$IPTW_trunc <- pmin(pmax(Lalondedataset$IPTW, low), high)

# Plot to compare untruncated and truncated weights

par(mfrow=c(1,2))
hist(Lalondedataset$IPTW, main="Untruncated Weights", col="gray")
hist(Lalondedataset$IPTW_trunc, main="Truncated Weights", col="darkgreen")
par(mfrow=c(1,1))

#Average Causal Effect after trucation

weighted_data_trunc <- svydesign(ids = ~1, data = Lalondedataset, weights = ~IPTW_trunc)
iptw_model_trunc <- svyglm(re78 ~ treat, design = weighted_data_trunc)
summary(iptw_model_trunc)
confint(iptw_model_trunc)

cat("ACE (Truncated):", coef(iptw_model_trunc)[["treat"]], "\n")
confint(iptw_model_trunc)

