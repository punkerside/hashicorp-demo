ARG IMG
FROM ${IMG}

RUN apk add --no-cache \
  curl \
  unzip \
  aws-cli \
  git

RUN curl -s https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip -o /tmp/terraform_1.4.6_linux_amd64.zip && \
  unzip /tmp/terraform_1.4.6_linux_amd64.zip -d /tmp/ && \
  chmod +x /tmp/terraform && mv /tmp/terraform /usr/bin/ && \
  rm -rf /tmp/terraform_1.4.6_linux_amd64.zip

ENTRYPOINT [ "/usr/bin/terraform" ]