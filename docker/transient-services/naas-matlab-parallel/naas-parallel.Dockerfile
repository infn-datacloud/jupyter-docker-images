# Image name: naas_matlab_parallel -> based on jaas_user_containers
# Copyright 2021-2023 The MathWorks, Inc.
# Builds Docker image with 
# 1. MATLAB - Using MPM
# 2. MATLAB Integration for Jupyter
# on a base image of jupyter/base-notebook.

## Sample Build Command:
# docker build --build-arg MATLAB_RELEASE=r2023a \
#              --build-arg MATLAB_PRODUCT_LIST="MATLAB Deep_Learning_Toolbox Symbolic_Math_Toolbox"\
#              --build-arg LICENSE_SERVER=12345@hostname.com \
#              -t my_matlab_image_name .

# Specify release of MATLAB to build. (use lowercase, default is r2023a)
ARG MATLAB_RELEASE=r2023a

# Specify the list of products to install into MATLAB, 
ARG MATLAB_PRODUCT_LIST="MATLAB"

# Optional Network License Server information
ARG LICENSE_SERVER

# If LICENSE_SERVER is provided then SHOULD_USE_LICENSE_SERVER will be set to "_use_lm"
ARG SHOULD_USE_LICENSE_SERVER=${LICENSE_SERVER:+"_with_lm"}

# Default DDUX information
ARG MW_CONTEXT_TAGS=MATLAB_PROXY:JUPYTER:MPM:V1

# Base Jupyter image without LICENSE_SERVER
FROM harbor.cloud.infn.it/datacloud-templates/jaas_user_containers:1.2.0 AS base_jupyter_image

# Base Jupyter image with LICENSE_SERVER
FROM harbor.cloud.infn.it/datacloud-templates/jaas_user_containers:1.2.0 AS base_jupyter_image_with_lm
ARG LICENSE_SERVER
# If license server information is available, then use it to set environment variable
ENV MLM_LICENSE_FILE=${LICENSE_SERVER}

# Select base Jupyter image based on whether LICENSE_SERVER is provided
FROM base_jupyter_image${SHOULD_USE_LICENSE_SERVER} AS jupyter_matlab
ARG MW_CONTEXT_TAGS
ARG MATLAB_RELEASE
ARG MATLAB_PRODUCT_LIST

# Switch to root user
USER root
ENV DEBIAN_FRONTEND="noninteractive" TZ="Etc/UTC"

## Installing Dependencies for Ubuntu 20.04
# For MATLAB : Get base-dependencies.txt from matlab-deps repository on GitHub
# For mpm : wget, unzip, ca-certificates
# For MATLAB Integration for Jupyter : xvfb
# List of MATLAB Dependencies for Ubuntu 20.04 and specified MATLAB_RELEASE
ARG MATLAB_DEPS_REQUIREMENTS_FILE="https://raw.githubusercontent.com/mathworks-ref-arch/container-images/main/matlab-deps/${MATLAB_RELEASE}/ubuntu20.04/base-dependencies.txt"
ARG MATLAB_DEPS_REQUIREMENTS_FILE_NAME="matlab-deps-${MATLAB_RELEASE}-base-dependencies.txt"

# Install dependencies
RUN wget ${MATLAB_DEPS_REQUIREMENTS_FILE} -O ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME} \
    && export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && xargs -a ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME} -r apt-get install --no-install-recommends -y \
    wget \
    unzip \
    ca-certificates \
    xvfb \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME}

# Run mpm to install MATLAB in the target location and delete the mpm installation afterwards
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm && \ 
    chmod +x mpm && \
    ./mpm install \
    --release=${MATLAB_RELEASE} \
    --destination=/opt/matlab \
    --products ${MATLAB_PRODUCT_LIST} && \
    rm -f mpm /tmp/mathworks_root.log && \
    ln -s /opt/matlab/bin/matlab /usr/local/bin/matlab

# Install patched glibc - See https://github.com/mathworks/build-glibc-bz-19329-patch
WORKDIR /packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get clean && apt-get autoremove && \
    wget -q https://github.com/mathworks/build-glibc-bz-19329-patch/releases/download/ubuntu-focal/all-packages.tar.gz && \
    tar -x -f all-packages.tar.gz \
    --exclude glibc-*.deb \
    --exclude libc6-dbg*.deb && \
    apt-get install --yes --no-install-recommends --allow-downgrades ./*.deb && \
    rm -fr /packages
WORKDIR /

# Optional: Install MATLAB Engine for Python, if possible. 
# Note: Failure to install does not stop the build.
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get install --no-install-recommends -y  python3-distutils \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && cd /opt/matlab/extern/engines/python \
    && python3 setup.py install || true

ENV BASE_CACHE_DIR="/usr/local/share/dodasts/sts-wire/cache"

RUN mkdir -p ${BASE_CACHE_DIR} && \
    mkdir -p /usr/local/share/dodasts/sts-wire/cache && \
    mkdir -p /var/log/sts-wire/ && \
    mkdir -p /s3/scratch

# Switch back to notebook user
RUN adduser --disabled-password --group --system --gecos '' --home /home/matlabuser matlabuser && \
    sed -i 's#/opt#/home/matlabuser#g' /.init/spawn.sh && \
    chmod -R g+w /s3 && chgrp -R matlabuser /s3 && \
    chmod -R g+w /.init && chgrp -R matlabuser /.init && \
    chmod -R g+w /workarea && chgrp -R matlabuser /workarea && \
    chmod -R g+w /var/log/sts-wire && chgrp -R matlabuser /var/log/sts-wire && \
    chmod -R g+w /usr/local/share/dodasts/sts-wire && chgrp -R matlabuser /usr/local/share/dodasts/sts-wire

# Install MATLAB HTCondor Plugin
RUN chown matlabuser:matlabuser -R /home/matlabuser

ENV MW_CONTEXT_TAGS=${MW_CONTEXT_TAGS}

CMD /.init/spawn.sh

USER matlabuser
WORKDIR /workarea
