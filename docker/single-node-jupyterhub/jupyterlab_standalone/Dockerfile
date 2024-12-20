# Image name: harbor.cloud.infn.it/datacloud-templates/jlab-standalone:1.3.0-1
ARG BASE_IMAGE="harbor.cloud.infn.it/datacloud-templates/snj-base-lab:1.3.0-1" 
FROM ${BASE_IMAGE}

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install oidc-agent
RUN apt update && \
    apt install -y oidc-agent && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

# Install sts-wire
ADD https://repo.cloud.cnaf.infn.it/repository/sts-wire/sts-wire-linux/2.1.5/sts-wire-linux-2.1.5 /usr/local/bin/sts-wire
RUN chmod +x /usr/local/bin/sts-wire

WORKDIR /jupyter-workspace
