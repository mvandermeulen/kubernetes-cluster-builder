# Installing the Kubernetes Agents

The *agent* nodes are the worker nodes for the kubernetes cluster. They will be marked as workers and will be performing most of the work in the kubernetes cluster.

To execute this Ansible Playbook, run the following command:

`ansible-playbook -K -i inventory configure-os.yaml`

After this Ansible Playbook is finished, log into the server and run the following command:

`sudo ./run-me-first-as-sudo.sh {{ the-ip-address-with-mask-to-set-this-server-to }}`

Example:
    `sudo ./run-me-first-as-sudo.sh 192.168.7.151/22`

Run this Ansible Playbook once for each Kubernetes Agent Node.

# But First, There Are Some Things To Change
## The [ configure-os.yaml ] File
The *configures-os.yaml* file, ansible playbook, has the following instructional line at the beginning of the file:

`
TODO:   kube1   --> username
`

Use 'search and replace' to replace all of the `kube1` items with the username for the server.

## The [ inventory ] File
The *inventory* file contains the following information required to connect to the server:

`
192.168.6.100 ansible_connection=ssh ansible_user={{ set-to-server-username }} ansible_ssh_pass={{ set-to-server-ssh-password }}
`

Change the IP Address to the server's IP Address.

Change the `{{ set-to-server-username }}` to the server's username.

Change the `{{ set-to-server-ssh-password }}` to the server's password.

## The [ run-me-first-as-sudo.sh ] File
The *run-me-first-as-sudo.sh* file contains the following information required to connect to the various servers and the private docker registory:

---
local_user="kube6"

docker_repo_ip="192.168.7.150"

kubernetes_ip="192.168.7.151"

share_ip="192.168.7.150"

share_username="archive"

---

Change this information as required.

## Look Around
If you plan on changing the IP Address or other information; you may need to look around the files for any errant IP Addresses or other information. For example, in the *configures-os.yaml* file in the *aliases* settings there are hardcoded IP Addresses. Other hard-coded information may be hiding elsewhere in the files.
