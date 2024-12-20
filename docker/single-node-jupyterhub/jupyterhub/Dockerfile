# Image name: snj-base-jhub
FROM jupyterhub/jupyterhub:4.1.5

#RUN mkdir -p /.init
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget  && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir -U \
            # dockerspawner==13.0.0 latest in 2024-10-02
            dockerspawner \ 
            jupyterhub-idle-culler \
            jupyterhub-kubespawner==7.0.0 \
            kubernetes \
            # oauthenticator >= 16.0.0 not compatible
            oauthenticator==15.1.0  \
            pip \
            pyjwt \
            setuptools \
            wheel 
                                              
COPY jupyterhub_config.py /srv/jupyterhub/