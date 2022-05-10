# Custom Argo CD

<!-- TOC -->

- [Custom Argo CD](#custom-argo-cd)
- [About](#about)
- [Build and send image to Docker Hub](#build-and-send-image-to-docker-hub)
- [Use Argo CD Custom](#use-argo-cd-custom)
- [Deploy of testapp with Argo CD](#deploy-of-testapp-with-argo-cd)
- [Uninstall Argo CD](#uninstall-argo-cd)

<!-- TOC -->

# About

My custom Docker image of Argo CD to add support [Sops](https://github.com/mozilla/sops) and Helm plugins:
* [helm secrets](https://github.com/jkroepke/helm-secrets)
* [helm diff](https://github.com/databus23/helm-diff)

> *Argo CD is un-opinionated about how secrets are managed. There's many ways to do it and there's no one-size-fits-all solution.*
>
> Reference: https://argoproj.github.io/argo-cd/operator-manual/secret-management/

A approach sugested is create custom Docker image of Argo CD.

References:

* https://faun.pub/handling-kubernetes-secrets-with-argocd-and-sops-650df91de173
* https://rtfm.co.ua/en/argocd-a-helm-chart-deployment-and-working-with-helm-secrets-via-aws-kms/
* https://argoproj.github.io/argo-cd/user-guide/helm/#helm-plugins
* https://hackernoon.com/how-to-handle-kubernetes-secrets-with-argocd-and-sops-r92d3wt1
* https://github.com/argoproj/argo-cd/issues/1364
* https://gitlab.com/ittennull/sopshelm
* https://github.com/camptocamp/docker-argocd

# Build and send image to Docker Hub

Install Docker following the instructions in [this tutorial](REQUIREMENTS.md).

> In this image, the ``sops`` command will be configured to encrypt and decrypt secrets using [AWS KMS](https://aws.amazon.com/kms).
>
> More informations in https://github.com/mozilla/sops#kms-aws-profiles. 

Change the image version of Argo CD in ``custom-argocd/Dockerfile`` file, in ``from`` line.

Change value of the ``AWS_KMS_ARN`` variable in ``custom-argocd/Makefile`` file.

Change the value of the ``AWS_PROFILE`` variable in ``custom-argocd/Makefile`` file.

Change the custom image version of Argo CD in ``custom-argocd/Makefile`` file.

Commands to build image:

```bash
cd custom-argocd

make image
make publish
```

Access https://hub.docker.com/r/DOCKER_HUB_ACCOUNT/custom-argocd

Commands to run container:

```bash
cd custom-argocd

make container
```

More information about docker run command: https://docs.docker.com/engine/reference/run/

# Use Argo CD Custom

Access Kubernetes cluster.

Change content of the AWS credentials in file ``custom-argocd/credentials``

Search by **argocd-repo-server** *deployment* and add follow content in ``volumeMounts`` section of file ``custom-argocd/install.yaml``:

```yaml
        - mountPath: /home/argocd/.aws
          name: argocd-aws-credentials
```

Search by **argocd-repo-server** *deployment* and add follow content in ``volumes`` section of file ``custom-argocd/install.yaml``:

```yaml
      - name: argocd-aws-credentials
        secret:
          secretName: argocd-aws-credentials
```

Run the command:

```bash
cd custom-argocd

kubectl create namespace argocd

kubectl delete secret argocd-aws-credentials -n argocd

kubectl create -n argocd secret generic argocd-aws-credentials --from-file=credentials=./credentials

kubectl apply -n argocd -f install.yaml

kubectl -n argocd port-forward svc/argocd-server -n argocd 8080:443
```

The default login is admin and a random password will be generated. To get it, run the following command in another terminal:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

After logging into the Argo CD, change the password at the following address: https://localhost:8080/user-info?changePassword=true

After changing the password in the web interface, you can remove the secret ``argocd-initial-admin-secret``, which contains the initial password with the following command:

```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
```

The Argo CD can also be managed from the command line. To do this, run the following commands to install the binary:

```bash
ARGOCD_BINARY_VERSION=v2.3.3

wget https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_BINARY_VERSION}/argocd-linux-amd64 -O /tmp/argocd-linux-amd64

sudo mv /tmp/argocd-linux-amd64 /usr/bin/argocd

sudo chmod +x /usr/bin/argocd
```

Authenticate between the binary and the server with the following command:

```bash
argocd login localhost:8080
```

# Deploy of testapp with Argo CD

> ATTENTION!!! Tested with kind 0.12.0 and k8s 1.21.10

To deploy the application:

```bash
kubectl apply -f testapp/app-example.yaml
```

To remove the application:

```bash
kubectl delete -f testapp/app-example.yaml
```

# Uninstall Argo CD

To uninstall Argo CD:

```bash
kubectl delete -n argocd -f install.yaml
```
