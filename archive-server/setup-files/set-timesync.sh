#!/bin/bash

# set the current date and time
timedatectl set-ntp false
timedatectl set-time "$1"
sleep 3
timedatectl set-time "$2"

# copy the timesyncd.conf file to it's proper system folder
sudo cp --remove-destination /home/archive/setup-files/timesyncd.conf /etc/systemd/timesyncd.conf
sudo chown root:root /etc/systemd/timesyncd.conf

# set the auto-sync flag to true
timedatectl set-ntp true
