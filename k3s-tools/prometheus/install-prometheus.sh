#!/bin/bash

# ADDING THE MONITORING NAMESPACE
echo -------- ADDING THE MONITORING NAMESPACE
kubectl create namespace monitoring

# INSTALLING PROMETHEUS OPERATORS
echo
echo -------- INSTALLING PROMETHEUS OPERATORS
kubectl apply --server-side -f ./prometheus-operators.yaml

# INSTALLING PROMETHEUS OPERATORS
echo
echo -------- INSTALLING LONGHORN SERVICE MONITORS
kubectl apply --server-side -f ./longhorn-servicemonitor.yaml

# INSTALLING PROMETHEUS OPERATORS
echo
echo -------- INSTALLING PROMETHEUS NODE EXPORTER
kubectl apply --server-side -f ./node-exporter.yaml

# INSTALLING PROMETHEUS OPERATORS
echo
echo -------- INSTALLING KUBE STATE METRICS
kubectl apply --server-side -f ./kube-state-metrics.yaml

# INSTALLING PROMETHEUS OPERATORS
echo
echo -------- INSTALLING KUBLET
kubectl apply --server-side -f ./kublet.yaml

# INSTALLING PROMETHEUS OPERATORS
echo
echo -------- INSTALLING TRAEFIK
kubectl apply --server-side -f ./traefik.yaml

# INSTALLING PROMETHEUS OPERATORS
echo
echo -------- INSTALLING PROMETHEUS
kubectl apply --server-side -f ./prometheus.yaml

# CHECKING DEPLOYMENT
echo
echo -------- CHECKING PROMETHEUS
echo
watch -n2 '# WAIT FOR THE PROMETHEUS SYSTEMS TO START; PRESS [ ctrl+c ] TO EXIT
kubectl get all -n monitoring'

# GETTING THE UI's IP ADDRESS
echo
echo -------- GETTING PROMETHEUS UI IP ADDRESS
echo "http://192.168.7.214:9090/"
echo
echo "Check out the IP Address above in your favorite web browser to be sure it works..."
