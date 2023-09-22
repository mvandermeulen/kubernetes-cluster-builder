#!/bin/bash

# INSTALLING GRAFANA
echo
echo -------- INSTALLING GRAFANA
kubectl apply -f ./grafana.yaml

# CHECKING DEPLOYMENT
echo
echo -------- CHECKING GRAFANA
echo
watch -n2 '# WAIT FOR THE GRAFANA SYSTEMS TO START; PRESS [ ctrl+c ] TO EXIT
kubectl get all -n monitoring'

# GETTING THE UI's IP ADDRESS
echo
echo -------- GETTING GRAFANA UI IP ADDRESS
echo "http://192.168.7.220:3000/"
echo
echo "Check out the IP Address above in your favorite web browser to be sure it works..."
