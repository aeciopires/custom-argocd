#---------------------------
#---------------------------
# VARIABLES
#---------------------------
#---------------------------

PATH_DOCKERFILE="./Dockerfile"
SHELL=/bin/bash

# Change the value according to new releases
VERSION="v0.5.0"

# Change the value according to new releases
ARGOCD_VERSION="v2.11.2"

# Change the value as needed
APP_NAME="custom-argocd"

#----------------------------------------------------------------------------------------------------------





#---------------------------
#---------------------------
# MAIN
#---------------------------
#---------------------------

# References
# https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php
# https://stackoverflow.com/questions/3743793/makefile-why-is-the-read-command-not-reading-the-user-input
# https://stackoverflow.com/questions/60147129/interactive-input-of-a-makefile-variable
# https://makefiletutorial.com/
# https://stackoverflow.com/questions/589276/how-can-i-use-bash-syntax-in-makefile-targets
# https://til.hashrocket.com/posts/k3kjqxtppx-escape-dollar-sign-on-makefiles
# https://stackoverflow.com/questions/5618615/check-if-a-program-exists-from-a-makefile

requirements:
REQUIRED_PACKAGES := docker
$(foreach package,$(REQUIRED_PACKAGES),\
	$(if $(shell command -v $(package) 2> /dev/null),$(info Found `$(package)`),$(error Please install `$(package)`)))

image:
	make requirements
	if [ ! -f "${PATH_DOCKERFILE}" ]; then
		echo "[ERROR] File not found: ${PATH_DOCKERFILE}"
		exit 1
	fi
	docker build -t "${APP_NAME}:${VERSION}" .

container:
	make requirements
	docker run -it --rm --name "${APP_NAME}" "${APP_NAME}:${VERSION}" bash

.ONESHELL:
publish:
	make requirements
	read -rp 'Username of Docker Hub: ' DOCKER_HUB_ACCOUNT
	read -rsp 'Password of Docker Hub: ' DOCKER_HUB_PASSWORD
	docker login -u "$${DOCKER_HUB_ACCOUNT}" -p "$${DOCKER_HUB_PASSWORD}"
	docker tag "${APP_NAME}:${VERSION}" "$${DOCKER_HUB_ACCOUNT}/${APP_NAME}:${VERSION}"
	docker push "$${DOCKER_HUB_ACCOUNT}/${APP_NAME}:${VERSION}"
	wget https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml -O ./argocd/install_argocd.yaml
	sed -i "s~image: quay.io/argoproj/argocd:\(.*\)~image: $${DOCKER_HUB_ACCOUNT}/${APP_NAME}:${VERSION}~g" ./argocd/install_argocd.yaml
