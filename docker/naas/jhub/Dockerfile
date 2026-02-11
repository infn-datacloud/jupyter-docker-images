# Image name: harbor.cloud.infn.it/datacloud-templates/jhub-naas:2.1.0

FROM jupyterhub/k8s-hub:4.3.0

USER root

RUN apt-get update && \
    apt-get -y install \
        vim \
        sudo \
        git \
        curl \
        ca-certificates \
        wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

#RUN wget "https://crt.sh/?d=2475254782" --no-check-certificate -O /usr/local/share/ca-certificates/ca.crt 
# RUN curl "https://crt.sh/?d=2475254782" --insecure --output /usr/local/share/ca-certificates/ca.crt && \
#     update-ca-certificates && \
#     wget https://baltig.infn.it/infn-cloud/web-site/-/raw/master/imgs/INFN_Cloud/Sito/selezione_sito_cloud/INFN_Cloud_logo_home.png -O /etc/logo.png && \
#     echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 

RUN curl "https://crt.sh/?d=2475254782" --insecure --output /usr/local/share/ca-certificates/ca.crt 
RUN update-ca-certificates 
RUN wget https://baltig.infn.it/infn-cloud/web-site/-/raw/master/imgs/INFN_Cloud/Sito/selezione_sito_cloud/INFN_Cloud_logo_home.png -O /etc/logo.png 
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 

# Use bash instead of dash
RUN rm /bin/sh && \
    ln -s /bin/bash /bin/sh

RUN pip install --upgrade pip && \
    pip install --upgrade urllib3 && \
    pip install kubernetes

CMD ["/usr/bin/start.sh", "jupyterhub"]