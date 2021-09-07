# Use Argo CD Custom

Access Kubernetes cluster.

Change the base64 of AWS credentials in file ``custom-argocd/secret-aws-variable.yaml``

Run the commands:

```bash
DOCKER_HUB_ACCOUNT="CHANGE_HERE"
VERSION="v0.1.0"
ARGOCD_CUSTOM_IMAGE="${DOCKER_HUB_ACCOUNT}/custom-argocd:${VERSION}"

cd custom-argocd

wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -O ./install.yaml

sed -i "s~image: quay.io/argoproj/argocd\(.*\)~image: $ARGOCD_CUSTOM_IMAGE~g" ./install.yaml
```

Search by **argocd-repo-server** *deployment* and add follow content in ``env`` section of file ``custom-argocd/install.yaml``:

```yaml
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: argocd-aws-credentials
              key: accesskey
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: argocd-aws-credentials
              key: secretkey
```

Run the command:

```bash
cd custom-argocd

kubectl create namespace argocd

kubectl apply -f secret-aws-example.yaml -n argocd

kubectl apply -n argocd -f install.yaml
```