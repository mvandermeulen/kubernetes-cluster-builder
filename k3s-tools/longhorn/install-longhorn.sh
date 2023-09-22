#!/bin/bash

# ADDING LONGHORN TO HELM
echo -------- ADDING LONGHORN TO THE HELM REPOSITORY
helm repo add longhorn https://charts.longhorn.io

# UPDATING HELM
echo
echo -------- UPDATING HELM
helm repo update

# INSTALLING LONGHORN
echo
echo -------- INSTALLING LONGHORN
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set defaultSettings.defaultDataPath="/mnt/storage01"

# ADDING EXTERNAL IP [ ingress ]
echo
echo -------- ADDING LONGHORN INGRESS
kubectl apply -f longhorn-ingress.yaml

# WAIT FOR IT
sleep 10

# CHECKING DEPLOYMENT
echo
echo -------- CHECKING DEPLOYMENT
echo
watch -n2 '# WAIT FOR THE LONGHORN SYSTEMS TO START; PRESS [ ctrl+c ] TO EXIT
kubectl get all -n longhorn-system'

# GETTING THE UI's IP ADDRESS
echo
echo -------- GETTING LONGHORN UI IP ADDRESS
echo "http://192.168.7.212"
echo
echo "Check out the IP Address above in your favorite web browser to be sure it works..."
