# IPTW-Analysis-in-R-
Coursera causal inference course assignment

**Inverse Probability of Treatment Weighting (IPTW)**

**Overview**

This project was an assignment for an online course titled "A crash course on causality: Infering causal effects from observational data". This assignment evaluates the impact of a job training program on participant earnings using the Lalonde Dataset.

**Problem**

In an observational study, participants in the treatment and control groups may differ from each other in the basline of covariates before the intervention begins. Hence, Naive treatment effect may not be accurate due to the presence of confounds.

**Solution**

To address the limitations of naive treatment effect, this code implements an inverse probability of treatment weighting (IPTW) in R. The script uses logistic regression to estimate treatment probabilities, given the covariates for each participant. Then, it creates a balanced pseudo population for analysis by weighting each particiapnt by the inverse of the probability of being assigned to the treatment group, given the confounds. An addtional analysis was carried out by truncating the weights at the 1st and 99th percentiles to eliminate effects of potential outliers.

**Execution**

Libraries used: tableone, survey, Matching, ipw, MatchIt

Required packages can be installed in R by using install.packages() command. The name of the resspective package is typed inside the brackets of the command.

To run the script on R studio, please ensure the required libraries are installed. Then, copy and paste the script on the console.
