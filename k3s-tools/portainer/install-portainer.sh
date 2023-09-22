#!/bin/bash

# ADDING PORTAINER TO HELM'S REPOSITORY
echo -------- ADDING PORTAINER TO THE HELM REPOSITORY
helm repo add portainer https://portainer.github.io/k8s/

# UPDATING HELM
echo
echo -------- UPDATING HELM
helm repo update

# INSTALLING PORTAINER
echo
echo -------- INSTALLING PORTAINER
helm install --create-namespace -n portainer portainer portainer/portainer

# ADDING EXTERNAL IP [ ingress ]
echo
echo -------- ADDING PORTAINER INGRESS
kubectl apply -f portainer-ingress.yaml

# CHECKING DEPLOYMENT
echo
echo -------- CHECKING DEPLOYMENT
echo
watch -n2 '# WAIT FOR THE PORTAINER SYSTEMS TO START; PRESS [ ctrl+c ] TO EXIT
kubectl get all -n portainer'

# GETTING THE UI's IP ADDRESS
echo
echo -------- GETTING PORTAINER UI IP ADDRESS
echo "http://192.168.7.216:9000/"
echo
echo "Check out the IP Address above in your favorite web browser to be sure it works..."
