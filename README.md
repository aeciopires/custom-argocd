# Custom Argo CD

<!-- TOC -->

- [Custom Argo CD](#custom-argo-cd)
- [About](#about)
- [Build and send image to Docker Hub](#build-and-send-image-to-docker-hub)
- [Use Argo CD Custom](#use-argo-cd-custom)

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

Change the ARN of KMS key in ``AWS_KMS_ARN`` variable in ``custom-argocd/Dockerfile``.

Change the image version of Argo CD in ``custom-argocd/Dockerfile`` in ``from`` line.

Change the custom image version of Argo CD in ``custom-argocd/Makefile``.

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

Change the AWS credentials in file ``custom-argocd/credentials``

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
```