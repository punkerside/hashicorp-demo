ARG IMG
FROM ${IMG}

RUN apk add \
  curl \
  jq \
  aws-cli

RUN curl -o packer_1.8.4_linux_amd64.zip https://releases.hashicorp.com/packer/1.8.4/packer_1.8.4_linux_amd64.zip && \
  unzip packer_1.8.4_linux_amd64.zip && \
  mv packer /usr/bin/packer && \
  chmod +x /usr/bin/packer

RUN apk add ansible

COPY docker/packer/init.sh /usr/bin/init.sh
CMD [ "/usr/bin/init.sh" ]