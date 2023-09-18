# The Worker Server

The *worker* server will host a samba share folder and a private docker registry. The disk drive and it's partitions have to be setup manually. There are two partitions required:
* Network Share
* Private Docker Registry

# Installing the Worker Server's OS and Software

To execute this Ansible Playbook, run the following command:

`ansible-playbook -K -i inventory configure-os.yaml`

After this Ansible Playbook is finished, log into the server and run the following command:

`sudo ./run-me-first-as-sudo.sh {{ the-ip-address-with-mask-to-set-this-server-to }}`

Example:
    `sudo ./run-me-first-as-sudo.sh 192.168.7.150/22`

# But First, There Are Some Things To Change
## The [ configure-os.yaml ] File
The *configures-os.yaml* file, ansible playbook, has the following instructional line at the beginning of the file:

`
TODO:   worker --> { this is the username }
`

Use 'search and replace' to replace all of the `worker` items with the username for the server.

## The [ inventory ] File
The *inventory* file contains the following information required to connect to the server:

`
192.168.6.100 ansible_connection=ssh ansible_user={{ set-to-server-username }} ansible_ssh_pass={{ set-to-server-ssh-password }}
`

Change the IP Address to the server's IP Address.

Change the `{{ set-to-server-username }}` to the server's username.

Change the `{{ set-to-server-ssh-password }}` to the server's password.

## The [ run-me-first-as-sudo.sh ] File
The *run-me-first-as-sudo.sh* file contains information required to create the directories for the samba share and the private docker registory. It also creates self-signed certificates for the private docker registry and stores them in the share directory.

It will create the samba share and the private docker registory and set the static IP Address.

Change this information as required.

## Look Around
If you plan on changing the IP Address or other information; you may need to look around the files for any errant IP Addresses or other information. For example, in the *configures-os.yaml* file in the *aliases* settings there are hardcoded IP Addresses. Other hard-coded information may be hiding elsewhere in the files.
