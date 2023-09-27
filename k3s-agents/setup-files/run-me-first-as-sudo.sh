#!/bin/bash

################ CHECK COMMAND LINE ARGUMENTS ################
##############################################################
# CHECK FOR ROOT USER
if (( $EUID != 0 )); then
    echo "Please run as root.  [ sudo run-me-first-as-sudo.sh 192.168.7.255/22 ]"
    exit
fi

# CHECK FOR IP ADDRESS
if [ -z "$1" ]; then
    echo "Enter an IP Address with a Mask.  [ sudo run-me-first-as-sudo.sh 192.168.7.255/22 ]"
    exit 0
fi

# CHECK FOR VALID IP ADDRESS
REGEX='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,3}'
if [[ ! $1 =~ $REGEX ]]; then
    echo "Enter a valid IP Address with a Mask.  [ sudo run-me-first-as-sudo.sh 192.168.7.255/22 ]"
    exit 0
fi

# -------- SET VARIABLES
local_user="kube6"
docker_repo_ip="192.168.7.150"
kubernetes_ip="192.168.7.151"
share_ip="192.168.7.150"
share_username="archive"



################ DISPLAY STARTUP INFORMATION ################
#############################################################
echo
echo ----------------------------------------------------------------
echo Local User                           : $local_user
echo Private Docker Repository Ip Address : $docker_repo_ip
echo Kubernetes Master IP Address         : $kubernetes_ip
echo Share IP Address                     : $share_ip
echo Share Password                       : $share_username
echo ----------------------------------------------------------------



################ SETUP DOCKER CERTIFICATES ################
###########################################################
# -------- COPY DOCKER CERTIFICATES
echo
echo ---------------- COPYING PRIVATE DOCKER REPOSITORY CERTIFICATES
# copy the certificate from the file-share to "/usr/local/share/ca-certificates/"
sudo scp "$share_username"@"$share_ip":/mnt/archive/kubernetes/docker-certs/public/ca.crt /usr/local/share/ca-certificates/ca.crt

# copy the certificate from the file-share to "/etc/docker/certs.d/{docker_ip}\:5000"
sudo mkdir -p /etc/docker/certs.d/"$docker_repo_ip"\:5000
sudo cp /usr/local/share/ca-certificates/ca.crt /etc/docker/certs.d/"$docker_repo_ip"\:5000/ca.crt

# UPDATE CERTIFICATES
echo
echo ---------------- UPDATING THE PRIVATE DOCKER REPOSITORY CERTIFICATES
sudo update-ca-certificates

# RESTART AND ENABLE DOCKER
echo
echo ---------------- RESTARTING AND ENABLING DOCKER
sudo systemctl stop docker.service
sudo systemctl start docker.service
sudo systemctl enable docker.service



################ SETTING THE STATIC IP ADDRESS ################
###############################################################
echo
echo "---------------- SETTING THE STATIC IP ADDRESS TO [ $1 ]"
echo
echo "Static IP Address: [ $1 ]"
echo "   If you are running this remotely [ SSH ] then you"
echo "   will need to terminate the console and log back in."
echo
# replace _IP_ADDRESS_ with the actual IP Address in the [ ./01-netcfg.yaml ] file
sed -i -e "s|_IP_ADDRESS_|$1|g" ./01-netcfg.yaml

# COPY FILE
sudo rm /etc/netplan/*
sudo mv ./01-netcfg.yaml /etc/netplan/

# APPLY FILE
sudo netplan apply

# DISPLAY RESULTS
echo
echo --------[ THE NEW IP ADDRESS ]--------
echo "  [  ip a|grep 'inet '|grep 'eth0'  ]"
ip a|grep 'inet '|grep 'eth0'
echo ----------------------------------------
echo



################ SETUP KUBERNETES ################
##################################################
# GET THE KUBERNETES SERVER TOKEN
echo ---------------- GETTING THE KUBERNETES SERVER TOKEN
sudo scp "$share_username"@"$share_ip":/mnt/archive/kubernetes/kubernetes.token /home/"$local_user"/kubernetes.token
kubernetes_token=$(cat /home/"$local_user"/kubernetes.token)
echo "$kubernetes_token"
echo

# INSTALL KUBERNETES AS A SERVER
echo ---------------- INSTALLING KUBERNETES AS AN AGENT
curl -sfL https://get.k3s.io | K3S_URL=https://"$kubernetes_ip":6443 K3S_TOKEN="$kubernetes_token" sh -
echo

# CONFIGURE KUBERNETES
echo ---------------- CONFIGURING KUBERNETES
mkdir -p /home/"$local_user"/.kube
chown "$local_user":"$local_user" /home/"$local_user"/.kube
sudo k3s kubectl config view --raw > /home/"$local_user"/.kube/config
sudo chown "$local_user":"$local_user" /home/"$local_user"/.kube/config

# set environment varaible
echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /etc/environment

# delete the kubernetes token
sudo rm /home/"$local_user"/kubernetes.token



################ CHECK THE REMOTE DOCKER REGISTRY ################
##################################################################
echo
echo ---------------- RETRIEVING PRIVATE DOCKER REPOSITORY CATALOG
echo
curl -i  https://192.168.7.150/v2/_catalog | grep { | python3 -m json.tool
echo -------------------------------------------------------------
echo



################ TASK COMPLETE ################
###############################################
echo
echo --------------------------------------------------
echo TASK COMPLETE
echo
read -p "Delete this file? (y|n)" yesno
case $yesno in
    [Yy]* )
        echo Deleting File...
        rm ./run-me-first-as-sudo.sh
    ;;
    * )
        echo Leaving the file intact.
    ;;
esac

echo
read -p "Reboot? (y|n)" yesno
case $yesno in
    [Yy]* )
        echo Rebooting...
        sleep 1.5
        reboot
    ;;
    * )
        echo Task Complete.
    ;;
esac
