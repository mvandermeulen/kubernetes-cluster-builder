#!/bin/bash

# INSTALLING THE KUBERNETES-DASHBOARD
echo -------- INSTALLING THE KUBERNETES-DASHBOARD
kubectl apply -f ./kubernetes-dashboard.yaml

# WAIT FOR IT
sleep 10

# CHECKING DEPLOYMENT
echo
echo -------- CHECKING DEPLOYMENT
echo
watch -n2 '# WAIT FOR THE KUBERNETES-DASHBOARD SYSTEMS TO START; PRESS [ ctrl+c ] TO EXIT
kubectl get all -n kubernetes-dashboard'

# GETTING THE UI's IP ADDRESS
echo
echo -------- GETTING KUBERNETES-DASHBOARD UI IP ADDRESS
echo "https://192.168.7.210"
echo
echo "Check out the IP Address above in your favorite web browser to be sure it works..."
echo "      Use the alias 'kubedashboardtoken' to get the login token"
echo
echo "-------- GETTING THE KUBERNETES-DASHBOARD TOKEN"
kubectl describe secrets/admin-user -n kubernetes-dashboard | grep token:
echo
