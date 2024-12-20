FROM jupyterhub/k8s-hub:0.11.1

USER root

RUN apt-get update && \
    apt-get -y install vim sudo git curl ca-certificates

RUN wget "https://crt.sh/?d=2475254782" -O /usr/local/share/ca-certificates/ca.crt && \                                      
    update-ca-certificates 

RUN wget https://baltig.infn.it/infn-cloud/web-site/-/raw/master/imgs/INFN_Cloud/Sito/selezione_sito_cloud/INFN_Cloud_logo_home.png -O /etc/logo.png

RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Use bash instead of dash
RUN rm /bin/sh && \
    ln -s /bin/bash /bin/sh

USER $NB_UID

CMD ["/usr/bin/start.sh", "jupyterhub"]
