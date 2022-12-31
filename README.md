# Custom Argo CD

<!-- TOC -->

- [Custom Argo CD](#custom-argo-cd)
- [About](#about)
- [Contributing](#contributing)
  - [Updating the custom Argo CD image](#updating-the-custom-argo-cd-image)
    - [Publishing the image](#publishing-the-image)
- [Use the custom Argo CD](#use-the-custom-argo-cd)
- [Deploy of testapp with Argo CD](#deploy-of-testapp-with-argo-cd)
- [Uninstall Argo CD](#uninstall-argo-cd)
- [Developers](#developers)
- [License](#license)

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

* https://blog.argoproj.io/draft-argo-cd-v2-6-release-candidate-ced1853bbfdb
* https://faun.pub/handling-kubernetes-secrets-with-argocd-and-sops-650df91de173
* https://rtfm.co.ua/en/argocd-a-helm-chart-deployment-and-working-with-helm-secrets-via-aws-kms/
* https://argoproj.github.io/argo-cd/user-guide/helm/#helm-plugins
* https://hackernoon.com/how-to-handle-kubernetes-secrets-with-argocd-and-sops-r92d3wt1
* https://github.com/argoproj/argo-cd/issues/1364
* https://gitlab.com/ittennull/sopshelm
* https://github.com/camptocamp/docker-argocd

# Contributing

* See the [REQUIREMENTS.md](REQUIREMENTS.md) file.
* See the [CONTRIBUTING.md](CONTRIBUTING.md) file.
* See the section [Use the custom Argo CD](#use-the-custom-argo-cd).

## Updating the custom Argo CD image

> In this image, the ``sops`` command will be configured to encrypt and decrypt secrets using [AWS KMS](https://aws.amazon.com/kms).
>
> More informations in https://github.com/mozilla/sops#kms-aws-profiles.

* Change the image version of Argo CD in ``custom-argocd/Dockerfile`` file, in ``from`` line.

* Change value of the ``AWS_KMS_ARN`` variable in ``custom-argocd/Makefile`` file.

* Change the value of the ``AWS_PROFILE`` variable in ``custom-argocd/Makefile`` file.

* Change the value of the ``VERSION`` variable in ``custom-argocd/Makefile`` file.

* Commands to build the image:

```bash
cd custom-argocd

make image
```

Commands to run a container:

```bash
cd custom-argocd

make container
```

More information about docker run command: https://docs.docker.com/engine/reference/run/

### Publishing the image

* Create or access your account in Docker Hub and create the repository for custom image. Example: https://hub.docker.com/r/DOCKER_HUB_ACCOUNT/custom-argocd

* Commands to publish the image:

```bash
cd custom-argocd

make publish
```

# Use the custom Argo CD

* Clone this repo. See the [CONTRIBUTING.md](CONTRIBUTING.md) file.

* Search by **argocd-repo-server** *deployment* and add follow content in ``spec.template.spec.containers.volumeMounts`` section of file ``custom-argocd/install.yaml``, if it doesn't exist:

```yaml
        - mountPath: /home/argocd/.aws
          name: argocd-aws-credentials
```

* Search by **argocd-repo-server** *deployment* and add follow content in ``spec.template.spec.containers.volumes`` section of file ``custom-argocd/install.yaml``, if it doesn't exist:

```yaml
      - name: argocd-aws-credentials
        secret:
          secretName: argocd-aws-credentials
```

* Access Kubernetes cluster.

* Change content of the AWS credentials in file ``custom-argocd/credentials``

* Run the command:

```bash
cd custom-argocd

# If it doesn't exist
kubectl create namespace argocd

# If it exist
kubectl delete secret argocd-aws-credentials -n argocd

kubectl create -n argocd secret generic argocd-aws-credentials --from-file=credentials=./credentials

kubectl apply -n argocd -f install.yaml

kubectl -n argocd port-forward svc/argocd-server -n argocd 8080:443
```

* The default login is admin and a random password will be generated. To get it, run the following command in another terminal:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

* After logging into the Argo CD, change the password at the following address: https://localhost:8080/user-info?changePassword=true

* After changing the password in the web interface, you can remove the secret ``argocd-initial-admin-secret``, which contains the initial password with the following command:

```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
```

* The Argo CD can also be managed from the command line. To do this, run the following commands to install the binary:

```bash
ARGOCD_BINARY_VERSION=v2.6.0-rc1

wget https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_BINARY_VERSION}/argocd-linux-amd64 -O /tmp/argocd-linux-amd64

sudo mv /tmp/argocd-linux-amd64 /usr/bin/argocd

sudo chmod +x /usr/bin/argocd
```

* Authenticate between the binary and the server with the following command:

```bash
argocd login localhost:8080
```

# Deploy of testapp with Argo CD

> ATTENTION!!! Tested with kind 0.13.0 and k8s 1.23.13

* Deploy the application:

```bash
kubectl apply -f testapp/app-example.yaml
```

* Remove the application:

```bash
kubectl delete -f testapp/app-example.yaml
```

# Uninstall Argo CD

* Uninstall Argo CD:

```bash
kubectl delete -n argocd -f install.yaml
```

# Developers

* Aécio Pires --> [Linkedin](https://www.linkedin.com/in/aeciopires/) | [Github](https://github.com/aeciopires)

* Isaac Mecchi --> [Linkedin](https://www.linkedin.com/in/isaacmecchi/) | [Github](https://github.com/mecsys)

# License

* See the [LICENSE](LICENSE) file.
