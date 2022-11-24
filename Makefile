SHELL:=/bin/bash

PROJECT            = falcon
ENV                = lab
SERVICE            = multicloud
AWS_DEFAULT_REGION = us-east-1

base:
	@export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} && \
	cd terraform/base/ && \
	terraform init && \
	terraform apply \
	  -var="name=${PROJECT}-${ENV}-${SERVICE}" \
	-auto-approve

envs:
	$(eval VPC_ID = $(shell aws ec2 describe-vpcs --region ${AWS_DEFAULT_REGION} --filter Name=tag:Name,Values=${PROJECT}-${ENV}-${SERVICE} --query Vpcs[].VpcId --output text))

ami: envs
	$(eval SUBNET_ID = $(shell aws ec2 describe-subnets --region ${AWS_DEFAULT_REGION} --filter Name=vpc-id,Values=${VPC_ID} --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' --output json | jq -r .[0]))
	cd packer/ && packer init config.pkr.hcl
	export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} && \
	cd packer/ && packer build \
	  -var 'project=$(PROJECT)' \
	  -var 'env=$(ENV)' \
	  -var 'service=$(SERVICE)' \
	  -var 'subnet_id=$(SUBNET_ID)' \
	config.pkr.hcl