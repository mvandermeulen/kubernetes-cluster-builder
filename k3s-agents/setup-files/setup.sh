#!/bin/bash

# -------- SET UP DATE AND TIME
# set the current date and time
timedatectl set-ntp false
timedatectl set-time "$2"
sleep 3
timedatectl set-time "$3"

# copy the timesyncd.conf file to it's proper system folder
sudo cp --remove-destination /home/"$1"/setup-files/timesyncd.conf /etc/systemd/timesyncd.conf
sudo chown root:root /etc/systemd/timesyncd.conf

# set the auto-sync flag to true
timedatectl set-ntp true



# -------- CONFIGURE VIM
sudo mkdir -p /home/"$1"/.vim
sudo mkdir -p /home/"$1"/.vim/autoload
sudo mkdir -p /home/"$1"/.vim/backup
sudo mkdir -p /home/"$1"/.vim/colors
sudo mkdir -p /home/"$1"/.vim/plugged
sudo chown "$1":"$1" /home/"$1"/.vim /home/"$1"/.vim/autoload /home/"$1"/.vim/backup /home/"$1"/.vim/colors /home/"$1"/.vim/plugged
sudo chmod 775 /home/"$1"/.vim /home/"$1"/.vim/autoload /home/"$1"/.vim/backup /home/"$1"/.vim/colors /home/"$1"/.vim/plugged
sudo mv /home/"$1"/setup-files/.vimrc /home/"$1"/



# -------- COPY THE REQUIRED FILES TO THE HOME PATH
sudo mv /home/"$1"/setup-files/run-me-first-as-sudo.sh /home/"$1"/
sudo mv /home/"$1"/setup-files/01-netcfg.yaml /home/"$1"/
sudo chmod 775 /home/"$1"/run-me-first-as-sudo.sh
