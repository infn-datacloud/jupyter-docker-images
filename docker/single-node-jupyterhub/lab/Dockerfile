# Image name: snj-base-lab -> based on ubuntu:20.04
ARG BASE_IMAGE="ubuntu:20.04"

FROM ${BASE_IMAGE}

ARG BASE_IMAGE
WORKDIR /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN if [ "$BASE_IMAGE" = "tensorflow/tensorflow:2.7.0rc1-gpu" ] ;  then \
    rm /etc/apt/sources.list.d/cuda.list \
    && rm /etc/apt/sources.list.d/nvidia-ml.list \
    && apt-key del 7fa2af80 \
    && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub \
    && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub; else echo 'Ubuntu'; fi && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git=1:2.25.1-1ubuntu3 software-properties-common=0.99.9.12 wget fuse=2.9.9-3 curl \
    build-essential=12.8ubuntu1.1 python3-dev=3.8.2-0ubuntu2 python3-pip libargon2-dev=0~20171227-0.2 \
    libffi-dev=3.3-4 libpixman-1-dev=0.38.4-0ubuntu2.1 libcairo2-dev=1.16.0-4ubuntu1 libpangox-1.0-dev=0.0.2-5ubuntu1 \
    libjpeg-dev=8c-2ubuntu8 libczmq-dev=4.2.0-2 libcurl4-openssl-dev \
    libssl-dev dirmngr=2.2.19-3ubuntu2.2 gpg-agent=2.2.19-3ubuntu2.2 gnupg=2.2.19-3ubuntu2.2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    # Make dodasts, script and bin folders
    mkdir -p /usr/local/share/dodasts /usr/local/share/dodasts/script /usr/local/share/dodasts/bin && \
    python3 -m pip install -U --no-cache-dir pip==23.0.1 setuptools==67.6.0 wheel==0.40.0 && \
    # Install sts-wire
    curl -L https://repo.cloud.cnaf.infn.it/repository/sts-wire/sts-wire-linux/2.1.5/sts-wire-linux-2.1.5 -o /usr/local/share/dodasts/bin/sts-wire && \
    chmod +x /usr/local/share/dodasts/bin/sts-wire && \
    ln -s /usr/local/share/dodasts/bin/sts-wire /usr/local/bin/sts-wire && \
    # Install oidc-agent
    apt-key adv --keyserver hkp://pgp.surfnet.nl --recv-keys ACDFB08FDC962044D87FF00B512839863D487A87 && \
    add-apt-repository "deb https://repo.data.kit.edu/ubuntu/20.04 ./" && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    liboidc-agent4=4.5.1-1 oidc-agent-cli=4.5.1-1 oidc-agent-desktop=4.5.1-1 oidc-agent=4.5.1-1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    # Install jupyterlab
    python3 -m pip install --no-cache-dir \
    idna==3.3 \
    importlib-metadata==6.6.0 \
    ipympl==0.8.2 \
    ipywidgets==7.6.5 \
    jedi-language-server==0.34.8 \
    pycurl==7.44.1 \
    tornado==6.2 \
    traitlets==5.9.0 \
    nbclassic==0.5.3 \
    nbclient==0.7.2 \
    nbconvert==7.2.10 \
    nbdime==3.1.1 \
    nbformat==5.7.3 \
    nest-asyncio==1.5.6 \
    notebook==6.4.5 \
    notebook_shim==0.2.2 \
    jupyter_client==7.4.9 \
    jupyter-contrib-core==0.4.2 \
    jupyter-contrib-nbextensions==0.7.0 \
    jupyter_core==5.3.0 \
    jupyter-highlight-selected-word==0.2.0 \
    jupyter-matlab-proxy==0.5.3 \
    jupyter-nbextensions-configurator==0.6.3 \
    jupyter-resource-usage==0.7.2 \
    jupyter-server==1.23.6 \
    jupyter-server-mathjax==0.2.6 \
    jupyter_server_proxy==4.0.0 \
    jupyter-telemetry==0.1.0 \
    jupyterhub==1.5.0 \
    jupyterlab==3.2.3 \
    jupyterlab-git==0.33.0 \
    jupyterlab-pygments==0.2.2 \
    jupyterlab_server==2.15.2 \
    jupyterlab-system-monitor==0.8.0 \
    jupyterlab-topbar==0.6.1 \
    jupyterlab-widgets==3.0.5
    # jupyter_http_over_ws==0.0.8 \ # Temporarly removed. Needs further config: https://github.com/googlecolab/jupyter_http_over_ws#usage
    # RUN jupyter serverextension enable --py jupyter_http_over_ws
    #curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=16 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs=16.19.1-1nodesource1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install --no-cache-dir jupyterhub==1.5.0 && \
    npm install -g configurable-http-proxy@4.5.4 && \
    jupyter serverextension enable --py jupyterlab --sys-prefix

WORKDIR /usr/local/share/dodasts
RUN git clone https://github.com/DODAS-TS/jupyterlab-collaborative-util-extension.git
WORKDIR /usr/local/share/dodasts/jupyterlab-collaborative-util-extension
RUN sed -i 's/\(    "target":\)\(.*\)/\1 "'"es2018"'",/g' tsconfig.json && \
    sed -i '/"compilerOptions": {/a \    "lib": ["es2018", "dom"],\n    "skipLibCheck": true,' tsconfig.json && \
    jupyter labextension install
WORKDIR /usr/local/share/dodasts

COPY jupyter_lab_config.py /usr/etc/jupyter/

# Build jupyter lab stuff
RUN /bin/bash -c "jupyter lab build --dev-build=False --minimize=True"

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

WORKDIR /jupyter-workspace
