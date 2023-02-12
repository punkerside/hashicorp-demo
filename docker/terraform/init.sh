#!/bin/bash

tf_apply () {
  export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
  echo ${AWS_ACCESS_KEY_ID}
  echo ${AWS_SECRET_ACCESS_KEY}
  echo ${AWS_SESSION_TOKEN}
  aws sts get-caller-identity
  aws iam list-roles
  aws s3api list-buckets --query "Buckets[].Name"
  # terraform init
  # terraform apply -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve
}

tf_destroy () {
  terraform init
  terraform destroy -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve
}

"$@"