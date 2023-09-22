# Setting Up Useful Tools in the Kubernetes Cluster
The `setup-k3s-tools.sh` file will set all of the agent node's labels to **worker** and install the following tools into the Kubernetes Cluster:
* [Helm](https://helm.sh/)
* [MetalLB](https://metallb.org/)
* [Longhorn](https://longhorn.io/)
* [Prometheus](https://prometheus.io/)
* [Grafana](https://grafana.com/)
* [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
* [Portainer](https://www.portainer.io/)
* [ArgoCD](https://argoproj.github.io/)
* [Gitea](https://about.gitea.com/) COMING SOON
* [Jenkins](https://www.jenkins.io/) COMING SOON

This folder is expected to be located on the **archive** server at the following location: `/mnt/share/.kubernetes/k3s-tools/`

# Changes

## ArgoCD
In the file *install-argocd.sh*, check lines #15 and #30 for the IP Address to expose for the ArgoCD UI.

## Grafana
In the file *install-grafana.sh*, check lines #18 for the IP Address to expose for the Grafana UI.

In the file *grafana.yaml*, check lines #88 for the IP Address to expose for the Grafana UI.

## K8S-Dashboard
In the file *install-kubernetes-dashboard.sh*, check lines #20 for the IP Address to expose for the Kubernetes Dashboard UI.

In the file *dashboard.yaml*, check lines #42 for the IP Address to expose for the Kubernetes Dashboard UI.

## Longhorn
In the file *install-longhorn.sh*, check lines #35 for the IP Address to expose for the Longhorn UI.

In the file *longhorn-ingress.yaml*, check lines #10 for the IP Address to expose for the Longhorn UI.

## MetalLB
In the file *install-metallb.sh*, check lines #28 for the pool of IP Addresses to make available for ingresses.

## Portainer
In the file *install-portainer.sh*, check lines #32 for the IP Address to expose for the Portainer UI.

In the file *portainer-ingress.yaml*, check lines #16 for the IP Address to expose for the Portainer UI.

## Prometheus
In the file *install-prometheus.sh*, check lines #52 for the IP Address to expose for the Prometheus UI.

In the file *prometheus.yaml*, check lines #55 for the IP Address to expose for the Prometheus UI.
