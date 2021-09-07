FROM argoproj/argocd:v2.1.2

LABEL maintainer="Aecio Pires" \
      date_create="06/09/2021" \
      version="0.1.0" \
      description="My custom Docker image of Argo CD to add support other tools" \
      licensce="GPLv3"

# References:
#  https://argoproj.github.io/argo-cd/operator-manual/secret-management/
#  https://faun.pub/handling-kubernetes-secrets-with-argocd-and-sops-650df91de173
#  https://rtfm.co.ua/en/argocd-a-helm-chart-deployment-and-working-with-helm-secrets-via-aws-kms/
#  https://argoproj.github.io/argo-cd/user-guide/helm/#helm-plugins
#  https://hackernoon.com/how-to-handle-kubernetes-secrets-with-argocd-and-sops-r92d3wt1
#  https://github.com/argoproj/argo-cd/issues/1364
#  https://gitlab.com/ittennull/sopshelm
#  https://github.com/camptocamp/docker-argocd

ENV SOPS_VERSION="v3.7.1" \
    HELM_SECRETS_VERSION="v3.6.1" \
    SOPS_CREDENTIALS_FILE='/home/argocd/.sops.yaml' \
    AWS_KMS_ARN='arn:aws:kms:us-east-2:255686512659:key/d38c3af4-e577-4634-81b2-26a54a7ba9b6' \
    AWS_PROFILE='default'

USER root

COPY helm-wrapper.sh /usr/local/bin/

RUN apt-get update \
    && apt-get install -y curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && cd /usr/local/bin \
    && mv helm helm.bin \
    && mv helm2 helm2.bin \
    && mv helm-wrapper.sh helm \
    && ln helm helm2 \
    && chmod +x helm helm2 \
    && echo "creation_rules:" > ${SOPS_CREDENTIALS_FILE} \
    && echo "  - kms: '${AWS_KMS_ARN}'" >> ${SOPS_CREDENTIALS_FILE} \
    && echo "    aws_profile: ${AWS_PROFILE}" >> ${SOPS_CREDENTIALS_FILE} \
    && chown 999:999 ${SOPS_CREDENTIALS_FILE}

# Install sops
RUN curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux \
    && chown root:root /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops \
    && sops --version

# helm secrets plugin should be installed as user argocd (999) or it won't be found
# Reference: https://github.com/argoproj/argo-cd/blob/master/Dockerfile
USER 999

RUN /usr/local/bin/helm.bin plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION} \
    && /usr/local/bin/helm.bin plugin install https://github.com/databus23/helm-diff

ENV HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/"