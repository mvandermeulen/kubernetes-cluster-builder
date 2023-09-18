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
cat << 'EOF' | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.7.200-192.168.7.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
EOF

# CHECKING DEPLOYEMENT
echo
echo -------- CHECKING DEPLOYMENT
echo
watch -n2 '# WAIT FOR THE METAL-LB SYSTEMS TO START; PRESS [ ctrl+c ] TO EXIT
kubectl get all -n metallb-system'
