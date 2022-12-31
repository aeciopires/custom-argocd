FROM argoproj/argocd:v2.6.0-rc1

LABEL maintainer="Aecio Pires, Isaac Mecchi" \
      date_create="30/12/2022" \
      version="0.3.0" \
      description="My custom ArgoCD image to add support other tools" \
      licensce="GPLv3"

# References:
# See the README.md file in the About section

#---------------------------------#
# Variables
#---------------------------------#
# Environment variables (the value is changed at container startup or build image, if empty, it will be given a default value)

ARG AWS_KMS_ARN
ENV AWS_KMS_ARN ${AWS_KMS_ARN:-'arn:aws:kms:us-east-2:255686512659:key/d38c3af4-e577-4634-81b2-26a54a7ba9b6'}

ARG AWS_PROFILE
ENV AWS_PROFILE ${AWS_PROFILE:-'default'}

ENV SOPS_VERSION="v3.7.3" \
    HELM_SECRETS_VERSION="v3.13.0" \
    HELM_DIFF_VERSION="v3.4.1" \
    SOPS_CONFIG_FILE='/home/argocd/.sops.yaml'
#-------- End - Variables --------#

USER root

COPY helm-wrapper.sh /usr/local/bin/

RUN apt-get update \
    && apt-get install -y curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && cd /usr/local/bin \
    && mv helm helm.bin \
    && mv helm-wrapper.sh helm \
    && chmod +x helm \
    && echo "creation_rules:" > ${SOPS_CONFIG_FILE} \
    && echo "  - kms: '${AWS_KMS_ARN}'" >> ${SOPS_CONFIG_FILE} \
    && echo "    aws_profile: ${AWS_PROFILE}" >> ${SOPS_CONFIG_FILE} \
    && chown 999:999 ${SOPS_CONFIG_FILE}

# Install sops
RUN curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux \
    && chown root:root /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops \
    && sops --version

# helm secrets plugin should be installed as user argocd (999) or it won't be found
# Reference: https://github.com/argoproj/argo-cd/blob/master/Dockerfile
USER 999

RUN /usr/local/bin/helm.bin plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION} \
    && /usr/local/bin/helm.bin plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION}

ENV HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/"
