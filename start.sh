#!/bin/sh
#set -ex

# This project was tested using Minikube v0.23 and Kubernetes V1.8

# Start minikube and ensure security for our demonstration container registry is off
# You may want to adjust the cpu and memory resources to work with your target machine
minikube start --kubernetes-version v1.8.0 --cpus 4 --memory 8192 --insecure-registry '192.168.99.0/24'
# minikube start --kubernetes-version v1.7.5 --cpus 4 --memory 8192 --insecure-registry '192.168.99.0/24'

# See https://github.com/kubernetes/minikube/tree/master/deploy/addons
minikube addons enable registry
minikube addons enable heapster

# Create a namespace where we can play. later it can be deleted 
if kubectl get namespace pact >/dev/null 2>&1 ; then 
  echo 'pact namespace found'
else
  kubectl create namespace pact
fi

# May be a few moments before service is ready to respond to a patch request
# Expose the Registry externally as a NodePort (use 'minikube service list' to find the URL of services)
for i in {1..5}; do \
kubectl patch service registry --namespace=kube-system --type='json' -p='[{"op": "replace",  "path": "/spec/type", "value":"NodePort"}]' \
&& break || echo 'Retrying NodePort adjustment...' && sleep 10; done

minikube status
echo "$(minikube version) is now ready"
echo "Be sure to now run this command: '. ./env.sh'"

# Troubleshooting:
# If Minikube does not start correctly, try wiping it clean with `minikube delete`, then 
# remove `~/.minikube` directory then run this script again. If this does not help sometimes
# a cleaner slate such removing `~/.minikube`, `~/.kube` and `~/.virtualbox` may help.

