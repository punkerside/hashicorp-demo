ARG IMG
FROM ${IMG}

RUN apk add curl

RUN curl -s https://releases.hashicorp.com/terraform/1.3.5/terraform_1.3.5_linux_amd64.zip -o /tmp/terraform_1.3.5_linux_amd64.zip && \
  unzip /tmp/terraform_1.3.5_linux_amd64.zip -d /tmp/ && \
  chmod +x /tmp/terraform && mv /tmp/terraform /usr/bin/ && \
  rm -rf /tmp/terraform_1.3.5_linux_amd64.zip

COPY docker/terraform/init.sh /usr/bin/init.sh
ENTRYPOINT [ "/usr/bin/init.sh" ]