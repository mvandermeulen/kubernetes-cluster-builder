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
samba_user="worker"
samba_path="/mnt/share"



################ DISPLAY STARTUP INFORMATION ################
#############################################################
echo
echo ----------------------------------------------------------------
echo New IP Address  : "$1"
echo Samba Share User: $samba_user
echo Samba Share Path: $samba_path
echo ----------------------------------------------------------------



################ CREATE REQUIRED DIRECTORIES ################
#############################################################
# CREATE DIRECTORIES
DIR1=/mnt/docker-repository/certs
if [ ! -d "$DIR1" ]; then
  echo
  echo ---------------- Creating Directory ["$DIR1"]
  sudo mkdir -p "$DIR1"
  sudo chmod 777 "$DIR1"
fi
DIR2=/mnt/docker-repository/repository
if [ ! -d "$DIR2" ]; then
  echo
  echo ---------------- Creating Directory ["$DIR2"]
  sudo mkdir -p "$DIR2"
  sudo chmod 777 "$DIR2"
fi
DIR3=/mnt/share/.docker/certs
if [ ! -d "$DIR3" ]; then
  echo
  echo ---------------- Creating Directory ["$DIR3"]
  sudo mkdir -p "$DIR3"
  sudo chmod 777 /mnt/share/.docker
  sudo chmod 777 /mnt/share/.docker/certs
fi



################ CREATING CERTIFICATES ################
#######################################################
FILE="$DIR1"/domain.crt
if [ ! -f "$FILE" ]; then
  echo
  echo ---------------- Creating Certificates
  sudo openssl req \
      -newkey rsa:4096 -nodes -sha256 -keyout "$DIR1"/domain.key \
      -addext "subjectAltName = IP:192.168.7.150" \
      -x509 -days 10000 -out "$DIR1"/domain.crt \
      -subj "/C=US/ST=Texas/L=Plano/O=dodson labs/OU=IT/CN=worker"
fi

# COPYING CERTIFICATES TO THE PROPER DIRECTORIES
echo
echo ---------------- Copying and Updating Certificates
sudo mkdir -p /etc/docker/certs.d/192.168.7.150:5000
sudo cp "$DIR1"/domain.crt /etc/docker/certs.d/192.168.7.150:5000/ca.crt
sudo cp "$DIR1"/domain.crt /usr/share/ca-certificates/ca.crt
sudo cp "$DIR1"/domain.crt /usr/local/share/ca-certificates/ca.crt
sudo cp "$DIR1"/domain.crt "$DIR3"/ca.crt 

# UPDATE CERTIFICATES
sudo update-ca-certificates

# RESTARTING DOCKER
echo
echo ---------------- Restarting Docker
sudo systemctl stop docker.service
sudo systemctl start docker.service
sudo systemctl enable docker.service



################ PULLING AND STARTING THE PRIVATE DOCKER REPOSITORY ################
#################################################################################### 
echo
echo ---------------- Pulling and Running the Private Docker Repository
docker run -d \
  --restart=always \
  --name registry \
  -v "$DIR1":/certs \
  -v "$DIR2":/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 443:443 \
  registry:2



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
echo --------
echo



################ SETTING UP THE SAMBA NETWORK SHARE ################
####################################################################
echo
echo ---------------- SETTING UP THE SAMBA NETWORK SHARE

# install samba applications
sudo apt install -y samba cifs-utils samba-client

# add the [share_network] to the end of the smb.conf file
sudo tee -a /etc/samba/smb.conf > /dev/null <<EOT
[network_share]
        comment = network-share
        path = "$samba_path"
        browseable = yes
        read only = no
        guest ok = no
        valid user = "$samba_user"
EOT

# restart the samba service
sudo systemctl restart smbd.service

# get the samba service password
sudo smbpasswd -a "$samba_user"



################ CHECK THE REMOTE DOCKER REGISTRY ################
##################################################################
# remove the mask from the given IP Address
dude="$1"
the_ip_address=${dude%**\/*}
echo
echo ---------------- RETRIEVING PRIVATE DOCKER REPOSITORY CATALOG
echo "[  curl -i  https://$the_ip_address/v2/_catalog  ]"
echo
curl -i  https://"$the_ip_address"/v2/_catalog
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
