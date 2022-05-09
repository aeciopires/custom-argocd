VERSION="v0.2.0"
APP_NAME="custom-argocd"
PATH_DOCKERFILE="./Dockerfile"
SHELL=/bin/bash
AWS_PROFILE='default'
AWS_KMS_ARN='arn:aws:kms:us-east-2:255686512659:key/d38c3af4-e577-4634-81b2-26a54a7ba9b6'

# References
# https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php
# https://stackoverflow.com/questions/3743793/makefile-why-is-the-read-command-not-reading-the-user-input
# https://stackoverflow.com/questions/60147129/interactive-input-of-a-makefile-variable
# https://makefiletutorial.com/
# https://stackoverflow.com/questions/589276/how-can-i-use-bash-syntax-in-makefile-targets
# https://til.hashrocket.com/posts/k3kjqxtppx-escape-dollar-sign-on-makefiles
# https://stackoverflow.com/questions/5618615/check-if-a-program-exists-from-a-makefile

requirements:
REQUIRED_BINS := docker
$(foreach bin,$(REQUIRED_BINS),\
	$(if $(shell command -v $(bin) 2> /dev/null),$(info Found `$(bin)`),$(error Please install `$(bin)`)))

image:
	make requirements
	if [ ! -f "${PATH_DOCKERFILE}" ]; then     
		echo "[ERROR] File not found: ${PATH_DOCKERFILE}"
		exit 1
	fi
	docker build \
	  --build-arg AWS_PROFILE=${AWS_PROFILE} \
	  --build-arg AWS_KMS_ARN=${AWS_KMS_ARN} \
	  -t "${APP_NAME}:${VERSION}" .

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
	wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -O ./install.yaml
	sed -i "s~image: quay.io/argoproj/argocd:\(.*\)~image: $${DOCKER_HUB_ACCOUNT}/${APP_NAME}:${VERSION}~g" ./install.yaml
