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
local_user="kube1"
docker_repo_ip="192.168.7.150"
share_ip="192.168.7.150"
share_username="archive"



################ DISPLAY STARTUP INFORMATION ################
#############################################################
echo
echo ----------------------------------------------------------------
echo Local User                           : $local_user
echo Private Docker Repository Ip Address : $docker_repo_ip
echo Share IP Address                     : $share_ip
echo Share Username                       : $share_username
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
echo ---------------- SETTING THE STATIC IP ADDRESS
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
# install kubernetes as a server
echo
echo ---------------- INSTALLING KUBERNETES AS A SERVER
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable servicelb --node-taint CriticalAddonsOnly=true:NoExecute --disable-cloud-controller --disable local-storage

# configure kubernetes
echo
echo ---------------- CONFIGURING KUBERNETES
mkdir -p /home/"$local_user"/.kube
chown "$local_user":"$local_user" /home/"$local_user"/.kube
sudo k3s kubectl config view --raw > /home/"$local_user"/.kube/config
sudo chown "$local_user":"$local_user" /home/"$local_user"/.kube/config
sudo chmod 700 /home/"$local_user"/.kube/config

# set environment varaible
echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /etc/environment

# get the server's token
echo
echo --------[ THE SERVERS NODE TOKEN ]--------
sudo cat /var/lib/rancher/k3s/server/node-token > /home/"$local_user"/kubernetes.token
cat /home/"$local_user"/kubernetes.token
sudo scp /home/"$local_user"/kubernetes.token "$share_username"@"$share_ip":/mnt/archive/kubernetes/kubernetes.token
rm /home/"$local_user"/kubernetes.token



################ INSTALLING K9S ################
################################################
echo
echo ---------------- INSTALLING K9S
echo
curl -sS https://webi.sh/k9s | sh
sleep 5
source ~/.config/envman/PATH.env
rm -r ~/Downloads
echo



################ CHECK THE REMOTE DOCKER REGISTRY ################
##################################################################
echo
echo ---------------- RETRIEVING PRIVATE DOCKER REPOSITORY CATALOG
echo
curl -i  https://192.168.7.150/v2/_catalog | grep { | python3 -m json.tool
echo -------------------------------------------------------------
echo



################ GETTING THE K3S INSTALLATION FILES ################
####################################################################
echo
echo --------------------------------------------------
echo GETTING THE K3S TOOLS INSTALLATION FILES
echo
sudo scp -r "$share_username"@"$share_ip":/mnt/archive/kubernetes/k3s-tools/ .
echo
echo Install all of the K3S Agents and then return to install the k3s tools.
echo "     Change directory to [ k3s-tools ] and run [ setup-k3s-tools.sh ] to complete the Kubernetes setup."



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
