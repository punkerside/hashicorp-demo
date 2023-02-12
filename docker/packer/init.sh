#!/bin/bash

rm -rf ansible/roles/common/
ansible-galaxy install punkerside.ansible_ubuntu_common -p common/
mv common/punkerside.ansible_ubuntu_common/ ansible/roles/common/
rm -rf common/

VPC_ID=$(aws ec2 describe-vpcs --region ${AWS_DEFAULT_REGION} --filter Name=tag:Name,Values=${PROJECT}-${ENV}-${SERVICE} --query Vpcs[].VpcId --output text)
SUBNET_ID=$(aws ec2 describe-subnets --region ${AWS_DEFAULT_REGION} --filter Name=vpc-id,Values=${VPC_ID} --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' --output json | jq -r .[0])

packer init packer/config.pkr.hcl
packer build \
  -var 'project='${PROJECT}'' \
  -var 'env='${ENV}'' \
  -var 'service='${SERVICE}'' \
  -var 'subnet_id='${SUBNET_ID}'' \
 packer/config.pkr.hcl