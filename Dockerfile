FROM argoproj/argocd:v2.6.7

LABEL maintainer="Aecio Pires, Isaac Mecchi" \
      date_create="10/04/2023" \
      version="0.4.0" \
      description="My custom ArgoCD image to add support other tools" \
      licensce="GPLv3"

# References:
# See the README.md file in the About section

#---------------------------------#
# Variables
#---------------------------------#

ENV SOPS_VERSION="v3.7.3" \
    HELM_SECRETS_VERSION="v3.13.0" \
    HELM_DIFF_VERSION="v3.4.1"
#-------- End - Variables --------#

USER root

COPY argocd/helm-wrapper.sh /usr/local/bin/helm-wrapper.sh

RUN apt-get update \
    # Install packages
    && apt-get install -y curl \
    # Clean packages
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # Configure helm wrapper
    && cd /usr/local/bin \
    && mv helm helm.bin \
    && mv helm-wrapper.sh helm \
    && chmod +x helm \
    # Install sops
    && touch /home/argocd/.sops.yaml \
    && chown 999:999 /home/argocd/.sops.yaml \
    && curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux \
    && chown root:root /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops \
    && sops --version

# helm secrets plugin should be installed as user argocd (999) or it won't be found
# Reference: https://github.com/argoproj/argo-cd/blob/master/Dockerfile
USER 999

RUN /usr/local/bin/helm.bin plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION} \
    && /usr/local/bin/helm.bin plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION}

ENV HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/"
