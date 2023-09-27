#!/bin/bash

################ SETTING UP VARIABLES ################
user_name=$USER
gitea_root_path="$1"/gitea
gitea_data_path="$1"/gitea/data
postgres_path="$1"/gitea/postgres



################ DISPLAYING STARTUP INFORMATION ################
################################################################
echo
echo ---------------- INSATLLING GITEA ------------------------------
echo
echo ----------------------------------------------------------------
echo "User Name       : $user_name"
echo "Gitea Root Path : $gitea_root_path"
echo "Gitea Data Path : $gitea_data_path"
echo "PostgreSQL Path : $postgres_path"
echo ----------------------------------------------------------------



################ CREATING "git" USER ################
#####################################################
echo
echo ---------------- CREATING "git" USER ----------------
sudo adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git



################ GETTING THE "git" USER ID AND GROUP ################
####################################################################
git_user_id=$(id -u git)
git_group_id=$(id -g git)
echo
echo ----------------------------------------------------------------
echo "Git User ID  : $git_user_id"
echo "Git Group ID : $git_group_id"
echo ----------------------------------------------------------------



################ CREATING REQUIRED DIRECTORIES ################
###############################################################
echo 
echo ---------------- CREATING REQUIRED DIRECTORIES ----------------
sudo mkdir -p "$gitea_root_path"
sudo chown git:git "$gitea_root_path"
sudo chmod 775 "$gitea_root_path"

sudo mkdir -p "$gitea_data_path"
sudo chown git:git "$gitea_data_path"
sudo chmod 775 "$gitea_data_path"

sudo mkdir -p "$postgres_path"
sudo chown git:git "$postgres_path"
sudo chmod 775 "$postgres_path"



################ PREPARING THE "docker-compose.yaml" FILE ################
##########################################################################
echo 
echo ---------------- PREPARING THE "docker-compose.yaml" FILE ----------------
echo
# replace __GIT_USER_ID__ with the "git_user_id" in the [ ./docker-compose.yaml ] file
sed -i -e "s|__GIT_USER_ID__|$git_user_id|g" ./docker-compose.yaml

# replace __GIT_GROUP_ID__ with the "git_group_id" in the [ ./docker-compose.yaml ] file
sed -i -e "s|__GIT_GROUP_ID__|$git_group_id|g" ./docker-compose.yaml

# replace __GITEA_DATA_PATH__ with the "git_group_id" in the [ ./docker-compose.yaml ] file
sed -i -e "s|__GITEA_DATA_PATH__|$gitea_data_path|g" ./docker-compose.yaml

# replace __DATABASE_PATH__ with the "postgres_path" in the [ ./docker-compose.yaml ] file
sed -i -e "s|__DATABASE_PATH__|$postgres_path|g" ./docker-compose.yaml



################ INSTALLING GITEA ################
##################################################
docker compose up -d



################ CHECKING GITEA INSTALLATION ################
#############################################################
sleep 5
echo 
echo ---------------- CHECKING THE GITEA INSTALLATION ----------------
echo
docker compose ps



################ TASK COMPLETE ################
###############################################
ip_address="$(hostname -I | cut -d " " -f1)"
echo
echo "---------------- GITEA HAS BEEN INSTALLED ----------------"
echo
echo "Check out the IP Address: http://$ip_address:3333"
echo "    Register a new user to login"
echo
read -n 1 -s -r -p "Press any key to continue: "
