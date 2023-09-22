#!/bin/bash

# CREATING THE ARGOCD NAMESPACE
echo -------- CREATING THE ARGO-CD NAMESPACE
kubectl create namespace argocd

# INSTALLING ARGO-CD
echo
echo -------- INSTALLING ARGO-CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ADDING EXTERNAL IP [ ingress ]
echo
echo -------- ADDING ARGO-CD INGRESS
kubectl patch service argocd-server -n argocd --patch '{ "spec": { "type": "LoadBalancer", "loadBalancerIP": "192.168.7.218" } }'

# WAIT FOR IT
sleep 10

# CHECKING DEPLOYMENT
echo
echo -------- CHECKING DEPLOYMENT
echo
watch -n2 '# WAIT FOR THE ARGOCD SYSTEMS TO START; PRESS [ ctrl+c ] TO EXIT
kubectl get all -n argocd'

# GETTING THE UI's IP ADDRESS
echo
echo -------- GETTING ARGO-CD UI IP ADDRESS
echo "http://192.168.7.218"
echo "     USERNAME: admin"
echo "     PASSWORD: "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
echo
echo "Check out the IP Address above in your favorite web browser to be sure it works..."
echo "     Change the username and password:"
echo "         Click on 'User Info' in the left menu"
echo "         Click 'Update Password' in the menu along the top"
echo
