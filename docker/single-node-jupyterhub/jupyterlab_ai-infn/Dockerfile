# Image name: harbor.cloud.infn.it/datacloud-templates/jlab-ai-infn:1.3.0-1-v4.0.5
ARG BASE_IMAGE="harbor.cloud.infn.it/datacloud-templates/snj-base-lab:1.3.0-1" 
FROM ${BASE_IMAGE}

# RUN splitted to Install apptainer, cvmfs and openssh-server
# Install apptainer, cvmfs and openssh-server
RUN apt update && \
    apt install -y gnupg2 && \
    apt install -y \
        lsb-release \
        software-properties-common \
        wget && \
    wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb && \
    dpkg -i cvmfs-release-latest_all.deb && \
    add-apt-repository -y ppa:apptainer/ppa && \
    apt-get clean && rm -rf /var/lib/apt/lists/* cvmfs-release-latest_all.deb && \
    apt update --allow-unauthenticated && \
    apt install -y \
      apptainer \
      cvmfs \
      cvmfs-fuse3 \
      cvmfs-libs \
      libgl1-mesa-glx \
      openssh-server \
      xvfb \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

# Install customized JuiceFS client
ADD https://pandora.infn.it/public/3423df/dl/juicefs /usr/bin/juicefs 
RUN chmod a+rx /usr/bin/juicefs 

# Install sts-wire
ADD https://repo.cloud.cnaf.infn.it/repository/sts-wire/sts-wire-linux/2.1.5/sts-wire-linux-2.1.5 /usr/local/bin/sts-wire
RUN chmod +x /usr/local/bin/sts-wire

# Changes the home directory of the user to private
RUN sed -i 's/:\/root:/:\/home\/private:/g' /etc/passwd

# Import configuration of sshd
COPY ./sshd.conf /etc/ssh/sshd_config.d/aiinfn.conf 

# Clean home of default jupyter user
RUN rm -rf /home/jovyan

WORKDIR /home
ENTRYPOINT []