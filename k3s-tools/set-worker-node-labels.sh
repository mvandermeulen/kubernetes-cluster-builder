#!/bin/bash

# CHECK ARGUMENTS
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Two numeric arguments required.   [ set-worker-node-labels.sh 2 6 ]"
    exit
fi

# SETTING WORKER NODE'S LABELS
echo "-------- SETTING WORKER NODE LABELS ( kubernetes.io/role=worker, node-type=worker )"
for i in $(seq $1 $2); 
do
    kubectl label nodes kube${i} kubernetes.io/role=worker
    kubectl label nodes kube${i} node-type=worker
done

# CHECKING NODES
echo
echo -------- CHECKING NODES
echo "[ NODES ]"
kubectl get nodes -o wide | sort -k 1

# WAIT-FOR-IT
sleep 10
