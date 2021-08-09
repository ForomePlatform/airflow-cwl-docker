# Title     : Sample script to estimate R
# Objective : Show how to use R with CWL-Airflow
# Created by: Michael Bouzinier
# Created on: 8/9/21

simulation <- function(long){
  c <- rep(0,long)
  numberIn <- 0
  for(i in 1:long){
    x <- runif(2,-1,1)
    if(sqrt(x[1]*x[1] + x[2]*x[2]) <= 1){
      numberIn <- numberIn + 1
    }
    prop <- numberIn / i
    piHat <- prop * 4
    c[i] <- piHat
  }
  return(c)
}



args <- commandArgs(trailingOnly=TRUE)
size <- strtoi(args[1])
res <- simulation(size)
cat(size, " -> ", res[size-1], '\n')
