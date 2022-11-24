#!/bin/bash

terraform init
terraform apply -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve