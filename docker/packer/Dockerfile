ARG IMG
FROM ${IMG}

RUN apk add \
  curl \
  jq \
  aws-cli \
  ansible

RUN curl -s -o packer_1.9.1_linux_amd64.zip https://releases.hashicorp.com/packer/1.9.1/packer_1.9.1_linux_amd64.zip && \
  unzip packer_1.9.1_linux_amd64.zip && \
  mv packer /usr/bin/packer && \
  chmod +x /usr/bin/packer

ENTRYPOINT [ "/usr/bin/packer" ]