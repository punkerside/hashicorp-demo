SHELL:=/bin/bash

PROJECT = falcon
ENV     = lab
SERVICE = multicloud

DOCKER_UID  = $(shell id -u)
DOCKER_GID  = $(shell id -g)
DOCKER_USER = $(shell whoami)

AWS_DEFAULT_REGION = us-east-1

passwd-file:
	@echo ''"${DOCKER_USER}"':x:'"${DOCKER_UID}"':'"${DOCKER_GID}"'::/app:/sbin/nologin' > passwd

build-docker:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:base -f docker/base/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:packer --build-arg IMG=${PROJECT}-${ENV}-${SERVICE}:base -f docker/packer/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:terraform --build-arg IMG=${PROJECT}-${ENV}-${SERVICE}:base -f docker/terraform/Dockerfile .

session-token:
	@rm -rf /tmp/session-token.txt
	@aws sts get-session-token --duration-seconds 3600 --output json --region "${AWS_DEFAULT_REGION}" > /tmp/session-token.txt

session-parse: session-token
	$(eval AWS_ACCESS_KEY_ID = $(shell cat /tmp/session-token.txt | jq -r .Credentials.AccessKeyId))
	$(eval AWS_SECRET_ACCESS_KEY = $(shell cat /tmp/session-token.txt | jq -r .Credentials.SecretAccessKey))
	$(eval AWS_SESSION_TOKEN = $(shell cat /tmp/session-token.txt | jq -r .Credentials.SessionToken))

install-vpc: session-parse
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/terraform/base:/app \
	  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	  -e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
	  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	  -e PROJECT=${PROJECT} \
	  -e ENV=${ENV} \
	  -e SERVICE=${SERVICE} \
	${PROJECT}-${ENV}-${SERVICE}:terraform tf_apply

build-ami: session-parse
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/packer:/app \
	  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	  -e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
	  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	  -e PROJECT=${PROJECT} \
	  -e ENV=${ENV} \
	  -e SERVICE=${SERVICE} \
	${PROJECT}-${ENV}-${SERVICE}:packer

destroy: session-parse
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/terraform/base:/app \
	  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	  -e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
	  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	  -e PROJECT=${PROJECT} \
	  -e ENV=${ENV} \
	  -e SERVICE=${SERVICE} \
	${PROJECT}-${ENV}-${SERVICE}:terraform tf_destroy