#!/bin/bash

# ADDING METALLB TO HELM'S REPOSITORY
echo -------- ADDING METAL-LB TO THE HELM REPOSITORY
helm repo add metallb https://metallb.github.io/metallb

# UPDATING HELM
echo
echo -------- UPDATING HELM
helm repo update

# INSTALLING METALLB
echo
echo -------- INSTALLING METAL-LB
helm upgrade --install metallb metallb/metallb --create-namespace --namespace metallb-system --wait

# CONFIGURING METALLB
echo 
echo -------- CONFIGURING METAL-LB
kubectl apply -f metallb-ipaddresspool.yaml

# CHECKING DEPLOYEMENT
echo
echo -------- CHECKING DEPLOYMENT
echo
watch -n2 '# WAIT FOR THE METAL-LB SYSTEMS TO START; PRESS [ ctrl+c ] TO EXIT
kubectl get all -n metallb-system'
