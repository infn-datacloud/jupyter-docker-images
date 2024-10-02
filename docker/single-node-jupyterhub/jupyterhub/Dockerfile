# Image name: snj-base-jhub
FROM jupyterhub/jupyterhub:4.1.5

#RUN mkdir -p /.init
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget  && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir -U \
            dockerspawner \
            jupyterhub-idle-culler \
            oauthenticator==14.2.0 \
            pip \
            pyjwt \
            setuptools \
            wheel 
                                              
COPY jupyterhub_config.py /srv/jupyterhub/