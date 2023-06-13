PROJECT            = titan
ENV                = lab
SERVICE            = multicloud

DOCKER_UID         = $(shell id -u)
DOCKER_GID         = $(shell id -g)
DOCKER_USER        = $(shell whoami)
AWS_DEFAULT_REGION = us-east-1

base:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:base -f docker/base/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:terraform --build-arg IMG=${PROJECT}-${ENV}-${SERVICE}:base -f docker/terraform/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:packer --build-arg IMG=${PROJECT}-${ENV}-${SERVICE}:base -f docker/packer/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:ansible --build-arg IMG=${PROJECT}-${ENV}-${SERVICE}:base -f docker/ansible/Dockerfile .

filepasswd:
	@echo '${DOCKER_USER}:x:${DOCKER_UID}:${DOCKER_GID}::/app:/sbin/nologin' > passwd

vpc: filepasswd
# iniciando terraform
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/terraform/base:/app ${PROJECT}-${ENV}-${SERVICE}:terraform init
# creando vpc
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/terraform/base:/app \
	  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	${PROJECT}-${ENV}-${SERVICE}:terraform apply -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve

build: filepasswd
# descargando role
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/ansible:/app ${PROJECT}-${ENV}-${SERVICE}:ansible
# configurando role
	@rm -rf ansible/roles/common/ && mv ansible/common/punkerside.ansible_ubuntu_common/ ansible/roles/common/ && rm -rf ansible/common/
# iniciando packer 
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}":/app ${PROJECT}-${ENV}-${SERVICE}:packer init packer/config.pkr.hcl
# creando imagen dorada
	docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}:/app \
	  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	${PROJECT}-${ENV}-${SERVICE}:packer build -var 'name=${PROJECT}-${ENV}-${SERVICE}' packer/config.pkr.hcl

deploy: filepasswd
# iniciando terraform
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/terraform/app:/app ${PROJECT}-${ENV}-${SERVICE}:terraform init
# creando servidores
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/terraform/app:/app \
	  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	${PROJECT}-${ENV}-${SERVICE}:terraform apply -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve

destroy: filepasswd
# eliminando servidores
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/terraform/app:/app \
	  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	${PROJECT}-${ENV}-${SERVICE}:terraform destroy -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve
# eliminando vpc
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/terraform/base:/app \
	  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	${PROJECT}-${ENV}-${SERVICE}:terraform destroy -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve