#!/bin/bash

tf_apply () {
  terraform init
  terraform apply -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve
}

tf_destroy () {
  terraform init
  terraform destroy -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve
}

"$@"