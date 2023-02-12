ARG IMG
FROM ${IMG}

RUN apk update && apk add --no-cache \
  curl \
  unzip \
  bash \
  jq \
  gettext \
  python3 \
  py3-pip \
  git

RUN pip install --no-cache-dir awscli==1.27.20

RUN curl -s https://releases.hashicorp.com/terraform/1.3.5/terraform_1.3.5_linux_amd64.zip -o /tmp/terraform_1.3.5_linux_amd64.zip && \
  unzip /tmp/terraform_1.3.5_linux_amd64.zip -d /tmp/ && \
  chmod +x /tmp/terraform && mv /tmp/terraform /usr/bin/ && \
  rm -rf /tmp/terraform_1.3.5_linux_amd64.zip

COPY docker/terraform/init.sh /usr/bin/init.sh
ENTRYPOINT [ "/usr/bin/init.sh" ]