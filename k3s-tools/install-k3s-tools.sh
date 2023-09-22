#!/bin/bash

drawlines() {
    # initialize
    ch=$'\u2550'
    width=$(tput cols)
    line=$(printf "%0.s$ch" $(seq 1 $width))

    # draw lines
    echo
    echo $line
    echo $(printf "%0.s$ch" $(seq 1 16))$'\u2561 '"$1"
    echo $line
    echo
}

pressanykey(){
    echo "-------------------------"
    read -n 1 -s -r -p "Press any key to continue: "
}

# ----------------------------------------------------------------

# -------- SET ALL WORKER NODE LABELS
drawlines "SETTING WORKER NODE LABELS"
./set-worker-node-labels.sh 2 6

# -------- INSTALLING HELM
drawlines "INSTALLING HELM"
cd ./helm
./install-helm.sh

# -------- INSTALLING METALLB
drawlines "INSTALLING METAL-LB"
cd ../metallb
./install-metallb.sh

# -------- INSTALLING LONGHORN
drawlines "INSTALLING LONGHORN"
cd ../longhorn
./install-longhorn.sh
pressanykey

# -------- INSTALLING PORTAINER
drawlines "INSTALLING PORTAINER"
cd ../portainer
./install-portainer.sh
pressanykey

# -------- ARGO-CD
drawlines "INSTALLING ARGO-CD"
cd ../argocd
./install-argocd.sh
pressanykey

# -------- KUBERNETES DASHBOARD
drawlines "INSTALLING KUBERNETES DASHBOARD"
cd ../k8s-dashboard
./install-kubernetes-dashboard.sh
pressanykey

# -------- PROMETHEUS
drawlines "INSTALLING PROMETHEUS"
cd ../prometheus
./install-prometheus.sh
pressanykey

# -------- GRAFANA
drawlines "INSTALLING GRAFANA"
cd ../grafana
./install-grafana.sh
pressanykey

# -------- TASK COMPLETE
drawlines "INSTALLING KUBERNETES TOOLS - TASK COMPLETE"
echo
read -p "Delete this directory? (y|n)" yesno
case $yesno in
    [Yy]* )
        echo Deleting Directory...
        cd ..
        sudo rm -r ./k3s-tools
    ;;
    * )
        echo Leaving the directory intact.
    ;;
esac
