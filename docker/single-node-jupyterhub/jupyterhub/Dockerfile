# Image name: snj-base-jhub
FROM jupyterhub/jupyterhub:1.5.0

RUN mkdir -p /.init

RUN python3 -m pip install --no-cache-dir -U pip==23.0.1 setuptools==67.6.0 wheel==0.40.0 && \
    python3 -m pip install --no-cache-dir \
    dockerspawner==12.1.0 \
    oauthenticator==14.2.0 \
    pyjwt==2.4.0 \
    jupyterhub-idle-culler==1.2.1

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget=1.20.3-1ubuntu2 && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY jupyterhub_config.py /srv/jupyterhub/
