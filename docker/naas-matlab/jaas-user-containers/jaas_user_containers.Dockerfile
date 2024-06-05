# Image name: jaas_user_containers -> based on ubuntu:20.04
FROM ubuntu:20.04

ARG JUPYTER_ROOT=/workarea

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y software-properties-common wget python3-pip git fuse 

RUN apt-key adv --keyserver hkp://pgp.surfnet.nl --recv-keys ACDFB08FDC962044D87FF00B512839863D487A87 && \
    add-apt-repository "deb https://repo.data.kit.edu/ubuntu/20.04 ./" && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    liboidc-agent4=4.5.1-1 oidc-agent-cli=4.5.1-1 oidc-agent-desktop=4.5.1-1 oidc-agent=4.5.1-1

COPY ./certs/geant-ov-rsa-ca.crt /usr/local/share/ca-certificates/ca.crt

RUN update-ca-certificates 

RUN python3 -m pip --no-cache-dir install --upgrade pip

RUN pip install --no-cache-dir jupyter_client==8.2.0 \
    jupyter-contrib-core==0.4.2 \
    jupyter-contrib-nbextensions==0.7.0 \
    jupyter_core==5.3.0 \
    jupyter-events==0.6.3 \
    jupyter-highlight-selected-word==0.2.0 \
    matlab-proxy==0.5.11 \
    jupyter-matlab-proxy==0.5.4 \
    jupyter-nbextensions-configurator==0.6.3 \
    jupyter_server==2.6.0 \
    jupyter_server_proxy==4.0.0 \
    jupyter_server_terminals==0.4.4 \
    jupyter-telemetry==0.1.0 \
    jupyterlab-pygments==0.2.2 \
    jupyterhub==1.5.0 \
    traitlets==5.9.0 \
    tornado==6.3.2 \
    nbclassic==1.0.0 \
    nbclient==0.8.0 \
    nbconvert==7.4.0 \
    nbformat==5.9.0 \
    notebook_shim==0.2.3 \
    notebook==6.5.4 \
    && pip3 install -U git+https://github.com/infn-datacloud/boto3sts

ARG JUPYTER_ROOT=/workarea

# Automount S3 with sts-wire
COPY custom-spawner/jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser
COPY custom-spawner/spawn.sh ./.init/spawn.sh
COPY examples ${JUPYTER_ROOT}/examples

RUN chmod +x /usr/local/bin/jupyterhub-singleuser \
    && chmod +x ./.init/spawn.sh

RUN mkdir -p .init \
    && wget https://repo.cloud.cnaf.infn.it/repository/sts-wire/sts-wire-linux/2.1.5/sts-wire-linux-2.1.5 -O ./.init/sts-wire \
    && chmod +x ./.init/sts-wire

#RUN mkdir ${JUPYTER_ROOT}
RUN ln -s /s3 ${JUPYTER_ROOT}/cloud-storage \
    && ln -s /opt/user_data ${JUPYTER_ROOT}/local

WORKDIR ${JUPYTER_ROOT}
