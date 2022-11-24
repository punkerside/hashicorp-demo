SHELL:=/bin/bash

PROJECT            = falcon
ENV                = lab
SERVICE            = multicloud
AWS_DEFAULT_REGION = us-east-1

base:
	export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} && \
	cd terraform/base/ && \
	terraform init && \
	terraform apply \
	  -var="name=${PROJECT}-${ENV}-${SERVICE}" \
	-auto-approve