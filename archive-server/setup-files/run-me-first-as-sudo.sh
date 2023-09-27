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
samba_user="archive"
samba_path="/mnt/share"
registry_path="/mnt/archive"
DIR1="$registry_path"/kubernetes/
DIR2="$registry_path"/kubernetes/docker-certs
DIR3="$registry_path"/kubernetes/docker-certs/public



################ DISPLAY STARTUP INFORMATION ################
#############################################################
echo
echo ----------------------------------------------------------------
echo New IP Address  : "$1"
echo Samba Share User: $samba_user
echo Samba Share Path: $samba_path
echo Docker Registry Path: $registry_path
echo ----------------------------------------------------------------



################ CREATE REQUIRED DIRECTORIES ################
#############################################################
if [ ! -d "$DIR1" ]; then
  echo
  echo ---------------- Creating Directory ["$DIR1"]
  sudo mkdir -p "$DIR1"
  sudo chmod 774 "$DIR1"
  sudo chown "$samba_user":"$samba_user" "$DIR1"
fi
if [ ! -d "$DIR2" ]; then
  echo
  echo ---------------- Creating Directory ["$DIR2"]
  sudo mkdir -p "$DIR2"
  sudo chmod 774 "$DIR2"
  sudo chown "$samba_user":"$samba_user" "$DIR2"
fi
if [ ! -d "$DIR3" ]; then
  echo
  echo ---------------- Creating Directory ["$DIR3"]
  sudo mkdir -p "$DIR3"
  sudo chmod 774 "$DIR3"
  sudo chown "$samba_user":"$samba_user" "$DIR3"
fi



################ CREATING CERTIFICATES ################
#######################################################
FILE1="$DIR2"/domain.crt
if [ ! -f "$FILE1" ]; then
  echo
  echo ---------------- Creating Certificates
  sudo openssl req \
      -newkey rsa:4096 -nodes -sha256 -keyout "$DIR2"/domain.key \
      -addext "subjectAltName = IP:192.168.7.150" \
      -x509 -days 10000 -out "$DIR2"/domain.crt \
      -subj "/C=US/ST=Texas/L=Plano/O=dodson labs/OU=IT/CN=$samba_user"
fi

# COPYING CERTIFICATES TO THE PROPER DIRECTORIES
echo
echo ---------------- Copying and Updating Certificates
sudo mkdir -p /etc/docker/certs.d/192.168.7.150:5000
sudo cp "$DIR2"/domain.crt /etc/docker/certs.d/192.168.7.150:5000/ca.crt
sudo cp "$DIR2"/domain.crt /usr/share/ca-certificates/ca.crt
sudo cp "$DIR2"/domain.crt /usr/local/share/ca-certificates/ca.crt

# CHECK FOR EXISTING CERTIFICATE; COPY IF NOT FOUND
FILE2="$DIR3"/ca.crt
if [ ! -f "$FILE2" ]; then
    sudo cp "$DIR2"/domain.crt "$FILE2"
fi

# UPDATE CERTIFICATES
sudo update-ca-certificates

# RESTARTING DOCKER
echo
echo ---------------- Restarting Docker
sudo systemctl stop docker.service
sudo systemctl start docker.service
sudo systemctl enable docker.service



################ PULLING AND STARTING THE PRIVATE DOCKER REGISTRY ################
#################################################################################### 
echo
echo ---------------- Pulling and Running the Private Docker Registry
docker run -d \
  --restart=always \
  --name registry \
  -v "$DIR2":/certs \
  -v "$registry_path":/var/lib/registry \
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



################ INSTALLING GITEA ################
##################################################
cd ./gitea
./install-gitea.sh "$registry_path"
cd ..
sudo rm -r ./gitea



################ CHECK THE REMOTE DOCKER REGISTRY ################
##################################################################
# remove the mask from the given IP Address
dude="$1"
the_ip_address=${dude%**\/*}
echo
echo ---------------- RETRIEVING PRIVATE DOCKER REGISTRY CATALOG
echo "[  curl -i  https://$the_ip_address/v2/_catalog | grep { | python3 -m json.tool  ]"
echo
curl -i  https://"$the_ip_address"/v2/_catalog | grep { | python3 -m json.tool
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
