# =============================================================================
# snj-jlab-base  —  immagine single-user JupyterLab su base Debian 13 (Trixie)
#
# Sostituisce quay.io/jupyter/minimal-notebook:ubuntu-22.04 (basata su Ubuntu),
# per cui NON esiste un tag Debian 13. Strategia: debian:trixie-slim + micromamba
# per ricreare l'ambiente conda (jupyterlab, ipykernel, estensioni).
#
# Include:
#   - jupyter-server-proxy (+ estensione JupyterLab) → tile nel launcher
#   - config /etc/jupyter/jupyter_server_config.py con il tile "Grafana"
#     (Opzione B: link esterno a https://<DNS>:3000 — robusto per servizio condiviso)
# =============================================================================
ARG BASE_IMAGE="debian:trixie-slim"
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="jlab-base" \
      org.opencontainers.image.description="Single-user JupyterLab base (Debian 13, micromamba)" \
      org.opencontainers.image.vendor="INFN-DataCloud"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash \
    MAMBA_ROOT_PREFIX=/opt/conda \
    CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:$PATH \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=1000 \
    HOME=/home/jovyan \ 
    JUPYTERLAB_WORKSPACE=/jupyterlab-workspace

# --- Pacchetti di sistema -----------------------------------------------------
# fuse3  : su Debian 13 il pacchetto reale è fuse3 (fuse è transizionale)
# i -dev : necessari per build di alcune estensioni Python
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      bzip2 \
      ca-certificates \
      curl \
      fuse3 \
      git \
      graphviz \
      jq \
      less \
      libcairo2-dev \
      libczmq-dev \
      libffi-dev \
      libjpeg-dev \
      libpixman-1-dev \
      nano \
      oidc-agent \
      openssh-client \
      pandoc \
      rclone \
      rsync \
      screen \
      snakemake \
      texlive-base \
      texlive-fonts-recommended \
      texlive-xetex \
      tini \
      vim \
      wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Utente non-root jovyan (convenzione docker-stacks) ----------------------
RUN groupadd -g ${NB_GID} ${NB_USER} \
    && useradd -m -s /bin/bash -N -u ${NB_UID} -g ${NB_GID} ${NB_USER} \
    && mkdir -p /opt/conda /jupyterlab-workspace \
    && chown -R ${NB_UID}:${NB_GID} /opt/conda /home/jovyan /jupyterlab-workspace

# --- micromamba ---------------------------------------------------------------
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest \
      | tar -xvj -C /usr/local/bin --strip-components=1 bin/micromamba \
    && chmod +x /usr/local/bin/micromamba

RUN micromamba install -y -p /opt/conda -c conda-forge \
      boto3=1.35.99 \
      python=3.14 \
      jupyterlab=4.6.0 \
      jupyterhub-singleuser=5.5.0 \
      ipykernel=7.3.0 \
      ipywidgets=8.1.8 \
      nbconvert=7.17.1 \
      nbformat=5.10.4 \
      nbclient=0.11.0 \
      notebook=7.6.0 \
    && micromamba clean -a -y    

# --- Estensioni JupyterLab / server-proxy -------------------------------------
RUN python3 -m pip install --no-cache-dir \
      boto3==1.35.99 \
      numpy \ 
      pandas \
      matplotlib \
      h5py \
      nbdime==4.0.4 \
      dask-labextension \
      jupyterlab-git  \
      jupyterlab-nvdashboard \
      jupyterlab-theme-toggler \
      jupyterlab-widgets \
      jupyter-resource-usage \
      jupyter-server-proxy==4.5.0 \
      jupyter-app-launcher==0.3.2


# --- VS Code ------------------------------------
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN python3 -m pip install --no-cache-dir \
      "git+https://github.com/infn-datacloud/jupyter_codeserver_proxy.git@c6b2d6f16774bbde18a52160cee11ec569436e64"

COPY jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser
COPY spawn.sh ${JUPYTERLAB_WORKSPACE}/.init/spawn.sh

# Copy Rclone files
COPY rclone-aws.config ${JUPYTERLAB_WORKSPACE}/.init/rclone-aws.config
COPY rclone-cmd.sh ${JUPYTERLAB_WORKSPACE}/.init/rclone-cmd.sh
COPY rclone-sts.py ${JUPYTERLAB_WORKSPACE}/.init/rclone-sts.py
COPY rclone-sts.sh ${JUPYTERLAB_WORKSPACE}/.init/rclone-sts.sh
COPY rclone-token.sh ${JUPYTERLAB_WORKSPACE}/.init/rclone-token.sh
COPY rclone.config ${JUPYTERLAB_WORKSPACE}/.init/rclone.config

RUN chmod +x /usr/local/bin/jupyterhub-singleuser && \
    chmod +x /jupyterlab-workspace/.init/*.sh && \
    chmod +x /jupyterlab-workspace/.init/*.py 

# --- Config Launcher ----------------------------------------------------------
COPY grafana.svg /opt/conda/share/grafana.svg
COPY infn.svg /opt/conda/share/infn.svg
COPY jp_app_launcher.yaml /opt/conda/share/jupyter/jupyter_app_launcher/jp_app_launcher.yaml

# --- Workspace and permissions -----------------------------------------------------
WORKDIR ${JUPYTERLAB_WORKSPACE}
# RUN chown -R ${NB_UID}:${NB_GID} /jupyterlab-workspace 
# RUN chown -R ${NB_UID}:${NB_GID} /jupyterlab-workspace /etc/jupyter

# USER ${NB_UID}
USER root

EXPOSE 8888
ENTRYPOINT ["tini", "-g", "--"]
CMD ["jupyterhub-singleuser", "--ip=0.0.0.0", "--port=8888", "--allow-root"]
