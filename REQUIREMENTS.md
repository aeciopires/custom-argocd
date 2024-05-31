<!-- TOC -->

- [Requirements to develop/test in this project](#requirements-to-developtest-in-this-project)
  - [Basic requirements](#basic-requirements)
    - [General Commands](#general-commands)
      - [Ubuntu](#ubuntu)
    - [Install Docker-CE](#install-docker-ce)
    - [Trivy](#trivy)
  - [Advanced requirements](#advanced-requirements)
    - [Kubernetes Cluster](#kubernetes-cluster)
    - [Install Kubectl](#install-kubectl)

<!-- TOC -->

Requirements to develop/test in this project

# Packages

## Ubuntu

Install the following packages:

```bash
sudo apt install make git
```

# Docker

Follow the instructions on the page to install Docker.

* Ubuntu: https://docs.docker.com/engine/install/ubuntu/
* Debian: https://docs.docker.com/engine/install/debian/
* CentOS: https://docs.docker.com/engine/install/centos/
* MacOS: https://docs.docker.com/desktop/install/mac-install/

Start the Docker service, configure Docker to boot with the operating system and add your user to the Docker group.

```bash
# Start the Docker service
sudo systemctl start docker

# Configure Docker to boot up with the OS
sudo systemctl enable docker

# Add your user to the Docker group
sudo usermod -aG docker $USER
sudo setfacl -m user:$USER:rw /var/run/docker.sock
```

Reference: https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot

# Trivy

To perform a vulnerability scan of Docker images locally, before sending to the Docker Hub, ECR, GCR or other remote registry, you can use trivy: https://github.com/aquasecurity/trivy

The documentation on Github presents information about installing on Ubuntu and other GNU / Linux distributions and / or other operating systems, but it is also possible to run via Docker using the following commands:

```bash
mkdir /tmp/caches

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/caches:/root/.cache/ aquasec/trivy image IMAGE_NAME:IMAGE_TAG
```

# Kubernetes Cluster

You will need to create a Kubernetes cluster locally using [minikube](https://minikube.sigs.k8s.io/docs/start/), [microk8s](https://microk8s.io), [kind](https://kind.sigs.k8s.io/docs/user/quick-start/), [k3s](https://k3s.io) or other tools.

Or use Kubernetes cluster in [EKS](https://aws.amazon.com/eks), [GKE](https://cloud.google.com/kubernetes-engine), [AKS](https://docs.microsoft.com/en-us/azure/aks), [DOKS](https://www.digitalocean.com/products/kubernetes) or other cloud provider.

# Kubectl

Simple shell function for Kubectl installation in Linux 64 bits. Copy and paste this code:

```bash
sudo su

VERSION=v1.30.1
KUBECTL_BIN=kubectl

function install_kubectl {
if [ -z $(which $KUBECTL_BIN) ]; then
    curl -LO https://dl.k8s.io/release/$VERSION/bin/linux/amd64/$KUBECTL_BIN
    chmod +x ${KUBECTL_BIN}
    sudo mv ${KUBECTL_BIN} /usr/local/bin/${KUBECTL_BIN}
else
    echo "Kubectl is most likely installed"
fi
}

install_kubectl

which kubectl

kubectl version --client

exit
```

Kubectl documentation:

https://kubernetes.io/docs/reference/kubectl/overview/

**Credits:** Juan Pablo Perez - https://www.linkedin.com/in/juanpabloperezpeelmicro/ 

https://github.com/peelmicro/learn-devops-the-complete-kubernetes-course
