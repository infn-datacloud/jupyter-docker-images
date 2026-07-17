# Image name: harbor.cloud.infn.it/datacloud-jupyter/jhub-naas:2.3.0

FROM jupyterhub/k8s-hub:4.3.0

USER root

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        vim \
        sudo \
        git \
        curl \
        ca-certificates \
        wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# GEANT OV RSA CA 4 (expires 2033-05-01), same content served by
# https://crt.sh/?d=2475254782 (sha256 fingerprint
# 37:83:4F:A5:EA:40:FB:F7:B6:11:96:95:59:62:E1:CA:05:58:87:24:35:E4:20:66:53:D3:F6:20:DD:8E:98:8E).
# Shipped from the repo instead of downloading at build time: crt.sh often
# times out, and fetching a trust anchor with --insecure allows MITM injection.
COPY ca.crt /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates
COPY INFN_Cloud_logo_home.png /etc/logo.png
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Use bash instead of dash
RUN rm /bin/sh && \
    ln -s /bin/bash /bin/sh

RUN pip install --upgrade pip && \
    pip install --upgrade urllib3 && \
    pip install kubernetes

CMD ["/usr/bin/start.sh", "jupyterhub"]
