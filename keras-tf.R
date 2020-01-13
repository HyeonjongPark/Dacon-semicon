
install.packages("keras")
library(keras)

model = keras_model_sequential()
model

mnist = dataset_mnist()
mnist



##  병렬처리

library(foreach)
library(doParallel)


eratosthenes<-function(n){
  residue<-2:n
  while(n %in% residue){
    p<-residue[1]
    residue<-residue[as.logical(residue%%p)]
  }
  return(p)
}



set.seed(150421)
test<-sample(2*1:10^5+1,1000)

system.time({
  for(n in test){
    eratosthenes(n)
  }
})



numCores <- detectCores() -1
myCluster <- makeCluster(numCores)
registerDoParallel(myCluster)



record<-numeric(0)
clusterExport(myCluster, "record")



system.time({
  foreach(n = test, .combine = c) %dopar% {
    eratosthenes(n)
  }
})

stopCluster(myCluster)
