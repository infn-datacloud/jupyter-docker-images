# Image name: harbor.cloud.infn.it/datacloud-jupyter/jhub-singlenode:2.3.0

# =============================================================================
# snj-jhub  —  JupyterHub image (Debian 13 base)
#
# jupyterhub/jupyterhub:5.x è già basata su Debian. La teniamo come base:
# è il punto in cui vive l'Hub (orchestrazione, DockerSpawner, OAuth IAM).
# Le immagini single-user (jlab-base / jlab-standalone) sono separate.
#
# Modifiche rispetto all'originale:
#   - niente blocchi "collaborative" e niente ramo NOTEBOOK (solo /lab)
#   - jupyterhub_config.py con helper *_FILE per i Docker secrets
# =============================================================================
ARG BASE_IMAGE="jupyterhub/jupyterhub:5.4.5"
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="jhub-singlenode" \
      org.opencontainers.image.description="JupyterHub single-node" \
      org.opencontainers.image.vendor="INFN-DataCloud"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash 

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \ 
    DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# --- Python packages -----------------------------------------------
RUN python3 -m pip install --no-cache-dir \
        "dockerspawner==13.*" \
        "oauthenticator>=17.1.0,<18" \
        "jupyterhub-idle-culler==1.*" \
        "pyjwt>=2.8"

# --- Hub Config ----------------------------------------------------------
COPY jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py

# State Directories 
RUN mkdir -p /srv/jupyterhub/cookies /srv/jupyterhub/db

WORKDIR /srv/jupyterhub

EXPOSE 8088 8081

CMD ["jupyterhub", "--config=/srv/jupyterhub/jupyterhub_config.py"]
