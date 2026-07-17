# Image name: harbor.cloud.infn.it/datacloud-jupyter/jlab-ai-infn:2.3.0-ai1.5
ARG BASE_IMAGE="harbor.cloud.infn.it/datacloud-jupyter/jlab-base:2.3.0"
FROM ${BASE_IMAGE}

# Apptainer: the PPA exists only for Ubuntu; on Debian 13 we use the official
# .deb with the "trixie+" suffix (compatible with Trixie's libfuse3)
ARG APPTAINER_VERSION=1.5.2

# Install apptainer, cvmfs-libs, openssh-server e stack remote-desktop
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb && \
    dpkg -i cvmfs-release-latest_all.deb && \
    wget https://github.com/apptainer/apptainer/releases/download/v${APPTAINER_VERSION}/apptainer_${APPTAINER_VERSION}-trixie+_amd64.deb && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ./apptainer_${APPTAINER_VERSION}-trixie+_amd64.deb \
#      cvmfs \
#      cvmfs-fuse3 \
      cvmfs-libs \
      libgl1 \
      openssh-server \
      xvfb \
      # Remote desktop:
      dbus-x11 \
      xorg \
      xfce4 xfce4-panel xfce4-session xfce4-settings breeze-icon-theme kde-plasma-desktop \
      tigervnc-standalone-server \
    && \
    mkdir -p /run/sshd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* cvmfs-release-latest_all.deb apptainer_${APPTAINER_VERSION}-trixie+_amd64.deb

# Install snakemake Python modules
# (version constraints must be quoted: an unquoted ">=" is a shell redirection)
RUN python3 -m pip install --no-cache-dir \
      jupyter-remote-desktop-proxy \
      "snakemake-executor-plugin-cluster-generic>=1" \
      snakemake-storage-plugin-s3 \
      git+https://github.com/landerlini/snakemake-storage-plugin-webdav \
      git+https://github.com/landerlini/snakemake-storage-plugin-fs \
      git+https://github.com/landerlini/snakemake-storage-helper \
      "snakemake>=9.11"

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

# Enable defining secondary groups through env var $NB_GROUPS
COPY ./create_user_groups.py /usr/local/bin/before-notebook.d/05_create_user_groups.py
RUN chmod a+rx /usr/local/bin/before-notebook.d/05_create_user_groups.py

RUN echo "rm -rf /home/jovyan" >  /usr/local/bin/before-notebook.d/99_cleanup_jovyan.sh
RUN chmod a+rx                    /usr/local/bin/before-notebook.d/99_cleanup_jovyan.sh

# The Debian 13 base no longer derives from docker-stacks: start.sh does not
# exist and the before-notebook.d hooks would never run. The wrapper runs them
# and then delegates to the base entrypoint (rclone/oidc init + tini).
COPY ./entrypoint.sh /usr/local/bin/entrypoint-aiinfn.sh
RUN chmod a+rx /usr/local/bin/entrypoint-aiinfn.sh

WORKDIR /home

ENTRYPOINT ["/usr/local/bin/entrypoint-aiinfn.sh"]
# Redefining ENTRYPOINT in a derived image resets the inherited CMD
CMD ["jupyterhub-singleuser", "--ip=0.0.0.0", "--port=8888", "--allow-root"]
