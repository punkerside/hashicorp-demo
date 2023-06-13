ARG IMG
FROM ${IMG}

RUN apk add ansible

CMD [ "/usr/bin/ansible-galaxy", "install", "punkerside.ansible_ubuntu_common", "-p", "common/", "--force" ]